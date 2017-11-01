function [ loss_fwh, loss_deair ] = gui_valve_dialog(n_fwh, n_fwh_hp, ex_val, daex_val)
%gui_bypass_dialog Generate valve pressire loss value with a dialog

% Returns: vector of percentage of 1 lossed. Example: [0.05 0.05 0 0.02]

% Create figure
f = figure('Name','Set valve pressure loss',...
    'Visible','off','NumberTitle','off',...
    'MenuBar','none','ToolBar','none',...
    'Resize','off','WindowStyle','modal');

% Buttons for bypasses
hor_dist=60; % pixels

boxes=cell(n_fwh+1,1);

for i=1:n_fwh+1
    if i==n_fwh_hp+1
        uicontrol('Style','text',...
            'Position',[hor_dist*i-25,80,50,15],...
            'String','DeAir');
        
        boxes{i}=uicontrol('Style','edit',...
            'Position',[hor_dist*i-20,55,40,20],...
            'String',sprintf('%.2f',daex_val*100));
    elseif i<n_fwh_hp+1
        uicontrol('Style','text',...
            'Position',[hor_dist*i-25,80,50,15],...
            'String',sprintf('FWH %i',i));
        
        boxes{i}=uicontrol('Style','edit',...
            'Position',[hor_dist*i-20,55,40,20],...
            'String',sprintf('%.2f',ex_val(i)*100));
    else
        uicontrol('Style','text',...
            'Position',[hor_dist*i-25,80,50,15],...
            'String',sprintf('FWH %i',i-1));
        
        boxes{i}=uicontrol('Style','edit',...
            'Position',[hor_dist*i-20,55,40,20],...
            'String',sprintf('%.2f',ex_val(i-1)*100));
    end
end

% Calculate figure size
fig_width=hor_dist*(n_fwh+2);
if fig_width<360
    fig_width=360;
end

uicontrol('Style','text',...
    'Position',[0,100,fig_width,30],...
    'String',sprintf(['Introduce perceantage of initial pressure loss for each line',...
    '\n        Example: set value to 2 for a 2%% pressure loss']),...
    'HorizontalAlignment','center');

% Accept and cancel boxes
but_width=80;
but_height=30;
but_inter_margin=10;

can_but=uicontrol('Style','pushbutton',...
    'Position',[fig_width-but_width-but_inter_margin,but_inter_margin,but_width,but_height],...
    'String','Cancel');

ok_but=uicontrol('Style','pushbutton',...
    'Position',[can_but.Position(1)-but_width-but_inter_margin,but_inter_margin,but_width,but_height],...
    'String','Ok');

% Resize figure
f.Position(3)=fig_width;
f.Position(4)=140;

% Set callbacks
ok_but.Callback=@(src,evdata) ok_callback(src,evdata);
can_but.Callback=@(src,evdata) can_callback(src,evdata);

loss_fwh=-1;
loss_deair=-1;

% Show figure
f.Visible='on';

uiwait(f)

    function ok_callback(~,~)
        % Get activated boxes
        loss_fwh=zeros(1,n_fwh);
        for b=1:n_fwh+1
            if b==n_fwh_hp+1
                if isempty(boxes{b}.String)
                    loss_deair=0;
                else
                    loss_deair=str2double(boxes{b}.String)/100;
                end
            else
                if b>n_fwh_hp+1
                    idx=b-1;
                else
                    idx=b;
                end
                
                if isempty(boxes{b}.String)
                    loss_fwh(idx)=0;
                else
                    loss_fwh(idx)=str2double(boxes{b}.String)/100;
                end
            end
        end
        
        uiresume(f);
        
        % Close figure
        close(f);
    end

    function can_callback(~,~)
        % Set bypass to -1 for no action
        loss_fwh=-1;
        loss_deair=-1;
        
        uiresume(f);
        
        % Close figure
        close(f);
    end

end

