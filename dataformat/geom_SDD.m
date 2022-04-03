function SDD = geom_SDD(pixel_size, wavelength, standard_q, standard_x)
% SDD = geom_SDD(pixel_size, wavelength, standard_q, standard_x)
% standard_q (unit : Angstrom)
% wavelength (unit : Angstrom)
% pixel_size (unit : um)
% SDD (unit : mm)

SDD = pixel_size/1000.*standard_x./tan(2*asin(standard_q.*wavelength/4/pi));