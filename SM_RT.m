
% Author: 2024 Gustaf Bodin

function [r, Lfmax] = SM_RT(dag, f, m)
    % Separate Maximization Response Time estimate

    global print;
    
    %[Lfmax, ~] = longestFaultyPath(dag, f);

    r = dag.Lfmax + ((dag.Wfmax - dag.Lfmax) / m);

    Lfmax = dag.Lfmax;
    if print == 1
        fprintf('\n#Processors = %d\n', m);
        fprintf('Max WCET = %d\n', maxWCET);
        fprintf('Workload W = %d\n', W);
        fprintf('Wfmax = %d\n', dag.Wfmax);
        fprintf('Lfmax = %d\n', dag.Lfmax);
    end 
end 
