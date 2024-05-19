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

workspace_name = 'FP_NTASKS.mat';

maxCondBranches = 2;
maxParBranches = 6;
p_cond = 0;
p_par = 0.6;
p_term = 0.4;
rec_depth = 2;
Cmin = 1;
Cmax = 100;

tasksetsPerNTask = 1;
n_min = 1;
n_max = 1;
nTasks = n_min - 1;

m = 3;
nTasksets = tasksetsPerNTask * (n_max - n_min + 1);
addProb = 0.1;
Utot = 2;
save_rate = 25;
print = 1;

lost = 0;

stepN = 1;

vectorT_RTAFP = zeros(1, (n_max - n_min + 1) / stepN);
vectorT_Maia = zeros(1, (n_max - n_min + 1) / stepN);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

for x = 1 : nTasksets

    if rem(x - 1, tasksetsPerNTask) == 0
        nTasks = nTasks + stepN;
    end

    U = 0;

    schedRTAFP = 0;
    schedMaia = 0;

    sumU = Utot;


    for i = 1 : nTasks

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});

        v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        z = [];
        test1 = v;
        test1 = assignWCETs(test1, Cmin, Cmax);
        test1 = makeItDAG(test1, addProb);
        test2 = AlgV2(test1, m);
         for i = 1 : length(test1)
            test2(i).C = test1(i).C;
        end
        

        %disp(test1);
        z = [z [test1]];
       
        z = [z [test2]];
        %disp(z);
         
        for p = 1 : 2
            if p == 1
            task(i).v = test1;
            %disp(task(i).v);
            elseif p== 2
                task(i).v = test2;
            end

            %task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
           
            %task(i).v = mod_assignWCETs(task(i).v);

            %task(i).v = makeItDAG(task(i).v, addProb);

            if print == 1
                newPrintTask(task(i).v);
            end
            %disp(v(2).pred);

            %disp(task(i).v);
            


            task(i).v = computeAccWorkload(task(i).v);
            [~, q] = max([task(i).v.accWorkload]);
            cp = getCP(q, task(i).v);
            task(i).len = task(i).v(q).accWorkload;

            [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
            c = ['wcw ', num2str(task(i).wcw)];
            disp(c);

            if i < nTasks
                nextSumU = sumU .* rand^(1 / (nTasks - i));
                Upart = sumU - nextSumU;

                while task(i).len > ceil(task(i).wcw / Upart)
                    nextSumU = sumU .* rand^(1 / (nTasks - i));
                    Upart = sumU - nextSumU;
                end

                sumU = nextSumU;
            else
                Upart = sumU;
            end

            task(i) = generateSchedParametersUUniFast(i, Upart);
            U = U + task(i).wcw / task(i).T;
            
            l = ['longest path ', num2str(task(i).len)]; %I think, not sure if it is the right variable
            disp(l);

            [~, task(i).Z] = computeZk(task(i).v); %makespan
            b = ['makespan ', num2str(task(i).Z)];
            disp(b);

            
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
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

        taskGSSG = testFonsecaSAC15();
        schedMaia = testMaiaRTNS14(taskGSSG);

        indexU = nTasks - n_min + 1;

        %x

        if schedRTAFP == 1
            vectorT_RTAFP(1, indexU) = vectorT_RTAFP(1, indexU) + 1;
        end

        if schedMaia == 1
            vectorT_Maia(1, indexU) = vectorT_Maia(1, indexU) + 1;
        end

        if schedMaia == 1 && schedRTAFP == 0
            lost = lost + 1;
        end

        if rem(x, save_rate) == 0
            save(workspace_name, 'vectorT_RTAFP', 'vectorT_Maia', 'x', 'lost');
        end
    end
end




% x = n_min : n_max;
% 
% y1 = vectorT_RTAFP;
% y2 = vectorT_Maia;
% 
% figure;
% plot(x, y1, '--ro', x, y2, '-.b*');
% xlabel('Number of tasks');
% ylabel('Number of schedulable task-sets');
% legend('RTA-FP', 'COND-SP'); 

