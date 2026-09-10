function convergence_experiment_template_generalized()
    num_iter = 500;
    x_guess0 = 0.5;

    target_root = fzero(@test_func01, x_guess0);

    bisection_left = linspace(target_root-1.5, target_root-0.05, num_iter);
    bisection_right = linspace(target_root+0.05, target_root+1.5, num_iter);

    newton_guesses = linspace(x_guess0-1.5, x_guess0+1.5, num_iter);

    secant_guess1 = linspace(x_guess0-1.5, x_guess0+1.5, num_iter);
    secant_guess2 = secant_guess1 + 0.1;

    fzero_guesses = linspace(x_guess0-1.5, x_guess0+1.5, num_iter);

    bisection_filter = [1e-15, 1e-2, 1e-14, 1e-2, 2];
    newton_filter = [1e-15, 1e-2, 1e-14, 1e-2, 2];
    secant_filter = [1e-15, 1e-2, 1e-14, 1e-2, 3];
    fzero_filter = [1e-15, 1e-2, 1e-14, 1e-2, 2];

    [p_bisection, k_bisection] = convergence_analysis(1, @test_func01, ...
        x_guess0, bisection_left, bisection_right, bisection_filter);

    [p_newton, k_newton] = convergence_analysis(2, @test_func01, ...
        x_guess0, newton_guesses, 0, newton_filter);

    [p_secant, k_secant] = convergence_analysis(3, @test_func01, ...
        x_guess0, secant_guess1, secant_guess2, secant_filter);

    [p_fzero, k_fzero] = convergence_analysis(4, @test_func01, ...
        x_guess0, fzero_guesses, 0, fzero_filter);

    fprintf('\n');
    fprintf('Bisection: p = %.4f, k = %.4f\n', p_bisection, k_bisection);
    fprintf('Newton:    p = %.4f, k = %.4f\n', p_newton, k_newton);
    fprintf('Secant:    p = %.4f, k = %.4f\n', p_secant, k_secant);
    fprintf('fzero:     p = %.4f, k = %.4f\n', p_fzero, k_fzero);
end

function [fval, dfdx] = test_func01(x)
    fval = (x.^3)/100 - (x.^2)/8 + 2*x + 6*sin(x/2+6) - 0.7 - exp(x/6);
    dfdx = 3*(x.^2)/100 - 2*x/8 + 2 + (6/2)*cos(x/2+6) - exp(x/6)/6;
end