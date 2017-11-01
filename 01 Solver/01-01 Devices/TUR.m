classdef TUR < matlab.mixin.Copyable
    % Turbine object. Used to solve isentropic performance, generated
    % power, pressures at part load, ant conditions along expansion line
    
    properties (Access = public)
        % Results
        % Stage point is defined as input / outputs points of each stage
        x_st % Stage point steam quality
        T_st % Stage point temperature [K]
        W_st % Stage generated shaft power [kW]
        h_st % Stage point enthaply [kJ/kg]
        m_out % Output mass flow [kg/s]
        s_st % Stage point entropy [kJ/kg*K]
        
        W_out % Group generated shaft power [kW]
        W_out_sep % Separated generated shaft power, for reheat type [kW]
        nise % Isentropic performance, calculated as in paper
        nise_st % Isentropic performance per stage
        nise_total % Isentropic performance measured at beggining and end
        nise_d % Design conditions isentropic performance, for HP turbine
        TFR % Throttle flow ratio
        UEEP % Used energy end point [kJ / kg]
        
        % Admision data
        adm_length % Number of points for admission line (3 for HP, 2 for IPLP)
        adm_EX % Vector containing admission pressures [bar]
        adm_h % Admission vector enthaply [kJ/kg]
        adm_T % Admission vector temperature [K]
        adm_s % Admision vector entropy [kJ/kg*K]
        
        % Data
        EX % Vector containing extraction pressures [bar]
        m_EX % Vector containing extraction mass flows [kg/s]. First
        % position must be 0. Vector length is "number of extractions"
        exh_loss % Exhaust loss [kJ / kg]
        T_in % Intake flow temperature [K]
        P_in % Intake flow pressure [bar]
        m_in % Intake mass flow [kg/s]
        h_in % Turbine intake enthalpy
        s_in % Turbine intake entropy
        P_out % presion de salida [bar]
        XO_pos % Cross-over position in EX
        op_mode % Turbine operation mode for part load calculation, a string
        % which can be either 'constant' for constant steam
        % generator pressure operation, or 'sliding' for sliding
        % pressure operation
        adm_PLoss % Admission pressure loss [%]
        
        % Leak flows
        m_Leaks % Structure containing leaks for both turbines
        m_Lks % Vector containing leaks per stage
        m_Lks_d % Vector containing leaks per stage at design conditions
        m_Lks_mid % Leaks mid-turbine
        h_Lks_mid % Enthalpy of said leaks
        m_Lks_to_DA % Mass flow to deareator (HP Turbine only)
        h_1_leak % Leak 1 enthalpy, for IPLP only
        h_B_leak % B Leak enthalpy, for IPLP only
        
        % Design conditios
        m_in_d % Design inlet mass flow [kg/s]
        m_EX_d % Design extraction stage mass flows [kg/s]
        EX_d % Design extraction pressures [bar]
        phi_st_d % Design mass flow coefficient, used for Stodola method
        y_st_d % Design "y" for each stage, used for Stodola method
        
        % Turbine configuration
        turbine_type    % Turbine type for isentropic performance. Options:
        %      - HP-1ROW      -> 3600-rpm NonCondensing 1-row
        %                        governing stage
        %      - HP-2ROW      -> 3600-rpm NonCondensing 2-row
        %                        governing stage
        %      - REHEAT-36    -> 3600-rpm Condensing without
        %                        governing stage
        %      - REHEAT-36/18 -> 3600/1800-rpm Condensing
        %                        without governing stage
        %      - REHEAT-18    -> 1800-rpm Condensing without
        %                        governing stage
        baumann_factor % Baumann factor used for the baumann rule
        leak_type % Turbine leak scheme type. A string containing type and
        % sub type
        num_bod % Number of bodies the turbine is composed of. For example,
        % an IP-LP turbine would have 2 bodies. The turbine is
        % grouped in bodies depending on the type used for the
        % isentropic performance calculation
        N % Number of parallel flow sections at beginning of Expansion
        pitch_diameter % Governing stage pitch diameter [m]
        annulus_area % LP Turbine annulus area at output [m2]
        nise_nom % Nominal isentropic performance
        P_out_D % Exhaust pressure at design flow (nominal) [bar]
        P_in_D % Rated throttle pressure (nominal input pressure) [bar]
        T_in_D % Design flow turbine inlet temperature [K]
        vf_D % Design volume flow at throttle [m3/s]
        
        % Correction values
        corr_nise
        corr_moisture
        
        % Deviation control
        dev_final % Maximum deviation of controled variables
        
    end
    
    properties (Access = private)
        
        % Internal calculation variables
        x_in % Turbine intake steam quality
        
        % Reversible properties (used for output enthalpy calculation)
        T_st_rev
        x_st_rev
        h_st_rev
        
        % Propiedades calculadas
        Tout_rev % temperatura de salida, turbina isentropica (reversible)
        xout_rev % titulo a la salida, turbina isentropica (reversible)
        hout_rev % entalpia a la salida, turbina isentropica (reversible)
        vf % Volume flow
        h_m % Enthalpy corresponding to the resulting conditions of mixing
        % the leakage steam with the steam ahead of the intercept
        % valves (coming out of the reheater) [kJ/kg K]
        s_m % Enthropy corresponding to the resulting conditions of mixing
        % the leakage steam with the steam ahead of the intercept
        % valves (coming out of the reheater) [kJ/kg K]
        h_XO % Available energy at crossover
        
        % Deviation control
        dev_pre % Previous values
        dev_new % New calculated values
        
        % Data used in figs function
        table3
    end
    
    methods (Access = public)
        function t = TUR(fTt,fLt,fN,fpd,fPinD,fPoutD,fmsD,fniseD,...
                fIVpos,fTinD,fannulus,fadmPloss,fBaumann)
            
            % Class constructor, sets turbine caracteristics which do not
            % change between main programa iterations
            
            t.turbine_type=fTt;
            t.leak_type=fLt;
            t.N=fN;
            t.pitch_diameter=fpd;
            t.P_in_D=fPinD;
            t.P_out_D=fPoutD;
            t.m_in=fmsD;
            t.T_in_D=fTinD;
            t.nise_nom=fniseD;
            t.XO_pos=fIVpos;
            t.annulus_area=fannulus;
            t.adm_PLoss=fadmPloss;
            t.baumann_factor=fBaumann;
            
            % Set number of admision points
            if strcmp(t.turbine_type,'HP-1ROW') || strcmp(t.turbine_type,'HP-2ROW')
                t.adm_length=3;
            else
                t.adm_length=2;
            end
            
            % Calculate design volume flow at turbine inlet
            t.vf_D=t.m_in_d*v_pTx_97(t.P_in_D/10,...
                t.T_in_D,-1);
            
            % Set leaks to zero for initial calculation
            t.m_Leaks=struct('vlv_stem',zeros(1,3),'shft_nd',zeros(1,7));
            
            % Set x to -1 for initial calculation
            t.x_st=(-1)*ones(1,100);
            
            t.T_st=zeros(1,length(t.EX));
            
        end
        
        function set(t,fPin,fPOut,fmEX,fTin,fmin,fopmode,fEX)
            % Class setter method, sets turbine operational variables which
            % may vary between iterations
            
            t.m_EX=fmEX;
            t.T_in=fTin;
            t.m_in=fmin;
            t.op_mode=fopmode;
            t.P_in=fPin;
            t.P_out=fPOut;
            
            if nargin==8
                % Store EX pressures (only used in inizialization)
                t.EX=fEX;
            end
            
            % Set output pressure at end of EX vector
            t.EX(end)=t.P_out;
            
            % Compute inlet enthalpy
            t.h_in=h_pTx_97(t.P_in/10,t.T_in,-1);
            
            % Calculate throttle flow ratio
            if ~isempty(t.EX_d)
                t.TFR=t.m_in/t.m_in_d;
            end
            
            % Recalculate input mass flow depending on tubine type
            if strcmp(t.turbine_type,'HP-1ROW') || strcmp(t.turbine_type,'HP-2ROW')
                % HP Turbine gets valve stem leaks substracted
                t.m_in = t.m_in - t.m_Leaks.vlv_stem(1);
                
                % Set mid-turbine leaks mass flow
                t.m_Lks_mid=t.m_Leaks.shft_nd(1);
                
                % Calculate mass flow to deareator
                t.m_Lks_to_DA=t.m_Leaks.shft_nd(3)-t.m_Leaks.shft_nd(4);
                
                % Construct stage leaks vector
                t.m_Lks=zeros(1,length(t.EX));
                
            elseif strcmp(t.turbine_type,'REHEAT-36/18') ...
                    || strcmp(t.turbine_type,'REHEAT-36') ...
                    || strcmp(t.turbine_type,'REHEAT-18')
                
                % Re-compute intake enthalpy, if leaks have been computed
                if ~isempty(t.h_B_leak)
                    t.h_in=(t.m_in*t.h_in+t.m_Leaks.vlv_stem(3)*t.h_B_leak+...
                        t.m_Leaks.shft_nd(1)*t.h_1_leak)/...
                        (t.m_in + t.m_Leaks.vlv_stem(3) + t.m_Leaks.shft_nd(1));
                    
                    % Re-compute inlet temperature
                    t.T_in=T_ph_97(t.P_in/10,t.h_in);
                end
                
                % IP Turbine gets vlv_stem leaks to IP inlet added and
                % mixed with input flow from reheater
                t.m_in = t.m_in + t.m_Leaks.vlv_stem(3) + t.m_Leaks.shft_nd(1);
                
                % Construct stage leaks vector
                t.m_Lks=zeros(1,length(t.EX));
                t.m_Lks(t.XO_pos)=t.m_Leaks.shft_nd(6);
                
                % Set mid-turbine leaks to zero
                t.m_Lks_mid=0;
                t.h_Lks_mid=0;
            end
            
            % Compute inlet entropy
            t.s_in=s_pTx_97(t.P_in/10,t.T_in,-1);
            
        end
        
        function solv(t,mode)
            
            % Save previous values for deviation control
            t.dev_previous();
            
            % Save previous x values for Baumann use
            x_st_prev=t.x_st;
            
            % Per-stage point variables, set to zero
            t.x_st=zeros(1,length(t.EX));
            t.s_st=zeros(1,length(t.EX));
            t.h_st=zeros(1,length(t.EX));
            t.T_st_rev=zeros(1,length(t.EX));
            t.x_st_rev=zeros(1,length(t.EX));
            t.h_st_rev=zeros(1,length(t.EX));
            t.W_st=zeros(1,length(t.EX));
            t.nise_st=zeros(1,length(t.EX));
            t.adm_EX=zeros(1,t.adm_length);
            t.adm_h=zeros(1,t.adm_length);
            t.adm_T=zeros(1,t.adm_length);
            t.adm_s=zeros(1,t.adm_length);
            
            % Construct initial values
            % Stage intake steam quality, -1 for HP / IPLP groups
            t.x_st(1)=-1;
            t.x_in=-1;
            
            % Compute admission properties
            t.adm_EX(1)=t.P_in;
            t.adm_h(1)=t.h_in;
            t.adm_h(2)=t.h_in; % Isentalpic expansion through control valve
            t.adm_T(1)=t.T_in;
            t.adm_s(1)=t.s_in;
            
            % Pressure loss through admission valve
            t.adm_EX(2)=t.P_in*(1-t.adm_PLoss);
            
            % Properties after admission valve
            t.adm_T(2)=T_ph_97(t.adm_EX(2)/10,t.adm_h(2));
            t.adm_s(2)=s_pTx_97(t.adm_EX(2)/10,t.adm_T(2),-1);
            
            % Store inlet temperature after admission
            t.T_st(1)=t.adm_T(2);
            
            % Store inlet entropy after admission
            t.s_st(1)=t.adm_s(2);
            
            % Store intake enthalpy
            t.h_st(1)=t.adm_h(2);
            
            % Calculate partial load pressures if necessary
            if isempty(t.EX_d)==0
                % Use stodola's law to calculate part load pressures
                t.part_pressures();
            else
                % Set stage inlet pressure to pressure after admission
                t.EX(1)=t.adm_EX(2);
            end
            
            % Calculate isentropic performance. In sliding pressure, the
            % design isentropic performance is used
            t.Isen_perf(mode);
            
            % Store design isentropic perfornace for HP Turbine calculation
            % if the mode is set to FLD (Full Load Design), or if the mode
            % is set to sliding pressure
            if strcmp(mode,'FLD') || strcmp(t.op_mode,'sliding')
                t.nise_d=t.nise;
            end
            
            % Solve each turbine stage. Stage input is index "i", output is
            % index "i+1"
            for i=1:(length(t.EX)-1)
                
                % Generage nise_st and apply Baumann correction if necessary,
                % using previous iteration x values
                if x_st_prev(i+1)==-1 % Evaluate wetness at stage exhaust
                    % Use uniform isentropic performance for dry turbine
                    % stages
                    t.nise_st(i+1)=t.nise;
                    
                    % Set nise to t.nise_d if HP Turbine with more than 1
                    % extraction
                    if i>1 && (strcmp(t.turbine_type,'HP-1ROW') || strcmp(t.turbine_type,'HP-2ROW'))
                        t.nise_st(i+1)=t.nise_d;
                    end
                else
                    % Use Baumann rule if the stage exhaust is wet. Note:
                    % Steam wetness is defined as 1-x, the total liquid
                    % per unit of mixture. Mean wetness is used
                    if x_st_prev(i)==-1
                        y_mean=1-(1+x_st_prev(i+1))/2;
                    else
                        y_mean=1-(x_st_prev(i)+x_st_prev(i+1))/2;
                    end
                    
                    t.nise_st(i+1)=t.nise*(1-t.baumann_factor*y_mean);
                end
                
                % Stage exhaust reversible temperature
                t.T_st_rev(i+1)=T_ps_97(t.EX(i+1)/10,t.s_st(i));
                
                % Stage exhaust reversible steam quality
                t.x_st_rev(i+1)=x_ps_97(t.EX(i+1)/10,t.s_st(i));
                
                % Stage exhaust reversible enthalpy
                if t.x_st_rev(i+1)==-1
                    t.h_st_rev(i+1)=h_pTx_97(t.EX(i+1)/10,t.T_st_rev(i+1),...
                        t.x_st_rev(i+1));
                else
                    t.h_st_rev(i+1)=h_pTx_97(t.EX(i+1)/10,-1,...
                        t.x_st_rev(i+1));
                end
                
                % Stage exhaust enthalpy (irreversible)
                t.h_st(i+1)=t.h_st(i)-t.nise_st(i+1)*(t.h_st(i)-t.h_st_rev(i+1));
                
                % Stage exhaust steam quality
                t.x_st(i+1)=x_ph_97(t.EX(i+1)/10,t.h_st(i+1));
                
                % Stage exhaust temperature
                t.T_st(i+1)=T_ph_97(t.EX(i+1)/10,t.h_st(i+1));
                
                % Stage exhaust entropy
                if t.x_st(i+1)==-1
                    t.s_st(i+1)=s_pTx_97(t.EX(i+1)/10,t.T_st(i+1),-1);
                else
                    t.s_st(i+1)=s_pTx_97(t.EX(i+1)/10,-1,t.x_st(i+1));
                end
                
                % Compute liquid fraction if the stage exhaust is wet
                if t.x_st(i+1) ~= -1
                    if t.x_st(i) ~=-1
                        % If the steam is already condensing in previous
                        % stage, calculate average liquid fraction
                        liq_frac = 0.5 * (t.x_st(i)+t.x_st(i+1));
                    else
                        % Calculate mean average liquid fraction using
                        % saturated steam as previous stage liquid fraction
                        liq_frac = 0.5 * (1+t.x_st(i+1));
                    end
                else
                    liq_frac=1;
                end
                
                % Compute nozzle losses for HP Turbine
                if i==1 && (strcmp(t.turbine_type,'HP-1ROW') || strcmp(t.turbine_type,'HP-2ROW'))
                    % Use fzero to find input enthalpy
                    fun=@(hin) t.get_hout_diff(hin,t.EX(i),t.EX(i+1),...
                        t.nise_d,t.h_st(i+1));

%                     %%%%%%%
%                     % Test search for exhaust conditions
%                     res=zeros(1,100);
%                     x=linspace(t.adm_h(2)*1.01,t.h_st(i+1),100);
% 
%                     for p=1:100
%                         res(p)=fun(x(p));
%                     end
%                     %%%%%%%
                    
                    try
                        t.h_st(i)=fzero(fun, [t.adm_h(2)*1.01,t.h_st(i+1)]);
                    catch                                                
                        disp('Error when solving control stage exhaust conditions');
                    end
                                        
                    t.adm_h(3)=t.h_st(i);
                    
                    % Re-Compute governing stage output values
                    % Stage inlet and admission temperature
                    t.T_st(i)=T_ph_97(t.EX(i)/10,t.h_st(i));
                    t.adm_T(3)=t.T_st(i);
                    
                    % Stage inlet and admission entropy
                    t.s_st(i)=s_pTx_97(t.EX(i)/10,t.T_st(i),-1);
                    t.adm_s(3)=t.s_st(i);
                    
                    % Admission exhaust entropy
                    t.adm_EX(3)=t.EX(i);
                    
                    % Admission exhaust title
                    t.x_st(i)=x_ph_97(t.EX(i)/10,t.h_st(i));
                end
                
                % Stage generated shaft power
                t.W_st(i+1)=(t.m_in-sum(t.m_EX(1:i))-sum(t.m_Lks(1:i)))*...
                    liq_frac*(t.h_st(i)-t.h_st(i+1));
                
            end
            
            % Calculate output mass flow, leaks, last stage for LP tur
            if strcmp(t.turbine_type,'HP-1ROW') || strcmp(t.turbine_type,'HP-2ROW')
                % HP Turbine gets shaft end leaks 1, 3 substracted
                t.m_out=t.m_in-sum(t.m_EX)-...
                    t.m_Leaks.shft_nd(1)-...
                    t.m_Leaks.shft_nd(3);
                
                % Calculate mid-turbine leaks enthalpy, as average between
                % inlet and exhaust
                t.h_Lks_mid=(t.h_in+t.h_st(end))/2;
                
                % Asign last enthalpy to UEEP property
                t.UEEP=t.h_st(end);
                
            elseif strcmp(t.turbine_type,'REHEAT-36/18') ...
                    || strcmp(t.turbine_type,'REHEAT-36') ...
                    || strcmp(t.turbine_type,'REHEAT-18')
                % IP Turbine gets shaft end leak 6 substracted
                t.m_out=t.m_in-sum(t.m_EX)-...
                    t.m_Leaks.shft_nd(6);
                
                % Calculate last stage for LP turbine
                % Correction for exhaust pressure
                t.exhaust_presssure_correction();
                
                % Exhaust loss
                t.exhaust_loss();
                
                % Recalculate liquid fraction
                if t.x_st(i) ~=-1
                    % If the steam is already condensing in previous
                    % stage, calculate average liquid fraction
                    liq_frac = 0.5 * (t.x_st(i)+t.x_st(i+1));
                else
                    % Calculate mean average liquid fraction using
                    % saturated steam as previous stage liquid fraction
                    liq_frac = 0.5 * (1+t.x_st(i+1));
                end
                
                % Re-Calculate last stage generated power
                t.W_st(end)=(t.m_in-sum(t.m_EX(1:end))-sum(t.m_Lks(1:end)))*...
                    liq_frac*(t.h_st(end-1)-t.UEEP);
            end
            
            % Calculate total isentropic performance
            x_out_isen=x_ps_97(t.EX(end)/10,t.s_st(1));
            if x_out_isen ~= -1
                h_out_isen=h_pTx_97(t.EX(end)/10,-1,x_out_isen);
            else
                h_out_isen=t.h_st_rev(end);
            end
            
            t.nise_total=(t.h_st(1)-t.UEEP)/(t.h_st(1)-h_out_isen);
            
            % Re-Calculate last stage entropy
            if t.x_st(end)==-1
                t.s_st(end)=s_pTx_97(t.EX(end)/10,t.T_st(end),t.x_st(end));
            else
                t.s_st(end)=s_pTx_97(t.EX(end)/10,-1,t.x_st(end));
            end
            
            % Calculate generated power
            t.W_out=sum(t.W_st);
            
            % Add power generated by mid-turbine leaks
            t.W_out=t.W_out+t.m_Lks_mid*(t.h_st(1)-t.h_Lks_mid);
            
            % Calculate entropy at bowl conditions, if turbine type is IP
            % turbine 'REHEAT-36/18', crossover available energy, and
            % separated shaft power
            if strcmp(t.turbine_type,'REHEAT-36/18') ...
                    || strcmp(t.turbine_type,'REHEAT-36') ...
                    || strcmp(t.turbine_type,'REHEAT-18')
                t.s_m=t.s_st(t.XO_pos);
                t.h_XO=t.h_st(t.XO_pos);
                
                t.W_out_sep=zeros(1,2);
                t.W_out_sep(1)=sum(t.W_st(1:t.XO_pos))+...
                    t.m_Lks_mid*(t.h_in-t.h_Lks_mid);
                
                t.W_out_sep(2)=sum(t.W_st(t.XO_pos+1:end));
            end
            
            % Calculate deviation
            t.dev_calc();
        end
        
        function save_design(t)
            % Save design conditions after full-load calculation
            t.m_in_d=t.m_in + t.m_Leaks.vlv_stem(1);
            t.m_EX_d=t.m_EX;
            t.EX_d=t.EX;
            t.m_Lks_d=t.m_Lks;
            
            % Save design isentropic performance (only used for HP TUR)
            t.nise_d=t.nise_st(2);
            
            % Stodola design conditions, using temperature mass flow
            % coefficient definition
            t.phi_st_d=zeros(1,size(t.EX,2));
            t.y_st_d=zeros(1,size(t.EX,2));
            
            EX_pascal = t.EX.*10^5;
                        
            for i=size(t.EX,2):-1:2
                % Stage input mass flow
                m_st_d=t.m_in_d-sum(t.m_EX_d(1:i-1))-sum(t.m_Lks_d(1:i-1));
                
                % Mass flow coefficient at design conditions
                t.phi_st_d(i)=m_st_d*sqrt(t.T_st(i-1))/EX_pascal(i-1);
                
                % Y at design conditios
                t.y_st_d(i)=(EX_pascal(i-1)^2-EX_pascal(i)^2)/...
                    (EX_pascal(i-1)^2*t.phi_st_d(i)^2);
            end
            
        end
        
        function store_data(t,table3)
            t.table3=table3;
        end
    end
    
    methods (Access = private)
        
        function Isen_perf(t,mode)
            
            % Calculate the turbines isentropic performance using the
            % Spencer-Cotton-Cannon methodology.
            % Apply the necessary steps depending on the turbine type
            
            % Set initial isentropic performance value to nominal value
            t.nise=t.nise_nom;
            
            cuft_cumtr=0.028316846592^-1; % Cubic feet / cubic meter
            
            % Do not calculate part load isentropic performance if mode is
            % set to nominal
            if strcmp(mode,'nominal')
                % Calculate with nominal performance only
                type='none';
                t.nise_d=t.nise;
            elseif strcmp(mode,'FLD')
                % Calculate at full load design, TFR=1
                type=t.turbine_type;
                t.TFR=1;
                t.m_in_d=t.m_in;
                % Calculate design volume flow at turbine inlet
                t.vf_D=t.m_in_d*v_pTx_97(t.P_in_D/10,...
                    t.T_in_D,-1);                
            elseif strcmp(mode,'part')
                % Calculate at part load
                type=t.turbine_type;
            end
            
            % Calculate part load isentropic performance if necessary
            if strcmp(type,'HP-1ROW')
                
                % 1.
                % Efficiency correction for volume flow. Volume flow
                % calculated at turbine steam input, using design
                % mass flow and throttle specific volume
                
                t.vf=t.m_in_d*v_pTx_97(t.P_in_D/10,t.T_in_D,t.x_in);
                corr_1=(1005200/(cuft_cumtr*3600))*t.N/t.vf;
                
                t.nise=t.nise*(1-corr_1/100);
                
                % 2.
                % Efficiency correction for governing Stage. Using Figure 7,
                % with pitch diameter
                corr_2=figs('Fig7',t.pitch_diameter);
                
                % if (corr_2<1e-8); corr_2=0; end
                
                t.nise=t.nise*(1+corr_2/100);
                
                % 3.
                % Efficiency correction for pressure ratio. Using Figure 6,
                % with exhaust pressure at design flow, rated throttle
                % pressure, and design volume flow
                
                corr_3=figs('Fig6',...
                    t.P_out_D/t.P_in_D,...
                    t.vf_D);
                
                t.nise=t.nise*(1+corr_3/100);
                
                % 4.
                % Efficiecy correction for Governing Stage at Part Load.
                % Using Figure 8, with throttle flow ratio and stage pitch
                % diameter
                corr_4=figs('Fig8', t.TFR, t.pitch_diameter);
                
                t.nise=t.nise*(1+corr_4/100);
                
                % 5. Efficiency Correction for Part Load. Using Figure 9,
                % with throttle flow ratio, rated throttle pressure and
                % exhaust pressure at design flow
                
                % This corrections is only applied for constant pressure
                % operation
                corr_5=[];
                if strcmp(t.op_mode,'constant')
                    corr_5=figs('Fig9',...
                        t.TFR,...
                        t.P_in_D/t.P_out_D);
                    
                    t.nise=t.nise*(1+corr_5/100);
                end
                
                % 6.
                % Efficiency Correction for Mean-of-Loops: not implemented
                
                % Store corrections
                t.corr_nise=[-corr_1,corr_2,corr_3,corr_4,corr_5];
                
            elseif strcmp(type,'REHEAT-36/18')
                
                % 1.
                % Efficiency correction for volume flow. Volume flow
                % calculated at turbine steam input
                
                %                 t.vf=t.m_in*v_pTx_97(t.P_in/10,t.T_in,t.x_in);
                %                 corr_1=(1270000/(cuft_cumtr*3600))*t.N/t.vf;
                
                t.vf=t.m_in_d*v_pTx_97(t.P_in_D/10,t.T_in_D,t.x_in);
                corr_1=(1270000/(cuft_cumtr*3600))*t.N/t.vf;
                
                t.nise=t.nise*(1-corr_1/100);
                
                % 2.
                % Efficiency correction for initial conditions. Using
                % Figure 14, with initial pressure, initial enthalpy, and
                % string with options and enthropy
                corr_2=figs('Fig14',...
                    t.P_in,...
                    t.h_in,...
                    t.s_in);
                
                t.nise=t.nise*(1+corr_2/100);
                
                % 3.
                % Efficiency correction for substitution of 1800-rpm Low
                % pressure section. Using available energy from bowl mixed
                % entalpy (IP input, mix of reheat + leakage from HP to
                % IP), available energy from crossover pressure, and
                % enthalpy at Sm and 1.5 in Hg Abs
                P_1_5_inHgAbs=5079.58*10^-5; % 1.5 in Hg Abs, in [bar]
                h_1_5_inHgAbs=h_pTx_97(P_1_5_inHgAbs,...
                    T_ps_97(P_1_5_inHgAbs,t.s_m),...
                    x_ps_97(P_1_5_inHgAbs,t.s_m));
                
                h_Bowl_mix=t.h_in;
                
                corr_3=1.25*(t.h_XO-h_1_5_inHgAbs)/...
                    (h_Bowl_mix-h_1_5_inHgAbs);
                
                t.nise=t.nise*(1+corr_3/100);
                
                % Store corrections
                t.corr_nise=[-corr_1,corr_2,corr_3];
                
            elseif strcmp(type,'HP-2ROW')
                
                % 1.
                % Efficiency correction for volume flow. Volume flow
                % calculated at turbine steam input, using design
                % mass flow and throttle specific volume
                
                t.vf=t.m_in_d*v_pTx_97(t.P_in_D/10,t.T_in_D,t.x_in);
                corr_1=(1350000/(cuft_cumtr*3600))*t.N/t.vf;
                
                t.nise=t.nise*(1-corr_1/100);
                
                % 2.
                % Efficiency correction for pressure ratio. Using Figure 6,
                % with exhaust pressure at design flow, rated throttle
                % pressure, and design volume flow
                
                corr_2=figs('Fig10',...
                    t.P_out_D/t.P_in_D,...
                    t.vf_D);
                
                % if (corr_3<1e-8); corr_3=0; end
                
                t.nise=t.nise*(1+corr_2/100);
                
                % 3. Efficiency Correction for Part Load. Using Figure 9,
                % with throttle flow ratio, rated throttle pressure and
                % exhaust pressure at design flow
                
                % This corrections is only applied for constant pressure
                % operation
                corr_3=[];
                if strcmp(t.op_mode,'constant')
                    corr_3=figs('Fig11',...
                        t.TFR,...
                        t.P_in_D/t.P_out_D);
                    
                    t.nise=t.nise*(1+corr_3/100);
                end
                
                % 6.
                % Efficiency Correction for Mean-of-Loops: not implemented
                
                % Store corrections
                t.corr_nise=[-corr_1,corr_2,corr_3];                                
                
            elseif strcmp(type,'REHEAT-36') || strcmp(type,'REHEAT-18')
                
                % 1.
                % Efficiency correction for volume flow. Volume flow
                % calculated at turbine steam input
                
                t.vf=t.m_in_d*v_pTx_97(t.P_in_D/10,t.T_in_D,t.x_in);
                corr_1=(1270000/(cuft_cumtr*3600))*t.N/t.vf;
                
                t.nise=t.nise*(1-corr_1/100);
                
                % 2.
                % Efficiency correction for initial conditions. Using
                % Figure 14, with initial pressure, initial enthalpy, and
                % string with options and enthropy
                corr_2=figs('Fig14',...
                    t.P_in,...
                    t.h_in,...
                    t.s_in);
                
                t.nise=t.nise*(1+corr_2/100);
                
                % Store corrections
                t.corr_nise=[-corr_1,corr_2];
            end
            
        end
        
        function exhaust_loss(t)
            % Calculate exhaust loss for the LP Turbine
            
            % Calculate exhaust velocity
            v_exh = t.m_out * v_pTx_97(t.EX(end)/10,-1,t.x_st(end))/...
                t.annulus_area;
            
            Y_steam = 1 - t.x_st(end);
            
            % Remove condensation effect on velocity
            v_exh = v_exh * (1 - Y_steam);
            
            % Select configuration
            switch t.annulus_area
                case 17.7
                    conf = 1;
                case 19.67
                    conf = 2;
                case 23.01
                    conf = 2;
                otherwise
                    conf = 3;
            end
            
            % Calculate exhaust loss using Fig17
            t.exh_loss = figs('Fig17',v_exh,conf, t.table3);
            
            % Calculate UEEP using Fig17 formula
            t.UEEP = t.h_st(end) + t.exh_loss*0.87*...
                (1-Y_steam)*(1-0.65*Y_steam);
            
        end
        
        function part_pressures(t)
            % Calculate part load operation pressures according to
            % Stodola's law
            
            for i=size(t.EX,2):-1:2
                % Stodola's method, using temperature mass flow coefficient definition
                
                % Stage input mass flow
                m_st=t.m_in-sum(t.m_EX(1:i-1))-sum(t.m_Lks(1:i-1));
                
                % New stage inlet (total) pressure
                p_in_new = sqrt(m_st^2*t.T_st(i-1)*t.y_st_d(i)+(t.EX(1,i)*10^5)^2);
                
                % Store inlet pressure
                t.EX(1,i-1) = p_in_new/10^5; % Convert to bar
            end
        end
        
        function exhaust_presssure_correction(t)
            % Correction for IPLP turbines. Correct expansion line end point
            % for exhaust pressure
            
            % Steps: compute expansion line end point at 1.5 in Hg
            % (0.0507958 bar), apply correction using figure 15 to actual
            % exhaust pressure, recompute generated power
            
            non_corrected_pressure=0.0507958; % [bar]
            
            % Expansion line end point at 1.5 in Hg
            % Reversible temperature and entalpy to 1.5 in Hg
            x_out_nc=x_ps_97(non_corrected_pressure/10,t.s_st(end-1));
            h_out_nc=h_pTx_97(non_corrected_pressure/10,-1,x_out_nc);
            
            t.h_st(end)=t.h_st(end-1)-t.nise_st(end)*(t.h_st(end-1)-h_out_nc);
            
            % Moisture at expansion line end point 1.5 in Hg
            y_non_corrected=1-x_ph_97(non_corrected_pressure/10,t.h_st(end));
            
            % Apply correction according to Fig 15
            corr_fig=figs('Fig15',t.EX(end));
            
            corr=corr_fig*0.87*(1-y_non_corrected)*(1-0.65*y_non_corrected);
            
            t.h_st(end)=t.h_st(end)+corr;
            
            % Store value
            t.corr_moisture=corr;
            
            % Recalculate exhaust temperature and title
            % Stage exhaust steam quality
            t.x_st(end)=x_ph_97(t.EX(end)/10,t.h_st(end));
            
            % Stage exhaust temperature
            t.T_st(end)=T_ph_97(t.EX(end)/10,t.h_st(end));
            
            
        end
        
        function h_diff=get_hout_diff(~,h_in,p_in,p_out,eta_isen,h_out_R)
            % Calculate output enthalpy for given conditions
            t_in=T_ph_97(p_in/10,h_in);
            s_inf=s_pTx_97(p_in/10,t_in,-1);
            t_out_s=T_ps_97(p_out/10,s_inf);
            
            % Check for exhaust title
            x_out_s=x_ps_97(p_out/10,s_inf);
            
            if x_out_s==-1
                % Ideal Exhaust is dry
                h_out_s=h_pTx_97(p_out/10,t_out_s,-1);
            else
                % Ideal Exhaust is wet
                h_out_s=h_pTx_97(p_out/10,-1,x_out_s);
            end
            
            % Calculate output enthalpy
            h_out=h_in-eta_isen*(h_in-h_out_s);
            
            h_diff=h_out-h_out_R;
        end
        
        function dev_previous(t)
            % Save previous values (stored at execution)
            t.dev_pre=[t.x_st';...
                t.T_st';...
                t.W_st(2:end)';...
                t.h_st';...
                t.m_out;...
                t.W_out;...
                t.nise;...
                t.TFR;...
                t.m_in_d;...
                t.EX(1,:)'];
            
            for i=1:size(t.dev_pre,1)
                % Remove zeros
                if t.dev_pre(i)==0
                    t.dev_pre(i)=1;
                end
            end
        end
        
        function dev_calc(t)
            % Calculate deviation values after calculation of bleed mass
            t.dev_new=[t.x_st';...
                t.T_st';...
                t.W_st(2:end)';...
                t.h_st';...
                t.m_out;...
                t.W_out;...
                t.nise;...
                t.TFR;...
                t.m_in_d;...
                t.EX(1,:)'];
            
            if size(t.dev_new,1)~=size(t.dev_pre,1)
                t.dev_pre=ones(size(t.dev_new,1),1);
            end
            
            t.dev_final=abs((t.dev_new-t.dev_pre)./t.dev_new);                        
            t.dev_final=max(t.dev_final);
        end
        
    end
    
end