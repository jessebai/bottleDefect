function  [data] = readraw(fname,distance,M,N)
%distanceΪ�ļ�ͷ��65536��

%% �����ļ�
f1=fopen(fname,'r');
fseek(f1,distance-1,'bof');
data=fread(f1,[M,N],'uint16');
fclose(f1);