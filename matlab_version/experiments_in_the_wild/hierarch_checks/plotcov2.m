% PLOTCOV2 - Plots a covariance ellipse with major and minor axes
%            for a bivariate Gaussian distribution.
%
% Usage:
%   h = plotcov2(mu, Sigma[, OPTIONS]);
% 
% Inputs:
%   mu    - a 2 x 1 vector giving the mean of the distribution.
%   Sigma - a 2 x 2 symmetric positive semi-definite matrix giving
%           the covariance of the distribution (or the zero matrix).
%
% Options:
%   'conf'    - a scalar between 0 and 1 giving the confidence
%               interval (i.e., the fraction of probability mass to
%               be enclosed by the ellipse); default is 0.9.
%   'num-pts' - the number of points to be used to plot the
%               ellipse; default is 100.
%
% This function also accepts options for PLOT.
%
% Outputs:
%   h     - a vector of figure handles to the ellipse boundary and
%           its major and minor axes
%
% See also: PLOTCOV3

% Copyright (C) 2002 Mark A. Paskin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function h = plotcov2(mu, Sigma, varargin)

if size(Sigma) ~= [2 2], error('Sigma must be a 2 by 2 matrix'); end
if length(mu) ~= 2, error('mu must be a 2 by 1 vector'); end

[p, ...
 n, ...
 plot_opts] = process_options(varargin, 'conf', 0.9, ...
					'num-pts', 100);
h = [];
holding = ishold;
if (Sigma == zeros(2, 2))
  z = mu;
else
  % Compute the Mahalanobis radius of the ellipsoid that encloses
  % the desired probability mass.
  k = conf2mahal(p, 2);
  % The major and minor axes of the covariance ellipse are given by
  % the eigenvectors of the covariance matrix.  Their lengths (for
  % the ellipse with unit Mahalanobis radius) are given by the
  % square roots of the corresponding eigenvalues.
  if (issparse(Sigma))
    [V, D] = eigs(Sigma);
  else
    [V, D] = eig(Sigma);
  end
  % Compute the points on the surface of the ellipse.
  t = linspace(0, 2*pi, n);
  u = [cos(t); sin(t)];
  w = (k * V * sqrt(D)) * u;
  z = repmat(mu, [1 n]) + w;
  % Plot the major and minor axes.
  L = k * sqrt(diag(D));
  h = plot([mu(1); mu(1) + L(1) * V(1, 1)], ...
	   [mu(2); mu(2) + L(1) * V(2, 1)], plot_opts{:});
  hold on;
  h = [h; plot([mu(1); mu(1) + L(2) * V(1, 2)], ...
	       [mu(2); mu(2) + L(2) * V(2, 2)], plot_opts{:})];
end

h = [h; plot(z(1, :), z(2, :), plot_opts{:})];
if (~holding) hold off; end
end

function [varargout] = process_options(args, varargin)

% Check the number of input arguments
n = length(varargin);
if (mod(n, 2))
  error('Each option must be a string/value pair.');
end

% Check the number of supplied output arguments
if (nargout < (n / 2))
  error('Insufficient number of output arguments given');
elseif (nargout == (n / 2))
  warn = 1;
  nout = n / 2;
else
  warn = 0;
  nout = n / 2 + 1;
end

% Set outputs to be defaults
varargout = cell(1, nout);
for i=2:2:n
  varargout{i/2} = varargin{i};
end

% Now process all arguments
nunused = 0;
for i=1:2:length(args)
  found = 0;
  for j=1:2:n
    if strcmpi(args{i}, varargin{j})
      varargout{(j + 1)/2} = args{i + 1};
      found = 1;
      break;
    end
  end
  if (~found)
    if (warn)
      warning(sprintf('Option ''%s'' not used.', args{i}));
      args{i}
    else
      nunused = nunused + 1;
      unused{2 * nunused - 1} = args{i};
      unused{2 * nunused} = args{i + 1};
    end
  end
end

% Assign the unused arguments
if (~warn)
  if (nunused)
    varargout{nout} = unused;
  else
    varargout{nout} = cell(0);
  end
end
end

% CONF2MAHAL - Translates a confidence interval to a Mahalanobis
%              distance.  Consider a multivariate Gaussian
%              distribution of the form
%
%   p(x) = 1/sqrt((2 * pi)^d * det(C)) * exp((-1/2) * MD(x, m, inv(C)))
%
%              where MD(x, m, P) is the Mahalanobis distance from x
%              to m under P:
%
%                 MD(x, m, P) = (x - m) * P * (x - m)'
%
%              A particular Mahalanobis distance k identifies an
%              ellipsoid centered at the mean of the distribution.
%              The confidence interval associated with this ellipsoid
%              is the probability mass enclosed by it.  Similarly,
%              a particular confidence interval uniquely determines
%              an ellipsoid with a fixed Mahalanobis distance.
%
%              If X is an d dimensional Gaussian-distributed vector,
%              then the Mahalanobis distance of X is distributed
%              according to the Chi-squared distribution with d
%              degrees of freedom.  Thus, the Mahalanobis distance is
%              determined by evaluating the inverse cumulative
%              distribution function of the chi squared distribution
%              up to the confidence value.
%
% Usage:
% 
%   m = conf2mahal(c, d);
%
% Inputs:
%
%   c    - the confidence interval
%   d    - the number of dimensions of the Gaussian distribution
%
% Outputs:
%
%   m    - the Mahalanobis radius of the ellipsoid enclosing the
%          fraction c of the distribution's probability mass
%
% See also: MAHAL2CONF

% Copyright (C) 2002 Mark A. Paskin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function m = conf2mahal(c, d)

m = chi2inv(c, d);
% pr = 0.95 ; c = (1 - pr)/2 ; 
% m = norminv([c 1-c],0,1) ;

end