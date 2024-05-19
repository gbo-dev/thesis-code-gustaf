
% Author: 2024 Gustaf Bodin

function sources = getSources(v) 
    sources = [];
    for i = 1:length(v)
        if isempty(v(i).pred)
            sources = [sources i];
        end
    end
end