function show_fwh(fwhobj, figure_name)
%show_fwh Show fwh properties

% Initialize figure
f=figure('Name',figure_name,...
    'Visible','off',...
    'Color',[255,255,255]/255,...
    'MenuBar','none','ToolBar','figure');

% Disable unwanted buttons
disable_tooltips(f,false,true);

% Adjust size
f.Position(3)=800;
f.Position(4)=400;

% Text area
in_pan = uipanel(f,'Units','normalized',...
    'Position',[0.01,0.01,0.49,0.98],...
    'Title','Feed Water Heater information');

% JText area
jText = javax.swing.JTextArea;
jText.setEditable(0);

% jContainer = javax.swing.JScrollPane(jText);
jContainer = javax.swing.JScrollPane(jText);
[hjContainer, hContainer] = javacomponent(jContainer,[0,0,1,1], in_pan);

F = java.awt.Font('Lucida Console', java.awt.Font.PLAIN, 12);

set(jText,'Font',F);

set(hContainer,'Units','normalized','position',[0.01,0.01,0.98,0.98]); %note container size change

% Axes area
ax_pan = uipanel(f,'Units','normalized',...
    'Position',[0.51,0.01,0.48,0.98],...
    'Title','Temperatures');

ax_temps=axes(ax_pan,'Units','normalized','OuterPosition',[0,0,1,1],...
    'NextPlot','add','XGrid','on','YGrid','on','FontSize',10,...
    'GridColor',[0,0,0]./255,'GridAlpha',0.25,...
    'Box','on');

ax_temps.YLabel.String = 'Temperature [ºC]';

% Write text
% Newline
nl=char(10);

jText.insert('Mass flow ',0);
jText.append([nl,'     Feed water [kg/s] --------------- ', num2str(fwhobj.mciclo,'%.2f')]);
jText.append([nl,'     Extraction steam [kg/s] --------- ', num2str(fwhobj.mex,'%.2f')]);
jText.append([nl,'     Drainback [kg/s] ---------------- ', num2str(fwhobj.md,'%.2f')]);
jText.append([nl,nl,'Pressures']);
jText.append([nl,'     Tubes [bar] --------------------- ', num2str(fwhobj.P_C,'%.2f')]);
jText.append([nl,'     Shell [bar] --------------------- ', num2str(fwhobj.P_ex,'%.2f')]);
jText.append([nl,nl,'Heater operation']);
jText.append([nl,'     Exchanged heat [kW] ------------- ', num2str(fwhobj.Q_exchanged,'%.2f')]);
jText.append([nl,'     Global U·A [kW/k] --------------- ', num2str(fwhobj.UA,'%.2f')]);
jText.append([nl,'     TTD [K] ------------------------- ', num2str(fwhobj.TTD,'%.2f')]);
jText.append([nl,'     DCA [K] ------------------------- ', num2str(fwhobj.DCA,'%.2f')]);

if fwhobj.x_ex==-1
    jText.append([nl,'     Steam title (m st./m tot.) [%] -- ', num2str(100,'%.2f')]);
else
    jText.append([nl,'     Steam title (m st./m tot.) [%] -- ', num2str(fwhobj.x_ex*100,'%.2f')]);
end

if fwhobj.L_DSH>0
    jText.append([nl,nl,'Residuals: De-superheater section']);
    jText.append([nl,'     Q_U·A·LMTD - Q_hot [kW] ---------- ', num2str(fwhobj.Q_EXC_DSH(1),'%.12f')]);
    jText.append([nl,'     Q_cold - Q_hot [kW] -------------- ', num2str(fwhobj.Q_EXC_DSH(2),'%.12f')]);
else
    jText.append([nl]);
end
jText.append([nl,'Residuals: Condenser section']);
jText.append([nl,'     Q_U·A·LMTD - Q_hot [kW] ---------- ', num2str(fwhobj.Q_EXC_CON(1),'%.12f')]);
jText.append([nl,'     Q_cold - Q_hot [kW] -------------- ', num2str(fwhobj.Q_EXC_CON(2),'%.12f')]);
jText.append([nl,'Residuals: Subcooler section']);
jText.append([nl,'     Q_U·A·LMTD - Q_hot [kW] ---------- ', num2str(fwhobj.Q_EXC_SUB(1),'%.12f')]);
jText.append([nl,'     Q_cold - Q_hot [kW] -------------- ', num2str(fwhobj.Q_EXC_SUB(2),'%.12f')]);

if fwhobj.L_DSH>0
    jText.append([nl,nl,'De-SuperHeater']);
    jText.append([nl,'     Exchanged heat [kW] ------------- ', num2str(fwhobj.Q_DSH ,'%.2f')]);
    jText.append([nl,'     U·A [kW/k] ---------------------- ', num2str(fwhobj.U_DSH*fwhobj.A_DSH/1000 ,'%.2f')]);
    jText.append([nl,'     U [W/k·m2] ---------------------- ', num2str(fwhobj.U_DSH ,'%.2f')]);
    jText.append([nl,'     Exchange area [m2] -------------- ', num2str(fwhobj.A_DSH ,'%.2f')]);
    jText.append([nl,'     Length [m] ---------------------- ', num2str(fwhobj.L_DSH ,'%.2f')]);
    jText.append([nl,'     Steam input temperature [K] ----- ', num2str(fwhobj.T_Hin -273,'%.2f')]);
    jText.append([nl,'     Steam output temperature [K] ---- ', num2str(fwhobj.T_HDSH_out -273,'%.2f')]);
    jText.append([nl,'     Water input temperature [K] ----- ', num2str(fwhobj.T_CDSH_in -273,'%.2f')]);
    jText.append([nl,'     Water output temperature [K] ---- ', num2str(fwhobj.T_Cout -273,'%.2f')]);
end

jText.append([nl,nl,'Condenser']);
jText.append([nl,'     Exchanged heat [kW] ------------- ', num2str(fwhobj.Q_CON ,'%.2f')]);
jText.append([nl,'     U·A [kW/k] ---------------------- ', num2str(fwhobj.U_CON*fwhobj.A_CON/1000 ,'%.2f')]);
jText.append([nl,'     U [W/k·m2] ---------------------- ', num2str(fwhobj.U_CON ,'%.2f')]);
jText.append([nl,'     Exchange area [m2] -------------- ', num2str(fwhobj.A_CON ,'%.2f')]);
jText.append([nl,'     Length [m] ---------------------- ', num2str(fwhobj.L_CON ,'%.2f')]);
jText.append([nl,'     Steam input temperature [K] ----- ', num2str(fwhobj.T_HCON_in -273,'%.2f')]);
jText.append([nl,'     Steam output temperature [K] ---- ', num2str(fwhobj.T_HCON_out -273,'%.2f')]);
jText.append([nl,'     Water input temperature [K] ----- ', num2str(fwhobj.T_CSUB_out -273,'%.2f')]);
jText.append([nl,'     Water output temperature [K] ---- ', num2str(fwhobj.T_CCON_out -273,'%.2f')]);
jText.append([nl,'     Tube surface temperature [K] ---- ', num2str(fwhobj.T_CON_sur -273,'%.2f')]);

jText.append([nl,nl,'Subcooler']);
jText.append([nl,'     Exchanged heat [kW] ------------- ', num2str(fwhobj.Q_SUB ,'%.2f')]);
jText.append([nl,'     U·A [kW/k] ---------------------- ', num2str(fwhobj.U_SUB*fwhobj.A_SUB/1000,'%.2f')]);
jText.append([nl,'     U [W/k·m2] ---------------------- ', num2str(fwhobj.U_SUB ,'%.2f')]);
jText.append([nl,'     Exchange area [m2] -------------- ', num2str(fwhobj.A_SUB ,'%.2f')]);
jText.append([nl,'     Length [m] ---------------------- ', num2str(fwhobj.L_SUB ,'%.2f')]);
jText.append([nl,'     Steam input temperature [K] ----- ', num2str(fwhobj.T_HCON_out -273,'%.2f')]);
jText.append([nl,'     Steam output temperature [K] ---- ', num2str(fwhobj.T_Hout -273,'%.2f')]);
jText.append([nl,'     Water input temperature [K] ----- ', num2str(fwhobj.T_Cin -273,'%.2f')]);
jText.append([nl,'     Water output temperature [K] ---- ', num2str(fwhobj.T_CSUB_out -273,'%.2f')]);

jText.append([nl,nl,'Heater geometry']);
jText.append([nl,'     Number of tubes (total) --------- ', num2str(fwhobj.N_tubos ,'%.2f')]);
jText.append([nl,'     Shell diameter [m] -------------- ', num2str(fwhobj.d_car,'%.2f')]);

% Draw temperatures in axes
if fwhobj.L_DSH>0
    x_values=[fwhobj.L_DSH+fwhobj.L_CON+fwhobj.L_SUB,...
        fwhobj.L_CON+fwhobj.L_SUB,...
        fwhobj.L_CON+fwhobj.L_SUB,...
        fwhobj.L_SUB,...
        0];
    
    ax_temps.XTick = fliplr([x_values(1), x_values(3:end)]);
    ax_temps.XTickLabel = {'SUB','SUB-CON','CON-DSH','DSH'};
    ax_temps.XTickLabelRotation = 45;
    
    hot_line=[fwhobj.T_Hin, fwhobj.T_HDSH_out, fwhobj.T_HCON_in,...
        fwhobj.T_HCON_out, fwhobj.T_Hout] -273;
    
    cold_line=[fwhobj.T_Cout, fwhobj.T_CDSH_in, fwhobj.T_CDSH_in,...
        fwhobj.T_CSUB_out, fwhobj.T_Cin] -273;
    
else
    x_values=[fwhobj.L_CON+fwhobj.L_SUB,...
        fwhobj.L_CON+fwhobj.L_SUB,...
        fwhobj.L_SUB,...
        0];
    
    ax_temps.XTick = fliplr([x_values(1), x_values(3:end)]);
    ax_temps.XTickLabel = {'SUB','SUB-CON','CON'};
    ax_temps.XTickLabelRotation = 45;
    
    hot_line=[fwhobj.T_Hin, fwhobj.T_HCON_in,...
        fwhobj.T_HCON_out, fwhobj.T_Hout] -273;
    
    cold_line=[fwhobj.T_Cout, fwhobj.T_CCON_out,...
        fwhobj.T_CSUB_out, fwhobj.T_Cin] -273;
    
end

% Draw
plot(ax_temps,x_values,hot_line,...
    'Color',[255,0,0]/255,'LineWidth',1);

plot(ax_temps,x_values,cold_line,...
    'Color',[0,0,255]/255,'LineWidth',1);

% Set limits
ax_temps.XLim = [min(x_values),max(x_values)];

% Make figure visible
f.Visible='on';

end

