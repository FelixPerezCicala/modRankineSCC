classdef gui_valve < handle
    %gui_valve Draws a valve
    
    properties (Access = public)
        left
        right
        top
        bottom
    end
    
    properties (Access = private)
        width
        height
    end
    
    methods
        
        function v = gui_valve(fwidth,fheight)
            v.width=fwidth;
            v.height=fheight;
        end
        
        function txt=draw(v,ax,xy,orientation,text_str,txt_pos,fontsize)
            
            if strcmp(orientation,'ver')
                dir=[0,1];
            else
                dir=[1,0];
            end
            
            size=[v.width,v.height];
            
            corners=[xy;...
                xy+size;...
                xy+dir.*size;...
                xy+abs((1-dir)).*size;...
                xy];
            
            plot(ax,corners(:,1), corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            
            v.left=xy+[0,size(2)./2];
            v.right=xy+[size(1),size(2)./2];
            v.top=xy+[size(1)/2,size(2)];
            v.bottom=xy+[size(1)/2,0];
            
            txt=cell(1,1);
            
            if nargin==7
                % Draw text adjacent to valve
                margin=0.3;
                
                hor_alg='center';
                vert_alg='middle';
                
                switch txt_pos
                    case 'up'
                        txt_pos=v.top+[0,margin];
                        vert_alg='bottom';
                    case 'down'
                        txt_pos=v.bottom+[0,0];
                        vert_alg='top';                        
                    case 'right'
                        txt_pos=v.right+[margin,0];
                        hor_alg='left';
                    case 'left'
                        txt_pos=v.left+[-margin,0];
                        hor_alg='right';
                end
                
                txt=text(ax,txt_pos(1),txt_pos(2),text_str,...
                    'HorizontalAlignment',hor_alg,'VerticalAlignment',vert_alg,...
                    'FontUnits','normalized','FontSize',fontsize,...
                    'Clipping', 'on');
                
                txt={txt};
            end
        end
        
    end
    
end

