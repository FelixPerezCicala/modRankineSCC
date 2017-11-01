clear
clc
close all

x=linspace(0.25,10,100);
y=[2,3,4,5,6,7,10,20,30,50];

z=zeros(10,100);

for cont=1:10
    for cont2=1:100
        z(cont,cont2)=figs('Fig13',x(cont2)*10^6,y(cont));
    end
end

for cont=1:10
    semilogx(x,z(cont,:));
    hold on
end

legend('2','3','4','5','6','7','10','20','30','50','Location','southeast');
grid on