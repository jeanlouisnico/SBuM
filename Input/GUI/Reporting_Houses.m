import mlreportgen.dom.* ;
import mlreportgen.report.* ;
rpt_type = 'pdf';
doc = Report('mydoc', rpt_type); 

add(doc,'Hello World');

close(doc)

rptview(doc.OutputPath) ;