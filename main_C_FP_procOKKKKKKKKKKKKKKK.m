close all;
clear all;

global m;
global task;
global maxCondBranches;
global maxParBranches;
global p_cond;
global p_par;
global p_term;

workspace_name = 'FP_PROC.mat';

maxCondBranches = 2; 
maxParBranches = 5; 
p_cond = 0;
p_par = 0.5;
p_term = 0.5;
rec_depth = 2;
Cmin = 1;
Cmax = 100;
print = 0;
save_rate = 25;
beta = 0.1;
stepM = 4;
tasksetsPerProc = 5;
for(ut=1:3)
Utot = 2^ut;
m_min = Utot;
m_max =128+2^ut;

lost = 0;

m =m_min-stepM;

ss=sprintf('Varym%dUtot%d.fig', m_min, Utot);
filename1=ss;


nTasksets = tasksetsPerProc * ((m_max - m_min)/stepM+1);

addProb = 0.1;



vectorM_RTAFP = zeros(1, (m_max - m_min) / stepM+1);
vectorM_Maia = zeros(1, (m_max - m_min) / stepM+1);
vectorM_RTAFP_HLPLUS=zeros(1, (m_max - m_min) / stepM+1);

%task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
for x = 1 : nTasksets
    
    x
    nTasksets
    
    if rem(x - 1, tasksetsPerProc) == 0
        m = m + stepM;
    end

    U = 0;
    
    schedRTAFP = 0;
    schedMaia = 0;
    
    i = 0;
    
    % generation of the DAG-tasks
    while 1

        i = i + 1;
        
       % v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});
 v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {}, 'Lpath', {}, 'Offset', {}, 'deadline', {}, 'res', {}, 'IntSet', {});
       
        v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0); 
        task(i).v = v;
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);

        task(i).v = makeItDAG(task(i).v, addProb);

        if print == 1
            printTask(task(i).v);
        end

        task(i).v = computeAccWorkload(task(i).v);
        [~, q] = max([task(i).v.accWorkload]);
        cp = getCP(q, task(i).v);
        task(i).len = task(i).v(q).accWorkload;
        task(i).vol = computeVolume(task(i).v);

        [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);
                
        task(i) = generateSchedParameters(i, beta);
        U = U + task(i).wcw / task(i).T;
        
        if U <= Utot
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v); 
        else
            Uprev = U - task(i).wcw / task(i).T;
            Utarget = Utot - Uprev;
            %task(i).T = randi([task(i).len floor(task(i).wcw / beta)]);
            task(i).T = floor(task(i).wcw / Utarget);
            task(i).D = task(i).len+ceil(rand*(task(i).T-task(i).len));
            U = Uprev + task(i).wcw / task(i).T;
            
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
            nTasks = i;
            break;
        end
    end
    
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    for i = 1 : nTasks
        
        [task(i).R, schedRTAFP] = runRTA_FP_2(i, task(i).mksp);
        if (task(i).wcw/m >task(i).R && schedRTAFP)
           disp('MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM'); 
           task(i)
           task(i).R
           task(i).mksp
           
           
        end
        
        if schedRTAFP == 0
            break;
        end
    end
   
   
   [~, ind] = sort([task.D]);
    task = task(ind);
    
     for i = 1 : nTasks
         NN=task(i).mksp;
         
        [task(i).v,NN]=New_MakeSpan_2(task(i).v, task(i).D, 0);
        
         if(NN>task(i).mksp)
         disp('probss Msoddddddddddddddddan');
         disp(task(i).mksp);
         BB=1;
         end
         
         task(i).mksp=NN; 
     end;
    
   
    
    for i = 1 : nTasks
        %[~, task(i).mksp] = computeMakespanUB(task(i).v);
%         NN=New_MakeSpan(task(i).v);
%          if(NN>task(i).mksp)
%          disp('prob');
%          end
         
        [task(i).R, schedRTAFP_HLPLUS] = runRTA_FP_2_HLPLUS(i,task(i).mksp);
        %[task(i).R, schedRTAFP_HLPLUS] = runRTA_FP_2_HLPLUS(i, task(i).mksp);
         
        if schedRTAFP_HLPLUS == 0
            break;
        end
    end
    
    
    indexU = (m - m_min)/stepM + 1;
    m
    m_min
    
        
    if schedRTAFP == 1
        vectorM_RTAFP(1, indexU) = vectorM_RTAFP(1, indexU) + 1;
    end

    if schedRTAFP_HLPLUS == 1
        vectorM_RTAFP_HLPLUS(1, indexU) = vectorM_RTAFP_HLPLUS(1, indexU) + 1;
    end

    
    if rem(x, save_rate) == 0
       save(workspace_name, 'vectorM_RTAFP', 'vectorM_Maia', 'x', 'lost');
    end
    
end

x = m_min :stepM: m_max;
y1 = vectorM_RTAFP/tasksetsPerProc;
y2 = vectorM_RTAFP_HLPLUS/tasksetsPerProc;

figure;
%plot(x, y1, '--ro', x, y2, '-.b*',x, y3, ':k+',x, y4, ':g' );
%plot(x, y1, '--ro', x, y3, '-.b*',x, y4, ':k+', x, y5, ':g');

%plot(x, y5, '--ro', x, y4, '--md', x, y3, '--k+', x, y2, '--g^', x, y1, '--b*');
hold on

%plot(x, y5, '--ro', 'LineWidth', 2);
%plot(x, y4, '--md', 'LineWidth', 2);
%plot(x, y3, '--r+', 'LineWidth', 2);
plot(x, y2, '--g^', 'LineWidth', 2);
plot(x, y1, '--b*', 'LineWidth', 2);
hold off

xlabel('Number of Processors (m)');
ylabel('Acceptance Ratio');
legend('Our-DM','MBBMB-DM','Location', 'southeast');

%legend('Our-NLC-Other','Our-NLC-DM','MBBMB-DM','Location', 'southwest');

savefig(filename1);



end