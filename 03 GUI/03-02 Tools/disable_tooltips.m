function disable_tooltips(fig,zoom_pan_on,data_cursor_on)
%disable_tooltips Disables all tooltips of fig, excpet print and save

% Inputs:
% zoom_pan_on -> Boolean, enable zoom and pan tools
% data_cursor_on -> Boolean, enable data cursor tool

fhandle=findall(fig);

% Disable all except save and print
tbh=findall(fhandle,'ToolTipString','New Figure');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Open File');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Edit Plot');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Rotate 3D');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Brush/Select Data');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Link Plot');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Insert Colorbar');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Insert Legend');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Hide Plot Tools');
delete(tbh);
tbh=findall(fhandle,'ToolTipString','Show Plot Tools and Dock Figure');
delete(tbh);

if nargin==1
    zoom_pan_on=false;
end

if ~zoom_pan_on
    tbh=findall(fhandle,'ToolTipString','Zoom In');
    delete(tbh);
    tbh=findall(fhandle,'ToolTipString','Zoom Out');
    delete(tbh);
    tbh=findall(fhandle,'ToolTipString','Pan');
    delete(tbh);
end

if nargin<=2
    data_cursor_on=false;
end

if ~data_cursor_on
    tbh=findall(fhandle,'ToolTipString','Data Cursor');
    delete(tbh);
end

end

