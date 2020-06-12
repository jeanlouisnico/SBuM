function usecase = dateseparator(s)

if contains(s,'/')
    usecase = '/' ;
elseif contains(s,'.')
    usecase = '.' ;
elseif contains(s,'-')
    usecase = '-' ;
elseif contains(s,' ')
    usecase = ' ' ;    
else
    errordlg('Invalid Input Format. Format must be  separated by . - or /','Error Message','modal')
    usecase = -1 ;
    return
end