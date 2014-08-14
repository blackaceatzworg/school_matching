function [ listdp ] = DropStudents(type, Nst, Nsc, matchst, Ndp, good, medium)
    
    % type = 1 : Randomly choose students that drop
    % type = 2 : Randomly choose students that drop from set of students
    % matched to bad schools
    
    % n = number of students matched to bad schools
    n=Nsc-ceil(Nsc*good)-ceil(Nsc*medium);
    indbad = ceil(Nsc*good)+ceil(Nsc*medium)+1;
    
    if (type == 1)
        %Randomly choose students that are dropping out
        tmp=randperm(Nst);
        listdp=tmp(1:Ndp);
    else
        badmatch = (matchst>=indbad).*(1:Nst);
        listbad = badmatch(badmatch~=0);

        tmp=randperm(n);        
  
        listdp=listbad(tmp(1:Ndp));        
    end
end

