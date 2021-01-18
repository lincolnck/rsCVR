% write an .img file
% Input:
%       ImageArray : the image array
%       filename : The name of the file
%       fileformat : e.g. 'int16', 'uint8', 'float'
%
function f = write_img(ImageArray,filename,fileformat)
           fid = fopen(filename,'w');
           fwrite(fid, ImageArray(:),fileformat);
           fclose(fid);


