function egg_animation()

close all

%set the oval hyper-parameters
egg_params = struct();
egg_params.a = 3; egg_params.b = 2; egg_params.c = .15;

y_ground = 0;
x_wall = 30;

[t_ground,t_wall] = collision_func(@egg_trajectory01,egg_params,y_ground,x_wall);
t_collision = min(t_ground,t_wall);

%define location and filename where video will be stored
fname = 'egg_animation.avi';
input_fname = fname;

%create a videowriter, which will write frames to the animation file
writerObj = VideoWriter(input_fname);
writerObj.FrameRate = 30;
open(writerObj); %must call open before writing any frames

%initialize the current figure and save as object
fig1 = figure(1);

%set up the plotting axis
hold on; axis equal; axis square
axis([y_ground-1,x_wall+5,y_ground-1,x_wall])

plot([y_ground-1,x_wall+5],[y_ground,y_ground],'k','LineWidth',2);
plot([x_wall,x_wall],[y_ground,x_wall],'k','LineWidth',2);

%initialize the plot of the egg
egg_plot = plot(0,0,'k','LineWidth',2);
contact_plot = plot(NaN,NaN,'ro','markerfacecolor','r');

s_list = linspace(0,1,100);

%iterate through time
for t = 0:.03:t_collision

    [x0,y0,theta] = egg_trajectory01(t);

    %compute positions of egg perimeter
    [V_list,~] = egg_func(s_list,x0,y0,theta,egg_params);

    %update the coordinates of the egg plot
    set(egg_plot,'xdata',V_list(1,:),'ydata',V_list(2,:));

    %update the actual plotting window
    drawnow;

    %capture a frame (what is currently plotted)
    current_frame = getframe(fig1);

    %write the frame to the video
    writeVideo(writerObj,current_frame);

end

[x0,y0,theta] = egg_trajectory01(t_collision);
[V_list,~] = egg_func(s_list,x0,y0,theta,egg_params);

set(egg_plot,'xdata',V_list(1,:),'ydata',V_list(2,:));

if t_wall < t_ground
    [~,contact_index] = max(V_list(1,:));
    contact_x = x_wall;
    contact_y = V_list(2,contact_index);
else
    [~,contact_index] = min(V_list(2,:));
    contact_x = V_list(1,contact_index);
    contact_y = y_ground;
end

set(contact_plot,'xdata',contact_x,'ydata',contact_y);
drawnow;

for n = 1:60
    current_frame = getframe(fig1);
    writeVideo(writerObj,current_frame);
end

%must call close after all frames are written
close(writerObj);

end


%Example parabolic trajectory
function [x0,y0,theta] = egg_trajectory01(t)
x0 = 7*t + 8;
y0 = -6*t.^2 + 20*t + 6;
theta = 5*t;
end