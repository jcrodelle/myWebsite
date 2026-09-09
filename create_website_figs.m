%% Global Color Palette
colorBlue   = [14, 165, 233] / 255;  % Vibrant Cyan/Blue (#0ea5e9)
colorRose   = [244, 63, 94]  / 255;  % Vibrant Rose/Red (#f43f5e)
colorAmber  = [245, 158, 11] / 255;  % Warm Amber (#f59e0b)
colorPurple = [139, 92, 246] / 255;  % Deep Purple (#8b5cf6)
colorGrid   = [203, 213, 225] / 255;  % Slate Gray (#cbd5e1)

%% 1. Synaptic Plasticity (STDP Curve with Shaded Fills)
fig1 = figure('Position', [100, 100, 480, 260], 'Color', 'w');
ax1 = axes('Parent', fig1);

dt_pos = linspace(0.5, 40, 200);
dt_neg = linspace(-40, -0.5, 200);
w_pos  = exp(-dt_pos / 12);
w_neg  = -exp(dt_neg / 12);

% Semi-transparent shaded fills under LTP and LTD curves
fill(ax1, [dt_pos, fliplr(dt_pos)], [w_pos, zeros(size(w_pos))], colorBlue, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none'); hold(ax1, 'on');
fill(ax1, [dt_neg, fliplr(dt_neg)], [w_neg, zeros(size(w_neg))], colorRose, ...
    'FaceAlpha', 0.2, 'EdgeColor', 'none');

% Main STDP curves
plot(ax1, dt_pos, w_pos, 'Color', colorBlue, 'LineWidth', 3.5);
plot(ax1, dt_neg, w_neg, 'Color', colorRose, 'LineWidth', 3.5);

% Center dashed axis lines
yline(ax1, 0, '--', 'Color', colorGrid, 'LineWidth', 1.5);
xline(ax1, 0, '--', 'Color', colorGrid, 'LineWidth', 1.5);

% Styled Text Labels with Colored Background Badges
text(ax1, 18, 0.55, ' LTP ', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold', ...
    'BackgroundColor', colorBlue, 'Margin', 1, 'HorizontalAlignment', 'center');
text(ax1, -18, -0.55, ' LTD ', 'Color', 'w', 'FontSize', 12, 'FontWeight', 'bold', ...
    'BackgroundColor', colorRose, 'Margin', 1, 'HorizontalAlignment', 'center');

axis(ax1, 'off');
exportgraphics(fig1, 'synaptic_plasticity.png', 'BackgroundColor', 'none', 'Resolution', 300);
% close(fig1);


%%
% =========================================================================
% MATLAB Script: Synthetic Seizure-Like Event (SLE) Generator
% =========================================================================

% 1. Setup Parameters
fs = 500;                  % Sampling rate (Hz)
t = 0:1/fs:25;             % Time vector (25 seconds)
N = length(t);

% Initialize signal array
signal = zeros(1, N);

% Time logical masks for seizure phases
pre_idx    = t < 5;
tonic_idx  = t >= 5 & t < 5.5;
clonic_idx = t >= 5.5 & t < 19;
post_idx   = t >= 19;

% 2. Synthesize Seizure Phases
% Pre-ictal: Normal background alpha/beta rhythms
signal(pre_idx) = 15 * sin(2*pi*10 * t(pre_idx)) + 8 * sin(2*pi*21 * t(pre_idx));

% Tonic Phase: Rapid high-frequency spiking (~18 Hz) with ramped amplitude
t_tonic = t(tonic_idx) - 5;
amp_envelope = linspace(20, 140, length(t_tonic));
signal(tonic_idx) = amp_envelope .* (0.7 * sin(2*pi*18 * t_tonic) + 0.3 * sin(2*pi*36 * t_tonic));

% Clonic Phase: Rhythmic 3.5 Hz bursting (burst modulation + slow wave)
t_clonic = t(clonic_idx) - 11;
burst_mod = max(0, sin(2*pi*3.5 * t_clonic)).^3;
clonic_spikes = 180 * burst_mod .* sin(2*pi*18 * t_clonic);
clonic_slowwave = -110 * max(0, sin(2*pi*3.5 * t_clonic - 0.5));
signal(clonic_idx) = clonic_spikes + clonic_slowwave;

% Post-Ictal Suppression: Flattened signal with low-frequency delta wave
t_post = t(post_idx) - 19;
signal(post_idx) = 6 * sin(2*pi*1.5 * t_post);

% 3. Add Realistic Noise & Muscle Artifacts
noise_background = 8 * randn(1, N);                        % Thermal / Sensor noise
noise_emg = zeros(1, N);
noise_emg(tonic_idx | clonic_idx) = 18 * randn(1, sum(tonic_idx | clonic_idx)); % High EMG jitter

eeg_seizure = signal + noise_background + noise_emg;

% 4. Plot Results
F = figure('Name', 'Seizure-Like Event Simulation', 'Color', 'w', 'Position', [100, 100, 1000, 450]);

% Background phase shading
% hold on;
% patch([0 5 5 0], [-250 -250 250 250], [0.94 0.96 0.98], 'EdgeColor', 'none', 'HandleVisibility', 'off');
% patch([5 11 11 5], [-250 -250 250 250], [1.0 0.95 0.8], 'EdgeColor', 'none', 'HandleVisibility', 'off');
% patch([11 19 19 11], [-250 -250 250 250], [1.0 0.88 0.88], 'EdgeColor', 'none', 'HandleVisibility', 'off');
% patch([19 25 25 19], [-250 -250 250 250], [0.88 0.95 1.0], 'EdgeColor', 'none', 'HandleVisibility', 'off');

% Plot trace
plot(t, eeg_seizure, 'Color', 'k', 'LineWidth', 0.9);

% Labels and Formatting
xlabel('Time (seconds)', 'FontWeight', 'bold');
ylabel('Voltage (\muV)', 'FontWeight', 'bold');
% title('Synthetic Seizure-Like Event (Tonic-Clonic Progression)', 'FontSize', 12, 'FontWeight', 'bold');
xlim([0 25]);
ylim([-250 250]);
% grid on;
box off;
exportgraphics(F, 'epilepticSeizure.png', 'BackgroundColor', 'none', 'Resolution', 300);

% Annotations
% text(2.5, 210, 'Pre-Ictal', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.3 0.3 0.3]);
% text(8.0, 210, 'Tonic Phase', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.6 0.3 0.0]);
% text(15.0, 210, 'Clonic Phase', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.6 0.0 0.0]);
% text(22.0, 210, 'Post-Ictal', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.0 0.3 0.5]);