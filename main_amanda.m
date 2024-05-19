%Amandas main


close all;
clear all;

global m;
global task;
global maxCondBranches;
global maxParBranches;
global p_cond;
global p_par;
global p_term;


workspace_name = 'amanda_main.mat';

maxCondBranches = 0;
maxParBranches = 4; %6
p_cond = 0;
p_par = 0.6;
p_term = 0.4;
Cmin = 1;
Cmax = 100;
beta = 0.1;
rec_depth = 2; %2


addProb = 0.1;
m = 4;
lost = 0;
%rec_depth = 2;
print = 0;

Umin = 0;
Umax = m / 2;
stepU = 0.25;
tasksetsPerU = 2;

nTasksets = tasksetsPerU * ((Umax - Umin)/stepU); %nTasksets is how many tasksets to be done in total
amandaPass = zeros(1, (Umax - Umin) / stepU);

melaniPass = zeros(1, (Umax - Umin) / stepU);



tasksinantaskset = 1;
U = 1;
Ucurr = Umin;

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

x = 1;
%nTasksets
while(x <= nTasksets)
    
    if rem(x-1, (tasksetsPerU * tasksinantaskset)) == 0
        Ucurr = Ucurr + stepU;
    end

%     amandaPass = 0;
%     melaniPass = 0;

    for i = 1 : tasksetsPerU
        
        Uvec = UUniFast(tasksinantaskset, U);
        %Uvec
        Uvec = Uvec * Ucurr;
        %Uvec
        
        for dagNb = 1 : tasksinantaskset
           
            %create the new dag here
            v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}); %maybe don't need condPred and branchlist??


            % create the original DAG for task i

            task(i).v  = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
            task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
            task(i).v = makeItDAG(task(i).v, addProb);

            %newPrintTask(task(i).v);
             % returns the workload accumulated from the source to each node in v
            task(i).v = computeAccWorkload(task(i).v);

            % q is the index of the max accWorkload
            [~, q] = max([task(i).v.accWorkload]);

            %compute the critical path of DAG v starting at vertex q
            cp = getCP(q, task(i).v);

            % the longest path in task(i) is the accWorkload of v(q) (biggest accWorkload)
            task(i).len = task(i).v(q).accWorkload;

            % the worst-case workload of the conditional DAG represented by v
            % returns: [v, wSet, wValue], wSet is the path and wValue is the
            % value of the path
            [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
            

             %U = U + task(i).wcw / task(i).T;
             %task(i).T
             task(i).T = task(i).wcw / Uvec(dagNb);
             task(i).D = task(i).T;
             
             x = x + 1;
             %x

        end
        
        indexU = ceil(Ucurr/stepU);
%         % Amandas test
        modified = task(i);
        %task(i).v
        modified.v = AlgV2(task(i).v, m);
        %'alg'
        %newPrintTask(modified.v);
        modified.v = computeAccWorkload(modified.v);
        [~, q] = max([modified.v.accWorkload]);
        cp = getCP(q, modified.v);
        modified.len = modified.v(q).accWorkload;
%         disp('modified');
%         modified.len
        %task(i).T
        
        if modified.len <= task(i).T
            amandaPass(1, indexU) = amandaPass(1, indexU) + 1;
           
        end
        
        % the worst-case workload of the conditional DAG represented by v
        % returns: [v, wSet, wValue], wSet is the path and wValue is the
        % value of the path
%         [modified.v, ~, modified.wcw] = computeWorstCaseWorkload(modified.v);
%         [~, modified.Z] = computeZk(modified.v);
%         [~, modified.mksp] = computeMakespanUB(modified.v);

        % Melainies test
    
        melani = task(i);
        %newPrintTask(melani.v);
        valMSpan =simulateSCH(modified.v, melani.v, m)
pause
        
        quit();
        [~, melani.Z] = computeZk(melani.v); 
        [~, melani.mksp] = computeMakespanUB(melani.v);
%         disp('melani');
%         melani.mksp

        if melani.mksp <= task(i).T
            melaniPass(1, indexU) = melaniPass(1,indexU) + 1;
        end
        %'end of taskset'
    end
 
    %Figure:

% % 

% % 
% figure('Name','Utilization plot');
% plot(x, y1, '--ro', x, y2, '-.b*');
% xlabel('Utilization');
% ylabel('Number of schedulable task-sets');
% legend('Amanda', 'Melani'); 


end
amandaPass
melaniPass
y1 = amandaPass;
y2 = melaniPass;
x = Umin : stepU : Umax - stepU;
figure('Name','Utilization plot');
plot(x, y1, '--ro', x, y2, '-.b*');
xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('Amanda', 'Melani'); 















% for x = 1 : nTasksets
% 
% 
% 
% 
% 
% 
% 
% 
%     if rem(x - 1, tasksetsPerU) == 0  %increase the x-axis one step if all tasksets hav been done
%         Ucurr = Ucurr + stepU;
% %         amandaPass = 0;
% %         melaniPass = 0;    
% 
%         %generating D and T for task(i)
%         %task(i) = generateSchedParameters(i, beta);
% 
%         Uvec = UUniFast(tasksetsPerU, Ucurr);
%         for y = 1: tasksetsPerU
%             %T=C/Uvec(i)
%             task(y + x).T = task(y +x).C / Uvec(y);
%             Tmin = task(y +x).len;
%             % Tmax = tsk.wcw / beta;
%             %
%             %     int1 = Tmin;
%             %     int2 = Tmax;
%             %     tsk.T = randi([int1, int2]);
%             task(y+x).D = randi([Tmin, task(y+x).T]);
%         end
%     end
% 
%     
%     
%     %U = 0;
%     i = 0; % i is the index for each task in the taskset
% 
%     while 1  %should it be while??
% 
%         i = i + 1;
% 
%         v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}); %maybe don't need condPred and branchlist??
% 
% 
%         % create the original DAG for task i
%         v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
%         task(i).v = v;
%         task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
%         task(i).v = makeItDAG(task(i).v, addProb);
%         
% 
%        
% 
%         original = task(i).v;
%         modified = task(i).v;
% 
%         modified = AlgV2(modified,m);
% 
%         for a = 1:2
%             if a == 1
%                 task(i).v = original;
%             elseif a == 2
%                 task(i).v = modified;
%             end
% 
%             if print == 1
%                 printTask(task(i).v);
%             end
% 
%             % returns the workload accumulated from the source to each node in v
%             task(i).v = computeAccWorkload(task(i).v);
% 
%             % q is the index of the max accWorkload
%             [~, q] = max([task(i).v.accWorkload]);
% 
%             %compute the critical path of DAG v starting at vertex q
%             cp = getCP(q, task(i).v);
% 
%             % the longest path in task(i) is the accWorkload of v(q) (biggest accWorkload)
%             task(i).len = task(i).v(q).accWorkload;
% 
%             % the worst-case workload of the conditional DAG represented by v
%             % returns: [v, wSet, wValue], wSet is the path and wValue is the
%             % value of the path
%             [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
%             
% 
%              U = U + task(i).wcw / task(i).T;
% 
%             %compute the makespan and longest path (different for melainie and amanda)
%             [~, task(i).Z] = computeZk(task(i).v); 
%             [~, task(i).mksp] = computeMakespanUB(task(i).v);
%             
% 
%             
%         end
% 
%         
% 
% 
% 
%     end
% 
% 
% end









