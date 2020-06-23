function findreplace(file,otext,ntext,varargin)

%FINDREPLACE finds and replaces strings in a text file
%
% SYNTAX:
%
% findreplace(file,otext,ntext)
% findreplace(file,otext,ntext,match)
%
% findreplace  : This function finds and replaces strings in a text file
%
%       file:           text file name (with or without path)
%       otext:          text to be replaced (old text)
%       ntext:          replacing text (new text)
%       match:          either (1) for match case or (0) to ignore case
%                       default value is (1)
%
% Example:
%   findreplace('sample.txt','Moller','Moler');
%   findreplace('sample.txt','jake','Jack',0);
%   findreplace('sample.txt','continue it is','continue its',0);
%
%   Copyright 2005 Fahad Al Mahmood
%   Version: 1.0    $Date: 24-Dec-2005

% Obtaining the file full path
[fpath,fname,fext] = fileparts(file);
if isempty(fpath)
    out_path = pwd;
elseif fpath(1)=='.'
    out_path = [pwd filesep fpath];
else
    out_path = fpath;
end

% Reading the file contents
k=1;
all=0;
opt=[];
first_time=1;
change_counter=0;
fid = fopen([out_path filesep fname fext],'r');
while 1
    line{k} = fgetl(fid);
    if ~ischar(line{k})
        break;
    end
    k=k+1;
end
fclose(fid);
old_lines = line;

%Number of lines
nlines = length(line)-1;

for i=1:nlines
    if isnumeric(regexp(line{i},otext)) == 1;
        if regexp(line{i},otext) > 0
            all = all + 1;
        else
            all = all + 0;
        end
        line{i} = regexprep(line{i},otext,ntext);
    else
        if isempty(cell2mat(regexp(line{i},otext)))
            all = all + 0;
        else
            all = all + 1;
        end
        line{i} = regexprep(line{i},otext,ntext);
    end
end

line = line(1:end-1);

if all > 0
    % Writing to file
    fid2 = fopen([out_path filesep fname fext],'w');
    
    for i=1:nlines
        if strcmp(fext, '.m')
            line{i} = strrep(line{i},'%','%%');
        end
        fprintf(fid2,[line{i} '\n']);
    end
    fclose(fid2);
end

function uline = underline(loc,length)
s=' ';
l='-';
uline=[];
if loc==1
    for i=1:length
        uline=[uline l];
    end
else
    for i=1:loc-1
        uline = [uline s];
    end
    for i=1:length
        uline=[uline l];
    end
end
uline = [uline s];




