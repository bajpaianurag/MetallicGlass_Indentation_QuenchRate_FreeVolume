python d2min.py
python load_depth_headness_modulus.py > indent_summary
cp ../CFG/indent_400000.cfg final.cfg
#python free.py --use-radii --radii "Cu=1.28,Al=1.43,Ti=1.47,Zr=1.60" --export-per-atom final.cfg
#python rdf.py
python bond.py final.cfg
python voronoi.py
