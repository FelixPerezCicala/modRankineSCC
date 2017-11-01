function [ s,T ] = TSdiag_bell()
%TSdiag_bell Generate TS diagram phase change bell

resolution=100;

t_camp=[linspace(0,350,resolution*0.5*4/5) linspace(350,370,resolution*0.5*0.5/5) linspace(371,373.9,resolution*0.5*0.5/5)];
s_bell=zeros(resolution,1);
for cont=1:resolution/2
    s_bell(cont)=XSteam('sL_T',t_camp(cont));
    s_bell(resolution+1-cont)=XSteam('sV_T',t_camp(resolution/2+1-cont));
end

s=[s_bell(1:resolution/2);flip(s_bell(resolution/2+1:resolution))];
T=[t_camp,flip(t_camp)];


end

