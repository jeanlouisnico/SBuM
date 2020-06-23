import mlreportgen.dom.*;
d = Document('mydoc','docx');
p = Paragraph('Hello World');
load Input_Data
append(d,p);
HouseNbr = Input_Data(2,2);
HouseNbr = HouseNbr{1};
p = Paragraph(strcat('There are ',num2str(HouseNbr),' Houses in the model'));
append(d,p);

tableArray = {'a','b';'c','d'};
append(d,tableArray);

close(d);

%rptview('mydoc.pdf');