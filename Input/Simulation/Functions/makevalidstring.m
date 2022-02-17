function nameout = makevalidstring(bidname)

nameout = strrep(lower(bidname),' ','_') ;
nameout = strrep(nameout, '/', '_') ;
nameout = strrep(nameout, '-', '_') ;
nameout = strrep(nameout, '...', '_') ;
nameout = strrep(nameout, '%', 'perc') ;
nameout = strrep(nameout, '>=', 'GE') ;
nameout = strrep(nameout, '<=', 'SE') ;
nameout = strrep(nameout, '>', 'G') ;
nameout = strrep(nameout, '<', 'S') ;
nameout = strrep(nameout, '=', 'E') ;
nameout = strrep(nameout, '.', '') ;
nameout = strrep(nameout, '(', '') ;
nameout = strrep(nameout, ')', '') ;
nameout = strrep(nameout, ',', '') ;
