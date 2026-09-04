function [startTimes, stopTimes]=betaAngles(root)
    sat = root.GetObjectFromPath('Satellite/CLICK-B');
    
    %% Beta angles over time
    % Access the Beta Angle data provider
    betaDP = sat.DataProviders.Item('Beta Angle');
    % Execute over scenario duration (Interval data provider type)
    step=600; %timestep (s)
    result = betaDP.Exec(scenario.StartTime, scenario.StopTime,step);
    % Extract time
    time = result.DataSets.GetDataSetByName('Time').GetValues;
    % Extract beta angle dataset
    betas = result.DataSets.GetDataSetByName('Beta Angle').GetValues;
    betamat=cell2mat(betas);
    timemat=datetime(time,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    figure
    plot(timemat,betamat);
    ylabel("degrees")
    title('Beta angles over time');
    
    %% Sun vector over time
    % Access the Sun Vector data provider
    sunvecDP = sat.DataProviders.Item('Sun Vector').Group.Item('Fixed'); %@@ how do the "fixed" axes work?
    % Execute over scenario duration (Interval data provider type)
    step=600; %timestep (s)
    result2 = sunvecDP.Exec(scenario.StartTime, scenario.StopTime,step);
    % Extract sun vector components
    sunvecX = result2.DataSets.GetDataSetByName('x').GetValues;
    sunvecY = result2.DataSets.GetDataSetByName('y').GetValues;
    sunvecZ = result2.DataSets.GetDataSetByName('z').GetValues;
    % animated vector plot
    for i=1:length(sunvecX)
        sunvectors(i,1:3)=[sunvecX{i,1},sunvecY{i,1},sunvecZ{i,1}];
        sunvectors(i,1:3)=sunvectors(i,1:3)/norm(sunvectors(i,1:3));
        quiver3(0,0,0,sunvectors(i,1),sunvectors(i,2),sunvectors(i,3));
        xlim([-1,1]);ylim([-1,1]);zlim([-1,1]);
        drawnow;
    end
    %@@ ideally this should be using Solar Panel Angles, why doesn't that work?

    %% Final altitude
    % Access the COEs data provider
    coeDP = sat.DataProviders.Item('Classical Elements').Group.Item('J2000'); %@@ which coordsystem?
    % Execute over scenario duration (Interval data provider type)
    step=600; %timestep (s)
    result3=coeDP.Exec(scenario.StartTime, scenario.StopTime,step);
    % pull datetime values for each timestep from STK
    time3 = result3.DataSets.GetDataSetByName('Time').GetValues;
    % Extract sun vector components
    semimaj=cell2mat(result3.DataSets.GetDataSetByName('Semi-major Axis').GetValues);
    ecc=cell2mat(result3.DataSets.GetDataSetByName('Eccentricity').GetValues);
    truanom=cell2mat(result3.DataSets.GetDataSetByName('True Anomaly').GetValues);
    p=semimaj.*(1-ecc.^2);
    alt=p./(1+ecc.*cosd(truanom))-6378.137; %km
    timemat3=datetime(time3,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    figure
    plot(timemat3,alt);
    ylabel('km')
    title('Altitude over time');

    %% get angle between orbit velocity and body Z axis (solar panel normal)
    velbodyDP = sat.DataProviders.Item('Vectors(Body)').Group.Item('Velocity');
    step=600; %timestep (s)
    result4 = velbodyDP.Exec(scenario.StartTime, scenario.StopTime,step);
    % pull datetime values for each timestep from STK
    time4 = result4.DataSets.GetDataSetByName('Time').GetValues;
    % pull unit vector velocity in body frame from STK
    velX = result4.DataSets.GetDataSetByName('x/Magnitude').GetValues;
    velY = result4.DataSets.GetDataSetByName('y/Magnitude').GetValues;
    velZ = result4.DataSets.GetDataSetByName('z/Magnitude').GetValues;
    % put it into a single array instead of multiple cell
    for i=1:length(velX)
        velInBodyFrame(i,1:3)=abs([velX{i,1},velY{i,1},velZ{i,1}]);
    end
    % scalar drag areas for each axis
    Lpanel=0.4532884;
    xDragArea=Ly*Lz; %m^2
    yDragArea=Lx*Lz; %m^2
    zDragArea=Lpanel*Lx; %dimensions from datasheet, m^2
    % calculate drag area wrt velocity vector
    % totalDragArea=dot(velInBodyFrame(1,:),[1;0;0])*xDragArea;
    dragAreaX=velInBodyFrame(:,1)*xDragArea;
    dragAreaY=velInBodyFrame(:,2)*yDragArea;
    dragAreaZ=velInBodyFrame(:,3)*zDragArea; %high drag face, it has the solar panels
    totalDragArea=dragAreaX+dragAreaY+dragAreaZ; %this is how projections work right? %@@
    timemat4=datetime(time4,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    figure;plot(timemat4,totalDragArea);title("Total drag area, m^2");
    %%
    %testing for drag area
    points=[-Lx/2 -Lx/2 -Lx/2 -Lx/2 Lx/2 Lx/2 Lx/2 Lx/2 Lx/2 Lx/2 -Lx/2 -Lx/2;Ly/2 -Ly/2 Ly/2 -Ly/2 Ly/2 -Ly/2 Ly/2 -Ly/2 Lpanel/2 -Lpanel/2 Lpanel/2 -Lpanel/2;Lz/2 Lz/2 -Lz/2 -Lz/2 Lz/2 Lz/2 -Lz/2 -Lz/2 0 0 0 0];
    plot3(points(1,:),points(2,:),points(3,:),'o','Color','b','MarkerSize',5,'MarkerFaceColor','#D9FFFF');
    xlabel("x");ylabel("y");zlabel("z");
    hold on
    for i=1:length(points)
        newpoints(1:3,i)=dot(points(:,i),velInBodyFrame(1,:))*velInBodyFrame(1,:);
    end
    plot3(newpoints(1,:),newpoints(2,:),newpoints(3,:),'o','Color','r','MarkerSize',5,'MarkerFaceColor','#E7FFFF');
end