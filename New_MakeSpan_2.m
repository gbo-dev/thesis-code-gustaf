
function [vs, W] = New_MakeSpan_2(vs, D, P)
global m;
%disp('Deadline');
%disp(D);
Print=P;
order=computeTopologicalOrder(vs);

n=length(vs);
W=0;


for i=1:n
vs(i).deadline=D-(vs(i).Lpath-vs(i).C);
vs(i).res=0;
vs(i).IntSet=[];
end



for kk=1:n
    i=order(kk);
    if(Print==1)
      disp('ind');
      disp(i);
      disp('exe');
      disp(vs(i).C);
    end
 
    largestRes=0;
    
    vs(i).IntSet=[];
    
    for k=1: length(vs(i).pred)
       KL=vs(i).pred(k);
       if(length(vs(KL).IntSet)>0)
         vs(i).IntSet=[vs(i).IntSet, vs(KL).IntSet];     
       end
       if(vs(KL).res>largestRes)
       largestRes=vs(KL).res;
       end
    end
 
    vs(i).Offset=largestRes;
    r1=vs(i).Offset;
    d1=vs(i).deadline;

    if(Print==1)
      disp('off');
      disp(vs(i).Offset);
      disp('dead');
      disp(d1);
    end

    sums=0;
    nonIntsum=0;
    sameoffset=0;
    setIntno=[];
    
    for k=1:n 
       j=order(k);
       if(Print==1)
       disp('j');
       disp(j);
       disp(sums);
       end
       if ~(i==j) && isAncestorDescendent(vs, i, j)==0 && vs(j).res>0
         d2=vs(j).res;
         %%r2=vs(j).Offset;
         if(Print==1)
           disp('d2');
           disp(d2);
         end
      C=vs(j).C;
      %a=min(d1,d2);
      %b=max(r1,r2);
      c=max(d2-r1, 0);
      d=0;
      if(c>0)
        % d=min(c, C);
        d=C;
        d=min(C,c);
      end
      if(Print==1)
        disp('C');
        disp(C);
        disp('d');
        disp(d);
      end
      
      TT=0;
      for LK=1: length(vs(i).pred)
        indx=vs(i).pred(LK);
        for OL=1:length(vs(indx).IntSet)
          if(j==vs(indx).IntSet(OL))
              TT=1;
              break;
          end
        end
        if(TT==1)
          break;
        end
      end
   
      if(TT==0)
         if(vs(j).Offset==vs(i).Offset)
            sameoffset=sameoffset+1;
            nonIntsum=nonIntsum+d;
            setIntno=[setIntno, j];
         end
        if(Print==1) 
            disp('dd');
            disp(d);
        end   
        sums=sums+d;
        if(Print==1) 
           disp('  running  ');
           disp(sums);
        end
        vs(i).IntSet=[vs(i).IntSet, j];
      end
   
  end
end  



if(sameoffset<m && sums==nonIntsum)
   
   % vs(i).IntSet=[];
   sums=0;
   vs(i).IntSet=setdiff(unique(vs(i).IntSet), unique(setIntno));
   
%    
%     elei=[];
%     for(LKO=1: length(vs(i).IntSet))
%         JH=vs(i).IntSet(LKO);
%         if(vs(JH).res>vs(i).Offset+vs(i).Offset)
%             d2=vs(JH).res;
%             C=vs(JH).C;
%             c=max(d2-r1, 0);
%             d=min(c, C);
%             sums=sums-d;
%             elei=[elei, JH];
%         end
%     end;
%     vs(i).IntSet=setdiff(unique(vs(i).IntSet), unique(elei));
end

Intr=floor(sums/m);

if(Print==1)
 disp('sum');
 disp(sums);
 disp('Intr');
 disp(Intr);
end

vs(i).res=Intr+vs(i).C+vs(i).Offset;

    if(vs(i).res>vs(i).deadline)
    W=D+1;
    return;
    end
    if(W<vs(i).res)
        W=vs(i).res;
    end;
    if(Print==1)
 disp('exeWWWWW');
 disp(W);
    end
end;

return;

% %W=0;
% %return;
% job=struct('indx', {}, 'rel', {}, 'wcet', {}, 'segment', {}, 'allocated', {});
% relset=[vs.Offset];
% 
% deadset=[vs.Offset];
% n1=length(ExeSet);
% 
% 
% 
% REL=unique(relset);
% 
% 
% %disp(relset);
% %disp(ExeSet);
% %disp(n);
% %disp(REL);
% %disp(m);
% %disp('enter');
% %disp(tcin);
% for(k=1: n)
% job(k).indx=k;
% job(k).rel=relset(k);
% job(k).wcet=ExeSet(k);
% job(k).segment=[];
% job(k).allocated=0;
% %str=sprintf('Job %d %d %d', job(k).indx,job(k).rel,job(k).wcet);
% %disp(str);
% %disp(job(k).segment);
% end
% 
% %Wcarry=0;
% %job(k).segment=[2,3];
% %job(k).segment=[job(k).segment, [5,7]];
% %disp(job(k).segment);
% %job(1).segment=[2, 3, 5, 8, 8, 16];
%  %     job(1).wcet=0;
% %disp(job(1).segment);
% %job(1).segment=[2, 3, 5, 8, 8, 16];
%  %      [job]=findactivejobs(job, 7);
%   %      disp(job(1).segment);
%    %     disp(job(1).wcet);
%   
%  RelLen=length(REL);
%  % disp('RelLenthhh');
%  % W=3;
%  % disp(RelLen);
%  % return; 
%   
%   
% for(z=1 : RelLen)
%   %disp('CurRelLenthhh');
%     %disp(z);
%      if(1)
%         p=1;
%         [job]=findactivejobs(job, REL(z));
%         esum=0;
%         emax=0;
%         numactive=0;
%       %  disp('Main rele');
%       %  disp(z); 
%         %find active jobs emax and esum
%         for(k=1:n)
%             if REL(z)>=job(k).rel && job(k).wcet>0
%                 numactive=numactive+1;
%             %    str=(sprintf('Job %d %d', job(k).rel, job(k).wcet))
%                 esum=esum+job(k).wcet;
%                 if(emax<job(k).wcet)
%                     emax=job(k).wcet;
%                 end
%                             % disp(str);
%                % S=union(S,job(k));            
%             end
%         end
%       %  disp('esum');
%       %  disp(esum);
%         
%       %  disp('emax');
%      %   disp(emax);
%         
%       %  disp('activejobs');
%      %   disp(numactive);
%         
%         
%         
%        % for(k=1:n)
%         %    if REL(z)==job(k).rel && job(k).wcet>0
%        %           Wcarry=Wcarry+job(k).wcet;
%        %     end
%        % end
%         
%         while numactive>0
%             
%             width=ceil(esum/(m-p+1));
%             
%         if(emax<=width)
%             [job]=McNaughton(job, REL(z), REL(z)+width);
%             numactive=0;
%         else
%             for I=1:n
%                 if(job(I).allocated==0 && job(I).rel<=REL(z) && job(I).wcet==emax)
%                     job(I).allocated=1;
%                     job(I).segment=[job(I).segment, REL(z), REL(z)+job(I).wcet];
%                     job(I).wcet=0;
%                     p=p+1;
%                   %  disp('raw');
%                   %  disp(job(I).segment);
%                 end
%             end
%             numactive=0;
%             esum=0;
%             emax=0;
%             for kk=1:n
%             if REL(z)>=job(kk).rel && job(kk).wcet>0
%                 numactive=numactive+1;
%                 %str=sprintf('Job %d %d', job(k).rel, job(k).wcet)
%                 esum=esum+job(kk).wcet;
%                 if(emax<job(kk).wcet)
%                     emax=job(kk).wcet;
%                 end
%                             % disp(str);
%                % S=union(S,job(k));            
%             end
%             end
%             
%         end
%         
%      
%         end
%         
%         for(l=1:n)
%             job(l).allocated=0;
%         end
%         
%         
%         
%     end
%     
%     
% end
% 
% 
% %[job]=findactivejobs(job, tcin);
% 
% %for KK=1: n
%  %   LK=length(job(KK).segment);
%  %   if LK>0
%   %      disp(job(KK).segment)
%  %   end
% 
% %end
% 
% max=0;
% for KK=1: n
%     LK=length(job(KK).segment);
%     if LK>0
%          if(job(KK).segment(LK)>max) 
%           max=job(KK).segment(LK);
%          end
%     end
% end
% %disp('sum');
% %disp(sum);
% W=max;

end
