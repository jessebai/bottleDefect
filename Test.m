I1=dicomread('1-XÉäÏß»ú');
% imshow(I1);
I1=medfilt2(I1,[5,5]);
II1=I1(365:791,961:1753);
% figure
% imshow(II1);
J=stdfilt(II1);
ind=max(max(J))/255;
II2=uint8(round(J./ind));
% figure
% imshow(II2);
IContain=II1(148:367,35:178);
JContainStd=stdfilt(IContain);
ind=max(max(JContainStd))/255;
JContainStdInt=uint8(round(JContainStd./ind));
% figure
% imshow(JContainStdInt);

ILiquid=II1(330:364,32:176);
StdLiquid=stdfilt(ILiquid);
ind=max(max(StdLiquid))/255;
IntStdLiquid=uint8(round(StdLiquid./ind));
figure
imshow(IntStdLiquid);
