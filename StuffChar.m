function str = StuffChar(str,char1)

inds = find(str == char1);

for i=length(inds):-1:1
    str = [str(1:inds(i)-1) '\' str(inds(i):end)];
end
