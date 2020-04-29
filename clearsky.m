function [Iclr,sza] = clearsky(datetime_vector, lat, lon)
% CLEARSKY : Compute solar irradiance under clear sky condition
% USAGE: [Iclr] = clearsky(datetime_vector, lat, lon) %mapping toolbox required
%        [Iclr] = clearsky(datetime_vector, solar plant code)
% Iclr.ineichen is the irradiance from Ineichen model
% Iclr.kasten is the irradiance from Kasten model
% Iclr.ashrae model is the irradiance from ASHRAE model
% Iclr.robledo is the irradiance from Robledo-Soler model
% Iclr.haurwitz is the irradiance from Haurwitz model
% Iclr.berger is the irradiance from Berger-Duffie model
% Iclr.adnote is the irradiance from Adnote-Bourges-Campana-Gicquel model
% ####################### Useful location #################################
% solar plant code	"Latitude(degree decimal)"	"Longitude(degree decimal)"
%       eecu                 13.737                      100.532
%       ned                  15.053548                   100.893138
%       bcpg                 14.166891                   100.553708
%       ea_nsw               15.363907                   100.311733
%       ea_psl               17.078556                   100.117341
%       serm                 15.018762                   100.704178
%       spp6                 15.030656                   100.754572	
% developed by Sararut Pranonsatid (Feb 2020)
%Ref: Computing global and diffuse solar hourly irradiation on clearsky
%% Set location
solarplant_list = ["eecu", "ned", "bcpg", "ea_nsw", "ea_psl", "serm", "ssp6"];
switch nargin
    case 1 %Default location is EECU site
        lat = 13.737; %<<<<<<<<<<< latitude of EECU site (North +)
        lon = 100.532; %<<<<<<<<<<< longitude of EECU site (East +)  
    case 2
        if isa(lat, 'char')
            solarplant = lat;
            switch solarplant
                case 'eecu'
                    lat = 13.737; lon = 100.532;
                case 'ned'
                    lat = 15.053548; lon = 100.893138;
                case 'bcpg'
                    lat = 14.166891; lon = 100.553708;
                case 'ea_nsw'
                    lat = 15.363907; lon = 100.311733;
                case 'ea_psl'
                    lat = 17.078556; lon = 100.117341;
                case 'serm'
                    lat = 15.018762; lon = 100.704178;
                case 'spp6'
                    lat = 15.030656; lon = 100.754572;
                otherwise
                    error('Invalid solar plant code')
            end
        else
            error('Invalid input')
        end
    case 3 %Find nearest solar plant from the input location
        %find distance between input lat/lon and all plant
        wgs84 = wgs84Ellipsoid('kilometer');
        dist = distance('gc',[lat lon],[13.737 100.532;... 
        15.053548 100.893138; 14.166891 100.553708;15.363907 100.311733;...
        17.078556 100.117341; 15.018762 100.704178;15.030656 100.754572]...
        , wgs84);
    %gc means Great Circle distance for python : https://pypi.org/project/geopy/
        solarplant = solarplant_list( find(dist==min(dist)) );
        %disp(solarplant);
    otherwise
        error('Invalid input')
end

%% Parameters
Iclr.time = datetime_vector;
switch solarplant
    case 'eecu'
        alt = 35; % above mean sea level of the site in meters 
        TL1 = 7.422297874315465;
        TL2 = 10.195775953042700;
        K = 1663.52224574355;
        B = 0.739550805574049;
    case 'serm'
        alt = 40;
        K = 1561.37778996196;
        B= 0.514273047062970;
        TL1 = 2.73236019392741;
        TL2 = 3.28564425346629;
    case 'ned'
        alt = 35;
        K = 1395.27300681049;
        B = 0.471962649225552;
        TL1 = 3.39112534833096;
        TL2 = 4.25685763280593;
    case 'bcpg'
        alt = 35;
        K = 1266.96155393993;
        B = 0.633659540384103;
        TL1 = 9.28916296754953;
        TL2 = 12.9699001646807;
    case 'ea_nsw'
        alt = 35;
        K = 1516.67745960399;
        B = 0.549916730796064;
        TL1 = 4.22489470086748;
        TL2 = 5.46655928674312;
    case 'spp6'
        alt = 35;
        K = 1582.35095681632;
        B = 0.552831296153957;
        TL1 = 3.61692502373267;
        TL2 = 4.56693069046348;
end
%% physical parameter
Isc= 1366.1; % solar constant (Isc) = 1366.1 W/m^2

% cal solar zenith angle (sza)
% if the site is other locations, CAL_SZA needs a modification
[sza] = cal_sza(datetime_vector, lat, lon);
sza = abs(sza); % for day time theta is between 0 - 90, so sza is between 0-1
% for night time theta is between 90-180, so sza can be negative (should exclude night time data)

AM = 1./(sza + 0.50572*(96.07995-acosd(sza)).^-1.6364); % Kasten and Yung 1989 (Weather Modeling and forecasting of PV system operation)
%AM = 1./(sza+0.15*(93.885-acosd(sza)).^-1.253); % another formula of air mass (AM) refer to supachai thesis


%% Ineichen and Kasten models
% initial parameter of ineichen clear sky model & kasten clear sky model
f1 = exp(-alt/8000); 
f2 = exp(-alt/1250); 
a1 = (alt*5.09e-5)+0.868; 
a2 = (alt*3.92e-5)+0.0387; 

Iclr.ineichen = a1*Isc*sza.*exp(-a2*AM*(f1+f2*(TL1-1)));
Iclr.kasten = 0.84*Isc*sza.*exp(-0.027*AM*(f1+f2*(TL2-1)));
%% ASHRAE model
Iclr.ashrae = K.*exp(-B./sza);

%% Robledo-Soler model
Iclr.robledo = 1159.24.*(sza).^1.179.*exp(-0.0019.*(90-acosd(sza)));

%% Haurwitz model
Iclr.haurwitz = 1098.*sza.*exp(-0.057./sza);

%% Berger-Duffie model**
Iclr.berger = Isc*0.7*sza;

%% Adnote-Bourges-Campana-Gicquel model
Iclr.adnote = 951.39*(sza).^1.15;




