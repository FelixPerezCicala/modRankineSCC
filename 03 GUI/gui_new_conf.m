function gui_new_conf(cy_conf)
%gui_new_conf Generate new conf (or load previous one)

%%%
% Default base isentropic performance for different turbine types
hp_tur_base_isen=[0.87,0.84];
iplp_tur_base_isen=[0.9193,0.9193,0.9295];

% If no input arguments, generate cy_conf with default values
if nargin==0
    cy_conf=cycle_configuration();
    cy_conf.load_defaults;
end

% Initialize figure
width=700;
height=574;

scrsz = get(groot,'ScreenSize');

f=figure('Name','Cycle configuration','NumberTitle','off',...
    'Visible','off',...
    'MenuBar','none','ToolBar','none',...
    'Position',[(scrsz(3)-width)/2,(scrsz(4)-height)/2,width,height]);

% Panels: Turbine configuration, heater temp and pressure loss, condenser
% : heater train settings, fwh geometry, pump performance

pan_width=0.485;
m_pan=0.005;

% Turbine panel
tur_pan_pos=[m_pan,1-0.8-m_pan,pan_width,0.8];
turb_pan=uipanel(f,'Units','normalized','Position',tur_pan_pos,...
    'Title','Turbine group');

tHP_pan=uipanel(turb_pan,'Units','normalized','Position',...
    [m_pan*2,1-7/15+m_pan,0.98,7/15-m_pan*3],...
    'Title','High Pressure Turbine');
tLP_pan=uipanel(turb_pan,'Units','normalized','Position',...
    [m_pan*2,m_pan*2,0.98,8/15-m_pan*3],...
    'Title','Intermediate and Low Pressure Turbine');

% Pump panel
pmp_pan_pos=[m_pan,tur_pan_pos(2)-m_pan-0.12,pan_width,0.12];
pmp_pan=uipanel(f,'Units','normalized','Position',pmp_pan_pos,...
    'Title','Pump performance');

% Cycle power
pow_pan_pos=[1-m_pan-pan_width,1-0.07-m_pan*3/4,pan_width,0.07];
pow_pan=uipanel(f,'Units','normalized','Position',pow_pan_pos,...
    'Title','Cycle shaft power');

% Heater panel (4 elements)
sg_pan_pos=[1-pan_width-m_pan,pow_pan_pos(2)-m_pan-0.22,pan_width,0.22];
sg_pan=uipanel(f,'Units','normalized','Position',sg_pan_pos,...
    'Title','Steam generator');

% FWH geometry panel
fwh_pan_pos=[1-pan_width-m_pan,sg_pan_pos(2)-m_pan-0.36,pan_width,0.36];
fwh_pan=uipanel(f,'Units','normalized','Position',fwh_pan_pos,...
    'Title','FWH geometry');

% Condenser panel (3 elements)
con_pan_pos=[1-pan_width-m_pan,fwh_pan_pos(2)-m_pan-0.17,pan_width,0.17];
con_pan=uipanel(f,'Units','normalized','Position',con_pan_pos,...
    'Title','Condenser');

% Build buttons
but_width=0.1;
but_height=0.05;
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

%%%%%%
% Build turbine panels
tur_texts_HP={'Turbine type'; 'Leakage type'; 'Governing Stage Pitch Diameter [m]';...
    'Nominal Inlet Pressure [bar]';'Nominal Exhaust Pressure [bar]';...
    'Nominal Isentropic Performance [%]';'';...
    'Throttle valve pressure loss [%]';''};

tur_texts_IPLP={'Turbine type'; 'Leakage type'; 'Governing Stage Pitch Diameter [m]';...
    'Nominal Inlet Pressure [bar]';'Nominal Exhaust Pressure [bar]';...
    'Nominal Isentropic Performance [%]';'Exhaust Annulus Area [m2]';...
    'Intercept valve pressure loss [%]';'Baumann factor (0 to disable)'};

tur_HP_values=cy_conf.tur_conf(:,1);
tur_IPLP_values=cy_conf.tur_conf(:,2);

HP_conf=build_turbine_panel(tHP_pan,tur_texts_HP,tur_HP_values);
IPLP_conf=build_turbine_panel(tLP_pan,tur_texts_IPLP,tur_IPLP_values);

% Disable HP turbine output pressure
HP_conf{5}.Enable='off';

% Disable LP turbine output pressure
IPLP_conf{5}.Enable='off';

% Set HP Turbine type callback
HP_conf{1}.Callback=@(src,evdata) hp_tur_type_cb(src,evdata);

% Set IPLP Turbine type callback
IPLP_conf{1}.Callback=@(src,evdata) iplp_tur_type_cb(src,evdata);

% Set IPLP inlet callback
IPLP_conf{4}.Callback=@change_HP_out_pres;

% Build heater panel
heater_texts={'Heater Temperature [ºC]';'Reheater Temperature [ºC]';...
    'Heater Pres. Loss [%]';'ReHeater Pres. Loss [%]'};

heater_values=[cy_conf.T_HTR_d-273;cy_conf.T_RHTR_d-273;...
    cy_conf.HTR_ploss*100;cy_conf.RHTR_ploss*100];

heater_boxes=build_all_boxes(sg_pan,heater_texts,heater_values,4);

% Set HP turbine output callback dependent on RHTR Ploss
heater_boxes{4}.Callback=@change_HP_out_pres;

% Build condenser panel
con_texts={'Condenser Temperature [ºC]';'Temperature at part load TFR [ºC]';...
    'Part load temperature TFR [%]'};

con_values=[cy_conf.T_con_max-273;cy_conf.T_con_min-273;...
    cy_conf.TFR_con_min*100];

con_boxes=build_all_boxes(con_pan,con_texts,con_values,3);

% Condenser temperature callback
con_boxes{1}.Callback=@change_LP_out_pres;

% Build heater geometry boxes
geom_texts={'Feedwater flow speed [m/s]';'Tube thermal conductivity [W/m*K]';...
    'Tube external diameter [mm]';'Tube internal diameter [mm]';...
    'Tube pitch distance [mm]';'Baffle distance for Desuperheater [mm]';...
    'Baffle distance for Subcooler [mm]'};

geom_values=[cy_conf.fwh_geom_conf.v;cy_conf.fwh_geom_conf.k;...
    cy_conf.fwh_geom_conf.de*1000;cy_conf.fwh_geom_conf.di*1000;...
    cy_conf.fwh_geom_conf.pt*1000;cy_conf.fwh_geom_conf.bafDSH*1000;...
    cy_conf.fwh_geom_conf.bafSUB*1000];

geom_boxes=build_all_boxes(fwh_pan,geom_texts,geom_values,7);

% Build pump performance panel
pump_text={'Feedwater pump performance [%]';'Condenser pump performance [%]'};

pump_value=[cy_conf.FWpmp_nise*100;cy_conf.COpmp_nise*100];

pmp_boxes=build_all_boxes(pmp_pan,pump_text,pump_value,2);

% Build cycle power performance panel
pow_box=build_all_boxes(pow_pan,{'Cycle generated shaft power [MW]'},...
    cy_conf.W_out_d/1000,1);

% Ensure correct temperatures
set_pressures();

% Make figure visible
f.Visible='on';

%%%%%
    function store_values_in_cycle(c_des)
        % Store all values in cycle_configuration object
        
        % Ensure correct temperatures
        set_pressures();
        
        % Turbine
        for c=1:9
            if c<3
                % HP Tur
                c_des.tur_conf{c,1}=char(HP_conf{c}.String(HP_conf{c}.Value));
                
                % IPLP Tur
                c_des.tur_conf{c,2}=char(IPLP_conf{c}.String(IPLP_conf{c}.Value));
            else
                c_des.tur_conf{c,1}=str2double(HP_conf{c}.String);
                c_des.tur_conf{c,2}=str2double(IPLP_conf{c}.String);
            end
        end
        
        c_des.tur_conf{6,1}=c_des.tur_conf{6,1}/100;
        c_des.tur_conf{6,2}=c_des.tur_conf{6,2}/100;
        
        c_des.tur_conf{8,1}=c_des.tur_conf{8,1}/100;
        c_des.tur_conf{8,2}=c_des.tur_conf{8,2}/100;
        
        % Steam generator
        c_des.T_HTR_d=str2double(heater_boxes{1}.String)+273;
        c_des.T_RHTR_d=str2double(heater_boxes{2}.String)+273;
        c_des.HTR_ploss=str2double(heater_boxes{3}.String)/100;
        c_des.RHTR_ploss=str2double(heater_boxes{4}.String)/100;
        
        % FWH geometry
        new_conf_values=zeros(1,7);
        for c=1:7
            new_conf_values(c)=str2double(geom_boxes{c}.String);
        end
        new_conf=fwh_conf(new_conf_values(1),new_conf_values(2),...
            new_conf_values(3)/1000,new_conf_values(4)/1000,...
            new_conf_values(5)/1000,2,new_conf_values(6)/1000,...
            new_conf_values(7)/1000);
        
        c_des.fwh_geom_conf=new_conf;
        
        % Condenser parameters
        c_des.T_con_max=str2double(con_boxes{1}.String)+273;
        c_des.T_con_min=str2double(con_boxes{2}.String)+273;
        c_des.TFR_con_min=str2double(con_boxes{3}.String)/100;
        
        % Pump performance
        c_des.FWpmp_nise=str2double(pmp_boxes{1}.String)/100;
        c_des.COpmp_nise=str2double(pmp_boxes{2}.String)/100;
        
        % Store cycle power
        c_des.W_out_d=str2double(pow_box{1}.String)*1000;
        
    end

% Callbacks
    function canc_but_cb(~,~)
        % Close figure
        close(f);
    end

    function next_but_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
        
        % Call next step
        gui_cycle_conf(cy_conf);
        
        % Close figure
        close(f);
    end

    function back_but_cb(~,~)
        % Store values
        store_values_in_cycle(cy_conf);
        
        % Go back to previous step
        gui_run();
        
        % Close figure
        close(f);
    end

    function change_HP_out_pres(~,~)
        % Change HP Tur output pressure to reflect RHTR Ploss
        RHTR_ploss=str2double(heater_boxes{4}.String)/100;
        
        % IPTur input pressure
        IPTur_Pin=str2double(IPLP_conf{4}.String);
        
        % New output pressure
        HPTur_Pout=IPTur_Pin/(1-RHTR_ploss);
        
        % Store value
        HP_conf{5}.String=sprintf('%.2f',HPTur_Pout);
    end

    function change_LP_out_pres(src,~)
        % Change HP Tur output pressure to reflect Condenser temperature
        output_temp=str2double(src.String);
        
        % LPTur output pressure
        LPTur_pout=ps_T_97(output_temp+273)*10;
        
        % Store value
        IPLP_conf{5}.String=sprintf('%.4f',LPTur_pout);
    end

% Auxilixaries

    function set_pressures()
        change_HP_out_pres(heater_boxes{4});
        change_LP_out_pres(con_boxes{1});
    end

    function boxes = build_turbine_panel(pan,texts,values)
        
        if strcmp(pan.Title,'Intermediate and Low Pressure Turbine')
            num_boxes=8;
        else
            num_boxes=7;
        end       
        
        margin=0.03;
        inter_margin=0.01;
        box_width=(1-margin*2-inter_margin)*2/3;
        box_height=(1-margin*2-inter_margin*(num_boxes-1))/num_boxes;
                
        text_box=[margin,margin-0.03,box_width,box_height];
        pos_box=text_box+[box_width+inter_margin,0.03,-box_width/2,0];
                
        % Baumann factor (IPLP Only, HP is set to 0)
        if strcmp(pan.Title,'Intermediate and Low Pressure Turbine')
            uicontrol(pan,'Style','text','Units','normalized',...
                'Position',text_box,'String',texts(9),...
                'HorizontalAlignment','left');
            
            box9=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String',sprintf('%.2f',values{9}));
            
            text_box=text_box+[0,box_height+inter_margin,0,0];
            pos_box=pos_box+[0,box_height+inter_margin,0,0];
        else
            box9=struct('String','0');
        end
        
        % Throttle / intercept valve PLoss
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(8),...
            'HorizontalAlignment','left');
        
        box8=uicontrol(pan,'Style','edit','Units','normalized',...
            'Position',pos_box,'String',sprintf('%.2f',values{8}*100));
            
        % Annulus area
        text_box=text_box+[0,box_height+inter_margin,0,0];
        pos_box=pos_box+[0,box_height+inter_margin,0,0];
        
        if strcmp(pan.Title,'Intermediate and Low Pressure Turbine')
            uicontrol(pan,'Style','text','Units','normalized',...
                'Position',text_box,'String',texts(7),...
                'HorizontalAlignment','left');
            
            box7=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String',sprintf('%.2f',values{7}));
            
            text_box=text_box+[0,box_height+inter_margin,0,0];
            pos_box=pos_box+[0,box_height+inter_margin,0,0];
        else
            box7=struct('String','0');
        end
        
        % Nom isen perf        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(6),...
            'HorizontalAlignment','left');
        
        box6=uicontrol(pan,'Style','edit','Units','normalized',...
            'Position',pos_box,'String',sprintf('%.2f',values{6}*100));
        
        % Nom output press
        text_box=text_box+[0,box_height+inter_margin,0,0];
        pos_box=pos_box+[0,box_height+inter_margin,0,0];
        
        txt=uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(5),...
            'HorizontalAlignment','left');
        
        if strcmp(pan.Title,'Intermediate and Low Pressure Turbine')
            box5=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String',sprintf('%.4f',values{5}));
            
            txt.TooltipString='Dependent on condenser temperature';
        else
            box5=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String',sprintf('%.2f',values{5}));
            
            txt.TooltipString=sprintf(['Dependent on IP Turbine inlet pressure and\n',...
                'reheater pressure loss']);
        end
        
        
        % Nom input press
        if strcmp(pan.Title,'Intermediate and Low Pressure Turbine')
            tooltip='Pressure ahead of intercept valve';
        else
            tooltip='Pressure ahead of throttle valve';
        end
        text_box=text_box+[0,box_height+inter_margin,0,0];
        pos_box=pos_box+[0,box_height+inter_margin,0,0];
        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(4),...
            'HorizontalAlignment','left',...
            'TooltipString',tooltip);
        
        box4=uicontrol(pan,'Style','edit','Units','normalized',...
            'Position',pos_box,'String',sprintf('%.2f',values{4}));
        
        % Governing stage pitch diameter
        text_box=text_box+[0,box_height+inter_margin,0,0];
        pos_box=pos_box+[0,box_height+inter_margin,0,0];
        
        if strcmp('High Pressure Turbine',pan.Title)
            uicontrol(pan,'Style','text','Units','normalized',...
                'Position',text_box,'String',texts(3),...
                'HorizontalAlignment','left');
            
            box3=uicontrol(pan,'Style','edit','Units','normalized',...
                'Position',pos_box,'String',sprintf('%.2f',values{3}));
            
            text_box=text_box+[0,box_height+inter_margin,0,0];
            pos_box=pos_box+[0,box_height+inter_margin,0,0];
        else
            box3=struct('String','0');
        end
        
        % Leak type
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(2),...
            'HorizontalAlignment','left');
        
        box2=uicontrol(pan,'Style','popupmenu','Units','normalized',...
            'Position',pos_box,'String',values(2),'Enable','off');
        
        % Turbine type
        text_box=text_box+[0,box_height+inter_margin,0,0];
        pos_box=pos_box+[0,box_height+inter_margin,0,0];
        
        uicontrol(pan,'Style','text','Units','normalized',...
            'Position',text_box,'String',texts(1),...
            'HorizontalAlignment','left');
        
        if strcmp('High Pressure Turbine',pan.Title)
            switch values{1}
                case 'HP-1ROW'
                    val=1;
                case 'HP-2ROW'
                    val=2;
            end
            
            box1=uicontrol(pan,'Style','popupmenu','Units','normalized',...
                'Position',pos_box,...,
                'String',{'HP-1ROW','HP-2ROW'},'Enable','on',...
                'Value',val);
        else            
            switch values{1}
                case 'REHEAT-36'
                    val=1;
                case 'REHEAT-36/18'
                    val=2;
            end
            
            box1=uicontrol(pan,'Style','popupmenu','Units','normalized',...
                'Position',pos_box,...
                'String',{'REHEAT-36','REHEAT-36/18'},...
                'Enable','on','Value',val);
        end
        
        % Boxes cell
        boxes={box1;box2;box3;box4;box5;box6;box7;box8;box9};
        
    end

    function boxes = build_all_boxes(pan,texts,values,num_boxes)
        % Fill a panel with edit boxes
        margin=0.03;
        inter_margin=0.02;
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

    function hp_tur_type_cb(src,~)
        % Disable stage pitch diameter if turbine type is HP-2ROW,
        % and set default base isentropic performance
        switch src.String{src.Value}
            case 'HP-1ROW'
                HP_conf{3}.Enable='on';
            case 'HP-2ROW'
                HP_conf{3}.Enable='off';                
        end
        
        % Set isentropic performance
        HP_conf{6}.String=sprintf('%.2f',hp_tur_base_isen(src.Value)*100);
    end

    function iplp_tur_type_cb(src,~)
        % Set default base isentropic performance
        IPLP_conf{6}.String=sprintf('%.2f',iplp_tur_base_isen(src.Value)*100);
    end

end

