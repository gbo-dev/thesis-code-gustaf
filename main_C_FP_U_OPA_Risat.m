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

%workspace_name = 'D:\00PostDoc\000Conf&Jour Submission\0000_RTSS_2016\Parallel Tasks\CodeINg\cptasks\RisatTests\FP_U.mat';
workspace_name = 'FP_U.mat';
maxCondBranches = 2; 
maxParBranches = 6;
p_cond = 0;
p_par = 0.8;
p_term = 0.2;

rec_depth = 2;
Cmin = 1;
Cmax = 100;
beta = 0.1;

BIG=0;

tasksetsPerU = 100;
addProb = 0.1;
m = 2;
lost = 0;
Umin = 0;
stepU = 0.25;
Umax = m+stepU;
U = 0;
Ucurr = Umin;
save_rate = 10;
print = 0;

nTasksets = tasksetsPerU * ((Umax - Umin) / stepU);

vectorU_RTAFP = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_OPA = zeros(1, (Umax - Umin) / stepU);
vectorU_Maia = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_HLPLUS = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_HLPLUS_OPA = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_U = zeros(1, (Umax - Umin) / stepU);
vectorU_RTAFP_HLPLUS_LimC = zeros(1, (Umax - Umin) / stepU);

task  = struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
revtask =struct('v', {}, 'D', {}, 'T', {}, 'wcw', {}, 'vol', {}, 'len', {}, 'R', {}, 'mksp', {}, 'Z', {});
%revv = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {});
        
for x = 1 :  nTasksets
 disp('n , x');
 disp(nTasksets);
  disp(x);
 
    if rem(x-1, tasksetsPerU) == 0
        Ucurr = Ucurr + stepU;
    end
    
    U = 0;
   
    schedRTAFP = 0;
    schedRTAFP_OPA = 0;
    schedMaia = 0;
    schedRTAFP_HLPLUS = 0;
    schedRTAFP_U=0;
    schedRTAFP_HLPLUS_LimC=0;
    
    i = 0;
    
    % generation of the DAG-tasks
    while 1
        
        i = i + 1;

        v = struct('pred', {}, 'succ', {}, 'cond', {}, 'depth', {}, 'width', {}, 'C', {}, 'accWorkload', {}, 'condPred', {}, 'branchList', {}, 'RevRel', {}, 'Lpath', {}, 'Offset', {}, 'deadline', {}, 'res', {}, 'IntSet', {});
    
       % job=struct('rel', {}, 'wcet', {}, 'localD', {});
        
        %disp('ssdf'+U);
        task(i).v = expandTaskSeriesParallel(v, [], [], rec_depth, 0, 0);
        task(i).v = assignWCETs(task(i).v, Cmin, Cmax);
        task(i).v = makeItDAG(task(i).v, addProb);
        
     %   disp(length(task(i).v));
        
        
        if print == 1
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
            %[~, task(i).mksp] = computeMakespanUB(task(i).v);
       
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
   
  %  disp('here1');
   
  
    schedRTAFP_OPA=1;
    
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    
      
    for PL=nTasks:-1:1 
    task(PL).R=task(PL).D;
    end
    
   
    for PL=nTasks:-1:1
        remain=PL;
        while remain >0
            [task(PL).R, OK] = runRTA_FP_2(i, task(i).mksp); %runRTA_FP_2_HLPLUS(PL, task(PL).mksp);
        
            task(PL).R=task(PL).D;
            if OK==1
                break;
            else
                remain=remain-1;
                if remain>0
                     X1=task(1:remain-1);
                     X2=task(PL);
                     X3=task(remain+1:PL-1);
                     X4=task(remain);
                     X5=task(PL+1:nTasks);
                     task=[X1,X2,X3,X4,X5];
               else
                   break;
               end
            end
        end
        if remain ==0
            schedRTAFP_OPA=0;
            
            break;
        end
    end
    
     

   
    [~, ind] = sort([task.D]);
    task = task(ind);
    BB=0;
     for i = 1 : nTasks
        %[~, task(i).mksp] = computeMakespanUB(task(i).v);
         NN=task(i).mksp;
        
        [task(i).v,NN]=New_MakeSpan_2(task(i).v, task(i).D, 0);
         if(NN>task(i).mksp)
         disp('probss Msoddddddddddddddddan');
         disp(task(i).mksp);
         BB=1;
         end
         
           if ((task(i).wcw/m >NN || BB==1) && task(i).mksp<task(i).D)
           disp('XXXXXXXXXXXXXXvvvvvvvvvvvvvvvvvvvvv'); 
           NN=New_MakeSpan_2(task(i).v, task(i).D, 1);
           task(i)
           task(i).R
           task(i).mksp
           NN
           
           %  if print == 1
            printTask(task(i).v);
           %end
           return;
           
           end
           %disp(task(i).mksp);
         task(i).mksp=NN; 
     end;
    

    
     
     
    for i = 1 : nTasks
        %[~, task(i).mksp] = computeMakespanUB(task(i).v);
%         NN=New_MakeSpan(task(i).v);
%          if(NN>task(i).mksp)
%          disp('prob');
%          end
         
        [task(i).R, schedRTAFP_HLPLUS] = runRTA_FP_2_HLPLUS(i,  task(i).mksp);
        
        %[task(i).R, schedRTAFP_HLPLUS] = runRTA_FP_2_HLPLUS(i, task(i).mksp);
         
        if schedRTAFP_HLPLUS == 0
            break;
        end
    end
    
    
    
    schedRTAFP_HLPLUS_OPA=1;
 
    
    if(1)
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    
    for i = 1 : nTasks
        
        [task(i).R, schedRTAFP_HLPLUS_LimC] = runRTA_FP_2_HLPLUS_Limcarry(i, task(i).mksp);

        if schedRTAFP_HLPLUS_LimC == 0
            break;
        end
    end
    
    
   % taskGSSG = testFonsecaSAC15();
   % schedMaia = testMaiaRTNS14(taskGSSG);
    
    schedRTAFP_HLPLUS_OPA=1;
    
    [~, ind] = sort([task.D]);
    task = task(ind);
    
    
      
    for PL=nTasks:-1:1 
    task(PL).R=task(PL).D;
    end
    
   
    for PL=nTasks:-1:1
        remain=PL;
        while remain >0
            [task(PL).R, OK] = runRTA_FP_2_HLPLUS_Limcarry(i, task(i).mksp); %runRTA_FP_2_HLPLUS(PL, task(PL).mksp);
        
            task(PL).R=task(PL).D;
            if OK==1
                break;
            else
                remain=remain-1;
                if remain>0
                     X1=task(1:remain-1);
                     X2=task(PL);
                     X3=task(remain+1:PL-1);
                     X4=task(remain);
                     X5=task(PL+1:nTasks);
                     task=[X1,X2,X3,X4,X5];
               else
                   break;
               end
            end
        end
        if remain ==0
            schedRTAFP_HLPLUS_OPA=0;
            
            break;
        end
    end
    
    end
    
    
            
    indexU = ceil(Ucurr / stepU);

    if schedRTAFP == 1
        vectorU_RTAFP(1, indexU) = vectorU_RTAFP(1, indexU) + 1;
    end

    if schedRTAFP_OPA == 1
        vectorU_RTAFP_OPA(1, indexU) = vectorU_RTAFP_OPA(1, indexU) + 1;
    end

    if schedRTAFP_HLPLUS == 1
        vectorU_RTAFP_HLPLUS(1, indexU) = vectorU_RTAFP_HLPLUS(1, indexU) + 1;
    end
    
     if schedRTAFP_HLPLUS_LimC == 1
        vectorU_RTAFP_HLPLUS_LimC(1, indexU) = vectorU_RTAFP_HLPLUS_LimC(1, indexU) + 1;
     end
    
    if schedRTAFP_HLPLUS_OPA == 1
        vectorU_RTAFP_HLPLUS_OPA(1, indexU) = vectorU_RTAFP_HLPLUS_OPA(1, indexU) + 1;
    end
%     
%     if  schedRTAFP_U == 1
%         vectorU_RTAFP_U(1, indexU) = vectorU_RTAFP_U(1, indexU) + 1;
%     end
%     
    if schedRTAFP == 1 && schedRTAFP_HLPLUS == 0
    disp('Not dominate ...Implementaion problem');
    end
    
     if schedRTAFP_HLPLUS == 1 && schedRTAFP_HLPLUS_OPA == 0
      disp('Not OPAAAAAAAAAAAAAA dominate ...Implementaion problem....Amy not because Ri is replaced by D');
     end
    
    if 0 && schedRTAFP_HLPLUS == 0 && schedRTAFP_HLPLUS_OPA == 1
    disp('GOOD');
    end
    
  %  if schedMaia == 1
  %      vectorU_Maia(1, indexU) = vectorU_Maia(1, indexU) + 1;
  %  end

   % if schedMaia == 1 && schedRTAFP == 0
   %     lost = lost + 1;
   % end
    
   % if rem(x, save_rate) == 0
   %     save(workspace_name, 'x', 'lost', 'vectorU_RTAFP', 'vectorU_Maia', 'vectorU_RTAFP_HLPLUS', 'vectorU_RTAFP_HLPLUS_OPA');
   % end
    
    if rem(x, save_rate) == 0
        save(workspace_name, 'x', 'vectorU_RTAFP', 'vectorU_RTAFP_HLPLUS',  'vectorU_RTAFP_HLPLUS_LimC', 'vectorU_RTAFP_OPA', 'vectorU_RTAFP_HLPLUS_OPA');
    end
    if(x+tasksetsPerU==nTasksets)
       break; 
    end
end

x = Umin : stepU : Umax - stepU;

y1 = vectorU_RTAFP;
%y2 = vectorU_Maia;
y2=vectorU_RTAFP_HLPLUS;
y3=vectorU_RTAFP_HLPLUS_LimC;
y4= vectorU_RTAFP_OPA;
y5=vectorU_RTAFP_HLPLUS_OPA;

figure;
%plot(x, y1, '--ro', x, y2, '-.b*',x, y3, ':k+',x, y4, ':g' );
%plot(x, y1, '--ro', x, y3, '-.b*',x, y4, ':k+', x, y5, ':g');

%plot(x, y5, '--ro', x, y4, '--md', x, y3, '--k+', x, y2, '--g^', x, y1, '--b*');
if(BIG==1)
hold on
plot(x, y5, '--ro', 'LineWidth', 2);
plot(x, y4, '--md', 'LineWidth', 2);
plot(x, y3, '--k+', 'LineWidth', 2);
plot(x, y2, '--g^', 'LineWidth', 2);
plot(x, y1, '--b*', 'LineWidth', 2);
hold off

xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('Our-OPA', 'MBBMB-OPA', 'Our-LC-DM', 'Our-NLC-DM','MBBMB-DM','Location', 'southwest');

else
hold on
plot(x, y5, '--ro');
plot(x, y4, '--md');
plot(x, y3, '--k+');
plot(x, y2, '--g^');
plot(x, y1, '--b*');
hold off

xlabel('Utilization');
ylabel('Number of schedulable task-sets');
legend('Our-OPA', 'MBBMB-OPA', 'Our-LC-DM', 'Our-NLC-DM','MBBMB-DM','Location', 'southwest');
end;