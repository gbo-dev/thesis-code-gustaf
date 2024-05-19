
%algOk: returns the set of 
function set = algOk(v,i)
all = superSucc(v, 1); %add 1
notandself = union(algNotOk(v,i), i);
set = setdiff(all,notandself);
end