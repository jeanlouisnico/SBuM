function folderpath = getfolder(FullPath,filelimiter)

PathSplit = strsplit(FullPath,filesep)  ;

for i = numel(PathSplit):-1:1
    if strcmp(PathSplit{i},filelimiter)
        folderpath = PathSplit{1};
        for ij = 2:i
            folderpath = [folderpath,filesep,PathSplit{ij}] ;
        end
        break
    end
end