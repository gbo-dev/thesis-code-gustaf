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
    % Author: 2015 Alessandra Melani
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


print = 0; 
print_dag = 1;
maxParBranches = 3;
rec_depth = 2;
Cmin = 10;
Cmax = 200;
beta = 0.1;

m = 2;
f = 3; 
num_tasks = 2000;

task = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {},...
    'R', {}, 'mksp', {}, 'Z', {}, 'W', {}, 'maxWCET', {}, 'Wfmax', {},...
    'cmaxs', {}, 'lengths', {}, 'paths',{});

accepted_joint = 0;
accepted_separate = 0;
m_sum = 0;

diff_sum = 0;
joint_dom = 0;
joint_smaller = 0;

diff = 0; 

joint_delta_sum = 0;
separ_delta_sum = 0;
joint_equal_separate = 0; 

for i = 1:num_tasks

    dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print, m, f);
    if print_dag == 1 && i == 1
        printTask(dag.v);
    end
    D = dag.D;

    [R_joint, m_max] = JM_RT(dag, f, m);
    [R_separate, Lfmax] = SM_RT(dag, f, m);

    joint_delta_sum = joint_delta_sum + D - R_joint;
    separ_delta_sum = separ_delta_sum + D - R_separate;

    dag.success = 0;
    if R_joint <= D
        dag.success = 1;
        accepted_joint = accepted_joint + 1;
    end

    if R_separate <= D
        dag.success = 1;
        accepted_separate = accepted_separate + 1;
    end

    if R_joint > R_separate
        fprintf("R_joint: %d\n", R_joint);
        fprintf("R_separ: %d\n", R_separate);
        fprintf('\nANOMALY\n');
    end
       
    if (R_joint <= D) && (R_separate > D)
        joint_dom = joint_dom + 1;
    end

    if R_joint <= R_separate 
        diff = diff + (R_separate - R_joint) / R_separate;
        joint_smaller = joint_smaller + 1;
    end

    if R_joint == R_separate
        joint_equal_separate = joint_equal_separate + 1;
    end

end

diff = diff / num_tasks;

fprintf('\nNumber of tasks: %d\n', num_tasks);
fprintf('Number of faults: %d\n', f);

fprintf('Avg improvement in response time: %d\n', diff);

fprintf('#(Joint <= Separate): %d\n', joint_smaller);
fprintf('#(Joint == Separate): %d\n', joint_equal_separate);
fprintf('#(Joint dominates Separate): %d (%.4f)', joint_dom, joint_dom / num_tasks);

fprintf('\nJoint Acceptance ratio: %.2f\n', accepted_joint / num_tasks);
fprintf('\nSepar Acceptance ratio: %.2f\n', accepted_separate / num_tasks);

