function v = mod_assignWCETs(v)
% assigns WCETs to vertices in v in a range [minWCET, maxWCET]
    
    for i = 1 : length(v)
        v(i).C = 10;
    end
end