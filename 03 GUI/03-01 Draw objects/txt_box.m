classdef txt_box < handle
    
    properties (Access = public)
        left
        right
        top
        bottom
    end
    
    properties (Access = private)
        width
        height
        string
    end
    
    methods (Access = public)
        
        function t = txt_box(fwidth, fheight, fstr)
            % Draw text with a box in ax, at positions x y
            
            t.width=fwidth;
            t.height=fheight;
            t.string=fstr;
        end
        
        function txt=draw(t,ax,xy, fontsize)
            
            txt=text(ax,xy(1)+t.width/2,xy(2)+t.height/2,t.string,...
                'HorizontalAlignment','center','VerticalAlignment','middle',...
                'FontUnits','normalized','FontSize',fontsize,...
                'Clipping', 'on');
            
            corners=[xy;...
                xy+[0,t.height];...
                xy+[t.width,t.height];...
                xy+[t.width,0];...
                xy];
            
            t.left=xy+[0,t.height/2];
            t.right=t.left+[t.width,0];
            t.top=xy+[t.width/2,t.height];
            t.bottom=xy+[t.width/2,0];
            
            plot(ax,corners(:,1), corners(:,2),...
                'Color',[0,0,0],'LineWidth',1);
            
            txt={txt};
        end
        
    end
    
end


