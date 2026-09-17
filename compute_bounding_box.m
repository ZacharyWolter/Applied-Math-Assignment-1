%Function that computes the bounding box of an oval
%INPUTS:
%theta: rotation of the oval. theta is a number from 0 to 2*pi.
%x0: horizontal offset of the oval
%y0: vertical offset of the oval
%egg_params: a struct describing the hyperparameters of the oval
%OUTPUTS:
%x_range: the x limits of the bounding box in the form [x_min,x_max]
%y_range: the y limits of the bounding box in the form [y_min,y_max]
function [x_range,y_range] = compute_bounding_box(x0,y0,theta,egg_params)
    
    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;

    Vx_list = [];
    Vy_list = [];

    %wrapper function that calls egg_wrapper1
    %but only takes s as an input (other inputs are fixed)
    %(single input)
    xegg_wrapper2 = @(s) xegg_wrapper1(s,x0,y0,theta,egg_params);
    yegg_wrapper2 = @(s) yegg_wrapper1(s,x0,y0,theta,egg_params);
        
    for s_guess0 = [0,1/4,1/2,3/4]
        %compute the value of s for which the corresponding point on the oval
        %has an x-coordinate of zero
        
        [sx_root, ~, ~] = secant_solver(xegg_wrapper2,s_guess0,s_guess0+.001, dxtol ,ftol, max_iter, dxmax);
        [sy_root, ~, ~] = secant_solver(yegg_wrapper2,s_guess0,s_guess0+.001, dxtol ,ftol, max_iter, dxmax);

        [V, ~] = egg_func(sx_root, x0,y0,theta,egg_params);
        Vx_list(end+1) = V(1);

        [V, ~] = egg_func(sy_root, x0,y0,theta,egg_params);
        Vy_list(end+1) = V(2);

    end 
    
    x_range = [min(Vx_list), max(Vx_list)];
    y_range = [min(Vy_list), max(Vy_list)];
    
end


function x_out = xegg_wrapper1(s,x0,y0,theta,egg_params)
    [~, G] = egg_func(s,x0,y0,theta,egg_params);
    x_out = G(1);
end

function y_out = yegg_wrapper1(s,x0,y0,theta,egg_params)
    [~, G] = egg_func(s,x0,y0,theta,egg_params);
    y_out = G(2);
end
