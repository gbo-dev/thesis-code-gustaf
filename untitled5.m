%Amandas main


close all;
clear all;

global m;
global task;
% global maxCondBranches;
% global maxParBranches;
global p_cond;
global p_par;
global p_term;


workspace_name = 'amanda_main.mat';

% maxCondBranches = 0;
% maxParBranches = 6;
p_cond = 0;
p_par = 0.6;
p_term = 0.4;
Cmin = 1;
Cmax = 100;
beta = 0.1;


addProb = 0.1;
m = 4;
lost = 0;
rec_depth = 2;
print = 0;

Umin = 0;
Umax = 4;
stepU = 0.25;
tasksetsPerU = 10;

nTasksets = tasksetsPerU * ((Umax - Umin)/stepU); %nTasksets is how many tasksets to be done in total

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});

tasksinAtaskset = 2; 

U = 0;
Ucurr = Umin;
amandaPass = 0;
melaniePass = 0;



Each U, how may taskset? = 3   Amanda{F, T, T}  Melani[F, F, T]
             how may tasks in each tasjkset...yourcas e= 1


             Ulevel = 0.25, 1.0, 2.0 
                     

x=1;
while(x<=nTasksets)   //9



  if(rem(x-1, tasksetperU*tasksinAtaskset)==0{
          
           Ucurr= Ucurr+StepU;   /0.25 
  }

      amandaPss=0;
      melanipass=0;
 %% generating all the TASKSETS for one Uti point 
 for taskset=1: tasksetsPerU //3
     

     U[tasksinAtaskset]=UUNIFAST(1, tasksinAtaskset)   //2 tasks          [1] 
     U[tasksinAtaskset] = U[tasksinAtaskset]*Ucurr;   [.3*0.25, 0.7*0.25]
     %% is generating all the N tasks for ONE taskset
     for taskNo=1:tasksinAtaskset
               cc=newDAG;
               cc.T = cc.w/U[taskNo];
               x=x+1 ;    

     end    

     amandaPss= amandaPss+TESTAMANDA(cc);
     melanipass=melanipass+TESTELANI(cc)
 end

 GRAPHpointAmanda(Utilizatiopintnum)=amandaPss/tasksetsPerU;

  end of whoilw
         
    


    if rem(x - 1, tasksetsPerU) == 0  %increase the x-axis one step if all tasksets hav been done
        Ucurr = Ucurr + stepU;
%         amandaPass = 0;
%         melaniePass = 0;    

        %generating D and T for task(i)
        %task(i) = generateSchedParameters(i, beta);

        Uvec = UUniFast(tasksetsPerU, Ucurr);
        for y = 1: tasksetsPerU
            %T=C/Uvec(i)
            task(y + x).T = task(y +x).C / Uvec(y);
            Tmin = task(y +x).len;
            % Tmax = tsk.wcw / beta;
            %
            %     int1 = Tmin;
            %     int2 = Tmax;
            %     tsk.T = randi([int1, int2]);
            task(y+x).D = randi([Tmin, task(y+x).T]);
        end
    end

    
    
    %U = 0;
    i = 0; % i is the index for each task in the taskset

    while 1  %should it be while??

        i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}); %maybe don't need condPred and branchlist??


        % create the original DAG for task i
        v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = v;
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = makeItDAG(task(i).v, addProb);
        

       

        original = task(i).v;
        modified = task(i).v;

        modified = AlgV2(modified,m);

        for a = 1:2
            if a == 1
                task(i).v = original;
            elseif a == 2
                task(i).v = modified;
            end

            if print == 1
                printTask(task(i).v);
            end

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
            

             U = U + task(i).wcw / task(i).T;

            %compute the makespan and longest path (different for melainie and amanda)
            [~, task(i).Z] = computeZk(task(i).v); 
            [~, task(i).mksp] = computeMakespanUB(task(i).v);
            

            
        end

        



    end


end









