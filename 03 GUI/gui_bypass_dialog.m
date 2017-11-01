function [ bypass ] = gui_bypass_dialog(n_fwh)
%gui_bypass_dialog Generate bypass vector with a dialog

% Create figure
f = figure('Name','Choose FWHs to bypass',...
    'Visible','off','NumberTitle','off',...
    'MenuBar','none','ToolBar','none',...
    'Resize','off','WindowStyle','modal');

% Buttons for bypasses
hor_dist=60; % pixels

buttons=cell(n_fwh,1);

for i=1:n_fwh
    buttons{i}=uicontrol('Style','checkbox',...
        'Position',[hor_dist*i-10,55,20,15]);
    
    uicontrol('Style','text',...
        'Position',[hor_dist*i-25,70,50,15],...
        'String',sprintf('FWH %i',i));
end

% Calculate figure size
fig_width=hor_dist*(n_fwh+1);
if fig_width<360
    fig_width=360;
end

% Accept and cancel buttons
but_width=80;
but_height=30;
but_inter_margin=10;

can_but=uicontrol('Style','pushbutton',...
    'Position',[fig_width-but_width-but_inter_margin,but_inter_margin,but_width,but_height],...
    'String','Cancel');

ok_but=uicontrol('Style','pushbutton',...
    'Position',[can_but.Position(1)-but_width-but_inter_margin,but_inter_margin,but_width,but_height],...
    'String','OK');

% Resize figure
f.Position(3)=fig_width;
f.Position(4)=100;

% Set callbacks
ok_but.Callback=@(src,evdata) ok_callback(src,evdata);
can_but.Callback=@(src,evdata) can_callback(src,evdata);

bypass=-1;

% Show figure
f.Visible='on';

uiwait(f)

    function ok_callback(~,~)        
        % Get activated buttons
        bypass=zeros(1,n_fwh);
        for b=1:n_fwh
            bypass(b)=buttons{b}.Value;
        end
        
        uiresume(f);
        
        % Close figure
        close(f);
    end

    function can_callback(~,~)
        % Set bypass to -1 for no action
        bypass=-1;
        
        uiresume(f);
        
        % Close figure
        close(f);        
    end

end

