
% train_files = dir('E:\New Folder\*.tif');  % the folder in which ur images exists
% for i = 1 : length(train_files)
%     filename = strcat('E:\New Folder\',train_files(i).name);
%     I = imread(filename);
%     figure, imshow(I);
% end

train_hist = [];
train_labels = {};
length_labels = 1;
%train_files = dir('/home/kavya/Documents/sem5/smai/project/train/*');
%train_files = dir('/home/kavya/Documents/sem5/smai/project/test/*');
for no_of_fruits = 3 : length(train_files)
    fruit_name = train_files(no_of_fruits).name;
    %fruit_images = dir(strcat('/home/kavya/Documents/sem5/smai/project/train/',fruit_name, '/*'));
    fruit_images = dir(strcat('/home/kavya/Documents/sem5/smai/project/test/',fruit_name, '/*'));
    for no_of_images_of_fruit = 3 : length(fruit_images)
        %filename = strcat('/home/kavya/Documents/sem5/smai/project/train/',fruit_name,'/',fruit_images(no_of_images_of_fruit).name);
        filename = strcat('/home/kavya/Documents/sem5/smai/project/test/',fruit_name,'/',fruit_images(no_of_images_of_fruit).name);
        image = imread(filename);
        %image = imread('sample.jpg');
        hsv_image = rgb2hsv(image);
        fruit_name
        % Downsampling by linear interpolation upto 25%

        image_down = imresize(hsv_image, 0.25, 'bilinear');
        s_channel = image_down(:,:,2);
        h_channel = image_down(:,:,1);
        v_channel = image_down(:,:,3);

        rows = size(s_channel,1);
        cols = size(s_channel,2);

        oned_s = s_channel(:);           % converting 2D S channel to 1D
        clustered = kmeans(oned_s,2,'EmptyAction','singleton');
        clustered = (clustered -1);
        edge_detect = edge(s_channel,'sobel');


        %figure, imshow(edge_detect) %limitation that there are plain backgrounds and background is more
        M = reshape(clustered',[rows, cols]);

        % identifying the background cluster

        tot_sum_row = 0;
        count_row = 0;
        rows_arr = [];

        for i = 1:rows
            edge_count = 0;
            for j = 1:cols
                if edge_detect(i,j) ~= 0
                    edge_count = edge_count + 1;
                    if edge_count > 1
                        break
                    end
                end
            end
            if edge_count <= 1
                count_row = count_row + 1;
                rows_arr(count_row) = i;
                sum = 0;
                for k = 1:cols
                    sum = sum + M(i,k);
                end
                tot_sum_row = tot_sum_row + round(sum/cols);
            end
        end
        row_bcolor = round(tot_sum_row/count_row);


        tot_sum_col = 0;
        count_col = 0;
        cols_arr = [];

        for i = 1:cols
            edge_count = 0;
            for j = 1:rows
                if edge_detect(j,i) ~= 0
                    edge_count = edge_count + 1;
                    if edge_count > 1
                        break
                    end
                end
            end
            if edge_count <= 1
                count_col = count_col + 1;
                cols_arr(count_col) =  i;
                sum = 0;
                for k = 1:rows
                    sum = sum + M(k,i);
                end
                tot_sum_col = tot_sum_col + round(sum/cols);
            end
        end
        col_bcolor = round(tot_sum_col/count_col);


        % here background color is detected
        if col_bcolor == row_bcolor
            bcolor = row_bcolor;
        else
            if tot_sum_col/count_col > tot_sum_row/count_row
                large = 1 - tot_sum_col/count_col;
                small = tot_sum_row/count_row;
                if large > small
                    bcolor = row_bcolor;
                else
                    bcolor = col_bcolor;
                end
            else
                large = 1 - tot_sum_row/count_row;
                small = tot_sum_col/count_col;
                if large > small
                    bcolor = col_bcolor;
                else
                    bcolor = row_bcolor;
                end
            end
        end

        if bcolor == 1
            M = -(M-1);
        end

        for i = 1:count_row
            M(rows_arr(i),:) = 0;
        end
        for i = 1:count_col
            M(:,cols_arr(i)) = 0;
        end

        % for morphing, using imclose

        %figure, imshow(M)

        se = strel('disk',9);
        closeBW = imclose(M,se);
        M = closeBW;

        image_down(:,:,2) = M.*s_channel;
        image_down(:,:,1) = M.*h_channel;
        image_down(:,:,3) = M.*v_channel;

        f = hsv2rgb(image_down);
        final = imresize(f, 4, 'bilinear');
        %figure, imshow(final)

end


