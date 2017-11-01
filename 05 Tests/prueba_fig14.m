clear
clc
close all

sample_size=10000;

x=linspace(20,2000,sample_size);
y=[1400,1350,1300,1250,1200,1150,1100,1050,1000,950,900,850,800,750,700,650,600,550,500];

x_psi=x;
y_string=num2str(y');

x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
y=convtemp(y,'F','K'); % Pasar F a K

z=zeros(19,sample_size);

for cont=1:14
    for cont2=1:sample_size
        h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
        s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
        z(cont,cont2)=figs('Fig14',x(cont2),h,s);
    end
end

cont=15;
x=linspace(20,1500,sample_size);
x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
for cont2=1:sample_size
    h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
    s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
    z(cont,cont2)=figs('Fig14',x(cont2),h,s);
end

cont=cont+1;
x=linspace(20,1300,sample_size);
x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
for cont2=1:sample_size
    h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
    s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
    z(cont,cont2)=figs('Fig14',x(cont2),h,s);
end

cont=cont+1;
x=linspace(20,1000,sample_size);
x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
for cont2=1:sample_size
    h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
    s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
    z(cont,cont2)=figs('Fig14',x(cont2),h,s);
end

cont=cont+1;
x=linspace(20,800,sample_size);
x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
for cont2=1:sample_size
    h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
    s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
    z(cont,cont2)=figs('Fig14',x(cont2),h,s);
end

cont=cont+1;
x=linspace(20,600,sample_size);
x=convpres(x,'psi','pa')*10^-5; % Pasar PSI a bar
for cont2=1:sample_size
    h=h_pTx_97(x(cont2)*10^-1,y(cont),-1);
    s=s_pTx_97(x(cont2)*10^-1,y(cont),-1);
    z(cont,cont2)=figs('Fig14',x(cont2),h,s);
end


for cont=1:14
    semilogx(x_psi,z(cont,:));
    hold on
end

semilogx(linspace(20,1500,sample_size),z(15,:));
semilogx(linspace(20,1300,sample_size),z(16,:));
semilogx(linspace(20,1000,sample_size),z(17,:));
semilogx(linspace(20,800,sample_size),z(18,:));
semilogx(linspace(20,600,sample_size),z(19,:));

legend(y_string);
grid on




