function ExtractMetering(varargin)
%% Select Output folder
if nargin > 0
    folder_name = varargin{1} ;
else
    disp('Select the results folder');
    folder_name = uigetdir;
    if folder_name == 0; return; end
end
%% Check the existance of the files
File1 = strcat(folder_name,filesep,'Cons_Tot_Global.mat');
File2 = strcat(folder_name,filesep,'Input_Data.mat');
File3 = strcat(folder_name,filesep,'Emissions_ReCiPe.mat');
File4 = strcat(folder_name,filesep,'Bill_Global.mat');

%% Select Output folder
% disp('Select the Plot Results File');
% %'D:\Applications\Matlab6p5\work\*.m;*.mdl;*.mat'
% FolderOpen = strcat(folder_name,filesep,'*.m',';','*.mdl',';','*.mat');
% [finalfile,PathName,~]= uigetfile(FolderOpen,'MATLAB Files');
% File5 = strcat(PathName,finalfile);
% if folder_name == 0; return; end

%% File Error
if ~(exist(File1, 'file') == 2)
    disp('The file "Cons_Tot_Global.mat" does not exists');
    return;
elseif ~(exist(File2, 'file') == 2)
    disp('The file "Input_Data.mat" does not exists');
    return; 
end
%% Extract power consumption per metering systems
Emissions       = load(File3);
Cons_Tot_Global = load(File1);
Inputdata       = load(File2);
Bill_Global     = load(File4);

CO2EmissionsAllHouses = Emissions.Emissions_ReCiPe;
Input_Data = Inputdata.Input_Data ;
Cons_Tot = Cons_Tot_Global.Cons_Tot ;
Price = Bill_Global.Price ;
AllHouses = fieldnames(Input_Data) ;
for varMeter = 1:4
    ij = 1;
    MeteringVar = [] ;
    for i = 1:numel(AllHouses)
        MeteringPerHouse = str2double(Input_Data.(AllHouses{i}).Metering) ;
        if MeteringPerHouse == varMeter
            MeteringVar(ij,1) = i ;
            Inh(ij) = str2double(Input_Data.(AllHouses{i}).inhabitants) ;
            ij = ij + 1 ;
        end
    end
   %MeteringVar = find([Input_Data{2:end,83}]==varMeter)';
   if ~isempty(MeteringVar)
        %Inh = [Input_Data{MeteringVar + 1,41}];
        PriceM = Price(MeteringVar(:,1),:)';
        EnerM = Cons_Tot(MeteringVar(:,1),:)';
        EnerInh = zeros(size(EnerM,1),size(Inh,2)) ;
        
        Colin = 1;
        for var = 1:size(Inh,2)
             EnerInh(:,Colin) = EnerM(:,Colin) / Inh(Colin);
             Colin = Colin + 1 ;
        end
        % Emissions per metering
        for jj = 1:size(Emissions.Emissions_ReCiPe{1}.EmissionsfactProduced,2)
            for tt = 1:size(MeteringVar,1)
                IndexI = MeteringVar(tt,1) ;
                EmissionM(jj).Metering(varMeter).ReCiPeEm(:,tt) = Emissions.Emissions_ReCiPe{1,IndexI}.EmissionHouseProduced(:,jj) ;
            end
        end
        EnerMeter{varMeter} = EnerM;
        EnerMeterInh{varMeter} = EnerInh;
        PriceMeter{varMeter} = PriceM;
   else
       EnerMeter{varMeter} = [];
       EnerMeterInh{varMeter} = [];
       PriceMeter{varMeter} = [];
       for jj = 1:size(Emissions.Emissions_ReCiPe{1}.EmissionsfactProduced,2)
            for tt = 1:size(MeteringVar,1)
                IndexI = MeteringVar(tt,1) ;
                EmissionM(jj).Metering(varMeter).ReCiPeEm(:,tt) = [] ;
            end
        end
   end
end


%% Extract power consumption per number of inhabitants

for varInh = 1:5
    ij = 1;
    I = [] ;
    for i = 1:numel(AllHouses)
        MeteringPerHouse = str2double(Input_Data.(AllHouses{i}).inhabitants) ;
        if MeteringPerHouse == varInh
            I(ij,1) = i ;
            ij = ij + 1 ;
        end
    end
%    I = find([Input_Data{2:end,41}]==varInh)';
   if ~isempty(I)
       EnerI = Cons_Tot(I(:,1),:)';
       EnerHabitant{varInh} = EnerI;
       for jj = 1:size(Emissions.Emissions_ReCiPe{1}.EmissionsfactProduced,2)
            for tt = 1:size(I,1)
                IndexI = I(tt,1) ;
                EmInhProduced(jj).Inhabitant(varInh).ReCiPeEm(:,tt) = Emissions.Emissions_ReCiPe{1,IndexI}.EmissionHouseProduced(:,jj) ;
                EmInhNetto(jj).Inhabitant(varInh).ReCiPeEm(:,tt) = Emissions.Emissions_ReCiPe{1,IndexI}.EmissionHouseNetto(:,jj) ;
            end
       end
   else
       EnerHabitant{varInh} = [];
       for jj = 1:size(Emissions.Emissions_ReCiPe{1}.EmissionsfactProduced,2)
            for tt = 1:size(I,1)
                IndexI = I(tt,1) ;
                EmInhProduced(jj).Inhabitant(varInh).ReCiPeEm(:,tt) = [] ;
                EmInhNetto(jj).Inhabitant(varInh).ReCiPeEm(:,tt) = [] ;
            end
       end
   end
end

%% Extract by contract type
Housenbr = fieldnames(Input_Data) ;
irow = 1;
A = [];
for i = 1:numel(Housenbr)
    Lowprice = Input_Data.(Housenbr{i}).Low_Price ;
    if ~ismember(str2double(Lowprice),A)
        A(irow) = str2double(Lowprice) ;
        AA(1,irow) = str2double(Lowprice) ;
        irow = irow + 1 ;
    end
end
irow = 1;
B = [] ;
for i = 1:numel(Housenbr)
    Highprice = Input_Data.(Housenbr{i}).High_Price ;
    if ~ismember(str2double(Highprice),B)
        B(irow) = str2double(Highprice) ;
        BB(1,irow) = str2double(Highprice) ;
        irow = irow + 1 ;
    end
end
for i = 1:numel(Housenbr)
    Contract = Input_Data.(Housenbr{i}).Contract ;
    C{i} = Contract ;
    CC{i} = Contract ;
end
for i = 1:numel(Housenbr)
    ContElec = Input_Data.(Housenbr{i}).ContElec ;
    D{i} = ContElec ;
    DD{i} = ContElec ;
end
% A = unique([Input_Data{2:end,115}]);
% B = unique([Input_Data{2:end,116}]);
% C = Input_Data(2:end,117);
% D = Input_Data(2:end,40);

A(isnan(A)) = Inf; % replace NaN with Inf
B(isnan(B)) = Inf; % replace NaN with Inf
C(cellfun(@(x) any(isnan(x)),C)) = {''};
D(cellfun(@(x) any(isnan(x)),D)) = {''};

A = unique(A);
B = unique(B);
C = unique(C)';
D = unique(D)';

% AA = [Input_Data{2:end,115}]';
AA(isnan(AA)) = Inf;
% BB = [Input_Data{2:end,116}]';
BB(isnan(BB)) = Inf;
% CC = Input_Data(2:end,117);
CC(cellfun(@(x) any(isnan(x)),CC)) = {''};
% DD = Input_Data(2:end,40);
DD(cellfun(@(x) any(isnan(x)),DD)) = {''};
Enerpri = 1;
ws = workspace;

for ContD = 1:size(D,2)
    for ContC = 1:size(C,2)
        for ContB = 1:size(B,2)
            for ContA = 1:size(A,2)
                CT2 = find(strcmp(D(ContD),DD) & ...
                           BB == B(ContB) & ...
                           strcmp(C(ContC),CC) & ...
                           AA == A(ContA));
                if ~isempty(CT2)
                    NameVar = strcat('EnerPri',num2str(Enerpri));
                    NameVar2 = strcat('EuroPri',num2str(Enerpri));
                   ws.(NameVar2) = Price(CT2(:,1),:)';
                         NameVar3 = strcat('EmPri',num2str(Enerpri));
                    NVAr{Enerpri} = strcat(D(ContD),'_',num2str(B(ContB)),'_',C{ContC},'_',num2str(A(ContA))) ;
                    if ischar(D(ContD))
                        ws.(NameVar) = Cons_Tot(CT2(:,1),:)';
                        ws.(NameVar3) = [CO2EmissionsAllHouses{1,CT2(:,1)}];
                    else
                        ws.(NameVar) = Cons_Tot(CT2(:,1),:)';
                        ws.(NameVar2) = Price(CT2(:,1),:)';
                        ws.(NameVar3) = [CO2EmissionsAllHouses{1,CT2(:,1)}];
                    end
                    EnerPri{Enerpri} = ws.(NameVar);
                    EuroPri{Enerpri} = ws.(NameVar2);
                    EmPri{Enerpri} = ws.(NameVar3);
                    Enerpri = Enerpri + 1;
                end
            end
        end
    end
end

%% Save Variables

%SAve Emission related variables
save(strcat(folder_name,filesep,'Emissions_Results_ReCiPe_Produced.mat'),'EmInhProduced')         ;
save(strcat(folder_name,filesep,'Emissions_Results_ReCiPe_Netto.mat'),'EmInhNetto')         ;
save(strcat(folder_name,filesep,'Emissions_Metering.mat'),'EmissionM')         ;
save(strcat(folder_name,filesep,'Emission_Price.mat'),'EmPri')         ;
%Save Energy related variable
save(strcat(folder_name,filesep,'Energy_by_Meter.mat'),'EnerMeter')         ;
save(strcat(folder_name,filesep,'Energy_per_Inhabitant.mat'),'EnerHabitant')         ;
save(strcat(folder_name,filesep,'Energy_Price.mat'),'EnerPri')         ;
save(strcat(folder_name,filesep,'Euro_Price.mat'),'EuroPri')         ;
save(strcat(folder_name,filesep,'Energy_Metering_Inh.mat'),'EnerMeterInh')         ;
%Save price related variables
save(strcat(folder_name,filesep,'Contract_Order.mat'),'NVAr')         ;