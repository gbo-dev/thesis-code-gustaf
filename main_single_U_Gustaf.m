% % u % 
% cptasks - A MATLAB(R) implementation of schedulability tests for
% conditional and parallel tasks
%
% Copyright (C) 2014-2015  
% ReTiS Lab - Scuola Superiore Sant'Anna - Pisa (Italy)
%
% cptasks is free software; you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% version 2 as published by the Free Software Foundation, 
% (with a special exception described below).:
%
% Linking this code statically or dynamically with other modules is
% making a combined work based on this code.  Thus, the terms and
% conditions of the GNU General Public License cover the whole
% combination.
%
% cptasks is distributed in the hope that it will be
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License version 2 for more details.
%
% You should have received a copy of the GNU General Public License
% version 2 along with cptasks; if not, write to the
% Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301 USA.
%
%
    % Author: 2015 Alessandra Melani (Modified by Gustaf Bodin)
%


% TODO: 
% 1. Remove bad edges from imbalanced DAG, and make sure lengths, cmaxs etc correspond
% 2. Test if no imbalance is OK?

% IMPORTANT: 
% No DAG imbalancing as of now

close all;
clear all;

global m;
global task;
global maxCondBranches;
global maxParBranches;
global p_cond;
global p_par;
global p_term;
global print; 

workspace_name = 'C:\Users\Gustaf\Desktop\masters-thesis\Master_code\FP_U.mat';
maxCondBranches = 0; 
p_cond = 0;
p_par = 0.8;
p_term = 0.2;

addProb = 0.1;
save_rate = 25;

task = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {},...
    'R', {}, 'mksp', {}, 'Z', {}, 'W', {}, 'maxWCET', {}, 'Wfmax', {},...
    'Lfmax', {}, 'cmaxs', {}, 'lengths', {}, 'paths',{});


print = 0; 
print_dag = 0;
maxParBranches = 4;
rec_depth = 3;
Cmin = 10;
Cmax = 200;
beta = 0.1;

f = 2;
num_tasks = 25;

stepU = 0.25;
U = 4;
m = U;
Umin = 0; 
Ucurr = 0;

% 1x16?
vectorUSeparate = zeros(1, (U - Umin) / stepU);
vectorUJoint = zeros(1, (U - Umin) / stepU);
vectorUHe = zeros(1, (U - Umin) / stepU);

vectorUSeparate(1, 1) = 1.0;
vectorUJoint(1, 1) = 1.0;
vectorUHe(1, 1) = 1.0;

% NOTE: Single DAG testing:
% Step over each utilization, generating X number of DAGs for each utilization

while 1
    Ucurr = Ucurr + stepU;
    fprintf("Ucurr: %.2f\n", Ucurr);

    okSM = 0;
    okJM = 0;
    okHE = 0;

    for i = 1 : num_tasks
        dag = generateDAGSingle(i, rec_depth, Cmin, Cmax, beta, addProb, print, Ucurr, m, f);

        [r_sm, okSM] = runSM_RT(dag, f, m, okSM);
        [r_jm, okJM] = runJM_RT(dag, f, m, okJM);
        [r_he, okHE] = runHE_RT(dag, f, m, okHE);
    end

    % When U = 0: Acceptance ratio = 1
    indexU  = ceil(Ucurr / stepU) + 1;

    separate_accepted_ratio = okSM / num_tasks;
    vectorUSeparate(1, indexU) = separate_accepted_ratio;

    joint_accepted_ratio = okJM / num_tasks;
    vectorUJoint(1, indexU) = joint_accepted_ratio;

    he_accepted_ratio = okHE / num_tasks;
    vectorUHe(1, indexU) = he_accepted_ratio;

    if Ucurr >= U
        break;
    end
end

x = 0:stepU:U;
plot(x, vectorUSeparate(1, :));
hold on;
plot(x, vectorUJoint(1, :));
hold on;
plot(x, vectorUHe(1, :));

xlabel('Utilization');
ylabel('Acceptance');
title('Acceptance vs Utilization');


function [r_sm, okSM] = runSM_RT(dag, f, m, okSM)
    r_sm = SM_RT(dag, f, m);
    if r_sm <= dag.D
        okSM = okSM + 1;
    end
end

function [r_jm, okJM] = runJM_RT(dag, f, m, okJM)
    r_jm = JM_RT(dag, f, m);
    if r_jm <= dag.D
        okJM = okJM + 1;
    end
end

function [r_he, okHE] = runHE_RT(dag, f, m, okHE)
    r_he = HE_RT(dag, f, m);
    if r_he <= dag.D
        okHE = okHE + 1;
    end
end

function dag = generateDAGSingle(i, rec_depth, Cmin, Cmax, beta, addProb, print, Ucurr, m, f)

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

    task(i).W = computeVolume(task(i).v);


    % NOTE: Temporary, fix imbalanced DAGs later
    [task(i).cmaxs, task(i).lengths, task(i).paths] = getAllPaths(task(i).v);
    %task(i) = generateImbalancedDAG(task(i), 0.5);
    %[task(i).cmaxs, task(i).lengths, task(i).paths] = getAllPaths(task(i).v);

    task(i) = generatePeriodSingle(task(i), Ucurr);    
    task(i) = generateDeadlineSingle(task(i), beta, m, f);
    dag = task(i);
end

function dag = generateImbalancedDAG(dag, percentage)
    dag = imbalanceDAG(dag, percentage);
    [dag.cmaxs, dag.lengths, dag.paths] = getAllPaths(dag.v);
end

function dag = generatePeriodSingle(dag, Ucurr)
    % TODO: Ensure ceil is OK here
    dag.T = ceil(dag.W / Ucurr);
end

function dag = generateDeadlineSingle(dag, beta, m, f)

    dag.maxWCET = findMaxWCET(dag);
    dag.Wfmax = dag.W + dag.maxWCET * f;
    [dag.Lfmax, ~] = longestFaultyPath(dag, f);

    LowerBoundOnValidDeadline = max(dag.Wfmax/m, dag.Lfmax);

    if LowerBoundOnValidDeadline > dag.T
        %fprintf("ANOMALY: Deadline greater than period of task\n");
    end
    %dag.D = LowerBoundOnValidDeadline * 1.02; 
    % NOTE: temporary
    dag.D = dag.T;
end

function m = requiredProcsSeparate(dag)
    m = ceil((dag.Wfmax - dag.Lfmax) / (dag.D - dag.Lfmax));
end

function m = requiredProcsJoint(dag, f)
    for q = 0:f

    end
end


% function deadline = generateDeadline(dag)
%
%     dag.maxWCET = findMaxWCET(dag);
%     dag.Wfmax = dag.W + dag.maxWCET * f;
%     [Lfmax, ~] = longestFaultyPath(dag, f);
%
%     LowerBoundOnValidDeadline = max(dag.Wfmax/m, Lfmax);
%     return LowerBoundOnValidDeadline * 1.1; 
% end

%fprintf("Number of tasks: %d\n", nTasks);


    %U = 0;
    % if rem(x - 1, tasksetsPerU) == 0
    %     % Occurs U/ Umin times
    %     Ucurr = Ucurr + stepU;
    % end
    % i = 0;
    % while 1
    %     i = i + 1;
    %     task(i) = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f);
    %
    %     %U = U + task(i).wcw / task(i).T;
    %
    %     task(i).T = floor(task(i).wcw / Ucurr);
    %
    %     if U > Ucurr
    %         Uprev = U - task(i).wcw / task(i).T;
    %         Utarget = Ucurr - Uprev;
    %
    %         task(i).T = floor(task(i).wcw / Utarget);
    %         task(i).D = randi([task(i).len task(i).T]);
    %         U = Uprev + task(i).wcw / task(i).T;
    %         
    %         nTasks = i;
    %         break;
    %     end
    %
    % end



%for i = 1:num_tasks
%
%    dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f);
%    if print_dag == 1 && i == 1
%        printTask(dag.v);
%    end
%    D = dag.D;
%
%    [R_joint, m_max] = JM_RT(dag, f, m);
%    [R_separate, Lfmax] = SM_RT(dag, f, m);
%    R_He = HE_RT(dag, f, m);
%
%    if i == 1
%        printRoundInfo(D, R_joint, R_separate, R_He);
%    end
%
%    joint_delta_sum = joint_delta_sum + D - R_joint;
%    separ_delta_sum = separ_delta_sum + D - R_separate;
%
%    if R_joint <= D
%        accepted_joint = accepted_joint + 1;
%    end
%
%    if R_separate <= D
%        failed_separate = failed_separate + 1;
%    end
%
%    if R_He <= D
%        accepted_he = accepted_he + 1;
%    end
%
%    if R_joint > R_separate || R_He > R_separate
%        fprintf("R_joint: %d\n", round(R_joint));
%        fprintf("R_separ: %d\n", round(R_separate));
%        fprintf("R_He: %d\n", round(R_He));
%        fprintf('\nANOMALY\n');
%    end
%end
%
%diff = diff / num_tasks;
%
%fprintf('\nNumber of tasks: %d\n', num_tasks);
%fprintf('Number of faults: %d\n', f);
%
%fprintf('Joint Acceptance ratio: %.2f\n', accepted_joint / num_tasks);
%fprintf('Separ Acceptance ratio: %.2f\n', failed_separate / num_tasks);
%fprintf('He    Acceptance ratio: %.2f\n', accepted_he / num_tasks);





function printRoundInfo(D, R_joint, R_separate, R_He)
    fprintf("Deadline 1: %d\n", round(D));
    fprintf("Joint    R: %d\n", round(R_joint));
    fprintf("Separate R: %d\n", round(R_separate));
    fprintf("He       R: %d\n", round(R_He));
end
