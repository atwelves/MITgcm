function q = binread (filename,varargin);
% q = binread (fname,varargin)
%
% read a binary file (with big-endian architecture and double precision
% data types) into a matlab array with specified dimensions
% 
% fname: filename or path (string)
% varargin: a comma-separated list of dimension sizes. 
%           note (dimsize1) x (dimsize 2) x ... (dimsize N) must be equal
%           to the size of the file (in bytes) divided by 8!

%filename = input(prompt,'s');
%disp(filename)
%varargin = [50,30];

if (size(varargin,2) < 1)
    
    error ('enter array dimensions');
    
else
    
    arrsize = [];
    
    for ind=1:size(varargin,2);
      arg=varargin{ind};
      arrsize = [arrsize arg];
    end
    
end

fid = fopen (filename, 'r', 'b');
q=fread(fid,inf,'real*8');

if (size(varargin,2)>1)
 q=reshape(q,arrsize);
end

fclose(fid);

return

    
