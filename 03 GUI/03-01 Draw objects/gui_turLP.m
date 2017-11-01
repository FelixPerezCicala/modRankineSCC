classdef gui_turLP < handle
    
    properties (Access = public)
        
        % Connections
        in
        out
        out_end
        
        % Text positions
        tin
        tout
        
        % Corners
        pos_corners
        
    end
    
    properties (Access = private)
        width
        height
        angle
        extLP
        
    end
    
    properties (Access = private)
        
        
    end
    
    methods (Access = public)
        
        function t = gui_turLP(w,he,ang,eLP)
            % Set properties of the design
            t.width=w;
            t.height=he;
            t.angle=ang;
            t.extLP=eLP;
            
            t.out=zeros(eLP,2);
        end
        
        function draw(t, ax, x, y)
            % Draw TUR type P in LP ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            
            % Calculate outer shape coordinates.
            % Clockwise starting at lower left
            
            slope_loss1=t.width/2*tan(t.angle*2*pi/360);
            
            t.pos_corners=[x,y+slope_loss1;...
                x,y+t.height-slope_loss1;...
                x+t.width, y+t.height;...
                x+t.width,y;...
                x,y+slope_loss1];
            
            % Draw in ax
            plot(ax,t.pos_corners(:,1),t.pos_corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            
            % Fill with blue the turbine
            tur_color=[207,239,250]/255;
            
            fill(ax,t.pos_corners(:,1),t.pos_corners(:,2),tur_color);
            
            patch(ax,'XData',t.pos_corners(:,1),'YData',t.pos_corners(:,2),...
                'FaceColor',tur_color,'HitTest','off');
            
            % Store connection coordinates
            t.in=[x,y+t.height-slope_loss1];
            t.out_end=[x+t.width,y];
            
            for e=1:t.extLP
                t.out(e,:)=[x + t.width*(e/(t.extLP+1)),...
                    y + slope_loss1*(1-e/(t.extLP+1))];
                
            end
            
            % Store text positions
            cross_width=12;
            cross_height=5;
            margin=0.5;
            
            t.tin=t.in+[-margin-0.5-cross_width,margin];            
                        
            for e=1:t.extLP
                t.tout(e,:)=t.out(e,:)+[margin,-margin*4-cross_height];                
            end
            
%             plot(ax,t.out(:,1),t.out(:,2),'o');
            
        end
        
    end
    
end