# Cu-Induced-Softening-in-BCC-Iron
# Effect of Cu Content on the Tensile Behavior of BCC Fe: A Molecular Dynamics Study

Molecular dynamics (MD) simulations of uniaxial tensile deformation in BCC iron with 0%, 2%, and 5% substitutional copper, using LAMMPS and an EAM/alloy potential. The goal is to quantify how Cu impurity content affects Young's modulus and ultimate tensile strength (UTS) at 300 K.

## Overview

- **Simulation engine:** LAMMPS
- **System:** BCC Fe supercell (15×15×15 unit cells, a = 2.855 Å, 6750 atoms), with a random fraction of atoms substituted with Cu
- **Potential:** Bonny, Pasianot, Malerba & Castin (2009), Fe-Cu-Ni EAM/alloy potential (*Phil. Mag.* 89, 3531)
- **Protocol:** Energy minimization → NPT equilibration at 300 K → NVT uniaxial tension along z at a strain rate of 0.005 ps⁻¹ (`fix deform erate`)
- **Post-processing:** MATLAB script fits the elastic region (0.01–0.035 strain) to extract Young's modulus and identifies UTS from the peak stress

## Results

| Cu content | Young's Modulus (GPa) | UTS (GPa) |
|---|---|---|
| 0% | 212.35 | 13.30 |
| 2% | 210.57 | 13.04 |
| 5% | 206.63 | 12.72 |

Both modulus and strength decrease modestly and monotonically with increasing Cu content, consistent with Cu substitution locally weakening the Fe matrix. The simulated modulus (~206–212 GPa) is close to the experimental value for bulk BCC Fe (~211 GPa), which is a useful sanity check on the potential and the fitting procedure.

![Stress-strain curves for 0/2/5% Cu](figures/Graph-1.png)

## Repository structure

```
.
├── simulation/
│   ├── in.tensile          # LAMMPS input script
│   ├── FeCuNi_eam.alloy    # EAM/alloy potential file (Bonny et al. 2009)
│   └── log.lammps          # Example LAMMPS run log
├── data/
│   ├── stress_strain_0_00.txt
│   ├── stress_strain_0_02.txt
│   ├── stress_strain_0_05.txt
│   └── Origin_Export.csv   # Combined data for plotting
├── dumps/
│   ├── dump_0_00.lammpstrj
│   ├── dump_0_02.lammpstrj
│   └── dump_0_05.lammpstrj
├── analysis/
│   └── process_data.m      # MATLAB: modulus/UTS extraction + CSV export
├── figures/
│   └── Graph-1.png
└── plot.opju                # OriginLab project file
```

## Reproducing the results

1. Run the LAMMPS simulation for each Cu fraction, e.g.:
   ```bash
   cd simulation
   lmp -in in.tensile -var cu_frac 0.00
   lmp -in in.tensile -var cu_frac 0.02
   lmp -in in.tensile -var cu_frac 0.05
   ```
   Each run writes `stress_strain_<cu_frac>.txt` and `dump_<cu_frac>.lammpstrj` using a dot in the filename (LAMMPS variable substitution). Rename these to match the `data/` and `dumps/` convention used here (underscore instead of dot), e.g. `stress_strain_0.05.txt` → `stress_strain_0_05.txt`.

2. Run the analysis script in MATLAB:
   ```matlab
   cd analysis
   process_data
   ```
   This prints the modulus/UTS summary and writes `data/Origin_Export.csv`.

3. Open `plot.opju` in OriginLab (or import `Origin_Export.csv` fresh) to reproduce the stress-strain figure.

## Notes and limitations

- The Cu distribution is generated with `set region ... type/fraction`, i.e. random substitution rather than clustering/precipitation — this models solid-solution Cu, not Cu precipitates.
- The strain rate (0.005 ps⁻¹, ~5×10⁹ s⁻¹) is many orders of magnitude higher than experimental tensile tests, as is standard for MD; absolute stress values are not directly comparable to experiment, but relative trends across Cu content are meaningful.
- The elastic-region fit window (0.01–0.035 strain) was chosen by inspection of the linear portion of the curves; it is hardcoded in `process_data.m` rather than automatically detected.

## citation

G. Bonny, R.C. Pasianot, L. Malerba, N. Castin, *Philosophical Magazine* 89 (2009) 3531.
