function decreeProfile = ProfileDecree

[ProfileDecree_Profile1,~,~] = xlsread('ProfileDecree_Profile1') ;
[ProfileDecree_Profile2,~,~] = xlsread('ProfileDecree_Profile2') ;

rowim = 1 ;

for i = 1:12
    for k = 1:3
        decreeProfile.Profile1(i,k,:)          = ProfileDecree_Profile1(:,rowim) ;
        decreeProfile.Profile1Perc(i,k,:)      = decreeProfile.Profile1(i,k,:) / sum(decreeProfile.Profile1(i,k,:));
        rowim = rowim + 1;
    end
end

rowim = 1 ;
for i = 1:12
    for k = 1:3
        decreeProfile.Profile2(i,k,:)          = ProfileDecree_Profile2(:,rowim) ;
        decreeProfile.Profile2Perc(i,k,:)      = decreeProfile.Profile2(i,k,:) / sum(decreeProfile.Profile2(i,k,:));
        rowim = rowim + 1;
    end
end