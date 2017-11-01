function exit_flag=create_ok_cancel_dialog(text_string,text_height)
%create_ok_cancel_dialog Makes an ok cancel dialog

% Initialize figure
if nargin==1
    text_height=50;
    height=100;
else
    height=100+text_height-50;
end

width=300;

scrsz = get(groot,'ScreenSize');

f=figure('Name','Warning','NumberTitle','off',...
    'Visible','off',...
    'Color',[255,255,255]/255,...
    'MenuBar','none','ToolBar','none',...
    'Position',[(scrsz(3)-width)/2,(scrsz(4)-height)/2,width,height],...
    'Resize','off','WindowStyle','modal');

% Text
text_pos=[10,height-10-text_height,width-20,text_height];
uicontrol(f,'Style','text','String',text_string,...
    'Units','pixels','Position',text_pos,...
    'Callback',@cancel_but_cb,...
    'HorizontalAlignment','left');

% Make 2 buttons
but_width=80;
but_height=30;
but_inter_margin=20;

% Cancel button
can_but_pos=[width/2-but_width-but_inter_margin/2,10,but_width,but_height];
can_but=uicontrol(f,'Style','pushbutton','String','Cancel',...
    'Units','pixels','Position',can_but_pos,...
    'Callback',@cancel_but_cb);

% Ok button
ok_but_pos=[width/2+but_inter_margin/2,10,but_width,but_height];
ok_but=uicontrol(f,'Style','pushbutton','String','Ok',...
    'Units','pixels','Position',ok_but_pos,...
    'Callback',@ok_but_cb);

% Make figure visible
f.Visible='on';

% Force wait out
uiwait

% Callbacks
    function cancel_but_cb(~,~)                
        exit_flag='cancel';
        close(f);
    end

    function ok_but_cb(~,~)
        exit_flag='ok';
        close(f);
    end

end

