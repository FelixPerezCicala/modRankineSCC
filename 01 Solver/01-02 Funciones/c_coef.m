function [C_VSLO, C_PACK] = c_coef(tur_type)
% Return loss coefficents C depending on turbine type
%   Using input parameter tur_type, a string containing the turbine type
%   (A,B,C,D,E,F,G,H,I,K) return vector containing coeffient values. Input
%   parameter sub_type is used for certain tubine types, and is a string
%   containing the sub type (A,B,C,D,E,F)
%   C_VSLO is a 3-column vector containing the necessary C values fot the
%   calculation of valve steam leakages
%   C_PACK is a 7 column vector containing the necessary C values fot the
%   calculation of shaft end packings leakages

% Import C coefficient values
source_table=fopen('c_constants.txt');
c_table=fscanf(source_table,'%f,',[7 Inf])';
fclose(source_table);

% Turbine types number of sub-type rows
sub_rows=[0,2,6,5,2,2,3,3,1,1,1,2];

% Find C values corresponding to turbine type
alphabet='ABCDEFGHIJK';
row=sum(sub_rows(1:find(alphabet==tur_type(1))))+find(alphabet==tur_type(2));

% Return C_PACK values
C_PACK=c_table(row,:);

% Return C_VSLO values, for Reheat-subcritical subtype. Other options not
% implemented
C_VSLO=[56,50,0];

end

