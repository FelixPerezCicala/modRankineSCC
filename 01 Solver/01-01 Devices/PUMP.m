classdef PUMP < matlab.mixin.Copyable
    %PUMP Pump class
    %   Pump class calculates pump operation parameters given input and
    %   output pressures, input enthalpy and isentropic performance
    
    properties (Access = public)
        
        P_in % Input flow pressure [bar]
        P_out % Output flow pressure [bar]
        T_in % Input flow temperature [K]
        T_out % Output flow temperature [K]
        h_in % Input flow enthlapy [kJ/kg]
        s_in % Input entropy [kJ/kg·K]
        h_out % Output flow enthlapy [kJ/kg]
        nise % Isentropic performance
        nise_D % Isentropic performance at design conditions
        W_pump % Consumed power [kW]
        m_in % Input mass flow [kg/s]
        m_in_D % Input mass flow at design conditions[kg/s]
        P_out_D % Output pressure at design conditions[bar]
        P_in_D % Input pressure at design conditions[bar]
        
        perf_table % Isentropic performance table
    end
    
    methods (Access = public)
        
        % Constructor
        function p = PUMP(fnise, fperf_table)
            p.nise_D=fnise;
            p.perf_table=fperf_table;
        end
        
        function solv_T(p,fPin,fPout,fTin,fhin,fsin,fmin)
            % Solve output temperature and enthalpy
            p.P_in=fPin;
            p.P_out=fPout;
            p.T_in=fTin;
            p.h_in=fhin;
            p.s_in=fsin;
            p.m_in=fmin;
            
            % Isentropic enthalpy
            h_out_ise=h_pTx_97(p.P_out/10,...
                T_ps_97(p.P_out/10,p.s_in),-1);
            
            % Calculate isentropic performance if design conditions are
            % stored
            if isempty(p.m_in_D)
                p.nise=p.nise_D;
            else
                %                 % Previous method
                %                 e_mo=p.part_load_constant;
                %
                %                 MFR = p.m_in/p.m_in_D; % Mass flow ratio
                %
                %                 A=e_mo+2*(1-e_mo)*MFR-(1-e_mo)*MFR^2;
                %
                %                 p.nise=p.nise_D*A;
                
                nise_offset=p.nise_D-0.8;
                
%                 p.nise=pump_perf(p.m_in, p.m_in_D, p.P_out, p.P_out_D, ...
%                     p.perf_table, nise_offset);

                p.nise=pump_perf(p.m_in, p.m_in_D, p.P_out-p.P_in,...
                    p.P_out_D-p.P_in_D,...
                    p.perf_table, nise_offset);

            end
            
            % Output enthalpy
            p.h_out=p.h_in+(1/p.nise)*...
                (h_out_ise-p.h_in);
            
            % Output temperature
            p.T_out=T_ph_97(p.P_out/10,p.h_out);
        end
        
        function solv_W(p,min)
            % Calculate consumed power
            p.m_in = min;
            
            p.W_pump = p.m_in * (p.h_out-p.h_in);
        end
        
        function save_design(p)
            p.m_in_D = p.m_in;
            p.P_out_D = p.P_out;
            p.P_in_D = p.P_in;
        end
        
    end
    
    
    
end

