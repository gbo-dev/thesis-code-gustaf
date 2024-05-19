
% Author: 2024 Gustaf Bodin

function [Lfmax, index] = longestFaultyPath(dag, f)
    % longestFaultyPath: for all paths in the DAG, find the longest one under f faults

    global print;
    
    % dag.lengths: set of lengths of all complete paths in DAG
    % NOTE: Selects first path if no other, MATLAB mad without it
    % index = 1; 

    Lfmax = 0;
    for i = 1:length(dag.lengths)
        cmax = dag.cmaxs(i);
        % fprintf("cmax: %d\n", cmax);
        L = dag.lengths(i);
        % fprintf("L: %d\n", L);
        Lf = L + f * cmax;

        if Lf > Lfmax
            Lfmax = Lf;
            index = i; 
        end
    end
end
