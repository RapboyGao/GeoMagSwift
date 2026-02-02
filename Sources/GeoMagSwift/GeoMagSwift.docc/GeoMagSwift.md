# ``GeoMagSwift``

GeoMagSwift provides fast, offline geomagnetic field computation based on spherical harmonic coefficient (SHC) models such as IGRF and WMM.

*Looking for Chinese? → <doc:GeoMagSwift-zh>*

## Overview

- Compute magnetic field components (north/east/down), declination, inclination, and intensity.
- Support multiple model generations (IGRF/WMM/WMMHR).
- Deterministic and suitable for navigation, mapping, and scientific analysis.
- Designed to run without network access once model data is embedded.

## Repository

- GitHub: [RapboyGao/GeoMagSwift](https://github.com/RapboyGao/GeoMagSwift)

## Computation Flow

![GeoMagSwift computation flow diagram](geomag-computation-flow.svg)

## Mathematical Flow (Detailed)

![GeoMagSwift detailed mathematical flow diagram](geomag-math-flow.svg)

## SHCModel Explained (Plain Language)

`SHCModel` is a mathematical description of Earth’s magnetic field. Think of it like a global “map” of magnetism that can be queried at any location and time. The model stores numbers (coefficients) for a set of reference years and lets us compute the magnetic field for dates in between.

What it contains:

- `epochs`: a list of reference years like `2020.0`, `2025.0`.
- `coefficients`: tables of numbers named `g(n,m)` and `h(n,m)` for each epoch.
- `nmax`: how detailed the model is (higher means more detail).
- `validFrom` / `validTo`: the recommended time range.

## The Big Picture

We compute a magnetic **potential** first, then take its **gradient** to get the magnetic field. You do not need to compute these by hand; this is just the idea.

### 1) The magnetic potential

The model represents a scalar potential `V` around Earth:

![Magnetic potential equation](equation-potential.svg)

What the symbols mean (simple explanation):

- `V`: magnetic potential (a scalar field).
- `a`: Earth reference radius (a fixed constant).
- `r`: distance from Earth’s center to your point.
- `θ` (theta): colatitude = 90° − latitude.
- `λ` (lambda): longitude.
- `n, m`: indices for the spherical harmonics (like rows/columns of detail).
- `g(n,m), h(n,m)`: model coefficients (numbers from the dataset).
- `P(n,m)`: associated Legendre functions (special polynomials).
- `Σ`: sum (add up all terms).

### 2) Magnetic field from potential

The magnetic field `B` is the negative gradient of `V`:

`B = -∇V`

In plain terms: “take the spatial rate of change of the potential.” The library does this internally.

## Step-by-step Computation (Beginner Friendly)

### Step 1 — Convert date to decimal year

A date like 2025-07-01 becomes a number like `2025.5`. This makes interpolation easy.

### Step 2 — Interpolate coefficients between epochs

If the model has data for 2025.0 and 2030.0, and your date is 2027.5, we blend values linearly:

![Interpolation equations](equation-interpolation.svg)

- `t`: your decimal year
- `t0`, `t1`: surrounding epochs
- `frac`: how far between the two you are (0 to 1)

### Step 3 — Compute field components

Using the interpolated coefficients, we evaluate the spherical harmonics to obtain the field components in a local coordinate system:

- `X` = north component
- `Y` = east component
- `Z` = down component

### Step 4 — Compute derived quantities

From `X, Y, Z`, we compute the values people commonly use:

![Derived magnetic quantities equations](equation-derived.svg)

Plain meaning:

- `H`: strength of the horizontal field
- `F`: total field strength
- `D`: how far magnetic north is from true north (angle)
- `I`: angle the field dips into the ground

### Step 5 — Secular variation (SV)

The model also provides how the field changes per year. It calculates derivatives by comparing epochs, then propagates them to `H`, `F`, `D`, and `I`.

## Topics

### Models

- ``SHCModel``

### Results

- ``MagneticFieldSolution``
- ``MagneticFieldResult``
- ``MagneticFieldSecularVariation``
