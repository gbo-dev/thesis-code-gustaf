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
function [W] = HLOnRevNonCPGiven_t_cin(v, tcin)
global m;
if tcin==0
W=0;
return;
end
tcin=ceil(tcin);

[~,I]=sort([v.RevRel]);
vs=v(I);
job=struct('indx', {}, 'rel', {}, 'wcet', {}, 'segment', {}, 'allocated', {});
relset=[vs.RevRel];
ExeSet=[vs.C];
n=length(ExeSet);
REL=unique(relset);
%disp(relset);
%disp(ExeSet);
%disp(n);
%disp(REL);
%disp(m);
%disp('enter');
%disp(tcin);
for(k=1: n)
job(k).indx=k;
job(k).rel=relset(k);
job(k).wcet=ExeSet(k);
job(k).segment=[];
job(k).allocated=0;
%str=sprintf('Job %d %d %d', job(k).indx,job(k).rel,job(k).wcet);
%disp(str);
%disp(job(k).segment);
end

%Wcarry=0;
%job(k).segment=[2,3];
%job(k).segment=[job(k).segment, [5,7]];
%disp(job(k).segment);
%job(1).segment=[2, 3, 5, 8, 8, 16];
 %     job(1).wcet=0;
%disp(job(1).segment);
%job(1).segment=[2, 3, 5, 8, 8, 16];
 %      [job]=findactivejobs(job, 7);
  %      disp(job(1).segment);
   %     disp(job(1).wcet);
  
  RelLen=length(REL);
 % disp('RelLenthhh');
 % W=3;
 % disp(RelLen);
 % return; 
  
  
for(z=1 : RelLen)
  %disp('CurRelLenthhh');
    %disp(z);
    if(REL(z)<tcin)
        p=1;
        [job]=findactivejobs(job, REL(z));
        esum=0;
        emax=0;
        numactive=0;
      %  disp('Main rele');
      %  disp(z); 
        %find active jobs emax and esum
        for(k=1:n)
            if REL(z)>=job(k).rel && job(k).wcet>0
                numactive=numactive+1;
            %    str=(sprintf('Job %d %d', job(k).rel, job(k).wcet))
                esum=esum+job(k).wcet;
                if(emax<job(k).wcet)
                    emax=job(k).wcet;
                end
                            % disp(str);
               % S=union(S,job(k));            
            end
        end
      %  disp('esum');
      %  disp(esum);
        
      %  disp('emax');
     %   disp(emax);
        
      %  disp('activejobs');
     %   disp(numactive);
        
        
        
       % for(k=1:n)
        %    if REL(z)==job(k).rel && job(k).wcet>0
       %           Wcarry=Wcarry+job(k).wcet;
       %     end
       % end
        
        while numactive>0
            
            width=ceil(esum/(m-p+1));
            
        if(emax<=width)
            [job]=McNaughton(job, REL(z), REL(z)+width);
            numactive=0;
        else
            for I=1:n
                if(job(I).allocated==0 && job(I).rel<=REL(z) && job(I).wcet==emax)
                    job(I).allocated=1;
                    job(I).segment=[job(I).segment, REL(z), REL(z)+job(I).wcet];
                    job(I).wcet=0;
                    p=p+1;
                  %  disp('raw');
                  %  disp(job(I).segment);
                end
            end
            numactive=0;
            esum=0;
            emax=0;
            for kk=1:n
            if REL(z)>=job(kk).rel && job(kk).wcet>0
                numactive=numactive+1;
                %str=sprintf('Job %d %d', job(k).rel, job(k).wcet)
                esum=esum+job(kk).wcet;
                if(emax<job(kk).wcet)
                    emax=job(kk).wcet;
                end
                            % disp(str);
               % S=union(S,job(k));            
            end
            end
            
        end
        
     
        end
        
        for(l=1:n)
            job(l).allocated=0;
        end
        
        
        
    end
    
    
end


[job]=findactivejobs(job, tcin);

%for KK=1: n
 %   LK=length(job(KK).segment);
 %   if LK>0
  %      disp(job(KK).segment)
 %   end

%end

sum=0;
for KK=1: n
    LK=length(job(KK).segment);
    if LK>0
          
          for LL=2:2:LK
              sum=sum+job(KK).segment(LL)-job(KK).segment(LL-1);
          end
    end

end
%disp('sum');
%disp(sum);
W=sum;

end
