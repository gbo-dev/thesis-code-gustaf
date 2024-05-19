function int2 = get_NC_Interf_2_HLPLUS(ind, L)
% used for RTA (more accurate bound)

    global task;
    global m;
    
    q1 = task(ind).wcw;

    fullIns=floor(L/task(ind).T);
    
    carryout=min((L-(fullIns*task(ind).T))*m, q1);
    
    if(carryout<0)
        disp('carryout negative');
    end
    int2 = fullIns * q1+ carryout; 
    
    
    
end