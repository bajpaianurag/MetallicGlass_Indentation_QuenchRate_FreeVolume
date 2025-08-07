# MD-Based Study of Free Volume and Indentation in Metallic Glasses

This repository contains all input scripts, analysis tools, and dataset references used in the study:
**"Compositional Complexity Suppresses Free Volume Sensitivity and Stabilizes Mechanical Response in Metallic Glasses"** submitted to *Scripta Materialia*.

## Project Overview

We investigate how quench rate and compositional complexity influence free volume and mechanical behavior in Cu-Zr-based metallic glasses. The workflow includes:
- Atomistic model generation using Python + ASE
- Quenching and equilibration via LAMMPS
- Nanoindentation simulations
- Post-processing of load–depth curves, free volume, stress, and STZ activity using Python

## Repository Structure

```
scripts/
    ├── generate_structure.py         # Generate initial structures using ASE
    ├── quench_protocols/             # LAMMPS input files for quenching
    ├── indentation/                  # LAMMPS input files for nanoindentation
    └── analysis/                     # Python scripts for post-processing

data/
    └── compositions.xlsx                # Alloy compositions

requirements.txt                   # Python dependencies
README.md                          # This file
```

## Requirements

Install required packages using:

```bash
pip install -r requirements.txt
```

## How to Run

1. **Structure Generation**

```bash
python scripts/generate_structure.py
```

2. **Quenching (via LAMMPS)**

```bash
lmp_mpi -in scripts/quench_protocols/CuZr_quench_1e+11.in
```

3. **Indentation (via LAMMPS)**

```bash
lmp_mpi -in scripts/indentation/nanoindent.in
```

4. **Post-Processing**

```bash
python scripts/analysis/load_depth_analysis.py
python scripts/analysis/fv_d2min_analysis.py
```

## Key Analyses

- **Load–depth curve analysis**
- **Hardness/modulus extraction**
- **Non-affine displacement (D²_min) and STZ visualization**
- **Free volume distribution (Voronoi)**
- **Elastic recovery and residual strain mapping**


## Contact

For questions, please contact the corresponding authors:
**Dr. Anurag Bajpai**,**Dr. Jaemin Wang**   
Email: a.bajpai@mpie.de, j.wang@mpie.de

---
