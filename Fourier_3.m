close all;
training = imageDatastore('/Users/Will/Documents/SPS/CW2/characters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
test = imageDatastore('/Users/Will/Documents/SPS/CW2/Testcharacters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% Calculate average vertical elements
magVertT = zeros(10,2);
for t = 13:22

    X = readimage(training, t);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1); 

    filtered = zeros(400,640);

    for u = 150:250
        for v = 315:325        
                filtered(u,v) = Y(u,v);        
        end
    end
    
    s = t-12;
    magVertT(s,1) = t;
    magVertT(s,2) = sum(sum(filtered.^2)); 
    
end

avgVertT = sum(magVertT);
avgVertT = avgVertT(1,2);

% Calculate average horizontal elements
magHorT = zeros(10,2);
for t = 13:22

    X = readimage(training, t);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1); 

    filtered = zeros(400,640);

    for u = 195:205
        for v = 280:360       
                filtered(u,v) = Y(u,v);        
        end
    end
    
    s = t-12;
    magHorT(s,1) = t;
    magHorT(s,2) = sum(sum(filtered.^2));
   
end

avgHorT = sum(magHorT);
avgHorT = avgHorT(1,2);

percentT = zeros(30,2);
for x = 3:32
    X = readimage(training, x);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1);
    
    filtered = zeros(400,640);
    for u = 150:250
        for v = 315:325        
                filtered(u,v) = Y(u,v);        
        end
    end
    
    filtered2 = zeros(400,640);
    for u = 195:205
        for v = 280:360       
                filtered2(u,v) = Y(u,v);        
        end
    end
    percentT(x-2,2) = ((sum(sum(filtered.^2))) + (sum(sum(filtered2.^2))))/(avgVertT+avgHorT);
end

% Calculate average V, Needs to be improved
magV = zeros(10,2);
for t = 23:32

    X = readimage(training, t);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1); 
    filtered = zeros(400,640);

    for u = 0:200
        for v = 320:640       
            if(abs(u-200)^2 + (v-320)^2 < 50^2)  
                if(atan(abs(u-200)/(v-320)) > 10*(pi/180) && atan(abs(u-200)/(v-320)) < 50*(pi/180)) 
                    filtered(u,v) = Y(u,v);
                end
            end
        end
    end
    
    s = t-12;
    magV(s,1) = t;
    magV(s,2) = sum(sum(filtered.^2)); 
end

avgV = sum(magV);
avgV = avgV(1,2);

percentV = zeros(30,2);
for x = 3:32
    X = readimage(training, x);
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1);
    
    filtered = zeros(400,640);
    for u = 0:200
        for v = 320:640       
            if(abs(u-200)^2 + (v-320)^2 < 50^2)  
                if(atan(abs(u-200)/(v-320)) > 10*(pi/180) && atan(abs(u-200)/(v-320)) < 50*(pi/180)) 
                    filtered(u,v) = Y(u,v);
                end
            end
        end
    end
    
    percentV(x-2,2) = sum(sum(filtered.^2))/avgV;
end

Z = horzcat(percentT(:,2), percentV(:,2));
B = char(zeros(30, 1));
for x = 1:30
    if(x<= 10)  
        B(x) = 'S';
    else
        if(x<=20)
            B(x) = 'T';
        else 
            B(x) = 'V';
        end
    end
end

%create knn classifier.
classifier = fitcknn(Z,B);
sz = 20;
figure;
% Plotting decision boundaries.
xrange = [0.07 0.11];
yrange = [0.06 0.13];
inc = 0.0001;
[i, j] = meshgrid(xrange(1):inc:xrange(2), yrange(1):inc:yrange(2));
image_size = size(i);
ij = [i(:) j(:)];
boundaryLabels = predict(classifier, ij);
decisionmap = double(reshape(boundaryLabels, image_size));
imagesc(xrange,yrange,decisionmap);
hold on;
cmap = [1 0.8 0.8; 0.95 1 0.95; 0.9 0.9 1];
colormap(cmap);

scatter(Z(B == 'S', 1), Z(B == 'S', 2), sz, 'r', 'filled');
hold on
scatter(Z(B == 'T', 1), Z(B == 'T', 2), sz,  'g', 'filled');
hold on
scatter(Z(B == 'V', 1), Z(B == 'V', 2), sz,  'b', 'filled');
hold on

xlabel('T Percent');
ylabel('V Percent');
hold on

% Extract features of test data
percentT = zeros(9,2);
for x = 1:9
    X = imbinarize(rgb2gray(readimage(test, x)));
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1);
    
    filtered = zeros(400,640);
    for u = 150:250
        for v = 315:325        
                filtered(u,v) = Y(u,v);        
        end
    end
    
    filtered2 = zeros(400,640);
    for u = 195:205
        for v = 280:360       
                filtered2(u,v) = Y(u,v);        
        end
    end
    percentT(x,2) = ((sum(sum(filtered.^2))) + (sum(sum(filtered2.^2))))/(avgVertT+avgHorT);
end

percentV = zeros(9,2);
for x = 1:9
    X = imbinarize(rgb2gray(readimage(test, x)));
    z = fft2(double(X));
    q = fftshift(z);
    Y = log(abs(q)+1);
    
    filtered = zeros(400,640);
    for u = 0:200
        for v = 320:640       
            if(abs(u-200)^2 + (v-320)^2 < 50^2)  
                if(atan(abs(u-200)/(v-320)) > 10*(pi/180) && atan(abs(u-200)/(v-320)) < 50*(pi/180)) 
                    filtered(u,v) = Y(u,v);
                end
            end
        end
    end
    
    percentV(x,2) = sum(sum(filtered.^2))/avgV;
end

% A contains the created test points T and V values.
A = horzcat(percentT(:,2), percentV(:,2));
TestLabels = predict(classifier, A);
scatter(A(TestLabels == 'S', 1), A(TestLabels == 'S', 2), sz, 'r', 'filled');
hold on
scatter(A(TestLabels == 'T', 1), A(TestLabels == 'T', 2), sz,  'g', 'filled');
hold on
scatter(A(TestLabels == 'V', 1), A(TestLabels == 'V', 2), sz,  'b', 'filled');
hold on
