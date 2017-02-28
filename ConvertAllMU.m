
baseDir = 'C:\Users\Bob\Documents\MATLAB\TigerEFP\Alarms\Stalker\MU\';

d = dir([baseDir '*.ele']);
%for i=1:length(d)
%    ConvertMUAlarm([baseDir d(i).name]);
%end;

CatConvertMUAlarm([baseDir 'YPGBT026_cmult_hits_conf.ele'], [baseDir 'YPGBT027_cmult_hits_conf.ele'], [baseDir 'YPGBT026_027_cmult_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT036_cmult_hits_conf.ele'], [baseDir 'YPGBT037_cmult_hits_conf.ele'], [baseDir 'YPGBT036_037_cmult_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT024_cmult_hits_conf.ele'], [baseDir 'YPGBT025_cmult_hits_conf.ele'], [baseDir 'YPGBT024_025_cmult_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT028_cmult_hits_conf.ele'], [baseDir 'YPGBT029_cmult_hits_conf.ele'], [baseDir 'YPGBT028_029_cmult_hits_conf.alm']);

CatConvertMUAlarm([baseDir 'YPGBT026_energy_hits_conf.ele'], [baseDir 'YPGBT027_energy_hits_conf.ele'], [baseDir 'YPGBT026_027_energy_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT036_energy_hits_conf.ele'], [baseDir 'YPGBT037_energy_hits_conf.ele'], [baseDir 'YPGBT036_037_energy_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT024_energy_hits_conf.ele'], [baseDir 'YPGBT025_energy_hits_conf.ele'], [baseDir 'YPGBT024_025_energy_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT028_energy_hits_conf.ele'], [baseDir 'YPGBT029_energy_hits_conf.ele'], [baseDir 'YPGBT028_029_energy_hits_conf.alm']);

CatConvertMUAlarm([baseDir 'YPGBT026_rx_hits_conf.ele'], [baseDir 'YPGBT027_rx_hits_conf.ele'], [baseDir 'YPGBT026_027_rx_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT036_rx_hits_conf.ele'], [baseDir 'YPGBT037_rx_hits_conf.ele'], [baseDir 'YPGBT036_037_rx_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT024_rx_hits_conf.ele'], [baseDir 'YPGBT025_rx_hits_conf.ele'], [baseDir 'YPGBT024_025_rx_hits_conf.alm']);
CatConvertMUAlarm([baseDir 'YPGBT028_rx_hits_conf.ele'], [baseDir 'YPGBT029_rx_hits_conf.ele'], [baseDir 'YPGBT028_029_rx_hits_conf.alm']);