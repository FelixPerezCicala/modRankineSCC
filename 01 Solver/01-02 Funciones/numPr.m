function Pr = numPr(p,T,x)

% p en MPa
% Temperatura en K
% Titulo en kg vapor/kg liquido

cp=cp_pTx_97(p,T,x)*1000;
u=eta_pTx_97(p,T,x);
k=lambda_pTx_97(p,T,x);

Pr=cp*u/k;

end

