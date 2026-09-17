%Function that computes the collision time for a thrown egg
%INPUTS:
%traj_fun: a function that describes the [x,y,theta] trajectory
% of the egg (takes time t as input)
%egg_params: a struct describing the hyperparameters of the oval
%y_ground: height of the ground
%x_wall: position of the wall
%OUTPUTS:
%t_ground: time that the egg would hit the ground
%t_wall: time that the egg would hit the wall
function [t_ground,t_wall] = collision_func(traj_fun, egg_params, y_ground, x_wall)
    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;

    ground_fun = @(t) ground_wrapper(t, traj_fun, egg_params, y_ground);
    wall_fun = @(t) wall_wrapper(t, traj_fun, egg_params, x_wall);
    
    t_ground_brackets = [0, 5]; 
    t_wall_brackets = [0, 5];
    
    [t_ground, ~, ~] = bisection_solver(ground_fun, t_ground_brackets(1), t_ground_brackets(2), dxtol, ftol, max_iter);
    [t_wall, ~, ~] = bisection_solver(wall_fun, t_wall_brackets(1), t_wall_brackets(2), dxtol, ftol, max_iter);
end

function val = ground_wrapper(t, traj_fun, egg_params, y_ground)
    [x0, y0, theta] = traj_fun(t);
    [~, y_range] = compute_bounding_box(x0, y0, theta, egg_params);
    val = y_range(1) - y_ground;
end

function val = wall_wrapper(t, traj_fun, egg_params, x_wall)
    [x0, y0, theta] = traj_fun(t);
    [x_range, ~] = compute_bounding_box(x0, y0, theta, egg_params);
    val = x_range(2) - x_wall;
end