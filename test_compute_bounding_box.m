function test_compute_bounding_box()
    %set the oval hyper-parameters
    egg_params = struct();
    egg_params.a = 3; egg_params.b = 2; egg_params.c = .15;
    %specify the position and orientation of the egg
    x0 = 0.5;
    y0 = -.7;
    theta = pi/6;
    [x_range,y_range] = compute_bounding_box(x0,y0,theta,egg_params);
    
end