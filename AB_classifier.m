training = imageDatastore('/Users/jacobmontgomery/University/Year2/SPS/SPSCW2/characters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% test = imageDatastore('/Users/jacobmontgomery/University/Year2/SPS/SPSCW2/test_characters', 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
% image = readimage(training, 35);
% imagesc(image);
% Calculate average vertical elements
magVertT = zeros(11,2);
for t = 2

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
    
    s = t;
    magVertT(s,1) = t;
    magVertT(s,2) = sum(sum(filtered.^2)); 
end

avgVertT = sum(magVertT);
avgVertT = avgVertT(1,2);

% Calculate average horizontal elements
magHorT = zeros(11,2);
for t = 2

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
    
    s = t;
    magHorT(s,1) = t;
    magHorT(s,2) = sum(sum(filtered.^2)); 
end

avgHorT = sum(magHorT);
avgHorT = avgHorT(1,2);


percentT = zeros(30,2);
for x = 1:2
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
    percentT(x,2) = ((sum(sum(filtered.^2))) + (sum(sum(filtered2.^2))))/(avgVertT+avgHorT);
end

% Calculate average V, Needs to be improved
magV = zeros(10,2);
for t = 2

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
    
    s = t;
    magV(s,1) = t;
    magV(s,2) = sum(sum(filtered.^2)); 
end

avgV = sum(magV);
avgV = avgV(1,2);

percentV = zeros(30,2);
for x = 1:2
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
    
    percentV(x,2) = sum(sum(filtered.^2))/avgV;
end

% scatter(percentT(:,2), percentV(:,2));

Z = horzcat(percentT(:,2), percentV(:,2));
[idx,C] = kmeans(Z, 3);
sz = 20;
scatter(Z(idx == 1, 1), Z(idx == 1, 2), sz, 'r', 'filled');
hold on
%scatter(Z(idx == 2, 1), Z(idx == 2, 2), sz,  'g', 'filled');
%hold on
%scatter(Z(idx == 3, 1), Z(idx == 3, 2), sz,  'b', 'filled');
%hold on
voronoi(C(:,1), C(:,2));

xlabel('T Percent');
ylabel('V Percent');