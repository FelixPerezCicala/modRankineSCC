classdef COND < matlab.mixin.Copyable
    %COND Condenser object
    %   Calculate condenser presssure depending on maximum and minimum
    %   pressure, and TFR
    
    properties (Access = public)
        % Condenser design and operation
        T_max % Condensing temperature at maximum load [K]
        P_max % Condensing pressure at maximum load [bar]
        T_min % Condensing temperature at minimum load [K]
        P_min % Condensing pressure at minimum load (also floor) [bar]
        TFR_min % TFR value at P_min
        
        % Current operation conditions
        TFR % Current operating TFR
        P % Current operating pressure [bar]
        T % Current operating temperature [K]
        h_out % Current operating output enthalpy
        s_out % Current operating output entropy
    end
    
    properties (Access = public)
        % Linear interpolation parameters
        slope
        T_x0
    end
    
    methods (Access = public)
        function c = COND(fT_max, fT_min, fTFR_min)
            % Class constructor
            c.T_max=fT_max;
            c.T_min=fT_min;
            c.TFR_min=fTFR_min;
            
            % Compute pressures (convert to bar)
            c.P_max = ps_T_97(c.T_max)*10;
            c.P_min = ps_T_97(c.T_min)*10;   
            
            % Linear interpolation parameters
            c.slope = (c.T_max-c.T_min)/(1-c.TFR_min);
            c.T_x0 = c.T_min-c.slope*c.TFR_min;
            
            % Set conditions for TFR=1
            c.solv(1);
            
        end
        
        function solv(c,fTFR)
            % Solve condenser pressure for TFR
            c.TFR=fTFR;
            
            % Pressure is obtained using a linear interpolation. If the TFR
            % value is less than TFR_min, P_min is set as condenser
            % pressure
            if c.TFR<=c.TFR_min
                % Minimum TFR (floor)
                c.P=c.P_min;
                c.T=c.T_min;
            elseif c.TFR>=1
                % Maximum floor (ceiling)
                c.P=c.P_max;
                c.T=c.T_max;
            else
                % Interpolate temperature linearly and recalculate P
                c.T=c.T_x0+c.slope*c.TFR;
                
                c.P=ps_T_97(c.T)*10; % Convert to bar
                
            end
            
            % Calculate output conditions
            c.h_out=h_pTx_97(c.P/10,-1,0);
            c.s_out=s_pTx_97(c.P/10,-1,0);
        end
        
        
    end
    
end

