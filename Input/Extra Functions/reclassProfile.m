function AppProfile = reclassProfile(InputProfile, DataBaseName)

AppName = fieldnames(InputProfile) ;

for i = 1:length(AppName)
    AppTag = AppName{i} ;
    AppProfile.(AppTag).(DataBaseName) = InputProfile.(AppTag) ;
end