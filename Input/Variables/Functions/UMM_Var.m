function UMM_Var
dbstop if error  

timeref = datenum(2013,11,22) + 22 /24;
%timeref = datenum(2013,12,1) + 12/24;
newcol = 1;
if ~(exist('alldata','var') == 1)
    [ndata, text, alldata] = xlsread('Statistics_Finnish_Industry_Association.xlsm', 'Sheet1', 'B2:AF702');
    for rcol = 1:1:size(alldata,2)
        newrow = 1;
        for nrow = 1:size(alldata,1)
            if rcol == 1 || rcol == 2
                if length(alldata{nrow,rcol}) == 10
                    UMM{newrow,newcol} = dtstr2dtnummx(alldata(nrow,rcol),'dd/MM/yyyy');
                else
                    UMM{newrow,newcol} = dtstr2dtnummx(alldata(nrow,rcol),'dd/MM/yyyy HH:mm:ss');
                end
                newrow = newrow + 1;
            elseif (15 <= rcol && rcol <= 23)
                continue
            else
                UMM{newrow,newcol} = alldata{nrow,rcol};
                newrow = newrow + 1;
            end
        end
        if rcol == 1 || rcol == 2
            newcol = newcol + 1;
        elseif (15 <= rcol && rcol <= 23)
            continue
        else
            newcol = newcol + 1;
        end
     end
end
for tech = 1:6
    if ~(tech == 1 || tech == 2)
        switch tech
            case 3
                techname = 'District heating CHP';
                nbrstat = 26;
                nbrndata = 27;
            case 4
                techname = 'Industry CHP';
                nbrstat = 28;
                nbrndata = 29;
            case 5
                techname = 'Nuclear energy';
                nbrstat = 24;
                nbrndata = 25;
            case 6
                techname = 'Separate electricity production';
                nbrstat = 30;
                nbrndata = 31;
        end
        Nbr_stations = length(unique(text(:,nbrstat))) - 1;
        UMM2 = repmat(UMM(:,6),1,Nbr_stations);
        newcmp = repmat(text(1:Nbr_stations,nbrstat)',701,1);
        Cmp_str = strcmp(UMM2,newcmp);
        Row_found = find([UMM{:,1}]' <= timeref & [UMM{:,2}]' >= timeref & strcmp(UMM(:,14),techname) & sum(strcmp(UMM2,newcmp),2) == 1);
        Row_found2 = zeros(100,Nbr_stations);
        for var_tech  = 1:Nbr_stations
            countif_func(1,var_tech) = sum(([UMM{:,1}] <= timeref & [UMM{:,2}] >= timeref & strcmp(UMM(:,14),techname)') .* Cmp_str(:,var_tech)');
            if isempty(find(([UMM{:,1}] <= timeref & [UMM{:,2}] >= timeref & strcmp(UMM(:,14),techname)') .* Cmp_str(:,var_tech)')')
                Power_func(:,var_tech) = 0;
            else
                Power_func(1:countif_func(1,var_tech),var_tech) = find(([UMM{:,1}] <= timeref & [UMM{:,2}] >= timeref & strcmp(UMM(:,14),techname)') .* Cmp_str(:,var_tech)')';
            end
            Power(1,var_tech) = sum(ndata(Power_func(1:countif_func(1,var_tech),var_tech),7))/countif_func(1,var_tech);
        end
        Power(isnan(Power)) = 0;
        PTot(tech) = sum(Power);
        clear countif_func Power_func Power
    end
end