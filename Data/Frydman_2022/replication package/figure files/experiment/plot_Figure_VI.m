%plots time series of average response time (RT), depending on order of risky choice conditions

clear

%load dataset
load mastermatrix
%"mastermatrix" is a 90,0000 x 10 matrix 

    %Column 1: X
    %Column 2: C
    %Column 3: risky on left = 1, 0 if on right
    %Column 4: risky choice = 1 if choose risky lottery, 0 otherwise
    %Column 5: response time (seconds)
    %Column 6: trial (1-600)
    %Column 7: SubjectID (1-150)
    %Column 8: High condition first=1, 0 otherwise 
    %Column 9: High condition=1, low condition=0
    %Column 10: Test trial = 1, adapt trial =0

    
%create time series of RT for those subjects who go from high to low vol
%condition

%t indexes trial=1 to 600
for t=1:1:600
    count=0;
    summer=0;
    
    for i=1:1:90000
        if mastermatrix(i,8)==1
            if mastermatrix(i,6)==t
                if mastermatrix(i,5)>.5
                    if mastermatrix(i,7)~=148
                        count=count+1;
                        summer=summer+mastermatrix(i,5);
                    end
                end
            end
        end
    end

%trial number   
hightolowRT(t,1)=t;

%average RT for trial t
hightolowRT(t,2)=summer/count;
end


%create time series of RT for those subjects who go from low to high vol
%condition

%t indexes trial=1 to 600
for t=1:1:600
    count=0;
    summer=0;
    
    for i=1:1:90000
        if mastermatrix(i,8)==0
            if mastermatrix(i,6)==t
                if mastermatrix(i,5)>.5
                    if mastermatrix(i,7)~=148
                        count=count+1;
                        summer=summer+mastermatrix(i,5);
                    end
                end
            end
        end
    end
    
%trial number
lowtohighRT(t,1)=t;

%average RT for trial t
lowtohighRT(t,2)=summer/count;
end
                
                    
%plot the two time series

set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

subplot(2,1,1);

scatter(1:1:600, lowtohighRT(:,2),'filled')
set(gca,'FontSize',16);
hold

title('Low to high volatility','FontSize',16)
ylabel('Average response time (seconds)','Interpreter','Latex','FontSize', 16)
xlabel('Trial number','Interpreter','Latex','FontSize', 16)
line([300 300], [0, 5],'color','red','LineWidth',2);
ylim([1 4])


subplot(2,1,2);
scatter(1:1:600, hightolowRT(:,2),'filled')
set(gca,'FontSize',16);
hold

title('High to low volatility','FontSize',16)
ylabel('Average response time (seconds)','Interpreter','Latex','FontSize', 16)
xlabel('Trial number','Interpreter','Latex','FontSize', 16)
line([300 300], [0, 5],'color','red','LineWidth',2);
ylim([1 4])
hold
