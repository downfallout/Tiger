# Tiger

Author: Robert Luke

This is my automated scoring program for side looking anomaly detection.  (It can also be used for downward or forward looking detection)

The program takes as input a configuration file name.  This configuration file has the following format,

Halo size in meters
Offset X Direction, Offset Y Direction
Target type scoring S1 S2 S3 S4 S5
Date/Lane boundary file, Date/Emplacement truth file, SystemName/GroupName/Date/alarm file, run name
Date/Lane boundary file, Date/Emplacement truth file, SystemName/GroupName/Date/alarm file, run name
...
Date/Lane boundary file, Date/Emplacement truth file, SystemName/GroupName/Date/alarm file, run name


The "Target type scoring" variables define how target categories are scored. 
S1 = True targets.
S2 = Natural clutter. (Single rock, Bush)
S3 = Manmade clutter. (Cinder block wall)
S4 = Natural manmade clutter.  (Pile of rocks placed by tester)
S5 = Target like clutter. (Metal car parts, soda can)
0 = Treat category as true targets.
1 = Treat category as false alarms.
2 = Disregard all alarms to targets in this category category.
Usually this will be 0 1 1 1 0.  If you want to treat target like clutter as false alarms, 0 1 1 1 1.  If you want to disregard target like clutter, 0 1 1 1 2.

The program takes a second parameter which is the name prefix of saved figures.  If you do not wish to save out the figures, do not pass a second parameter. This is used with "run name" parameter of each line.

To run the scorer in Matlab use the command,

[allPD, allFA, allConfsSorted] = Tiger('configFileName');

To run the scorer in Matlab and store the plots, include a name for the files saved.

[allPD, allFA, allConfsSorted] = Tiger('configFileName', 'saveFileName');

configFileName will have the format: SystemName/GroupName/Date/config file name (i.e. 'Akela\MU\Apr15\configTigerEFPMUAkelaClassifierLane88S.txt')
