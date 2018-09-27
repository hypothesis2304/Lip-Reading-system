clc; clear;

u = VideoReader('C:\Users\VIKAS\Desktop\practice_final\database\sample 30\s30_4_2.mp4'); 
v = read(u); % v is the uint8 speaker video
[e,f,g,h] = size(v);

a = v(:,:,:,1); % a is any frame from the video

face_detector = vision.CascadeObjectDetector('MergeThreshold',30);
fbox = step(face_detector,a);
% fbox is the box bounding the face and 'FrontalFaceCART' is the default
% classification model

mouth_detector = vision.CascadeObjectDetector('Mouth','MergeThreshold',40);
lower_face = a(fbox(1,2)+ round(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:);
mbox = step(mouth_detector,lower_face);
% search for the mouth only in the lower face to avoid detecting
% eyes as mouth. mbox is the box bounding the mouth.

% To show face and mouth annotations 
a = insertObjectAnnotation(a,'rectangle',fbox,'face','color','yellow');
lower_face = a(fbox(1,2)+ round(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:);
a(fbox(1,2)+ round(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:) = insertObjectAnnotation(lower_face,'rectangle',mbox,'mouth','color','yellow');
imshow(a);

rgb_mouth = lower_face(mbox(1,2):mbox(1,2)+ mbox(1,4),mbox(1,1):mbox(1,1)+mbox(1,3),:);
% [r1,c1,p1] = size(rgb_mouth);
% rgb_mouth2 = rgb_mouth(1:3,:,:);
% rgb_mouth1 = rgb_mouth(r1-9 :r1,:,:);
% rgb_mouth = rgb_mouth(4:r1-10,:,:);
figure();
subplot(2,2,1)
imshow(rgb_mouth);
title('mouth region (ROI)');

hsv_mouth = rgb2hsv(rgb_mouth);
[p,q,r] = size(rgb_mouth);
skin_lip = 0*rgb_mouth(:,:,1);

for i = 1:p
    for j= 1:q
        if ((hsv_mouth(i,j,1)*360 >= 7 ) && (hsv_mouth(i,j,1)*360 <= 25))%28
             skin_lip(i,j) = 0;
        else
            skin_lip(i,j) = 255;
        end
    end
end

% gray_mouth = rgb2gray(rgb_mouth);
% for i = 1:p
%     for j = 1:q
%         if gray_mouth(i,j) < 80
%             skin_lip(i,j) = 255;
%         end
%     end
% end

for i = 1:1
        for j = 1:q
            skin_lip(i,j) = 0;
        end
    end

    for i = p-14 : p
        for j = 1:q
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:p
        for j = 1:4
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:p
        for j = q-4:q
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:6
        for j = 1:6
            skin_lip(i,j) = 0;
        end
    end
    for i = 1:6
        for j = q-6:q
            skin_lip(i,j) = 0;
        end
    end
    for i = p-24:p
        for j = 1:24
            skin_lip(i,j) = 0;
        end
    end
    for i = p-24:p
        for j = q-24:q
            skin_lip(i,j) = 0;
        end
    end
    
% skin_lip is a binary image with the white region approximating the lips
subplot(2,2,2)
imshow(skin_lip);
title('binary lip image after filtering');

CH = bwconvhull(skin_lip);
subplot(2,2,3)
imshow(CH);
title('convex hull of the binary lip image');

B = bwboundaries(CH);
boundary = B{1} ;
[m,n] = size(boundary);
smallest_row = boundary(1,1);
smallest_col = boundary(1,2);
largest_row = boundary(1,1);
largest_col = boundary(1,2);

for i = 1:m
    row = boundary(i,1);
    col = boundary(i,2); 
    if (row < smallest_row)
        smallest_row = row;
    elseif (row > largest_row)
        largest_row = row;
    end
    if (col < smallest_col)
        smallest_col = col; 
    elseif (col > largest_col)
        largest_col = col;       
    end
    rgb_mouth(row,col,:) = [0 0 0];
end

for i = smallest_row
    for j = smallest_col:largest_col
        rgb_mouth(i,j,:) = [0 0 0];
    end
end
for i = largest_row
    for j = smallest_col:largest_col
        rgb_mouth(i,j,:) = [0 0 0];
    end
end
for j = smallest_col
    for i = smallest_row:largest_row
        rgb_mouth(i,j,:) = [0 0 0];
    end
end
for j = largest_col
    for i = smallest_row:largest_row
        rgb_mouth(i,j,:) = [0 0 0];
    end
end

subplot(2,2,4);
imshow(rgb_mouth);
title('image showing mouth border');

