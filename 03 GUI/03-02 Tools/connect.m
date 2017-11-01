function  connect(ax, p1, p2, p3, opt1, arrow_length, opt2, interrupt)
%connect Draw a connection in ax from p1 to p2, passing p3
% Set p3 to -1 to use the median between p1 and p2 as mid point
% Set opt1 to true to draw an arrow at p2
% Set opt2 to ver or hor

if p3==-1
    p3=(p1+p2)/2;
end

if nargin==7
    interrupt=[];
end

% Calculate coordinates
if strcmp(opt2,'hor')
    long_leg1=[1,0];
    long_leg2=[1,0];
elseif strcmp(opt2,'ver')
    long_leg1=[0,1];
    long_leg2=[0,1];
elseif strcmp(opt2,'outer1')
    long_leg1=[1,0];
    long_leg2=[0,1];
elseif strcmp(opt2,'outer2')
    long_leg1=[0,1];
    long_leg2=[1,0];
end

corners=[p1.*long_leg1+p3.*abs(1-long_leg1);...
    p3;...
    p2.*long_leg2+p3.*abs(1-long_leg2)];

pos=[p1;corners;p2];

angle = 15;
arrow_mid_height = arrow_length * tan(angle/2 * 2*pi/360);

corner_end=p2-corners(end,:);
if corner_end==0
    corner_end=corners(end,:)-p3;
    %     corner_end=[p2(1)-p1(1),0];
end
distance=corner_end / max(abs(corner_end));
arrow = [p2;...
    p2 - distance*arrow_length - (1-abs(distance))*arrow_mid_height;...
    p2 - distance*arrow_length + (1-abs(distance))*arrow_mid_height;...
    p2];


% Draw in ax
if isempty(interrupt)
    plot(ax,pos(:,1), pos(:,2),...
        'Color',[0,0,0],'LineWidth',1);
else
    split=0;
    p=1;
    
    while split==0 && p<size(pos,1)
        % Between X or between Y
                
        if (sign((pos(p,1)-interrupt(1))/(pos(p+1,1)-interrupt(1))) ==-1) ||...
                (sign((pos(p,2)-interrupt(2))/(pos(p+1,2)-interrupt(2))) ==-1)
            
            split=p;
        else
            p=p+1;
        end
    end
    
    % Rebuild pos1 and pos2
    pos1=[pos(1:split,:);interrupt];
    pos2=[interrupt;pos(split+1:end,:)];
    
    % Apply break
    margin=1;
    
    % Equal Y
    if pos1(end-1,2)==pos2(2,2)
        chg_sign=sign(pos1(end-1,1)-pos2(2,1));
        
        pos1(end,1)=pos1(end,1)+margin*chg_sign;
        pos2(1,1)=pos2(1,1)-margin*chg_sign;
    end
    
    % Equal X
    if pos1(end-1,1)==pos2(2,1)
        chg_sign=sign(pos1(end-1,2)-pos2(2,2));
        
        pos1(end,2)=pos1(end,2)+margin*chg_sign;
        pos2(1,2)=pos2(1,2)-margin*chg_sign;
    end
    
    % Plot
    plot(ax,pos1(:,1), pos1(:,2),...
        'Color',[0,0,0],'LineWidth',1);
    
    plot(ax,pos2(:,1), pos2(:,2),...
        'Color',[0,0,0],'LineWidth',1);
end

if opt1
    fill(ax,arrow(:,1),arrow(:,2),...
        'k');
end


end

