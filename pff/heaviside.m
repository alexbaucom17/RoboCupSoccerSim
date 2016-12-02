function Y = heaviside(X)
%HEAVISIDE    Copied and modified from matlab file since symbolic toolbox
%is not available in compiler

Y = zeros(size(X),'like',X);
Y(X > 0) = 1;
if any(X(:)==0)
  Y(X==0) = 0.5;
end
Y(isnan(X) | imag(X) ~= 0 ) = NaN;
