clear
clc
close all

x=linspace(0.2,1,100);
y=[2,3,4,5,6];

z=zeros(5,100);

for cont=1:5
    for cont2=1:100
        z(cont,cont2)=figs('Fig11',x(cont2),y(cont));
    end
end

hold on
for cont=1:5
    plot(x,z(cont,:));
end

legend('2','3','4','5','6','Location','southeast');
grid on