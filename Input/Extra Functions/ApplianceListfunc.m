function AppliancesList = ApplianceListfunc

AppliancesList = {
            'Washing Machine';'Dish Washer';'Electric plates';'Kettle';'Oven';...
            'Coffee maker';'Microwave';'Toaster';'Waffle Maker';'Fridge';'Television';...
            'Laptop';'Shaver';'Hair Dryer';'Stereo';'Vacuum Cleaner';'Telephone Charger';...
            'Iron';'Electric heating in bathroom';'Sauna';'Radio';'Lighting System'
            };
AppliancesList(:,2)={'Rate';'Rate';'None';'Rate';'Rate';'Rate';'Rate';'Rate';...
                     'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';'Rate';...
                     'Rate';'None';'None';'Rate';'Rate'
                     };
AppliancesList(:,3)={'WashMach';'DishWash';'Elec';'Kettle';'Oven';'Coffee';'MW';'Toas';...
                     'Waff';'Fridge';'Tele';'Laptop';'Shaver';'Hair';'Stereo';'Vacuum';'Charger';...
                     'Iron';'Elecheat';'Sauna';'Radio';''
                     };
AppliancesList(:,4)={'clWashMach';'clDishWash';'';'clKettle';'clOven';'clCoffee';'clMW';'clToas';...
                     'clWaff';'clFridge';'clTele';'clLaptop';'clShaver';'clHair';'clStereo';'clVacuum';'clCharger';...
                     'clIron';'';'';'clRadio';'clLight'
                     };