I1=dicomread('1-XÉäÏß»ú');
% I1=I1(522:738,1193:1314);
figure
imshow(I1);
minI1=min(min(I1));
maxI1=max(max(I1));

I2=dicomread('dicom_test_single2');
I2=I2(870:1279,921:1188);
figure
imshow(I2);
minI2=min(min(I2));
maxI2=max(max(I2));