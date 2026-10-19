clear
tic
rng(42);

%% Import data
M = tdfread('data_anon.csv',',');
id = M.x0x22userid0x22;

safe_choice = 1 - M.x0x22pickedRisky0x22;
% age = M.cage;
cAge = string(M.x0x22cAge0x22);
gr25 = cAge ~= '"16-25"';

sex = string(M.x0x22sex0x22);
nonmale = sex ~= '"Male"      ';

nonger = 1 - M.x0x22germany0x22;

wealth = M.x0x22goldBefore0x22/1000;
wealthflag = wealth > 6;

dt = M.x0x22decisionTime0x22;
tbroad = dt<3.5;

riskyleft = M.x0x22riskyLeft0x22;

risky_success = M.x0x22riskySuccess0x22;
rs_alt = risky_success(:,1);
rs = NaN(length(id),1);
for i = 1:length(rs_alt)
    aux = (rs_alt(i)=="N")*0 + (rs_alt(i)=="0")*0 + (rs_alt(i)=="1")*1;
    rs(i) = aux;
end

unique_ids = unique(id);
risky_exp = NaN(length(id),1);
picked_risky = 1-safe_choice;
for i = 1:length(unique_ids)
    id_here = unique_ids(i);
    pr_here = picked_risky(id==id_here);
    rs_here = rs(id==id_here);
    aux = NaN(sum(id==id_here),1);
    aux(1) = 0.5;
    for ii = 2:length(aux)
        aux(ii) = sum(rs_here(1:ii-1))/sum(pr_here(1:ii-1));
    end
    aux(isnan(aux))=0;
    risky_exp(id==id_here) = aux;
end    

%risky_exp = rand(length(dt),1); %M.x0x22risky_exp0x22;

thresh = M.x0x22threshold0x22;

lotType = string(M.x0x22lotType0x22);
Abs = lotType == '"Absolute Lotteries"';

R_A = [0.008644411; 0.007692219; 0.006769781; 0.005872595; 0.004996632;...
    0.004138245; 0.00329409; 0.002461057; 0.001636218; 0.000816771; 0;...
    -0.000816771; -0.001636218; -0.002461057; -0.00329409; -0.004138245];
R_R = [9.239990007; 8.230655327; 7.25094471; 6.29620783; 5.362268588; ...
    4.445328957; 3.541889037; 2.648679276; 1.762601705; 0.88067767; 0;...
    -0.882312188; -1.769157642; -2.66349763; -3.56840268; -4.487103079];

lotname = M.x0x22lotName0x22;
lotfe = zeros(length(lotname),1);
for i = 1:length(lotfe)
    if lotname(i,9) == '"' 
        lotfe(i) = string(lotname(i,7:8));
    else
        lotfe(i) = string(lotname(i,7));
    end
end

R_A_choice = NaN(length(lotfe),1);
R_R_choice = NaN(length(lotfe),1);

for i = 1:length(lotfe)
    if Abs(i) == 1
        R_A_choice(i) = R_A(16-lotfe(i));
    elseif Abs(i) == 0
        R_R_choice(i) = R_R(16-lotfe(i));
    end
end

options = optimset('MaxFunEvals',5e4,'MaxIter',5e4);
bootstrap_n = 1000;

% abs_index = logical((1-isnan(R_A_choice)).*(1-wealthflag==1).*(1-tbroad==1));
abs_index = logical((1-isnan(R_A_choice)).*(1-wealthflag==1));
wealth_here = wealth(abs_index);
R_A_here = R_A_choice(abs_index);
% Normalize into [-1.96, 1.96]
aux = (R_A_here - min(R_A_here))./(max(R_A_here) - min(R_A_here));
R_A_here = aux.*3.92 - 1.96;
id_here = id(abs_index);
uniq_id_here = unique(id_here);
safe_choice_here = safe_choice(abs_index);
tbroad_here = tbroad(abs_index);
rl_here = riskyleft(abs_index);
re_here = risky_exp(abs_index);
thresh2_here = thresh(abs_index);
gr25_here = gr25(abs_index);
nonmale_here = nonmale(abs_index);
nonger_here = nonger(abs_index);
data = [wealth_here, R_A_here, tbroad_here, rl_here, re_here, thresh2_here,...
    gr25_here, nonmale_here, nonger_here, safe_choice_here];

my_fun = @(x) abs_dec_v2(x(1),x(2),x(3:9),1,data(:,1),data(:,2),...
    data(:,3:9),data(:,10));
x0 = [0,0,2,0,0,0,0,0,0];
[x_all_abs,~,exits_abs_all] = fminsearch(my_fun,x0,options);

boostrap_x_abs = NaN(bootstrap_n,9);
exits_abs = NaN(bootstrap_n,1);
for i = 1:bootstrap_n
    boot_id = datasample(uniq_id_here,length(uniq_id_here));
    boot_data = [];
    for j = 1:length(uniq_id_here)
        boot_data = [boot_data; data(id_here==boot_id(j),:)];
    end    
    my_fun = @(x) abs_dec_v2(x(1),x(2),x(3:9),1,boot_data(:,1),boot_data(:,2),...
        boot_data(:,3:9),boot_data(:,10));
    x0 = x_all_abs;
    [boostrap_x_abs(i,1:9),~,exits_abs(i)] = fminsearch(my_fun,x0,options);
end

my_fun = @(x) abs_dec_v4(x(1),x(2),x(3:9),x(10:12),1,data(:,1),data(:,2),...
    data(:,3:9),data(:,10));
x0 = [0,0,2,0,0,0,0,0,0,0,0,0];
[x_all_abs_inter,~,exits_abs_all_inter] = fminsearch(my_fun,x0,options);

boostrap_x_abs_inter = NaN(bootstrap_n,12);
exits_abs_inter = NaN(bootstrap_n,1);
for i = 1:bootstrap_n
    boot_id = datasample(uniq_id_here,length(uniq_id_here));
    boot_data = [];
    for j = 1:length(uniq_id_here)
        boot_data = [boot_data; data(id_here==boot_id(j),:)];
    end    
    my_fun = @(x) abs_dec_v4(x(1),x(2),x(3:9),x(10:12),1,boot_data(:,1),...
        boot_data(:,2),boot_data(:,3:9),boot_data(:,10));
    x0 = x_all_abs_inter;
    [boostrap_x_abs_inter(i,1:12),~,exits_abs_inter(i)] = fminsearch(my_fun,x0,options);
end
% generates a histogram
g = figure;
[j,out] = hist(boostrap_x_abs_inter(:,2),30);
j=j/bootstrap_n;
bar(out,j,1),
grid on;
colormap([0.5 0.5 0.5]);
% xlim([5 15]);
% ylim([0 0.3]);
set(gca,'FontSize',14);

rel_index = logical((1-isnan(R_R_choice)).*(1-wealthflag==1));
wealth_here = wealth(rel_index);
R_R_here = R_R_choice(rel_index);
% Normalize into [-1.96, 1.96]
aux = (R_R_here - min(R_R_here))./(max(R_R_here) - min(R_R_here));
R_R_here = aux.*3.92 - 1.96;
id_here = id(rel_index);
uniq_id_here = unique(id_here);
safe_choice_here = safe_choice(rel_index);
tbroad_here = tbroad(rel_index);
rl_here = riskyleft(rel_index);
re_here = risky_exp(rel_index);
thresh2_here = thresh(rel_index);
gr25_here = gr25(rel_index);
nonmale_here = nonmale(rel_index);
nonger_here = nonger(rel_index);
data = [wealth_here, R_R_here, tbroad_here, rl_here, re_here, thresh2_here,...
    gr25_here, nonmale_here, nonger_here, safe_choice_here];

my_fun = @(x) abs_dec_v2(x(1),x(2),x(3:9),1,data(:,1),data(:,2),...
    data(:,3:9),data(:,10));
x0 = [0,0,2,0,0,0,0,0,0];
[x_all_rel,~,exits_rel_all] = fminsearch(my_fun,x0,options);

boostrap_x_rel = NaN(bootstrap_n,9);
exits_rel = NaN(bootstrap_n,1);
for i = 1:bootstrap_n
    boot_data = datasample(data,length(data));
    my_fun = @(x) abs_dec_v2(x(1),x(2),x(3:9),1,boot_data(:,1),boot_data(:,2),...
        boot_data(:,3:9),boot_data(:,10));
    x0 = x_all_rel;
    [boostrap_x_rel(i,1:9),~,exits_rel(i)] = fminsearch(my_fun,x0,options);
end

my_fun = @(x) abs_dec_v4(x(1),x(2),x(3:9),x(10:12),1,data(:,1),data(:,2),...
    data(:,3:9),data(:,10));
x0 = [0,0,2,0,0,0,0,0,0,0,0,0];
[x_all_rel_inter,~,exits_rel_all_inter] = fminsearch(my_fun,x0,options);

boostrap_x_rel_inter = NaN(bootstrap_n,12);
exits_rel_inter = NaN(bootstrap_n,1);
for i = 1:bootstrap_n
    boot_id = datasample(uniq_id_here,length(uniq_id_here));
    boot_data = [];
    for j = 1:length(uniq_id_here)
        boot_data = [boot_data; data(id_here==boot_id(j),:)];
    end 
    my_fun = @(x) abs_dec_v4(x(1),x(2),x(3:9),x(10:12),1,boot_data(:,1),boot_data(:,2),...
        boot_data(:,3:9),boot_data(:,10));
    x0 = x_all_rel_inter;
    [boostrap_x_rel_inter(i,1:12),~,exits_rel_inter(i)] = fminsearch(my_fun,x0,options);
end

% Checks whether everything converged
mean([exits_abs_inter, exits_rel_inter])

VarNames = {'Constant','Wealth (in 1000s)','Dec. Time <3.5s','Safe on Right','Lottery Expectations',...
    'Threshold','Age >25','Not Male','Not German'};
Coeffs_Abs = [x_all_abs;std(boostrap_x_abs(:,1:9));x_all_abs./std(boostrap_x_abs(:,1:9))];
T_C_abs = array2table(Coeffs_Abs,'VariableNames',VarNames(1:9));
writetable(T_C_abs,'TableA3.xlsx','Sheet','Column (1)');
Coeffs_Rel = [x_all_rel;std(boostrap_x_rel(:,1:9));x_all_rel./std(boostrap_x_rel(:,1:9))];
T_C_rel = array2table(Coeffs_Rel,'VariableNames',VarNames(1:9));
writetable(T_C_rel,'TableA3.xlsx','Sheet','Column (3)');


VarNames = {'Constant','Wealth (in 1000s)','Dec. Time <3.5s','Safe on Right','Lottery Expectations',...
    'Threshold','Age >25','Not Male','Not German',...
    'Age >25 x Wealt (in 1000s)','Not Male x Wealt (in 1000s)','Not German x Wealt (in 1000s)'};
Coeffs_Abs = [x_all_abs_inter;std(boostrap_x_abs_inter(:,1:12));x_all_abs_inter./std(boostrap_x_abs_inter(:,1:12))];
T_C_abs = array2table(Coeffs_Abs,'VariableNames',VarNames(1:12));
writetable(T_C_abs,'TableA3.xlsx','Sheet','Column (2)');
Coeffs_Rel = [x_all_rel_inter;std(boostrap_x_rel_inter(:,1:12));x_all_rel_inter./std(boostrap_x_rel_inter(:,1:12))];
T_C_rel = array2table(Coeffs_Rel,'VariableNames',VarNames(1:12));
writetable(T_C_rel,'TableA3.xlsx','Sheet','Column (4)');

toc