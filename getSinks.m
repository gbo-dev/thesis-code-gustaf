
% Author: 2024 Gustaf Bodin

function sinks = getSinks(v) 
    sinks = [];
    for i = 1:length(v)
        if isempty(v(i).succ)
            sinks = [sinks i];
        end
    end
end