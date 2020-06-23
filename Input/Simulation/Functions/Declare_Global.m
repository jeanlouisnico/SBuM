function Declare_Global(Input_Data, BuildSim, Nbr_Building)
global Housenbr	Layer1	Layer2	Layer3	StartDay	StartMonth	StartYear ...	
       EndDay	EndMonth	EndYear	Latitude	Longitude	User_Type ...
       	Building_Type	WindTurbine	PhotoVol	FuelCell ...
       WTPowertot	WindSpeed	Lambdanom	Cp	MaxPowerWT	Baserotspeed ...
       Pitch	EfficiencyWT	NbrmodTot	Nbrmodser	Nbrmodpar	Aspect ...
       Tilt	Voc	Isc	MaxPowerPV	LengthPV	WidthPV	NOCT	 ...
       		inhabitants	nbrRoom	WashMach ...
       	DishWash		Elec	Kettle		Oven ...
       	Coffee		MW		Toas		Waff ...
       	Fridge		Tele		Laptop	 ...
       Shaver		Hair		Stereo		Vacuum ...
       	Charger		Iron		Elecheat	Sauna ...
       Radio  	Metering	Self	Comp	Goal	Bill ...
       Building_Area	hgt	lgts	lgte	pitch	aws	awe	awn ...
       aww ad uvs uve uvn uvw	uvsw	uvew	uvnw	uvww	uvd	uvf ...
       uvr N0 HighNbHouse	HighNbrRoom	VTempCoff Appliance_Max nbr_appliances nbr_app_max
global Time_Step MaxPowerFC SolarData ContElec clDishWash clHair clFridge clTele ...
       clLight clRadio clLaptop clStereo clCharger clVacuum clWaff clOven ...
       clWashMach clKettle clToas clMW clIron clShaver clCoffee class_app
   % Alternatively, we could use
   % "find(strcmp('MaxPowerFC',Input_Data(1,:)))" for finding the column
   % number in which we want to look for. It decreases the speed though.
Housenbr = [Input_Data{BuildSim,1}];
Layer1 = [Input_Data{BuildSim,2}];
Layer2 = [Input_Data{BuildSim,3}];
Layer3 = [Input_Data{BuildSim,4}];
StartDay = [Input_Data{BuildSim,5}];
StartMonth = [Input_Data{BuildSim,6}];
StartYear = [Input_Data{BuildSim,7}];
EndDay = [Input_Data{BuildSim,8}];
EndMonth = [Input_Data{BuildSim,9}];
EndYear = [Input_Data{BuildSim,10}];
Latitude = [Input_Data{BuildSim,11}];
Longitude = [Input_Data{BuildSim,12}];
User_Type = [Input_Data{BuildSim,13}];
Time_Step = {Input_Data{BuildSim,14}};
Building_Type = [Input_Data{BuildSim,15}];
WindTurbine = [Input_Data{BuildSim,16}];
PhotoVol = [Input_Data{BuildSim,17}];
FuelCell = [Input_Data{BuildSim,18}];
WTPowertot = [Input_Data{BuildSim,19}];
WindSpeed = [Input_Data{BuildSim,20}];
Lambdanom = [Input_Data{BuildSim,21}];
Cp = [Input_Data{BuildSim,22}];
MaxPowerWT = [Input_Data{BuildSim,23}];
Baserotspeed = [Input_Data{BuildSim,24}];
Pitch = [Input_Data{BuildSim,25}];
EfficiencyWT = [Input_Data{BuildSim,26}];
NbrmodTot = [Input_Data{BuildSim,27}];
Nbrmodser = [Input_Data{BuildSim,28}];
Nbrmodpar = [Input_Data{BuildSim,29}];
Aspect = [Input_Data{BuildSim,30}];
Tilt = [Input_Data{BuildSim,31}];
Voc = [Input_Data{BuildSim,32}];
Isc = [Input_Data{BuildSim,33}];
MaxPowerPV = [Input_Data{BuildSim,34}];
LengthPV = [Input_Data{BuildSim,35}];
WidthPV = [Input_Data{BuildSim,36}];
NOCT = [Input_Data{BuildSim,37}];
MaxPowerFC = {Input_Data{BuildSim,38}};
SolarData = {Input_Data{BuildSim,39}};
ContElec = {Input_Data{BuildSim,40}};
inhabitants = [Input_Data{BuildSim,41}];
nbrRoom = [Input_Data{BuildSim,42}];
WashMach = [Input_Data{BuildSim,43}];
clWashMach = {Input_Data{BuildSim,44}};
DishWash = [Input_Data{BuildSim,45}];
clDishWash = {Input_Data{BuildSim,46}};
Elec = [Input_Data{BuildSim,47}];
Kettle = [Input_Data{BuildSim,48}];
clKettle = {Input_Data{BuildSim,49}};
Oven = [Input_Data{BuildSim,50}];
clOven = {Input_Data{BuildSim,51}};
Coffee = [Input_Data{BuildSim,52}];
clCoffee = {Input_Data{BuildSim,53}};
MW = [Input_Data{BuildSim,54}];
clMW = {Input_Data{BuildSim,55}};
Toas = [Input_Data{BuildSim,56}];
clToas = {Input_Data{BuildSim,57}};
Waff = [Input_Data{BuildSim,58}];
clWaff = {Input_Data{BuildSim,59}};
Fridge = [Input_Data{BuildSim,60}];
clFridge = {Input_Data{BuildSim,61}};
Tele = [Input_Data{BuildSim,62}];
clTele = {Input_Data{BuildSim,63}};
Laptop = [Input_Data{BuildSim,64}];
clLaptop = {Input_Data{BuildSim,65}};
Shaver = [Input_Data{BuildSim,66}];
clShaver = {Input_Data{BuildSim,67}};
Hair = [Input_Data{BuildSim,68}];
clHair = {Input_Data{BuildSim,69}};
Stereo = [Input_Data{BuildSim,70}];
clStereo = {Input_Data{BuildSim,71}};
Vacuum = [Input_Data{BuildSim,72}];
clVacuum = {Input_Data{BuildSim,73}};
Charger = [Input_Data{BuildSim,74}];
clCharger = {Input_Data{BuildSim,75}};
Iron = [Input_Data{BuildSim,76}];
clIron = {Input_Data{BuildSim,77}};
Elecheat = [Input_Data{BuildSim,78}];
Sauna = [Input_Data{BuildSim,79}];
Radio = [Input_Data{BuildSim,80}];
clRadio = {Input_Data{BuildSim,81}};
clLight = {Input_Data{BuildSim,82}};
Metering = [Input_Data{BuildSim,83}];
Self = [Input_Data{BuildSim,84}];
Comp = [Input_Data{BuildSim,85}];
Goal = [Input_Data{BuildSim,86}];
Bill = [Input_Data{BuildSim,87}];
myiter = [Input_Data{BuildSim,88}];
Building_Area = [Input_Data{BuildSim,89}];
hgt = [Input_Data{BuildSim,90}];
lgts = [Input_Data{BuildSim,91}];
lgte = [Input_Data{BuildSim,92}];
pitch = [Input_Data{BuildSim,93}];
aws = [Input_Data{BuildSim,94}];
awe = [Input_Data{BuildSim,95}];
awn = [Input_Data{BuildSim,96}];
aww = [Input_Data{BuildSim,97}];
ad = [Input_Data{BuildSim,98}];
uvs = [Input_Data{BuildSim,99}];
uve = [Input_Data{BuildSim,100}];
uvn = [Input_Data{BuildSim,101}];
uvw = [Input_Data{BuildSim,102}];
uvsw = [Input_Data{BuildSim,103}];
uvew = [Input_Data{BuildSim,104}];
uvnw = [Input_Data{BuildSim,105}];
uvww = [Input_Data{BuildSim,106}];
uvd = [Input_Data{BuildSim,107}];
uvf = [Input_Data{BuildSim,108}];
uvr = [Input_Data{BuildSim,109}];
N0 = [Input_Data{BuildSim,110}];
HighNbHouse = [Input_Data{BuildSim,111}];
HighNbrRoom = [Input_Data{BuildSim,112}];
VTempCoff = [Input_Data{BuildSim,113}];
Appliance_Max = [Input_Data{BuildSim,114}];


nbr_applinces = [0, 0];
Series_App = [find(1==strcmp('WashMach',Input_Data(1,:))),...
              find(1==strcmp('DishWash',Input_Data(1,:))),...
              find(1==strcmp('Elec',Input_Data(1,:))),...
              find(1==strcmp('Kettle',Input_Data(1,:))),...
              find(1==strcmp('Oven',Input_Data(1,:))),...
              find(1==strcmp('MW',Input_Data(1,:))),...
              find(1==strcmp('Coffee',Input_Data(1,:))),...
              find(1==strcmp('Toas',Input_Data(1,:))),...
              find(1==strcmp('Waff',Input_Data(1,:))),...
              find(1==strcmp('Fridge',Input_Data(1,:))),...
              find(1==strcmp('Radio',Input_Data(1,:))),...
              find(1==strcmp('Laptop',Input_Data(1,:))),...
              find(1==strcmp('Elecheat',Input_Data(1,:))),...
              find(1==strcmp('Shaver',Input_Data(1,:))),...
              find(1==strcmp('Hair',Input_Data(1,:))),...
              find(1==strcmp('Tele',Input_Data(1,:))),...
              find(1==strcmp('Stereo',Input_Data(1,:))),...
              find(1==strcmp('Iron',Input_Data(1,:))),...
              find(1==strcmp('Vacuum',Input_Data(1,:))),...
              find(1==strcmp('Charger',Input_Data(1,:))),...
              find(1==strcmp('Sauna',Input_Data(1,:)));1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]';
for var_app = 1:21
    var_appn = Series_App(var_app,1); %[43,45,47,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,79,80]
    if ~Input_Data{BuildSim,var_appn} == 0
        for var_nbr = 1:Input_Data{BuildSim,var_appn}
            nbr_applinces(size(nbr_applinces,1) + 1,1) = size(nbr_applinces,1);
            nbr_applinces(length(nbr_applinces),2) = find(Series_App == var_appn);
        end
    end
end
nbr_appliances = nbr_applinces(2:end,1:2);
nbr_app_max = max([Input_Data{2 : str2double(Nbr_Building)+1,114}]) + 1;
class_app = [clWashMach clDishWash 0 clKettle clOven clMW clCoffee clToas ...
             clWaff clFridge clRadio clLaptop 0 clShaver clHair clTele ...
             clStereo clIron clVacuum clCharger 0]';         
         
         
         
         
         
