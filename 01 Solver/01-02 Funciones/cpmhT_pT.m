function cp = cpmhT_pT(p,T1,T2)

% Calculo de cp usando la fórmula cp=(h1-h2)/(t1-t2)
% presion en bares, temperatura en K
% fluido debe estar fuera de la campana de cambio de fase

h1=h_pTx_97(p,T1,-1);
h2=h_pTx_97(p,T2,-1);

cp=abs((h1-h2)/(T1-T2));

end

