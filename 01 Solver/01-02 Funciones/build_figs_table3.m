function [ t3 ] = build_figs_table3()
%build_figs_table3 Build table 3, needed for FIGS operation
source_table=fopen('table_3.txt');
t3=fscanf(source_table,'%f,',[10 Inf])';
fclose(source_table);
end

