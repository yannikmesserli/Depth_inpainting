%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%											%
%	IMAGE COMMUNICATION - EPFL COURSE		%
%				June 2012					%
%		Inpaiting of depth image			%
%											%
% Yannik Messerli: yannik.messerli@epfl.ch	%
% 	Nicolas Jorns: nicolas.jorns@epfl.ch	%
%											%
% 		Supervised by Thomas Maugey			%
%											%
%	Code freely taken from Sooraj Bhat		%
%				and modified				%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------
% Returns the indices for a 2w+1x2w+1 patch centered at pixel p.
%---------------------------------------------------------------------
function [Hp,rows,cols] = getpatch(sz,p, w)
	% Returns the indices for a 2w+1x2w+1 patch centered at pixel p.
	% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size
	p = p-1; y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;
	rows = max(x-w,1):min(x+w,sz(1));
	cols = (max(y-w,1):min(y+w,sz(2)))';
	Hp = sub2ndx(rows,cols,sz(1));
end


%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
	X = rows(ones(length(cols),1),:);
	Y = cols(:,ones(1,length(rows)));
	N = X+(Y-1)*nTotalRows;
end