function [txt] = cross(ax, xy, s1, s2, s3, s4, fontsize, txt_obj)
%connect Draw a croos with text
% Return text object handles. s1 s2 s3 s4 are text strings in cross,
% starting at top left and advancing in clockwise direction

% If nargin==7 -> New cross is created
% If nargin==8 -> txt_obj cross is modified to s1,s2,s3,s4 strings

% Normally: s1 = 'bar', s2 = 'kg/s', s3 = 'kJ/kg', s4 = 'ºC'

if nargin==7
    % Create cross
    
    % Calculate lines
    width=12;
    height=5;
    
    pos_lin1=[xy(1), xy(2) + height/2;...
        xy(1)+width, xy(2) + height/2];
    
    pos_lin2=[xy(1)+width/2, xy(2);...
        xy(1)+width/2, xy(2) + height];
    
    % Draw text
    margin_hor=0.5;
    margin_ver=0.5;
    
    if ~ischar(s1)
        s1=num2str(s1,'%.2f');
        s2=num2str(s2,'%.2f');
        s3=num2str(s3,'%.1f');
        s4=num2str(s4,'%.1f');
    end
    
    t1=text(ax,xy(1)+width/2-margin_hor,xy(2)+height/2+margin_ver,s1,...
        'HorizontalAlignment','right','VerticalAlignment','baseline',...
        'FontUnits','normalized','FontSize',fontsize);
    
    t2=text(ax,xy(1)+width/2-margin_hor,xy(2)+height/2-margin_ver,s4,...
        'HorizontalAlignment','right','VerticalAlignment','cap',...
        'FontUnits','normalized','FontSize',fontsize);
    
    t3=text(ax,xy(1)+width/2+margin_hor,xy(2)+height/2+margin_ver,s2,...
        'HorizontalAlignment','left','VerticalAlignment','baseline',...
        'FontUnits','normalized','FontSize',fontsize);
    
    t4=text(ax,xy(1)+width/2+margin_hor,xy(2)+height/2-margin_ver,s3,...
        'HorizontalAlignment','left','VerticalAlignment','cap',...
        'FontUnits','normalized','FontSize',fontsize);
    
    % Draw in ax
    plot(ax,pos_lin1(:,1), pos_lin1(:,2),...
        'Color',[0,0,0],'LineWidth',1);
    plot(ax,pos_lin2(:,1), pos_lin2(:,2),...
        'Color',[0,0,0],'LineWidth',1);
    
    % Return object
    txt={t1,t2,t3,t4};
    
else
    % Rewrite previously created cross
    if ~ischar(s1)
        s1=num2str(s1,'%.2f');
        s2=num2str(s2,'%.2f');
        s3=num2str(s3,'%.1f');
        s4=num2str(s4,'%.1f');
    end
    
    % Rewrite already created text objects
    txt_obj{1}.String=s1;
    txt_obj{2}.String=s4;
    txt_obj{3}.String=s2;
    txt_obj{4}.String=s3;
end

end

