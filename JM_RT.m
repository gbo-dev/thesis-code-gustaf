
% Author: 2024 Gustaf Bodin

% TODO: Fix so it is according to the paper algorithm
function [R_max] = JM_RT(dag, f, m)
    % Joint Maximization Response Time estimate

    global print;

    R_max = 0;

    % q: number of faults suffered by longest path 
    % (f-q): Nodes not in LP suffers (f-q) faults 
    % Find LP and (maxWCET not in LP) for q = [0,f] (LP changes with faults)

    for p = 1:length(dag.paths)

        L = dag.lengths(p);
        Lcmax = dag.cmaxs(p);

        % TODO: VERIFY CORRECTNESS HERE: I think it is correct
        Wcmax = findMaxWCETExcludeCurrLongestPath(dag, p);

        for q = 0:f
            max_WCET_excluding_LP = findMaxWCETExcludeCurrLongestPath(dag, p);

            clmax = dag.cmaxs(p);

            Lq = dag.lengths(p) + q * clmax;
            Wfq = dag.W + (f-q) * max_WCET_excluding_LP + q * clmax; 

            R = Lq + ((Wfq - Lq) / m);

            if R > R_max
                R_max = R;
                if R_max > dag.D
                end
            end
        end
end 
