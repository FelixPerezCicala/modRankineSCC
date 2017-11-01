function [ s,h ] = HSdiag_bell()
%TSdiag_bell Generate hs diagram phase change bell

t_camp=[linspace(0,371,200) linspace(371,373.9,50)];
s_bell=zeros(500,1);
h_bell=zeros(500,1);

for cont=1:250
    s_bell(cont)=XSteam('sL_T',t_camp(cont));
    s_bell(501-cont)=XSteam('sV_T',t_camp(251-cont));
        
    h_bell(cont)=XSteam('hL_T',t_camp(cont));
    h_bell(501-cont)=XSteam('hV_T',t_camp(251-cont));
end

s=[s_bell(1:250);flip(s_bell(251:500))];
h=[h_bell(1:250);flip(h_bell(251:500))];


end

