% QUANTUM NOISE  Quantum noise in a Fabry-Perot Michelson interferometer
%
% [total, shot, radp] = quantum_noise(f, m, P, F, L, lambda, units)
%
% f : frequency vector [Hz]
% m : mass of each test mass [kg]
% P : power at the beamsplitter [W]
% F : finesse
% L : length of arm [m] - used to get cavity pole
% lambda: wavelength [m]
% units: 'm' or 'Hz'

% Tobin Fricke - 2012-10-04

function [total, shot, radp] = quantum_noise(f, m, P, F, L, varargin)
h = 6.6261e-34;  % Planck's constant [J*s] 
c = 299792458;   % Speed of light    [m/s]

if ~isempty(varargin)
    lambda = varargin{1};
    varargin(1) = [];
else
    lambda = 1064e-9;  % default to 1064 nm
end

if ~isempty(varargin)
    units = varargin{1};
    varargin(1) = [];  %#ok<NASGU>
else
    units = 'm';  % default to meters/rtHz
end

nu = c / lambda; % optical frequency [Hz]

omega = 2*pi*f;

% I just made this up, so it might not be right:
radp = (128/c) * sqrt((3/2)*  h * c * F * P / (pi * lambda)) ./ (m * omega.^2);

% Shot noise formula is from http://arxiv.org/abs/1110.2815 (DC Readout):
shot = (1/4) * sqrt(lambda* h * c / (2 * P)) * (1/F) * abs(1 + 1i * 4 * F * L .* f / c);

switch units,
    case 'm',
        % already in meters - do nothing
    case 'h',
        % convert to strain
        radp = radp / L;
        shot = shot / L;
    case 'Hz',
        % L / lambda = constant  ==>  d nu / d L = - nu / L
        radp = radp * nu / L;
        shot = shot * nu / L;
    otherwise
        error('unknown unit')
end

total = sqrt(radp.^2 + shot.^2);
