function [sza, datetime_vector] = cal_sza(datetime_vector, phi, lon)
% sza = cal_sza(datetime_vector, lat, long) , sza = cal_sza(datetime_vector, solarplant code)
% CAL_SZA calculates the solar zenith angle according to the day of year
% datetime_vector: is a date time vector (see format in MATLAB)
% lat, long are latitude and longitude of the plant in degree (North + /East +)
% sza: the solar zenith angle (radian)
% developped by Supachai Suksamosorn (Mar 2019), Sararut Pranonsatid (Feb 2020)
% The mathematical formula can be chekced from Supachai thesis (attached):
% formula_sza.pdf
% ####################### Useful location #################################
% solar plant code	"Latitude(degree decimal)"	"Longitude(degree decimal)"
%       eecu                 13.737                      100.532
%       ned                  15.053548                   100.893138
%       bcpg                 14.166891                   100.553708
%       ea_nsw               15.363907                   100.311733
%       ea_psl               17.078556                   100.117341
%       serm                 15.018762                   100.704178
%       spp6                 15.030656                   100.754572		
	
%% %% Set default value
switch nargin
    case 1 %default location : EECU site
        phi = 13.737; %<<<<<<<<<<< latitude of EECU site (North +)
        lon = 100.532; %<<<<<<<<<<< longitude of EECU site (East +)  
    case 2
        if isa(phi, 'char')
            solarplant = phi;
            switch solarplant
                case 'eecu'
                    phi = 13.737; lon = 100.532;
                case 'ned'
                    phi = 15.053548; lon = 100.893138;
                case 'bcpg'
                    phi = 14.166891; lon = 100.553708;
                case 'ea_nsw'
                    phi = 15.363907; lon = 100.311733;
                case 'ea_psl'
                    phi = 17.078556; lon = 100.117341;
                case 'serm'
                    phi = 15.018762; lon = 100.704178;
                case 'spp6'
                    phi = 15.030656; lon = 100.754572;
                otherwise
                    error('Invalid solar plant code')
            end
        else
            error('Invalid input')
        end
    case 3
    otherwise
        error('Invalid input')
end
%% cal solar zenith angle (sza)
doy =day(datetime_vector,'dayofyear');
theta = 2*pi*(doy-1)/365;
delta = (0.006918-0.399912*cos(theta)+0.070257*sin(theta)-0.006759*cos(2*theta)+0.000907*sin(2*theta)-0.002697*cos(3*theta)+0.00148*sin(3*theta))*(180/pi); %solar declination in rad (angle between the sun and equator at noon) 
time_vector = hour(datetime_vector)+minute(datetime_vector)/60; %cal solar hour
et = 9.87*sin(2*2*pi*(doy-81)/364)-7.53*cos(2*pi*(doy-81)/364)-1.5*sin(2*pi*(doy-81)/364); %cal equation of time
omega = abs(time_vector+(et/60)-((105-lon)/15)-12)*15; %angular of solar time in degree (15 degree = 1 hour)
sza = cosd(phi)*cosd(delta).*cosd(omega)+sind(phi)*sind(delta); %solar zenith angle (sza)= cos\theta(t)

% the following options have no significant difference
% alternate formula for DECLINATION ANGLE (delta): unit in degree
% DECLINATION1 = -23.45*(cosd((360/365)*(doy+10)));
% DECLINATION2 = 23.45*(sind((360/365)*(doy+284)));
% DECLINATION3 = 23.45*(sind((360/365)*(doy-81)));
% plot(doy,delta,doy,DECLINATION1,doy,DECLINATION2,doy,DECLINATION3);

end
