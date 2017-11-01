classdef gui_fwh < handle
    
    properties (Access = public)
        % Connections
        Cold_out
        Cold_in
        Hot_out
        Hot_in
        Db_in % Drainback input
        
        % Text positions
        tHot_out
        tHot_in
        tCold_out
        tCold_in
        tDB
        tp_loss
        
        % Corners box
        pos_corners
    end
    
    properties (Access = private)
        width
        height
    end
    
    methods (Access = public)
        
        function h = gui_fwh(w,he)
            % Set properties of the design
            h.width=w;
            h.height=he;
        end
        
        function draw(h, ax, x, y, draw_res)
            % Draw FWH in ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            
            % Calculate coordinates. Clockwise starting at lower left
            h.pos_corners=[x,y;...
                x,y+h.height;...
                x+h.width,y+h.height;...
                x+h.width,y;...
                x,y];
            
            pos_resistance=[x,y+h.height/2;...
                x+h.width*0.25,y+h.height/2;...
                x+h.width*0.25,y+1.4*h.height/2;...
                x+h.width*0.75,y+0.6*h.height/2;...
                x+h.width*0.75,y+h.height/2;...
                x+h.width,y+h.height/2];
            
            % Draw in ax
            plot(ax,h.pos_corners(:,1),h.pos_corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            if (draw_res == true)
                plot(ax,pos_resistance(:,1),pos_resistance(:,2),...
                    'Color',[120,120,120]/255,'LineWidth',1);
            end
                        
            % Fill with gradient the box
            color=[1,0,0;
                1,0,0;
                0,0,1;
                0,0,1;
                1,0,0];
            
            gradient=0:1/4:1;
            if (draw_res == true)
                patch(ax,h.pos_corners(:,1),h.pos_corners(:,2),gradient,...
                    'FaceVertexCData',color,'FaceColor','interp',...
                    'FaceAlpha',0.25,'HitTest','off');
            end
            
            % Store connection coordinates
            h.Cold_out=[x,y+h.height/2];
            h.Cold_in=[x+h.width,y+h.height/2];
            h.Hot_out=[x+h.width/2,y];
            h.Hot_in=[x+h.width/2,y+h.height];
            h.Db_in=[x+h.width*0.25,y];
                        
            cross_width=12;
            cross_height=5;
            margin=0.5;
            
            h.tHot_out=h.Hot_out+[margin,-cross_height-margin];
            h.tHot_in=h.Hot_in+[margin+0.2, margin+2];
            h.tCold_out=h.Cold_out+[-margin-cross_width,margin];
            h.tCold_in=h.Cold_in+[margin,margin];
            h.tp_loss=h.Hot_in+[-10,10];
            
        end
        
        function [txt] = draw_TTDDCA(h,ax,TTD,DCA,bypass,fontsize)
            
            % Draw TTD and DCA text
            s_empty='';
            t1 = text(ax,h.Hot_in(1),h.Hot_in(2)-h.height*0.15,s_empty,...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'FontUnits','normalized','FontSize',fontsize,'HitTest','off');
            
            t2 = text(ax,h.Hot_in(1),h.Hot_in(2)-h.height*0.85,s_empty,...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'FontUnits','normalized','FontSize',fontsize,'HitTest','off');
            
            if bypass==0
                % TTD
                string1 = ['TD ', num2str(TTD,'%.2f')];
                
                % DCA
                string2 = ['DA ', num2str(DCA,'%.2f')];
                
                t1.String=string1;
                t2.String=string2;
                
            else
                % Bypass
                t1.String='BYPASS';
                t1.Color=[1,0,0];
                t1.FontWeight='bold';
                
                t2.String='';
            end
            
            txt={t1,t2,{},{}};
            
        end
        
    end
    
end