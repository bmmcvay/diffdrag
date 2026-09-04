function [startTimes, stopTimes, endofdeployment]=findEclipseIntervals(root,scenario,deploymentTime)
    sat = root.GetObjectFromPath('Satellite/CLICK-B');
    
    % Access the Eclipse Times data provider
    eclipseDP = sat.DataProviders.Item('Eclipse Times');
    
    % Execute over scenario duration (Interval data provider type)
    result = eclipseDP.Exec(scenario.StartTime, scenario.StopTime);
    
    % Extract start and stop time datasets
    startTimes = result.DataSets.GetDataSetByName('Start Time').GetValues;
    stopTimes  = result.DataSets.GetDataSetByName('Stop Time').GetValues;
    
    % Delete weird bugged duplicate dates. This is very ungraceful but shhh
    k=1;
    for i=1:length(startTimes)
        for j=1:length(stopTimes)
            if isequal(startTimes{i},stopTimes{j})
                badstartindex(k,1)=i;
                badstopindex(k,1)=j;
                k=k+1;
            end
        end
    end
    for i=1:length(badstartindex)
        badstartTimes{i,1}=startTimes{badstartindex(i)};
        badstopTimes{i,1}=stopTimes{badstopindex(i)};
    end
    startTimes=setdiff(startTimes,badstartTimes,'stable');
    stopTimes=setdiff(stopTimes,badstopTimes,'stable');
    
    % Cut off all eclipse intervals from before when ops can start
    endofdeployment=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(deploymentTime)); %UTC time that satellite is ready to start operations
    maneuverStartindex=datetime(startTimes,'InputFormat','dd MMM yyyy HH:mm:ss.SSS')>=datetime(endofdeployment,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    maneuverStopindex=datetime(stopTimes,'InputFormat','dd MMM yyyy HH:mm:ss.SSS')>=datetime(endofdeployment,'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    startTimes=startTimes(maneuverStartindex);
    stopTimes=stopTimes(maneuverStopindex);
    %make sure the first stop time isn't before the first start time
    firstStopindex=datetime(stopTimes,'InputFormat','dd MMM yyyy HH:mm:ss.SSS')>=datetime(startTimes{1},'InputFormat','dd MMM yyyy HH:mm:ss.SSS');
    stopTimes=stopTimes(firstStopindex);
end