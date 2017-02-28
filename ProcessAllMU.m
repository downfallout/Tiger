
close all;

TigerEFP('configTigerEFPMULane60NEmp1cmult.txt', 'MU60NEmp1cmult');
TigerEFP('configTigerEFPMULane60NEmp1energy.txt', 'MU60NEmp1energy');
TigerEFP('configTigerEFPMULane60NEmp1rx.txt', 'MU60NEmp1rx');
TigerEFP('configTigerEFPMULane60NEmp1.5cmult.txt', 'MU60NEmp1.5cmult');
TigerEFP('configTigerEFPMULane60NEmp1.5energy.txt', 'MU60NEmp1.5energy');
TigerEFP('configTigerEFPMULane60NEmp1.5rx.txt', 'MU60NEmp1.5rx');


TigerEFP('configTigerEFPMULane88SEmp1cmult.txt', 'MU88SEmp1cmult');
TigerEFP('configTigerEFPMULane88SEmp1energy.txt', 'MU88SEmp1energy');
TigerEFP('configTigerEFPMULane88SEmp1rx.txt', 'MU88SEmp1rx');
TigerEFP('configTigerEFPMULane88SEmp1.5cmult.txt', 'MU88SEmp1.5cmult');
TigerEFP('configTigerEFPMULane88SEmp1.5energy.txt', 'MU88SEmp1.5energy');
TigerEFP('configTigerEFPMULane88SEmp1.5rx.txt', 'MU88SEmp1.5rx');


close all;

figure(1); CompareROCs('MU60NEmp1cmult', 'MU60NEmp1energy', 'MU60NEmp1rx')
figure(2); CompareROCs('MU60NEmp1.5cmult', 'MU60NEmp1.5energy', 'MU60NEmp1.5rx')

figure(3); CompareROCs('MU88SEmp1cmult', 'MU88SEmp1energy', 'MU88SEmp1rx')
figure(4); CompareROCs('MU88SEmp1.5cmult', 'MU88SEmp1.5energy', 'MU88SEmp1.5rx')