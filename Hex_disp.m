function Hex_disp(data,type)
    if(nargin < 2)
        type = 0;
    end
    h_disp = ' ';
    for i=1:length(data)
         if(type == 0)
            h_disp=[h_disp data(i,:) ' '];
         elseif(type == 1)
             h_disp=[h_disp data(i,:) ':'];
         end    
    end
    disp(h_disp);
end