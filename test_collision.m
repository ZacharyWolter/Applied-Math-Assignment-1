function test_collision()
    y_ground = 0;
    x_wall = 30;

    egg_params = struct();
    egg_params.a = 3; 
    egg_params.b = 2; 
    egg_params.c = .15;

    [t_ground, t_wall] = collision_func(@egg_trajectory01, egg_params, y_ground, x_wall);
    
end


function [x0, y0, theta] = egg_trajectory01(t)
    x0 = 7*t + 8;
    y0 = -6*t.^2 + 20*t + 6;
    theta = 5*t;
end