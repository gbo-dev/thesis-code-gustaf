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
maxParBranches = 2;
%maxParBranches = 6;
p_cond = 0;
p_par = 0.8;
p_term = 0.2;

rec_depth = 2;
Cmin = 1;
Cmax = 100;
beta = 0.1;

tasksetsPerU = 1;
addProb = 0.1;
% lost = 0;
% Umin = 0;
% Umax = m;
% U = 0;
% Ucurr = Umin;

%stepU = 0.25; % G: 1 or 2 tasks? 
%stepU = 0.50; % G: 2 or 4 tasks?
%stepU = 1.5; 

save_rate = 25;
print = 0; 

task = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

% TODO: Change to use Melani's way of determining #tasks
num_tasks = 200;
m = 4;
f = 15; 
num_accepted = 0;
m_sum = 0;

for i = 1:num_tasks
    dag = generateDAG(i, rec_depth, Cmin, Cmax, beta, addProb, print);
    [R, m_max] = JM_RT(dag, f, m);

    m_sum = m_sum + m_max;

    if R <= dag.D
        dag.success = 1;
        num_accepted = num_accepted + 1;
    else
        dag.success = 0;
    end
end

fprintf('\nNumber of tasks: %d\n', num_tasks);
fprintf('m_sum: %d\n', m_sum);


% Print acceptance ratio
fprintf('\nAcceptance ratio: %.2f\n', round(num_accepted / num_tasks, 2));







