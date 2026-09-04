function maneuver2(root,satName,followersatName,dupesatName,deploymentTime,endofdeployment,periodHigh,periodWait,startDateStr,stopDateStr,slewTime,slewRate,targettingDuration)
    totalHighTime=0;
    totalLowTime=0;
    totalHighTimeC=0;
    totalPointingTime=0;
    firstTimeB=true;
    firstTimeC=true;
    begin_seconds=deploymentTime;
    begin_utc=endofdeployment;

    for i=1:9 %@@

        % B maneuvers to high drag
        time_slew2highB=begin_utc;
        time_highB=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+slewTime));
        time_slew2lowB=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+slewTime+periodHigh));
        time_lowB=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+2*slewTime+periodHigh));
        sunPointing_highDragManeuver(root,satName,time_slew2highB,time_highB,time_slew2lowB,time_lowB);

        % ... while C maneuvers to low
        slew2low=append('AddAttitude */Satellite/', followersatName,' Profile "',time_slew2highB,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2low);
        low=append('AddAttitude */Satellite/', followersatName,' Profile "',time_highB,'" AlignConstrain Axis 0 0 1 "Satellite/', followersatName,' Sun" Axis 1 0 0 "Satellite/', followersatName,' Velocity"');
        root.ExecuteCommand(low);

        % C maneuvers to high drag after wait period is over
        time_slew2highC=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+periodWait));
        time_highC=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+periodWait+slewTime));
        time_slew2lowC=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+periodWait+slewTime+periodHigh));
        time_lowC=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(begin_seconds+periodWait+2*slewTime+periodHigh));
        sunPointing_highDragManeuver(root,followersatName,time_slew2highC,time_highC,time_slew2lowC,time_lowC);

        % Both perform targetting for experiment after C is done
        maneuveringCompleteTime=begin_seconds+periodWait+2*slewTime+periodHigh;
        time_experimentstart=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(maneuveringCompleteTime));
        time_experimentend=root.ConversionUtility.ConvertDate('EpSec','UTCG',num2str(maneuveringCompleteTime+targettingDuration));
        firstTimeB=experimentManeuver(root,satName,dupesatName,time_experimentstart,time_experimentend,slewTime,slewRate,startDateStr,stopDateStr,firstTimeB);
        firstTimeC=experimentManeuver(root,followersatName,satName,time_experimentstart,time_experimentend,slewTime,slewRate,startDateStr,stopDateStr,firstTimeC);
       
        begin_utc=time_experimentend;
        begin_seconds=str2num(root.ConversionUtility.ConvertDate('UTCG','EpSec',begin_utc));
    end
end