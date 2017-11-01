function gui_solve(cy_conf)
%gui_solve Gui for solving a configuration
% Initialize figure
width=400;
height=360;

scrsz = get(groot,'ScreenSize');

f=figure('Name','Run solver','NumberTitle','off',...
    'Visible','off',...
    'MenuBar','none','ToolBar','none',...
    'Position',[(scrsz(3)-width)/2,(scrsz(4)-height)/2,width,height]);

% Buttons
but_height=0.08;
but_margin=0.01;
but_width=0.2;

% Close button
canc_but_pos=[1-but_margin-but_width,but_margin,but_width,but_height];
but_canc=uicontrol(f,'Style','pushbutton','String','Cancel',...
    'Units','normalized','Position',canc_but_pos,...
    'Callback',@canc_but_cb);

% Back button
back_but_pos=canc_but_pos+[-but_width-but_margin,0,0,0];
but_back=uicontrol(f,'Style','pushbutton','String','< Back',...
    'Units','normalized','Position',back_but_pos,...
    'Callback',@back_but_cb);

% Save configuration button
save_config_pos=[0.5-but_width*1.75/2,but_margin*2+but_height,but_width*1.75,but_height];
save_config=uicontrol(f,'Style','pushbutton','String','Save configuration',...
    'Units','normalized','Position',save_config_pos,...
    'Callback',@save_config_cb);

% Solve button
solv_pos=save_config_pos+[0,but_margin+but_height,0,0];
solv_but=uicontrol(f,'Style','pushbutton','String','Solve',...
    'Units','normalized','Position',solv_pos,...
    'Callback',@solv_cb);

% Panels
pan_width=0.98;
pan_height=(1-0.01*3-but_margin*4-but_height*3);
load_pan_height=pan_height*4/16;
iter_pan_height=pan_height*8/16;
par_pan_height=pan_height*4/16;

% Loads to calculate
load_opt_pos=[0.01,1-0.01-load_pan_height,pan_width,load_pan_height];
load_opt=uipanel(f,'Units','normalized','Position',load_opt_pos,...
    'Title','Partial load options');

% Iteration control
iter_control_pos=[0.01,load_opt_pos(2)-0.01-iter_pan_height,pan_width,iter_pan_height];
iter_control=uipanel(f,'Units','normalized','Position',iter_control_pos,...
    'Title','Iteration control');

% Parallel processing
par_proc_pos=[0.01,iter_control_pos(2)-0.01-par_pan_height,pan_width,par_pan_height];
par_proc=uipanel(f,'Units','normalized','Position',par_proc_pos,...
    'Title','Parallel processing');

% Build loads panel
load_texts={'Step size (minimum TFR step) [%]';'Minimum TFR (20-100) [%]'};
load_values=[cy_conf.pl_TFR_step*100;cy_conf.pl_TFR_min*100];

load_boxes=build_all_boxes(load_opt,load_texts,load_values,2);

% Build iteration control panel
iter_texts={'Maximum number of iterations';...
    'Deviation tolerance (use 1e-3 format)';...
    'Residuals tolerance (use 1e-3 format)';...
    'Dampening factor (value range 0-1)'};

iter_values=[cy_conf.max_iterations;cy_conf.tolerance_dev;...
    cy_conf.tolerance_res;cy_conf.dampening_factor];

iter_boxes=build_all_boxes(iter_control,iter_texts,iter_values,4);

% Use special format for deviation and residuals
iter_boxes{2}.String=sprintf('%0.0e',iter_values(2));
iter_boxes{3}.String=sprintf('%0.0e',iter_values(3));

% Build parallel processing options
cores=0;
num_cores_available=-1;
[par_check,par_list]=build_paraproc_boxes(par_proc);

% Set checkbox callback
par_check.Callback=@(src,evdata) par_ckeck_callback(src,evdata,par_list);

% Make figure visible
f.Visible='on';

%%%%%
% Callbacks
    function solv_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
        
        run=false;
        
        if par_check.Value
            if num_cores_available==cy_conf.num_cores
                n=newline;
                text_height=100;
                
                text_string=[sprintf('Using parallel processing with all cores (%i) can cause',num_cores_available),n,...
                    'freezes and, in some systems, complete OS crashes.',n,n,...
                    'This is specially not recommended in i3 or i5 systems',n,n,...
                    'Are you sure you want to proceed?'];
                
                exit_flag=create_ok_cancel_dialog(text_string,text_height);
                
                if strcmp(exit_flag,'ok')
                    run=true;
                end
            else
                run=true;
            end
        else
            run=true;
        end
        
        if run
            % Close figure
            close(f);
            
            % Call solver
            cycle_solver(cy_conf);
        end
        
    end

    function canc_but_cb(~,~)
        % Close figure
        close(f);
    end

    function back_but_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
                
        % Go back to previous step
        gui_cycle_conf(cy_conf)
        
        % Close figure
        close(f);
    end

    function save_config_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
                
        % Save configuration
        cycle_solution_save([],[],cy_conf,'configuration');
        
    end

    function par_ckeck_callback(src,~,list_box)
        % Parallel processing checkbox callback
        switch src.Value
            case false
                list_box.Enable='off';
            case true
                list_box.Enable='on';
        end
    end

    function store_values_in_cycle(c_des)
        % Store selected options in cycle conf
        c_des.pl_TFR_step=str2double(load_boxes{1}.String)/100;
        c_des.pl_TFR_min=str2double(load_boxes{2}.String)/100;
        c_des.max_iterations=str2double(iter_boxes{1}.String);
        c_des.tolerance_dev=str2double(iter_boxes{2}.String);
        c_des.tolerance_res=str2double(iter_boxes{3}.String);
        c_des.dampening_factor=str2double(iter_boxes{4}.String);
        
        if par_check.Value
            c_des.num_cores=cores{par_list.Value};
        else
            % Single thread
            c_des.num_cores=-1;
        end
    end

%%%%%
% Auxiliary functions
    function boxes = build_all_boxes(pan,texts,values,num_boxes)
        % Fill a panel with edit boxes
        margin=0.03;
        inter_margin=0.03;
        box_width=(1-margin*2-inter_margin)*2/3;
        box_height=(1-margin*2-inter_margin*(num_boxes-1))/num_boxes;
        
        boxes=cell(num_boxes,1);
        
        switch num_boxes
            case 1
                text_offset=0.25;
            case 2
                text_offset=0.12;
            case 3
                text_offset=0.08;
            case 4
                text_offset=0.05;
            case 7
                text_offset=0.03;
            otherwise
                text_offset=0.05;
        end
        
        text_box=[margin,margin-text_offset,box_width,box_height];
        pos_box=text_box+[box_width+inter_margin,text_offset,-box_width/2,0];
        
        for i=1:num_boxes
            if ~strcmp(texts(num_boxes-i+1),'empty')
                uicontrol(pan,'Style','text','Units','normalized',...
                    'Position',text_box,'String',texts{num_boxes-i+1},...
                    'HorizontalAlignment','left');
                
                boxes{num_boxes-i+1}=uicontrol(pan,'Style','edit','Units','normalized',...
                    'Position',pos_box,'String',sprintf('%.2f',values(num_boxes-i+1)));
            end
            
            text_box=text_box+[0,box_height+inter_margin,0,0];
            pos_box=pos_box+[0,box_height+inter_margin,0,0];
        end
        
    end

    function [parproc_on,num_cores] = build_paraproc_boxes(pan)
        % Build parallel processing boxes in pan
        
        margin=0.03;
        inter_margin=0.03;
        box_height=(1-margin*2-inter_margin);
        box_width=1-margin*2-inter_margin;
        
        % Checkbox
        chk_box_pos=[margin,1-margin-box_height/3-0.05,box_width,box_height/3];
        
        parproc_on=uicontrol(pan,'Style','Checkbox','Units','normalized',...
            'Position',chk_box_pos,'Value',false,...
            'String','Enable parallel processing');
        
        % Get number of cores available
        try
            num_cores_available=feature('numCores');
        catch
            % Disable multithreading option
            parproc_on.Enable='off';
            num_cores_available=-1;
        end
        
        % Build options
        cores=num2cell(1:num_cores_available);
        
        % Number of cores listbox
        txt_box_pos=[margin,1-margin*2-box_height*2/3-0.2,...
            box_width*2/3,box_height/3];
        
        list_box_pos=[margin+box_width*2/3+inter_margin,1-margin*2-box_height*2/3-0.05,...
            box_width*1/3,box_height/3];
        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',txt_box_pos,'String','Number of cores',...
            'HorizontalAlignment','left');
        
        num_cores=uicontrol(pan,'Style','popupmenu','Units','normalized',...
            'Position',list_box_pos,'String',cores,...
            'Value',size(cores,2),'Enable','off');
    end

end

