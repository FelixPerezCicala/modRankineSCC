classdef list_cell < handle
    %list_cell List of cell objects (either single cells or a row of cells)
    %   Fake thing to emulate java lists, because why not
    
    
    properties (Access = public)
        list_storage
    end
    
    properties (Access = private)
        empty_pos
        current_pos
    end
    
    methods (Access = public)
        
        function l = list_cell(rows,cols)
            % Build cell
            
            if nargin==1
                l.list_storage=cell(rows,1);
            elseif nargin==2
                l.list_storage=cell(rows,cols);
            end
            
            l.empty_pos=1;
            l.current_pos=1;
        end
        
        function add(l,cell_to_add)
            % Add a cell to the list, to the last position
            
            if size(l.list_storage,2)==1
                for element = 0:length(cell_to_add)-1
                    l.list_storage{l.empty_pos+element}=cell_to_add{element+1};
                end
                
                l.empty_pos=l.empty_pos+length(cell_to_add);
            else
                l.list_storage(l.empty_pos,:)=cell_to_add;
                
                l.empty_pos=l.empty_pos+1;
            end
        end
        
        function res = get(l,element,col)
            % Get element in list column
            
            if nargin==2
                res = l.list_storage{element};
            elseif nargin==3
                res = l.list_storage{element,col};
            end
        end
        
        function res = get_next(l)
            % Get next item in list, move position +1
            % Gives back row if the list is a matrix
            
            if size(l.list_storage,2)==1
                res = l.list_storage{l.current_pos};
            else
                res = l.list_storage(l.current_pos,:);
            end
            
            l.current_pos=l.current_pos+1;
        end
        
        function res = get_length(l)
            % Get List length
            res=l.empty_pos-1;
        end
        
        function reset_counter(l)
            % Reset list position counter
            l.current_pos=1;
        end
        
    end
    
end

