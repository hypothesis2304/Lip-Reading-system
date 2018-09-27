%%

height_9 = cell(3,1);
width_9  = cell(3,1);
h_w_ratio_9 = cell(3,1);

%%
u = VideoReader('C:\Users\VIKAS\Desktop\practice_final\database\sample 9\s09_0_4.mp4'); 
v = read(u); % v is the uint8 speaker video
[e,f,g,h] = size(v);

% v = v(:,:,:,1:h-7);
% [e,f,g,h] = size(v);

output = v;

% lip features to be extracted 
height_mat = zeros(h);
width_mat = zeros(h);
h_w_ratio_mat = zeros(h);
area_mat = zeros(h);
perimeter_mat = zeros(h);

for o = 1:h
    a = v(:,:,:,o); % a is any frame from the video

    face_detector = vision.CascadeObjectDetector('MergeThreshold',40);
    fbox = step(face_detector,a);
    % fbox is the box bounding the face and 'FrontalFaceCART' is the default
    % classification model

    mouth_detector = vision.CascadeObjectDetector('Mouth','MergeThreshold',150);
    lower_face = a(fbox(1,2)+ floor(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:);
    mbox = step(mouth_detector,lower_face);
    % search for the mouth only in the lower face to avoid detecting
    % eyes as mouth. mbox is the box bounding the mouth.

    % To show face and mouth annotations 
    % a = insertObjectAnnotation(a,'rectangle',fbox,'face');
    % a(fbox(1,2)+ round(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:) = insertObjectAnnotation(lower_face,'rectangle',mbox,'mouth');
    % imshow(a);

    rgb_mouth = lower_face(mbox(1,2):mbox(1,2)+ mbox(1,4),mbox(1,1):mbox(1,1)+mbox(1,3),:);
    
    %   [r1,c1,p1] = size(rgb_mouth);
    %   rgb_mouth2 = rgb_mouth(1:3,:,:);
    %   rgb_mouth1 = rgb_mouth(r1-13 :r1,:,:);
    %   rgb_mouth = rgb_mouth(4:r1-14,:,:);
    
    % subplot(2,2,1)
    % imshow(rgb_mouth);
    % title('mouth region');
    hsv_mouth = rgb2hsv(rgb_mouth);
    [p,q,r] = size(rgb_mouth);
    skin_lip = 0*rgb_mouth(:,:,1);
        
    for i = 1:p
        for j= 1:q
            if ((hsv_mouth(i,j,1)*360 >= 7 ) && (hsv_mouth(i,j,1)*360 <= 26))
                 skin_lip(i,j) = 0;
            else
                skin_lip(i,j) = 255;
            end
        end
    end
    
    gray_mouth = rgb2gray(rgb_mouth);
    for i = 1:p
        for j = 1:q
            if gray_mouth(i,j) < 80
                skin_lip(i,j) = 255;
            end
        end
    end
%     
%     for i = 1:8
%         for j = 1:q
%             skin_lip(i,j) = 0;
%         end
%     end

    for i = p-12 : p
        for j = 1:q
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:p
        for j = 1:5
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:p
        for j = q-5:q
            skin_lip(i,j) = 0;
        end
    end

    for i = 1:8
        for j = 1:8
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
    % subplot(2,2,2)
    % imshow(skin_lip);
    % title('binary lip image');

    CH = bwconvhull(skin_lip);
    % subplot(2,2,3)
    % imshow(CH);
    % title('convex hull of the binary image');

    B = bwboundaries(CH);
    boundary = B{1} ;
    [m,n] = size(boundary);
    perimeter = m;
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

    % subplot(2,2,4);
    % imshow(rgb_mouth);
    % title('image showing mouth border');
    
    % rgb_mouth = [rgb_mouth2 ;rgb_mouth ;rgb_mouth1];
    lower_face(mbox(1,2):mbox(1,2)+ mbox(1,4),mbox(1,1):mbox(1,1)+mbox(1,3),:) = rgb_mouth;
    a(fbox(1,2)+ floor(fbox(1,4)/2):fbox(1,2)+ fbox(1,4),fbox(1,1):fbox(1,1)+fbox(1,3),:) = lower_face;
    output(1:e,1:f,1:g,o) = a;
    height = largest_row - smallest_row + 1;
    width = largest_col - smallest_col + 1;
    height_mat(o) = height;
    width_mat(o) = width;
    h_w_ratio = height ./ width ;
    h_w_ratio_mat(o) = h_w_ratio;
    perimeter_mat(o) = perimeter;
    
    for i = 1:p
        for j = 1:q
            if (CH(i,j) == 255)
                area = area + 1;
            end
        end
    end
    
    area_mat(o) = width;
end
implay(output);

frame_num = 1:h;

% plotting of various lip features with respect to frame number
% figure();
% plot(frame_num , height_mat);
% title('variation of height');
% 
% figure();
% plot(frame_num , width_mat);
% title('variation of width');

figure();
plot(frame_num , h_w_ratio_mat);
title('variation of h/w ratio with frame number');
xlabel('frame number');
ylabel('h/w ratio');

% figure();
% plot(frame_num , area_mat);
% title('variation of lip area');
% 
% figure();
% plot(frame_num , perimeter_mat);
% title('variation of perimeter of the lip');


%%

height_9{2} = height_mat;
width_9{2}  = width_mat;
h_w_ratio_9{2} = h_w_ratio_mat;


