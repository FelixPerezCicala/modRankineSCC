classdef gui_con < handle
    
    properties (Access = public)
        % Connections
        out
        in
        in_DB
        left
        right_most
        
        tout
        tin
    end
    
    properties (Access = private)
        width
        height
    end
    
    methods (Access = public)
        
        function c = gui_con(w,h)
            % Set properties of the design
            c.width=w;
            c.height=h;
        end
        
        function draw(c, ax, x, y)
            % Draw FWH in ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            
            % Calculate coordinates. Clockwise starting at lower left
            pos_corners=[x,y;...
                x,y+c.height;...
                x+c.width,y+c.height;...
                x+c.width,y;...
                x,y];
            
            % Resistance to outut
            pos_resistance=[x+1.5*c.width,y+c.height*0.15;...
                x+c.width*0.5,y+c.height*0.15;...
                x+c.width*0.5,y+c.height*0.25;...
                x+c.width*0.3,y+c.height*0.25;...
                x+c.width*0.7,y+c.height*0.75;...
                x+c.width*0.5,y+c.height*0.75;...
                x+c.width*0.5,y+c.height*0.85;...
                x+c.width*1.5,y+c.height*0.85];
            
            angle = 15;
            arrow_length=2.5;
            arrow_mid_height = arrow_length * tan(angle/2 * 2*pi/360);
            
            arrow1=[x+1.25*c.width-arrow_length/2,y+c.height*0.15;...
                x+1.25*c.width+arrow_length/2,y+c.height*0.15+arrow_mid_height;...
                x+1.25*c.width+arrow_length/2,y+c.height*0.15-arrow_mid_height;...
                x+1.25*c.width-arrow_length/2,y+c.height*0.15];
            
            arrow2=[x+1.25*c.width+arrow_length/2,y+c.height*0.85;...
                x+1.25*c.width-arrow_length/2,y+c.height*0.85+arrow_mid_height;...
                x+1.25*c.width-arrow_length/2,y+c.height*0.85-arrow_mid_height;...
                x+1.25*c.width+arrow_length/2,y+c.height*0.85];
            
            % Draw in ax
            plot(ax,pos_corners(:,1),pos_corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            plot(ax,pos_resistance(:,1),pos_resistance(:,2),...
                'Color',[120,120,120]/255,'LineWidth',1);
            fill(ax,arrow1(:,1),arrow1(:,2),...
                [120,120,120]/255,...
                'EdgeColor',[120,120,120]/255);
            fill(ax,arrow2(:,1),arrow2(:,2),...
                [120,120,120]/255,...
                'EdgeColor',[120,120,120]/255);
            
            % Fill with gradient the box
            color=[0,0,1;
                1,0,0;
                1,0,0;
                0,0,1;
                0,0,1];
            
            gradient=0:1/4:1;
            
            patch(ax,pos_corners(:,1),pos_corners(:,2),gradient,...
                'FaceVertexCData',color,'FaceColor','interp',...
                'FaceAlpha',0.25);
            
            % Store connection coordinates
            c.out=[x+c.width/2, y];
            c.in=[x+c.width/2, y+c.height];
            c.in_DB=[x+c.width/2*0.25, y];
            c.left=[x,y+c.height/2];
            c.right_most=pos_resistance(end,1);
            
            cross_width=12;
            cross_height=5;
            margin=0.5;
            
            c.tout=c.out+[margin, -margin-cross_height];
            c.tin=c.in+[margin, +margin];
            
        end
        
    end
    
end