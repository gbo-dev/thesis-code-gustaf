
% Author: Gustaf (From Melani)

function dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f)
    % Initial (unfinished as of 05-22) attempt of new way of generating DAGs
    % with the goal of highlighting improved performance of JM_RT

    function v = taskSeriesUnbalanced(v, source, sink, depth, numBranches, ifCond)
        
        %parBranches = 2;
        depthFactor = 2;
        horSpace = depthFactor^depth;  
        
        if isempty(source) && isempty(sink)
            % G: Create source 
            v(1).pred = [];
            v(1).cond = 0;
            v(1).depth = depth;
            v(1).width = 0;

            % G: Create sink
            v(2).succ = [];
            v(2).cond = 0;
            v(2).depth = -depth;
            v(2).width = 0;
            
           % parBranches = randi([2 maxParBranches]); % G: Between 2 and 6 branches
            v = taskSeriesUnbalanced(v, 1, 2, depth - 1, 2, 0); 
        else
            step = horSpace / (numBranches - 1);

            w1 = (v(source).width - horSpace / 2); 
            w2 = (v(sink).width - horSpace / 2);
           
            for i = 1 : numBranches
                current = length(v);
                next = current + 1;

                if depth == 0
                    v(next).pred = source;
                    v(next).succ = sink;
                    v(next).cond = 0;
                    v(next).depth = depth;
                    v(next).width = w1 + step * (i - 1);
                    
                    v(source).succ = [v(source).succ next];
                    v(sink).pred = [v(sink).pred next];
                    v(sink).cond = 0;
                    
                    v(next).condPred = [v(next).condPred v(source).condPred];
                    v(next).branchList = [v(next).branchList v(source).branchList];
                else
                    v(next).pred = source;
                    v(next).depth = depth;
                    v(next).width = w1 + step * (i - 1);                    
                    v(source).succ = [v(source).succ, next];
                    v(next + 1).succ = sink;
                    v(next + 1).depth = -depth;
                    v(next + 1).width = w2 + step * (i - 1);
                    
                    v(sink).pred = [v(sink).pred next + 1];
                    %parBranches = randi([2 maxParBranches]);
                    parBranches = 2;
                    
                    v(next).condPred = [v(next).condPred v(source).condPred];
                    v(next + 1).condPred = [v(next + 1).condPred v(source).condPred];
                    
                    v(next).branchList = [v(next).branchList v(source).branchList];
                    v(next + 1).branchList = [v(next + 1).branchList v(source).branchList];
                    
                    v = generateUnbalancedDAG(v, next, next + 1, depth - 1, parBranches, 0);              

                end
            end
        end
    end


    global task;

    v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {},...
    'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {});

    task(i).v = taskSeriesUnbalanced(v, [], [], rec_depth, 0, 0);
    task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
    task(i).v = makeItDAG(task(i).v, addProb);

    task(i).v = computeAccWorkload(task(i).v);
    [~, q] = max([task(i).v.accWorkload]);
    cp = getCP(q, task(i).v);
    task(i).len = task(i).v(q).accWorkload;

    [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
    % task(i) = generateSchedParameters(i, beta);    % OLD, params: new 


    %[task(i).cmaxs, task(i).lengths, task(i).paths] = getAllPaths(task(i).v);
    %task(i) = imbalanceDAG(task(i), 0.5);

    task(i) = generateSchedParams(i, beta, m, f);    

    dag = task(i);
end
