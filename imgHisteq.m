% gOrg=dicomread('��-005-0063-008-01-0125-016-02-1');
% % figure,imshow(gOrg);
% 
% % gHistadj=histeq(gOrg,256);
% gHistadj=histeq(gOrg);
% figure,imshow(gHistadj);
% 
% gOrg=dicomread('��-002-003-004-005-006-01-015-02-1');
% % figure,imshow(gOrg);
% 
% gHistadj=histeq(gOrg,256);
% figure,imshow(gHistadj);
% 
% gOrg=dicomread('����-005-02-03-1-1-1.2-1.5-2-1');
% % figure,imshow(gOrg);
% 
% gHistadj=histeq(gOrg,256);
% figure,imshow(gHistadj);
% 
% gOrg=dicomread('ƿ��-1(����)�󽹵�');
% % figure,imshow(gOrg);
% 
% gHistadj=histeq(gOrg,256);
% figure,imshow(gHistadj);
% 
% gOrg=dicomread('dark-avg-int-g6');
% gOrg=gOrg';
% % figure,imshow(gOrg);
% 
% gHistadj=histeq(gOrg,256);
% figure,imshow(gHistadj);
% 
% gOrg=dicomread('rad-avg-int-g6');
% gOrg=gOrg';
% % figure,imshow(gOrg);
% 
% gHistadj=histeq(gOrg,256);
% figure,imshow(gHistadj);

close all;
gOrg=dicomread('����');
gOrg=gOrg';
% figure,imshow(gOrg);

gHistadj=imadjust(gOrg,stretchlim(0.05,0.1),[0,1],1/5)';
% gHistadj=adpmedian(gHistadj,5);
figure,imshow(gHistadj);