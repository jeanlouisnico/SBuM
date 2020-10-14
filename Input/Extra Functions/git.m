function git(varargin)
%git Control TortoiseGit from within MATLAB.
% This is meant to serve as a half way point between the full git bash
% and TorgoiseGit. It is intended for users that prefer to be able to
% manipulate git from the MATLAB prompt but also like the added usefullness
% of the TortoiseGit GUI.
%
% Note:
%   Before commits the script will save all open *.m files and *.mdl files.
%   Before checkouts the script will close all open *.m files and *.mdl
%   files. (The script can be edited to disable these features).
%
% Almost all TortoiseGit and git functionality is available. Since
% TortoiseGIT was ported from TortoiseSVN some functions are still called
% by their SVN name (such as git init).
%
% If you want a full command line version there are other
% wrappers for just the git command.
%
% Examples:
%   git checkout [TortoiseGit Dialog]
%   edit newfile.m [M-File Editor] Add text.
%   git add [TortoiseGit Dialog]
%   git commit [TortoiseGit Dialog]
%
% See also: http://code.google.com/p/tortoisegit/,
% http://git-scm.com/documentation

% Edit these variables to suit your workflow.
% Valid Options: true, false or 'ask'.
SAVE_ON_COMMIT=true;    % Before a 'git commit' all open *.m and *.mdl files are saved so that they are in the commit
% 'true', 'false', or 'ask'.
CLOSE_ON_CHECKOUT='ask'; % Anytime 'git checkout' is run it closes all *.m and *.mdl files so that they aren't open when they get switched by the checkout.

% TortoiseGit is Windows only.
if ~ispc
    error('TortoiseGit is only available for Windows machines');
end

% If the user doesn't have git setup
if ~ispref('git','tgit_path') || ... % If the preference is not set.
        ~exist(getpref('git','tgit_path'),'file') % Or the old path no longer exists
    button=questdlg({'This is the first time you have run git, you have cleared your preferences, or have deleted the executable.', ...
        'You must first select the TortoiseProc.exe file from TortoiseGit if it is not automatically found.','', ...
        'If TortoiseGit is not installed please install it from the TortoiseGit website below'}, ...
        '', ...
        'Search for TortoiseProc.exe','TortoiseGit Website','Select TortoiseProc.exe');
    switch button
        case 'Search for TortoiseProc.exe'
            path1='C:\Program Files\TortoiseGit\bin\TortoiseProc.exe';
            path2='C:\Program Files (x86)\TortoiseGit\bin\TortoiseProc.exe';
            if exist(path1,'file')
                setpref('git','tgit_path',path1);
                disp('TortoiseProc.exe found and preferences saved');
            elseif exist(path2,'file')
                setpref('git','tgit_path',path2);
                disp('TortoiseProc.exe found and preferences saved');
            else
                [filename, pathname] = uigetfile('TortoiseProc.exe', 'TortoiseProc.exe not automatically found. Select it:');
                if filename==0
                    warning('git:canceled','User canceled executable selection');
                    return;
                end
                setpref('git','tgit_path',fullfile(pathname,filename));
            end
        case 'TortoiseGit Website'
            web('http://code.google.com/p/tortoisegit/','-browser');
    end
end
% If nothing is given, show help and warn that a command is needed.
if nargin<1
    help(mfilename);
    warning('git:command','You must give at least one command\nSee: http://git-scm.com/documentation');
    return;
else
    % Else grab the first input as a command.
    command=varargin{1};
end
% If no argument is given use the current working directory.
if nargin<2
    varargin{2}=pwd;
end

% List of known working commands and any modifications that must be made to
% to the arguments before calling TortoiseProc.exe
switch command
    %% Commands with no changes.
    case {'about','rebase','branch','clone','push','diff','conflicteditor', ...
            'help','repostatus','repobrowser','add','revert','resolve','export', ...
            'merge','tag','settings','pull','fetch','log'}
    %% Throwbacks to TortoiseSVN
    case 'reset'
        command='revert';
    case 'clean'
        command='cleanup';
    case 'init'
        command='repocreate';
    %% Commands to prompt the user for which files to perform the action on.
    case 'rm'
        command='remove';
        varargin=[varargin{1} getFiles]; 
    case 'rename'
        varargin=[varargin{1} getFiles];
    %% 
    case 'checkout'
        command='switch';
        if strcmpi(CLOSE_ON_CHECKOUT,'ask')
            button=questdlg('Close all open .m and .mdl files before checking out? This reduces post checkout errors and the chance that you will resave the current version in the branch you switch to','Close Open Files?','Yes','No','No');
            if strcmpi(button,'yes')
                closeall;
            end
        elseif CLOSE_ON_CHECKOUT %#ok<BDLGI>
            closeall;
        end
    case 'commit'
        try
        if strcmpi(SAVE_ON_COMMIT,'ask')
            button=questdlg('Close all open .m and .mdl files before checking out? This reduces post checkout errors and the chance that you will resave the current version in the branch you switch to','Close Open Files?','Yes','No','No');
            if strcmpi(button,'yes')
                saveall;
            end
        elseif SAVE_ON_COMMIT
            saveall;
        end
        catch
        end
    %% Warning for command that just doesn't work.
    case 'cat'
        warning('git:nogui','No GUI equivalent for command');
        return;
        % Valid 'git' commands that are flat out not implemented in
        % TortoiseGit.
    case {'bisect'}
        warning('git:notimplemented','This command is not implemented in this version of TortoiseGit');
        return;
    %% Throw up a warning but attempt the command anyway.
    otherwise
        uiwait(warndlg('This command might not currently be supported. If you get the TortoiseGit about page it means that it is not'));
end

%% For each input
for i=2:numel(varargin)
    % Use double quotes for if there is a space in the path.
    cmd=sprintf('"%s" /command:"%s" /closeonend:1 /path:"%s" &',getpref('git','tgit_path'),command,abspath(varargin{i}));
    dos(cmd);
end
end

% Prompt the user for files.
function files=getFiles
if (nargin<2)
    [filename, pathname, ~] = uigetfile( ...
        {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)';
        '*.m',  'M-files (*.m)'; ...
        '*.fig','Figures (*.fig)'; ...
        '*.mat','MAT-files (*.mat)'; ...
        '*.mdl','Models (*.mdl)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Pick a file','MultiSelect','on');
    if iscell(filename)
        files=cell(1,numel(filename));
        for i=1:numel(filename)
            files{i}=fullfile(pathname,filename{i});
        end
    else
        if filename==0
            error('User selection canceled');
        end
        files{1}=fullfile(pathname,filename);
    end
end
end

% Get the absolute path of a file.
function [absolutepath]=abspath(partialpath)
% Taken from xlswrite.
% parse partial path into path parts
[pathname filename ext] = fileparts(partialpath);
% no path qualification is present in partial path; assume parent is pwd, except
% when path string starts with '~' or is identical to '~'.
if isempty(pathname) && isempty(strmatch('~',partialpath))
    Directory = pwd;
elseif isempty(regexp(partialpath,'(.:|\\\\)','once')) && ...
        isempty(strmatch('/',partialpath)) && ...
        isempty(strmatch('~',partialpath));
    % path did not start with any of drive name, UNC path or '~'.
    Directory = [pwd,filesep,pathname];
else
    % path content present in partial path; assume relative to current directory,
    % or absolute.
    Directory = pathname;
end
% construct absulute filename
absolutepath = fullfile(Directory,[filename,ext]);
end

function saveall
try % Don't fail the whole commit because something went wrong here.
    % Save all simulink models & open .m files before commiting.
    if exists('.git','directory') % If we are in a working directory.
        % Get all open Simulink models.
        openSystems=find_system('SearchDepth',0);
        % Get all M-files open in the Matlab Editor.
        openM=char(com.mathworks.mlservices.MLEditorServices.builtinGetOpenDocumentNames);
        for i=1:numel(openSystems)
            try % Try to save every system, if it fails continue on to the next one.
                save_system(openSystems{1})
            catch
            end
        end
        for i=1:size(openM,1)
            try % Try to save every M-file, if one fails move
                % on to the next one.
                com.mathworks.mlservices.MLEditorServices.saveDocument(strtrim(openM(i,:)));
            catch
            end
        end
    end
catch
end
end

function closeall
try % Don't fail the whole checkout because this fails.
    % Close all simulink models and *.m files before checkout
    bdclose('all');
    com.mathworks.mlservices.MLEditorServices.closeAll;
catch
end
end