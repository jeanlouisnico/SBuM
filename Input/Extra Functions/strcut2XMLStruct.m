function sXML = strcut2XMLStruct(s, filename, varargin)

% Loop through each of the structure array to resetructure it and make it
% available for xml formatting and saving

% A structure containing:
% s.XMLname.Attributes.attrib1 = "Some value";
% s.XMLname.Element.Text = "Some text";
% s.XMLname.DifferentElement{1}.Attributes.attrib2 = "2";
% s.XMLname.DifferentElement{1}.Text = "Some more text";
% s.XMLname.DifferentElement{2}.Attributes.attrib3 = "2";
% s.XMLname.DifferentElement{2}.Attributes.attrib4 = "1";
% s.XMLname.DifferentElement{2}.Text = "Even more text";
%
% Will produce:
% <XMLname attrib1="Some value">
%   <Element>Some text</Element>
%   <DifferentElement attrib2="2">Some more text</Element>
%   <DifferentElement attrib3="2" attrib4="1">Even more text</DifferentElement>
% </XMLname>
sfield = fieldnames(s)  ;
for i = 1:numel(sfield)
    %Loop through each field name
    if nargin <= 2
        sXML.(filename).Attributes.ShortName = "Saved Summary" ;
    else
        % In this case, this is a re-iteration
        
    end
    
    % Loop through each house
    for jj = 1:size(s.(sfield{i}),1)
        %If there are multiple sub elements in the house e.g. multiple
        %appliances
        sXML.(filename).Element{i}.Text = sfield{i} ; % ['House ',num2str(jj)]
        
        for kk = 1:size(s.(sfield{i}),2)
            Value = s.(sfield{i}) ;
            if isnumeric(Value{jj,kk})
                Valueinput = num2str(Value{jj,kk}) ;
                attrib = ['subElement',num2str(kk)] ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.(attrib) = Valueinput ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.Text = ['House ',num2str(jj)] ;
            elseif isa(Value{jj,kk},'logical')
                Valueinput = num2str(double(Value{jj,kk}));
                attrib = ['subElement',num2str(kk)] ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.(attrib) = Valueinput ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.Text = ['House ',num2str(jj)] ;
            elseif isa(Value{jj,kk}, 'char')
                Valueinput = Value{jj,kk} ;
                attrib = ['subElement',num2str(kk)] ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.(attrib) = Valueinput ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.Text = ['House ',num2str(jj)] ;
            elseif isa(Value{jj,kk}, 'struct')
                % in this case, we re-iterate to add multiple sub elements
                % to this one
                sXML.(filename).Element{i}.subElement{jj} = Value{jj,kk} ;
                sXML.(filename).Element{i}.subElement{jj}.Attributes.Text = ['House ',num2str(jj)] ;
            end
        end
    end
end
