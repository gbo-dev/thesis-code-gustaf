
% Author: 2024 Gustaf Bodin

% TODO: Add print/cancel when R>D? 
function [R_max, m_max] = JM_RT(dag, f, m)
    % Joint Maximization Response Time estimate

    global print;

    R_max = 0;
    m_max = 0;

    % q: number of faults suffered by longest path 
    % (f-q): Nodes not in LP suffers (f-q) faults 
    % Find LP and (maxWCET not in LP) for q = [0,f] (LP changes with faults)
    for q = 0:f
        [Lfmax, index] = longestFaultyPath(dag, q);
        
        max_WCET_excluding_LP = findMaxWCETExcludeCurrLongestPath(dag, index);

        clmax = dag.cmaxs(index);

        Lq = dag.lengths(index) + q * clmax;
        Wfq = dag.W + (f-q) * max_WCET_excluding_LP + q * clmax; 

        R = Lq + (Wfq - Lq) / m;

        if R > R_max
            R_max = R;
            if R_max > dag.D
                if print == 1
                    fprintf('Response Time = %d\n', R_max);
                    fprintf('Deadline = %d\n', dag.D);
                    fprintf('Task is not schedulable\n');
                end

                % NOTE: Printouts for values of for-loop scope can look smaller if we return here
                % return;
            end
        end
    end

    if print == 1
        fprintf('Task is schedulable\n');
        fprintf('Response Time = %d\n', R_max);
        fprintf('Deadline = %d\n', dag.D);
    end
end 
