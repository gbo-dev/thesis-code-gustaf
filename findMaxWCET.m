
% Author: 2024 Gustaf Bodin

function maxWCET = findMaxWCET(task)
    maxWCET = 0; 
    for i = 1:length(task.v)
        if task.v(i).C > maxWCET
            maxWCET = task.v(i).C;
        end
    end
end