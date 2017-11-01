function cycle_solver(cy_conf)
%cycle_solver Solve a cy_conf, using parameters
% Run results windows when ended

% Ensure graphics performance
close all

% Build objects for calculation
cycle_1=cy_conf.to_cycle();
cycle_2=cy_conf.to_cycle();

% Get pump performance tables
pmp_perf_table=build_pumpperf_table();
table_3=build_figs_table3();

cycle_1.store_tables(pmp_perf_table, table_3);
cycle_2.store_tables(pmp_perf_table, table_3);

% Initialize
cycle_1.ini;
cycle_2.ini;
%%%%%%%%

% Loads to be calculated, defined as mass flow. Calculate from design load
% to 20% of nominal performance, in steps of -10kg/s
step=cy_conf.pl_TFR_step;
min_TFR=cy_conf.pl_TFR_min;
max_TFR_mass=cycle_1.m_HTR_d;
min_TFR_mass=max_TFR_mass*min_TFR;
step_mass=max_TFR_mass*step;

mass=cycle_1.m_HTR_d:-step_mass:min_TFR_mass;

% Auto bypass control
auto_bypass_limit_DCA=0; % Maximum DCA value. Set to 0 to disable auto bypass
auto_bypass_limit_TTD=-100; % Minimum TTD value
auto_bypass_hitcount=10; % Number of times a FWH must exceed DCA or TTD for it to be bypasses
enable_auto_last_FWH=false; % Enable or disable auto bypass for last FWH

% Iteration control
max_iter=cy_conf.max_iterations; % Maximum number of iterations
dev_tol=cy_conf.tolerance_dev; % Deviation tolerance
res_tol=cy_conf.tolerance_res; % Residuals tolerance
df=cy_conf.dampening_factor; % Dampening factor

%%%%%%%%%%%%%%%%
bypass=zeros(1,cy_conf.N_FWH);

% Use single thread or multi thread
if cy_conf.num_cores==-1
    % Use single thread
    
    % Storage vectors
    cycles_1=cell(length(mass),1);
    cycles_2=cell(length(mass),1);
    
    % Create waitbar
    wb = waitbar(0,'','Name','Solving cycle... Progress: 0 %');
    
    % Start timer
    tic;
    
    % Constant pressure
    for i=1:length(mass)
        % Copy initialized cycle to storage (constant)
        cycles_1(i)={copy(cycle_1)};
        
        % Solve cycle (constant)
        cycles_1{i}.solv_PL(mass(i),bypass, auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
            auto_bypass_hitcount, enable_auto_last_FWH,...
            'constant', max_iter, dev_tol, res_tol,2,df);
        
        % Update waitbar
        wb.Name=sprintf('Solving cycle... Progress: %.0f %%',i/(length(mass)*2)*100);
        waitbar(i/(length(mass)*2),wb,'');
    end
    
    % Sliding pressure
    for i=1:length(mass)
        % Copy initialized cycle to storage (sliding)
        cycles_2(i)={copy(cycle_2)};
        
        % Solve cycle (sliding)
        cycles_2{i}.solv_PL(mass(i),bypass, auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
            auto_bypass_hitcount, enable_auto_last_FWH,...
            'sliding', max_iter, dev_tol, res_tol,2,df);
        
        % Update waitbar
        wb.Name=sprintf('Solving cycle... Progress: %.0f %%',...
            (i+length(mass))/(length(mass)*2)*100);
        waitbar((i+length(mass))/(length(mass)*2),wb,'');
    end
    
    % Store consumed time
    cy_conf.time_to_solve=toc;
    
    % Close waitbar
    close(wb);
else
    % Use multithread
    
    %%%%
    delete(gcp('nocreate'))
    %%%%
    
    %%%% Start parallel processing pool
    parpool(cy_conf.num_cores);
    %%%%
    
    % Storage vectors
    cycles_1=cell(length(mass),1);
    cycles_2=cell(length(mass),1);
        
    % Create progress bar
    strWindowTitle='Solving cycle... ';
    nNumIterations=size(mass,2)*2;
    
    ppm = ParforProgMon(strWindowTitle, nNumIterations);
    
    % Start timer
    tic;
    
    % Calculate each cycle at requested loads
    % Constant pressure
    parfor i=1:length(mass)
        % Copy initialized cycle to storage (constant)
        cycles_1(i)={copy(cycle_1)};
        
        % Solve cycle (constant)
        cycles_1{i}.solv_PL(mass(i),bypass, auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
            auto_bypass_hitcount, enable_auto_last_FWH,...
            'constant', max_iter, dev_tol, res_tol,2,df);
        
        % Update bar
        ppm.increment();
    end
    
    % Sliding pressure
    parfor i=1:length(mass)
        % Copy initialized cycle to storage (sliding)
        cycles_2(i)={copy(cycle_2)};
        
        % Solve cycle (sliding)
        cycles_2{i}.solv_PL(mass(i),bypass, auto_bypass_limit_DCA, auto_bypass_limit_TTD,...
            auto_bypass_hitcount, enable_auto_last_FWH,...
            'sliding', max_iter, dev_tol, res_tol,2,df);
        
        % Update bar
        ppm.increment();
    end
    
    % Store consumed time
    cy_conf.time_to_solve=toc;
    
    % Delete performance progress bar
    delete(ppm);
    
    %%%%
    delete(gcp('nocreate'))
    %%%%
end

% Calculate total number of iterations to solution
iters=0;
for i=1:length(mass)
    iters=iters+cycles_1{i}.iter_pl+cycles_2{i}.iter_pl;
end
cy_conf.iterations_to_solve=iters;

% Show next gui
draw_PLcycle_par(cycles_1,cycles_2,cy_conf,false,'gui_solve','');

end

