

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

%workspace_name = 'D:\00PostDoc\000Conf&Jour Submission\0000_RTSS_2016\Parallel Tasks\CodeINg\cptasks\RisatTests\FP_U.mat';
workspace_name = 'FP_U.mat';
maxCondBranches = 2; 
maxParBranches = 5;
p_cond = 0;
p_par = 0.5;
p_term = 0.5;

rec_depth = 2;
Cmin = 10;
Cmax = 100;
beta = 0.1;

BIG=0;

n_min = 1;
n_max = 12;
nTasks = n_min - 1;

tasksetsPerNTask = 5;

tasksetsPerU=tasksetsPerNTask;

addProb = 0.1;

for(mm=3:4)
m = 2^mm;
Utot = m/2;

s=sprintf('Scale1NvarymM%dUtot%d.fig', m,m/2);
lost = 0;
Umin = 0;
stepU = 0.25;
Umax = m;
if(m==4)
    n_max=15;
else if (m==8)
        n_max=25;
    end
end
U = 0;
Ucurr = Umin;
save_rate = 10;
print = 0;

stepN = 1;

nTasksets = tasksetsPerNTask * ((n_max - n_min + 1)/ stepN);


vectorU_RTAFP = zeros(1, (n_max - n_min + 1) / stepN);
vectorU_RTAFP_HLPLUS = zeros(1, (n_max - n_min + 1) / stepN);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
for x = 1 :  nTasksets
 disp('n , x, ucurr');
 disp(nTasksets);
 disp(x);
 disp(Ucurr);
 disp(tasksetsPerU);
 
    
    if rem(x - 1,  tasksetsPerU) == 0
        nTasks = nTasks + stepN;
        Sc=0;
    end

    U = 0;
   
    schedRTAFP = 0;
    schedRTAFP_OPA = 0;
    schedMaia = 0;
    schedRTAFP_HLPLUS = 0;
    schedRTAFP_HLPLUS2 = 0;
    schedRTAFP_U=0;
    schedRTAFP_HLPLUS_LimC=0;
    
    i = 0;
    
    sumU = Utot;
    % generation of the DAG-tasks
    %while 1
     for i = 1 : nTasks
   
       % i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {}, 'Lpath', {}, 'Offset', {}, 'deadline', {}, 'res', {}, 'IntSet', {});
        v2 = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {}, 'Lpath', {}, 'Offset', {}, 'deadline', {}, 'res', {}, 'IntSet', {});
    
       % job=struct('rel', {}, 'wcet', {}, 'localD', {});
        
        %disp('ssdf'+U);
        task(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = makeItDAG(task(i).v, addProb);
        %task2(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        %task2(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        %task2(i).v = makeItDAG(task(i).v, addProb);
        
     %   disp(length(task(i).v));
        
        
        if print == 1
            printTask(task(i).v);
        end

        task(i).v = computeAccWorkload(task(i).v);
        [~, q] = max([task(i).v.accWorkload]);
        cp = getCP(q, task(i).v);
        task(i).len = task(i).v(q).accWorkload;

        [task(i).v, ~, task(i).wcw] = computeWorstCaseWorkload(task(i).v);

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
        
        [~, task(i).Z] = computeZk(task(i).v); 
        [~, task(i).mksp] = computeMakespanUB(task(i).v);
        
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
    
        
    indexU = (nTasks - n_min + 1)/stepN;

    if schedRTAFP == 1
        vectorU_RTAFP(1, indexU) = vectorU_RTAFP(1, indexU) + 1;
      %  Sc=Sc+1;
      %  disp('sdfsd');
      %  disp(Sc);
    end

   
    if schedRTAFP_HLPLUS == 1
        vectorU_RTAFP_HLPLUS(1, indexU) = vectorU_RTAFP_HLPLUS(1, indexU) + 1;
    end
    
        
    if rem(x, save_rate) == 0
        save(workspace_name, 'x', 'vectorU_RTAFP', 'vectorU_RTAFP_HLPLUS');
    end
    
end

x = n_min:stepN : n_max;

%x = Umin+stepU : stepU : Umax;

%vectorU_RTAFP

filename1=s; %(s);

y1 = vectorU_RTAFP/tasksetsPerU;
%y2 = vectorU_Maia;
y2=vectorU_RTAFP_HLPLUS/tasksetsPerU;
%y3=vectorU_RTAFP_HLPLUS2;%/tasksetsPerU;
%y3=vectorU_RTAFP_HLPLUS_LimC;
%y4= vectorU_RTAFP_OPA;
%y5=vectorU_RTAFP_HLPLUS_OPA;

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

xlabel('Number of tasks in a task set (n)');
ylabel('Fraction of schedulable task-sets');
legend('Our-DM','MBBMB-DM','Location', 'southwest');

%legend('Our-NLC-Other','Our-NLC-DM','MBBMB-DM','Location', 'southwest');

savefig(filename1);
end