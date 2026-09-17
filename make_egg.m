function make_egg()
    close all

    %set the oval hyper-parameters
    egg_params = struct();
    egg_params.a = 3; egg_params.b = 2; egg_params.c = .15;

    %specify the position and orientation of the egg
    x0 = 5; y0 = 5; theta = pi/6;

    %set up the axis
    hold on; axis equal; axis square
    axis([0,10,0,10])

    %plot the origin of the egg frame
    plot(x0,y0,'ro','markerfacecolor','r');

    %compute the perimeter of the egg
    [V_list, ~] = egg_func(linspace(0,1,100),x0,y0,theta,egg_params);
    [x_range,y_range] = compute_bounding_box(x0,y0,theta,egg_params);

    %plot the perimeter of the egg
    plot(V_list(1,:),V_list(2,:),'k');

    xmin = x_range(1); xmax = x_range(2);
    ymin = y_range(1); ymax = y_range(2);

    x_coords = [xmin,xmax,xmax,xmin,xmin];
    y_coords = [ymin,ymin,ymax,ymax,ymin];

    plot(x_coords, y_coords)
end