classdef gui_turHPIP < handle
    
    properties (Access = public)
        
        % Connections
        HP_in
        HP_out
        IP_in
        IP_out
        IP_out_up
        A_leak
        B_leak
        L1_leak
        L3_leak
        L4_leak
        L6_leak
        toDEAIR_leak
        
        % Text points
        tHP_in
        tHP_out
        tHP_out_full
        tIP_in
        tIP_out
        
        % Pos corners
        hp_corners
        ip_corners
        
    end
    
    properties (Access = private)
        width
        height
        angle_HP
        angle_IP
        extHP
        extIP
        width_HP_rel
        width_IP_rel
    end
    
    properties (Access = private)
        
        
    end
    
    methods (Access = public)
        
        function t = gui_turHPIP(w,he,angHP, angIP,eHP,eIP,HP_width,IP_width)
            % Set properties of the design
            t.width=w;
            t.height=he;
            t.angle_HP=angHP;
            t.angle_IP=angIP;
            t.extHP=eHP;
            t.extIP=eIP;
            t.width_HP_rel=HP_width;
            t.width_IP_rel=IP_width;
            
            t.HP_out=zeros(eHP,2);
            t.IP_out=zeros(eIP,2);
            t.tHP_out=zeros(eHP,2);
            t.tIP_out=zeros(eIP,2);
        end
        
        function draw(t, ax, x, y)
            % Draw TUR type HP + IP in ax axes. Store connection coordinates
            % Coordinates FOR LOWER LEFT CORNER
            
            % Calculate outer shape coordinates.
            % Clockwise starting at lower left
            
            mid_he = 0.7*t.height; % Midbox height
            ax_mid = y + mid_he/2; % turbine box height (arm not included)
            tur_width_HP=t.width*t.width_HP_rel;
            tur_width_IP=t.width*t.width_IP_rel;
            slope_lossHP=tur_width_HP*tan(t.angle_HP*2*pi/360);
            slope_lossIP=tur_width_IP*tan(t.angle_IP*2*pi/360);
            axis_width=t.width*0.1;
            axis_width_small=t.width*0.05;
            arm_width=tur_width_HP*0.15;
            slope_lossHP_2=(tur_width_HP - arm_width)*tan(t.angle_HP*2*pi/360);
            axis_slim_he=mid_he*0.2;
            axis_yhk_he=mid_he*0.3;
            x_HP=x+axis_width;
            x_IP=x+axis_width+tur_width_HP+axis_width;
            
            pos_corners=[x,ax_mid-axis_slim_he/2;...
                x,ax_mid+axis_slim_he/2;...
                x_HP,ax_mid+axis_slim_he/2;...
                x_HP,y+mid_he;...
                x_HP+tur_width_HP-arm_width,y+mid_he-slope_lossHP_2;...
                x_HP+tur_width_HP-arm_width,y+t.height;...
                x_HP+tur_width_HP,y+t.height;...
                x_HP+tur_width_HP,ax_mid+axis_yhk_he/2;...
                x_IP,ax_mid+axis_yhk_he/2;...
                x_IP,y+mid_he-slope_lossIP;...
                x_IP+tur_width_IP,y+mid_he;...
                x_IP+tur_width_IP,ax_mid+axis_slim_he/2;...
                x_IP+tur_width_IP+axis_width_small,ax_mid+axis_slim_he/2;...
                x_IP+tur_width_IP+axis_width_small,ax_mid-axis_slim_he/2;...
                x_IP+tur_width_IP,ax_mid-axis_slim_he/2;...
                x_IP+tur_width_IP,y;...
                x_IP,y+slope_lossIP;...
                x_IP,ax_mid-axis_yhk_he/2;...
                x_HP+tur_width_HP,ax_mid-axis_yhk_he/2;...
                x_HP+tur_width_HP,y+slope_lossHP;...
                x_HP,y;...
                x_HP,ax_mid-axis_slim_he/2;...
                x,ax_mid-axis_slim_he/2];
            
            midline_1=[x_HP,ax_mid+axis_slim_he/2;...
                x_HP,ax_mid-axis_slim_he/2];
            midline_2=[x_HP+tur_width_HP,ax_mid+axis_yhk_he/2;...
                x_HP+tur_width_HP,ax_mid-axis_yhk_he/2];
            midline_3=[x_IP,ax_mid+axis_yhk_he/2;...
                x_IP,ax_mid-axis_yhk_he/2];
            midline_4=[x_IP+tur_width_IP,ax_mid+axis_slim_he/2;...
                x_IP+tur_width_IP,ax_mid-axis_slim_he/2];
            
            % Draw in ax
            plot(ax,pos_corners(:,1),pos_corners(:,2),...
                midline_1(:,1),midline_1(:,2),...
                midline_2(:,1),midline_2(:,2),...
                midline_3(:,1),midline_3(:,2),...
                midline_4(:,1),midline_4(:,2),...
                'Color',[0,0,0],'LineWidth',1,'HitTest','off');
            
            % Fill with blue the turbines
            tur_color=[207,239,250]/255;
            
            hp_tur=[pos_corners(3:8,:);
                pos_corners(19:22,:);
                pos_corners(3,:)];
            
            patch(ax,'XData',hp_tur(:,1),'YData',hp_tur(:,2),...
                'FaceColor',tur_color,'HitTest','off');
            
            ip_tur=[pos_corners(9:12,:);
                pos_corners(15:18,:);
                pos_corners(9,:)];
            
            patch(ax,'XData',ip_tur(:,1),'YData',ip_tur(:,2),...
                'FaceColor',tur_color,'HitTest','off');
            
            % Store connection coordinates and text
            t.HP_in=[x_HP+tur_width_HP-arm_width/2,y+t.height];
            t.IP_in=[x_IP,y+mid_he-slope_lossIP];
            t.IP_out_up=[x_IP+tur_width_IP,y+mid_he];
            t.A_leak=[x_HP+tur_width_HP-arm_width,y+t.height]+[0,-5];
            t.B_leak=[x_HP+tur_width_HP,y+t.height]+[0,-10];
            t.L1_leak=[x_HP+tur_width_HP,ax_mid];
            t.L3_leak=[x_HP,ax_mid];
            t.L4_leak=[x+axis_width*0.25,ax_mid-axis_slim_he/2];
            t.toDEAIR_leak=[x+axis_width*0.75,ax_mid-axis_slim_he/2];
            t.L6_leak=[x_IP+tur_width_IP+axis_width_small*0.75, ax_mid-axis_slim_he/2];
            
            cross_width=12;
            cross_height=5;
            margin=0.75;
            
            for e=1:t.extHP
                t.HP_out(e,:)=[x_HP + tur_width_HP*(1-e/t.extHP),...
                    y + slope_lossHP*(1-e/t.extHP)];
            end
            
            for e=1:t.extIP
                t.IP_out(e,:)=[x_IP + tur_width_IP*(e/t.extIP),...
                    y + slope_lossIP*(1-e/t.extIP)];
            end
            
            t.tHP_in=t.HP_in+[-margin-cross_width-2,margin-3];
            t.tIP_in=t.IP_in+[margin,margin*6];
            
            for e=1:t.extHP
                if e==t.extHP
                    t.tHP_out_full=t.HP_out(e,:)+[margin,-margin-cross_height];
                    
                    t.tHP_out(e,:)=t.HP_out(e,:)+[margin,-margin-cross_height-8];
                else
                    t.tHP_out(e,:)=t.HP_out(e,:)+[margin,-margin-cross_height];
                end
            end
            
            for e=1:t.extIP
                t.tIP_out(e,:)=t.IP_out(e,:)+[-margin-cross_width,-margin-cross_height];
            end
            
            %             plot(ax,t.HP_out(:,1),t.HP_out(:,2),'o',...
            %                 t.IP_out(:,1),t.IP_out(:,2),'o');
            
            % Store corners
            t.hp_corners=hp_tur;
            
            t.ip_corners=ip_tur;
            
        end
        
    end
    
end