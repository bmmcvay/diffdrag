%% DIFFERENTIAL DRAG MANEUVERING FOR CLICK B/C
% Script to program an STK scenario to simulate CLICK-B & C as they go
% through their mission life of maneuvering. Start distance could be
% anywhere from 1 m to 25 km, depending on how bad the tumbling is. We want
% to demonstrate abilities between 25 and 580 km.
% Experiments will be run at 50 km, 100 km, 150 km, 200 km, and so on until
% we hit 550 km. Maybe try for 580, idk.
%
% Everything you actually need to edit is in the "variables" section.
% Hopefully.
%
% Disclaimer: I'm a terrible coder and I know it, so can it, okay?
% As long as it works...

%% variables
clear all

% Define the starting keplerian elements in a structure
startPosition.a = 6795.137;   % Semi-major axis (km)
startPosition.i = 51.6448;   % Inclination (degrees)
startPosition.e = 0.002243;   % Eccentricity (unitless)
startPosition.omega = 36.2327; % Right ascension of ascending node (RAAN) (degrees)
startPosition.w = 27.871;     % Argument of periapsis (degrees)
startPosition.vB = 332.3;    % True anomaly (degrees) (CLICK-B)
startPosition.vC = 332.2;    % True anomaly (degrees) (CLICK-C)
%Masses of satellite
dryMass = 6; %kg
fuelMass = 0; %kg
sphericalArea=0.06; %m^2 @@
% Dimensions of satellite (not counting solar panels)
Lx=0.3405378; %m
Ly=0.1; %m
Lz=0.1; %m
% Coordinates of ground stations
coords_awarua=[-46.5045 168.373]; %deg, formatted [lat,lon]
coords_puertollano=[38.6741 -4.16201];
coords_puntaarenas=[-52.9328 -70.8502];
% Start time & duration
currentTime = 1767225600; %Jan 1 2026
scenario_time_length = 6; %weeks
% Attitude & targetting times
deploymentTime=17280; %time spent in deployment phase, in seconds. Usually 2 weeks
targettingDuration=1800; %time spent targetting the other satellite for the experiment, in seconds. Usually 30 min
slewTime=90; %time spent slewing. avg rate is ~1 deg/sec, so I have it as 90 sec here.
slewRate=3; %max slew rate, deg/sec
% For MO1, use 42105 and 34211
% For MO2, use 160000 and 130000
periodHigh=42105; %time spent in the high drag configuration, in seconds
periodWait=34211; %time CLICK-C will spent waiting after B enters high drag to enter high drag itself, in seconds

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Open stk and initialize
try
    % Try to connect to an existing STK instance
    uiapp = actxGetRunningServer('STK13.Application');
catch
    % If none exists, create a new one
    uiapp = actxserver('STK13.Application');
end

uiapp.Visible = 1;
root = uiapp.Personality2;

% Check if the scenario already exists
if ~isempty(root.CurrentScenario)
    % Optionally close the current scenario before making a new one
    root.CloseScenario;
end

% Create new scenario
root.NewScenario('DiffDragModel');

% Set scenario properties
scenario = root.CurrentScenario;

%Convert Unix time to a time stamp
scenario_time_length=scenario_time_length*7*24*60*60; % convert to seconds
endTime = currentTime + scenario_time_length;
unixTimeStart = currentTime;
unixTimeStop = endTime;
startDate = datetime(unixTimeStart, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
startDateStr = datestr(startDate, 'dd mmm yyyy HH:MM:SS.FFF');
stopDate = datetime(unixTimeStop, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
stopDateStr = datestr(stopDate, 'dd mmm yyyy HH:MM:SS.FFF');
%Set the scenario time
scenario.SetTimePeriod(startDateStr, stopDateStr);
scenario.StartTime = startDateStr;
scenario.StopTime = stopDateStr;
scenario.Epoch = startDateStr;

%Make the window show the beginning of the scenario
root.Rewind;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make ground stations
awarua = scenario.Children.New('ePlace','Awarua');
awarua.Position.AssignGeodetic(coords_awarua(1),coords_awarua(2),0);
awarua.UseTerrain = true;
awarua.SetAzElMask('eTerrainData',0);
root.ExecuteCommand(['SetConstraint */Place/Awarua AzElMask On']); 

puertollano = scenario.Children.New('ePlace','Puertollano');
puertollano.Position.AssignGeodetic(coords_puertollano(1),coords_puertollano(2),0);
puertollano.UseTerrain = true;
puertollano.SetAzElMask('eTerrainData',0);
root.ExecuteCommand(['SetConstraint */Place/Puertollano AzElMask On']); 

puntaarenas = scenario.Children.New('ePlace','PuntaArenas');
puntaarenas.Position.AssignGeodetic(coords_puntaarenas(1),coords_puntaarenas(2),0);
puntaarenas.UseTerrain = true;
puntaarenas.SetAzElMask('eTerrainData',0);
root.ExecuteCommand(['SetConstraint */Place/PuntaArenas AzElMask On']); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make CLICK-B satellite
if scenario.Children.Contains('eSatellite', 'CLICK-B')
    scenario.Children.GetElements('eSatellite').Item('CLICK-B').Unload;
end

CLICKB = scenario.Children.New('eSatellite', 'CLICK-B');
CLICKB.SetPropagatorType('ePropagatorAstrogator');
driverB = CLICKB.Propagator;

% Configure Astrogator MCS
mcsB = driverB.MainSequence;
mcsB.RemoveAll;  % Clear default segments

% Insert Initial State segment using driverB
initStateB = driverB.MainSequence.Insert('eVASegmentTypeInitialState', 'InitialState', '-');
%Define other conditions
initStateB.SpacecraftParameters.DryMass = dryMass+fuelMass;
initStateB.FuelTank.FuelMass = fuelMass;
initStateB.SpacecraftParameters.DragArea = sphericalArea;
initStateB.SpacecraftParameters.SolarRadiationPressureArea = sphericalArea;
initStateB.SpacecraftParameters.RadiationPressureArea = sphericalArea;
% Set epoch to scenario start time
initStateB.InitialState.Epoch = scenario.StartTime;
% Define orbital elements
initStateB.SetElementType('eVAElementTypekeplerian');
kepB = initStateB.Element;
kepB.SemiMajorAxis = startPosition.a;  %km
kepB.Eccentricity = startPosition.e;
kepB.Inclination = startPosition.i;             % deg
kepB.RAAN = startPosition.omega;                    % deg
kepB.TrueAnomaly = startPosition.vB;             % deg
kepB.ArgOfPeriapsis = startPosition.w;          % deg
% Sequence
dTB = driverB.MainSequence.Insert('eVASegmentTypePropagate', 'Propagate', '-');
dTB.PropagatorName = 'EDHFv13 n-plate with solar panels (updated)';
dTB.Properties.Color = 65280;  % green
dTB.StoppingConditions.Item('Duration').Properties.Trip = scenario_time_length;

% Model
modelB = CLICKB.VO.Model;
modelB.ModelData.Filename = 'STKData\VO\Models\Space\cubesat_3u_four_panel.glb';

% Mass/MOI
moiB=CLICKB.MassProperties.Inertia;
moiB.Ixx=dryMass/12*(Ly^2+Lz^2); %kgm^2
moiB.Iyy=dryMass/12*(Lx^2+Lz^2); %kgm^2
moiB.Izz=dryMass/12*(Lx^2+Ly^2); %kgm^2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make CLICK-C satellite
if scenario.Children.Contains('eSatellite', 'CLICK-C')
    scenario.Children.GetElements('eSatellite').Item('CLICK-C').Unload;
end

CLICKC = scenario.Children.New('eSatellite', 'CLICK-C');
CLICKC.SetPropagatorType('ePropagatorAstrogator');
driverC = CLICKC.Propagator;

% Configure Astrogator MCS
mcsC = driverC.MainSequence;
mcsC.RemoveAll;  % Clear default segments

% Insert Initial State segment using driverC
initStateC = driverC.MainSequence.Insert('eVASegmentTypeInitialState', 'InitialState', '-');

%Define other conditions
initStateC.SpacecraftParameters.DryMass = dryMass+fuelMass;
initStateC.FuelTank.FuelMass = fuelMass;
initStateC.SpacecraftParameters.DragArea = sphericalArea;
initStateC.SpacecraftParameters.SolarRadiationPressureArea = sphericalArea;
initStateC.SpacecraftParameters.RadiationPressureArea = sphericalArea;

% Set epoch to scenario start time
initStateC.InitialState.Epoch = scenario.StartTime;

% Define orbital elements
initStateC.SetElementType('eVAElementTypekeplerian');
kepC = initStateC.Element;
kepC.SemiMajorAxis = startPosition.a;  %km
kepC.Eccentricity = startPosition.e;
kepC.Inclination = startPosition.i;             % deg
kepC.RAAN = startPosition.omega;                    % deg
kepC.TrueAnomaly = startPosition.vC;             % deg
kepC.ArgOfPeriapsis = startPosition.w;          % deg

% Sequence
dTC = driverC.MainSequence.Insert('eVASegmentTypePropagate', 'Propagate', '-');
dTC.PropagatorName = 'EDHFv13 n-plate with solar panels (updated)';
dTC.Properties.Color = 255;  % red
dTC.StoppingConditions.Item('Duration').Properties.Trip = scenario_time_length;

% Model
modelC = CLICKC.VO.Model;
modelC.ModelData.Filename = 'STKData\VO\Models\Space\cubesat_3u_four_panel.glb';

% Mass/MOI
moiC=CLICKB.MassProperties.Inertia;
moiC.Ixx=dryMass/12*(Ly^2+Lz^2); %kgm^2
moiC.Iyy=dryMass/12*(Lx^2+Lz^2); %kgm^2
moiC.Izz=dryMass/12*(Lx^2+Ly^2); %kgm^2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Duplicate CLICK-C so that the targetting sequence doesn't have circular logic

CLICKCtargetobject = scenario.Children.CopyObject(CLICKC, 'CLICK-Ctargetobject');
driverCto = CLICKCtargetobject.Propagator;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Preliminary run to establish basic orbit

driverB.RunMCS;
driverC.RunMCS;
driverCto.RunMCS;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find eclipse intervals

[startTimes, stopTimes,endofdeployment]=findEclipseIntervals(root,scenario,deploymentTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial attitude configuration

% This will need to be done for both sats (and targetobject)
satName='CLICK-B';
followersatName='CLICK-C';
dupesatName='CLICK-Ctargetobject'; %this one legit just copies everything C does except the pointing

% Set the initial deployment status (tumbling)
deploymentB=append('SetAttitude */Satellite/', satName,' Profile SpinSun 0.0 0.0 "',startDateStr,'"');
root.ExecuteCommand(deploymentB);
deploymentCto=append('SetAttitude */Satellite/', dupesatName,' Profile SpinSun 0.0 0.0 "',startDateStr,'"');
root.ExecuteCommand(deploymentCto);
deploymentC=append('SetAttitude */Satellite/', followersatName,' Profile SpinSun 0.0 0.0 "',startDateStr,'"');
root.ExecuteCommand(deploymentC); %ideally this would be tumbling, but start in sun pointing for deployment

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Maneuver Option 1:
% Maintain sun pointing only when s/c is in sunlight. In eclipse, s/c
% maneuvers to high drag configuration.
maneuver1(root,startTimes,stopTimes,periodHigh,periodWait,satName,followersatName,dupesatName,slewTime,slewRate,startDateStr,stopDateStr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Maneuver Option 2:
% Maintain sun pointing at all times, rotating the s/c body around solar
% panel normal to create high/low drag configurations
% maneuver2(root,satName,followersatName,dupesatName,deploymentTime,endofdeployment,periodHigh,periodWait,startDateStr,stopDateStr,slewTime,slewRate,targettingDuration);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN THAT HOE
driverB.RunMCS;
driverC.RunMCS;
driverCto.RunMCS;
beep % So you can multitask while it's running!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Rerun eclipse interval calcs now that we have preliminary maneuver plan
% [startTimes, stopTimes]=findEclipseIntervals(root,scenario,deploymentTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ...and recalculate the maneuvers. Shouldn't change much