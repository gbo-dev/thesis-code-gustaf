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
global revtask;
global maxCondBranches;
global maxParBranches;
global p_cond;
global p_par;
global p_term;

workspace_name = 'C:\Users\Gustaf\Desktop\masters-thesis\Master_code\FP_U.mat';
maxCondBranches = 2; 
maxParBranches = 6;
p_cond = 0;
p_par = 0.8;
p_term = 0.2;

rec_depth = 2;
Cmin = 1;
Cmax = 100;
beta = 0.1;

tasksetsPerU = 500;
addProb = 0.1;
m = 4;
lost = 0;
Umin = 0;
Umax = m;
U = 0;
Ucurr = Umin;
stepU = 0.25;
save_rate = 25;
print = 1; % Prints the DAGs if 1 

nTasksets = tasksetsPerU * ((Umax - Umin) / stepU);  % 500 * ((4 - 0)/0.25) = 8000
vectorU_RTAFP = zeros(1, (Umax - Umin) / stepU);
vectorU_Maia = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_HLPLUS = zeros(1, (Umax - Umin) / stepU);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
revtask =struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
%revv = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});
        
for x = 1 : nTasksets

    if rem(x - 1, tasksetsPerU) == 0
        Ucurr = Ucurr + stepU;
    end
    
    U = 0;
   
    schedRTAFP = 0;
    schedMaia = 0;
    schedRTAFP_HLPLUS = 0;
    
    i = 0;
    
    % generation of the DAG-tasks
    while 1
        
        i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {});
    
       % job=struct('rel', {}, 'wcet', {}, 'localD', {});
        
        %disp('ssdf'+U);
        task(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = makeItDAG(task(i).v, addProb);
        
     %   disp(length(task(i).v));
        
        
        if  print == 1
            printTask(task(i).v);
            
        end

        task(i).v = computeAccWorkload(task(i).v);
        [~, q] = max([task(i).v.accWorkload]);
        cp = getCP(q, task(i).v);
        task(i).len = task(i).v(q).accWorkload;

        [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);

        task(i) = generateSchedParameters(i, beta);
        U = U + task(i).wcw / task(i).T;
        
        if U <= Ucurr
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v); 
         %   disp('New Dag');
            [task(i).v]=computeAperiodicJobsNonCP(task(i).v,task(i).R, task(i).D);
            %disp(task(i).v(1));
         %     for kk = 1 : length(task(i).v)   % plot vertices
         %      str = sprintf('v %d L=%d',kk, task(i).v(kk).RevRel);
         %      disp(str);
         %     end
    
        else
            Uprev = U - task(i).wcw / task(i).T;
            Utarget = Ucurr - Uprev;
            task(i).T = floor(task(i).wcw / Utarget);
            task(i).D = randi([task(i).len task(i).T]);
            U = Uprev + task(i).wcw / task(i).T;
            
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
         %   disp('New Dag Last');
            [task(i).v]=computeAperiodicJobsNonCP(task(i).v,task(i).R, task(i).D);
         
          %  for kk = 1 : length(task(i).v)   % plot vertices
          %     str = sprintf('v %d L=%d',kk, task(i).v(kk).RevRel);
          %     disp(str);
          %  end
    
            nTasks = i;
            break;
        end
        
    end
    
    % sorting by increasing relative deadlines (DEADLINE MONOTONIC)
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedRTAFP] = runRTA_FP_2(i, task(i).mksp);

        if schedRTAFP == 0
            break;
        end
    end
    
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedRTAFP_HLPLUS] = runRTA_FP_2_HLPLUS(i, task(i).mksp);

        if schedRTAFP_HLPLUS == 0
            break;
        end
    end
    
    %tcin=200;
    %WW=HLOnRevNonCPGiven_t_cin(task(1).v, tcin);
    
    taskGSSG = testFonsecaSAC15();
    schedMaia = testMaiaRTNS14(taskGSSG);
    
            
    indexU = ceil(Ucurr / stepU);

    if schedRTAFP == 1
        vectorU_RTAFP(1, indexU) = vectorU_RTAFP(1, indexU) + 1;
    end

    
    if schedRTAFP_HLPLUS == 1
        vectorU_RTAFP_HLPLUS(1, indexU) = vectorU_RTAFP_HLPLUS(1, indexU) + 1;
    end
    
    if schedRTAFP == 1 && schedRTAFP_HLPLUS == 0
    disp('Not dominate ...Implementaion problem');
    end
    
   % if schedRTAFP == 0 && schedRTAFP_HLPLUS == 1
   % disp('GOOD');
   % end
    
    if schedMaia == 1
        vectorU_Maia(1, indexU) = vectorU_Maia(1, indexU) + 1;
    end

    if schedMaia == 1 && schedRTAFP == 0
        lost = lost + 1;
    end
    
    if rem(x, save_rate) == 0
        save(workspace_name, 'x', 'lost', 'vectorU_RTAFP', 'vectorU_Maia', 'vectorU_RTAFP_HLPLUS');
    end
    
end

x = Umin : stepU : Umax - stepU;

y1 = vectorU_RTAFP;
y2 = vectorU_Maia;
y3=vectorU_RTAFP_HLPLUS;
figure;
plot(x, y1, '--ro', x, y2, '-.b*',x, y3, ':k+' );
xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('RTA-FP', 'COND-SP', 'RTA-FP-HL');
