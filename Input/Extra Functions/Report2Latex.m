% choose the Latex file name
filename = 'basicLatexFileGenerated.tex';
delete(filename);
 
fid = fopen(filename, 'at');
fprintf(fid, ['\\documentclass[10pt]{article}' '\n']);
% choose a font for your document
fprintf(fid, ['\\usepackage{mathpazo}' '\n\n']);
% write the title of your document
fprintf(fid, ['\\title{Generated Latex File}' '\n']);
% remove the date from the title generated with the command \maketitle
fprintf(fid, ['\\date{}' '\n']);
 % begining of your document
fprintf(fid, ['\\begin{document}' '\n\n']);
% write the title and the table of contents
fprintf(fid, ['\\maketitle' '\n']);
fprintf(fid, ['\\tableofcontents' '\n\n']);
% write the content of your document
fprintf(fid, ['\\section{First section of the document}' '\n']);
fprintf(fid, ['\\subsection{First subsection of the document}' '\n']);
fprintf(fid, ['\\subsubsection{First subsubsection of the document}' '\n']);
fprintf(fid, ['Here is a list of bullet points generated from MATLAB:' '\n']);
fprintf(fid, ['\\begin{itemize}' '\n']);
    fprintf(fid, ['\\item First bullet point' '\n']);
    fprintf(fid, ['\\item Second bullet point' '\n']);
fprintf(fid, ['\\end{itemize}' '\n\n']);
% end of your document
fprintf(fid, ['\\end{document}' '\n']);
fclose(fid);