function show_tur(turobj, figure_name, tur_type)
%show_fwh Show turbine object properties
%    turobj -> Turbine object to display
%    figure_name -> Desired figure name
%    start_pos -> Desired figure name
%    end_pos -> Turbine end stage to show
%    ignore_first_ext -> Ignore first extraction (LP Tur option)

% Initialize figure
f=figure('Name',figure_name,...
    'Visible','off',...
    'Color',[255,255,255]/255,...
    'MenuBar','none','ToolBar','figure');

% Disable unwanted buttons
disable_tooltips(f,true,true);

% Adjust size
f.Position(3)=800;
f.Position(4)=400;

% Text area
in_pan = uipanel(f,'Units','normalized',...
    'Position',[0.01,0.01,0.49,0.98],...
    'Title','Turbine information');

% JText area
jText = javax.swing.JTextArea;
jText.setEditable(0);

% jContainer = javax.swing.JScrollPane(jText);
jContainer = javax.swing.JScrollPane(jText);
[hjContainer, hContainer] = javacomponent(jContainer,[0,0,1,1], in_pan);

F = java.awt.Font('Lucida Console', java.awt.Font.PLAIN, 12);

set(jText,'Font',F);

set(hContainer,'Units','normalized','position',[0.01,0.01,0.98,0.98]); %note container size change

tab_gr = uitabgroup(f,'Units','normalized',...
    'Position',[0.51,0.01,0.48,0.98],...
    'TabLocation','left');

tab1 = uitab(tab_gr,'Title','h-s','ForegroundColor',[161,0,0]./255);
tab2 = uitab(tab_gr,'Title','T-s');
tab3 = uitab(tab_gr,'Title','n Is.');
tab4 = uitab(tab_gr,'Title','Pres.');
tab5 = uitab(tab_gr,'Title','Temp.');
tab6 = uitab(tab_gr,'Title','Power');
tab7 = uitab(tab_gr,'Title','Extr.');

tabs=cell(7,1);
tabs{1}=tab1;
tabs{2}=tab2;
tabs{3}=tab3;
tabs{4}=tab4;
tabs{5}=tab5;
tabs{6}=tab6;
tabs{7}=tab7;

% Build values and labels
if strcmp(tur_type,'HP')
    % HP Turbine values
    s=[turobj.adm_s ,turobj.s_st(2:end)];
    T=[turobj.adm_T ,turobj.T_st(2:end)];-273;
    h=[turobj.adm_h ,turobj.h_st(2:end)];
    P=[turobj.adm_EX ,turobj.EX(2:end)];
    nise=turobj.nise_st(2:end);
    W_st=turobj.W_st(2:end);
    x_st=turobj.x_st;
    W_out=turobj.W_out;
    P_ratio=P(3)/P(end);
    
    % Staging and labels
    stages=1:(length(turobj.h_st)+2);
    stages_labels=['TV','GS',cellstr(num2str((1:length(turobj.h_st))'))'];
    labels_x_offset=[-0.025,-0.015,0,0,0];
    labels_y_offset=[30,30,0,0,0;15,15,0,0,0];
    stages_labels_pow=cell(1,length(stages)-3);
    draw_legend=true;
    legend_text=sprintf('TV: Throttle Valve input\nGS: Governing stage input');
    
    % Extractions
    m_ex=turobj.m_EX(2:end);
    num_extr=length(m_ex);
    
elseif strcmp(tur_type,'IP')
    % IP Turbine values
    s=[turobj.adm_s ,turobj.s_st(2:turobj.XO_pos)];
    T=[turobj.adm_T ,turobj.T_st(2:turobj.XO_pos)];-273;
    h=[turobj.adm_h ,turobj.h_st(2:turobj.XO_pos)];
    P=[turobj.adm_EX ,turobj.EX(2:turobj.XO_pos)];
    nise=turobj.nise_st(2:turobj.XO_pos);
    W_st=turobj.W_st(2:turobj.XO_pos);
    x_st=turobj.x_st(1:turobj.XO_pos);    
    W_out=turobj.W_out_sep(1);
    P_ratio=P(2)/P(end);
    
    % Staging and labels
    stages=1:(1+length(turobj.h_st(1:turobj.XO_pos)));
    stages_labels=[{'IV'},num2cell(num2str(stages(1:end-1)'))'];
    labels_x_offset=zeros(1,length(stages_labels));
    labels_x_offset(1)=-0.03;
    labels_y_offset=zeros(2,length(stages_labels));
    stages_labels_pow=cell(1,length(stages)-2);
    draw_legend=true;
    legend_text='IV: Intercept valve input';
    
    % Extractions
    m_ex=turobj.m_EX(2:turobj.XO_pos);
    num_extr=length(m_ex);
else
    % LP Turbine values
    s=turobj.s_st(turobj.XO_pos:end);
    T=turobj.T_st(turobj.XO_pos:end)-273;
    h=turobj.h_st(turobj.XO_pos:end);
    P=turobj.EX(turobj.XO_pos:end);
    nise=turobj.nise_st(turobj.XO_pos+1:end);
    W_st=turobj.W_st(turobj.XO_pos+1:end);
    x_st=turobj.x_st(turobj.XO_pos:end);
    W_out=turobj.W_out_sep(2);
    P_ratio=P(1)/P(end);
    
    % Staging and labels
    stages=1:length(turobj.h_st(turobj.XO_pos:end));
    stages_labels=num2cell(num2str(stages'))';
    labels_x_offset=zeros(1,length(stages_labels));
    labels_y_offset=zeros(2,length(stages_labels));
    stages_labels_pow=cell(1,length(stages)-1);
    draw_legend=false;
    
    % Extractions
    m_ex=turobj.m_EX(turobj.XO_pos+1:end-1);
    num_extr=length(m_ex);
end

% Write labels for power stages
for i=length(stages_labels_pow):-1:1
    stages_labels_pow{end+1-i}=sprintf('%s-%s',...
        stages_labels{end-i},...
        stages_labels{end+1-i});
end


% h-s axes
ax_hs=axes(tab1,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_hs.XLabel.String='s [kj/kg·K]';
ax_hs.YLabel.String='h [kj/kg]';

plot(ax_hs,s,...
    h,...
    '-o','Color',[0, 0, 255]./255,'MarkerEdgeColor','r');

ax_hs.XLim = [min(s)*0.99,...
    max(s)*1.01];

ax_hs.YLim = [min(h)*0.95,...
    max(h)*1.05];

[s_bell,h_bell]=HSdiag_bell();

plot(ax_hs,s_bell,h_bell,...
    'Color',[0, 0, 0]./255);

for i=1:length(stages_labels)    
    text(ax_hs,s(i)+0.01+labels_x_offset(i),...
        h(i)+labels_y_offset(1,i),...
        stages_labels(i),'HorizontalAlignment','left','FontUnits','normalized');
end

% T-s axes
ax_Ts=axes(tab2,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_Ts.XLabel.String='s [kj/kg·K]';
ax_Ts.YLabel.String='T [ºC]';

plot(ax_Ts,s,...
    T,...
    '-o','Color',[0, 0, 255]./255,'MarkerEdgeColor','r');

ax_Ts.XLim = [min(s)*0.99,...
    max(s)*1.01];

if strcmp(tur_type,'LP')
    ax_Ts.YLim = [min(T)*0.5,...
        max(T)*1.05];
else
    ax_Ts.YLim = [min(T)*0.95,...
        max(T)*1.05];
end
    

[s_bell,t_bell]=TSdiag_bell();

plot(ax_Ts,s_bell,t_bell,...
    'Color',[0, 0, 0]./255);

for i=1:length(stages_labels)
    text(ax_Ts,s(i)+0.01+labels_x_offset(i),...
        T(i)+labels_y_offset(2,i),...
        stages_labels(i),'HorizontalAlignment','left','FontUnits','normalized');
end

if draw_legend
    text(ax_hs,ax_hs.XLim(1)+0.01,...
        ax_hs.YLim(1)+60,...
        legend_text,...
        'HorizontalAlignment','left',...
        'BackgroundColor',[1,1,1],'EdgeColor',[0,0,0],'FontUnits','normalized');
    
    text(ax_Ts,ax_Ts.XLim(1)+0.01,...
        ax_Ts.YLim(1)+25,...
        legend_text,...
        'HorizontalAlignment','left',...
        'BackgroundColor',[1,1,1],'EdgeColor',[0,0,0],'FontUnits','normalized');
end

% Isentropic performance axes
ax_pow=axes(tab3,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_pow.XLabel.String='Stage';
ax_pow.YLabel.String='Isentropic performance [%]';
ax_pow.XTick=1:length(stages_labels_pow);
ax_pow.XTickLabel=stages_labels_pow;
ax_pow.XLim=[min(ax_pow.XTick)-0.5,max(ax_pow.XTick)+0.5];

bar(ax_pow,nise*100);

% Pressure axes
ax_pre=axes(tab4,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_pre.XLabel.String='Stage';
ax_pre.YLabel.String='Pressure [bar]';
ax_pre.XTick=stages;
ax_pre.XTickLabel=stages_labels;
ax_pre.XLim=[0.5,stages(end)+0.5];

plot(ax_pre,stages,...
    P,...
    '-o','Color',[255, 0, 0]./255);

% Temperature axes
ax_t=axes(tab5,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_t.XLabel.String='Stage';
ax_t.YLabel.String='T [ºC]';
ax_t.XTick=stages;
ax_t.XTickLabel=stages_labels;
ax_pre.XLim=[0.5,stages(end)+0.5];

plot(ax_t,stages,...
    T,...
    '-o','Color',[255, 0, 0]./255);

% Power axes
ax_pow=axes(tab6,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_pow.XLabel.String='Stage';
ax_pow.YLabel.String='Power [MW]';
ax_pow.XTick=1:length(stages_labels_pow);
ax_pow.XTickLabel=stages_labels_pow;
ax_pow.XLim=[min(ax_pow.XTick)-0.5,max(ax_pow.XTick)+0.5];

bar(ax_pow,W_st*10^-3);

% Extraction axes
ax_ex=axes(tab7,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',9,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25);
ax_ex.XLabel.String='Extractions';
ax_ex.YLabel.String='Mass flow [kg/s]';

if num_extr==0
    ax_ex.XTick=1;
    
    ax_ex.XTickLabel=num2cell(ax_ex.XTick);
    ax_ex.XLim=[-0.5,0.5];
    
    bar(ax_ex,0);
else
    ax_ex.XTick=1:num_extr;
    
    ax_ex.XTickLabel=num2cell(ax_ex.XTick);
    ax_ex.XLim=[min(ax_ex.XTick)-0.5,max(ax_ex.XTick)+0.5];
    
    bar(ax_ex,m_ex);
end

% Write text
% Newline
nl=char(10);

jText.insert('Turbine group',0);
jText.append([nl,'     Turbine type -------------------- ', turobj.turbine_type]);
jText.append([nl,'     Total power [MW] ---------------- ', num2str(W_out/1000,'%.2f')]);

if (strcmp(turobj.turbine_type,'HP-1ROW') || strcmp(turobj.turbine_type,'HP-2ROW'))
    jText.append([nl,'     TFR [%] ------------------------- ', num2str(turobj.TFR*100,'%.2f')]);
end

jText.append([nl,'     Pressure ratio (P1/Pout) -------- ', num2str(P_ratio,'%.2f')]);
jText.append([nl,nl,'Isentropic performance']);
jText.append([nl,'     Base [%] ------------------------ ', num2str(turobj.nise_nom*100,'%.2f')]);
jText.append([nl,'     Total performance [%] ----------- ', num2str(turobj.nise_total*100,'%.2f')]);

jText.append([nl,nl,'Per stage isentropic performance']);

lab_count=1;
for s=1:length(nise)
    jText.append([nl,'     Stage ',stages_labels_pow{lab_count},...
        ' [%] ------------------- ', num2str(nise(s)*100,'%.2f')]);
    lab_count=lab_count+1;
end

jText.append([nl,nl,'Corrections applied to base isentropic performance']);

lab_count=1;
for s=1:length(turobj.corr_nise)
    jText.append([nl,sprintf('     Correction %i',s),...
        ' [% better] --------- ', num2str(turobj.corr_nise(s),'%.2f')]);
    lab_count=lab_count+1;
end

jText.append([nl,nl,'Per stage generated power']);

lab_count=1;
for s=length(W_st)
    jText.append([nl,'     Stage ',stages_labels_pow{lab_count},...
        ' [MW] ------------------ ', num2str(W_st(s)/1000,'%.2f')]);
    lab_count=lab_count+1;
end

jText.append([nl,nl,'Per stage title (steam mass / total mass)']);

lab_count=1;
for s=1:length(x_st)
    if x_st(s)==-1
        jText.append([nl,'     Stage ',num2str(stages(lab_count),'%.0f'),...
            ' [%] --------------------- ', num2str(100,'%.2f')]);
    else
        jText.append([nl,'     Stage ',num2str(stages(lab_count),'%.0f'),...
            ' [%] --------------------- ', num2str(x_st(s)*100,'%.2f')]);
    end
    lab_count=lab_count+1;
end

if (strcmp(turobj.turbine_type,'REHEAT-36/18') ...
        || strcmp(turobj.turbine_type,'REHEAT-36') ...
        || strcmp(turobj.turbine_type,'REHEAT-18'))
    
    jText.append([nl,nl,'Additional corrections for low pressure turbine']);
    jText.append([nl,'     Ex. pressure correction [kj/kg]-- ', num2str(turobj.corr_moisture,'%.2f')]);
    jText.append([nl,'     Used energy end point [kJ/kg] --- ', num2str(turobj.UEEP,'%.2f')]);
end

if (strcmp(turobj.turbine_type,'HP-1ROW') || strcmp(turobj.turbine_type,'HP-2ROW'))
    
    jText.append([nl,nl,'Losses through throttle valve']);
    jText.append([nl,'     Pressure loss [bar]-------------- ', num2str(P(1)-P(2),'%.2f')]);
    jText.append([nl,'     Temperature delta [K] ----------- ', num2str(T(1)-T(2),'%.2f')]);
    
    jText.append([nl,nl,'Losses through governing stage']);
    jText.append([nl,'     Pressure loss [bar]-------------- ', num2str(P(2)-P(3),'%.2f')]);
    jText.append([nl,'     Enthalpy loss [kJ/kg·K]---------- ', num2str(h(2)-h(3),'%.2f')]);
    jText.append([nl,'     Total energy loss [kW]----------- ', ...
        num2str((h(2)-h(3))*(turobj.m_in-sum(turobj.m_Lks(1:2))),'%.2f')]);
    jText.append([nl,'     Temperature delta [K] ----------- ', num2str(T(2)-T(3),'%.2f')]);
end

% Set tabs callbacks
tab1.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,1);
tab2.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,2);
tab3.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,3);
tab4.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,4);
tab5.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,5);
tab6.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,6);
tab7.ButtonDownFcn=@(src,evdata) tab_color(src,evdata,7);

% Make figure visible
f.Visible='on';

    function tab_color(~,~,active_tab)
        for t=1:length(tabs)
            if t==active_tab
                tabs{t}.ForegroundColor=[161,0,0]./255;
            else
                tabs{t}.ForegroundColor=[0,0,0]./255;
            end
        end
        
    end

end

