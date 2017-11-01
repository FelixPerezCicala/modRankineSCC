function gui_cycle_conf (cy_conf)
% Generate cycle configuration input window

% Initialize figure
width=850;
height=600;

scrsz = get(groot,'ScreenSize');

% Determine avaiable hardware acceleration
opengldata = opengl('data');

if strcmp(opengldata.HardwareSupportLevel,'full')
    renderer='opengl';
else
    renderer='painters';
end

f=figure('Name','Cycle configuration','NumberTitle','off',...
    'Visible','off','Renderer',renderer,...
    'MenuBar','none','ToolBar','none',...
    'Position',[(scrsz(3)-width)/2,(scrsz(4)-height)/2,width,height]);

% Diagram panel
diag_pan_pos=[0.01,0.47,0.98,0.52];

diag_pan=uipanel(f,'Units','normalized','Position',diag_pan_pos,...
    'Title','Diagram');

% Diagram axes object
diag_ax=axes(diag_pan,'Box','off',...
    'NextPlot','add',...
    'XColor','none','YColor','none',...
    'Units','normalized','Position',[0,0,1,1],...
    'Color',[1,1,1]);

% Configure extractiones panel
conf_ex_pos=[0.01,0.145,0.98,0.325];

conf_ex=uipanel(f,'Units','normalized','Position',conf_ex_pos,...
    'Title','Set extraction values');

% Heater train
hea_pan_pos=[0.01,0.065,0.98,0.07];
hea_pan=uipanel(f,'Units','normalized','Position',hea_pan_pos,...
    'Title','Heater train');

% Build buttons
but_width=0.08;
but_height=0.045;
but_inter_margin=0.005;

canc_but_pos=[1-0.01-but_width,0.01,but_width,but_height];
but_canc=uicontrol(f,'Style','pushbutton','String','Cancel',...
    'Units','normalized','Position',canc_but_pos,...
    'Callback',@canc_but_cb);

next_but_pos=canc_but_pos+[-but_inter_margin*4-but_width,0,0,0];
but_next=uicontrol(f,'Style','pushbutton','String','Next >',...
    'Units','normalized','Position',next_but_pos,...
    'Callback',@next_but_cb);

back_but_pos=next_but_pos+[-but_inter_margin-but_width,0,0,0];
but_back=uicontrol(f,'Style','pushbutton','String','< Back',...
    'Units','normalized','Position',back_but_pos,...
    'Callback',@back_but_cb);

%%%%%%%
% Draw diagram and build boxes
[box_cell,deair]=draw_diag_build_boxes(cy_conf);

% Get number of heaters
IP_in_pos=find(cy_conf.EX_d(2,:)==2);
LP_in_pos=find(cy_conf.EX_d(2,:)==3);

htrs_HP=sum(cy_conf.EX_d(2,1:IP_in_pos)==0);
htrs_IP=sum(cy_conf.EX_d(2,IP_in_pos:LP_in_pos)==0);

% Build heater train panel
htr_train_texts={'Number of Low Pres. FWH','Number of Intermediate Pres. FWH','Number of High Pres. FWH'};
htr_train_values=[cy_conf.N_FWH_LP,htrs_IP,htrs_HP];
htr_train_options_HP=[1,2];
htr_train_options_IP=[0,1,2];
htr_train_options_LP=[3,4,5];
callnack_change_fwh_num=@(src,evdata) change_fwh_num(src,evdata,cy_conf);

htr_train_lists=build_htr_train_listboxes(hea_pan,htr_train_texts,...
    htr_train_values,htr_train_options_LP,htr_train_options_IP,...
    htr_train_options_HP,callnack_change_fwh_num);

% Make figure visible
f.Visible='on';

%%%%%
% Callbacks
    function canc_but_cb(~,~)
        % Close figure
        delete(diag_ax);
        close(f);
    end

    function next_but_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
        
        % Call next step
        gui_solve(cy_conf)
        
        % Close figure
        delete(diag_ax);
        close(f);
    end

    function back_but_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
        
        % Go back to previous step
        gui_new_conf(cy_conf)
        
        % Close figure
        delete(diag_ax);
        close(f);
    end

%%%%%
% Auxiliary functions
    function store_values_in_cycle(c_des)
        
        % FWHs
        pres=zeros(1,c_des.N_FWH);
        
        for c=1:cy_conf.N_FWH
            c_des.TTD_d(c)=str2double(box_cell{1,c}.String);
            c_des.DCA_d(c)=str2double(box_cell{2,c}.String);
            c_des.EX_ploss(c)=str2double(box_cell{3,c}.String)/100;
            pres(c)=str2double(box_cell{4,c}.String);
        end
        
        pos=1;
        for c=1:size(c_des.EX_d,2)
            if c_des.EX_d(2,c)==0
                c_des.EX_d(1,c)=pres(pos);
                pos=pos+1;
            end
        end
        
        % Deareator
        cy_conf.DAEX_ploss=str2double(deair{1}.String)/100;
        cy_conf.EX_d(1,cy_conf.EX_d(2,:)==3)=str2double(deair{2}.String);
        
        % Turbine information
        cy_conf.EX_d(1,1)=cy_conf.tur_conf{4,1};
        cy_conf.EX_d(1,end)=cy_conf.tur_conf{5,2};
        cy_conf.EX_d(1,cy_conf.EX_d(2,:)==2)=cy_conf.tur_conf{4,2};
        
    end

    function boxes = build_editbox_group(parent,position,name)
        % Build a uipanel with position property and name
        % Inside de panel, set editboxes for Pres, Ploss, TTD, DCA
        % Return cell containing handles to said editboxes
        
        pan = uipanel(parent,'Units','normalized',...
            'Position',position,...
            'Title',name);
        
        % Edit boxes
        margin=0.03;
        inter_margin=0.02;
        box_size=(1-0.03*2-0.02*3)/4;
        
        pos_box=[margin,margin,1-margin*2,box_size/2];
        text_box=pos_box+[0,box_size/2-0.02,0,0];
        
        if ~strcmp(name,'Deareator')
            % Box1
            uicontrol(pan,'Style','text','Units','normalized',...
                'Position',text_box,'String','FWH TTD [ºC]',...
                'TooltipString',...
                sprintf('Feedwater Heater Terminal Temperature Difference [ºC]'));
            
            box1=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String','text');
            
            % Box2
            pos_box=pos_box+[0,box_size+inter_margin,0,0];
            text_box=pos_box+[0,box_size/2-0.02,0,0];
            
            uicontrol(pan,'Style','text','Units','normalized',...
                'Position',text_box,'String','FWH DCA [ºC]',...
                'TooltipString',...
                sprintf('Feedwater Heater Drain Cooler Approach [ºC]'));
            
            box2=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String','text');
        else
            pos_box=pos_box+[0,box_size+inter_margin,0,0];
        end
        
        % Box3
        pos_box=pos_box+[0,box_size+inter_margin,0,0];
        text_box=pos_box+[0,box_size/2-0.02,0,0];
        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String','Ex PLoss [%]',...
                'TooltipString',...
                sprintf('Extraction pressure loss to FWH [%%]'));
        
        box3=uicontrol(pan,'Style','edit','Units','normalized',...
            'Position',pos_box,'String','text');
        
        % Box4
        pos_box=pos_box+[0,box_size+inter_margin,0,0];
        text_box=pos_box+[0,box_size/2-0.02,0,0];
        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String','Ex P [bar]',...
                'TooltipString',...
                sprintf('Extraction pressure at turbine output [bar]'));
        
        box4=uicontrol(pan,'Style','edit','Units','normalized',...
            'Position',pos_box,'String','text');
        
        % Boxes cell
        if ~strcmp(name,'Deareator')
            boxes={box1;box2;box3;box4};
        else
            boxes={box3;box4};
        end
        
    end

    function boxes=build_htr_train_listboxes(pan,texts,values,opt1,opt2,opt3,callback)
        % Fill a panel with three listboxes and a button
        num_boxes=3;
        width_lba=0.825;
        margin=0.01;
        inter_margin=0.01;        
        text_width_hor=5/6*(width_lba-margin*2-inter_margin*(num_boxes-1))/num_boxes;
        box_width_hor=1/6*(width_lba-margin*2-inter_margin*(num_boxes-1))/num_boxes;
        box_height=1-margin*2;
        
        % Open temperatures plot button
        uicontrol(pan, 'Style','pushbutton','Units','normalized',...
            'Position',[margin,margin,1-width_lba-margin*2,box_height],...
            'String','Feedwater temp. rise',...
            'Callback',@(src,evdata) show_FW_temp_rise(src,evdata,cy_conf));
        
        boxes=cell(num_boxes,1);
        
        text_box=[1-width_lba+margin,0.01-0.2,text_width_hor,box_height];
        pos_box=[1-width_lba+margin+text_width_hor,...
            0.01,box_width_hor,box_height];
        
        options={opt1,opt2,opt3};
        
        for b=1:num_boxes
            if ~strcmp(texts(num_boxes-b+1),'empty')
                uicontrol(pan,'Style','text','Units','normalized',...
                    'Position',text_box,'String',texts{num_boxes-b+1},...
                    'HorizontalAlignment','center');
                
                boxes{num_boxes-b+1}=uicontrol(pan,'Style','popupmenu','Units','normalized',...
                    'Position',pos_box,'String',num2cell(options{num_boxes-b+1}),...
                    'Value',find(options{num_boxes-b+1}==values(num_boxes-b+1)),...
                    'Callback',callback);
            end
            
            text_box=text_box+[text_width_hor+box_width_hor+inter_margin,0,0,0];
            pos_box=pos_box+[text_width_hor+box_width_hor+inter_margin,0,0,0];
        end
    end

    function [boxes,deair_box] = draw_diag_build_boxes(c_des)
        
        % Select number of fwh
        fIP_in_pos=find(c_des.EX_d(2,:)==2);
        fhtrs_HP=sum(c_des.EX_d(2,1:fIP_in_pos)==0);
        
        % Draw the diagram in diag_ax
        cla(diag_ax);
        [~,~,fwh_cords,~,~] = diag_cy(c_des,0,diag_ax,false);
        
        % Get fwh positions
        limits=diag_ax.XLim;
        x_positions=zeros(1+c_des.N_FWH);
        for i=1:1+c_des.N_FWH
            x_positions(i)=fwh_cords{i}.Hot_in(1);
        end
        pos_offset=0.005;
        x_positions=x_positions./(limits(2)-limits(1))+pos_offset;
        
        % Build boxes panels
        box_width=0.11;
        if c_des.N_FWH_HP>=3 || c_des.N_FWH_LP==5
            box_width=0.08;
        end
        
        % Clear children of conf_ex
        children=allchild(conf_ex);
        delete(children);
        
        boxes=cell(4,c_des.N_FWH);
        
        for i=1:c_des.N_FWH_HP
            boxes(:,i) = build_editbox_group(conf_ex,...
                [x_positions(i)-box_width/2,0.01,box_width,0.98],...
                sprintf('Extraction %i',i));
        end
        
        deair_box=build_editbox_group(conf_ex,...
            [x_positions(c_des.N_FWH_HP+1)-box_width/2,0.01,box_width,0.98],...
            sprintf('Deareator',i));
        
        for i=c_des.N_FWH_HP+1:c_des.N_FWH
            boxes(:,i) = build_editbox_group(conf_ex,...
                [x_positions(i+1)-box_width/2,0.01,box_width,0.98],...
                sprintf('Extraction %i',i));
        end
        
        % Load c_des values
        pressures=c_des.EX_d(1,c_des.EX_d(2,:)==0);
        pressures(fhtrs_HP)=c_des.tur_conf{5,1};
        
        for i=1:c_des.N_FWH
            boxes{1,i}.String=sprintf('%.2f',c_des.TTD_d(i));
            boxes{2,i}.String=sprintf('%.2f',c_des.DCA_d(i));
            boxes{3,i}.String=sprintf('%.2f',c_des.EX_ploss(i)*100);
            boxes{4,i}.String=sprintf('%.2f',pressures(i));
        end
        
        % Disable HP Turbine exhaust pressure
        if fhtrs_HP==1
            boxes{4,1}.Enable='off';
        else
            % Disable second FWH pressure
            boxes{4,2}.Enable='off';
        end
        
        % Rebuild deareator values
        deair_box{1}.String=sprintf('%.2f',cy_conf.DAEX_ploss*100);
        deair_box{2}.String=sprintf('%.2f',cy_conf.EX_d(1,cy_conf.EX_d(2,:)==3));
    end

    function change_fwh_num(~,~,c_des)
        % Change number of FWHs
        
        % Select number of fwh
        n_fwh_HP=htr_train_options_HP(htr_train_lists{3}.Value);
        n_fwh_IP=htr_train_options_IP(htr_train_lists{2}.Value);
        n_fwh_LP=htr_train_options_LP(htr_train_lists{1}.Value);
        
        % Reload some defaults (precaution in case coming from next
        % window)
        c_des.load_default_EX_TTD_EXPloss;
        
        % Build EX Matrix
        c_des.EX_d(1,1)=c_des.tur_conf{4,1};
        c_des.EX_d(1,3)=c_des.tur_conf{4,2};
        c_des.EX_d(1,2)=c_des.tur_conf{4,2}/(1-c_des.RHTR_ploss);
        
        c_des.EX_d(1,end)=ps_T_97(c_des.T_con_max)*10;
        
        % If remove a fwh from LP train
        if n_fwh_LP==3
            c_des.EX_d=[c_des.EX_d(:,1:5),c_des.EX_d(:,7:end)];
            c_des.TTD_d=[c_des.TTD_d(1:2),c_des.TTD_d(4:6)];
            c_des.DCA_d=[c_des.DCA_d(1:2),c_des.DCA_d(4:6)];
            c_des.EX_ploss=[c_des.EX_ploss(1:2),c_des.EX_ploss(4:6)];
        end
        
        % If add a fwh to LP train
        if n_fwh_LP==5
            c_des.EX_d=[c_des.EX_d(:,1:5),[0;0;2],c_des.EX_d(:,6:end)];
            c_des.TTD_d=[c_des.TTD_d(1:2),0,c_des.TTD_d(3:end)];
            c_des.DCA_d=[c_des.DCA_d(1:2),0,c_des.DCA_d(3:end)];
            c_des.EX_ploss=[c_des.EX_ploss(1:2),0,c_des.EX_ploss(3:end)];
        end
                
        % If remove fwh in IP train
        if n_fwh_IP==0
            c_des.EX_d=[c_des.EX_d(:,1:3),c_des.EX_d(:,5:end)];
            c_des.TTD_d=[c_des.TTD_d(1),c_des.TTD_d(3:end)];
            c_des.DCA_d=[c_des.DCA_d(1),c_des.DCA_d(3:end)];
            c_des.EX_ploss=[c_des.EX_ploss(1),c_des.EX_ploss(3:end)];
        end
        
        % If insert new fwh in IP train
        if n_fwh_IP==2
            c_des.EX_d=[c_des.EX_d(:,1:3),[0;0;2],c_des.EX_d(:,4:end)];
            c_des.TTD_d=[c_des.TTD_d(1),0,c_des.TTD_d(2:end)];
            c_des.DCA_d=[c_des.DCA_d(1),0,c_des.DCA_d(2:end)];
            c_des.EX_ploss=[c_des.EX_ploss(1),0,c_des.EX_ploss(2:end)];
        end
        
        % If insert new fwh in HP train
        if n_fwh_HP==2
            c_des.EX_d=[c_des.EX_d(:,1),[0;0;1],c_des.EX_d(:,2:end)];
            c_des.TTD_d=[0,c_des.TTD_d];
            c_des.DCA_d=[0,c_des.DCA_d];
            c_des.EX_ploss=[0,c_des.EX_ploss];
        end
                
        % Store number of FWH
        c_des.N_FWH=n_fwh_HP+n_fwh_IP+n_fwh_LP;
        c_des.N_FWH_HP=n_fwh_HP+n_fwh_IP;
        c_des.N_FWH_LP=n_fwh_LP;
        
        % Redraw
        [box_cell,deair]=draw_diag_build_boxes(c_des);
        
        drawnow;
    end

    function show_FW_temp_rise(~,~,c_org)
        % Show the Feedwater temperature rise across the FWH train
        
        % Store results
        store_values_in_cycle(c_org);
        
        % Temps vector
        temps=zeros(1,c_org.N_FWH+1);
        
        % Pressures
        pres=c_org.EX_d(1,c_org.EX_d(2,:)==0);
        p_deair=c_org.EX_d(1,c_org.EX_d(2,:)==3);
        
        % Calculate temperature rise for each FWH in the LP train        
        T_in=Ts_p_97(c_org.EX_d(1,end)/10);
        for h=c_org.N_FWH:-1:c_org.N_FWH_HP+1
            T_out=Ts_p_97(pres(h)/10)-c_org.TTD_d(h);
            
            temps(h+1)=T_out-T_in;
            
            T_in=T_out;
        end
        
        % Calculate temperature rise for deareator
        temps(c_org.N_FWH_HP+1)=Ts_p_97(p_deair/10)-T_in;
        
        % Calculate temperature rise for each FWH in the HP train        
        T_in=Ts_p_97(p_deair/10);
        for h=c_org.N_FWH_HP:-1:1
            T_out=Ts_p_97(pres(h)/10)-c_org.TTD_d(h);
            
            temps(h)=T_out-T_in;
            
            T_in=T_out;
        end
        
        % Create bar plot
        f_rise=figure('Name','Temperature rise at each FWH','Visible','off',...
            'NumberTitle','off');
        
        ax=axes(f_rise);
        
        bar(ax,temps);
        
        ax.Title.String='Temperature rise at each FWH and deareator';
        ax.XLabel.String='FWH number';
        ax.YLabel.String='Temperature rise [ºC]';
        ax.XTickLabel{c_org.N_FWH_HP+1}='DeAir';
        
        f_rise.Visible='on';
        
    end
end
