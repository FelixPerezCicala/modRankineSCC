clear
clc
close all

x=linspace(0.1,0.5,100);
y=[31.4632,15.7316,7.8658,4.7195,1.5732];

z=zeros(5,100);

for cont=1:5
    for cont2=1:100
        z(cont,cont2)=figs('Fig6',x(cont2),y(cont));
    end
end

hold on
for cont=1:5
    plot(x,z(cont,:));
end

legend('4,000,000','2,000,000','1,000,000','600,000','200,000');
grid on