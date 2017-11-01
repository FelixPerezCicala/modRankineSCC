function hfg = hfg_p(p)

% Calculo de la entalpia de vaporizacion en funcion de la temperatura en
% MPa

h2=h_pTx_97(p,-1,1);
h1=h_pTx_97(p,-1,0);

hfg=h2-h1;

end

