classdef gui_pmp < handle
    
    properties (Access = public)
        % Connections
        out
        in
        tout
        tin
    end
    
    properties (Access = private)
        radius
        rotation        
    end
    
    methods (Access = public)
        
        function p = gui_pmp(rad)
            % Set properties of the design
            p.radius=rad;
        end
        
        function draw(p, ax, x, y, rot)
            % Draw FWH in ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            p.rotation=rot;
            
            x=x+p.radius;
            y=y+p.radius;
            
            pos_corners=zeros(361,2); % [x,y]
            
            % Circle
            for ang=0:1:360
                pos_corners(ang+1,1)=x+p.radius*cos(ang*2*pi/360);
                pos_corners(ang+1,2)=y+p.radius*sin(ang*2*pi/360);
            end
            
            % Triangle
            triangle = [x+p.radius*cos(rot*2*pi/360), y+p.radius*sin(rot*2*pi/360);...
                x+p.radius*cos((120+rot)*2*pi/360), y+p.radius*sin((120+rot)*2*pi/360);...
                x+p.radius*cos((240+rot)*2*pi/360), y+p.radius*sin((240+rot)*2*pi/360);...
                x+p.radius*cos(rot*2*pi/360), y+p.radius*sin(rot*2*pi/360)];
                            
            % Draw in ax
            plot(ax,pos_corners(:,1),pos_corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            plot(ax,triangle(:,1),triangle(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            
            % Store connection coordinates
            p.out=[x+p.radius*cos(rot*2*pi/360), y+p.radius*sin(rot*2*pi/360)];
            p.in=[x+p.radius*cos((180+rot)*2*pi/360), y+p.radius*sin((180+rot)*2*pi/360)];
            
            cross_width=12;
            cross_height=5;
            margin=0.5;
            
            p.tin=p.in+[margin,margin];
            p.tout=p.out+[-margin-cross_width+0.5,margin];
            
        end
        
    end
    
end