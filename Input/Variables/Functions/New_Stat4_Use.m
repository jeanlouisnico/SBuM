function [VarPlot,Stat4Use_New] = New_Stat4_Use(varargin)
%%% Introduction
% the function is meant to create the reference profile for each appliance
% used in a typical Finnish household. The starting profiles are set up
% with the REMODECE input values taking into account the Danish and
% Norwegian profiles. Then the value from the Finnish Legislation <http://edilex.fi/lainsaadanto/20090066?offset=1&perpage=20&phrase=66%2F2009&sort=relevance&searchKey=455079 Act 2009/66>
% are considered to level up the daily profiles. Each of the profiles are
% split into 3 categories: weekdays (Monday - Friday), Saturday, and Sunday
% profiles. 
dbstop if error
%clear all
clear Stat4Use_New
mydata = load('Smart_House_Data_MatLab.mat');
%%% Seasonal Variations
% The 

    if nargin == 0
        Profilechosen = input('Profile to be chosen (1 or 2): ', 's');
        Profilechosen = str2double(Profilechosen);
        switch Profilechosen
            case 1
                Profile_Decret = mydata.Seson_Var;
            case 2
                Profile_Decret = mydata.Seson_Var2;
            otherwise
                return;
        end
    elseif nargin == 1
        switch varargin{1}
            case 1
                Profile_Decret = mydata.Seson_Var;
            case 2
                Profile_Decret = mydata.Seson_Var2;
            otherwise
                Profile_Decret = mydata.Seson_Var;
        end
        figure(1)
        varh = 1;
        for vari = 1:12
            for varj = 1:3
                subplot(12,3,varh)
                plot(Profile_Decret(:,varj,vari))
                varh = varh + 1;
            end
        end
    end
%% Create Profiles
Number_of_Appliance2Cons = 21;
for weekday = 1:size(Profile_Decret,2)
    for Seasonvar = 1:size(Profile_Decret,3)
        [VarPlot(:,:,weekday,Seasonvar),Varvar] = New_Profile(Profile_Decret,mydata.Probability_Raw,mydata.Var_Mean,weekday,Seasonvar,Number_of_Appliance2Cons,nargin);
        Stat4Use_New(:,:,weekday,Seasonvar) = [Varvar zeros(25,1)];
        Stat4Use_New(:,21,weekday,Seasonvar) = mydata.Probability_function(1:25,21);
    end
end
%     if nargin > 0
%         varplot = 2;
%         for weekvar = 1:3
%             for Seasvar = 1:12
%                 figure(varplot)
%                 plot(VarPlot(:,:,weekvar,Seasvar))
%                 varplot = varplot + 1;
%             end
%         end
%     end
%% Nested Function
    function [Profile,Profile2] = New_Profile(Seson_Var,Probability_Raw,Var_Mean,Weekdayvar,Seasonvar, nbr_appliances, nbr_arg)
        %%% Set the average profile
        % To start, an average profile in drawn from the input values that
        % are given in the Excel file. In order to optimize the code, only
        % the houses that have to be simulated are given their profiles. It
        % includes the mean power (_*P*_), the mean time use per appliance in terms of
        % time (_*t*_) and in terms of quantity per week (_*U*_). Also, the primary
        % profile is to be taken into account for each appliance (_*Pr*_).
        %%%
        % $$ P_{R} = P_{r} \times \overline{P}\,\overline{t}\,\overline{U}\,\frac{52}{365.25}  $$
        %%%
        % Where $P_{R}$ is an n-by-m matrix of the mean energy profile within a year [kWh], Pr is
        % the original n-by-m matrix profile ['], P  is the mean power [kW], t is the
        % mean cycle time of use of an appliance [h], U is the average use
        % of an appliance in a week ['].
        for var_col = 1:nbr_appliances
            Product(:,var_col) = Probability_Raw(:,var_col) * prod(Var_Mean(var_col,:));
        end
        %%% 
        % In the mean time, the weight that an appliance is taking over the
        % other profiles must be evaluated. Thus, the percentage of energy
        % used, PR, for a given hour and a given appliance must be
        % evaluated
        %%%
        % $$ P_{P} = P_{R}S_{P_{R}}^{-1} $$
        %%%
        % Where $P_{P}$ is an n-by-m matrix, and $S_{PR}$ is an n-by-m matrix of the internal sum of
        % the mean energy profile $P_{R}$.
        Sum_Product = repmat(sum(Product,2),1,nbr_appliances);
        Perc_Product = Product ./ Sum_Product;
        %%%
        % Furthermore, the difference of variation between the reference daily
        % profiles given in the legislation (see the link above) and the profiles created in
        % this function must be known for correcting the raw profile. For
        % this matter, the percentage variations Pv of a
        % given time slot (weekday, Saturday or Sunday) and a given month
        % is multiplied by the daily energy consumption $S_{PR}$.
        %%%
        % $$ D_{var} = P_{v}\sum S_{P_{R}} $$
        %%%
        % Where $D_{var}$ is a n-by-1 matrix representing the difference
        % variations considering the raw distribution function of each
        % appliance, $P_{v}$ is a n-by-1 matrix, the percentage variations.
        %%%
        % Consequently, the percentage variation between the raw profile
        % and the legal based profile is found as
        %%%
        % $$ P_{Var} = D_{var} \cdot S_{P_{R}}^{-1} - 1 $$
        %%%
        % Where $P_{Var}$ is the percentage variation between both profiles
        % [%]. 
        Diff_Var = Seson_Var(:,Weekdayvar,Seasonvar) * sum(Sum_Product(:,1));
        Perc_Var = (Diff_Var ./ Sum_Product(:,1) - 1);
        if (nbr_arg == 1 && Weekdayvar == 1 && Seasonvar == 1)
            figure(10);
            plot(Perc_Var)
        end
        %%%
        % Then, each appliance weight in the profile definition is
        % re-calculated according to the differences that have been found
        % between the original daily profile and the legal profile given.
        %%%
        % $$ V_{Tot} = \left (1+P_{Var}  \right )\cdot P_{P} $$
        %%%
        % Where $V_{Tot}$ is a n-by-1 matrix representing the total variation
        % between the raw profile and the legal profile.
        for var_col = 1:nbr_appliances
            Var_Tot(:,var_col) = (1 + Perc_Var) .* Perc_Product(:,var_col) ;
        end
            Final = sum(Product,2)';
            %% 
            %%%
            % In turn, a temporary profile $P_{Temp}$, expressed in kWh, is defined.
            % As the new temporary profile is not consistent and between
            % the different appliances, it will have to be re-adjusted
            % further. As both matrices $V_{Tot}$ and $S_{P_{R}}$ are of
            % different sizes, only the diagonal is calculated for each
            % appliances. This will in turn form the new temporary profile
            %%%
            % $$ P_{Temp} = diag(V_{Tot}\cdot S_{P_{R}}^{T}) $$
            %%%
            % Where $P_{Temp}$ is a n-by-m matrix representing the temporary power
            % distribution used fo the simulation.
        for var_row = 1:nbr_appliances
            Global_Matrix = zeros(nbr_appliances,24);
            Global_Matrix(var_row,:) = Final;
            Diagonal_Matrix(:,var_row) = diag(Var_Tot * Global_Matrix)';
        end
        %%%
        % $$ P = P_{Temp}\cdot P_{r}^{T}\cdot \left (P_{R}^{T}  \right )^{-1}
        % $$
        %%%
        % Where P is a n-by-m matrix and the new profile of the appliance
        % [kWh].
         
        for var_col = 1:nbr_appliances
            New_Profile(:,var_col) = Diagonal_Matrix(:,var_col) / prod(Var_Mean(var_col,:));
        end
        New_Profile(isnan(New_Profile)) = 0;
        %%%
        % This new value must then be expressed in terms of percentage,
        % therefore, P can be re-written as:
        %%%
        % $$ P_{2} = \frac{P_{1}}{\sum_{1}^{app}P_{1}} $$
        %%%
        % Where $P_{2}$ and $P_{1}$ are the same matrix but $P_{2}$ is expressed in [%].
        for varcol = 1:nbr_appliances
            Profile(:,varcol) = New_Profile(:,varcol) / sum(New_Profile(:,varcol));
        end
        %%%
        % Another way of representing the probability distribution function
        % of appliances usage is by having them expressed in terms of
        % cumulative sum in the interval [0,1].
        New_Row = zeros(1,nbr_appliances);
        Profile = insertrows(Profile,New_Row,0);
        for varcole = 1:nbr_appliances
            Profile2(:,varcole) = cumsum(Profile(:,varcole));
        end
        Profile2(isnan(Profile2)) = 0;
        
        if nargin > 0
            figure (3)
            plot(1:25,Profile(:,1),1:25,Profile2(:,1));
        end
    end
% if nargin > 0
%     close all
% end
end