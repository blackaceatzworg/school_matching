function [ matchst, matchsc ] = DA_alg( PrefSt, Nst, PrefSc, Nsc )
%DA_alg: Gale Shapley Deferred Acceptance Algorithm
%   INPUTS:
%   PrefSt:     student's preferences (rows: Schools; columns: ranking of students for each school)
%   Nst:        # of students
%   PrefSc:     school's preferences (rows: Schools; columns: ranking of students for each school)
%   Nsc:        # of schools
%   OUTPUTS:
%   matchst:    row vector with the school Id (number) matched to each student 
%   matchsc:    row vector with the student Id (number) matched to each student 


matchst=zeros(1,Nst);   % vector with matching of each student
matchsc=zeros(1,Nsc);   % vector with matching of each school

conv=0;
iter=0;
NRej=ones(1,Nst);       % index in list of preferences of first preference that has not rejected the student
IdPrefSc=ones(1,Nst);   % Id (index number) of next preferred school for each student i (that has not rejected him)

while(conv==0)
    iter=iter+1;
    for i=1:Nst
        if(NRej(i)<=Nsc)
            IdPrefSc(i)=PrefSt(i,NRej(i)); 
        else
            % if NRej(i) > Nsc: Student has made an offer to all schools.
            % Won't make more offers.
            IdPrefSc(i)=0;
        end        
    end
    
    listoffer=((matchst==0).*(IdPrefSc>0)); % list of offering students in this round (= unmatched students .* students with preferences > 0)
    for i=1:Nst
        
        if(listoffer(1,i) == 1)
            %student i makes an offer to next school
            %in his preference list that has not rejected him
            
            if(matchsc(1,IdPrefSc(i)) == 0)
                % school is unmatched temporarily match school and student
                matchst(1,i) = IdPrefSc(i);
                matchsc(1,IdPrefSc(i))=i;
            else
                %School is temporarily matched: test preference of school
                
                %position of new student in preference list of school
                newst=find(PrefSc(IdPrefSc(i),:)==i);
                
                %Id of old student and his position in preference list of school
                oldstId=matchsc(1,IdPrefSc(i));
                oldst=find(PrefSc(IdPrefSc(i),:)==oldstId);
                
                if (oldst>newst)
                    %School prefers new student to the current one matched
                    
                    %unmatch current current student and increment his not
                    %rejected index
                    matchst(1,oldstId) = 0; 
                    NRej(oldstId)=NRej(oldstId)+1;
                    
                    %match new student to this school
                    matchst(1,i) = PrefSt(i,NRej(i));
                    matchsc(1,PrefSt(i,NRej(i)))=i;
                else
                    NRej(i)=NRej(i)+1;
                end
            end
        end
    end
    
    if (sum(listoffer)==0)
        %nobody makes an offer (end)
        conv=1;
    end  
end

end

