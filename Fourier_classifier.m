training = imageDatastore('/Users/Will/Documents/SPS/CW2/characters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% test = imageDatastore('Test S.jpg', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
X = readimage(training, 5);
z = fft2(double(X));
q = fftshift(z);
Magq = abs(q);
Phaseq=angle(q);
imagesc(log(abs(q)+1)); colorbar;