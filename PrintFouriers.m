training = imageDatastore('/Users/Will/Documents/SPS/CW2/characters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

figure;

for x = 3:32
    X = readimage(training, x);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1);
    subplot(3,10,x-2);
    imagesc(Y);
end
