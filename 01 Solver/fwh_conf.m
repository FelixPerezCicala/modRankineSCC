classdef fwh_conf
    %fwh_conf used to store fwh geometrical configuration
    
    properties (Access = public)
        
        v % Flow speed in tubes [m/s]
        k % Tube thermal conductivity [W/m*k]
        de % Tube external diameter [m]
        di % Tube internal diameter [m]
        pt % Tube pitch distance [m]
        np % Number of passes
        bafDSH % Baffle distance, DeSuperHeater [m]
        bafSUB % Baffle distance, Subcooler [m]
    end
    
    methods (Access = public)
        function c = fwh_conf(v,k,de,di,pt,np,bafDSH,bafSUB)
            % Class constructor
            c.v=v;
            c.k=k;
            c.de=de;
            c.di=di;
            c.pt=pt;
            c.np=np;
            c.bafDSH=bafDSH;
            c.bafSUB=bafSUB;
        end
    end
    
end

