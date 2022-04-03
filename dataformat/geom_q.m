function qx = geom_q(x, pixel_size, wavelength, SDD)
% qx = geom_q(x, pixel_size, wavelength, SDD)
% wavelength (unit : Angstrom)
% pixel_size (unit : um)
% SDD (unit : mm)
% qx (unit : A-1) 
%
% x should start from 0 : center position of beam is 0
%pixel_size = pixel_size;
%SDD = SDD;
%wavelength = wavelength;

qx = 4*pi/wavelength*sin(1/2*atan(pixel_size/1000.*x./SDD));