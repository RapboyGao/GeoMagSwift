#!/usr/bin/env python3
"""Offline smoke tests for the three geomagnetic data generators."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import sys
import tempfile
import unittest
from decimal import Decimal


ROOT = Path(__file__).resolve().parents[1]


def load_generator(file_name: str):
    path = ROOT / file_name
    spec = importlib.util.spec_from_file_location(file_name.removesuffix(".py"), path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load generator {path}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class GeneratorSmokeTests(unittest.TestCase):
    def check_writer(self, module, doc, version: int, model_name: str) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            module.OUT_DIR = root / "models"
            module.RES_DIR = root / "Resources"
            module.OUT_DIR.mkdir()
            module.RES_DIR.mkdir()

            sentinel = module.OUT_DIR / "SHCModel+unrelated.swift"
            sentinel.write_text("sentinel\n", encoding="utf-8")

            if hasattr(doc, "epochs"):
                module._write_model_file(doc)
            else:
                module._write_model_file(doc, version)

            stub = (module.OUT_DIR / f"SHCModel+{model_name}.swift").read_text(encoding="utf-8")
            self.assertIn(f'SHCModel.requiredResource("{model_name}")', stub)
            self.assertNotIn("try!", stub)

            resource = json.loads(
                (module.RES_DIR / f"{model_name}.json").read_text(encoding="utf-8")
            )
            if hasattr(doc, "epoch"):
                expected_epochs = [float(doc.epoch), float(doc.epoch + Decimal(5))]
            else:
                expected_epochs = [float(Decimal(value)) for value in doc.epochs]
            self.assertEqual(resource["epochs"], expected_epochs)
            self.assertTrue(resource["coefficients"])

            module._clean_output()
            self.assertTrue(sentinel.exists())
            self.assertFalse((module.OUT_DIR / f"SHCModel+{model_name}.swift").exists())
            self.assertFalse((module.RES_DIR / f"{model_name}.json").exists())

    def test_igrf_generator(self) -> None:
        module = load_generator("generate_igrf_data.py")
        row = module.CoefficientRow(n=1, m=0, kind="g", values=["1", "2"])
        doc = module.IGRFDoc(
            file_name="igrf14coeffs.txt",
            headers=["test"],
            header_numbers=[],
            epochs=["2020.0", "2025.0"],
            coefficients=[row],
        )
        self.check_writer(module, doc, 14, "igrf14")

    def test_wmm_generator(self) -> None:
        module = load_generator("generate_wmm_data.py")
        row = module.CoefficientRow(n=1, m=0, kind="g", values=["1", "2"])
        doc = module.WMMDoc(
            file_name="WMM.COF",
            header="2025.0 WMM test",
            epoch=Decimal("2025.0"),
            coefficients=[row],
        )
        self.check_writer(module, doc, 2025, "wmm2025")

    def test_wmmhr_generator(self) -> None:
        module = load_generator("generate_wmmhr_data.py")
        row = module.CoefficientRow(n=1, m=0, kind="g", values=["1", "2"])
        doc = module.WMMHRDoc(
            file_name="WMMHR.COF",
            header="2025.0 WMMHR test",
            epoch=Decimal("2025.0"),
            coefficients=[row],
        )
        self.check_writer(module, doc, 2025, "wmmhr2025")


if __name__ == "__main__":
    unittest.main()
