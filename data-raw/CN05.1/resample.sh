# cdo remapbil,grid_china_2deg.txt CN05.1_Pre_1961_2018_month_025x025.nc CN05.1_2deg_Pre_1961_2018_month.nc
cdo remapbil,grid_china_1deg.txt CN05.1_Pre_1961_2018_month_025x025.nc CN05.1_1deg_Pre_1961_2018_month.nc

# EOF

cdo eof,6 CN05.1_1deg_Pre_1961_2018_month.nc a.nc b.nc
