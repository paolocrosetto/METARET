function plot_Figure_I
%%%%%%Note: this program produces Figure I in Frydman and Jin (2021)

%%%%%%%%%%%%%%%%%%%%%%%%%%parameter values%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n = 10;     %capacity constraint parameter
x_u_h = 32; %upper bound of X  (high vol condition)
x_l_h = 8;  %lower bound of X  (high vol condition)
x_u_l = 24; %upper bound of X  (low vol condition)
x_l_l = 16; %lower bound of X  (low vol condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%vectors to plot%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 200;
X_vec_h = zeros(1,N); %vector of X (high vol condition)
X_vec_l = zeros(1,N); %vector of X (low vol condition)
pdf_vec_h = zeros(1,N);  %vector of pdf (high vol condition)
pdf_vec_ll = zeros(1,N); %vector of pdf (low vol condition; low vol range)
coding_func_h = zeros(1,N); %vector of coding function (high vol condition)
coding_func_l = zeros(1,N); %vector of coding function (low vol condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:N
    X_vec_h(i) = x_l_h + (i-1)/N*(x_u_h - x_l_h);
    X_vec_l(i) = x_l_l + (i-1)/N*(x_u_l - x_l_l);
    pdf_vec_h(i) = 1/(x_u_h - x_l_h);
    if (X_vec_h(i) <= x_u_l && X_vec_h(i) >= x_l_l)
        pdf_vec_ll(i) = 1/(x_u_l - x_l_l);
    end
    coding_func_h(i) = (sin(pi./2*(X_vec_h(i) - x_l_h)./(x_u_h - x_l_h))).^2;
    coding_func_l(i) = (sin(pi./2*(X_vec_l(i) - x_l_l)./(x_u_l - x_l_l))).^2;     
end

%%%%%%%%%%%%%%evaluate likelihood functions at X = 22 or X = 18%%%%%%%%%%%%
X_h = 22;
X_l = 18;

cdf_h_h = (X_h - x_l_h)/(x_u_h - x_l_h); %cdf evaluated at X = 22 (high vol)
cdf_l_h = (X_l - x_l_h)/(x_u_h - x_l_h); %cdf evaluated at X = 18 (high vol)
cdf_h_l = (X_h - x_l_l)/(x_u_l - x_l_l); %cdf evaluated at X = 22 (low vol)
cdf_l_l = (X_l - x_l_l)/(x_u_l - x_l_l); %cdf evaluated at X = 18 (low vol)

theta_h_h = (sin(pi/2.*cdf_h_h))^2; %coding function evaluated at X = 22 (high vol)     
theta_l_h = (sin(pi/2.*cdf_l_h))^2; %coding function evaluated at X = 18 (high vol)      
theta_h_l = (sin(pi/2.*cdf_h_l))^2; %coding function evaluated at X = 22 (low vol)      
theta_l_l = (sin(pi/2.*cdf_l_l))^2; %coding function evaluated at X = 18 (low vol) 

%%%%%%construct a vector of R_x%%%%%%
R_x = zeros(1,n+1);
for i = 1:n+1
   R_x(i) = i-1; 
end

likelihood_h_h = binopdf(R_x,n,theta_h_h); %likelihood evaluated at X = 22 (high vol)
likelihood_l_h = binopdf(R_x,n,theta_l_h); %likelihood evaluated at X = 18 (high vol)
likelihood_h_l = binopdf(R_x,n,theta_h_l); %likelihood evaluated at X = 22 (low vol)
likelihood_l_l = binopdf(R_x,n,theta_l_l); %likelihood evaluated at X = 18 (low vol)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Panel A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(gcf,'color','w');
set(0,'defaultTextInterpreter','latex');
set(gca,'FontName','Times New Roman');

subplot(3,1,1)
set(gca,'FontSize',16);
h1 = plot(X_vec_h,pdf_vec_ll,'r');
hold on;
h2 = plot(X_vec_h,pdf_vec_h,'b--');
set(gca,'FontSize',16);

h = legend([h1 h2],{'Low vol','High vol'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
title('$\bf{Panel\hspace{0.05in}A}$','Interpreter','Latex','FontSize', 16)
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l_h,x_u_h])
ylim([0.02,0.2])
ylabel('$f(X)$','Interpreter','Latex','FontSize', 16)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Panel B%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,2)
set(gca,'FontSize',16);
h1 = plot(X_vec_l,coding_func_l,'r');
hold on;
h2 = plot(X_vec_h,coding_func_h,'b--');
set(gca,'FontSize',16);

h = legend([h1 h2],{'Low vol','High vol'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'northwest')
title('$\bf{Panel\hspace{0.05in}B}$','Interpreter','Latex','FontSize', 16)
xlabel('$X$','Interpreter','Latex','FontSize', 16)
xlim([x_l_h,x_u_h])
ylabel('$\theta(X)$','Interpreter','Latex','FontSize', 16)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Panel C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,3)
set(gca,'FontSize',16);
h1 = plot(R_x,likelihood_l_l,':rs');
hold on;
h2 = plot(R_x,likelihood_h_l,'-ro');
h3 = plot(R_x,likelihood_l_h,':bs','MarkerSize',6,'MarkerEdgeColor','blue','MarkerFaceColor',[0 .0 1]);
h4 = plot(R_x,likelihood_h_h,'-bo','MarkerSize',6,'MarkerEdgeColor','blue','MarkerFaceColor',[0 .0 1]);

set(gca,'FontSize',16);
h = legend([h1 h2 h3 h4],{'Low vol, $X = 18$','Low vol, $X = 22$', 'High vol, $X = 18$', 'High vol $X = 22$'});
set(h,'Interpreter','Latex','FontSize', 14, 'Location', 'north')
title('$\bf{Panel\hspace{0.05in}C}$','Interpreter','Latex','FontSize', 16)
xlabel('$R_x$','Interpreter','Latex','FontSize', 16)
ylim([0,0.5])
ylabel('$f(R_x|X)$','Interpreter','Latex','FontSize', 16)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

