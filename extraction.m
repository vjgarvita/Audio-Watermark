filename = 'reconstructed.wav'; 
[y, fs] = audioread(filename);
nfft=2048;
F=fft(y,nfft);
F = F(1:nfft/2);
mx = abs(F);
f = (0:nfft/2-1)*fs/nfft;
figure;
subplot(2,1,1);
plot(f,mx);

i=656;
while(i<=1024)
    if (mx(i)<0.3)
        mx(i)=0;
    end
    i=i+16;
end

X = zeros(1,24);
i=656;
j=1;
while(i<=1024)
    if(mx(i)>0.3)
        X(j)=1;
    end
    j=j+1;
    i=i+16;
end
subplot(2,1,2);
plot(f,mx);
