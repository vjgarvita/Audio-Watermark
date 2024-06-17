
filename = 'new.wav'; 
[y, fs] = audioread(filename);


N = length(y); 
L = N / fs; 
f = fs * (0:(N/2))/N; 
Y = fft(y); 
P2 = abs(Y/N);  
P1 = P2(1:N/2+1); 
P1(2:end-1) = 2*P1(2:end-1);

subplot(2,1,1);
plot(f, P1);
title('Frequency Content of Audio Signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');


filename = 'reconstructed.wav'; 
[y, fs] = audioread(filename);


N = length(y); 
L = N / fs; 
f = fs * (0:(N/2))/N; 
Y = fft(y); 
P2 = abs(Y/N); 
P1 = P2(1:N/2+1); 
P1(2:end-1) = 2*P1(2:end-1);

subplot(2,1,2);
plot(f, P1);
title('Frequency Content of Audio Signal');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
