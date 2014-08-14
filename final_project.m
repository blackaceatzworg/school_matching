clear all;
clc;

%typedrop = 1 : random over all students
%typedrop = 2 : random over subset of students allocated to bad schools
typedrop = 2;

% classes of schools: GOOD(20%), MEDIUM(50%), BAD(30%)
good=0.2;
medium=0.5;
bad=0.3;

Nsim=100;      % # of runs

% Number of changes in the variable being studied (in this code: Ndp)
Ncases=9; 

% for example, if Ncases = 9 and we are studying the number of dropouts it
% will run for number of dropouts = 1, 2, 3,..., 9
% for each dropout case, it will run Nsim times 
% (to change the students that are dropping out) 

Cap=10;     % capacity of each school (NOT BEING USED)
Nst = 50;   % number of students
Nsc = 50;   % number of schools
Ndp = 20;    % number of dropouts

mean_std_result = zeros(Ncases,4);

% set seed of random number generator 
% (will always generate the same preferences)
%rng(10);    

% Generate preferences for of schools 
% ------------------------------------------------------------------------
% random sample of schools preferences 
% (rows: Schools;  columns: ranking of students for each school)
PrefSc = rand(Nsc, Nst); 
[Y,I]=sort(PrefSc,2);       % Sort preferences for each row
PrefSc=I;

tau_dist=zeros(Nsim,1);
changes=zeros(3,3);

for z=1:Ncases
    Ndp=z;      %new number of dropouts
    for k=1:Nsim
        % for each number of dropouts, simulate Nsim times 
        % (changing which students are dropping out and Preferences)
        
        PrefSt=GeneratePreferences(Nsc, Nst, good, medium, bad);
        
        % compute GS allocation
        [ matchst1, matchsc1 ] = DA_alg( PrefSt, Nst, PrefSc, Nsc );

        %---------------------------------------------------------------
        %Drop outs
        
        listdp=DropStudents(typedrop, Nst, Nsc, matchst1, Ndp, good, medium);

        PrefSt2 =PrefSt;
        j=1;
        for i=1:Ndp
            % students that drop are assigned preference 0 
            % (don't want any school)
            PrefSt2(listdp(i),:) = zeros(1,Nsc); 
        end

        %Students that drop are deleted from the ranking of the school
        PrefSc2 =PrefSc;
        for i=1:Nsc
            for j=1:Ndp
                iddp = find(PrefSc2(i,:)==listdp(j));
                if(iddp == 1)
                    PrefSc2(i,:) = [PrefSc2(i,2:Nst) 0];
                elseif (iddp < Nst)
                    PrefSc2(i,:) = [PrefSc2(i,1:(iddp-1)) ...
                        PrefSc2(i,(iddp+1):Nst) 0];
                else
                    PrefSc2(i,:) = [PrefSc2(i,1:(Nst-1)) 0 ];
                end
            end    
        end
        %----------------------------------------------------------------

        % compute new GS allocation after drop outs
        [ matchst2, matchsc2 ] = DA_alg( PrefSt2, Nst, PrefSc2, Nsc );

        % compare difference between both allocations
        matchsta=matchst1;
        matchstb=matchst2;
        %delete drop outs from list of students in first case
        matchsta(listdp)=[];    
        %delete drop outs from list of students in second case
        matchstb(listdp)=[];    
        l=length(matchsta);        
        %compute tau-dist (element wise differences in student allocation)
        tau_dist(k)=sum(matchsta~=matchstb);
        
        for i=1:l
            a=matchsta(i);
            b=matchstb(i);
            if (a~=b)
                if (a<=ceil(Nsc*good))
                   if(b<= ceil(Nsc*good))
                      changes(1,1)=changes(1,1)+1; 
                   elseif(b<= (ceil(Nsc*good)+ceil(Nsc*medium)))
                       changes(1,2)=changes(1,2)+1;
                   else
                       changes(1,3)=changes(1,3)+1;
                   end                    
                elseif (a<=(ceil(Nsc*good)+ceil(Nsc*medium)))
                   if(b<= ceil(Nsc*good))
                      changes(2,1)=changes(2,1)+1; 
                   elseif(b<= (ceil(Nsc*good)+ceil(Nsc*medium)))
                       changes(2,2)=changes(2,2)+1;
                   else
                       changes(2,3)=changes(2,3)+1;
                   end                    

                else
                   if(b<= ceil(Nsc*good))
                      changes(3,1)=changes(3,1)+1; 
                   elseif(b<= (ceil(Nsc*good)+ceil(Nsc*medium)))
                       changes(3,2)=changes(3,2)+1;
                   else
                       changes(3,3)=changes(3,3)+1;
                   end                         
                end 
            end     
        end
    end
    %for each number of dropouts, compute the average and standard
    %deviation
    
    avg_tau=mean(tau_dist);
    std_dev = std(tau_dist);
     
    mean_std_result(z,1) =avg_tau;
    mean_std_result(z,2) =std_dev;
    mean_std_result(z,3) =avg_tau-1.96*std_dev/sqrt(Nsim);
    mean_std_result(z,4) =avg_tau+1.96*std_dev/sqrt(Nsim);
end


%PLOT
if (typedrop ==1)
    filename = 'fig_1_randomdrop.jpeg';
    titulo = 'Students Drop Randomly ';
else
    filename = 'fig_1_badschooldrop.jpeg';
    titulo = {'Subset of students matched ' ; 'to bad schools drop '};    
end

hLine = plot(mean_std_result(:,1));
xlabel('Number of dropouts', 'FontSize',12,'FontWeight','bold');
ylabel('# of different matches', 'FontSize',12,'FontWeight','bold');
title(titulo,'FontSize',16,'FontWeight','bold')

hold on
AreaPlotConf=mean_std_result(:,3:4);
AreaPlotConf(:,2)=AreaPlotConf(:,2)-AreaPlotConf(:,1);
h = area(AreaPlotConf,'EdgeColor', 'none'); %
set(h(1),'FaceColor','none');
set(h(2),'FaceColor',[0.5 0.5 0.5]);
alpha(0.2);
grid on;

hold off

print('-djpeg', filename);