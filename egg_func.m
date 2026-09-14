%This function generates the parametric curve describing an oval
%INPUTS:
%s: the curve parametr. s is a number from 0 to 1. The curve function has a
% period of 1, so s=.3 and s=1.3 will generate the same output
% s can also be a list (row vector) of numbers
%theta: rotation of the oval. theta is a number from 0 to 2*pi.
% Increasing theta rotates the oval counterclockwise
%x0: horizontal offset of the oval
%y0: vertical offset of the oval
%egg_params: a struct describing the hyperparameters of the oval
% egg_params has three variables, a,b, and c
% without any rotation/translation, the oval satisfies the equation:
% xˆ2/aˆ2 + (yˆ2/bˆ2)*eˆ(c*x) = 1
% tweaking a,b,c changes the shape of the oval
%OUTPUTS:
%V: the position of the point on the oval given the inputs
% If s is a single number, then V will have the form of a column vector
% [x_out;y_out] where (x_out,y_out) are the coordinates of the point on
% the oval. If the input t is a list of numbers (a row vector) i.e.:
% s = [s_1,...,s_N]
% then V will be an 2xN matrix:
% [x_1,...,x_N; y_1,...,y_N]
% where (x_i,y_i) correspond to input s_i
%G: the gradient of V taken with respect to s
% If s is a single number, then G will be the column vector [dx/ds; dy/ds]
% If s is the list [s_1,...,s_N], then G will be the 2xN matrix:
% [dx_1/ds_1,...,dx_N/ds_N; dy_1/ds_1,...,dy_N/ds_N]
function [V, G] = egg_func(s,x0,y0,theta,egg_params)
%unpack the struct
a=egg_params.a;
b=egg_params.b;
c=egg_params.c;
%compute x (without rotation or translation)
x = a*cos(2*pi*s);
%useful intermediate variable
f = exp(-c*x/2);
%compute y (without rotation or translation)
y = b*sin(2*pi*s).*f;
%compute the derivatives of x and y (without rotation or translation)
dx = -2*pi*a*sin(2*pi*s);
df = (-c/2)*f.*dx;
dy = 2*pi*b*cos(2*pi*s).*f + b*sin(2*pi*s).*df;
%rotation matrix corresponding to theta
R = [cos(theta),-sin(theta);sin(theta),cos(theta)];
%compute position and gradient for rotated + translated oval
V = R*[x;y]+[x0*ones(1,length(theta));y0*ones(1,length(theta))];
G = R*[dx;dy];
end
