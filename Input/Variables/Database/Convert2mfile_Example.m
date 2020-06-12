InhabitantList = {'Inhabitant1', 'Inhabitant2', 'Inhabitant3','Inhabitant4', 'Inhabitant5', 'Inhabitant6', 'Inhabitant7'} ;
Category = {'MaxUse', 'Temp', 'TimeUsage','Weekdistr', 'Weekdayweight', 'Weekdayacc', 'Delay','Power'} ;
AppliancesList = {'WashMach';'DishWash';'Elec';'Kettle';'Oven';'MW';'Coffee';'Toas';...
'Waff';'Fridge';'Radio';'Laptop';'Elecheat';'Shaver';'Hair';'Tele';'Stereo';'Iron';...
'Vacuum'  ; 'Charger' ; 'Sauna'}';

CDetail_Appliance_Cell = num2cell(Detail_Appliance);
AllApp1 = cell2struct(CDetail_Appliance_Cell,InhabitantList) ;

B = permute(Detail_Appliance,[3 2 1]);
CDetail_Appliance_B = num2cell(B);
CreateAppDetailList = cell2struct(CDetail_Appliance_B,AppliancesList) ;

% Testing to create subindex
for ij = 1:numel(AppliancesList)
    for i = 1:numel(Category)
        for ik = 1:numel(InhabitantList)
            TestNewStr.(AppliancesList{ij})(ik).(Category{i}) = CreateAppDetailList(i,ik).(AppliancesList{ij}) ;
        end
    end
end


[str, sts] = gencode_rvalue(TestNewStr);
display(sts)
char(str)

strx = gencode(TestNewStr);
char(strx)

stry = gencode(TestNewStr,'ApplianceLD');
copystry = char(stry) ;

