#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from decimal import Decimal, getcontext
import json
from pathlib import Path
import re
import ssl
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request


@dataclass
class CoefficientRow:
    n: int
    m: int
    kind: str  # "g" or "h"
    values: list[str]


@dataclass
class IGRFDoc:
    file_name: str
    headers: list[str]
    header_numbers: list[str]
    epochs: list[str]
    coefficients: list[CoefficientRow]


ROOT = Path(__file__).resolve().parent
OUT_DIR = ROOT / "Sources" / "GeoMagSwift" / "models"
RES_DIR = ROOT / "Sources" / "GeoMagSwift" / "Resources"

DEFAULT_CONTEXT = None
URL_CONTEXT = None

getcontext().prec = 28


def _init_ssl_context() -> None:
    global DEFAULT_CONTEXT
    if DEFAULT_CONTEXT is not None:
        return
    try:
        import certifi

        DEFAULT_CONTEXT = ssl.create_default_context(cafile=certifi.where())
    except Exception:
        DEFAULT_CONTEXT = ssl.create_default_context()


def _http_text(url: str, retries: int = 3, backoff: float = 1.0) -> str:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": "GeoMagSwift/1.0 (data fetch)"},
    )
    context = URL_CONTEXT if URL_CONTEXT is not None else DEFAULT_CONTEXT
    last_err: Exception | None = None
    for attempt in range(retries):
        try:
            with urllib.request.urlopen(req, timeout=30, context=context) as resp:
                return resp.read().decode("utf-8")
        except urllib.error.URLError as err:
            last_err = err
            if attempt < retries - 1:
                time.sleep(backoff * (2 ** attempt))
                continue
            raise
        except ssl.SSLError as err:
            last_err = err
            if attempt < retries - 1:
                time.sleep(backoff * (2 ** attempt))
                continue
            raise
    raise urllib.error.URLError(last_err or "unknown error")


def _decimal_to_str(value: Decimal) -> str:
    text = format(value, "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text or "0"


def _parse_ncei_coeffs(text: str, file_name: str) -> IGRFDoc:
    headers: list[str] = []
    header_numbers: list[str] = []
    epochs: list[str] = []
    coefficients: list[CoefficientRow] = []

    lines = [line.rstrip() for line in text.splitlines()]
    non_comment: list[str] = []
    for line in lines:
        raw = line.strip()
        if not raw:
            continue
        if raw.startswith("#"):
            headers.append(raw.lstrip("#").strip())
            continue
        non_comment.append(raw)

    data_start = None
    for idx, line in enumerate(non_comment):
        lowered = line.lower()
        if lowered.startswith("g ") or lowered.startswith("h "):
            data_start = idx
            break
    if data_start is None:
        raise ValueError(f"No data rows found in {file_name}")

    header_lines = non_comment[:data_start]
    headers.extend(header_lines)

    column_header = header_lines[-1] if header_lines else ""
    tokens = column_header.split()
    epoch_tokens: list[str] = []
    sv_token: str | None = None
    for token in tokens[3:]:
        if re.match(r"^\d{4}(?:\.\d+)?$", token):
            epoch_tokens.append(token)
        elif re.match(r"^\d{4}-\d{2}$", token):
            sv_token = token

    if not epoch_tokens:
        raise ValueError(f"Could not parse epochs in {file_name}")

    epochs = list(epoch_tokens)
    sv_year_start: int | None = None
    sv_year_end: int | None = None
    if sv_token:
        start, end_suffix = sv_token.split("-")
        sv_year_start = int(start)
        end_year = (sv_year_start // 100) * 100 + int(end_suffix)
        if end_year < sv_year_start:
            end_year += 100
        sv_year_end = end_year
        epochs.append(f"{float(end_year):.1f}")

    data_lines = non_comment[data_start:]
    for line in data_lines:
        parts = line.split()
        if len(parts) < 4:
            continue
        kind = parts[0].lower()
        if kind not in ("g", "h"):
            continue
        n = int(parts[1])
        m = int(parts[2])
        values = parts[3:]
        if sv_token:
            if len(values) != len(epoch_tokens) + 1:
                raise ValueError(
                    f"Unexpected value count for {file_name} n={n} m={m}"
                )
            base_values = [Decimal(v) for v in values[:-1]]
            sv_value = Decimal(values[-1])
            delta_years = Decimal(sv_year_end - sv_year_start)
            predicted = base_values[-1] + sv_value * delta_years
            values = [_decimal_to_str(v) for v in base_values] + [
                _decimal_to_str(predicted)
            ]
        coefficients.append(CoefficientRow(n=n, m=m, kind=kind, values=values))

    return IGRFDoc(
        file_name=file_name,
        headers=headers,
        header_numbers=header_numbers,
        epochs=epochs,
        coefficients=coefficients,
    )


def _swift_string(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace('"', "\\\"")
        .replace("\n", "\\n")
    )


def _model_name(doc: IGRFDoc) -> str:
    match = re.search(r"(\d+)", doc.file_name)
    suffix = match.group(1) if match else doc.file_name
    return f"igrf{suffix}"


def _write_model_file(doc: IGRFDoc) -> None:
    model_name = _model_name(doc)
    file_name = f"SHCModel+{model_name}.swift"
    out_path = OUT_DIR / file_name
    lines: list[str] = []
    lines.append("import Foundation")
    lines.append("")
    lines.append("public extension SHCModel {")
    # 添加详细的中英文注释
    lines.append("    /// 国际地磁参考场 (IGRF) 模型")
    lines.append("    ///")
    lines.append(f"    /// International Geomagnetic Reference Field (IGRF) model")
    lines.append("    ///")
    lines.append("    /// 该模型是由国际地磁学与高空大气物理学协会 (IAGA) 发布的全球地磁场参考模型，")
    lines.append("    /// 用于描述地球磁场的空间分布和时间变化。IGRF 模型是一个球谐系数模型，")
    lines.append("    /// 包含了地磁场的基本结构和长期变化。")
    lines.append("    ///")
    lines.append("    /// This model is a global reference model of the Earth's magnetic field published by the")
    lines.append("    /// International Association of Geomagnetism and Aeronomy (IAGA). It is used to describe")
    lines.append("    /// the spatial distribution and temporal variation of the Earth's magnetic field.")
    lines.append("    /// The IGRF model is a spherical harmonic coefficient model that includes the")
    lines.append("    /// basic structure and secular variation of the magnetic field.")
    lines.append("    ///")
    lines.append(f"    /// 模型文件: {doc.file_name}")
    lines.append(f"    /// Model file: {doc.file_name}")
    if doc.epochs:
        epochs_str = ", ".join(doc.epochs)
        lines.append("    ///")
        if len(doc.epochs) >= 2:
            lines.append(
                f"    /// 有效 epoch: {doc.epochs[0]}–{doc.epochs[-1]} (共 {len(doc.epochs)} 个)"
            )
            lines.append(
                f"    /// Valid epochs: {doc.epochs[0]}–{doc.epochs[-1]} ({len(doc.epochs)} total)"
            )
        else:
            lines.append(f"    /// 有效 epoch: {epochs_str}")
            lines.append(f"    /// Valid epochs: {epochs_str}")
    lines.append(f"    static let {model_name}: SHCModel = SHCModel.requiredResource(\"{model_name}\")")
    lines.append("}")
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    payload = {
        "fileName": doc.file_name,
        "headers": doc.headers,
        "headerNumbers": [float(value) for value in doc.header_numbers],
        "epochs": [float(value) for value in doc.epochs],
        "validFrom": float(doc.epochs[0]) if doc.epochs else None,
        "validTo": float(doc.epochs[-1]) if doc.epochs else None,
        "coefficients": [
            {
                "n": row.n,
                "m": row.m,
                "kind": row.kind,
                "values": [float(value) for value in row.values],
            }
            for row in doc.coefficients
        ],
    }
    resource_path = RES_DIR / f"{model_name}.json"
    resource_path.write_text(
        json.dumps(payload, separators=(",", ":"), allow_nan=False) + "\n",
        encoding="utf-8",
    )


def _clean_output() -> None:
    if OUT_DIR.exists():
        for path in OUT_DIR.glob("SHCModel+igrf*.swift"):
            path.unlink()
    if RES_DIR.exists():
        for path in RES_DIR.glob("igrf*.json"):
            path.unlink()


def _write_swift(docs: list[IGRFDoc]) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    RES_DIR.mkdir(parents=True, exist_ok=True)
    _clean_output()
    for doc in docs:
        _write_model_file(doc)


def _run_swift_format() -> None:
    swift_files = sorted(str(path) for path in OUT_DIR.glob("*.swift"))
    if not swift_files:
        return
    subprocess.run(
        ["swift-format", "format", "-i", *swift_files],
        check=True,
    )


def _candidate_versions(start: int = 19, end: int = 1) -> list[int]:
    return list(range(start, end - 1, -1))


def _coeffs_url(version: int) -> str:
    return f"https://www.ngdc.noaa.gov/IAGA/vmod/coeffs/igrf{version}coeffs.txt"


def _try_download(version: int) -> tuple[int, str, str] | None:
    url = _coeffs_url(version)
    try:
        text = _http_text(url)
    except urllib.error.HTTPError:
        return None
    except urllib.error.URLError as err:
        raise err
    return version, url, text


def _ask_yes_no(prompt: str, default: str = "y") -> bool:
    suffix = " [Y/n]: " if default.lower() == "y" else " [y/N]: "
    answer = input(prompt + suffix).strip().lower()
    if not answer:
        answer = default.lower()
    return answer in ("y", "yes")


def _ask_int(prompt: str, default: int) -> int:
    answer = input(f"{prompt} [{default}]: ").strip()
    if not answer:
        return default
    return int(answer)


def main() -> None:
    _init_ssl_context()
    global URL_CONTEXT

    print("IGRF data fetch (NCEI)")
    if _ask_yes_no("Use insecure TLS (only if your cert store fails)?", default="n"):
        URL_CONTEXT = ssl._create_unverified_context()

    start_version = _ask_int("Start searching from version", 19)
    print("Downloading all available coeffs files...")

    docs: list[IGRFDoc] = []
    for version in _candidate_versions(start=start_version, end=1):
        try:
            result = _try_download(version)
        except urllib.error.URLError as err:
            if isinstance(err.reason, ssl.SSLCertVerificationError):
                raise SystemExit(
                    "TLS verification failed. Re-run and choose insecure TLS."
                )
            print(f"Skipping IGRF-{version}: {err}")
            continue
        if not result:
            continue
        found_version, coeffs_url, text = result
        file_name = (
            Path(urllib.parse.urlparse(coeffs_url).path).name
            or f"igrf{found_version}coeffs.txt"
        )
        try:
            docs.append(_parse_ncei_coeffs(text, file_name))
        except ValueError as err:
            if "No data rows found" in str(err):
                print(f"Skipping {file_name}: {err}")
                continue
            raise

    if not docs:
        raise SystemExit("No igrf*coeffs.txt found in the requested range.")

    _write_swift(docs)
    _run_swift_format()


if __name__ == "__main__":
    main()
