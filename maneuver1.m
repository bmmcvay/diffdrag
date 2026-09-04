function maneuver1(root,startTimes,stopTimes,periodHigh,periodWait,satName,followersatName,dupesatName,slewTime,slewRate,startDateStr,stopDateStr)
    totalHighTime=0;
    totalLowTime=0;
    totalHighTimeC=0;
    totalPointingTime=0;
    firstTimeB=true;
    firstTimeC=true;
    for i=1:length(startTimes)
    
        % Get the dates/times to maneuver during the eclipse interval
        time_slewout=startTimes{i};
        time_out=datestr(datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')+seconds(slewTime));
        time_slewin=datestr(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-seconds(slewTime));
        time_in=stopTimes{i};
        
        % Now, maneuver using those times
        if totalHighTime<periodHigh
    
            %if LEADER hasn't been in high drag for long enough, maneuver to high drag
            highDragManeuver(root,satName,time_slewout,time_out,time_slewin,time_in);
    
            %...while FOLLOWER maneuvers based on wait time
            if (totalHighTime+totalLowTime)>=periodWait
    
                %after the wait period, FOLLOWER starts maneuvering
                if totalHighTimeC<periodHigh
                    %if FOLLOWER hasn't been in high drag for long enough, maneuver to high drag
                    highDragManeuver(root,followersatName,time_slewout,time_out,time_slewin,time_in);
                    highDragManeuver(root,dupesatName,time_slewout,time_out,time_slewin,time_in); %TO
                    totalHighTimeC=totalHighTimeC+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
                else
                    %if FOLLOWER's finished with high drag, run the experiment and reset all high/low time counters
                    firstTimeB=experimentManeuver(root,satName,dupesatName,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr,firstTimeB);
                    firstTimeC=experimentManeuver(root,followersatName,satName,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr,firstTimeC);
                    totalPointingTime=totalPointingTime+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
                    totalHighTime=0;
                    totalLowTime=0;
                    totalHighTimeC=0;
                end
            else
                %if still in wait period, FOLLOWER maneuvers to low drag
                lowDragManeuver(root,followersatName,time_slewout,time_out,time_slewin,time_in);
                lowDragManeuver(root,dupesatName,time_slewout,time_out,time_slewin,time_in);
            end
    
            %update LEADER's high drag time
            totalHighTime=totalHighTime+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
        
        else
            %if LEADER's finished with high drag, maneuver to low drag
            lowDragManeuver(root,satName,time_slewout,time_out,time_slewin,time_in);
            
            %FOLLOWER maneuvers in low drag
            if (totalHighTime+totalLowTime)>=periodWait
                %after the wait period, FOLLOWER starts maneuvering
                if totalHighTimeC<periodHigh
                    %if FOLLOWER hasn't been in high drag for long enough, maneuver to high drag
                    highDragManeuver(root,followersatName,time_slewout,time_out,time_slewin,time_in);
                    highDragManeuver(root,dupesatName,time_slewout,time_out,time_slewin,time_in); %TO
                    totalHighTimeC=totalHighTimeC+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
                else
                    %if FOLLOWER's finished with high drag, run the experiment and reset all high/low time counters
                    firstTimeB=experimentManeuver(root,satName,dupesatName,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr,firstTimeB);
                    firstTimeC=experimentManeuver(root,followersatName,satName,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr,firstTimeC);
                    totalPointingTime=totalPointingTime+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
                    totalHighTime=0;
                    totalLowTime=0;
                    totalHighTimeC=0;
                end
            else
                %if still in wait period, FOLLOWER maneuvers to low drag
                lowDragManeuver(root,followersatName,time_slewout,time_out,time_slewin,time_in);
                lowDragManeuver(root,dupesatName,time_slewout,time_out,time_slewin,time_in);
            end
    
            %update LEADER's low drag time
            totalLowTime=totalLowTime+seconds(datetime(stopTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS')-datetime(startTimes{i},'InputFormat','dd MMM yyyy HH:mm:ss.SSS'))-1;
        end
    end
end