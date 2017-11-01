function [m_leak] = leakage(tur_HP, tur_IP)
%leakage Calculate 
%   Given hte HP turbine and the IP turbine, calculate the mass flows
%   leaking from each of them

% Outputs structure. "vlv_stem" stands for valve stem leakages, and
% "shft_nd" stands for shaft end packings. Mass flow in [kg/s]
% "shfT_nd" is a vector containg the mass flow of each leak. Columns 1-7
% correspond to leaks numbered from 1 to 7 in Table II of
% the paper, shaft end packings leaks.
% "vlv_stem" is a vector containg the valve stem leakges. Columns 1-3
% correspond to total flow, leaks A and B respectively
m_leak=struct('vlv_stem',zeros(1,3),'shft_nd',zeros(1,7));

% Pressures vector. Each column corresponds with the
% pressure of the respective leak. [bar]
leak_pressure=zeros(1,7);

% Specific volumes vector. Each column corresponds with the
% pressure of the respective leak. [bar]
spec_volume=zeros(1,7);

% Each turbine type has a different definition
switch tur_HP.leak_type(1)
    case 'B'
        
        % Valve stem leakage, A leak temperature, calculated using IP
        % turbine input pressure and HP turbine input enthalpy
        vsl_T_A=T_ph_97(tur_IP.P_in/10, tur_HP.h_in);
        
        % Valve stem leakage, A leak specific volume
        vsl_v_x=x_ph_97(tur_IP.P_in/10, tur_HP.h_in);
        if vsl_v_x==-1
            vsl_v_A=v_pTx_97(tur_IP.P_in/10, vsl_T_A, -1);
        else
            vsl_v_A=v_pTx_97(tur_IP.P_in/10, -1, vsl_v_x);
        end
        
        % Valve stem leakage, total flow specific volume
        vsl_v_TF=v_pTx_97(tur_HP.P_in/10, tur_HP.T_in,-1);
                
        % Leakage 1 pressure [bar]
        P_leak_1=(tur_HP.P_out+tur_HP.P_in)/2;
        
        % Leakage 1 temperature [K], calculated aproximating leak entropy
        % is equal to input entropy after throttle valve and governing
        % stage
        T_leak_1=T_ps_97(P_leak_1/10,tur_HP.s_st(1));
        x1=x_ps_97(P_leak_1/10,tur_HP.s_st(1));
        
        % Leakage 3 Temperature, calculated using HP turbine output
        % enthalpy
        T_leak_3=T_ph_97(tur_HP.P_out/10,tur_HP.h_st(end));
        x3=x_ph_97(tur_HP.P_out/10,tur_HP.h_st(end));
        
        % Leakage 4 Temperature, calculated using HP turbine output
        % enthalpy and IP turbine output pressure
        T_leak_4=T_ph_97(tur_IP.EX(tur_IP.XO_pos)/10,tur_HP.h_st(end));
        x4=x_ph_97(tur_IP.EX(tur_IP.XO_pos)/10,tur_HP.h_st(end));
        
        % Leakage 6 Temperature, calculated using IP turbine output
        % enthalpy and IP turbine output pressure
        T_leak_6=T_ph_97(tur_IP.EX(tur_IP.XO_pos)/10,tur_IP.h_st(tur_IP.XO_pos));
        x6=x_ph_97(tur_IP.EX(tur_IP.XO_pos)/10,tur_IP.h_st(tur_IP.XO_pos));
        
        % Set pressures
        leak_pressure(1)=P_leak_1;
        leak_pressure(2)=tur_HP.P_out;
        leak_pressure(3)=tur_HP.P_out;
        leak_pressure(4)=tur_IP.EX(tur_IP.XO_pos);
        leak_pressure(5)=0;
        leak_pressure(6)=tur_IP.EX(tur_IP.XO_pos);
        leak_pressure(7)=0;
        
        % Set specific volumes, checking for title
        if x1==-1
            spec_volume(1)=v_pTx_97(P_leak_1/10, T_leak_1, -1);
        else
            spec_volume(1)=v_pTx_97(P_leak_1/10, -1, x1);
        end
        
        spec_volume(2)=0;
        
        if x3==-1
            spec_volume(3)=v_pTx_97(tur_HP.P_out/10, T_leak_3, -1);
        else
            spec_volume(3)=v_pTx_97(tur_HP.P_out/10, -1, x3);
        end
        
        if x4==-1
            spec_volume(4)=v_pTx_97(tur_IP.P_out/10, T_leak_4, -1);
        else
            spec_volume(4)=v_pTx_97(tur_IP.P_out/10, -1, x4);
        end
        
        spec_volume(5)=1;
        
        if x6==-1
            spec_volume(6)=v_pTx_97(tur_IP.P_out/10, T_leak_6, -1);
        else
            spec_volume(6)=v_pTx_97(tur_IP.P_out/10, -1, x6);
        end
        
        spec_volume(7)=1;
end

% Unit conversions
psi_bar=14.503773773; % psi / bar
ft3_lb_m3_kg=16.01846353; % (ft3/lb)/(m3/kg)
kg_s_lb_hr=0.0001259979; % (kg/s)/(lb/hr)

% Get C constant values
[C_VSLO, C_PACK]=c_coef(tur_HP.leak_type);

% Calculate mass flows
m_leak.vlv_stem(1)=C_VSLO(1)*...
    sqrt(tur_HP.P_out*psi_bar/(vsl_v_TF*ft3_lb_m3_kg))*kg_s_lb_hr;
m_leak.vlv_stem(2)=C_VSLO(2)*...
    sqrt(tur_IP.P_in*psi_bar/(vsl_v_A*ft3_lb_m3_kg))*kg_s_lb_hr;
m_leak.vlv_stem(3)=m_leak.vlv_stem(1)-m_leak.vlv_stem(2);

m_leak.shft_nd=C_PACK.*...
    sqrt(leak_pressure*psi_bar./(spec_volume*ft3_lb_m3_kg))*kg_s_lb_hr;

% Store leak 1 enthalpy in tur_IP object, and leak B enthalpy
tur_IP.h_1_leak=h_pTx_97(P_leak_1/10,T_leak_1,-1);

% Estimate B enthalpy as enthalpy at HP Turbine inlet
tur_IP.h_B_leak=tur_HP.h_in;

end

