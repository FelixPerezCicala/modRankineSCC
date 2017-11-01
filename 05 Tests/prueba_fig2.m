clear
clc
close all

% x_axis=linspace(0.5,0.85,100);
% x=0.625-linspace(0.5,0.85,100);
% Qv1=10^10;
% Qv2=200000;
% Qv3=100000;
% 
% A=fliplr([0,-1.6649986,-22.538964,19.464851]);
% B=fliplr([0,798267.5,-7540.7,-154269.4]);
% 
% z1=polyval(A,x)+polyval(B,x)/Qv1;
% z2=polyval(A,x)+polyval(B,x)/Qv2;
% z3=polyval(A,x)+polyval(B,x)/Qv3;
% 
% plot(x_axis,z1,x_axis,z2,x_axis,z3);
% 
% legend('Inf','200000','100000');

x_axis=linspace(0.5,0.85,100);
x=linspace(0.5,0.85,100);
Qv1=10^10;
Qv2=200000;
Qv3=100000;

z1=feval('figs','Fig2',x,Qv1);
z2=feval('figs','Fig2',x,Qv2);
z3=feval('figs','Fig2',x,Qv3);

plot(x_axis,z1,x_axis,z2,x_axis,z3);

legend('Inf','200000','100000');