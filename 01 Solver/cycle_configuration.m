classdef cycle_configuration < handle
    %cycle_configuration Cycle configuration object
    
    properties (Access = public)
        % Cycle stored properties
        W_out_d
        tur_conf
        EX_d
        EX_ploss
        DAEX_ploss
        HTR_ploss
        RHTR_ploss
        FWpmp_nise
        COpmp_nise
        T_HTR_d
        T_RHTR_d
        TTD_d
        DCA_d
        T_con_max
        T_con_min
        TFR_con_min
        fwh_geom_conf
        N_FWH
        N_FWH_HP
        N_FWH_LP
        
        pl_TFR_step
        pl_TFR_min
        tolerance_dev
        tolerance_res
        max_iterations
        dampening_factor
        num_cores
        
        time_to_solve
        iterations_to_solve
    end
    
    methods (Access = public)
        % Constructor
        function c=cycle_configuration()            
        end
        
        % Load a new cycle class object
        function cy = to_cycle(c)
            cy=cycle(c.W_out_d,...
                c.tur_conf,...
                c.EX_d,...
                c.EX_ploss,...
                c.DAEX_ploss,...
                c.HTR_ploss,...
                c.RHTR_ploss,...
                c.FWpmp_nise,...
                c.COpmp_nise,...
                c.T_HTR_d,...
                c.T_RHTR_d,...
                c.TTD_d,...
                c.DCA_d,...
                c.T_con_max,...
                c.T_con_min,...
                c.TFR_con_min,...
                c.fwh_geom_conf);
        end
        
        % Load default values
        function load_defaults(c)
            % Nominal power
            c.W_out_d=305*10^3;
                        
            % Condenser temperature
            c.T_con_max=35+273;
            c.T_con_min=28+273;
            c.TFR_con_min=0.25;
            P_con=ps_T_97(c.T_con_max)*10;
            
            % Number of FWH
            c.N_FWH=6;
            c.N_FWH_HP=2;
            c.N_FWH_LP=4;
            
            % FWH geometries
            v_tubos=3;
            ktubos=15.2;
            de=0.01905;
            di=0.015;
            pt=0.024;
            np=2;
            bafDSH=0.214;
            bafSUB=0.07;
            c.fwh_geom_conf=fwh_conf(v_tubos,ktubos,de,di,pt,np,bafDSH,bafSUB);
            
            % Pressure loss at extraction lines (2%)
            c.EX_ploss=ones(1,c.N_FWH)*0.02;
            c.EX_ploss(6)=0; % No pressure loss for last FWH
            
            % Pressure loss a deareator line (6%)
            c.DAEX_ploss=0.04;
            
            % Pressure loss through heater and reater (10% and 7.14%)
            c.HTR_ploss=0.10;
            c.RHTR_ploss=0.05;
            
            % Turbine configuration
            P_iv=45;
            c.tur_conf={'HP-1ROW','REHEAT-36/18';... % Turbine type
                'BB','BB';... % Leak type (Only BB allowed)
                1.04394,0;... % Pitch diameter (HP Tur only) [m]
                174,P_iv;... % Inlet pressure at design [bar] (before throttle valve/intercept valve)
                P_iv/(1-c.RHTR_ploss),P_con;... % Exhaust pressure at design [bar]
                0.87,0.9193;... % Base isentropic performance
                0,23.012;... % Exhaust annulus area [m2] (IPLP only)
                0.04,0.02;... % Admission pressure loss [%] (Throttle valve loss for HP, IV valve loss for IPLP)
                0,0}; % Baumann factor, recommend 0.7
            
            
            % Pressures at extractions
            P_in=c.tur_conf{4,1};
            P_out=c.tur_conf{5,1};
            
            c.EX_d=[P_in, P_out, P_iv,   26.8,   12,   8,  3.15, 1.12,  0.3, P_con;...
                       1,     0,    2,    0,    3,   0,    0,    0,    0,     4;...
                       1,     1,    2,    2,    2,   2,    2,    2,    2,     2];
            % Design full load intake, exhaust and extraction pressures [bar].
            % The pressures are at turbine casing extraction flanges.
            % A two row matrix, first row containing pressures from HP
            % turbine input to condenser pressure. The second row contains
            % the position markers for reheat and deaerator. The third
            % row marks each turbine body. Example:
            % [180  70   65   40  20   12  7   4   1.5 0.1;
            %  1    0    2    0   3    0   0   0   0   4;
            %  1    1    2    2   2    2   2   2   2   2]
            %  HPIN RHIN IPIN FWH LPIN FWH FWH FWH FWH CON
            %       FWH           DEA
            
            % Pump nominal performance
            c.FWpmp_nise=0.88;
            c.COpmp_nise=0.86;
                        
            % Heater and reheater temperature
            c.T_HTR_d=545+273;
            c.T_RHTR_d=545+273;
            
            % TTD and DCA for each FWH
            c.TTD_d=[-3,0,2,2,2,2];
            c.DCA_d=[5,5,5,5,5,5];
            
            % Steps
            c.pl_TFR_step=0.05;
            c.pl_TFR_min=0.2;
            c.tolerance_dev=1e-8;
            c.tolerance_res=1e-6;
            c.max_iterations=300;
            c.dampening_factor=0.3;
            
        end
        
        function load_default_EX_TTD_EXPloss(c)
            P_con=ps_T_97(c.T_con_max)*10;
            P_in=c.tur_conf{4,1};
            P_out=c.tur_conf{5,1};
            P_iv=c.tur_conf{4,2};
            
            % Pressures at extractions
            c.EX_d=[P_in, P_out, P_iv,   26.8,   12,   8,  3.15, 1.12,  0.3, P_con;...
                       1,     0,    2,    0,    3,   0,    0,    0,    0,     4;...
                       1,     1,    2,    2,    2,   2,    2,    2,    2,     2];
            
            % Number of FWH
            c.N_FWH=6;
            c.N_FWH_HP=2;
            c.N_FWH_LP=4;
            
            % TTD and DCA for each FWH
            c.TTD_d=[-3,0,2,2,2,2];
            c.DCA_d=[5,5,5,5,5,5];
            
            % Pressure loss at extraction lines (2%)
            c.EX_ploss=ones(1,c.N_FWH)*0.02;
            c.EX_ploss(6)=0; % No pressure loss for last FWH
            
            % Pressure loss a deareator line (6%)
            c.DAEX_ploss=0.04;
        end
    end
    
end

