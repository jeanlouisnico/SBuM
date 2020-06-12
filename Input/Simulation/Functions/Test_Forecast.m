function [Forecasted_Profile] = Test_Forecast(myiter, Cons_Building, timehour)
global Temperature Timeoffset TimeVector Wind_Speed TempForca

TimeRef = Timeoffset + myiter - 1   ;
B = Reshape_Matrix(24,Temperature','mean');
Time_Reshape = floor(Reshape_Matrix(24,TimeVector','mean'));
if myweekday(TimeVector(Timeoffset + myiter)) <= 5 
    [r] = find(B(floor(Timeoffset/24):floor(TimeRef/24)-1) < (mean(TempForca(TimeRef + 24),1) + 1) & B(floor(Timeoffset/24):floor(TimeRef/24)-1) > (mean(TempForca(TimeRef + 24),1) - 1) & ...
               myweekday(Time_Reshape(floor(Timeoffset/24):floor(TimeRef/24)-1))<=5)';
else
    [r] = find(B(floor(Timeoffset/24):floor(TimeRef/24)-1) < (mean(TempForca(TimeRef + 24),1) + 1) & B(floor(Timeoffset/24):floor(TimeRef/24)-1) > (mean(TempForca(TimeRef + 24),1) - 1) & ...
               myweekday(Time_Reshape(floor(Timeoffset/24):floor(TimeRef/24)-1))>=5)';
end
if ~isempty(r)
    ConsMean = zeros([24 length(r)]);
    TMean = zeros([24 length(r)]);
    Tt1Mean = zeros([24 length(r)]);
    Tt2Mean = zeros([24 length(r)]);
    Tt3Mean = zeros([24 length(r)]);
    WS = zeros([24 length(r)]);
    WS1 = zeros([24 length(r)]);
    WS2 = zeros([24 length(r)]);
    for RowRef = 1:length(r)
        rowref = r(RowRef)*24;
        tref1 = -timehour;
        tref2 = 23 - timehour;
        if myiter == 1536
            y=1;
        end
        ConsMean(:,RowRef) = Cons_Building(rowref+tref1:rowref+tref2) ;
        TMean(:,RowRef) = Temperature(Timeoffset+rowref+tref1:Timeoffset+rowref+tref2)   ;
        Tt1Mean(:,RowRef) = Temperature(Timeoffset+rowref+tref1-1:Timeoffset+rowref+tref2-1)   ;
        Tt2Mean(:,RowRef) = Temperature(Timeoffset+rowref+tref1-2:Timeoffset+rowref+tref2-2)   ;
        Tt3Mean(:,RowRef) = Temperature(Timeoffset+rowref+tref1-3:Timeoffset+rowref+tref2-3)   ;
        WS(:,RowRef) = Wind_Speed(Timeoffset+rowref+tref1:Timeoffset+rowref+tref2)   ;
        WS1(:,RowRef) = Wind_Speed(Timeoffset+rowref+tref1-1:Timeoffset+rowref+tref2-1);
        WS2(:,RowRef) = Wind_Speed(Timeoffset+rowref+tref1-2:Timeoffset+rowref+tref2-2);
    end
    WS = mean(WS,2);
    WS1 = mean(WS1,2);
    WS2 = mean(WS2,2);
    Meanprofile = mean(ConsMean,2);
    T = mean(TMean,2);
    T2 = T.^2   ;
    T3 = T.^3   ;
    WC = (18-T).*WS.^(0.5);
    WC1 = (18-T).*WS1.^(0.5);
    WC2 = (18-T).*WS2.^(0.5);
    Tt1 = mean(Tt1Mean,2);
    Tt2 = mean(Tt2Mean,2);
    Tt3 = mean(Tt3Mean,2); 
    H = [ones(length(Meanprofile),1) T T2 T3 Tt1 Tt2 Tt3 WC WC1 WC2];
    Z = Meanprofile;
    X = (H'*H)^(-1)*H'*Z ;
    Var = [ones(length(T),1) T T2 T3 Tt1 Tt2 Tt3 WC WC1 WC2];
    Forecasted_Profile = Var*X;
else
    Forecasted_Profile = zeros(24,1);
end