classdef gui_turLP < handle
    
    properties (Access = public)
        
        % Connections
        in
        out_left
        out_right
        
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
            
            t.out_left=zeros(eLP,2);
            t.out_right=zeros(eLP,2);
        end
        
        function draw(t, ax, x, y)
            % Draw TUR type P in LP ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            
            % Calculate outer shape coordinates.
            % Clockwise starting at lower left
            
            slope_loss1=t.width/2*tan(t.angle*2*pi/360);
            
            pos_corners=[x,y;...
                x,y+t.height;...
                x+t.width/2, y+t.height-slope_loss1;...
                x+t.width,y+t.height;...
                x+t.width,y;...
                x+t.width/2,y+slope_loss1;...
                x,y];
            
            % Draw in ax
            plot(ax,pos_corners(:,1),pos_corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            
            % Store connection coordinates
            t.in=[x+t.width/2,y+t.height-slope_loss1];
            
            for e=1:t.extLP
                t.out_left(e,:)=[x + t.width/2*(1-e/t.extLP),...
                    y + slope_loss1*(1-e/t.extLP)];
                
                t.out_right(e,:)=[x + t.width/2*(1+e/t.extLP),...
                    y + slope_loss1*(1-e/t.extLP)];
            end
            
%             plot(ax,t.out_left(:,1),t.out_left(:,2),'o',...
%                 t.out_right(:,1),t.out_right(:,2),'o');
            
        end
        
    end
    
end