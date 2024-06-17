clc;
clear;
warning off;
Fs = 80000; 
recorder = audiorecorder(Fs, 16, 1);
duration = 0.01;

empty_signal = zeros(Fs * duration, 1);

audiowrite('new.wav', empty_signal, Fs);
audiowrite('reconstructed.wav', empty_signal, Fs);

enc_data = [0,1,1,0,1,0,1,1,0,1,1,0,0,1,0,1,0,1,1,1,1,0,0,1];
   
while true
 
    disp('Start recording...');
    recordblocking(recorder,4);
    disp('Recording finished.');
    tic
    
    x = getaudiodata(recorder);
    [new, Fs] = audioread('new.wav');
    
    combined_signal = vertcat(new, x);

    audiowrite('new.wav', combined_signal, Fs);

    Y = fft(x);
    
    i=100000;
    j=1;
    while(i<160000)
        i=i+2500;
        Y(i)=500*enc_data(j);
        j=j+1;
    end

    iY=real(ifft(Y));

    [reconstructed, Fs] = audioread('reconstructed.wav');
    combined_signal = vertcat(reconstructed, iY);
    audiowrite('reconstructed.wav', combined_signal, Fs);
    toc;
    
    t = (0:length(iY)-1)/Fs;
    close all;
    figure;
    subplot(2,1,1); plot(t, x); title('Original Signal');
    subplot(2,1,2); plot(t, iY); title('Reconstructed Signal');
end