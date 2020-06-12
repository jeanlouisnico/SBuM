function [FutureHourlyData] = Morphing(ClimateVariables, delta, alfa, MorphingTechnique, Temperature, Solar_Radiation, TimeVector, a)
%% Function to conduct morphing from current climate data to future one
% The main idea of this function is to downscale climate change data to
% hourly values for the use of building energy demand simulation
%% Input data
% Define the input data here
CurrentTemperature  = Temperature;  % This is the value for the existing hourly temperature data
CurrentRadiation    = Solar_Radiation; % This is the value for the existing hourly tempearature data
% MeanMax0            = ClimateVariables.MeanMax';
% MeanMin0            = ClimateVariables.MeanMin';
% MorphingTechniqueTemp  = MorphingTechnique{1};    % This is the selected morhing technique for temperature
% MorphingTechniqueSol    = MorphingTechnique{2};     % The selected morphing technique for solar radiation
% SelectedYearMonthly     = SelectedYearMonthly;      % For selecting correct column from climate change data
% SelectedYearDaily       = SelectedYearDaily;        % For selecting correct column from climate change data, daily database
% MeanMonthlyCurrent      = ClimateVariables.MeanMonthly;     % Mean temperature data for existing climate
% MeanMontlyRadCurrent    = ClimateVariables.MeanRad;         % Mean radition data for existing climate
% MeanMonthlyMinTemp      = ClimateVariables.deltaMin;        % Future monthly mean min temperature
% MeanMonthlyMaxTemp      = ClimateVariables.deltaMax;        % Future monthly mean max temperature

Months                  = TimeVector.Month;            % Current months

%% Loop for the morphing

for i = 1:2     % 2 variables are morphed
    
    MorphingTech     = MorphingTechnique{i};
    
    if i == 1       % 1st loop is for temperature
    
        BaseData    = CurrentTemperature;
        
    else            % 2nd loop is for radiation
        
        BaseData    = CurrentRadiation;
        
    end
    
    switch(MorphingTech)
        
        case 'Shift'
            
            % The equation for shifting change is x = xo + deltax;  
            
            MorphedTemperature = zeros(1,length(TimeVector));
            
            for j = 1:12    % Loop through every month
            
                MorphedTemperature(Months==j) = BaseData(Months==j) + delta(j);
                
            end
            
        case 'Stretch'
            
            % The equation for stretching change is x = a*x0;
            
            MorphedRadiation = zeros(1,length(TimeVector));
            
            for j = 1:12
                
                MorphedRadiation(Months==j) = BaseData(Months==j) * a(j);
                
            end
            
        case 'Shift and Stretch'
            
            % The equation for shifting and stretching is 
            % x = x0 + deltax + a*(x0 - x0m)
            % in which a = (deltaTmax,m - deltaTmi,n)/(Tmax0 - Tmin0)
            % alfa has been calculated in ConvertDailyToMonthly function
            
            for j = 1:12
                
                MonthlyAverage  = mean(BaseData(Months == j));
            
                MorphedTemperature(Months==j) = BaseData(Months==j) + delta(j) + alfa(j) * (BaseData(Months==j) - MonthlyAverage);
%                 MorphedTemperature(Months==j) = MonthlyAverage + delta(j) + (1 + alfa(j)) * (BaseData(Months==j) - MonthlyAverage);
                
            end
            
    end

end
   
FutureHourlyData.Temperature    = MorphedTemperature;
FutureHourlyData.Radiation      = MorphedRadiation;
    
end

