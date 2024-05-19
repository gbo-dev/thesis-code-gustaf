

%algNotOk: returns all the superPred and the superSucc for node i in v
function set = algNotOk(v, i)
set = union(superPred(v,i), superSucc(v,i));
end