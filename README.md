# MD-Based Study of Free Volume and Indentation in Metallic Glasses

This repository contains all input scripts, analysis tools, and dataset references used in the study:

> **“Compositional complexity reduces free-volume sensitivity and serrated flow in metallic glasses”**

## Overview

This codebase reproduces the molecular-dynamics (MD) workflows, analysis pipelines, and figure-generation scripts for studying how **quench rate** and **compositional complexity** control **free volume** and **nanoindentation** response in Cu–Zr–based metallic glasses and their multicomponent extensions. It includes:
- Atomic model construction (ASE), melt–quench schedules, and equilibration.
- Indentation simulations (LAMMPS), post-processing of P–h curves, hardness, and serration statistics.
- Free-volume quantification (Voronoi / Voronoi-like metrics, density-based proxies), STZ activity mapping, and structure–property links.
- Reproducible figure notebooks and helper utilities.

## Repository Structure

```
repo/
├── Github codes/
│   ├── Melt-Quench/
│   │   ├── postprocess/
│   │   │   ├── bond.py
│   │   │   ├── conv_cfg_script
│   │   │   ├── free.py
│   │   │   ├── rdf.py
│   │   │   ├── run.sh
│   │   │   └── voronoi.py
│   │   ├── lammps_script
│   │   ├── library.meam
│   │   ├── pot.meam
│   │   └── restart.equilib2
│   └── Nano-indentation/
│       ├── postprocess/
│       │   ├── bond.py
│       │   ├── d2min.py
│       │   ├── load_depth_headness_modulus.py
│       │   ├── run.sh
│       │   └── voronoi.py
│       ├── dump.post
│       ├── dump.pre
│       ├── indentation_out.load
│       ├── indentation_out.unload
│       ├── lammps_script
│       ├── library.meam
│       ├── pot.meam
│       └── restart.equilib2
├── plot_D2min.m
└── plot_freevolume.m
```

## Installation

We infer the following Python packages are used by this repo (edit as needed):

- ase
- lammps
- matplotlib
- numpy
- ovito
- pandas

**Install (pip)**
```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install ase lammps matplotlib numpy ovito pandas
```


## Quick Start

1. **Set up input structures**
   - Edit or copy the provided structure generators (`scripts/`) to define composition and supercell size.
   - Confirm interatomic potentials (EAM/MEAM/ML) in LAMMPS input files.

2. **Run melt–quench MD**
   - LAMMPS input files (temperature schedules, thermostats/barostats) are provided in this repo .
   - Output trajectories (`.dump`, `.lammpstrj`, `.xyz`) and thermodynamic logs will be written to `results/` or run-specific folders.

3. **Indentation simulations**
   - Configure indenter radius, velocity, and target depth in the LAMMPS inputs.
   - Post-process load–depth curves to extract hardness, modulus, and serration statistics with the analysis scripts.

4. **Free volume & structural analysis**
   - Use analysis scripts/notebooks to compute Voronoi metrics, free-volume proxies, and STZ maps.
   - Scripts export CSV/Parquet tables for figure-ready plots.

## Key Workflows

- **Structure generation**: Build multi-component amorphous models at target compositions; seed sizes for statistical robustness.
- **Melt–quench schedules**: Linear/cycling temperature ramps; NPT/NVT ensembles; quench-rate sweeps spanning 10¹²–10¹⁴ K/s (edit as applicable).
- **Indentation modeling**: Spherical indenter; depth-controlled or load-controlled indentation; recovery/relaxation steps.
- **Free volume metrics**: Voronoi indices, atomic Voronoi volumes (or proxies), local packing, and correlations with STZ activation.
- **Mechanical response**: P–h curves, unloading stiffness, Oliver–Pharr modulus/hardness, serration detection, statistics vs. quench rate.
- **Compositional complexity effects**: Compare binary vs. multicomponent glasses; sensitivity of free volume and indentation response.

## Reproducibility

- All random seeds are set in input scripts where applicable.
- Analysis scripts log versions and write intermediate datasets to `results/`.
- Use the provided environment files (or inferred requirements) to ensure consistent libraries.

## Contact

- Maintainer: Anurag Bajpai, Jaemin Wang
- Affiliation: Max-Planck-Institut for Sustainable Materials
- Email: a.bajpai@mpie.de, j.wang@mpie.de

---
