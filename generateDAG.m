
% Author: Gustaf (From Melani)

function dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f)
    % Modified Melani 'generateDAG' function to use 'generateSchedParams' 
    % instead of 'generateSchedParameters'

    global task;

    v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {},...
    'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {});

    task(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
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
