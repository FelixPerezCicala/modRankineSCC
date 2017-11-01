clear
clc
close all

TFR=linspace(0.2,1,100);
y=linspace(1.2,2,9);

z=zeros(9,100);

for cont=1:9
    for cont2=1:100
        z(cont,cont2)=figs('Fig4',TFR(cont2),y(cont));
    end
end

hold on
for cont=1:9
    plot(TFR,z(cont,:));
end

legend('1.2','1.3','1.4','1.5','1.6','1.7','1.8','1.9','2.0');
grid on