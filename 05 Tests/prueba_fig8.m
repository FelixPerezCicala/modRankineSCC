clear
clc
close all

x=linspace(0.2,1,100);
y=convlength([46,42,34,30],'in','m');

z=zeros(4,100);

for cont=1:4
    for cont2=1:100
        z(cont,cont2)=figs('Fig8',x(cont2),y(cont));
    end
end

hold on
for cont=1:4
    plot(x,z(cont,:));
end

legend('46','42','34','30');
grid on