function approxpi

f = waitbar(0,'1','Name','Approximating pi...',...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');

setappdata(f,'canceling',0);

% Approximate pi^2/8 as: 1 + 1/9 + 1/25 + 1/49 + ...
pisqover8 = 1;
denom = 3;
valueofpi = sqrt(8 * pisqover8);

steps = 20000;
for step = 1:steps
    % Check for clicked Cancel button
    if getappdata(f,'canceling')
        delete(f)
        return
    end
    
    % Update waitbar and message
    waitbar(step/steps,f,sprintf('%12.9f',valueofpi))
    
    % Calculate next estimate 
    pisqover8 = pisqover8 + 1 / (denom * denom);
    denom = denom + 2;
    valueofpi = sqrt(8 * pisqover8);
end
end