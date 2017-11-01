function [ s ] = s_ph_97(p, h)
%s_ph_97 Enthalpy from pressure [MPa] and enthalpy [kJ/kg*K]

% Get point temperature and title
T=T_ph_97(p,h);
x=x_ph_97(p,h);

if x==-1
    s=s_pTx_97(p,T,-1);
else
    s=s_pTx_97(p,-1,x);
end


end

