% 
% cptasks - A MATLAB(R) implementation of schedulability tests for
% conditional and parallel tasks
%
% Copyright (C) 2014-2015  
% ReTiS Lab - Scuola Superiore Sant'Anna - Pisa (Italy)
%
% cptasks is free software; you can redistribute it
% and/or modify it under the terms of the GNU General Public License
% version 2 as published by the Free Software Foundation, 
% (with a special exception described below).
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

tasksetsPerU = 1;
addProb = 0.1;
ave_rate = 25;
% lost = 0;
% Umin = 0;
% Umax = m;
% U = 0;
% Ucurr = Umin;
%stepU = 0.25; % G: 1 or 2 tasks? 
%stepU = 0.50; % G: 2 or 4 tasks?
%stepU = 1.5; 



task = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {},...
    'R', {}, 'mksp', {}, 'Z', {}, 'W', {}, 'maxWCET', {}, 'Wfmax', {},...
    'Lfmax', {}, 'cmaxs', {}, 'lengths', {}, 'paths',{});

accepted_joint = 0;
failed_separate = 0;
accepted_he = 0;
m_sum = 0;

diff_sum = 0;
joint_dom = 0;
joint_smaller = 0;

diff = 0; 

joint_delta_sum = 0;
separ_delta_sum = 0;
joint_equal_separate = 0; 


% TODO: 
% 1. Base DAG task generation from Utilization instead: use either of the two suggested techniques of Risat
    % Use UUnifast to generate tasksets with U = m
% 2. Implement environment for running tests for tasksets 
% 3. Produce acceptance ratio figures 

% NOTE: 
% U = m: either normalized [0, 1] or absolute [0, m]

print = 0; 
print_dag = 0;
maxParBranches = 4;
rec_depth = 3;
Cmin = 10;
Cmax = 200;
beta = 0.1;

f = 2;
%num_tasks = 1000;

U = 4;
n = 4;
m = U;
Umin = 0; 
Ucurr = 0;

stepU = 0.25;
tasksetsPerU = 50;

nTasksets = tasksetsPerU * (U - Umin) / stepU;
separateFailedTasksets = 0;
first_light = 1;
light_U_sum = 0;

% U: fixed
% n: fixed

for x = 1 : nTasksets
    % For each taskset, split the utilization into n tasks
    vector_U = UUniFast(n, U);

    % Sort vector in descending order to handle light tasks last?
    vector_U = sort(vector_U, 'descend');

    m_curr = m;

    for i = 1 : n
        dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f, vector_U(i));
        task(i) = dag;

        if vector_U(i) > 1
            % Task is heavy
            m_separate = requiredProcsSeparate(task(i));

            if m_separate > m
                separateFailedTasksets = separateFailedTasksets + 1;
                break;
            end

            r_sm = SM_RT(task(i), f, m_separate);
            if r_sm > task(i).D
                separateFailedTasksets = separateFailedTasksets + 1;
                break;
            end

            % Accepted task
            % Decrease processors by number of processors assigned to this task
            m_curr = m_curr - m_separate;
            continue;
        end

        if vector_U(i) <= 1

            fprintf("m_curr: %d\n", m_curr);
            % Task is light 
            % Remaining processors avaialbe to light tasks 

            if first_light == 1
                for j = i : n
                    light_U_sum = light_U_sum + vector_U(j);
                end
                first_light = 0;
                if light_U_sum > m_curr
                    % Scheduling this taskset is not possible
                    failed_separate = failed_separate + 1;
                    break;
                end

                % Find response time and check deadline for this task
                R_SM = SM_RT(task(i), f, m_curr);
                if R_SM > task(i).D
                    % Scheduling this taskset is not possible
                    failed_separate = failed_separate + 1;
                    break;
                end
            end 
        end

    end
end

fprintf("nTasksets: %d\n", nTasksets);
acceptance_ratio = (nTasksets - failed_separate) / nTasksets;
fprintf('Acceptance ratio: %.2f\n', acceptance_ratio);

function m = requiredProcsSeparate(dag)
    m = ceil((dag.Wfmax - dag.Lfmax) / (dag.D - dag.Lfmax));
end

% function m = requiredProcsJoint(dag, f)
%     for q = 0:f
%
%     end
% end

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
