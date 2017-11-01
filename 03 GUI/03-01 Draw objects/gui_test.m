function gui_test()
clc
clear
close all

% GUI test
f = figure('Name','le gui test');
ax = axes(f);
ax.NextPlot='add';

fwh=gui_fwh(20,20);
fwh.draw(ax,30,20, true);
fwh.draw(ax,60,20, true);

turHPIP=gui_turHPIP(70,30,12,3,3);
turHPIP.draw(ax,30,50);

turLP=gui_turLP(50,21,12,4);
turLP.draw(ax,120,50);

connect(ax,turHPIP.IP_out_up,...
    turLP.in,...
    [(turHPIP.IP_out_up(1) + turLP.in(1))/2,turHPIP.IP_out_up(2)+10],...
    true, 5, 'ver');

pump=gui_pmp(5);
pump.draw(ax,5,80,270);

con=gui_con(20,20);
con.draw(ax,100,20);

text_resize_factor=0.015;

text_arr=cell(2,4);

text_arr{1,:} = cross(ax,120,10,120,20,200.5,230);
text_arr{2,:} = cross(ax,120,10,120,20,200.5,230);

f.SizeChangedFcn = @(src,callbackdata) fig_resize(src,callbackdata,text_arr,text_resize_factor);

ax.XLim=[0,200];
ax.YLim=[0,100];
ax.DataAspectRatio=[1,1,1];
fig_resize(f,1,text_arr,text_resize_factor)

    function fig_resize(src,~,t,factor)
        
        for i=1:length(t)
            t{i}.FontSize=factor*src.Position(3);
        end
        
    end


end

