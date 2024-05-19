function [job]=McNaughton(job, tz, endtz)
p=1;
t=tz;
%disp('tz....endtz');
%disp(tz);
%disp(endtz);

for i=1: length(job)
   if(job(i).rel<=tz && job(i).wcet>0)
       %disp('b4Job MC ')
       % disp(i);
       % disp(job(i).segment);
       % disp(job(i).wcet);
        if(job(i).wcet>endtz-t)
            job(i).segment=[job(i).segment, t,endtz];
            job(i).wcet=job(i).wcet-(endtz-t);
            t=tz;
            job(i).segment=[job(i).segment, t,t+job(i).wcet];
            t=t+job(i).wcet;
            job(i).wcet=0;
        else
            job(i).segment=[job(i).segment, t,t+job(i).wcet];
            t=t+job(i).wcet;
            job(i).wcet=0;
        end
        job(i).segment=sort(job(i).segment);
      %  disp('Job MC ')
      %  disp(i);
      %  disp(job(i).segment);
        
   end
   
end

end
