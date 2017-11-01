classdef FWH < matlab.mixin.Copyable
    
    % Balance termodinámico de un FWH, tomando como inputs la entalpía y
    % presión de la extracción, el flujo másico y la temperatura y presión
    % del drainback, y las temperaturas de entrada y salida y presión
    % del fluido frío.
    
    % Para minimizar el código en el programa principal, el estado del
    % drainback se toma inmediatamente a la salida del FWH anterior. Es
    % decir, sin haber aún pasado por la válvula de expansión.
    
    % Importante: Q_DSH,Q_CON,Q_SUB están en W, Q_FWH está en kW
    
    properties (Access = public)
        % Temperatures
        T_Cout % temperatura de salida del fluido frio
        T_Cin % temperatura de entrada del agua de ciclo
        T_Hout % temperatura del fluido caliente, salida
        T_Hin % Extraction steam temperature [K]
        T_dA % temperatura del drainback, antes de la valvula de expansión
        TTD % diferencia entre la Tsat de la extracción y la temperatura de salida
        % del agua de ciclo
        DCA % diferencia entre la temperatura de salida del fluido caliente
        TTD_d % Design conditions TTD
        DCA_d % Design conditions DCA
        
        % Mass flows
        mex % masa de la extraccion
        mciclo % masa de agua de ciclo en el FWH
        md % masa del drainback
        m_Hout % Hot flow output mass flow (drainback + extraction)
        m_c_d % Cold fluid mass flow, design conditions [kg/s]
        
        % Enthalpies
        h_ex % entalpía del vapor procedente de la turbina (extraccion)
        h_Hout % entalpia de salida del fluido caliente
        h_Cout % entalpia del agua de ciclo, salida
        h_Cin % entalpia del agua de ciclo, entrada
        h_dA % entalpia drainback entrante al fwh
        
        % Pressures
        P_ex % Presion de la extraccion procendete de la turbina
        P_C % presion del agua de ciclo
        P_dA % presion del drainback, antes de la valvula de expansión
        
        % Heat
        Q_exchanged % Exchanged heat
        Q_exchanged_d % Design conditions Exchanged heat
        
        bypass=0 % FWH set to bypass mode
        UA_d % Heat transfer coefficient, design contiditions
        UA_d_simple
        UA % Heat transfer coefficient at part load operation
        cycle_pos % Position in cycle
        
        % Datos proporcionados
        x_ex % titulo de la extracción, -1 si no corresponde
        x_d % titulo del drainback
        
        % Deviation control
        dev_final % Maximum deviation of controled variables
        
        % FWH Dimension
        vtubos % Speed in tubes [m/s]
        k_tubos % Tube conductivity [W/m·K]
        d_tubos_e % Tube external diameter [m]
        d_tubos_i % Tube internal diameter [m]
        pitch_tubos % Tube pitch distance [m]
        Np % Number of passes
        LBDSH % Baffle distance, DeSuperHeater [m]
        LBSUB % Baffle distance, Subcooler [m]
        d_car % Shell diameter [m]
        N_tubos % Number of tubes
        L_tubos % Length of tubes [m]
        Ncolumna % Number of columns in CON section
        
        % Section dimension
        L_CON % Length of condenser [m]
        L_SUB % Length of subcooler [m]
        L_DSH % Length of desuperheater [m]
        A_DSH % Heat exchange area, DSH zone [m^2]
        A_CON % Heat exchange area, CON zone [m^2]
        A_SUB % Heat exchange area, SUB zone [m^2]
        
        % Exchanged heat
        Q_DSH % Exchanged heat, desuperheater zone [kW]
        Q_CON % Exchanged heat, condenser zone [kW]
        Q_SUB % Exchanged heat, subcooler zone [kW]
        
        % Excess heat in sections
        Q_EXC_DSH
        Q_EXC_CON
        Q_EXC_SUB
        
        % Heat transfer coefficients
        U_DSH % Global heat transfer coefficient, DSH zone [W/m^2·K]
        U_CON % Global heat transfer coefficient for CON section [W/m^2·K]
        U_SUB % Subcooler global heat transfer coefficient [W/m^2·K]
        hiCON % Condensate section convective heat transfer coefficient [W/m^2·K]
        U_DSH_d % Design conditions global heat transfer coefficient, DSH zone [W/m^2·K]
        U_CON_d % Design conditions global heat transfer coefficient for CON section [W/m^2·K]
        U_SUB_d % Design conditions Subcooler global heat transfer coefficient [W/m^2·K]
        
        % Temperatures
        T_HDSH_out % Steam temperature at exit of DSH (to condenser) [k]
        T_CDSH_in % Water temperature at DSH input [K]
        T_resDSH % Residual DSH heat [K]
        T_CON % Condensate temperature at CON section [K]
        T_CCON_out % Cold water output temperature from CON section [K]
        T_HCON_in % Steam input temperature at CON section [K]
        T_HCON_out % Steam output temperature from CON section [K]
        T_CON_sur % Condensate section tube surface temperature [K]
        T_CSUB_out % Water subcooler output temperature [K]
        T_HSUB_in % Steam input temperature in subcooler [K]
        T_CCON_in % Input temperature of water to CON section [K]
        
    end
    
    properties (Access = private)
        % Propiedades calculadas
        
        % Deviation control
        dev_pre % Previous values
        dev_new % New calculated values
        
        % Dimension
        d_eq % Equivalent diamenter (hot side) [m]
        SsDSH % Effective DSH section [m^2]
        SsSUB % Effective SUB section [m^2]
        T_DSH_sat % Steam saturation temperature [K]
        
        % Temperature tolerance for solving part load conditions
        tol_temp = 1e-6
        
        % Solution method for part load operation
        solve_simple=false
        % Simple solution method is currently deprecated and will be
        % removed
        
        
    end
    
    methods (Access = public)
        
        function h = FWH(geom_param,fcycle_pos)
            % Class constructor. Set geometrical parameters
            
            % Store geometrical parameters
            h.vtubos=geom_param.v;
            h.k_tubos=geom_param.k;
            h.d_tubos_e=geom_param.de;
            h.d_tubos_i=geom_param.di;
            h.pitch_tubos=geom_param.pt;
            h.Np=geom_param.np;
            h.LBDSH=geom_param.bafDSH;
            h.LBSUB=geom_param.bafSUB;
            
            h.cycle_pos=fcycle_pos; % Position in cycle
            
        end
        
        function FWH_bleed(h,fTTD,fDCA,fmciclo,fmd,fP_C,fP_ex,...
                fP_dA,fh_dA,fT_Hin,fT_Cin,fx_ex)
            % FWH_bleed obtiene el valor que debe tomar el flujo másico de
            % la extracción a partir de la presion, temperatura y masa de
            % el drainback, la temperatura de entrada y titulo de la
            % extraccion y el cociente entre la masa que circula por los
            % tubos del fwh y la maxima del ciclo.
            
            % Store variables for deviation control
            h.dev_previous();
            
            % Guardado de variables
            h.TTD=fTTD;
            h.DCA=fDCA;
            h.mciclo=fmciclo; % Cold fluid mass flow
            h.md=fmd; % Drainback mass flow
            h.P_ex=fP_ex; % Extraction pressure
            h.P_C=fP_C; % Feedwater pressure
            h.P_dA=fP_dA; % Drainback pressure
            h.h_dA=fh_dA; % Drainback enthalpy
            h.x_ex=fx_ex; % Extraction steam quality
            h.T_Hin=fT_Hin; % Extraction input temperature
            h.T_Cin=fT_Cin; % Feedwater input temperature
                        
            %Temperatura de salida del fluido frio
            h.T_Cout=Ts_p_97(h.P_ex/10)-h.TTD;
            
            %Temperatura de salida del fluido caliente
            h.T_Hout=h.T_Cin+h.DCA;
            
            %Entalpia de entrada de la extraccion, procedente de la turbina
            if h.x_ex~=-1 % si se está dentro de la campana de cambio de fase
                h.h_ex=h_pTx_97(h.P_ex/10,-1,h.x_ex);
            else % si el fluido es de una sola fase
                h.h_ex=h_pTx_97(h.P_ex/10,h.T_Hin,-1);
            end
            
            % Calculo de entalpias del fluido frio
            h.h_Cin=h_pTx_97(h.P_C/10,h.T_Cin,-1);
            h.h_Cout=h_pTx_97(h.P_C/10,h.T_Cout,-1);
            
            % Calculo de entalpia de entrada del drainback, sabiendo que la
            % valvula baja la presion desde P_dA hasta P_ex de manera
            % isentálpica
            if h.P_dA~=0
                h.T_dA=T_ph_97(h.P_ex/10,h.h_dA);
                h.x_d=x_ph_97(h.P_ex/10,h.h_dA);
            else
                h.h_dA=1;
                h.x_d=-1;
            end
            
            % Calculo de entalpia de salida del fluido caliente
            h.h_Hout=h_pTx_97(h.P_ex/10,h.T_Hout,-1);
            
            % Extraction mass flow.
            % Heater is yet to be designed
            h.mex=(h.mciclo*(h.h_Cout-h.h_Cin)-h.md*(h.h_dA-h.h_Hout))...
                /(h.h_ex-h.h_Hout);
            
            % Calculate exchanged heat
            h.Q_exchanged=h.mciclo*(h.h_Cout-h.h_Cin);
            
            % Hot fluid output mass flow
            h.m_Hout=h.md+h.mex;
            
            % Calculate deviation
            h.dev_calc();
        end
        
        function solv_UA_d(h)
            
            if h.solve_simple
                
                % Save UA at design conditions
                % Logarithmic mean temperature difference
                T_lm=((h.T_Hin-h.T_Cout)-(h.T_Hout-h.T_Cin))/...
                    (log((h.T_Hin-h.T_Cout)/(h.T_Hout-h.T_Cin)));
                
                % Calculate heat transfer coefficient ad design conditions
                h.UA_d=h.Q_exchanged/T_lm;
                
                % Store cold fluid mass flow at design conditions
                h.m_c_d=h.mciclo;
                
                % Store design TTD and DCA
                h.TTD_d=h.TTD;
                h.DCA_d=h.DCA;
                
            else
                
                % Solve dimensions
                h.FWH_dimension()
                
                % Store cold fluid mass flow at design conditions
                h.m_c_d=h.mciclo;
                
                % Store design TTD and DCA
                h.TTD_d=h.TTD;
                h.DCA_d=h.DCA;
                
                % Store heat transfer coefficients (por comparisson value)
                h.U_DSH_d=h.U_DSH;
                h.U_CON_d=h.U_CON;
                h.U_SUB_d=h.U_SUB;
                
                % Store exchanged heat
                h.Q_exchanged=(h.Q_DSH+h.Q_CON+h.Q_SUB)/1000;
                
                %%% TEST
                % Save UA at design conditions
                % Logarithmic mean temperature difference
                T_lm=((h.T_Hin-h.T_Cout)-(h.T_Hout-h.T_Cin))/...
                    (log((h.T_Hin-h.T_Cout)/(h.T_Hout-h.T_Cin)));
                
                % Calculate heat transfer coefficient ad design conditions
                h.UA_d_simple=h.Q_exchanged/T_lm;
                %%% TEST
                
            end
            
            % Set excess heat to 0
            h.Q_EXC_DSH=0;
            h.Q_EXC_CON=0;
            h.Q_EXC_SUB=0;
            
        end
        
        function solv_ent(h, fmex, fmd, fmc, fhd, fPC, fPEX,...
                fhin, fhcin)
            % Given extraction mass flow, drainback mass flow and feedwater
            % mass flow, calculate output enthalpies. Use UA at part load.
            
            % Store variables
            h.mex=fmex;
            h.md=fmd;
            h.mciclo=fmc;
            h.h_dA=fhd;
            h.P_C=fPC;
            h.P_ex=fPEX;
            h.h_ex=fhin;
            h.h_Cin=fhcin;
            
            % Store variables for deviation control
            h.dev_previous();
            
            % Calculate input steam temperature
            h.T_Hin = T_ph_97(h.P_ex/10, h.h_ex);
            
            % Calculate input steam title
            h.x_ex=x_ph_97(h.P_ex/10,h.h_ex);
            
            % Calculate input feedwater temperature
            h.T_Cin = T_ph_97(h.P_C/10, h.h_Cin);
            
            % Calculate drainback temperature
            h.T_dA = T_ph_97(h.mex/10, h.h_dA);
            
            % Calculate drainback title
            h.x_d=x_ph_97(h.P_ex/10,h.h_dA);
            
            % Solve 2-equation system for T_out_hot and T_out_cold. First
            % equation is Q=UA*LMTD, second equation is FWH heat balance.
            % Use drainback enthalpy from previous iteration, as it is
            % small compared to the input steam enthalpy.
            
            options = optimoptions(@lsqnonlin,'Display','none',...
                'FunctionTolerance', 1e-10,...
                'OptimalityTolerance', 1e-10,...
                'StepTolerance', 1e-10);
            
            if h.bypass==0
                % Solve using lsqnonlin
                
                if h.solve_simple
                    % Recalculate global heat transfer coefficient
                    h.UA=h.UA_d*(h.mciclo/h.m_c_d)^0.8;
                    
                    ex_sat_temp = Ts_p_97(h.P_ex/10);
                    cold_sat_temp = Ts_p_97(h.P_C/10);
                    
                    if cold_sat_temp > h.T_Hin-0.05
                        cold_ub=h.T_Hin-0.05;
                    else
                        cold_ub=cold_sat_temp-0.5;
                    end
                    
                    if isnan(h.eqsys_solv([h.T_Cin + 1,...
                            Ts_p_97(h.P_ex/10)-1]))
                        exitflag=-2;
                    else
                        [T,~,~,exitflag, output] = lsqnonlin(@h.eqsys_solv,...
                            [h.T_Cin + 2, h.T_Cin + 2],...
                            [h.T_Cin+0.5, h.T_Cin+0.5],... % Lower bound
                            [ex_sat_temp-0.5, cold_ub],... % Upper bound
                            options);
                    end
                    
                    % Check if the bounds are respected (exitflag == -2). A
                    % common case is the saturation temperature of the steam
                    % can be less than input water temperature in certain
                    % conditions (insufficient extraction pressure). Bypass
                    % conditions are enabled without enabling bypass option
                    % (left to auto bypass)
                    if exitflag==-2
                        h.T_Cout=h.T_Cin;
                        h.h_Cout=h.h_Cin;
                        h.h_Cout=h.h_Cin;
                        h.h_Hout=h.h_dA;
                        
                        if isempty(h.h_dA)
                            h.h_Hout=0;
                        end
                        
                        h.DCA=-1; % In order to not trigger auto bypass
                        h.TTD=0; % In order to not trigger auto bypass
                        
                        h.dev_final=0;
                    else
                        % Solution found
                        % Store results
                        h.T_Hout=T(1);
                        h.T_Cout=T(2);
                        
                        % Recalculate enthalpies and exchanged heat
                        h.h_Cout=h_pTx_97(h.P_C/10,h.T_Cout,-1);
                        h.h_Hout=h_pTx_97(h.P_ex/10,h.T_Hout,-1);
                        h.Q_exchanged=h.mciclo*(h.h_Cout-h.h_Cin);
                        
                        % Recalculate TTD and DCA
                        h.TTD=Ts_p_97(h.P_ex/10)-h.T_Cout;
                        h.DCA=h.T_Hout-h.T_Cin;
                        
                        % Calculate deviation
                        h.dev_calc();
                        
                    end
                    
                else
                    try
                        % Solve using complex method
                        h.fixed_area_solve();
                    catch ME
                        fprintf(['\n\n%%%%%%\nERROR\n\nFailed to solve partial load tempeartures',...
                            ' for FWH %i.\nSuggestion: Check extraction pressures ',...
                            'at design conditions, increase TTD value.\nFeedwater temperature ',...
                            'rise at each FWH show be as uniform as possible.\n',...
                            '\nRegular error message:\n\n'],h.cycle_pos);
                        
                        rethrow(ME);
                    end
                end
                
            else
                h.T_Cout=h.T_Cin;
                h.h_Cout=h.h_Cin;
                h.h_Cout=h.h_Cin;
                h.h_Hout=h.h_dA;
                
                if isempty(h.h_dA)
                    h.h_Hout=0;
                end
                
                h.DCA=-1; % In order to not trigger auto bypass
                h.TTD=0; % In order to not trigger auto bypass
                
                h.dev_final=0;
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function dev_previous(h)
            % Save previous values (stored at execution)
            h.dev_pre=[h.T_Cout;...
                h.T_Hout;...
                h.h_Hout;...
                h.h_Cout;...
                h.h_ex;...
                h.mex;...
                h.m_Hout;...
                h.x_d;...
                h.h_dA;...
                h.h_Cin;...
                h.Q_exchanged];
        end
        
        function dev_calc(h)
            % Calculate deviation values after calculation of bleed mass
            h.dev_new=[h.T_Cout;...
                h.T_Hout;...
                h.h_Hout;...
                h.h_Cout;...
                h.h_ex;...
                h.mex;...
                h.m_Hout;...
                h.x_d;...
                h.h_dA;...
                h.h_Cin;...
                h.Q_exchanged];
            
            if isempty(h.dev_pre)==0
                h.dev_final=abs((h.dev_new-h.dev_pre)./h.dev_new);
                
                for i=1:size(h.dev_final,1)
                    % Remove inf
                    if isinf(h.dev_pre(i))
                        h.dev_pre(i)=0;
                    end
                end
                h.dev_final=max(h.dev_final);
            else
                h.dev_final=1;
            end
            
        end
        
        function res = LMT_solv(h,LMTD,Thin,Thout,Tcin,Tcout)
            % Returns Logarithmic mean temperature difference, for
            % input and output temperatures of hot and cold fluid, in a
            % counter-current heat exchanger
            
            res=LMTD-((Thin-Tcout)-(Thout-Tcin))/...
                (log((Thin-Tcout)/(Thout-Tcin)));
            
            
        end
        
        function res = eqsys_solv(h,T)
            
            % T -> [T_hot_out, T_cold_out]
            % Feedwater output enthaply
            h_fw_out = h_pTx_97(h.P_C/10, T(2), -1);
            
            % Extraction steam output enthalpy
            h_ex_out = h_pTx_97(h.P_ex/10, T(1), -1);
            
            % Feedwater absorbed heat
            Q_fw=h.mciclo*(h_fw_out-h.h_Cin);
            
            % Extraction transfered heat
            Q_ex=h.mex*(h.h_ex-h_ex_out);
            
            % Drainback transfered heat
            Q_db=h.md*(h.h_dA-h_ex_out);
            
            % Logarithmic mean temperature difference
            LMTD=((h.T_Hin-T(2))-(T(1)-h.T_Cin))/...
                (log((h.T_Hin-T(2))/(T(1)-h.T_Cin)));
            
            % Q=UA*LMTD
            Q_UA=h.UA*LMTD;
            
            % Return res
            res=zeros(1,2);
            
            res(1)=Q_UA-Q_ex-Q_db;
            res(2)=Q_ex+Q_db-Q_fw;
            
        end
        
        %%%% Complex mode
        
        function FWH_dimension(h)
            % FWH_dimension obtiene los parametros geometricos del FWH a
            % partir de la velocidad de flujo en los tubos, conductividad
            % térmica de los tubos, diametro exterior, diametro interior,
            % pitch de los tubos, numero de pasos, distancia entre baffles
            % del DSH y distancia entre baffles del SUB.
            
            % Notación: T_H_out es temperatura de salida del vapor de una
            % seccion determinada, T_C_out es la temperatura de salida del
            % agua de ciclo de una seccion determinada
            
            % Calcular el numero de tubos necesario
            h.Np=2;
            h.N_tubos=round((h.mciclo*h.Np*4*v_pTx_97(h.P_C/10,h.T_Cout,-1))...
                /(h.vtubos*pi*(h.d_tubos_i)^2));
            
            % Calcular en diametro de la carcasa
            h.d_car=sqrt((2*sqrt(3)*h.pitch_tubos^2*h.N_tubos)...
                /(pi*0.9));
            
            % Calcular el diametro equivalente del lado caliente
            h.d_eq=4*(sqrt(3)*h.pitch_tubos^2/2-pi*h.d_tubos_e^2/4)/...
                (pi*h.d_tubos_e);
            
            % Seccion efectiva DSH
            h.SsDSH=h.d_car*(h.pitch_tubos-h.d_tubos_e)*h.LBDSH/h.pitch_tubos;
            
            % Seccion efectiva SUB
            h.SsSUB=h.d_car*(h.pitch_tubos-h.d_tubos_e)*h.LBSUB/h.pitch_tubos;
            
            %%%%%%%%%%%%%%%
            %Calculo de la seccion de desuperheating (DSH) si corresponde
            if h.x_ex==-1
                % Temperatura de saturacion del vapor
                h.T_DSH_sat=Ts_p_97(h.P_ex/10);
                
                % Calculo de la temperatura de salida del vapor del DSH
                % usando fzero
                % Intervalo de busqueda de valor de la temperatura de
                % salida
                intervalo=[h.T_DSH_sat+h.tol_temp h.T_Hin-h.tol_temp];
                
                % Funcion que usa fzero
                fun=@(t1) t1-h.DSH_Tout(t1);
                
                % Comprobacion de que es necesario colocar un FWH
                if isreal(fun(intervalo(1)))==0 || isreal(fun(intervalo(2)))==0 ...
                        || isinf(fun(intervalo(1)))==1 || isinf(fun(intervalo(2)))==1
                    % No calcular FWH si hay componentes imaginarios o
                    % infinitos
                    
                    h.L_tubos=0;
                    h.L_CON=0;
                    h.L_SUB=0;
                    h.L_tubos=0;
                    h.Q_DSH=0;
                    h.Q_CON=0;
                    h.Q_SUB=0;
                    h.Q_exchanged=0;
                    h.T_Cout=h.T_Cin;
                    h.h_Cout=h.h_Cin;
                    
                    % Devolver control a funcion invocante, el calculo ha
                    % acabado
                    return
                    
                elseif sign(fun(intervalo(1)))==sign(fun(intervalo(2)))
                    % No es necesario un DSH si el vapor empieza a
                    % condensar a la temperatura a la que entra
                    h.L_DSH=0;
                    h.Q_DSH=0;
                    h.U_DSH=0;
                    h.T_HDSH_out=h.T_Hin;
                    h.T_CDSH_in=h.T_Cout;
                    h.T_resDSH=0;
                    
                else % Se necesita un DSH: calcular T_HDSH_out
                    h.T_HDSH_out=fzero(fun,intervalo);
                    
                    % Calculo del calor intercambiado
                    h_steam_out = h_pTx_97(h.P_ex/10,h.T_HDSH_out,-1);
                    
                    h.Q_DSH=h.mex*(h.h_ex-h_steam_out)*1000;
                    
                    % Logarithmic mean temperature difference
                    LMTD = ((h.T_Hin-h.T_Cout)-(h.T_HDSH_out-h.T_CDSH_in))...
                        /(log((h.T_Hin-h.T_Cout)/(h.T_HDSH_out-h.T_CDSH_in)));
                    
                    % Calculo de la longitud de seccion
                    h.L_DSH=h.Q_DSH/(h.U_DSH*pi*h.d_tubos_e*(h.N_tubos/h.Np)*...
                        LMTD);
                    
                    % Calculate section exchange area
                    h.A_DSH=h.Q_DSH/(h.U_DSH*LMTD);
                    
                    % Calor residual DSH (en grados K)
                    h.T_resDSH=h.T_HDSH_out-h.T_DSH_sat;
                    
                    % Comprobar validez del resultado
                    if isreal(h.L_DSH)==0 || isinf(h.L_DSH)
                        % Eliminar FWH si no es posible construir el DSH para el
                        % TTD proporcionado
                        
                        h.L_tubos=0;
                        h.L_CON=0;
                        h.L_SUB=0;
                        h.L_tubos=0;
                        h.Q_DSH=0;
                        h.Q_CON=0;
                        h.Q_SUB=0;
                        h.Q_exchanged=0;
                        h.T_Cout=h.T_Cin;
                        h.h_Cout=h.h_Cin;
                        
                        % Devolver control a funcion invocante, el calculo ha
                        % acabado
                        return
                    end
                end
            else
                % El vapor entra en condiciones de saturación. No es
                % necesario un DSH
                
                h.L_DSH=0;
                h.Q_DSH=0;
                h.U_DSH=0;
                h.T_HDSH_out=h.T_Hin;
                h.T_CDSH_in=h.T_Cout;
                h.T_resDSH=0;
                h.T_DSH_sat=Ts_p_97(h.P_ex/10);
            end
            
            %%%%%%%%%%%%%%%
            % Calculo de la seccion de condesacion (CON)
            h.T_CON=h.T_DSH_sat; % temperatura de saturacion
            h.T_CCON_out=h.T_CDSH_in; % agua a la salida
            h.T_HCON_in=h.T_HDSH_out; % vapor a la entrada
            h.T_HCON_out=h.T_CON;
            
            % Calculo de parametros para obtener la temperatura de entrada
            % al condensador.
            % calor cedido por el vapor de la extraccion
            if h.x_ex==-1
                Qcondensado=h.mex*hfg_p(h.P_ex/10)*1000;
            else
                Qcondensado=h.mex*h.x_ex*hfg_p(h.P_ex/10)*1000;
            end
            
            % calor cedido por el vapor del drainback
            if (h.md~=0)&&(h.x_d~=-1)
                Qdrain=h.md*h.x_d*hfg_p(h.P_ex/10)*1000;
            else
                Qdrain=0;
            end
            % calor cedido por el calor residual del DSH; se suma 0.1  a la
            % temperatura de condensacion para garantizar que las entalpias
            % se toman a la derecha de la campana de cambio de fase
            if h.x_ex==-1
                h_dsh_residual=h_pTx_97(h.P_ex/10,h.T_HCON_in,-1);
                h_con=h_pTx_97(h.P_ex/10,-1,1); % Enthalpy at beggining of condensation
                
                Qresidual=h.mex*(h_dsh_residual-h_con)*1000;
            else
                Qresidual=0;
            end
            
            h.Q_CON=Qcondensado+Qresidual+Qdrain;
            
            % Calculo de la temperatura de entrada del agua de ciclo al
            % condensador, a partir del calor absorbido
            %             TCIN= @(tin) (tin-(h.T_CCON_out-h.Q_CON/(h.mciclo*cpmhT_pT(h.P_ex/10,h.T_CCON_out,tin)*1000)));
            TCIN= @(tin) h.T_CON_in(tin);
            
            if sign(TCIN(h.T_Cin))==sign(TCIN(h.T_CCON_out-0.01)) || ...
                    isreal(TCIN(h.T_Cin))==0 || isreal(TCIN(h.T_CCON_out-0.01))==0 || ...
                    isinf(TCIN(h.T_Cin))==1 || isinf(TCIN(h.T_CCON_out-0.01))==1
                % Condensador no válido. Eliminar FWH
                
                h.L_DSH=0;
                h.L_CON=0;
                h.L_SUB=0;
                h.L_tubos=0;
                h.Q_DSH=0;
                h.Q_CON=0;
                h.Q_SUB=0;
                h.Q_exchanged=0;
                h.T_Cout=h.T_Cin;
                h.h_Cout=h.h_Cin;
                
                % Devolver control a funcion invocante, el calculo ha
                % acabado
                return
                
            else
                h.T_CCON_in=fzero(TCIN,[h.T_Cin, h.T_CCON_out-0.01]);
            end
            
            % Propiedades del agua, lado de los tubos (C)
            u_CCON=eta_pTx_97(h.P_C/10,(h.T_CCON_out+h.T_CCON_in)/2,-1);
            Pr_CCON=numPr(h.P_C/10,(h.T_CCON_out+h.T_CCON_in)/2,-1);
            k_CCON=lambda_pTx_97(h.P_C/10,(h.T_CCON_out+h.T_CCON_in)/2,-1);
            
            % Coeficiente convectivo en el interior de los tubos
            ReiCON=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_CCON);
            NuiCON=0.023*ReiCON^0.8*Pr_CCON^(1/3);
            h.hiCON=NuiCON*k_CCON/h.d_tubos_i;
            
            % Calculo de Numero de columnas
            h.Ncolumna=h.d_car/(sqrt(3)*h.pitch_tubos);
            
            % Funcion usada en el fzero
            funsur=@(tsur) h.CON_Tsur(tsur);
            
            % Obtencion de la temperatura de superficie de tubos, necesaria
            % para obtener el valor de U_CON
            %             h.T_CON_sur=fzero(funsur,h.T_CON-10);
            h.T_CON_sur=fzero(funsur,[h.T_CON-h.tol_temp, h.T_CCON_in]);
            
            % Calculate logarithmic mean temperature difference
            LMTD = ((h.T_CON-h.T_CCON_out)-(h.T_CON-h.T_CCON_in))...
                /(log((h.T_CON-h.T_CCON_out)/(h.T_CON-h.T_CCON_in)));
            
            % Obtencion de la longitud de seccion
            h.L_CON=h.Q_CON/(h.U_CON*pi*h.d_tubos_e*h.N_tubos*...
                LMTD);
            
            % Calculate section area
            h.A_CON=h.Q_CON/(h.U_CON*LMTD);
            
            if isreal(h.L_CON)==0 || isinf(h.L_CON)==1
                % Eliminar FWH si no es posible construir el CON para el
                % TTD proporcionado
                
                h.L_tubos=0;
                h.L_CON=0;
                h.L_SUB=0;
                h.L_tubos=0;
                h.Q_DSH=0;
                h.Q_CON=0;
                h.Q_SUB=0;
                h.Q_exchanged=0;
                h.T_Cout=h.T_Cin;
                h.h_Cout=h.h_Cin;
                
                % Devolver control a funcion invocante, el calculo ha
                % acabado
                return
            end
            
            %%%%%%%%%%%%%%%
            % Calculo de la seccion de subcooling (SUB)
            
            h.T_CSUB_out=h.T_CCON_in;
            h.T_HSUB_in=h.T_HCON_out-h.tol_temp;
            % Se resta -0.1 para garantizar que las entalpias se toman a la
            % izquierda de la campana de cambio de fase
            
            % Propiedades del lado del liquido subenfriado (H)
            %             cp_HSUB=cpmhT_pT(h.P_ex/10,h.T_HSUB_in,h.T_Hout)*1000;
            u_HSUB=eta_pTx_97(h.P_ex/10,(h.T_HSUB_in+h.T_Hout)/2,-1);
            Pr_HSUB=numPr(h.P_ex/10,(h.T_HSUB_in+h.T_Hout)/2,-1);
            k_HSUB=lambda_pTx_97(h.P_ex/10,(h.T_HSUB_in+h.T_Hout)/2,-1);
            
            % Propiedades del lado del agua (C)
            u_CSUB=eta_pTx_97(h.P_C/10,(h.T_CSUB_out+h.T_Cin)/2,-1);
            Pr_CSUB=numPr(h.P_C/10,(h.T_CSUB_out+h.T_Cin)/2,-1);
            k_CSUB=lambda_pTx_97(h.P_C/10,(h.T_CSUB_out+h.T_Cin)/2,-1);
            
            % Coeficiente convectivo en el iterior de los tubos
            ReiSUB=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_CSUB);
            NuiSUB=0.023*ReiSUB^0.8*Pr_CSUB^(1/3);
            hiSUB=NuiSUB*k_CSUB/h.d_tubos_i;
            
            % Coeficiente convectivo en el exterior de los tubos
            ReeSUB=(h.mex+h.md)*h.d_eq/(h.SsSUB*u_HSUB);
            NueSUB=0.36*ReeSUB^0.55*Pr_HSUB^(1/3);
            heSUB=NueSUB*k_HSUB/h.d_eq;
            
            % Coeficiente de transferencia global
            h.U_SUB=1/(h.d_tubos_e/(hiSUB*h.d_tubos_i)...
                +h.d_tubos_e*log(h.d_tubos_e/h.d_tubos_i)/(2*h.k_tubos)...
                +1/heSUB);
            
            % Calor intercambiado en el subcooler
            h_ex_in=h_pTx_97(h.P_ex/10,h.T_HSUB_in,-1);
            h_ex_out=h_pTx_97(h.P_ex/10, h.T_Hout,-1);
            
            Q_ex=h.mex*(h_ex_in-h_ex_out);
            
            % Drainback transfered heat
            if h.x_d~=-1
                h_da_condensed=h_pTx_97(h.P_ex/10,-1,0);
            else
                h_da_condensed=h.h_dA;
            end
            
            Q_db=h.md*(h_da_condensed-h_ex_out);
            
            % Transferred heat
            h.Q_SUB=(Q_ex+Q_db)*1000;
            %             h.Q_SUB=(h.mex+h.md)*cp_HSUB*(h.T_HSUB_in-h.T_Hout);
            
            % Calculate logarithmic mean temperature
            LMTD=((h.T_HSUB_in-h.T_CSUB_out)-(h.T_Hout-h.T_Cin))/...
                (log((h.T_HSUB_in-h.T_CSUB_out)/(h.T_Hout-h.T_Cin)));
            
            % Calculo de la longitud de seccion
            h.L_SUB=h.Q_SUB*h.Np/(h.U_SUB*pi*h.d_tubos_e*h.N_tubos...
                *LMTD);
            
            % Calculate section area
            h.A_SUB=h.Q_SUB/(h.U_SUB*LMTD);
            
            %%%%%%%%%%%%%%%
            % Longitud total de tubos
            h.L_tubos=h.L_DSH+h.L_CON+h.L_SUB;
            
            if isreal(h.L_tubos)==0 || isinf(h.L_tubos)==1
                % Eliminar FWH si no es posible construir el FWH para el
                % TTD proporcionado
                
                h.L_tubos=0;
                h.L_CON=0;
                h.L_SUB=0;
                h.L_tubos=0;
                h.Q_DSH=0;
                h.Q_CON=0;
                h.Q_SUB=0;
                h.Q_exchanged=0;
                h.T_Cout=h.T_Cin;
                h.h_Cout=h.h_Cin;
                
                % Devolver control a funcion invocante, el calculo ha
                % acabado
                return
            end
            
            % Calor total intercambiado
            h.Q_exchanged=(h.Q_DSH+h.Q_CON+h.Q_SUB)/1000;
            
        end
        
        function T2 = DSH_Tout(h,T1)
            % DSH_Tout calcula la temperatura de salida del vapor del DSH a
            % partir de un valor de esa temperatura inicial. Se resuelve el
            % problema iterando con fzero.
            
            % Propiedades del lado del vapor
            cp_sDSH=cpmhT_pT(h.P_ex/10,h.T_Hin,T1)*1000;
            u_sDSH=eta_pTx_97(h.P_ex/10,(h.T_Hin+T1)/2,-1);
            Pr_sDSH=numPr(h.P_ex/10,(h.T_Hin+T1)/2,-1);
            k_sDSH=lambda_pTx_97(h.P_ex/10,(h.T_Hin+T1)/2,-1);
            
            % Recalcular temperatura de entrada del agua de ciclo
            try
                h.T_CDSH_in=fzero(@(T) h.T_CDSH(T,T1),h.T_Cout-1);
            catch
                T2=0+1i;
                return
            end
            
            % Propiedades del lado del agua
            cp_wDSH=cpmhT_pT(h.P_C/10,h.T_Cout,h.T_CDSH_in)*1000;
            u_wDSH=eta_pTx_97(h.P_C/10,(h.T_Cout+h.T_CDSH_in)/2,-1);
            Pr_wDSH=numPr(h.P_C/10,(h.T_Cout+h.T_CDSH_in)/2,-1);
            k_wDSH=lambda_pTx_97(h.P_C/10,(h.T_Cout+h.T_CDSH_in)/2,-1);
            
            % Coeficiente convectivo en el interior de los tubos
            ReiDSH=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_wDSH);
            NuiDSH=0.023*ReiDSH^0.8*Pr_wDSH^(1/3);
            hiDSH=NuiDSH*k_wDSH/h.d_tubos_i;
            
            % Coeficiente convectivo en el exterior de los tubos
            ReeDSH=h.mex*h.d_eq/(h.SsDSH*u_sDSH);
            NueDSH=0.36*ReeDSH^0.55*Pr_sDSH^(1/3);
            heDSH=NueDSH*k_sDSH/h.d_eq;
            
            % Coeficiente de transferencia global
            h.U_DSH=1/(h.d_tubos_e/(hiDSH*h.d_tubos_i)...
                +h.d_tubos_e*log(h.d_tubos_e/h.d_tubos_i)/(2*h.k_tubos)...
                +1/heDSH);
            
            % Temperatura de salida del vapor del DSH
            T2=(h.T_DSH_sat-(h.U_DSH/heDSH)*(h.T_Cout-h.T_Hin*...
                (h.mex*cp_sDSH)/(h.mciclo*cp_wDSH)))...
                /(1-(h.U_DSH/heDSH)*(1-...
                (h.mex*cp_sDSH)/(h.mciclo*cp_wDSH)));
        end
        
        function res = CON_Tsur(h,tsur)
            
            T_liq=(tsur+h.T_CON)/2;
            % Propiedades del lado del vapor. s es propiedades para el
            % vapor no condensado, liq es para el liquido ya condensado que
            % cae sobre los tubos
            rho_sCON=1/v_pTx_97(h.P_ex/10,-1,1);
            rho_liqCON=1/v_pTx_97(h.P_ex/10,T_liq,-1);
            u_liqDSH=eta_pTx_97(h.P_ex/10,T_liq,-1);
            k_liqDSH=lambda_pTx_97(h.P_ex/10,T_liq,-1);
            
            % Parametros de la ecuacion de hdn
            hfg_corr=hfg_p(h.P_ex/10)*1000+0.68*cp_pTx_97(h.P_ex/10,T_liq,-1)...
                *1000*(h.T_CON-tsur);
            A=9.8066*rho_liqCON*(rho_liqCON-rho_sCON)*(k_liqDSH^3)*hfg_corr;
            B=h.Ncolumna*u_liqDSH*h.d_tubos_e*(h.T_CON-tsur);
            
            hdn=0.729*(A/B)^(1/4);
            
            % Parametros para la obtencion de Tsur
            D=h.d_tubos_e/(h.d_tubos_i*h.hiCON)+...
                h.d_tubos_e*log(h.d_tubos_e/h.d_tubos_i)/(2*h.k_tubos);
            
            tmedia=(h.T_CCON_in+h.T_CCON_out)/2;
            
            h.U_CON=1/(D+1/hdn);
            
            %             tsur2=tmedia-h.U_CON*(h.T_CON-tmedia)*D;
            res=tsur-(h.T_CON-h.U_CON*(h.T_CON-tmedia)*D);
            
        end
        
        function dif = T_CDSH(h,Twaterin,Tsteam)
            % Find water input temperature to equalize exchanged heats
            
            % Steam heat
            h_steam_out=h_pTx_97(h.P_ex/10,Tsteam,-1);
            
            Q_steam = h.mex*(h.h_ex-h_steam_out);
            
            % Water side heat
            h_water_in = h_pTx_97(h.P_C/10,Twaterin,-1);
            h_water_out = h_pTx_97(h.P_C/10,h.T_Cout,-1);
            
            Q_water = h.mciclo*(h_water_out-h_water_in);
            
            % Difference
            dif=Q_steam-Q_water;
        end
        
        function res = T_CON_in(h,tin)
            % Given an input temperature tu condenser, calculate difference
            % to expect temperature given absorbed heat in condenser
            
            h_cold_in = h_pTx_97(h.P_C/10,tin,-1);
            h_cold_out = h_pTx_97(h.P_C/10,h.T_CCON_out,-1);
            
            Q_ex_con = h.mciclo * (h_cold_out-h_cold_in) *1000;
            
            res = h.Q_CON - Q_ex_con;
            
        end
        
        function fixed_area_solve(h)
            % Iterate to find cold water output temperature and condensate
            % output temperature
            
            % Set excess heat to 0
            h.Q_EXC_DSH=0;
            h.Q_EXC_CON=0;
            h.Q_EXC_SUB=0;
            
            %%%
            % Start solving subcooling sections
            h.T_HSUB_in=Ts_p_97(h.P_ex/10)-h.tol_temp;
            h.T_CON=Ts_p_97(h.P_ex/10);
            
            % Solve subcooler, using lsqnonlin
            options = optimoptions(@lsqnonlin,'Display','none',...
                'FunctionTolerance', 1e-10,...
                'OptimalityTolerance', 1e-10,...
                'StepTolerance', 1e-10);
            
            % Initial throw (x0)
            x0 = [h.T_HSUB_in - 1, h.T_Cin + 1];
            
            % Lower bound
            lb = [h.T_Cin + h.tol_temp, h.T_Cin + h.tol_temp];
            
            % Upper bound
            ub = [h.T_CON - h.tol_temp, h.T_CON - h.tol_temp];
            
            % Solve
            [T,~,residuals,exitflag, output] = lsqnonlin(@(T) h.solve_built_subcooler(T), ...
                x0, lb, ub,...
                options);
            
            %%%
            %             residuals = h.solve_built_subcooler(T);
            %             fprintf('\t\tres1 = %.10f res2 = %.10f\n',residuals(1),residuals(2));
            
            h.Q_EXC_SUB=residuals;
            %%%
            
            % Store results
            h.T_Hout=T(1);
            h.T_CSUB_out=T(2);
            
            % Exchanged heat
            h_cold_out = h_pTx_97(h.P_C/10, h.T_CSUB_out,-1);
            h.Q_SUB=h.mciclo * (h_cold_out - h.h_Cin);
            
            %%%
            % Solve condenser section, using lsqnonlin
            h.T_CCON_in=h.T_CSUB_out;
            
            % Initial throw (x0)
            x0 = h.T_CCON_in + 1;
            
            % Lower bound
            lb = h.T_CCON_in+h.tol_temp;
            
            % Upper bound
            ub = h.T_CON-h.tol_temp;
            
            %             T_vec=linspace(lb,ub,100);
            %             res=zeros(100,2);
            %             for i=1:100
            %                 res(i,:)=h.solve_built_cond(T_vec(i));
            %             end
            
            % Solve
            [T,~,residuals,exitflag, output] = lsqnonlin(@(T) h.solve_built_cond(T), ...
                x0, lb, ub,...
                options);
            
            %%%
            %             residuals = h.solve_built_cond(T);
            %             fprintf('\t\tres1 = %.10f res2 = %.10f\n',residuals(1),residuals(2));
            
            h.Q_EXC_CON=residuals;
            %%%
            
            % Store result
            h.T_CCON_out=T(1);
            
            % Exchanged heat
            h_cold_in = h_pTx_97(h.P_C/10, h.T_CCON_in, -1);
            h_cold_out = h_pTx_97(h.P_C/10, h.T_CCON_out, -1);
            h.Q_CON=h.mciclo * (h_cold_out - h_cold_in);
            
            %%%
            % Solve de-superheating section (only if FWH has a DSH)
            if h.L_DSH > 0
                % Store cold input temperature
                h.T_CDSH_in = h.T_CCON_out;
                
                % Solve using lsqnonlin
                % Initial throw (x0)
                x0 = [h.T_CON + 1, h.T_CCON_out + 1];
                
                % Lower bound
                lb = [h.T_CON + h.tol_temp, h.T_CCON_out + h.tol_temp];
                
                % Upper bound
                ub = [h.T_Hin-h.tol_temp, h.T_Hin-h.tol_temp];
                
                % Solve
                [T,~,residuals,exitflag, output] = lsqnonlin(@(T) h.solve_built_dsh(T), ...
                    x0, lb, ub,...
                    options);
                
                %%%
                %                 residuals = h.solve_built_dsh(T);
                %                 fprintf('\t\tres1 = %.10f res2 = %.10f\n',residuals(1),residuals(2));
                
                h.Q_EXC_DSH=residuals;
                %%%
                
                % Store results
                h.T_HDSH_out=T(1);
                h.T_Cout=T(2);
                
                % Exchanged heat
                h_c_in = h_pTx_97(h.P_C/10, h.T_CDSH_in, -1);
                h_c_out = h_pTx_97(h.P_C/10, h.T_Cout, -1);
                h.Q_DSH = h.mciclo * (h_c_out-h_c_in);
                
            else
                h.Q_DSH=0;
                h.T_Cout=h.T_CCON_out;
            end
            
            % Recalculate enthalpies
            h.h_Cout=h_pTx_97(h.P_C/10,h.T_Cout,-1);
            h.h_Hout=h_pTx_97(h.P_ex/10,h.T_Hout,-1);
            
            % Recalculate TTD and DCA
            h.TTD=Ts_p_97(h.P_ex/10)-h.T_Cout;
            h.DCA=h.T_Hout-h.T_Cin;
            
            % Recalculate exchanged heat
            h.Q_exchanged=h.Q_DSH+h.Q_CON+h.Q_SUB;
            
            % Recalculate global U·A coefficient
            LMTD=((h.T_Hin-h.T_Cout)-(h.T_Hout-h.T_Cin))/...
                log((h.T_Hin-h.T_Cout)/(h.T_Hout-h.T_Cin));
            h.UA=h.Q_exchanged/LMTD;
            
            % Calculate deviation
            h.dev_calc();
            
            
        end
        
        function res = solve_built_subcooler(h,t)
            % Calculate global heat transfer coefficient U
            % t -> Two row vector
            % res -> Solution vector
            
            % T(1) T_con_out -> Condensate (hot fluid) output temperature
            % T(2) T_water_out -> Feed water (cold fluid) output temperature
            
            T_con_out=t(1);
            T_water_out=t(2);
            
            % Propiedades del lado del liquido subenfriado (H)
            u_HSUB=eta_pTx_97(h.P_ex/10,(h.T_HSUB_in+T_con_out)/2,-1);
            Pr_HSUB=numPr(h.P_ex/10,(h.T_HSUB_in+T_con_out)/2,-1);
            k_HSUB=lambda_pTx_97(h.P_ex/10,(h.T_HSUB_in+T_con_out)/2,-1); % [W/mK]
            
            % Propiedades del lado del agua (C)
            u_CSUB=eta_pTx_97(h.P_C/10,(T_water_out+h.T_Cin)/2,-1);
            Pr_CSUB=numPr(h.P_C/10,(T_water_out+h.T_Cin)/2,-1);
            k_CSUB=lambda_pTx_97(h.P_C/10,(T_water_out+h.T_Cin)/2,-1); % [W/mK]
            
            % Coeficiente convectivo en el interior de los tubos
            ReiSUB=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_CSUB);
            NuiSUB=0.023*ReiSUB^0.8*Pr_CSUB^(1/3);
            hiSUB=NuiSUB*k_CSUB/h.d_tubos_i;
            
            % Coeficiente convectivo en el exterior de los tubos
            ReeSUB=(h.mex+h.md)*h.d_eq/(h.SsSUB*u_HSUB);
            NueSUB=0.36*ReeSUB^0.55*Pr_HSUB^(1/3);
            heSUB=NueSUB*k_HSUB/h.d_eq;
            
            % Coeficiente de transferencia global
            h.U_SUB=1/(h.d_tubos_e/(hiSUB*h.d_tubos_i)...
                +h.d_tubos_e*log(h.d_tubos_e/h.d_tubos_i)/(2*h.k_tubos)...
                +1/heSUB);
            
            % Calculate Q=U*A*TLM
            LMTD=((h.T_HSUB_in-T_water_out)-(T_con_out-h.T_Cin))/...
                log((h.T_HSUB_in-T_water_out)/(T_con_out-h.T_Cin));
            
            % Same difference at both terminals
            if isnan(LMTD)
                LMTD=(h.T_HSUB_in-T_water_out);
            end
            
            % Units: kW
            Q_UALMTD=h.U_SUB*h.A_SUB*LMTD / 1000;
            
            % Calculate exchanged heat at hot side
            h_ex_in=h_pTx_97(h.P_ex/10,-1,0);
            h_ex_out=h_pTx_97(h.P_ex/10, T_con_out,-1);
            
            Q_ex=h.mex*(h_ex_in-h_ex_out);
            
            % Drainback transfered heat
            if h.x_d~=-1
                h_da_condensed=h_pTx_97(h.P_ex/10,-1,0);
            else
                h_da_condensed=h.h_dA;
            end
            
            Q_db=h.md*(h_da_condensed-h_ex_out);
            
            % Calculate exchanged heat at cold side
            h_cold_out = h_pTx_97(h.P_C/10, T_water_out,-1);
            Q_ex_cold=h.mciclo * (h_cold_out - h.h_Cin);
            
            % Return value
            res=[0;0];
            res(1)=Q_UALMTD-Q_ex-Q_db;
            res(2)=Q_ex_cold-Q_ex-Q_db;
            
        end
        
        function res = solve_built_cond(h,T)
            
            % Solve for condenser output temperature
            T_cold_out=T(1); % agua a la salida
            
            % Calculo de la seccion de condesacion (CON)
            h.T_HCON_in=h.T_CON; % vapor a la entrada
            h.T_HCON_out=h.T_CON; % vapor a la salida
            h.T_CCON_out=T_cold_out;
            
            % Propiedades del agua, lado de los tubos (C)
            u_CCON=eta_pTx_97(h.P_C/10,(T_cold_out+h.T_CCON_in)/2,-1);
            Pr_CCON=numPr(h.P_C/10,(T_cold_out+h.T_CCON_in)/2,-1);
            k_CCON=lambda_pTx_97(h.P_C/10,(T_cold_out+h.T_CCON_in)/2,-1);
            
            % Coeficiente convectivo en el interior de los tubos
            ReiCON=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_CCON);
            NuiCON=0.023*ReiCON^0.8*Pr_CCON^(1/3);
            h.hiCON=NuiCON*k_CCON/h.d_tubos_i;
            
            % Obtencion de la temperatura de superficie de tubos, necesaria
            % para obtener el valor de U_CON
            % Set tolerance to e-12
            options = optimset('Tolx',1e-12);
            
            funsur=@(tsur) h.CON_Tsur(tsur);
            h.T_CON_sur=fzero(funsur,[h.T_CON-0.01, h.T_CCON_in],options);
            
            % Solve Q = U*A*LMTD
            U_con=h.U_CON; % Obtained in h.CON_Tsur
            A_con=h.A_CON;
            
            % LMTD
            LMTD = ((h.T_CON - T_cold_out) - (h.T_CON - h.T_CCON_in))/...
                log((h.T_CON - T_cold_out) / (h.T_CON - h.T_CCON_in));
            
            % Same difference at both terminals
            if isnan(LMTD)
                LMTD=(h.T_CON - T_cold_out);
            end
            
            % Exchanged heat, UA [kW]
            Q_ex_UA = U_con*A_con*LMTD / 1000;
            
            % Condensed heat
            if h.x_ex==-1
                Q_condensed=h.mex*hfg_p(h.P_ex/10);
            else
                Q_condensed=h.mex*h.x_ex*hfg_p(h.P_ex/10);
            end
            
            % Residual heat coming from desuperheater
            if h.x_ex==-1
                if h.L_DSH>0
                    T_out_DSH=h.T_HDSH_out;
                else
                    T_out_DSH=h.T_Hin;
                end
                
                h_dsh_residual=h_pTx_97(h.P_ex/10,T_out_DSH,-1);
                h_con=h_pTx_97(h.P_ex/10,-1,1); % Enthalpy at beggining of condensation
                
                Qresidual=h.mex*(h_dsh_residual-h_con);
            else
                Qresidual=0;
            end
            
            % calor cedido por el vapor del drainback
            if (h.md>0)&&(h.x_d~=-1)
                Qdrain=h.md*h.x_d*hfg_p(h.P_ex/10);
            else
                Qdrain=0;
            end
            
            % Cold side absorbed heat
            h_cold_in = h_pTx_97(h.P_C/10, h.T_CCON_in, -1);
            h_cold_out = h_pTx_97(h.P_C/10, T_cold_out, -1);
            Q_cold = h.mciclo * (h_cold_out - h_cold_in);
            
            % Give results
            res=[0;0];
            res(1) = Q_ex_UA - Q_condensed - Qresidual - Qdrain;
            res(2) = Q_cold - Q_condensed - Qresidual - Qdrain;
            
        end
        
        function res = solve_built_dsh(h,T)
            % Solve a built de super heater
            % T -> T(1) = Desuperheater steam output temperature
            %      T(2) = Feed water output temperature
            
            % res -> Exchanged heat
            
            T_hot_out = T(1);
            T_cold_out = T(2);
            
            % Propiedades del lado del vapor
            u_sDSH=eta_pTx_97(h.P_ex/10,(h.T_Hin+T_hot_out)/2,-1);
            Pr_sDSH=numPr(h.P_ex/10,(h.T_Hin+T_hot_out)/2,-1);
            k_sDSH=lambda_pTx_97(h.P_ex/10,(h.T_Hin+T_hot_out)/2,-1);
            
            % Propiedades del lado del agua
            u_wDSH=eta_pTx_97(h.P_C/10,(T_cold_out+h.T_CDSH_in)/2,-1);
            Pr_wDSH=numPr(h.P_C/10,(T_cold_out+h.T_CDSH_in)/2,-1);
            k_wDSH=lambda_pTx_97(h.P_C/10,(T_cold_out+h.T_CDSH_in)/2,-1);
            
            % Coeficiente convectivo en el interior de los tubos
            ReiDSH=h.mciclo*h.Np*4/(h.N_tubos*pi*h.d_tubos_i*u_wDSH);
            NuiDSH=0.023*ReiDSH^0.8*Pr_wDSH^(1/3);
            hiDSH=NuiDSH*k_wDSH/h.d_tubos_i;
            
            % Coeficiente convectivo en el exterior de los tubos
            ReeDSH=h.mex*h.d_eq/(h.SsDSH*u_sDSH);
            NueDSH=0.36*ReeDSH^0.55*Pr_sDSH^(1/3);
            heDSH=NueDSH*k_sDSH/h.d_eq;
            
            % Coeficiente de transferencia global
            h.U_DSH=1/(h.d_tubos_e/(hiDSH*h.d_tubos_i)...
                +h.d_tubos_e*log(h.d_tubos_e/h.d_tubos_i)/(2*h.k_tubos)...
                +1/heDSH);
            
            % Get exchanged heats
            % Q = UA*LMTD
            LMTD = ((h.T_Hin - T_cold_out) - (T_hot_out - h.T_CDSH_in))/...
                log((h.T_Hin - T_cold_out) / (T_hot_out - h.T_CDSH_in));
            
            % Same difference at both terminals
            if isnan(LMTD)
                LMTD=(h.T_Hin - T_cold_out);
            end
            
            % Heat [kW]
            Q_UALMTD = h.U_DSH * h.A_DSH * LMTD / 1000;
            
            % Hot side exchanged heat
            h_ex_in = h.h_ex;
            h_ex_out = h_pTx_97(h.P_ex/10, T_hot_out, -1);
            
            if h.x_ex==-1
                Q_ex = h.mex * (h_ex_in-h_ex_out);
            else
                Q_ex = h.mex * h.x_ex*(h_ex_in-h_ex_out);
            end
            
            % Cold side absorbed heat
            h_c_in = h_pTx_97(h.P_C/10, h.T_CDSH_in, -1);
            h_c_out = h_pTx_97(h.P_C/10, T_cold_out, -1);
            Q_cold = h.mciclo * (h_c_out-h_c_in);
            
            % Give results
            res=[0;0];
            res(1)=Q_UALMTD-Q_ex;
            res(2)=Q_cold-Q_ex;
            
        end
        
    end
end
