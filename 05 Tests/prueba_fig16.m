clear
clc
close all

x=linspace(128,1400,100);
y=[1,2,3,4,5];
z=zeros(100,length(y));

for cont=1:length(y)
    for i=1:length(x)
        z(i,cont)=figs('Fig16',x(i),y(cont));
    end
end

plot(x,z(:,1),...
    x,z(:,2),...
    x,z(:,3),...
    x,z(:,4),...
    x,z(:,5));
    

legend('1','2','3','4','5');