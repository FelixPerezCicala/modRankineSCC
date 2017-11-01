function draw_PLcycle_par(c1,c2,cy_conf,saved,caller,file_name)
%draw_PLcycle Draw diagrams for a list of cycles with different loads

% Inputs:
%     c1 -> Cell array containing sliding pressure cycle objects
%     c2 -> Cell array containing constant pressure cycle objects
%     cy_conf -> Cycle configuration object
%     saved -> Boolean, true if the solution file was saved
%     caller -> Calling function. Either 'gui_run' or 'gui_solve'

% Get load values for each cycle in the list. The first cycle is at design
% load (max value)

c1_length=length(c1);
c2_length=length(c2);

mass_c1=zeros(c1_length,1);
mass_c2=zeros(c2_length,1);

perf_c1=zeros(c1_length,1);
perf_c2=zeros(c2_length,1);

htrate_c1=zeros(c1_length,1);
htrate_c2=zeros(c1_length,1);

pow_c1=zeros(c1_length,1);
pow_c2=zeros(c2_length,1);

p_c1=zeros(c1_length,1);
p_c2=zeros(c2_length,1);

tur1per_c1=zeros(c1_length,1);
tur1per_c2=zeros(c2_length,1);

tur2per_c1=zeros(c1_length,1);
tur2per_c2=zeros(c2_length,1);

iters_c1=zeros(c1_length,1);
iters_c2=zeros(c2_length,1);

entr_c1=zeros(c1_length,200);
entr_c2=zeros(c1_length,200);

temp_c1=zeros(c1_length,200);
temp_c2=zeros(c1_length,200);

hs_entr_c1=zeros(c1_length,100);
hs_entr_c2=zeros(c1_length,100);

enta_c1=zeros(c1_length,100);
enta_c2=zeros(c1_length,100);

[ts_b_entr,ts_b_temp]=TSdiag_bell();
[hs_b_entr,hs_b_enta]=HSdiag_bell();

max_mass=c1{1}.m_HTR_d;

for i=1:c1_length
    mass_c1(i)=c1{i}.m_fw;
    mass_c2(i)=c2{i}.m_fw;
    
    perf_c1(i)=c1{i}.n_cycle*100;
    perf_c2(i)=c2{i}.n_cycle*100;
    
    htrate_c1(i)=c1{i}.heatrate*3600/1.055;
    htrate_c2(i)=c2{i}.heatrate*3600/1.055;
    
    pow_c1(i)=c1{i}.W_out/10^3;
    pow_c2(i)=c2{i}.W_out/10^3;
    
    p_c1(i)=c1{i}.P_HTR;
    p_c2(i)=c2{i}.P_HTR;
    
    tur1per_c1(i)=mean(c1{i}.tur{1}.nise_st(2:end))*100;
    tur1per_c2(i)=mean(c2{i}.tur{1}.nise_st(2:end))*100;
    
    tur2per_c1(i)=mean(c1{i}.tur{2}.nise_st(2:end))*100;
    tur2per_c2(i)=mean(c2{i}.tur{2}.nise_st(2:end))*100;
    
    iters_c1(i)=c1{i}.iter_pl;
    iters_c2(i)=c2{i}.iter_pl;
    
    [ec1,tc1,~,~,~,~]=cycle_TS_diagram(c1{i},'simple');
    [ec2,tc2,~,~,~,~]=cycle_TS_diagram(c2{i},'simple');
        
    entr_c1(i,1:length(ec1))=ec1;
    temp_c1(i,1:length(tc1))=tc1;
    entr_c2(i,1:length(ec2))=ec2;
    temp_c2(i,1:length(tc2))=tc2;
    
    [ec1,hc1,~,~,~,~]=cycle_HS_diagram(c1{i},'turbine');
    [ec2,hc2,~,~,~,~]=cycle_HS_diagram(c2{i},'turbine');
    
    hs_entr_c1(i,1:length(ec1))=ec1;
    enta_c1(i,1:length(hc1))=hc1;
    hs_entr_c2(i,1:length(ec2))=ec2;
    enta_c2(i,1:length(hc2))=hc2;
    
end

min_mass=mass_c1(end);

entr_c1=entr_c1(:,1:sum(entr_c1(1,:)>0));
temp_c1=temp_c1(:,1:sum(temp_c1(1,:)>0));
entr_c2=entr_c2(:,1:sum(entr_c2(1,:)>0));
temp_c2=temp_c2(:,1:sum(temp_c2(1,:)>0));

hs_entr_c1=hs_entr_c1(:,1:sum(hs_entr_c1(1,:)>0));
enta_c1=enta_c1(:,1:sum(enta_c1(1,:)>0));
hs_entr_c2=hs_entr_c2(:,1:sum(hs_entr_c2(1,:)>0));
enta_c2=enta_c2(:,1:sum(enta_c2(1,:)>0));

n_fwh=c1{1}.N_FWH;
n_fwh_hp=c1{1}.N_FWH_HP;

% Default bypass
crt_bypass=c1{1}.bypass;

%%%%%%%%%%%%%%%
% Determine avaiable hardware acceleration
opengldata = opengl('data');

if strcmp(opengldata.HardwareSupportLevel,'full')
    renderer='opengl';
else
    renderer='painters';
end

% Build window name
if saved==true
    fig_title=sprintf('%s - Cicle diagram',file_name);
else
    fig_title=sprintf('New solution - Cicle diagram');
end

% Initialize figure
f=figure('Name',fig_title,'NumberTitle','off',...
    'Visible','off','Renderer',renderer,...
    'MenuBar','none','ToolBar','figure',...
    'CloseRequestFcn',@close_request);

% Make window full scren
f.Units='normalized';
f.OuterPosition = [0.05 0.075 0.9 0.9];

% Disable unwanted buttons
disable_tooltips(f,true);

% Diagram panel height
diag_height=0.7;

margin=0.01/2;
pans_h=1-margin*3-diag_height;

% Diagram panel
diag_pan_pos=[margin,1-margin-diag_height,1-margin*2,diag_height];

diag_pan=uipanel(f,'Units','normalized','Position',diag_pan_pos,...
    'Title','Diagram','BackgroundColor',[0.94,0.94,0.94]);

% Auxiliary panel (for color background)
diag_pan_aux=uipanel(diag_pan,'Units','normalized','Position',[0,0,1,1],...
    'Title','','BorderType','none',...
    'BackgroundColor',[1,1,1]);

% Diagram axes object
diag_ax=axes(diag_pan_aux,'Box','off',...
    'NextPlot','add',...
    'XColor','none','YColor','none',...
    'Units','normalized','Position',[0,0,1,1],...
    'Color',[1,1,1],...
    'Clipping','off');

diag_ax.DataAspectRatio=[1,1,1];

% Draw the diagram in diag_ax
[~,cross_list,fwh_cords, tur_cords, other_txts_list] = diag_cy(c1{1},0,diag_ax,true);

cross_fontsize=cross_list.get(1,1).FontSize;
ax_default_xlim=diag_ax.XLim;
ax_default_ylim=diag_ax.YLim;

% Set mode to Constant
mode='Constant';

% Set uicontrols
% Axes uitabgroup
tab_pan=uipanel(f,'Units','normalized',...
    'Position',[margin,margin,0.45,pans_h],...
    'Title','Load');

tab_gr = uitabgroup(tab_pan,'Units','normalized',...
    'Position',[0.01,0.01,0.98,0.98],...
    'TabLocation','left');

tab1 = uitab(tab_gr,'Title','Perform.','ForegroundColor',[161,0,0]./255);
tab2 = uitab(tab_gr,'Title','HeatRate');
tab3 = uitab(tab_gr,'Title','Power');
tab4 = uitab(tab_gr,'Title','Heater P');
tab5 = uitab(tab_gr,'Title','T1 Perf.');
tab6 = uitab(tab_gr,'Title','T2 Perf.');
tab7 = uitab(tab_gr,'Title','Itera.');
tab8 = uitab(tab_gr,'Title','TS Diag.');
tab9 = uitab(tab_gr,'Title','HS Diag.');

tabs=cell(9,1);
tabs{1}=tab1;
tabs{2}=tab2;
tabs{3}=tab3;
tabs{4}=tab4;
tabs{5}=tab5;
tabs{6}=tab6;
tabs{7}=tab7;
tabs{8}=tab8;
tabs{9}=tab9;

% Zoom-in button
zoom_but=uicontrol(tab_pan,'Style','pushbutton','Units','normalized',...
    'Position',[0.94,1-0.01-0.13,0.05,0.13],'Enable','on',...
    'String','+','FontWeight','bold','FontSize',12);

% Tabs titles for use in zoom function
title_tabs = {'Cycle performance';'Cycle generated power';...
    'Heater output pressure';'HP Turbine isentropic performance';...
    'IP-LP Turbine isentropic performance';...
    'Iterations to solution';'TS Diagram'};

% Performance axes
ax_per=axes(tab1,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_per.XLabel.String='TFR [%]';
ax_per.YLabel.String='Performance [%]';

% Heat rate axes
ax_htr=axes(tab2,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_htr.XLabel.String='TFR [%]';
ax_htr.YLabel.String='Heat Rate [BTU/kWh]';

% Power axes
ax_pow=axes(tab3,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_pow.XLabel.String='TFR [%]';
ax_pow.YLabel.String='Power [MW]';

% Pressure axes
ax_pre=axes(tab4,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_pre.XLabel.String='TFR [%]';
ax_pre.YLabel.String='FW Pressure [bar]';

% Performance tur 1
ax_t1p=axes(tab5,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_t1p.XLabel.String='TFR [%]';
ax_t1p.YLabel.String='Tur 1 Isen. Perf. [%]';

% Performance tur 2
ax_t2p=axes(tab6,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_t2p.XLabel.String='TFR [%]';
ax_t2p.YLabel.String='Tur 2 Isen. Perf. [%]';

% Iterations
ax_ite=axes(tab7,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_ite.XLabel.String='TFR [%]';
ax_ite.YLabel.String='Iterations to solution';

% TS Diagram
ax_ts=axes(tab8,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_ts.XLabel.String='Entropy [kJ/kg·K]';
ax_ts.YLabel.String='Temperature [ºC]';

% HS Diagram
ax_hs=axes(tab9,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_hs.XLabel.String='Entropy [kJ/kg·K]';
ax_hs.YLabel.String='Enthalpy [kJ/kg]';

% Axes cell
ax_cell={ax_per,ax_htr,ax_pow,ax_pre,ax_t1p,ax_t2p,ax_ite,ax_ts,ax_hs};

% Mass slider
sl_height=pans_h-0.1;
sl_pan = uipanel(f,'Units','normalized',...
    'Position',...
    [tab_pan.Position(1)+tab_pan.Position(3)+margin,margin,0.12,sl_height],...
    'Title','Control');

jSlider = javax.swing.JSlider();

[hjSlider, hContainer] = javacomponent(jSlider,[0,0,1,1],sl_pan);
set(jSlider, 'Maximum',100,'Minimum',0,'Value',100,...
    'PaintLabels',true,'PaintTicks',true,...
    'Orientation',jSlider.VERTICAL, 'MinorTickSpacing',10);

label_table=jSlider.createStandardLabels(20);
jSlider.setLabelTable(label_table);
jSlider.setPaintLabels(true);

set(hContainer,'Units','normalized','position',[0,0,0.7,1]); %note container size change

% Incremental buttons for slider
b1=uicontrol(sl_pan,'Style','pushbutton','Units','normalized',...
    'Position',[0.71,0.56,0.25,0.15],'Enable','off',...
    'String','+','FontWeight','bold','FontSize',12);

b2=uicontrol(sl_pan,'Style','pushbutton','Units','normalized',...
    'Position',[0.71,0.3,0.25,0.18],...
    'String','-','FontWeight','bold','FontSize',12);

% Buttongroup
bg = uibuttongroup('Visible','on',...
    'Units','normalized','Position',...
    [tab_pan.Position(1)+tab_pan.Position(3)+margin, margin*2+sl_height, 0.12, pans_h-sl_height-margin],...
    'Title','Mode',...
    'SelectionChangedFcn',@(src,evdata) switch_mode(src,evdata,hjSlider,cross_list));

% Create three radio buttons in the button group.
butgr_height=0.425;
r1 = uicontrol(bg,'Style','radiobutton',...
    'String',sprintf('Constant pressure'),...
    'Units','normalized','Position',[0.05 0.525 0.9 butgr_height],...
    'HandleVisibility','off');

r2 = uicontrol(bg,'Style','radiobutton',...
    'String',sprintf('Sliding pressure'),...
    'Units','normalized','Position',[0.05 0.05 0.9 butgr_height],...
    'HandleVisibility','off');

% Selected cycle information area
in_pan = uipanel(f,'Units','normalized',...
    'Position',...
    [sl_pan.Position(1)+sl_pan.Position(3)+margin,margin,0.305,pans_h],...
    'Title','Cycle parameters and solution quality');

% JText area
jText = javax.swing.JTextArea;
jText.setEditable(0);

% jContainer = javax.swing.JScrollPane(jText);
jContainer = javax.swing.JScrollPane(jText);
[hjContainer, hContainer] = javacomponent(jContainer,[0,0,1,1], in_pan);

% F = java.awt.Font('monospaced', java.awt.Font.BOLD, 12);
% F = java.awt.Font('Courier New', java.awt.Font.BOLD, 12);
F = java.awt.Font('Lucida Console', java.awt.Font.PLAIN, 12);
% F = java.awt.Font('Lucida Sans Typewriter', java.awt.Font.PLAIN, 12);

set(jText,'Font',F);

set(hContainer,'Units','normalized','position',[0.01,0.01,0.98,0.98]); %note container size change

% Other buttons panel
mid_pan_height=pans_h/2*1.04;
oth_pan = uipanel(f,'Units','normalized',...
    'Position',...
    [in_pan.Position(1)+in_pan.Position(3)+margin,margin*2+(pans_h-margin-mid_pan_height),...
    0.10,mid_pan_height],...
    'Title','Other options');

margin_b=0.03;
inter_margin=0.02;
but_height=(1-margin_b*2-inter_margin*2)/3;
but_width=1-margin_b*2;

% Deviation and residuals button
dr_but=uicontrol(oth_pan,'Style','pushbutton','Units','normalized',...
    'Position',[margin_b,1-margin_b-but_height,but_width,but_height],...
    'String','Dev. and Res.');

% Manual bypass button
mB_but=uicontrol(oth_pan,'Style','pushbutton','Units','normalized',...
    'Position',dr_but.Position-[0,but_height+inter_margin,0,0],...
    'String','Manual Bypass');

% Manual valve button
mV_but=uicontrol(oth_pan,'Style','pushbutton','Units','normalized',...
    'Position',mB_but.Position-[0,but_height+inter_margin,0,0],...
    'String','Manual Valves');

% Save as, Back and close buttons
bc_pan_pos=[oth_pan.Position(1),margin-0.003,oth_pan.Position(3),pans_h-margin-mid_pan_height];
bc_pan = uipanel(f,'Units','normalized',...
    'Position',bc_pan_pos,...
    'BorderType','none');

% Save As button
save_but=uicontrol(bc_pan,'Style','pushbutton','Units','normalized',...
    'Position',[margin_b,1-margin_b-but_height,but_width,but_height],...
    'String','Save As');

% Back button
back_but=uicontrol(bc_pan,'Style','pushbutton','Units','normalized',...
    'Position',save_but.Position-[0,but_height+inter_margin,0,0],...
    'String','< Back');

% Close
close_but=uicontrol(bc_pan,'Style','pushbutton','Units','normalized',...
    'Position',back_but.Position-[0,but_height+inter_margin,0,0],...
    'String','Close');

% Set text
set_text_properties(c1{1});

% Initialize
% Draw performance in ax_per
plot(ax_per, 100*mass_c1./max_mass,perf_c1,'Color',[0,27,204]./255);
plot(ax_per, 100*mass_c2./max_mass,perf_c2,'Color',[0,138,28]./255);
ax_per.YLim=[min(perf_c1(end),perf_c2(end)*0.96),...
    max(perf_c1(1),perf_c2(1))*1.04];
ax_per.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw heat rate in ax_htr
plot(ax_htr, 100*mass_c1./max_mass,htrate_c1,'Color',[0,27,204]./255);
plot(ax_htr, 100*mass_c2./max_mass,htrate_c2,'Color',[0,138,28]./255);
ax_htr.YLim=[min(htrate_c1(1),htrate_c2(1)*0.96),...
    max(htrate_c1(end),htrate_c2(end))*1.04];
ax_htr.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw power in ax_pow
plot(ax_pow, 100*mass_c1./max_mass,pow_c1,'Color',[0,27,204]./255);
plot(ax_pow, 100*mass_c2./max_mass,pow_c2,'Color',[0,138,28]./255);
ax_pow.YLim=[min(pow_c1(end),pow_c2(end))*0.85,...
    max(pow_c1(1),pow_c2(1))*1.15];
ax_pow.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw pressure in ax_pre
plot(ax_pre, 100*mass_c1./max_mass,p_c1,'Color',[0,27,204]./255);
plot(ax_pre, 100*mass_c2./max_mass,p_c2,'Color',[0,138,28]./255);
ax_pre.YLim=[min(p_c1(end),p_c2(end))*0.85,...
    max(p_c1(1),p_c2(1))*1.15];
ax_pre.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw HP tur performance in ax_t1p
plot(ax_t1p, 100*mass_c1./max_mass,tur1per_c1,'Color',[0,27,204]./255);
plot(ax_t1p, 100*mass_c2./max_mass,tur1per_c2,'Color',[0,138,28]./255);
ax_t1p.YLim=[min(tur1per_c1(end),tur1per_c2(end))*0.85,...
    max(tur1per_c1(1),tur1per_c2(1))*1.15];
ax_t1p.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw IPLP tur performance in ax_t2p
plot(ax_t2p, 100*mass_c1./max_mass,tur2per_c1,'Color',[0,27,204]./255);
plot(ax_t2p, 100*mass_c2./max_mass,tur2per_c2,'Color',[0,138,28]./255);
ax_t2p.YLim=[min(tur2per_c1(end),tur2per_c2(end))*0.85,...
    max(tur2per_c1(1),tur2per_c2(1))*1.15];
ax_t2p.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw iterations
plot(ax_ite, 100*mass_c1./max_mass,iters_c1,'Color',[0,27,204]./255,...
    'LineStyle','none','Marker','o');
plot(ax_ite, 100*mass_c2./max_mass,iters_c2,'Color',[0,138,28]./255,...
    'LineStyle','none','Marker','+');
ax_ite.YLim=[min([iters_c1;iters_c2])*0.85,...
    max([iters_c1;iters_c2])*1.15];
ax_ite.XLim=[min(100*mass_c1./max_mass),max(100*mass_c1./max_mass)];

% Draw TS Diagram
plot(ax_ts,ts_b_entr,ts_b_temp,'Color',[0, 51, 135]./255);
line_ts = plot(ax_ts,entr_c1(1,:),temp_c1(1,:),...
    'Color',[255,0,0]./255,'LineWidth',0.75);
ax_ts.XLim=[min(entr_c1(1,:))*0.5,max(entr_c1(end,:))*1.05];

% Draw HS Diagram
plot(ax_hs,hs_b_entr,hs_b_enta,'Color',[0, 51, 135]./255);
line_hs = plot(ax_hs,hs_entr_c1(1,:),enta_c1(1,:),...
    'Color',[255,0,0]./255,'LineWidth',0.75);
ax_hs.XLim=[min(hs_entr_c1(1,:))*0.98,max(hs_entr_c1(end,:))*1.025];
ax_hs.YLim=[min(enta_c1(1,:))*0.98,max(enta_c1(end,:))*1.05];

% Draw current power line and legend
crt_tfr=cell(7,1);
crt_tfr{1}=plot(ax_per,[1,1].*100*mass_c1(1)./max_mass,...
    ax_per.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_per,'Constant','Sliding','Location','southeast');

crt_tfr{2}=plot(ax_htr,[1,1].*100*mass_c1(1)./max_mass,...
    ax_htr.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_htr,'Constant','Sliding','Location','southwest');

crt_tfr{3}=plot(ax_pow,[1,1].*100*mass_c1(1)./max_mass,...
    ax_pow.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_pow,'Constant','Sliding','Location','southeast');

crt_tfr{4}=plot(ax_pre,[1,1].*100*mass_c1(1)./max_mass,...
    ax_pre.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_pre,'Constant','Sliding','Location','southeast');

crt_tfr{5}=plot(ax_t1p,[1,1].*100*mass_c1(1)./max_mass,...
    ax_t1p.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_t1p,'Constant','Sliding','Location','southeast');

crt_tfr{6}=plot(ax_t2p,[1,1].*100*mass_c1(1)./max_mass,...
    ax_t2p.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_t2p,'Constant','Sliding','Location','southeast');

crt_tfr{7}=plot(ax_ite,[1,1].*100*mass_c1(1)./max_mass,...
    ax_ite.YLim,'Color',[207,0,0]./255,...
    'LineWidth',0.75,'DisplayName','');
legend(ax_ite,'Constant','Sliding','Location','southeast');

% Draw TFR
crt_tfr_txt=cell(7,1);
crt_tfr_txt{1}=text(ax_per, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_per.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{2}=text(ax_htr, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_htr.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{3}=text(ax_pow, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_pow.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{4}=text(ax_pre, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_pre.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{5}=text(ax_t1p, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_t1p.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{6}=text(ax_t2p, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_t2p.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

crt_tfr_txt{7}=text(ax_ite, 100*(mass_c1(1)-(mass_c1(1)-mass_c1(end))*0.075)/max_mass,...
    ax_ite.YLim(2), num2str(100*mass_c1(1)/max_mass, '%.1f'),...
    'HorizontalAlignment','center','VerticalAlignment','top');

% Set auto pointers
enable_auto_pointer=true;

% Current index
crt_idx=1;

% Auxiliary cycle object
c_aux=[];

% Set slider callback
hjSlider.StateChangedCallback=@(src,evdata) change_load(src,evdata,cross_list);

% Set buttons callback
b1.Callback=@(src,evdata) incremental_draw(src,evdata,'plus_one',cross_list);
b2.Callback=@(src,evdata) incremental_draw(src,evdata,'minus_one',cross_list);

% Set tabs callbacks
tab1.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,1);
tab2.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,2);
tab3.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,3);
tab4.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,4);
tab5.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,5);
tab6.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,6);
tab7.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,7);
tab8.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,8);
tab9.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,9);

% Zoom button callback
zoom_but.Callback = @(src,evdata) zoom_in_diag(src,evdata);

% Set deviation and residuals buttons callback
dr_but.Callback = @(src,evdata) draw_devres(src,evdata);

% Set manual bypass callback
mB_but.Callback=@(src,evdata) manual_bypass(src,evdata,cross_list);

% Set manual valves callback
mV_but.Callback=@(src,evdata) manual_valves(src,evdata,cross_list);

% Set axes callback, for clicking FWHs
diag_ax.ButtonDownFcn = @(src,evdata) selec_dev(src,evdata);

% Figure callback
f.WindowButtonMotionFcn = @(src,evdata) cursor_change(src,evdata);

% Save as button callback
save_but.Callback = @(src,evdata) saveas_cb(src,evdata);

% Back button callback
back_but.Callback = @(src,evdata) back_cb(src,evdata);

% Close button callback
close_but.Callback = @(src,evdata) close_request(src,evdata);

% % Axis text size change
zoom_obj=zoom(f);
zoom_obj.ActionPostCallback=@zoom_callback;
pan_obj=pan;

% Show figure
f.Visible = 'on';

%%%%%
% Callbacks

    function close_request(~,~)
        % Make the user wants to clase if the cycle hasn't been saved
        if ~saved
            % Newline
            n=char(10);
            
            text_string=['Are you sure you want to close the program?',n,...
                'The solution was not saved.'];
            
            exit_flag=create_ok_cancel_dialog(text_string);
            
            if strcmp(exit_flag,'ok')
                delete(f);
            end
        else
            delete(f);
        end
    end

    function saveas_cb(~,~)
        % Save solution
        [exit_flag, file_name]=cycle_solution_save(c1,c2,cy_conf,'solution');
        
        if strcmp(exit_flag,'success')
            saved=true;
            f.Name=sprintf('%s - Cicle diagram',file_name);
            
        end
    end

    function back_cb(~,~)
        % Make the user wants to clase if the cycle hasn't been saved
        
        % Newline
        n=char(10);
        
        if ~saved
            text_string=['Are you sure you want to go back?',n,...
                'The solution was not saved.'];
            
            exit_flag=create_ok_cancel_dialog(text_string);
            
            if strcmp(exit_flag,'ok')
                gui_solve(cy_conf);
                
                delete(f);
            end
        else
            text_string=['Are you sure you want to go back?',n,...
                'In order to see the results again, open the saved solution file.'];
            
            exit_flag=create_ok_cancel_dialog(text_string);
            
            if strcmp(exit_flag,'ok')
                if strcmp(caller,'gui_solve')
                    gui_solve(cy_conf);
                else
                    gui_run();
                end
                
                delete(f);
            end
        end
    end

    function switch_mode(~, evdata, sl_hand,clist)
        
        switch evdata.NewValue.String            
            case 'Constant pressure'
                % Find closest calculated to requested power
                req_mass=max_mass*sl_hand.Value/100;
                
                tmp=abs(mass_c1-req_mass);
                
                [~,idx]=min(tmp);
                
                % Store current mode
                mode='Constant';
                
            case 'Sliding pressure'
                % Find closest calculated to requested power
                req_mass=max_mass*sl_hand.Value/100;
                
                tmp=abs(mass_c2-req_mass);
                
                [~,idx]=min(tmp);
                
                % Store current mode
                mode='Sliding';                
        end
        
        % Redraw
        redraw(idx,clist);
        
        crt_idx=idx;
        
        drawnow;
    end

    function change_load(src,~,clist)
        % Draw cycle of required load
        % Check if the slider value is an integer
        if floor(src.Value)~=src.Value
            src.Value=floor(src.Value);
        end
        
        % Check if the value is above the minum power available
        if src.Value/100 >= min_mass/max_mass
            
            % Find closest calculated to requested power
            req_mass=max_mass*src.Value/100;
            
            tmp=abs(mass_c1-req_mass);
            [~,idx]=min(tmp);
            
        else
            src.Value = min_mass/max_mass*100;
            idx=length(mass_c1);
        end
        
        crt_idx=idx;
        
        % Set slider to drawn mass
        src.Value=mass_c1(idx)/max_mass*100;
        
        % Enable or disable buttons if needed
        if idx==length(mass_c1)
            b1.Enable='on';
            b2.Enable='off';
        elseif idx==1
            b1.Enable='off';
            b2.Enable='on';
        else
            b1.Enable='on';
            b2.Enable='on';
        end
        
        % Redraw
        redraw(idx,clist);
        
        % Set empty auxiliary cycle
        c_aux=[];
        
    end

    function tab_color(~,~,active_tab)
        for t=1:length(tabs)
            if t==active_tab
                tabs{t}.ForegroundColor=[161,0,0]./255;
                
                if t==8
                    % Redraw TS Diagram
                    switch mode
                        case 'Constant'
                            line_ts.XData=entr_c1(crt_idx,:);
                            line_ts.YData=temp_c1(crt_idx,:);
                        case 'Sliding'
                            line_ts.XData=entr_c2(crt_idx,:);
                            line_ts.YData=temp_c2(crt_idx,:);
                    end
                elseif t==9
                    % Redraw HS Diagram
                    switch mode
                        case 'Constant'
                            line_hs.XData=hs_entr_c1(crt_idx,:);
                            line_hs.YData=enta_c1(crt_idx,:);
                        case 'Sliding'
                            line_hs.XData=hs_entr_c2(crt_idx,:);
                            line_hs.YData=enta_c2(crt_idx,:);
                    end
                end
                
            else
                tabs{t}.ForegroundColor=[0,0,0]./255;
            end
        end
        
    end

    function zoom_in_diag(~,~)
        % Show an enlarged version of the displayed plot in tabs area
        
        % Find selected tab
        for t=1:9
            if tabs{t}==tab_gr.SelectedTab
                selection = t;
            end
        end
        
        title_tabs = {'Cycle performance';'Cycle heat rate';...
            'Cycle generated power';...
            'Heater output pressure';'HP Turbine isentropic performance';...
            'IP-LP Turbine isentropic performance';...
            'Iterations to solution';'T-s Diagram';'h-s Diagram'};
        
        if selection<8
            title=sprintf('%s.',title_tabs{selection});
        elseif selection==8
            title=sprintf('%s. %s pressure, cycle TFR %.2f',title_tabs{selection},...
                mode,mass_c1(crt_idx)/max_mass*100);
        else
            title=sprintf('%s diagram. %s pressure, cycle TFR %.2f',title_tabs{selection},...
                mode,mass_c1(crt_idx)/max_mass*100);
        end
        
        newfig=figure('Name',title,...
            'Color',[255,255,255]/255);
        
        if selection<8
            crt_tfr{selection}.Visible='off';
            crt_tfr_txt{selection}.Visible='off';
            
            newax=copyobj(ax_cell{selection},newfig);
            
            if selection~=2
                legend(newax,'Constant','Sliding','Location','southeast');
            else
                legend(newax,'Constant','Sliding','Location','southwest');
            end
            
            crt_tfr{selection}.Visible='on';
            crt_tfr_txt{selection}.Visible='on';
        elseif selection==8
            % Draw full TS Diagram
            if isempty(c_aux)
                if strcmp(mode,'Constant')
                    cycle=c1{crt_idx};
                else
                    cycle=c2{crt_idx};
                end
            else
                cycle=c_aux;
            end
            
            [s,T,s_fwh,t_fwh, sdeair, Tdeair]=cycle_TS_diagram(cycle,'complex');
            
            ax=axes(newfig,'Units','normalized','OuterPosition',[0,0,1,1],...
                'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
                'GridColor',[0,0,0]./255,'GridAlpha',0.25);
            ax.XLabel.String='Entropy [kJ/kg·K]';
            ax.YLabel.String='Temperature [ºC]';
            
            plot(ax,ts_b_entr,ts_b_temp,'Color',[0, 0, 0]./255);
            mainline=plot(ax,s,T,...
                'Color',[0,0,255]./255,'LineWidth',1);
            
            deair=plot(ax,sdeair,Tdeair,...
                'Color',[0,153,0]./255,'LineWidth',1);
            
            for h=1:cycle.N_FWH
                fwh=plot(ax,s_fwh(h,:),t_fwh(h,:),...
                    'Color',[255,0,0]./255,'LineWidth',1);
            end
            
            legend(ax,[mainline,fwh,deair],'Feed water','FWHs','Deaerator',...
                'Location','northwest');
        else
            % Draw full HS Diagram
            if isempty(c_aux)
                if strcmp(mode,'Constant')
                    cycle=c1{crt_idx};
                else
                    cycle=c2{crt_idx};
                end
            else
                cycle=c_aux;
            end
            
            [s,h]=cycle_HS_diagram(cycle,'turbine');
            
            ax=axes(newfig,'Units','normalized','OuterPosition',[0,0,1,1],...
                'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
                'GridColor',[0,0,0]./255,'GridAlpha',0.25);
            ax.XLabel.String='Entropy [kJ/kg·K]';
            ax.YLabel.String='Enthalpy [kJ/kg]';
            
            plot(ax,hs_b_entr,hs_b_enta,'Color',[0, 0, 0]./255);
            
            hp_end=length(cycle.tur{1}.h_st)+2;
            ip_sta=length(cycle.tur{1}.h_st)+2+31;
            
            plot(ax,s(1:hp_end),h(1:hp_end),...
                'Color',[0,0,255]./255,'LineWidth',1,...
                'Marker','o','MarkerEdgeColor',[1,0,0]);
                        
            plot(ax,s(hp_end+1:ip_sta-1),h(hp_end+1:ip_sta-1),...
                'Color',[1,0,0],'LineWidth',1);
            
            plot(ax,s(ip_sta:end),h(ip_sta:end),...
                'Color',[0,0,255]./255,'LineWidth',1,...
                'Marker','o','MarkerEdgeColor',[1,0,0]);
            
            ax.XLim=[s(1)*0.98,s(end)*1.02];
            
            stages_hp=1:length(cycle.tur{1}.h_st);
            stages_ip=1:length(cycle.tur{2}.h_st);
            stages_ip=num2cell(num2str(stages_ip'))';
            
            if size(stages_ip,1)==2
                stages_ip=strcat(stages_ip(1,:),stages_ip(2,:));
            end
            
            labels=[{'TV','GS'},num2cell(num2str(stages_hp'))',...
                'IV',stages_ip(1:cycle.tur{2}.XO_pos-1),...
                {[stages_ip{cycle.tur{2}.XO_pos},' - XO']},...
                stages_ip(cycle.tur{2}.XO_pos+1:end)];
            
            offset_x=[-0.09,-0.02,zeros(1,length(cycle.tur{1}.h_st)),...
                -0.09,zeros(1,length(cycle.tur{2}.h_st))];
            offset_y=[50,50,zeros(1,length(cycle.tur{1}.h_st)),...
                0,zeros(1,length(cycle.tur{2}.h_st))];
            
            legend_text=sprintf(['TV: Throttle valve\n',...
                'GS: Governing stage\nIV: Intercept valve\nXO: Cross-over to LP Turbine']);
            
            text(ax,ax.XLim(1)+0.1,ax.YLim(1)+200,legend_text,...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle','FontUnits','normalized',...
                'BackgroundColor',[1,1,1],'EdgeColor',[0,0,0]);
            
            for l=1:length(labels)
                
                if l<=hp_end
                    pos=l;
                else
                    pos=l+30;
                end
                
                text(ax,s(pos)+0.03+offset_x(l),h(pos)+10+offset_y(l),labels{l},...
                    'HorizontalAlignment','left',...
                    'VerticalAlignment','middle','FontUnits','normalized');
            end
        end
        
    end

    function draw_devres(~,~)
        % Draw a new figure with deviation and residuals for current
        % solution
                
        % File name
        if saved
            fname=sprintf('%s - ',file_name);
        else
            fname=sprintf('New solution - ',file_name);
        end        
        
        % Get values
        switch mode
            case 'Constant'
                dev_reg=c1{crt_idx}.dev_pl_his;
                res_reg=c1{crt_idx}.res_pl_his;
                
                tol_dev=c1{crt_idx}.tolerance_dev;
                tol_res=c1{crt_idx}.tolerance_res;
            case 'Sliding'
                dev_reg=c2{crt_idx}.dev_pl_his;
                res_reg=c2{crt_idx}.res_pl_his;
                
                tol_dev=c2{crt_idx}.tolerance_dev;
                tol_res=c2{crt_idx}.tolerance_res;
        end
        
        % Remove zeroes
        dev_reg=dev_reg(dev_reg>0);
        res_reg=res_reg(res_reg>0);
        
        % Create new figure
        title=[fname,'Deviation and Residuals. ',...
            sprintf('%s pressure, cycle TFR %.2f',mode,...
            mass_c1(crt_idx)/max_mass*100)];
        
        figure('Name',title);
        ax1=subplot(2,1,1);
        ax2=subplot(2,1,2);
        
        semilogy(ax1,1:length(dev_reg),dev_reg,'b-o',...
            [1,length(dev_reg)],[1,1]*tol_dev,'r');
        text(ax1,2,tol_dev,'Tolerance',...
            'VerticalAlignment','bottom');
        
        semilogy(ax2,1:length(res_reg),res_reg,'b-o',...
            [1,length(res_reg)],[1,1]*tol_res,'r');
        text(ax2,2,tol_res,'Tolerance',...
            'VerticalAlignment','bottom');
        
        ylabel(ax1,'Deviation');
        ylabel(ax2,'Residuals');
        xlabel(ax2,'Iteration');
        ax1.XLim=[1,length(dev_reg)+0.01];
        ax2.XLim=[1,length(res_reg)+0.01];
        
    end

    function manual_bypass(~,~,clist)
        % Get requested bypass
        fbypass=gui_bypass_dialog(c1{1}.N_FWH);
        
        if fbypass~=-1
            % Set pointer
            f.Pointer='watch';
            enable_auto_pointer=false;
            
            % Get paremeters for solving
            auto_bypass_limit_DCA=0;
            auto_bypass_limit_TTD=0;
            auto_bypass_hitcount=0;
            enable_auto_last_FWH=false;
            
            % Solve new cycle, with correct mode and mass
            if isempty(c_aux)
                if strcmp(mode,'Sliding')
                    % Create an auxiliary copy of the cycle to solve
                    c_aux=copy(c1{1});
                else
                    % Create an auxiliary copy of the cycle to solve
                    c_aux=copy(c2{1});
                end
            end
            
            if strcmp(mode,'Sliding')
                fmode='sliding';
            else
                fmode='constant';
            end
            
            % Set iteration parameters
            max_iter=c_aux.max_iterations;
            dev_tol=c_aux.tolerance_dev;
            res_tol=c_aux.tolerance_res;
            df=cy_conf.dampening_factor;
            
            fmass=mass_c1(crt_idx);
            
            c_aux.solv_PL(fmass,fbypass, ...
                auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
                auto_bypass_hitcount, enable_auto_last_FWH,...
                fmode, max_iter, dev_tol, res_tol,1,df);
            
            % Show cycle in diagram
            diag_cy(c_aux,clist);
            set_text_properties(c_aux);
            
            % Store bypass
            crt_bypass=fbypass;
            
            % Set pointer
            f.Pointer='arrow';
            enable_auto_pointer=true;
            
        end
        
    end

    function manual_valves(~,~,clist)
        % Get requested bypass
        [floss, fdeairloss]=gui_valve_dialog(c1{1}.N_FWH,c1{1}.N_FWH_HP,...
            c1{1}.EX_ploss,c1{1}.DAEX_ploss);
        
        if floss~=-1
            % Set pointer
            f.Pointer='watch';
            enable_auto_pointer=false;
            
            % Get paremeters for solving
            auto_bypass_limit_DCA=0;
            auto_bypass_limit_TTD=0;
            auto_bypass_hitcount=0;
            enable_auto_last_FWH=false;
            
            % Solve new cycle, with correct mode and mass
            if isempty(c_aux)
                if strcmp(mode,'Sliding')
                    % Create an auxiliary copy of the cycle to solve
                    c_aux=copy(c1{1});
                else
                    % Create an auxiliary copy of the cycle to solve
                    c_aux=copy(c2{1});
                end
            end
            
            if strcmp(mode,'Sliding')
                fmode='sliding';
            else
                fmode='constant';
            end
            
            % Set iteration parameters
            max_iter=c_aux.max_iterations;
            dev_tol=c_aux.tolerance_dev;
            res_tol=c_aux.tolerance_res;
            df=cy_conf.dampening_factor;
            
            fmass=mass_c1(crt_idx);
            
            % Set pressure losses
            c_aux.EX_ploss=floss;
            c_aux.DAEX_ploss=fdeairloss;
            
            c_aux.solv_PL(fmass,crt_bypass, ...
                auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
                auto_bypass_hitcount, enable_auto_last_FWH,...
                fmode, max_iter, dev_tol, res_tol,1,df);
            
            % Show cycle in diagram
            diag_cy(c_aux,clist);
            set_text_properties(c_aux);
            
            % Set pointer
            f.Pointer='arrow';
            enable_auto_pointer=true;
        end
        
    end

    function selec_dev(~,evdata)
        
        % File name
        if saved
            fname=sprintf('%s - ',file_name);
        else
            fname=sprintf('New solution - ',file_name);
        end
        
        % Selected coordinates
        xy_selected=evdata.IntersectionPoint;
        xy_selected=xy_selected(1:2);
        
        % Search for selected device
        for d = 1:n_fwh+1
            
            % FWH coordinates
            vert_x=fwh_cords{d}.pos_corners(:,1);
            vert_y=fwh_cords{d}.pos_corners(:,2);
            
            % Check if coordiantes are in polygon
            if inpolygon(xy_selected(1),xy_selected(2),vert_x,vert_y)
                if d ~= n_fwh_hp+1
                    
                    if d>n_fwh_hp+1
                        fwh_num=d-1;
                    else
                        fwh_num=d;
                    end
                    
                    if crt_bypass(fwh_num)==0
                        title=sprintf('%sFWH %i. %s pressure, cycle TFR %.2f',...
                            fname,fwh_num,mode,...
                            mass_c1(crt_idx)/max_mass*100);
                        
                        if isempty(c_aux)
                            if strcmp(mode,'Sliding')
                                show_fwh(c1{crt_idx}.fwh{fwh_num},title);
                            else
                                show_fwh(c2{crt_idx}.fwh{fwh_num},title);
                            end
                        else
                            show_fwh(c_aux.fwh{fwh_num},title);
                        end
                    end
                end
            end
        end
        
        for t = 1:3
            
            % TUR coordinates
            vert_x=tur_cords{t}(:,1);
            vert_y=tur_cords{t}(:,2);
            
            % Check if coordiantes are in polygon
            if inpolygon(xy_selected(1),xy_selected(2),vert_x,vert_y)
                
                switch t
                    case 1
                        % HP Tur
                        tur=1;
                        title=sprintf('%sHP Turbine. %s pressure, cycle TFR %.2f',...
                            fname,mode,mass_c1(crt_idx)/max_mass*100);
                        tur_type='HP';                        
                    case 2
                        % IP Tur
                        tur=2;
                        title=sprintf('%sIP Turbine. %s pressure, cycle TFR %.2f',...
                            fname,mode,mass_c1(crt_idx)/max_mass*100);
                        tur_type='IP';
                    case 3
                        % LP Tur
                        tur=2;
                        title=sprintf('%sLP Turbine. %s pressure, cycle TFR %.2f',...
                            fname,mode,mass_c1(crt_idx)/max_mass*100);
                        tur_type='LP';
                end
                
                
                if isempty(c_aux)
                    if strcmp(mode,'Constant')
                        show_tur(c1{crt_idx}.tur{tur},title,tur_type);
                    else
                        show_tur(c2{crt_idx}.tur{tur},title,tur_type);
                    end
                else
                    show_tur(c_aux.tur{tur},title,tur_type);
                end
                
            end
        end
    end

    function cursor_change(~,~)
        if enable_auto_pointer
            if strcmp(zoom_obj.Enable,'off') && strcmp(pan_obj.Enable,'off')
                % Only do this if not zooming or panning axes
                
                % Get pointer location
                p = get(diag_ax,'currentpoint');
                
                for h=1:n_fwh+1
                    
                    vert_x=fwh_cords{h}.pos_corners(:,1);
                    vert_y=fwh_cords{h}.pos_corners(:,2);
                    
                    if inpolygon(p(1),p(3),vert_x,vert_y)
                        if h~=n_fwh_hp+1
                            f.Pointer='hand';
                            
                            return
                        end
                    else
                        f.Pointer='arrow';
                    end
                    
                end
                
                for h=1:3
                    
                    vert_x=tur_cords{h}(:,1);
                    vert_y=tur_cords{h}(:,2);
                    
                    if inpolygon(p(1),p(3),vert_x,vert_y)
                        f.Pointer='hand';
                        return
                        
                    else
                        f.Pointer='arrow';
                    end
                end
            end
        end
    end

    function zoom_callback(~,~)
        f.Visible='on';
        
        % Get axis lims
        x_lim=diag_ax.XLim;
        y_lim=diag_ax.YLim;
        
        % Get maximum amplification factor
        amp=max(diff(ax_default_xlim)/diff(x_lim),...
            diff(ax_default_ylim)/diff(y_lim));
        
        % change font size accordingly
        cross_list.reset_counter();
        
        for pos=1:cross_list.get_length()
            row=cross_list.get_next();
            
            for t=1:4
                row{t}.FontSize=cross_fontsize*amp;
            end
        end
        
        other_txts_list.reset_counter();
        
        for pos=1:other_txts_list.get_length()
            row=other_txts_list.get_next();
            
            row.FontSize=cross_fontsize*amp;
        end
        
        drawnow;
    end

%%%%% Auxiliaries

    function redraw(idx,clist)
        % Redraw cycle
        switch mode
            case 'Constant'
                sub_redraw(c1,idx,mass_c1,clist);
                
                % Store bypass
                crt_bypass=c1{idx}.bypass;
            case 'Sliding'
                sub_redraw(c2,idx,mass_c2,clist);
                
                % Store bypass
                crt_bypass=c2{idx}.bypass;
        end
        
        % Force redraw
        drawnow;
    end

    function sub_redraw(c_obj,idx,mass,clist)
        % Rewrite cycle values
        diag_cy(c_obj{idx},clist);
        
        % Rewrite text properties
        set_text_properties(c_obj{idx});
        
        % Redraw current power
        for p=1:7
            crt_tfr{p}.XData=[1,1].*100*mass(idx)./max_mass;
            crt_tfr_txt{p}.String=num2str(100*mass(idx)/max_mass, '%.1f');
            
            if mass(idx) >= mass(round(length(mass)/2))
                crt_tfr_txt{p}.Position(1)=100*(mass(idx)-(mass(1)-mass(end))*0.075)/max_mass;
            else
                crt_tfr_txt{p}.Position(1)=100*(mass(idx)+(mass(1)-mass(end))*0.075)/max_mass;
            end
        end
        
        % Find selected tab
        for t=1:9
            if tabs{t}==tab_gr.SelectedTab
                selection = t;
            end
        end
        
        if selection==8
            % Redraw TS Diagram
            switch mode
                case 'Constant'
                    line_ts.XData=entr_c1(idx,:);
                    line_ts.YData=temp_c1(idx,:);
                case 'Sliding'
                    line_ts.XData=entr_c2(idx,:);
                    line_ts.YData=temp_c2(idx,:);
            end
        elseif selection==9
            % Redraw HS Diagram
            switch mode
                case 'Constant'
                    line_hs.XData=hs_entr_c1(idx,:);
                    line_hs.YData=enta_c1(idx,:);
                case 'Sliding'
                    line_hs.XData=hs_entr_c2(idx,:);
                    line_hs.YData=enta_c2(idx,:);
            end            
        end
    end

    function set_text_properties(cy)
        % Clear previous text
        jText.setText('');
        
        % Newline
        nl=char(10);
        
        jText.insert(   ['FW mass flow [kg/s] --- ', num2str(cy.m_fw,'%.2f')],0);
        jText.append([nl,'Cycle TFR [%] --------- ', num2str(cy.tur{1}.TFR*100,'%.2f')]);
        jText.append([nl,'Cycle power [kW] ------ ', num2str(cy.W_out,'%.2f')]);
        jText.append([nl,'HP Tur Power [kW] ----- ', num2str(cy.tur{1}.W_out,'%.2f')]);
        jText.append([nl,'IP Tur Power [kW] ----- ', num2str(cy.tur{2}.W_out_sep(1),'%.2f')]);
        jText.append([nl,'LP Tur Power [kW] ----- ', num2str(cy.tur{2}.W_out_sep(2),'%.2f')]);
        jText.append([nl,'Performance [%] ------- ', num2str(cy.n_cycle*100,'%.2f')]);
        jText.append([nl,'HeatRate [kJ/kWh] ----- ', num2str(cy.heatrate*3600,'%.2f')]);
        jText.append([nl,'HP Tur Perf [%] ------- ', num2str(cy.tur{1}.nise*100,'%.2f')]);
        jText.append([nl,'IP Tur Perf [%] ------- ', num2str(cy.tur{2}.nise*100,'%.2f')]);
        jText.append([nl,'LP Tur Perf [%] ------- ', num2str(cy.tur{2}.nise*100,'%.2f')]);
        jText.append([nl,'LP last st. perf [%] -- ', num2str(cy.tur{2}.nise_st(end)*100,'%.2f')]);
        jText.append([nl,'FW Pump Power [kW] ---- ', num2str(cy.fw_pmp.W_pump,'%.2f')]);
        jText.append([nl,'FW Pump perf [%] ------ ', num2str(cy.fw_pmp.nise*100,'%.2f')]);
        jText.append([nl,'CO Pump Power [kW] ---- ', num2str(cy.co_pmp.W_pump,'%.2f')]);
        jText.append([nl,'CO Pump perf [%] ------ ', num2str(cy.co_pmp.nise*100,'%.2f')]);
        
        for fwh=1:cy.N_FWH
            jText.append([nl,'U·A FWH ',num2str(fwh,'%.0f'),' [kW/K] ------ ', num2str(cy.fwh{fwh}.UA,'%.2f')]);
        end
        
        jText.append([nl,'Iterations ------------ ', num2str(cy.iter_pl,'%i')]);
        jText.append([nl,'Deviation ------------- ', num2str(cy.dev_pl,'%.10f')]);
        jText.append([nl,'Residuals ------------- ', num2str(cy.res_pl,'%.10f')]);
    end

    function incremental_draw(~,~,mode,clist)
        % Draw cycles by steps
        
        switch mode
            case 'plus_one'
                if crt_idx>1
                    crt_idx=crt_idx-1;
                    b2.Enable='on';
                else
                    b1.Enable='off';
                end
            case 'minus_one'
                if crt_idx<length(mass_c1)
                    crt_idx=crt_idx+1;
                    b1.Enable='on';
                else
                    b2.Enable='off';
                end
        end
        
        % Set slider to drawn mass
        set(jSlider,'Value',mass_c1(crt_idx)/max_mass*100);
        
        % Redraw
        redraw(crt_idx,clist);
    end

end

