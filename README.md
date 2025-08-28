# MD-Based Study of Free Volume and Indentation in Metallic Glasses

This repository contains all input scripts, analysis tools, and dataset references used in the study:

> **“Compositional Complexity Suppresses Free Volume Sensitivity and Stabilizes Mechanical Response in Metallic Glasses”**

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
   - Edit or copy the provided structure generators (e.g., `scripts/` or `models/`) to define composition and supercell size.
   - Confirm interatomic potentials (EAM/MEAM/ML) in LAMMPS input files.

2. **Run melt–quench MD**
   - LAMMPS input files (temperature schedules, thermostats/barostats) are provided in this repo .
   - Output trajectories (`.dump`, `.lammpstrj`, `.xyz`) and thermodynamic logs will be written to `results/` or run-specific folders.

3. **Indentation simulations**
   - Configure indenter radius, velocity, and target depth in the LAMMPS inputs.
   - Post-process load–depth curves to extract hardness, modulus, and serration statistics with the analysis scripts.

4. **Free volume & structural analysis**
   - Use analysis scripts/notebooks in `analysis/` or `notebooks/` to compute Voronoi metrics, free-volume proxies, and STZ maps.
   - Scripts export CSV/Parquet tables for figure-ready plots.

5. **Recreate figures**
   - Open notebooks in `notebooks/` (or similarly named directory) and run top-to-bottom.
   - Figures are saved to `figures/` with publication-ready resolutions.


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

## Datasets

- Raw/processed data live under `data/`, `datasets/`, or `results/` as detected at clone time.
- Large raw trajectories may be stored externally; see placeholders or notes inside the folders for retrieval instructions.

## Citing

If this repository was useful, please cite:

```
@article{MGFreeVolumeIndentation,
  title   = {{Compositional Complexity Suppresses Free Volume Sensitivity and Stabilizes Mechanical Response in Metallic Glasses}},
  author  = {<Author List>},
  journal = {<Journal>},
  year    = {2025},
  doi     = {<doi>}
}
```

Alternatively, include `CITATION.cff` if present in the repository.

## License

This project is released under the license specified in `LICENSE` (if present). If no license is included, please choose and add one (e.g., MIT, BSD-3-Clause, Apache-2.0) to clarify permitted use.

## Contact

- Maintainer: <Your Name / Group>
- Affiliation: <Institution>
- Email: <contact@domain>
- Issues & Questions: Please open a GitHub Issue.

---

**Notes**: This README was auto-generated by scanning the repository contents and inferring environments and workflows. Please adapt file paths, figure names, and parameter ranges to match the final repository layout.
