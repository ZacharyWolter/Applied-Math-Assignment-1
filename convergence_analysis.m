function [p_measured, k_measured] = convergence_analysis(solver_flag, fun, ...
    x_guess0, guess_list1, guess_list2, filter_list)

    target_root = fzero(fun, x_guess0);

    dxtol = 1e-14;
    ftol = 1e-14;
    max_iter = 200;
    dxmax = 1e10;

    x_current_list = [];
    x_next_list = [];
    index_list = [];

    my_recorder = input_recorder();
    f_record = my_recorder.generate_recorder_fun(fun);

    for n = 1:length(guess_list1)
        if solver_flag == 1
            [x_root, exit_flag, guess] = bisection_solver(fun, guess_list1(n), ...
                guess_list2(n), dxtol, ftol, max_iter);

            if exit_flag == 1 && length(guess) >= 2
                x_current_list = [x_current_list, guess(1:end-1)];
                x_next_list = [x_next_list, guess(2:end)];
                index_list = [index_list, 1:length(guess)-1];
            end

        elseif solver_flag == 2
            [x_root, exit_flag, guess] = newton_solver(fun, guess_list1(n), ...
                dxtol, ftol, max_iter, dxmax);

            if exit_flag == 1
                guess = [guess, x_root];

                if length(guess) >= 2
                    x_current_list = [x_current_list, guess(1:end-1)];
                    x_next_list = [x_next_list, guess(2:end)];
                    index_list = [index_list, 1:length(guess)-1];
                end
            end

        elseif solver_flag == 3
            [x_root, exit_flag, guess] = secant_solver(fun, guess_list1(n), ...
                guess_list2(n), dxtol, ftol, max_iter, dxmax);

            if exit_flag == 1 && length(guess) >= 2
                x_current_list = [x_current_list, guess(1:end-1)];
                x_next_list = [x_next_list, guess(2:end)];
                index_list = [index_list, 1:length(guess)-1];
            end

        elseif solver_flag == 4
            my_recorder.clear_input_list();
            [x_root, fval, exit_flag] = fzero(f_record, guess_list1(n));
            input_list = my_recorder.get_input_list();

            if exit_flag > 0 && length(input_list) >= 2
                x_current_list = [x_current_list, input_list(1:end-1)];
                x_next_list = [x_next_list, input_list(2:end)];
                index_list = [index_list, 1:length(input_list)-1];
            end
        end
    end

    e_n = abs(x_current_list - target_root);
    e_n_1 = abs(x_next_list - target_root);

    filter_mask = (e_n > filter_list(1)) & ...
        (e_n < filter_list(2)) & ...
        (e_n_1 > filter_list(3)) & ...
        (e_n_1 < filter_list(4)) & ...
        (index_list > filter_list(5));

    e_n_filt = e_n(filter_mask);
    e_n_1_filt = e_n_1(filter_mask);

    [p_measured, k_measured] = generate_error_fit(e_n_filt, e_n_1_filt);

    fprintf('Measured Order of Convergence (p): %.4f\n', p_measured);
    fprintf('Measured Error Constant (k): %.4f\n', k_measured);

    if solver_flag == 1
        solver_name = 'Bisection Method';
    elseif solver_flag == 2
        solver_name = 'Newton''s Method';
    elseif solver_flag == 3
        solver_name = 'Secant Method';
    elseif solver_flag == 4
        solver_name = 'fzero';
    end

    figure;
    loglog(e_n, e_n_1, 'r.', 'MarkerSize', 4); hold on;
    loglog(e_n_filt, e_n_1_filt, 'b.', 'MarkerSize', 4);

    fit_x = 10.^linspace(-14, -2, 100);
    fit_y = k_measured * fit_x.^p_measured;
    loglog(fit_x, fit_y, 'k-', 'LineWidth', 2);

    xlabel('\epsilon_n (-)');
    ylabel('\epsilon_{n+1} (-)');
    title(sprintf('%s (p = %.2f, k = %.2f)', ...
        solver_name, p_measured, k_measured));
    legend('Raw Data', 'Filtered Data', 'Fit Line', ...
        'Location', 'northwest');
    xlim([10e-18, 10e2]);
    ylim([10e-18, 10e2]);
    grid on;
end

function [p, k] = generate_error_fit(x_regression, y_regression)
    Y = log(y_regression)';
    X1 = log(x_regression)';
    X2 = ones(length(X1), 1);

    coeff_vec = regress(Y, [X1, X2]);

    p = coeff_vec(1);
    k = exp(coeff_vec(2));
end