classdef cycle < matlab.mixin.Copyable
    %CYCLE Cycle class provides the framework for cycle properties storage
    %and iteration methods
    %   Detailed explanation goes here
    
    properties (Access=public)
        
        %%% Design characteristics
        W_out_d % Nominal plant full load output power [kW]
        tur_conf % Turbine configuration. A seven-row, two or three columns
        % string cell containing in each row:
        % 1- The turbine type (for isentropic performance)
        % 2- Leak type
        % 3- Turbine pitch diameter [m] (HP tur only)
        % 4- Turbine input pressure at design load [bar]
        % 5- Turbine output pressure at design load [bar]
        % 6- Nominal isentropic performance
        % 7- LP Turbine last stage annulus area [m2]
        % 5- Turbine output pressure at design load [bar]
        % 6- Nominal isentropic performance
        % 7- LP Turbine last stage annulus area [m2]
        % 8- Admission pressure loss [%] (Throttle valve loss for HP, IV valve loss for IPLP)
        % 9- Baumann factor
        EX_d % Design full load intake, exhaust and extraction pressures [bar].
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
        % The pressure loss through the reheater is calculated
        EX % Partial load pressures [bar]. Same structure as EX_d
        T_HTR_d % Design full load heater output temperature [K]
        T_RHTR_d % Design full load reheater output temperature [K]
        EX_ploss % Pressure loss of steam through each extraction and
        % FWH case flange, as a percentage of initial pressure.
        % First postion is HP FWH
        DAEX_ploss % Deareator extraction pressure loss
        HTR_ploss % Pressure loss of feedwater through main heater, as a
        % percentage of initial pressure.
        RHTR_ploss % Pressure loss of steam through reheater, as a
        % percentage of initial pressure.
        FWpmp_nise % Feedwater pump isentropic performance
        COpmp_nise % Condensate pump isentropic performance
        N_FWH % Number of feed water heaters
        N_FWH_HP % Number of high-pressure feed water heaters
        N_FWH_LP % Number of low-pressure feed water heaters
        TTD_d % FWH Terminal Temperature Difference vector
        DCA_d % FWH Drain cooler approach vector
        T_con_max % Maximum condenser temperature (TFR=1) [K]
        T_con_min % Minimum condenser temperature (TFR=TFR_min)
        TFR_con_min % Minimum TFR for condenser at T_con_min
        fwh_geom_conf % FWH geometric configuration. fwh_conf class object
        
        %%% Devices
        tur % Cell containing TUR-class objects. Last postion is HP FWH
        fwh % Cell containing FWH-class objects. Last postion is HP FWH
        fw_pmp % Feedwater pump object
        co_pmp % Condensate pump object
        con % Condenser object
        
        %%% Variables - Problem defining
        target_W_out % Cycle output power (target) [kW]
        P_HTR % Heater steam output pressure [bar]. At design, equal to EX_d
        T_HTR % Heater steam output temperature [K]
        T_RHTR % Reheater steam output temperature [K]
        
        %%% Variables
        mode_op % Mode of operation (sliding or constant pressure)
        W_out=1 % Cycle output power [kW]
        W_out_tur=1 % Cycle output power (turbines only) [kW]
        m_fw % Feedwater maximum mass flow [kg/s]
        m_FWLP % Feedwater maximum mass flow, through low pressure circuit [kg/s]
        n_cycle % Rankine cycle performance
        heatrate % Rankine cycle heat rate
        Q_SG % Heat transfered in steam generator [kW]
        Q_HTR % Heat transfered in steam generator, from ECO to SUPERHTR [kW]
        Q_RHTR % Heat transfered in steam generator, in reheater [kW]
        m_HTR_d % Full load cycle mass flow [kg/s]
        P_FWpmp % Feedwater pump output pressure [bar]
        P_COpmp % Condenser pump output pressure [bar]
        T_DA_out % Deareator output temperature [K]
        h_DA_out % Deareator output enthalpy [kJ/kj]
        s_DA_out % Deareator output entropy [kJ/kj*K]
        m_DA_ex % Deareator steam extraction mass flow [kg/s]
        h_DAex % Deareator steam extraction enthalpy [kJ/kj]
        mex_pl % Part load extraction mass flows [kg/s]
        bypass % FWH bypass vector
        T_HPtur_in % HP Turbine inlet temperature
        
        % Deareator mix (leaks to DA + DA extraction)
        h_DA_mix
        T_DA_mix
        m_DA_mix
        
        % Iteration control
        tolerance_dev % Deviation tolerance
        tolerance_res % Residuals tolerance
        max_iterations % Maximum iterations allowed for part load
        
        dev_d % Deviation for full load solution
        res_d % Residuals for full load solution
        dev_pl % Deviation for part load solution
        res_pl % Residuals for part load solution
        dev_pl_his % Deviation for part load solution (all values)
        res_pl_his % Residuals for part load solution (all values)
        iter_d % Number of iterations for design soltion
        iter_pl % Number of iterions for part load solution
        
        % Solution control
        auto_bypass_DCA % Auto-bypass activated if this proprty is > 0
        % Maximum DCA value accepted
        auto_bypass_TTD % Auto-bypass min TTD value accepted
        min_hit_count % Number of times the minimum Drain approach set by
        % the auto bypass value must be exceeded in order to
        % enable the bypass for the FWH
        hit_count_DCA % Counter for hits for each FWH
        hit_count_TTD % Counter for hits for each FWH
        enable_auto_last_FWH % Enable auto bypass for last FWH
        
        
    end
    
    properties (Access=private)
        deair_pos % Deareator position
        
        % Data
        exhaust_loss_table % Exhaust loss data table for turbine isentropic
        % performance calculation
        pump_isen_perf_table % Table for pump isentropic performance calculation
        figs_table3 % Table 3, used for figs operation
        
        % Part load calculations
        indp
        enth
        
    end
    
    methods (Access=public)
        
        % Constructor
        function c = cycle(fWoutd,fturconf,fEXd,fEXploss,fDAEXploss,fHTRloss,...
                fRHTRloss,fFWpmpnise,fCOpmpnise,fTHTRd,fTRHTRd,...
                fTTD,fDCA,fTcon,fTcon_min,fTFR_con_min,fwhconf)
            
            % Set non-variable values
            c.W_out_d=fWoutd; % Nominal plant full load output power [kW]
            c.tur_conf=fturconf; % Turbine configuration
            c.EX_d=fEXd; % Design full load intake, exhaust and extraction pressures [bar].
            c.EX_ploss=fEXploss; % Pressure loss of steam through each extraction
            c.DAEX_ploss=fDAEXploss; % Deareator extraction pressure loss
            c.HTR_ploss=fHTRloss; % Pressure loss of feedwater through main heater
            c.RHTR_ploss=fRHTRloss; % Pressure loss of steam through reheater
            c.FWpmp_nise=fFWpmpnise; % Feedwater pump isentropic performance
            c.COpmp_nise=fCOpmpnise; % Condensate pump isentropic performance
            c.T_HTR_d=fTHTRd; % Design full load heater output temperature [K]
            c.T_RHTR_d=fTRHTRd; % Design full load reheater output temperature [K]
            c.TTD_d=fTTD; % FWH Terminal Temperature Difference vector
            c.DCA_d=fDCA; % FWH Drain cooler approach vector
            c.T_con_max=fTcon; % Maximum condenser temperature (TFR=1) [K]
            c.T_con_min=fTcon_min; % Minimum condenser temperature (TFR=TFR_min)
            c.TFR_con_min=fTFR_con_min; % Minimum TFR for condenser at T_con_min
            c.fwh_geom_conf=fwhconf; % FWH geometric configuration. fwh_conf class object
            
        end
        
        % Data tables setter
        function store_tables(c,fpmptable, ffigs_table3)
            c.pump_isen_perf_table=fpmptable;
            c.figs_table3=ffigs_table3;
        end
        
        % Initialiaze
        function ini(c)
            
            % Number of FWHs
            c.N_FWH=sum(c.EX_d(2,:) == 0);
            
            % Create cell arrays
            c.tur=cell(size(c.tur_conf,2),1);
            c.fwh=cell(c.N_FWH,1);
            
            % Count number of HP FWHs and LP FWHs
            for i=1:length(c.EX_d)
                if(c.EX_d(2,i)==3)
                    c.deair_pos=i;
                end
            end
            
            c.N_FWH_HP=sum(c.EX_d(2,1:c.deair_pos)==0);
            c.N_FWH_LP=sum(c.EX_d(2,c.deair_pos:end)==0);
            
            % Construct FWHs
            for i=1:c.N_FWH
                c.fwh{i}=FWH(c.fwh_geom_conf,i);
            end
            
            % Construct turbines and calculate extraction enthlapy at
            % nominal isentropic performance. Set feedwater mass to 0
            % for initial extraction enthalpy calculation
            tur_Tin=[c.T_HTR_d,c.T_RHTR_d];
            for i=1:size(c.tur_conf,2)
                
                m_EX=zeros(1,length(c.EX_d(1,c.EX_d(3,:)==i))-1);
                
                c.tur{i}=TUR(c.tur_conf{1,i},c.tur_conf{2,i},...
                    1,c.tur_conf{3,i},c.tur_conf{4,i},c.tur_conf{5,i},...
                    0,c.tur_conf{6,i},...
                    find(c.EX_d(2,:)==3)-length(find(c.EX_d(3,:)==1)),...
                    tur_Tin(i), c.tur_conf{7,i}, c.tur_conf{8,i},...
                    c.tur_conf{9,i});
                
                pressure=c.EX_d(1,c.EX_d(3,:)==i);
                
                c.tur{i}.set(pressure(1),pressure(2),...
                    m_EX,tur_Tin(i),0,'',pressure);
                
                c.tur{i}.store_data(c.figs_table3);
                
                % Solve in nominal mode
                c.tur{i}.solv('nominal');
            end
            
            % Construct pump objects
            c.fw_pmp=PUMP(c.FWpmp_nise,c.pump_isen_perf_table);
            c.co_pmp=PUMP(c.COpmp_nise,c.pump_isen_perf_table);
            
            % Construct condenser object
            c.con=COND(c.T_con_max,c.T_con_min,c.TFR_con_min);
            
            % Calculate full-load design
            c.solv('FLD',c.W_out_d,c.EX_d(1,1),c.T_HTR_d,c.T_RHTR_d,...
                c.TTD_d,c.DCA_d,...
                100,10^-8,10^-8);
            
            % Save FWH design conditions, and dimension the FWHs
            for i=1:c.N_FWH
                c.fwh{i}.solv_UA_d();
            end
            
            % Save turbine design conditions
            for i=1:size(c.tur_conf,2)
                c.tur{i}.save_design;
            end
            
            % Save pump design conditions
            c.fw_pmp.save_design;
            c.co_pmp.save_design;
            
        end
        
        % Solve cycle for part load conditions, given mass flow through
        % steam generator
        function solv_PL(c, fm_fw, bypass, fautoB_DCA, fautoB_TTD, ...
                min_bypass_hit, fen_lastFWH,...
                mode, max_it, tol_dev, ...
                tol_res, draw, dmp_f)
            % Solve part load cycle por m_in and P_HTR, with max_it
            % maximum number of iteraions, tol_dev desviation tolerance and
            % tol_res residuals tolerance.
            % mode:
            %       -> 'sliding' if sliding pressure
            %       -> 'constant' if constant pressure, uses design heater
            %       pressure
            
            % Reset cycle to initial conditions if m_fw is different from
            % design conditions mass flow
            if c.m_fw~=c.m_HTR_d
                c.ini();
            end
            
            if draw==2
                fprintf('Solving mass flow %.2f kg/s for %s pressure\n',fm_fw,mode);
            end
            
            % Store tolerances
            c.tolerance_dev=tol_dev;
            c.tolerance_res=tol_res;
            c.max_iterations=max_it;
            
            % Store auto bypass
            c.auto_bypass_DCA=fautoB_DCA;
            c.auto_bypass_TTD=fautoB_TTD;
            c.min_hit_count=min_bypass_hit;
            c.hit_count_DCA=zeros(1,c.N_FWH);
            c.hit_count_TTD=zeros(1,c.N_FWH);
            c.enable_auto_last_FWH=fen_lastFWH;
            
            % Store mode of operation
            c.mode_op=mode;
            
            % Set up heater temperature
            c.T_HTR=c.T_HTR_d;
            c.T_HPtur_in=c.T_HTR_d;
            
            % Store feedwater max mass flow
            c.m_fw=fm_fw;
            
            % Construct enthalpies matrix and independent terms vector
            c.indp=zeros(c.N_FWH+1,1);
            c.enth=zeros(c.N_FWH+1);
            c.mex_pl=zeros(c.N_FWH+1,1);
            
            % Draw section
            if draw==1
                f=figure('Name','Deviation and Residuals');
                f.Pointer='watch';
                ax1=subplot(2,1,1);
                ax2=subplot(2,1,2);
            end
            
            % Set bypass status
            c.bypass=bypass;
            for i=1:c.N_FWH
                c.fwh{i}.bypass=bypass(i);
            end
            
            % Calculate condenser operation
            c.con.solv(c.m_fw/c.m_HTR_d);
            
            % Set condenser pressure in EX storage
            c.EX(1,end)=c.con.P;
            
            % Set turbine inlet temperature to default
            c.T_HPtur_in=c.T_HTR_d;
            
            % Iteration control
            dev=1;
            res=1;
            cont=1;
            c.dev_pl_his=zeros(1,max_it+1);
            c.res_pl_his=zeros(1,max_it+1);
            
            i=1;
            
            % Build new enth and indp
            c.build_enth_indp(fm_fw);
            
            while (i<max_it) && ((dev>=tol_dev) || (res>=tol_res) || (cont==1))
                % Iterate, no dampening factor
                % [dev, res]=c.iterate_PL(fm_fw, P_heater);
                
                % Iterate, dampening factor
                [dev, res, cont]=c.iterate_PL_dampening(fm_fw, dmp_f);
                
                if draw==0 || draw==1
                    fprintf('\tPL Iter = %d\n\tDev = %.15f\n\tRes = %.15f\n',...
                        i,dev,res);
                end
                
                % Store deviation and residuals
                c.dev_pl_his(i)=dev;
                c.res_pl_his(i)=res;
                
                % Draw section
                if draw==1
                    dev_reg=c.dev_pl_his(1:i);
                    res_reg=c.res_pl_his(1:i);
                    
                    semilogy(ax1,1:i,dev_reg,'b-o',...
                        [1,length(dev_reg)],[1,1]*tol_dev,'r');
                    text(ax1,2,tol_dev,'Tolerance',...
                        'VerticalAlignment','bottom');
                    
                    semilogy(ax2,1:i,res_reg,'b-o',...
                        [1,length(res_reg)],[1,1]*tol_res,'r');
                    text(ax2,2,tol_res,'Tolerance',...
                        'VerticalAlignment','bottom');
                    
                    ylabel(ax1,'Deviation');
                    ylabel(ax2,'Residuals');
                    xlabel(ax2,'Iteration');
                    ax1.XLim=[1,length(dev_reg)+0.01];
                    ax2.XLim=[1,length(res_reg)+0.01];
                    drawnow;
                end
                
                % Next i
                i=i+1;
            end
            
            % Store deviation, residuals and iteration
            c.dev_pl=dev;
            c.res_pl=res;
            c.iter_pl=i;
            
            % Reset figure pointer
            f.Pointer='arrow';
            
            % Calculate deareator mix conditions
            c.m_DA_mix=c.m_DA_ex+c.tur{1}.m_Lks_to_DA;
            c.h_DA_mix=(c.h_DAex*c.m_DA_ex+...
                c.tur{1}.h_st(end)*c.tur{1}.m_Lks_to_DA)...
                /c.m_DA_mix;
            c.T_DA_mix=T_ph_97(c.P_COpmp/10,c.h_DA_mix);
            
            % Store steam generator operating pressure
            if strcmp(c.mode_op, 'sliding')
                c.P_HTR=c.EX(1,1);
            else
                c.P_HTR=c.EX_d(1,1);
            end
            
            % Calculate turbine power output
            c.W_out_tur=c.tur{1}.W_out+c.tur{2}.W_out;
            
            % Calculate pump consumed power
            c.fw_pmp.solv_W(c.m_fw);
            c.co_pmp.solv_W(c.m_FWLP);
            
            % Calculate total cycle output power
            c.W_out=c.W_out_tur-c.fw_pmp.W_pump-c.co_pmp.W_pump;
            
            % Calculate cycle heat rate
            % Heat transfered to steam in steam generator
            if strcmp(c.mode_op,'sliding')
                h_out=c.tur{1}.h_st(1);
            else
                h_out=h_pTx_97(c.EX_d(1,1)/10,c.T_HTR,-1);
            end
            
            c.Q_HTR=c.m_fw*(h_out-c.fwh{1}.h_Cout);
            
            c.Q_RHTR=c.tur{2}.m_in*(c.tur{2}.h_st(1)-c.tur{1}.h_st(end));
            c.Q_SG=c.Q_HTR + c.Q_RHTR;
            
            c.n_cycle=c.W_out/c.Q_SG;
            c.heatrate=1/c.n_cycle;
            
        end
        
    end
    
    methods (Access=private)
        
        % Solve the cycle for HTR conditions or desired output power
        function solv(c,mode,fWout,fPHTR,fTHTR,fTRHTR,TTD,DCA,...
                max_it,tol_dev,tol_res)
            
            % Solve cycle with tol_des (tolerance for between-iterations
            % maximum relative value deviation) and tol_res (tolerance
            % for maximum residual value), in a maximum number of iterations
            % max_it. If calculating for target power, tol_W is the
            % tolerance for difference between calculated and target.
            
            % Set variable values
            c.target_W_out=fWout;
            c.P_HTR=fPHTR;
            c.T_HTR=fTHTR;
            c.T_RHTR=fTRHTR;
            
            % Calculate feedwater pump output pressure
            c.P_FWpmp=c.P_HTR/(1-c.HTR_ploss);
            
            % CALCULATE c.EX
            if (mode=='FLD')
                c.EX=c.EX_d;
            end
            
            % Calculate condensate pump output pressure, equal to deareator
            % extraction pressure
            c.P_COpmp=c.EX(1,c.deair_pos)*(1-c.DAEX_ploss);
            
            % Calculate extraction enthalpies, coming from previous
            % iteration. Use nominal isentropic performance if calculating
            % FLD mode (first execution), use design h_ex for every other
            % case
            if (mode=='FLD')
                ex_pos=find(c.EX(2,:)==0);
                h_ex=[c.tur{1}.h_st,c.tur{2}.h_st];
                h_DA_ex=h_ex(c.EX(2,:)==3);
                h_ex=h_ex(ex_pos);
            else
                h_ex=c.h_ex_d;
                h_DA_ex=c.h_DA_ex_d;
            end
            
            % Set initial try m_HTR
            m_HTR=100;
            
            % Set deviation and residuals
            dev=1;
            res=1;
            
            % Main iterating loop
            i=1;
            
            while (i<max_it) && ((dev>=tol_dev) || (res>=tol_res))
                % Iterate
                [h_ex, h_DA_ex, dev, res]=c.iterate(mode,...
                    m_HTR,h_ex,h_DA_ex,TTD,DCA);
                
                % Calculate new m_HTR
                m_HTR=m_HTR*c.target_W_out/c.W_out;
                                
                % Next i
                i=i+1;
            end
            
            % Store deviation, residuals and iteration
            c.dev_d=dev;
            c.res_d=res;
            c.iter_d=i;
            
            % Store mass flow
            c.m_HTR_d=m_HTR;
            c.m_fw=m_HTR;
            
            % Store deareator extraction enthalpy, and calculate deareator
            % mix conditions
            c.h_DAex=h_DA_ex;
            c.m_DA_mix=c.m_DA_ex+c.tur{1}.m_Lks_to_DA;
            c.h_DA_mix=(c.h_DAex*c.m_DA_ex+...
                c.tur{1}.h_st(end)*c.tur{1}.m_Lks_to_DA)...
                /c.m_DA_mix;
            c.T_DA_mix=T_ph_97(c.P_COpmp/10,c.h_DA_mix);
            
            % Store heater pressure
            c.P_HTR=c.EX_d(1,1);
            
            % Store pressures in c.EX
            c.EX=c.EX_d;
            
            % Calculate turbine power output
            c.W_out_tur=c.tur{1}.W_out+c.tur{2}.W_out;
            
            % Calculate pump consumed power
            c.fw_pmp.solv_W(c.m_fw);
            c.co_pmp.solv_W(c.m_FWLP);
            
            % Calculate total cycle output power
            c.W_out=c.W_out_tur-c.fw_pmp.W_pump-c.co_pmp.W_pump;
            
            % Calculate cycle heat rate
            % Heat transfered to steam in steam generator
            h_out=c.tur{1}.h_in;
            
            c.Q_HTR=c.m_fw*(h_out-c.fwh{1}.h_Cout);
            c.Q_RHTR=c.tur{2}.m_in*(c.tur{2}.h_in-c.tur{1}.h_st(end));
            c.Q_SG=c.Q_HTR + c.Q_RHTR;
            
            c.n_cycle=c.W_out/c.Q_SG;
            c.heatrate=1/c.n_cycle;
        end
        
        % Iterator for design conditions calculation
        function [h_ex_out, h_DA_ex_out, dev, res] = iterate(c,...
                tur_mode,m_HTR,h_ex,h_DA_ex,TTD,DCA)
            
            % Perform an iteration. Objective is to calculate generated
            % electrical power
            
            % tur_mode is 'FLD' for full load design, or 'part' for part
            % load
            
            % Calculate extraction mass flows first, using previous
            % iteration data. Then calculate new turbine results.
            
            % m_HTR is the mass flow through the main heater
            
            %%%% Save previous values for desviation control
            W_out_pre=c.W_out;
            %%%%
            
            % Store feedwater mass
            c.m_fw=m_HTR;
            
            % Calculate extraction mass flows, starting at HP FWH. Use
            % extraction enthalpies from previous iteration.
            
            % Extraction position vector
            ex_pos=find(c.EX(2,:)==0);
            
            % Calculate extraction pressures at FWHs, after charge loss.
            % Postions in c.EX stored in ex_pos
            P_ex=c.EX(1,ex_pos).*(1-c.EX_ploss);
            
            % Calculate deareator output enthalpy and temperature, assuming
            % saturated output
            c.h_DA_out=h_pTx_97(c.P_COpmp/10,-1,0);
            c.T_DA_out=Ts_p_97(c.P_COpmp/10);
            c.s_DA_out=s_pTx_97(c.P_COpmp/10,-1,0);
            
            % Calculate feedwater pump output temperature. Asume deareator
            % ouput is at saturation point
            c.fw_pmp.solv_T(c.P_COpmp,c.P_FWpmp,c.T_DA_out,...
                c.h_DA_out,c.s_DA_out,m_HTR);
            
            % Calculate condenser output enthalpy and temperature, assuming
            % saturated output
            h_co_out=c.con.h_out;
            T_co_out=c.con.T;
            s_co_out=c.con.s_out;
            
            % Calculate condensate pump output temperature. Assume condenser
            % ouput is at saturation point
            c.co_pmp.solv_T(c.EX(1,end),c.P_COpmp,T_co_out,...
                h_co_out,s_co_out,c.m_FWLP);
            
            %%% Extraction mass flows
            
            % Calculate HP FWHs. First heater
            c.fwh{1}.FWH_bleed(TTD(1),DCA(1),...
                m_HTR,0,c.P_FWpmp,...
                P_ex(1),0,...
                0,...
                T_ph_97(P_ex(1)/10,h_ex(1)),...
                Ts_p_97(P_ex(2)/10)-TTD(2),...
                x_ph_97(P_ex(1)/10,h_ex(1)));
                        
            % Next heaters
            for i=2:c.N_FWH_HP
                
                % Set drainback mass flow
                m_dbck=c.fwh{i-1}.m_Hout;
                
                % Find drainback pressure before valve
                P_dbck=P_ex(i-1);
                
                % Find drainback enthalpy
                h_dbck=c.fwh{i-1}.h_Hout;
                
                % Calculate extraction steam temperature. Asume isentalpic
                % expansion as charge loss through tube to FWH
                T_ex=T_ph_97(P_ex(i)/10,h_ex(i));
                
                % Calculate feedwater input temperature, using previous
                % extraction pressure. Use deareator output temperature if
                % necessary
                if (i==c.N_FWH_HP)
                    T_fw_in=c.fw_pmp.T_out;
                else
                    T_fw_in=Ts_p_97(P_ex(i+1)/10)-c.TTD_d(i+1);
                end
                
                % Calculate extraction steam quality
                x_ex=x_ph_97(P_ex(i)/10,h_ex(i));
                
                % Calculate bleed mass flow
                c.fwh{i}.FWH_bleed(TTD(i),DCA(i),...
                    m_HTR,m_dbck,c.P_FWpmp,...
                    P_ex(i),P_dbck,...
                    h_dbck,T_ex,T_fw_in,x_ex);
            end
            
            % Enthalpy at deareator input from last LP FWH
            h_Cin=h_pTx_97(c.P_COpmp/10,...
                Ts_p_97(P_ex(c.N_FWH_HP+1)/10)-TTD(c.N_FWH_HP+1),...
                -1);
            
            % Calculate Deareator extraction mass flow, accounting for
            % leaks from HP turbine
            c.m_DA_ex=(m_HTR*(c.h_DA_out-h_Cin)-...
                c.tur{1}.m_Lks_to_DA*(c.tur{1}.h_st(end)-h_Cin)-...
                c.fwh{c.N_FWH_HP}.m_Hout*(c.fwh{c.N_FWH_HP}.h_Hout-h_Cin))/...
                (h_DA_ex-h_Cin);
            
            % Calculate condensate mass through LP FWHs
            c.m_FWLP=m_HTR-c.fwh{c.N_FWH_HP}.m_Hout-c.m_DA_ex-c.tur{1}.m_Lks_to_DA;
            
            % Calculate first LP FWH
            c.fwh{c.N_FWH_HP+1}.FWH_bleed(TTD(c.N_FWH_HP+1),DCA(c.N_FWH_HP+1),...
                c.m_FWLP,0,c.P_COpmp,...
                P_ex(c.N_FWH_HP+1),0,...
                0,...
                T_ph_97(P_ex(c.N_FWH_HP+1)/10,h_ex(c.N_FWH_HP+1)),...
                Ts_p_97(P_ex(c.N_FWH_HP+2)/10)-TTD(c.N_FWH_HP+2),...
                x_ph_97(P_ex(c.N_FWH_HP+1)/10,h_ex(c.N_FWH_HP+1)));
            
            % LP FWHs
            for i=c.N_FWH_HP+2:c.N_FWH
                
                % Set drainback mass flow
                m_dbck=c.fwh{i-1}.m_Hout;
                
                % Find drainback pressure before valve
                P_dbck=P_ex(i-1);
                
                % Find drainback enthalpy
                h_dbck=c.fwh{i-1}.h_Hout;
                
                % Calculate extraction steam temperature. Asume isentalpic
                % expansion as charge loss through tube to FWH
                T_ex=T_ph_97(P_ex(i)/10,h_ex(i));
                
                % Calculate feedwater input temperature, using previous
                % extraction pressure. Use condensate pump output
                % temperature if necessary
                if (i==c.N_FWH)
                    T_fw_in=c.co_pmp.T_out;
                else
                    T_fw_in=Ts_p_97(P_ex(i+1)/10)-TTD(i+1);
                end
                
                % Calculate extraction steam quality
                x_ex=x_ph_97(P_ex(i)/10,h_ex(i));
                
                % Calculate bleed mass flow
                c.fwh{i}.FWH_bleed(TTD(i),DCA(i),...
                    c.m_FWLP,m_dbck,c.P_COpmp,...
                    P_ex(i),P_dbck,...
                    h_dbck,T_ex,T_fw_in,x_ex);
            end
            
            % Build extractions vector
            m_ex=zeros(1,size(c.EX,2));
            
            num_FWH=1;
            for i=1:size(c.EX,2)
                switch c.EX(2,i)
                    case 1
                        m_ex(i)=0; % HP Turbine inlet
                        
                    case 2
                        m_ex(i)=0; % IP turbine inlet
                        
                    case 3
                        m_ex(i)=c.m_DA_ex; % Deareator
                        
                    case 4
                        m_ex(i)=0; % LP turbine exhaust
                        
                    case 0
                        m_ex(i)=c.fwh{num_FWH}.mex;
                        num_FWH=num_FWH+1;
                end
            end
            
            % HP TUR
            pressure=c.EX(1,c.EX(3,:)==1);
            
            c.tur{1}.set(pressure(1),pressure(end),...
                m_ex(c.EX(3,:)==1),...
                c.T_HTR,m_HTR,'');
            
            c.tur{1}.solv(tur_mode);
            
            % LP TUR
            pressure=c.EX(1,c.EX(3,:)==2);
            
            c.tur{2}.set(pressure(1),pressure(end),...
                m_ex(c.EX(3,:)==2),...
                c.T_RHTR,c.tur{1}.m_out,'');
            
            c.tur{2}.solv(tur_mode);
            
            % Calculate turbine power output
            c.W_out_tur=c.tur{1}.W_out+c.tur{2}.W_out;
            
            % Calculate pump consumed power
            c.fw_pmp.solv_W(c.m_fw);
            c.co_pmp.solv_W(c.m_FWLP);
            
            % Calculate total cycle output power
            c.W_out=c.W_out_tur-c.fw_pmp.W_pump-c.co_pmp.W_pump;
            
            % Calculate leak flows for next iteration use, store them
            m_leak = leakage(c.tur{1}, c.tur{2});
            c.tur{1}.m_Leaks=m_leak;
            c.tur{2}.m_Leaks=m_leak;
            
            % Return extraction vector for next iteration
            h_ex_out=[c.tur{1}.h_st,c.tur{2}.h_st];
            h_DA_ex_out=h_ex_out(c.EX(2,:)==3);
            h_ex_out=h_ex_out(ex_pos);
            
            % Calculate deviation and residuals
            dev=zeros(c.N_FWH+size(c.tur_conf,2),1);
            
            for i=1:c.N_FWH
                dev(i,1)=c.fwh{i}.dev_final;
            end
            
            for i=1:size(c.tur_conf,2)
                dev(i+c.N_FWH,1)=c.tur{i}.dev_final;
            end
            
            dev=[dev;...
                abs(c.W_out-W_out_pre)/W_out_pre];
            
            dev=max(dev);
            
            res=0;
            
        end
        
        % Iterator for part load conditions calculation
        function [dev, res, cont] = iterate_PL_dampening(c,m_in, dampen_f)
            
            % Save previous indp and enth and mex_pl
            indp_pre=c.indp;
            enth_pre=c.enth;
            mex_pre=c.mex_pl;
            
            % Store previous values for power and efficiencies
            Q_SG_pre=c.Q_SG;
            W_out_pre=c.W_out;
            n_cycle_pre=c.n_cycle;
            heatrate_pre=c.heatrate;
            
            % Store enth and indp, if they were not previously calculated
            if ~any(indp_pre)
                indp_pre=c.indp;
                enth_pre=c.enth;
                
                mex_pre=zeros(c.N_FWH+1,1);
                for i=1:c.N_FWH+1
                    if i<=c.N_FWH_HP
                        mex_pre(i)=c.fwh{i}.mex;
                    elseif i==c.N_FWH_HP+1
                        mex_pre(i)=c.m_DA_ex;
                    else
                        mex_pre(i)=c.fwh{i-1}.mex;
                    end
                end
            end
            
            % Dampen new enth and indp vectors
            % dampen_f -> [0,1]
            c.enth=enth_pre+(c.enth-enth_pre)*(1-dampen_f);
            c.indp=indp_pre+(c.indp-indp_pre)*(1-dampen_f);
            
            % Remove bypassed FWHs
            for i=1:c.N_FWH
                if c.fwh{i}.bypass==1
                    if i <= c.N_FWH_HP
                        c.enth(i,:)=0;
                        c.enth(i,i)=1;
                        c.indp(i)=0;
                    else
                        c.enth(i+1,:)=0;
                        c.enth(i+1,i+1)=1;
                        c.indp(i+1)=0;
                    end
                end
            end
            
            % Calculate extraction mass
            mex=c.enth\c.indp;
            
            % Set deareator to 0 if mass is negative
            if mex(c.N_FWH_HP+1)<0
                mex(c.N_FWH_HP+1)=0;
                
                % Increase hit counter for previous FWH
                c.hit_count_DCA(c.N_FWH_HP+1)=c.hit_count_DCA(c.N_FWH_HP+1)+1;
            end
            
            % Store values
            c.mex_pl=mex;
            
            %%%%%
            
            % Rebuild mex
            mex_tur = zeros(1,size(c.EX,2));
            j=1;
            for i=1:size(c.EX,2)
                if c.EX(2,i)==0 || c.EX(2,i)==3
                    mex_tur(i)=mex(j);
                    j=j+1;
                else
                    mex_tur(i)=0;
                end
            end
            
            % Store new deareator extraction value
            c.m_DA_ex=mex(c.N_FWH_HP+1);
            
            % Calculate new turbine pressures
            % LP TUR
            tur_mode='part';
            m_IPLP=c.tur{1}.m_out;
            
            % Pressures
            P_HP=c.EX(1,c.EX(3,:)==1);
            P_IPLP=c.EX(1,c.EX(3,:)==2);
            
            % Pressure ahead of intercept valve
            P_IV=P_HP(end)*(1-c.RHTR_ploss);
            
            % Condenser pressure
            P_CON=P_IPLP(end);
            
            c.tur{2}.set(P_IV,P_CON,...
                mex_tur(c.EX(3,:)==2),...
                c.T_RHTR,m_IPLP,'');
            
            c.tur{2}.solv(tur_mode);
            
            % Store new extraction pressures, with initial pressure
            % (pressure before intercept valve)
            P_IV=c.tur{2}.EX(1)/(1-c.tur{2}.adm_PLoss);
            
            c.EX(1,c.EX(3,:)==2)=[P_IV, c.tur{2}.EX(2:end)];
            
            % Calculate new reheater input pressure, using intervept valve
            % pressures
            P_HP(end)=P_IV/(1-c.RHTR_ploss);
            
            % HP TUR
            if strcmp(c.mode_op,'constant')
                % Set inlet pressure to design if constant pressure
                c.P_HTR=c.EX_d(1,1);
                P_HP(1)=c.P_HTR;
            else
                % Set heater pressure tu turbine inlet pressure, before
                % throttle valves
                c.P_HTR=c.tur{1}.EX(1)/(1-c.tur{1}.adm_PLoss);
            end
            
            c.tur{1}.set(P_HP(1),P_HP(end),...
                mex_tur(c.EX(3,:)==1),...
                c.T_HPtur_in,m_in,c.mode_op);
            
            c.tur{1}.solv(tur_mode);
            
            % Store new extraction pressures, storing inlet pressure as
            % pressure before throttle valves
            c.EX(1,c.EX(3,:)==1)=[c.P_HTR, c.tur{1}.EX(2:end)];
            
            %%%%%%
            
            % Calculate condensate pump output pressure, equal to deareator
            % extraction pressure
            c.P_COpmp=c.EX(1,c.deair_pos)*(1-c.DAEX_ploss);
            
            % Calculate condenser output enthalpy and temperature, assuming
            % saturated output
            h_co_out=c.con.h_out;
            T_co_out=c.con.T;
            s_co_out=c.con.s_out;
            
            % Feedwater through LP FWHs
            c.m_FWLP=m_in-sum(mex(1:c.N_FWH_HP+1))-c.tur{1}.m_Lks_to_DA;
            
            % Calculate condensate pump output temperature. Assume condenser
            % ouput is at saturation point
            c.co_pmp.solv_T(c.EX(1,end),c.P_COpmp,T_co_out,...
                h_co_out,s_co_out,c.m_FWLP);
            
            % Build extraction enthalpies vector, calculated by turbines
            h_exts=[c.tur{1}.h_st, c.tur{2}.h_st];
            c.h_DAex=h_exts(c.deair_pos);
            h_exts=h_exts(c.EX(2,:)==0);
            
            % Build FWH extraction pressure vector, calculate pressure
            % losses through extraction ducts
            P_ex=c.EX(1,c.EX(2,:)==0).*(1-c.EX_ploss);
            
            % Last FWH
            c.fwh{c.N_FWH}.solv_ent(mex(end), sum(mex(c.N_FWH_HP+2:end-1)),...
                c.m_FWLP,c.fwh{c.N_FWH-1}.h_Hout,...
                c.P_COpmp,...
                P_ex(end),...
                h_exts(c.N_FWH),...
                c.co_pmp.h_out);
            
            for i=c.N_FWH-1:-1:(c.N_FWH_HP+1)
                % Following FWHs
                c.fwh{i}.solv_ent(mex(i+1), sum(mex(c.N_FWH_HP+2:i)),...
                    c.m_FWLP,c.fwh{i-1}.h_Hout,...
                    c.P_COpmp,...
                    P_ex(i),...
                    h_exts(i),...
                    c.fwh{i+1}.h_Cout);
            end
            
            % Recalculate HP Pump output pressure, using reheater pressure
            % loss
            c.P_FWpmp=c.P_HTR/(1-c.HTR_ploss);
            
            % Calculate deareator output enthalpy and temperature, assuming
            % saturated output
            c.h_DA_out=h_pTx_97(c.P_COpmp/10,-1,0);
            c.T_DA_out=Ts_p_97(c.P_COpmp/10);
            c.s_DA_out=s_pTx_97(c.P_COpmp/10,-1,0);
            
            % Calculate feedwater pump output temperature. Asume deareator
            % ouput is at saturation point
            c.fw_pmp.solv_T(c.P_COpmp,c.P_FWpmp,c.T_DA_out,...
                c.h_DA_out,c.s_DA_out,m_in);
            
            % HP FWHs
            % First HP FWH
            c.fwh{c.N_FWH_HP}.solv_ent(mex(c.N_FWH_HP), sum(mex(1:c.N_FWH_HP-1)),...
                m_in,c.fwh{c.N_FWH_HP-1}.h_Hout,...
                c.P_FWpmp,...
                P_ex(c.N_FWH_HP),...
                h_exts(c.N_FWH_HP),...
                c.fw_pmp.h_out);
            
            for i=c.N_FWH_HP-1:-1:1
                % Following FWHs
                if i~=1
                    c.fwh{i}.solv_ent(mex(i), sum(mex(1:i-1)),...
                        m_in,c.fwh{i-1}.h_Hout,...
                        c.P_FWpmp,...
                        P_ex(i),...
                        h_exts(i),...
                        c.fwh{i+1}.h_Cout);
                else
                    c.fwh{i}.solv_ent(mex(i), 0,...
                        m_in,0,...
                        c.P_FWpmp,...
                        P_ex(i),...
                        h_exts(i),...
                        c.fwh{i+1}.h_Cout);
                end
            end
            
            % Calculate turbine power output
            c.W_out_tur=c.tur{1}.W_out+c.tur{2}.W_out;
            
            % Calculate total cycle output power
            c.W_out=c.W_out_tur-c.fw_pmp.W_pump-c.co_pmp.W_pump;
            
            % Calculate cycle heat rate
            % Heat transfered to steam in steam generator
            h_out=c.tur{1}.h_in;
            
            c.Q_HTR=c.m_fw*(h_out-c.fwh{1}.h_Cout);
            c.Q_RHTR=c.tur{2}.m_in*(c.tur{2}.h_in-c.tur{1}.h_st(end));
            c.Q_SG=c.Q_HTR + c.Q_RHTR;
            
            c.n_cycle=c.W_out/c.Q_SG;
            c.heatrate=c.Q_SG/c.W_out;
            
            % Calculate leak flows for next iteration use, store them
            m_leak = leakage(c.tur{1}, c.tur{2});
            c.tur{1}.m_Leaks=m_leak;
            c.tur{2}.m_Leaks=m_leak;
            
            %%%%
            % Build new enth and indp
            c.build_enth_indp(m_in);
            %%%%
            
            % Activate bypass if necessary for any FWH
            if c.auto_bypass_DCA > 0
                cont=c.auto_bypass();
            else
                cont=0;
            end
            
            % Calculate deviation and residuals
            % Deviation
            dev=zeros(9+c.N_FWH,1);
            dev(1:9)=[max((indp_pre-c.indp)./c.indp);...
                max(max((enth_pre-c.enth)./c.enth));...
                max((mex_pre-mex)./mex);...
                c.tur{1}.dev_final;...
                c.tur{2}.dev_final;...
                (Q_SG_pre-c.Q_SG)/c.Q_SG;...
                (W_out_pre-c.W_out)/c.W_out;...
                (n_cycle_pre-c.n_cycle)/c.n_cycle;...
                (heatrate_pre-c.heatrate)/c.heatrate];
            
            for i=1:c.N_FWH
                dev(9+i)=c.fwh{i}.dev_final;
            end
            
            dev=max(abs(dev));
            
            % Residuals
            res=c.enth*mex-c.indp;
            
            res=abs(max(res));
            
            
        end
        
        function build_enth_indp(c,m_in)
            % Build enthalpies matrix and indpendent vector
            % Build enthalpies matrix
            % HP FWHs
            for i=1:(c.N_FWH_HP)
                % Extraction mass enthalpy
                c.enth(i,i)=c.fwh{i}.h_ex - c.fwh{i}.h_Hout;
                
                % Drainbacks enthalpy
                for j=1:i-1
                    c.enth(i,j)=c.fwh{i}.h_dA - c.fwh{i}.h_Hout;
                end
            end
            
            % Deareator
            c.enth(c.N_FWH_HP+1,c.N_FWH_HP+1)=...
                c.h_DAex-c.fwh{c.N_FWH_HP+1}.h_Cout;
            
            % Deareator - remove previous extractions from feedwater flow
            for i=1:c.N_FWH_HP
                % Drainbacks
                c.enth(c.N_FWH_HP+1,i)=c.fwh{c.N_FWH_HP}.h_Hout - c.fwh{c.N_FWH_HP+1}.h_Cout;
            end
            
            % LP FWHs
            for i=(c.N_FWH_HP+1):c.N_FWH
                % Extraction mass enthalpy
                c.enth(i+1,i+1)=c.fwh{i}.h_ex - c.fwh{i}.h_Hout;
                
                % Drainbacks enthalpy
                for j=(c.N_FWH_HP+1):i-1
                    c.enth(i+1,j+1)=c.fwh{i}.h_dA - c.fwh{i}.h_Hout;
                end
                
                % Substract HP and LP FWHs extractions and deareator extraction from
                % LP FWHs
                for j=1:(c.N_FWH_HP+1)
                    c.enth(i+1,j)=c.fwh{i}.h_Cout - c.fwh{i}.h_Cin;
                end
            end
            
            % Independent terms
            for i=1:(c.N_FWH+1)
                if (i<c.N_FWH_HP+1)
                    % HP FWHs
                    c.indp(i)=c.fwh{i}.h_Cout-c.fwh{i}.h_Cin;
                    c.indp(i)= c.indp(i)* m_in;
                    
                elseif (i>c.N_FWH_HP+1)
                    % LP FWHs
                    c.indp(i)=c.fwh{i-1}.h_Cout-c.fwh{i-1}.h_Cin;
                    c.indp(i)= c.indp(i)* (m_in-c.tur{1}.m_Lks_to_DA);
                    
                else
                    % Deareator
                    c.indp(i)=m_in*(c.h_DA_out-c.fwh{c.N_FWH_HP+1}.h_Cout)-...
                        c.tur{1}.m_Lks_to_DA*(c.tur{1}.h_st(end)-c.fwh{c.N_FWH_HP+1}.h_Cout);
                end
            end
        end
        
        function cont = auto_bypass(c)
            % Update hit counter, and search for min DCA
            
            cont=0; % Disable calculation end if an invalid FWH is found.
            % Assume solution wiil be found
            
            max_dca=c.fwh{1}.DCA;
            max_dca_fwh=1;
            
            min_ttd=c.fwh{1}.TTD;
            min_ttd_fwh=1;
            
            % Disable last feed water heater auto bypass if necessary
            if c.enable_auto_last_FWH
                num_fwh_check=c.N_FWH;
            else
                num_fwh_check=c.N_FWH-1;
            end
            
            for i=1:num_fwh_check
                % Check DCA value
                if c.fwh{i}.DCA >= c.auto_bypass_DCA
                    c.hit_count_DCA(i)=c.hit_count_DCA(i)+1;
                    
                    % Disable calculation end
                    cont=1;
                end
                
                % Check TTD value
                if c.fwh{i}.TTD <= c.auto_bypass_TTD
                    c.hit_count_TTD(i)=c.hit_count_TTD(i)+1;
                    
                    % Disable calculation end
                    cont=1;
                end
                
                % Store max DCA
                if c.fwh{i}.DCA > max_dca
                    max_dca=c.fwh{i}.DCA;
                    max_dca_fwh=i;
                end
                
                % Store min TTD
                if c.fwh{i}.TTD < min_ttd
                    min_ttd=c.fwh{i}.TTD;
                    min_ttd_fwh=i;
                end
                
                %                     fprintf('\t\t\tDCA %.4f\n',c.fwh{i}.DCA);
                
            end
            
            if max(c.hit_count_DCA >= c.min_hit_count)
                % Enable FWH bypass if necessary (DCA control)
                c.fwh{max_dca_fwh}.bypass=1;
                %                     fprintf('bypass %i\n',min_dca_fwh);
                
                % Reset all bypasses in case a new solution is
                % found
                c.hit_count_TTD=zeros(1,c.N_FWH);
                c.hit_count_DCA=zeros(1,c.N_FWH);
            end
            
            if max(c.hit_count_TTD >= c.min_hit_count)
                % Enable FWH bypass if necessary (TTD Control)
                c.fwh{min_ttd_fwh}.bypass=1;
                %                     fprintf('bypass %i\n',min_dca_fwh);
                
                % Reset all bypasses in case a new solution is
                % found
                c.hit_count_TTD=zeros(1,c.N_FWH);
                c.hit_count_DCA=zeros(1,c.N_FWH);
            end
            
        end
    end
    
    methods(Access = protected)
        % Override copyElement method:
        function cpObj = copyElement(obj)
            % Make a shallow copy of all four properties
            cpObj = copyElement@matlab.mixin.Copyable(obj);
            % Make a deep copy of the DeepCp object
            cpObj.tur=cell(size(obj.tur_conf,2),1);
            cpObj.fwh=cell(obj.N_FWH,1);
            
            for i=1:size(obj.tur_conf,2)
                cpObj.tur{i}=copy(obj.tur{i});
            end
            
            for i=1:obj.N_FWH
                cpObj.fwh{i}=copy(obj.fwh{i});
            end
            
            cpObj.fw_pmp=copy(obj.fw_pmp);
            cpObj.co_pmp=copy(obj.co_pmp);
            cpObj.con=copy(obj.con);
            
        end
    end
    
end

