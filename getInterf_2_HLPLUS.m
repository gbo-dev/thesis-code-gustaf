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

function int2 = getInterf_2_HLPLUS(ind, L, makespan)
% used for RTA (more accurate bound)

    global task;
    global m;
    %disp('enter');
    q1 = task(ind).wcw;
    L=ceil(L);
    Xi_t=max(0,L-(task(ind).T-task(ind).R)-floor(q1/m));
    
    t_cin=Xi_t-floor(Xi_t/task(ind).T)*task(ind).T;
    
    XXX=min((t_cin*m), task(ind).wcw);
    
    WW=min(XXX,NewWCarryJob(task(ind).v, t_cin, makespan));
  %  WW1=HLOnRevNonCPGiven_t_cin(task(ind).v, t_cin);
    
    YYY=task(ind).wcw * floor((max(0,L -t_cin-floor(task(ind).wcw / m)))/task(ind).T)+min(task(ind).wcw, (L-t_cin)*m);;
    
    int2=WW+YYY;
    
    return;
    
    
    
    if(WW1<WW)
   %     WW=WW1;
    end;
    
    if(XXX<WW)
       disp('HL problemmmmmmmmmmmmmm'); 
    end
    
    %q2 = m * rem(L + task(ind).R - (task(ind).wcw / m), task(ind).T);
    YYY=task(ind).wcw * floor((max(0,L -t_cin-floor(task(ind).wcw / m)))/task(ind).T)+min(task(ind).wcw, (L-t_cin)*m);;
    
    int2=WW+YYY;
    
    
%    intttt=get_NC_Interf_2_HLPLUS(ind, L);
    
    X=1;
    if(intttt>int2)
 %       int2=get_NC_Interf_2_HLPLUS(ind, L); %getInterf_2(ind, L);
      %     disp('done'); 
      X=0;
    end
    
  %  intt=getInterf_2(ind, L);
    
    if(0&&~(XXX+YYY==intt))
       disp('CCCCHL problemmmmmmsdfsdfsdfsdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm'); 
    end
    
    if(int2>intt && task(ind).wcw/m<task(ind).D)
       disp('HL problemmmmmmsdfsdfsdfsdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm'); 
       disp('HL problemmmmmmsdfsdfsdfsdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm'); 
       disp('HL problemmmmmmsdfsdfsdfsdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm'); 
       disp('HL problemmmmmmsdfsdfsdfsdmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm'); 
       disp(X);
       for(I=1:length(task(ind).v));
       task(ind).v(I)
       end
       
          disp('does not dominate!!!!');
            disp(intt);
            disp(int2);
             disp('work');
        disp(task(ind).wcw);
        disp('period');
        disp(task(ind).T);
        disp('deadline');
        disp(task(ind).D);
          disp('Res');
        disp(task(ind).R);
        disp('L');
        disp(L);
        disp('WHL');
        disp(WW);
        disp('tcin');
        disp(t_cin);
        input('ppp');
        int2=200000;
    
    end
    
    return;
    
    
    
end