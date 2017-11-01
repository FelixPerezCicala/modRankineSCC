function y = polyvaln(p,x) 
%POLYVALN  evaluate a multivariate polynomial
%
%    The n-variate polynomial p, represented as an n-dimensional
%    array, is evaluated for each value in the array x. The last 
%    dimension of x should be of size n corresponding to the n
%    variables in the polynomial.
% 
%    Following the convention used in polyval(), the highest 
%    order coefficient of the polynomial comes first in the
%    array, and we take the first index to be the index of
%    the x-coefficient, the second of the y-coefficient and
%    so on. For a bivariate polynomial the array is a matrix 
%    and we have this sort of structure
%
%      [    x^n y^m,     x^n y^(m-1), ...     x^n y,    x^n
%       x^(n-1) y^m, x^(n-1) y^(m-1), ... x^(n-1) y, x^(n-1)
%                 :
%             x y^m,       x y^(m-1), ...        xy,      x
%               y^m,         y^(m-1), ...         y,      1]
%
%    Example: the polynomial x^2 + 2y^2 - 1 
%
%      p = [0,0,1;
%           0,0,0;
%           2,0,-1]
%
%    Evaluated at x=1, y=2 
%
%      polyvaln(p,[1,2])
%      ans = 8
% 
%    Evaluated at x,y = 1,..,5: we generate a 5x5x2 array xy
%    with the x values in xy(:,;,1), the y values in xy(:,:,2)
%
%      [x,y] = meshgrid(1:5)
%      xy = cat(3,x,y)
%      polyvaln(p,xy)
%      ans =
%          2    5   10   17   26
%          8   11   16   23   32
%         18   21   26   33   42
%         32   35   40   47   56
%         50   53   58   65   74
%
%    The evaluation method is a nested Horner's rule which is
%    implemented recursively. No attempt is made to exploit the 
%    sparsity (if any) of the polynomial. 
%
%    NOTE - this file should not be confused with the file of the
%    same name included with the PolyFit package by John D'Errico
%    http://mathworks.com/matlabcentral/fileexchange/34765-polyfitn
%
%    Copyright (c) 2011, 2012, J.J. Green
%    $Id: polyvaln.m,v 1.6 2012/05/15 20:26:02 jjg Exp $
%
%    Changes
%    
%    06 Jan 2011 : initial octave version
%    24 Jul 2011 : ported to work with matlab (7.12.0.635)
%    15 Mar 2012 : added note on the file in polyfit package

  % check arguments

  if nargin ~= 2
    error('exactly 2 arguments required')
  end

  % handle trivial case

  if isvector(p)
    y = polyval(p,x);
    return;
  end

  % size of last dimension of x

  if isvector(x)
    ndx  = 1;
    sldx = length(x);
  else
    dx   = size(x);
    ndx  = numel(dx);
    sldx = dx(ndx);
  end

  % number of dimensions of p

  dp = size(p);
  ndp = numel(dp);

  % check dimensions match

  if ndp ~= sldx
    error('size of last dim of x should equal number of dims of p')
  end

  % reshape x if needed

  if ndx > 1
    x = reshape(x,prod(dx(1:ndx-1)),sldx);
  end

  % call recursive subfunction

  y = pvn2(p,x);

  % reshape y to the same pattern as x if needed

  if ndx > 2

    y = reshape(y,dx(1:ndx-1));

  end

end

% recurse over the dimensions of p, evaluating using
% polyval() at the leaves of the recursion but pvn3()
% as we accumulate the totals

function y = pvn2(p,x) 

  if isvector(p)
    y = polyval(p,x);
    return
  end

  d  = size(p);
  nd = numel(d);

  c(1:nd-1) = {':'};
  x0 = x(:,2:nd);

  for i = 1:d(1)
    p0 = squeeze(p(i,c{:}));
    p1(:,i) = pvn2(p0,x0);
  end

  y = pvn3(p1,x(:,1));

end

% this is like polyval() except that p is an matrix
% with the same number of rows as x 

function y = pvn3(p,x) 

  n = size(p,2);

  y = p(:,1);
  for k = 2:n
    y = y.*x + p(:,k);
  end 

end