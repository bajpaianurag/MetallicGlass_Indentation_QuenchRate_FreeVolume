# MD-Based Study of Free Volume and Indentation in Metallic Glasses

**Repository for:**  
**“Compositional complexity suppresses quench-rate sensitivity and stabilizes nanoindentation response in Cu–Zr–based metallic glasses.”**

This repository provides input scripts, analysis tools, and figure recipes to reproduce our molecular-dynamics (MD) study that links **quench rate**, **compositional complexity**, and **mechanical response** in Cu–Zr-based metallic glasses (binary → ternary → quaternary).

We quantify structure and mechanics via:
- **Free volume** (radical Voronoi; FVHI, QRSI)
- **Short-range order** (icosahedral polyhedra)
- **Instrumented nanoindentation** (H, E, ER; serration density)
- **Non-affine displacement** (D^{2}_{min}) and **STZ clustering**
- **Compositional complexity** (CCI)

---

## Quick Start (5 steps)

1) **Create and activate a conda environment**
```bash
conda create -n mg-md python=3.11 -y
conda activate mg-md
pip install -r requirements.txt
```

2) **Unzip datasets and scripts** into the repository root (preserve folder names).

3) **(Optional) Build ~50k-atom structures with ASE**
```bash
python scripts/build_structures_50k.py --out data/initial/ --target 50000 --a 4.0
```

4) **Run LAMMPS**
- **Quench:**
```bash
lmp -in lammps/in.quench \
    -var infile data/initial/CuZr_50k.data \
    -var rate 1.0e11 \
    -var outfile data/quench/CuZr_1e11.data
```
- **Indent:**
```bash
lmp -in lammps/in.indent \
    -var datafile data/quench/CuZr_1e11.data \
    -var R 30 -var v 0.0005 -var dmax 20 \
    -var dumpbase dumps/CuZr_1e11
```

5) **Analyze & create figures**
```bash
# Load–depth, hardness/modulus, serrations
python analysis/load_depth_OP_serrations.py \
  --dump dumps/CuZr_1e11.dump.load \
  --log  logs/CuZr_1e11.log \
  --radius 30 --units metal \
  --out results/CuZr_1e11/

# Free volume (FVHI, QRSI, CCI)
python analysis/free_volume_metrics.py \
  --pre data/fv/CuZr_FV.xlsx \
  --rates 1e11 1e13 1e15 \
  --out results/fv/

# D²min & STZ clustering (3D voxel)
python analysis/d2min_stz_cluster.py \
  --xlsx data/d2min/CuZr_D2min.xlsx \
  --rates 1e11 1e13 1e15 \
  --out results/stz/
```

---

## Repository Layout

```
.
├── lammps/
│   ├── in.quench                 # NPT melt → quench → NVT relax (rates: 1e11–1e15 K/s)
│   ├── in.indent                 # Loading–unloading; R=3 nm, v=50 m/s, depth=2 nm
│   └── potentials/               # EAM/MEAM files (NIST repository)
├── scripts/
│   └── build_structures_50k.py   # ASE supercell + random assignment per target composition
├── analysis/
│   ├── load_depth_OP_serrations.py   # P–h curves, Oliver–Pharr, ER, pop-ins (S–G filter)
│   ├── free_volume_metrics.py        # FVHI, QRSI, CCI; histograms and rate trends
│   ├── d2min_stz_cluster.py          # D²min thresholding (μ+3σ far-field) + 3D clustering
│   ├── sro_voronoi_stats.py          # Voronoi polyhedra; icosahedral fractions pre/post
│   └── utils/                        # Shared helpers (I/O, smoothing, stats)
├── matlab/
│   ├── plot_D2min_three_alloys.m     # 2×3 D²min maps (XZ/XY/YZ), plasma/coolwarm
│   └── plot_freevolume_from_excel.m  # 3×3 free-volume maps (raw/Δ/z-score)
├── data/
│   ├── initial/                      # ASE outputs (.data/.lmp)
│   ├── quench/                       # LAMMPS data after quenching
│   ├── fv/                           # Free-volume spreadsheets (pre/post)
│   ├── d2min/                        # D²min spreadsheets per alloy/rate
│   └── voronoi/                      # Voronoi index distributions (pre/post)
├── dumps/                            # LAMMPS dumps: dump.load, dump.energy, .lammpstrj
├── logs/                             # Thermo output (for OP fits)
├── results/                          # CSVs, derived tables, figures
├── figures/                          # Camera-ready figures (Fig.1–5; SF1–SF8)
├── requirements.txt
└── README.md
```

---

## Details

### 0) Structure Build (ASE)
Generates supercells and assigns elements by composition:
- Binary: `Cu50Zr50`
- Ternary: `Cu47.5Zr47.5Al5`
- Quaternary: `Cu45Zr46.5Al7Ti1.5` (or your target)

```bash
python scripts/build_structures_50k.py \
  --comps CuZr CuZrAl CuZrAlTi \
  --target 50000 --a 4.0 \
  --out data/initial/
```

### 1) Quench Protocol (LAMMPS)
- NPT @ 2000 K → quench to 300 K at 10^11/10^13/10^15 K·s^-1  
- Final NVT relax @ 300 K  
- Potentials from NIST repository (cite specific files).

### 2) Nanoindentation (LAMMPS)
- Spherical indenter: R = 30 Å; v = 0.0005 Å/fs; max depth = 20 Å  
- Bottom 5 Å fixed; lateral shell NVT; indent region NVE  
- Dumps: `dump.load` (forces) and `dump.energy` (PE/KE/stress).

### 3) Mechanical Analysis
- Savitzky–Golay smoothing; pop-in detection  
- Oliver–Pharr unloading fit → **S**, **H**, **E**  
- Elastic recovery: ER = (h_max − h_res)/h_max

### 4) Free Volume Metrics
- Radical Voronoi volumes (pre/post) → **FVHI** = σ(V_free)/⟨V_free⟩  
- **QRSI** = |FV_fast − FV_slow| / FV_fast  
- **CCI** = (1/ln n) * [−∑ c_i ln c_i] (normalized Shannon entropy; n = species)

### 5) D²min & STZs
- Threshold by far-field **μ+3σ** (or P95)  
- Voxelize (edge ≈ 2.5 Å); label **26-connectivity** components  
- Report STZ **count density** and **plastic-zone volume**

### 6) Voronoi SRO
- ⟨0,0,12,0⟩ icosahedral fraction pre/post; Δf_ico

---

## Units & Conventions

- **LAMMPS units:** `metal` (Å, ps, eV)  
- Forces → N (SI) if needed; report **H, E** in **GPa**
- Contact area: spherical geometry; Oliver–Pharr stiffness from eV/Å² converted to SI

---

## Data & Reproducibility

- **Seeds:** N = 3 per condition; stored in `results/*/metadata.json`  
- **Workflow:** melt → quench (NPT) → relax (NVT) → indent (load/hold/unload) → dissipate  
- **Thresholds:** default STZ = far-field μ+3σ; robustness checked with P95.

---

## Contact

- **Maintainers:** Anurag Bajpai (a.bajpai@mpie.de), Jaemin Wang (j.wang@mpie.de) 
- **Supervision:** Dierk Raabe  
- Open a GitHub Issue with environment, command, and log snippet for support.
