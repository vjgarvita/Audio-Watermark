clc;
warning off;
% Initialize audio recording
Fs = 80000; % Sampling rate
recorder = audiorecorder(Fs, 16, 1);
duration = 0.01; % empty file generation duration (seconds)

% Create an empty audio signal of the desired duration
empty_signal = zeros(Fs * duration, 1);

% Generate audio signal
f = 30000;              % Frequency of the signal (Hz)
duration1 = 5;           % Duration of the audio signal (seconds)
t = 0:(1/Fs):duration1-1/Fs;  % Time vector (0 to duration seconds)
wm = 0.004*sin(2*pi*f*t);    % Generate sinusoidal signal as watermark

% Write the empty audio signal to a WAV file
audiowrite('new.wav', empty_signal, Fs);
audiowrite('reconstructed.wav', empty_signal, Fs);

% Perform DWT
level = 3;
wname = 'db4';
while true
    tic
    % Start audio recording for 2 seconds
    disp('Start recording...');
    recordblocking(recorder,5);
    disp('Recording finished...');

    % Get the recorded audio signal
    x1 = getaudiodata(recorder);
    % Define the filter parameters
    cutoff_freq = 20000;  % Cutoff frequency in Hz
    filter_order = 4;  % Filter order

    % Design the low-pass filter using Butterworth filter
    [b, a] = butter(filter_order, cutoff_freq/(Fs/2), 'low');

    % Apply the filter to the audio signal
    x = filtfilt(b, a, x1);

    [new, Fs] = audioread('new.wav');
    % Append the new audio data to the end of the original signal
    combined_signal = vertcat(new, x);

    % Write the combined audio data to a new file
    audiowrite('new.wav', combined_signal, Fs);

    [C, L] = wavedec(x, level, wname);

    % Perform DTMT on each level of DWT coefficients
    alpha = 1;  % DTMT alpha value
    for i = 1:level+1
        C(i,:) = dtmt(C(i,:), alpha);
    end

    % Resize the watermark to match the size of the DWT coefficients
    wm = interp1(linspace(0, 1, numel(wm)), wm, linspace(0, 1, numel(C)));  % Resize the watermark to match the size of the DWT coefficients

    % Embed the watermark in the DWT coefficient
    wm_embedded = alpha * wm;  % Embed the watermark in the watermark signal
    C(1:numel(wm_embedded)) = C(1:numel(wm_embedded)) + wm_embedded(:);  % Embed the watermark in the DWT coefficients

    % Perform IDTMT on each level of DWT coefficients
    inverse_alpha = 1 - alpha;
    for i = 1:level+1
        C(i,:) = dtmt(C(i,:), inverse_alpha);
    end

    % Perform IDWT
    x_reconstructed = waverec(C, L, wname);
    [reconstructed, Fs] = audioread('reconstructed.wav');
    combined_signal = vertcat(reconstructed, x_reconstructed);
    audiowrite("reconstructed.wav",combined_signal,Fs);
    toc;
    % Plot the original and reconstructed signals
    t = (0:length(x)-1) / Fs;
    close all;
    figure;
    subplot(2,1,1);
    plot(t, x);
    title('Original Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    subplot(2,1,2);
    plot(t, x_reconstructed);
    title('Reconstructed Signal after DWT and IDTMT');
    xlabel('Time (s)');
    ylabel('Amplitude');
end

function y = dtmt(x, alpha)
% Discrete Tchebichef Moment Transform (DTMT) implementation
% x: input signal
% alpha: alpha value for DTMT

% Check for valid input
if nargin < 2
    alpha = 0.5;  % Default alpha value
end

% Calculate the length of the input signal
N = length(x);

% Initialize output signal
y = zeros(1, N);

% Calculate the DTMT
for n = 0:N-1
    sum = 0;
    for k = 0:N-1
        sum = sum + x(k+1) * tchebichef(n, k, alpha);
    end
    y(n+1) = sum;
end

end

function y = tchebichef(n, k, alpha)
% Tchebichef polynomial implementation
% n: polynomial order
% k: variable value
% alpha: alpha value for Tchebichef polynomial

% Check for valid input
if n == 0
    y = 1;
elseif n == 1
    y = k * (2*alpha - 1);
else
    y = 2 * k * tchebichef(n-1, k, alpha) - tchebichef(n-2, k, alpha);
end

end