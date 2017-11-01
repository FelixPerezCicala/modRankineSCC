function gui_run()
%gui_run Initiate program execution

% Initialize figure
width=400;
height=300;

scrsz = get(groot,'ScreenSize');

f=figure('Name','Cycle configuration','NumberTitle','off',...
    'Visible','off',...
    'MenuBar','none','ToolBar','none',...
    'Position',[(scrsz(3)-width)/2,(scrsz(4)-height)/2,width,height]);

% Panels
pan_width=0.98;
pan_height=(1-0.01*3-0.11)/3;

% New configuration
new_conf_pan_pos=[0.01,1-0.01-pan_height,pan_width,pan_height];
new_conf_pan=uipanel(f,'Units','normalized','Position',new_conf_pan_pos,...
    'Title','New configuration','FontSize',12);

% Load configuration
load_conf_pan_pos=new_conf_pan_pos-[0,0.01+pan_height,0,0];
load_conf_pan=uipanel(f,'Units','normalized','Position',load_conf_pan_pos,...
    'Title','Load configuration','FontSize',12);

% Load solution
load_sol_pan_pos=load_conf_pan_pos-[0,0.01+pan_height,0,0];
load_sol_pan=uipanel(f,'Units','normalized','Position',load_sol_pan_pos,...
    'Title','Load solution','FontSize',12);

% Close button
but_width=0.2;
but_height=0.09;
but_inter_margin=0.005;

clo_but_pos=[1-0.01-but_width,0.01,but_width,but_height];
but_clo=uicontrol(f,'Style','pushbutton','String','Close',...
    'Units','normalized','Position',clo_but_pos,...
    'Callback',@close_but_cb);

% Build texts and options
text_new=strcat(sprintf('Solve a new cycle configuration.'),...
    sprintf('\nDefault parameters will be loaded.'));

text_load_conf=strcat(sprintf(['Load a previously generated configuration.',...
    '\nUse this option to modify a configuration stored\nin a solution file.',...
    '\nConfiguration files are named ''filename.conf.mat''']));

text_load_sol=strcat(sprintf(['Load a previously calculated solution',...
    '\nSolution files are named ''filename.sol.mat''']));

build_text_and_button(new_conf_pan,text_new,'Next >',@new_sol);
build_text_and_button(load_conf_pan,text_load_conf,'Open file',@load_conf);
build_text_and_button(load_sol_pan,text_load_sol,'Open file',@load_sol);

% Make figure visible
f.Visible='on';

%%%%%
% Callbacks
    function close_but_cb(~,~)
        % Close figure
        close(f);
    end

    function new_sol(~,~)
        % Generate new solution
        
        % Call next gui
        gui_new_conf();
        
        % Close figure
        close(f);
    end

    function load_conf(~,~)
        % Load configuration
        
        [exit_flag,~,~,cy_conf,~]=cycle_load_solution('configuration');
        
        if strcmp(exit_flag,'success')
            % Call next gui
            gui_new_conf(cy_conf);
            
            % Close figure
            close(f);
        end
    end

    function load_sol(~,~)
        % Load solution
        
        [exit_flag,c1,c2,cy_conf,fname]=cycle_load_solution('solution');
        
        if strcmp(exit_flag,'success')
            % Call next gui
            draw_PLcycle_par(c1,c2,cy_conf,true,'gui_run',fname);
            
            % Close figure
            close(f);
        end
    end

%%%%%
% Auxiliary functions
    function build_text_and_button(pan,tstring,but_string,but_callback)
        % Set in pan text and a button
        margin=0.03;
        button_height=0.45;
        button_width=0.2;
        
        text_pos=[margin,margin,1-margin*2-button_width,0.98];
        button_pos=[1-margin-button_width,0.5-button_height/2,...
            button_width,button_height];
        
        % Text
        uicontrol(pan,'Style','text','String',tstring,'Units','normalized',...
            'Position',text_pos,'HorizontalAlignment','left');
        
        % Button
        uicontrol(pan,'Style','pushbutton','String',but_string,...
            'Units','normalized','Position',button_pos,...
            'Callback',but_callback);
        
        
    end

end

