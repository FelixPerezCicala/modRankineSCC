function pmp_isen_perf = pump_perf(Q, Qn, H, Hn, tab_perf, nise_offset)
%pump_perf Return pump isentropic perfomance
%   Return isentropic perfomance at part load, using data in table

% Create polygon for last performance value
xV = tab_perf(tab_perf(:,3)==min(tab_perf(:,3)),1);
yV = tab_perf(tab_perf(:,3)==min(tab_perf(:,3)),2);

% Close circle
xV=[xV;xV(1)];
yV=[yV;yV(1)];

% Check if the input values are within the lower performance value. If
% they are, return lower perfornace value. Else return interpolated
% performance value
if ~inpolygon(Q/Qn,H/Hn,xV,yV)
    pmp_isen_perf=min(tab_perf(:,3));
else
    %         pmp_isen_perf=biharmonic_spline_interp2(tab_perf(:,1),tab_perf(:,2),tab_perf(:,3),...
    %             Q/Qn,H/Hn);
    
    pmp_isen_perf=griddata(tab_perf(:,1),tab_perf(:,2),tab_perf(:,3),...
        Q/Qn,H/Hn,...
        'cubic');
end

% Apply offset
pmp_isen_perf=pmp_isen_perf+nise_offset;



end

