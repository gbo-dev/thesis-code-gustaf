
% Author: Gustaf Bodin

function max_WCET_excluding_LP = findMaxWCETExcludeCurrLongestPath(dag, index)
    
    max_WCET_excluding_LP = 0;

    for j = 1:length(dag.v) 
        if ~ismember(j, dag.paths(1, index).list)
            if dag.v(j).C > max_WCET_excluding_LP
                max_WCET_excluding_LP = dag.v(j).C;
            end
        end
    end 
end 
