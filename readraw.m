function  [data] = readraw(fname,distance,M,N)
%distance为文件头（65536）

%% 读入文件
f1=fopen(fname,'r');
fseek(f1,distance-1,'bof');
data=fread(f1,[M,N],'uint16');
fclose(f1);