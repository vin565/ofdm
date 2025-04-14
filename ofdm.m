clc;
clear;
close all;

%% Parameters
N = 64;                % Number of subcarriers
Ncp = 16;              % Cyclic prefix length
Fs = 1000;             % Sampling frequency (Hz)
T = 1/Fs;              % Sampling period
t = (0:1/Fs:1-1/Fs)';  % Time vector for one symbol
numSymbols = 10;       % Number of OFDM symbols

%% Generate Message Signal
message = sin(2*pi*5*t); % Example message signal (sine wave)

% Plot message signal
figure;
plot(t, message);
title('Message Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% OFDM Modulation
% Reshape message into N subcarriers per OFDM symbol
message_trimmed = message(1:numSymbols*N); % Trim to fit symbol count
msg_blocks = reshape(message_trimmed, N, []); % Divide into blocks

% Perform FFT on each block (modulation in frequency domain)
ofdm_freq = fft(msg_blocks, N);

% Add cyclic prefix
cyclic_prefix = ofdm_freq(end-Ncp+1:end, :);
ofdm_with_cp = [cyclic_prefix; ofdm_freq];

% Convert back to time domain
modulated_signal = ifft(ofdm_with_cp, [], 1); % Time domain signal
modulated_signal = modulated_signal(:); % Flatten to single vector

% Plot modulated signal
figure;
plot(real(modulated_signal(1:200)));
title('OFDM Modulated Signal');
xlabel('Sample Index');
ylabel('Amplitude');
grid on;

%% OFDM Demodulation
% Reshape received signal into blocks
received_signal = reshape(modulated_signal, N+Ncp, []);
received_blocks = received_signal(Ncp+1:end, :); % Remove cyclic prefix

% Perform FFT on each block (demodulation in frequency domain)
received_freq = fft(received_blocks, N);

% Convert back to time domain
demodulated_blocks = ifft(received_freq, N);
demodulated_signal = real(demodulated_blocks(:)); % Flatten to single vector

% Trim to match original message length
demodulated_signal = demodulated_signal(1:length(message_trimmed));

% Plot demodulated signal
figure;
plot(t(1:length(demodulated_signal)), demodulated_signal, 'r', 'LineWidth', 1.5);
hold on;
plot(t(1:length(message_trimmed)), message_trimmed, 'b--', 'LineWidth', 1.5);
title('Original vs. Demodulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Demodulated Signal', 'Original Message');
grid on;
