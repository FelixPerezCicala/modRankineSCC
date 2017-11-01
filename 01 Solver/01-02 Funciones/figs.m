function z=figs(figure,x,y,opt)

% Use this function to obtain the outputs from the Figures presented in the
% paper "A Method for Predicting Performance of Steam Turbine Generators 
% 16500 KW and Larger"

% To use the function, the first input argument is a string specifying
% which figure to evaluate. For example, 'Fig2'. The other input arguments
% vary depending on the figure.

% The input units are always International System Units (exmple: m3/s)
% The poylnomials given in the paper for the Figures are in imperial units
% however, so the appropiate conversions are made when necessary

% Unit conversion constants:
cuft_cumtr=0.028316846592^-1; % Cubic feet / cubic meter
secs_hour=3600; % Seconds in an hour
kJ_btu=1.055; % kJ / BTU
kg_lb=0.45359237; % kg / lb
K_F=5/9; % Degrees Kelvin / Degrees Fahrenheit (valid for intervals only)
inHg_bar=29.53; % Inches Mercury / bar 
ft_m=3.28084; % Foot / meter

switch figure
    case 'Fig2'
        % Figure 2: Nonreheat condensing, 2-row governing stage, design
        % flow and efficiency correction for governing stage pressure ratio
        
        % Inputs:
        %   x -> Pressure at exit of governing stage at design flow
        %        --------------------------------------------------
        %                         Throttle Pressure
        %
        %   y -> Volume Flow
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Volume Flow (m^3/s)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the polynomials
        A=fliplr([0,-1.6649986,-22.538964,19.464851]);
        B=fliplr([0,798267.5,-7540.7,-154269.4]);
        
        % Calculate x value
        x=0.625-x;
        
        % Convert volume flow to Cubic Feet/Hr, from m^3/s
        y=y*cuft_cumtr*secs_hour;
        
        % Calculate output
        z=polyval(A,x)+polyval(B,x)/y;
        
     case 'Fig3'
        % Figure 3: Nonreheat condensing, 2-row governing stage, part load
        % efficiency correction for throttle flow ratio
        
        % Inputs:
        %   x -> Throttle Flow Ratio
        
        % Units:
        %   x -> Adimensional (ratio)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the polynomials
        A=fliplr([0,2.4462684,-41.904570,-164.13062,...
            -485.99735,-674.41251,-342.16474]);
        
        % Calculate x value
        x=log10(x);
        
        % Calculate output
        z=polyval(A,x);
        
     case 'Fig4'
        % Figure 4: Nonreheat condensing, 2-row governing stage, part load
        % efficiency correction for governing stage pressure ratio
        
        % Inputs:
        %   x -> Throttle Flow Ratio
        %   y -> Throttle Pressure
        %        -----------------------------------
        %        Pressure at exit of Governing stage at Desing Flow
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Adimensional (ratio)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[0,0,0,0,0;...
            -24.899722,63.299521,-75.518221,37.084109,0;...
            -0.71362812,-23.404163,126.77247,-102.17991,0;...
            -17.632581,-308.12317,594.36987,-269.89024,0];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Calculate y value
        y=0.625-y^-1;
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
%      case 'Fig5'
%         % Figure 5: Nonreheat condensing, 2-row governing stage, efficiency
%         % correction for mean-of-valve loops
%         
%         % Inputs:
%         %   x -> Throttle Flow Ratio
%         
%         % Units:
%         %   x -> Adimensional (ratio)
%         
%         % Output: Percentage change in efficiency
%         
%         % Coefficients of the polynomials
%         A=fliplr([-1.771,3.475,-3.389,1.445]);
%                 
%         % Calculate output
%         z=polyval(A,x);
        
     case 'Fig6'
        % Figure 6: 3600-rpm high pressure turbine section, 1-row governing
        % stage, design flow effciency correction for pressure ratio
        
        % Inputs:
        %   x -> Exhaust pressure at design flow
        %        -----------------------------------
        %        Rated Throttle Pressure
        %   y -> Design volume Flow at turbine inlet
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Volume Flow (m^3/s)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[11.151,-63;...
            -0.50091,2.83];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Convert volume flow to Cubic Feet/Hr, from m^3/s
        y=y*cuft_cumtr*secs_hour;
        
        % Calculate y
        y=log(y);
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig7'
        % Figure 7: 3600-rpm high pressure turbine section, 1-row governing
        % stage, design flow efficiency correction for governing stage
        % pitch diameter
        
        % Inputs:
        %   x -> Pitch diameter
        
        % Units:
        %   x -> Length (m)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the polynomials
        A=fliplr([4.37,-0.115]);
        
        % Convert x to inches
        x=convlength(x,'m','in');
                
        % Calculate output
        z=polyval(A,x);
        
     case 'Fig8'
        % Figure 8: 3600-rpm high pressure turbine section, 1-row governing
        % stage, part load effiency correction for governing stage pitch
        % diameter
        
        % Inputs:
        %   x -> Throttle flow ratio
        %   y -> Stage pitch diameter
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Length (m)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[-21.8085,21.8085;...
            0.573908,-0.573908];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Convert y to inches
        y=convlength(y,'m','in');
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig9'
        % Figure 9: 3600-rpm high pressure turbine section, 1-row governing
        % stage, part load effiency correction for throttle flow ratio
        
        % Inputs:
        %   x -> Throttle flow ratio
        %   y -> Rated Throttle Pressure
        %        -----------------------------------
        %        Exhaust pressure at design flow
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Adimensional (ratio)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[-60.75,66.85,29.75,-35.85;...
            17.50,-20.02,-0.525,3.045];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Calculate y
        y=log(y);
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig10'
        % Figure 10: 3600-rpm high pressure turbine section, 2-row governing
        % stage, design flow effciency correction for pressure ratio
        
        % Inputs:
        %   x -> Exhaust pressure at design flow
        %        -----------------------------------
        %        Rated Throttle Pressure
        %   y -> Design volume Flow
        
        % Units:
        %   x -> Adimensional (ratio)
        %   y -> Volume Flow (m^3/s)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[25.665,-145;...
            -1.33281,7.53];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Convert volume flow to Cubic Feet/Hr, from m^3/s
        y=y*cuft_cumtr*secs_hour;
        
        % Calculate y
        y=log(y);
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig11'
        % Figure 11: 3600-rpm high pressure turbine section, 2-row governing
        % stage, part load effiency correction for throttle flow ratio
        
        % Inputs:
        %   x -> Throttle flow ratio
        %   y -> Rated Throttle Pressure
        %        -----------------------------------
        %        Exhaust pressure at design flow
        
        % Units:
        %   x -> Volume Flow (m^3/s)
        %   y -> Adimensional (ratio)
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[0,42.676909,-89.391147,9.0376638;...
            0,-26.221836,25.549385,8.8283868;...
            0,4.0479550,-1.4725197,-4.0183332;...
            0,-0.14502211,-0.18580363,0.42657518];
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Calculate x value
        x=1-x;
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig13'
        % Figure 13: 3600-rpm intermediate pressure turbine section, without
        % governing stage, section effiency
        
        % Inputs:
        %   x -> Bowl initial volume flow
        %   y -> Initial Bowl Conditions
        %        -----------------------------------
        %        Exhaust pressure at design flow
        
        % Units:
        %   x -> Volume Flow (m^3/s)
        %   y -> Adimensional (ratio)
        
        % Output: Internal efficiency (percentage)
        
        % Coefficients
        A=90.799+0.7474*log(y-0.3)-0.5454/log(y-0.3);
        B=-505000+77568*log(y+0.8)-1262500/log(y+0.8);
        
        % Convert volume flow to Cubic Feet/Hr, from m^3/s
        %x=x*cuft_cumtr*secs_hour;
        
        % Calculate output
        z=A+B/x;
        
     case 'Fig14'
        % Figure 14: 3600- and 1800-rpm, reheat and nonreheat condensing
        % section, efficiency correction for initial steam conditions
        
        % Inputs:
        %   x -> Initial pressure
        %   y -> Enthalpy
        %   opt -> Initial entropy
        
        % Units:
        %   x -> Pressure (bar)
        %   y -> Enthalpy (kJ/kg)
        %   opt -> Entropy (kJ/(kg/K))
        
        % Output: Percentage change in efficiency
        
        % Coefficients of the bivariate polynomial. First row is A00,
        % A01,...,A04, second row is A10,A11,...,A14. The coefficient Aji
        % is for Aji*y^j*x^i
        A=[28.232252,-92.390491,-625.79590,207.23010,70.251642,-22.516388;...
            -0.047796308,1.2844571,0.38556961,-0.039652999,-0.27180357,0.064869467;...
            -0.69791427*10^-3,-0.17037268*10^-2,0.86563845*10^-3,-0.59510660*10^-3,0.39705804*10^-3,-0.73533255*10^-4;...
            0.12050837*10^-5,0.26826382*10^-6,-0.67887771*10^-6,0.52886157*10^-6,-0.24106229*10^-6,0.37881801*10^-7;...
            -0.50719109*10^-9,0.26393497*10^-9,0.38021911*10^-10,-0.10149993*10^-9,0.47757232*10^-10,-0.70989561*10^-11];
        
        % Convert x to PSI
        x=convpres(x*10^5,'pa','psi');
                
        % Calculate x value
        x=log10(x);
        
        % Convert enthalpy to BTU/lb
        y=y*kJ_btu^-1*kg_lb;
        
        % Convert entropy to BTU/(lb*F)
        s=opt;
        s=s*kJ_btu^-1*kg_lb*K_F;
        
        if s>2.0041
            HT=1154+80*x+88*x^2;
            y=min(y,HT);
        end
        
        % Transform matrix for polyvaln
        A=flip(flip(A,1)',1);
        
        % Calculate output
        z=polyvaln(A,[x,y]);
        
     case 'Fig15'
        % Figure 15: 3600- and 1800-rpm, reheat and nonreheat condensing
        % section, correction to expansion line end point for exhaust
        % pressure
                
        % Inputs:
        %   x -> Exhaust pressure
        
        % Units:
        %   x -> Pressure (bar)
        
        % Output: Change in expansion line end point with 0 percent
        % moisture (kj/kg)
        
        % Coefficients of the polynomials
        A=fliplr([-23.984811,57.862440,3.1849404]);
        
        % Convert x to in. Hg. Abs.
        x=x*inHg_bar;
                        
        % Calculate output
        z=polyval(A,log(x));
        
        % Convert output to kJ/kg
        z=z*kJ_btu/kg_lb;
        
    case 'Fig16'
        % Figure 16: 3600-rpm condensing section, exhaust loss
                
        % Inputs:
        %   x -> Annulus velocity
        %   y -> Configuration (Table III column)
        
        % Units:
        %   x -> Speed (m/s)
        %   y -> Adimensional. Integer from 1 to 5
        
        % Output: Exhaust loss (kj/kg)
        
        % Import table data
%         source_table=fopen('table_3.txt');
%         t3=fscanf(source_table,'%f,',[10 Inf])';
%         fclose(source_table);
        
        t3=opt;
        
        % Convert speed to ft/sec
        x=x*ft_m;
        
        % Obtain output value interpolating from table
        z=interp1(t3(:,1),t3(:,y+1),x,'spline');
        
        % Convert output value to kJ/kg from BTU/lb
        z=z*kJ_btu/kg_lb;
        
    case 'Fig17'
        % Figure 17: 1800-rpm condensing section, exhaust loss
                
        % Inputs:
        %   x -> Annulus velocity
        %   y -> Configuration (Table III column)
        
        % Units:
        %   x -> Speed (m/s)
        %   y -> Adimensional. Integer from 1 to 3
        
        % Output: Exhaust loss (kj/kg)
        
        % Import table data
%         source_table=fopen('table_3.txt');
%         t3=fscanf(source_table,'%f,',[10 Inf])';
%         fclose(source_table);
        
        t3=opt;
        
        % Convert speed to ft/sec
        x=x*ft_m;
        
        % Obtain output value interpolating from table. Use spline
        % interpolation if the requested speed is within table bounds. Use
        % linear interpolation using 2 last values otherwise
        if x < t3(1,1)
            slope=(t3(2,y+6)-t3(1,y+6))/(t3(2,1)-t3(1,1));
            z=t3(1,y+6)+(x-t3(1,1))*slope;
        elseif x > t3(end,1)
            % Warning: Not correct. Should use special case for supersonic
            % exhaust. But this case is rather rare so...
            
            slope=(t3(end,y+6)-t3(end-1,y+6))/(t3(end,1)-t3(end-1,1));
            z=t3(end,y+6)+(x-t3(end,1))*slope;
        else
            z=interp1(t3(:,1),t3(:,y+6),x,'spline');
        end
        
        % Convert output value to kJ/kg from BTU/lb
        z=z*kJ_btu/kg_lb;
                
    case 'Fig18'
        % Figure 18: 3600-rpm condensing section, exhaust loss for high
        % back-pressure units
                
        % Inputs:
        %   x -> Annulus velocity
        
        % Units:
        %   x -> Speed (m/s)
        
        % Output: Exhaust loss (kj/kg)
        
        % Import table data
%         source_table=fopen('table_3.txt');
%         t3=fscanf(source_table,'%f,',[10 Inf])';
%         fclose(source_table);
        
        t3=opt;
        
        % Convert speed to ft/sec
        x=x*ft_m;
        
        % Obtain output value interpolating from table
        z=interp1(t3(:,1),t3(:,7),x,'spline');
        
        % Convert output value to kJ/kg from BTU/lb
        z=z*kJ_btu/kg_lb;
        
    otherwise
        fprintf('No such figure\n');
end

end