
% Author: Gustaf (From Melani)

function dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f, U)
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

    task(i) = generateSchedParams(i, beta, m, f, U);    

    dag = task(i);
end
