clear
clc
close all

x=linspace(0.1,0.5,100);
y=[7.8658,4.7195,3.1463,2.3595,1.5732];

z=zeros(5,100);

for cont=1:5
    for cont2=1:100
        z(cont,cont2)=figs('Fig10',x(cont2),y(cont));
    end
end

hold on
for cont=1:5
    plot(x,z(cont,:));
end

legend('1,000,000','600,000','400,000','300,000','200,000');
grid on