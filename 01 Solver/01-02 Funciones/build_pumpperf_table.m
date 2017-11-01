function tab_perf = build_pumpperf_table()
%build_pumpperf_table Build pump isentropic performance table
% Input .dat files:
%       First column corresponds to Q/Qn values (flow / nominal flow)
%       Second column corresponds to H/Hn values (head / nominal head)

% Performance values of the curves to be imported
n_values=[0.8,0.78,0.72,0.64,0.56,0.48];

% Filenames
filenames={'curva 078.dat';...
    'curva 072.dat';...
    'curva 064.dat';...
    'curva 056.dat';...
    'curva 048.dat'};

% Storage variable
data_cell=cell(length(filenames)+1,2);

% Maximum performance point (0.8)
data_cell{1,1}=100;
data_cell{1,2}=100;

% Number of data points. Initial point is the max performance point
num_points=zeros(length(filenames)+1,1);
num_points(1,1)=1;

% Read files
for f=1:length(filenames)
    fid = fopen(filenames{f},'r');
    data = textscan(fid, '%f%f%f', 'HeaderLines', 0);
    fclose(fid);
    
    data_cell{f+1,1}=data{1};
    data_cell{f+1,2}=data{2};
    
    num_points(f+1)=length(data{1});
end

% Build table for interpolation use
% Column 1: Q/Qn
% Column 1: H/Hn
% Column 1: Isentropic performance
tab_perf=zeros(sum(num_points),3);

for f=1:length(filenames)+1
    
    p=1;
    
    while p <= num_points(f)
        
        tab_perf(sum(num_points(1:f-1))+p,1)=data_cell{f,1}(p)/100;
        tab_perf(sum(num_points(1:f-1))+p,2)=data_cell{f,2}(p)/100;
        
        tab_perf(sum(num_points(1:f-1))+p,3)=n_values(f);
        
        p=p+1;
    end    
end


end

