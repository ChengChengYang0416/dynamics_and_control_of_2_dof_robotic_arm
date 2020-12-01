% This a simulation for 2 dof robot arm. The dynamics of robot is described
% in this simulation and the controller is implemented.

close all;
init();

% simulation time
delta_t = 0.001;
sim_t = 50;
t = 0:delta_t:sim_t;

% initialize the state variables of the robot arm
x = zeros(2, length(t));
theta = zeros(2, length(t)+1);
theta_dot = zeros(2, length(t)+1);
theta_ddot = zeros(2, length(t));
tau = zeros(2, length(t));
theta_degree = zeros(2, length(t)+1);
theta_error_now = zeros(2, 1);
theta_error_accu = zeros(2, 1);

% initialize the parameters of the dynamics
inertia = zeros(2, 2);
cen_cor = zeros(2, 1);
gravity = zeros(2, 1);

% simulation start
for i = 1:length(t)
    
    % inertia matrix
    inertia = [(arm1.m+arm2.m)*arm1.l^2+arm2.m*arm2.l^2+2*arm2.m*arm1.l*arm2.l*cos(theta(2, i)) arm2.m*arm2.l^2+arm2.m*arm1.l*arm2.l*cos(theta(2, i));
                arm2.m*arm2.l^2+arm2.m*arm1.l*arm2.l*cos(theta(2, i))                           arm2.m*arm2.l^2];
            
    % centrifugal force and Coriolis force
    cen_cor = [-2*arm2.m*arm1.l*arm2.l*sin(theta(2, i))*theta_dot(1, i)*theta_dot(2, i)-arm2.m*arm1.l*arm2.l*sin(theta(2, i))*theta_dot(2, i)^2;
                arm2.m*arm1.l*arm2.l*sin(theta(2, i))*theta(1, i)^2];
            
    % gravity force
    gravity = [(arm1.m+arm2.m)*g*arm1.l*arm1.l*cos(theta(1, i))+arm2.m*g*arm2.l*cos(theta(1, i)+theta(2, i));
                arm2.m*arm2.l*g*cos(theta(1, i)+theta(2, i))];
            
    % controller : PID control
    desired_theta = [-(1/3)*pi; (1/3)*pi];
    desired_theta_dot = [0; 0];
    
    % angle error and integral of angle error
    theta_error_now = desired_theta - theta(:, i);
    theta_error_dot_now = desired_theta_dot - theta_dot(:, i);
    theta_error_accu = theta_error_accu + theta_error_now;
    theta_error_accu(1) = error_bound(theta_error_accu(1));
    theta_error_accu(2) = error_bound(theta_error_accu(2));
    
    % control input
    tau(1, i) = pid1.p*(theta_error_now(1)) ...
                + pid1.d*(theta_error_dot_now(1)) ...
                + pid1.i*theta_error_accu(1) ...
                + gravity(1);
    tau(2, i) = pid2.p*(theta_error_now(2)) ...
                + pid2.d*(theta_error_dot_now(2)) ...
                + pid2.i*theta_error_accu(2) ...
                + gravity(2);
    
    % angular acceleration
    theta_ddot(:, i) = inertia\(tau(:, i) - cen_cor - gravity);
    
    % angular velocity (numerical integration)
    theta_dot(:, i+1) = theta_dot(:, i) + theta_ddot(:, i)*delta_t;
    
    % angle (numerical integration)
    theta(:, i+1) = theta(:, i) + theta_dot(:, i)*delta_t;
    theta_degree(1, i+1) = rad2deg(theta(1, i+1));
    theta_degree(2, i+1) = rad2deg(theta(2, i+1));
end

% plot the theta1 , theta2, and control input
plotter(t, theta_degree, tau);