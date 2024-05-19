function [jobs]=findactivejobs(job, tz)

n=length(job);
%disp('total Jobs');
%disp(n);
 seg=[];
   remseg=[];
   
for k=1:n
   if(job(k).allocated==0) 
   job(k).segment=sort(job(k).segment);
   seg=[];
   remseg=[];
   exit=0;
   for(j=1: length(job(k).segment))

       if(job(k).segment(j)<tz)
           seg=[seg,job(k).segment(j)];
          % disp('xx');
           remseg=[remseg, job(k).segment(j+1:length(job(k).segment))];
           GH=length(job(k).segment);
           if GH==0
              exit=2;
              break;
           end
      
       else if(job(k).segment(j)==tz && rem(j,  2)==0)
         %  disp('yy');
           seg=[seg,job(k).segment(j)];
           exit=1;
           if(j+1<length(job(k).segment))
           % job(k).segment=job(k).segment(j+1:length(job(k).segment));
          % remseg=[remseg, job(k).segment(j+1:length(job(k).segment))];
           end
       else if(job(k).segment(j)==tz && rem(j,  2)==1)
          % job(k).segment=job(k).segment(j:length(job(k).segment));
         %  remseg=[remseg, job(k).segment(j:length(job(k).segment))];          
        %   disp('PP');
           exit=1;
       else if(job(k).segment(j)>tz && rem(j,  2)==1)
          % remseg=[remseg, job(k).segment(j:length(job(k).segment))];          
          % job(k).segment=job(k).segment(j: length(job(k).segment));
           exit=1;
       else if(job(k).segment(j)>tz && rem(j,  2)==0)
       %   disp('zz');
        %  disp(job(k).segment(j));
         % job(k).segment(j-1)=tz;   
        %  job(k).segment=job(k).segment(j-1: length(job(k).segment));
        %  remseg=[remseg, job(k).segment(j-1:length(job(k).segment))];          
          seg=[seg,tz];    
          exit=1;
           end
           end
           end
           end
       end
      
      if(exit==2)%null
        %  disp('beforeXX');
        %  disp(job(k).segment);
          job(k).segment=seg;
        %  disp('afterXX')
          break;
      end
      if(exit==1)
        %  disp('before')
       %   disp(job(k).segment);
          LKK=length(job(k).segment);
          remseg=[];
          
          for LP=1: length(seg)
              
              if ~(seg(LP)==job(k).segment(LP))
                  remseg=[seg(LP)];
                  remseg =[remseg, job(k).segment(LP:LKK)];
                  break;
              end
               
              if LP==length(seg)
              remseg=job(k).segment(LP+1:LKK);
              end
              
          end
          
          
       %   disp('after')
        %  disp(seg);
        %  disp(remseg);
          
          sum=0;
          
          CC=length(remseg);
          for LL=2:2:CC
              sum=sum+remseg(LL)-remseg(LL-1);
          end
       %   disp(sum);
          job(k).wcet=job(k).wcet+sum;
          job(k).segment=seg;
          break;
      end
      
   end
   
end
end
jobs=job;
end
