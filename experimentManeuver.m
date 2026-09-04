function firstTime=experimentManeuver(root,satName,sat2Name,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr,firstTime)
% Use the payload. Run the experiment. Targetting targetting Space lasers are a-go. 
    if firstTime==true
        % on the first run only, initialize the target
        addTarget=append('SetAttitude */Satellite/', satName,' Target Add Satellite/',sat2Name);
        root.ExecuteCommand(addTarget);
        accessOff=append('SetAttitude */Satellite/', satName,' Target Times UseAccess Off');
        root.ExecuteCommand(accessOff);
        removeDefault=append('SetAttitude */Satellite/', satName,' Target Times Remove Satellite/', sat2Name,' "',startDateStr,'" "',stopDateStr,'"');
        root.ExecuteCommand(removeDefault);
        slewsettings=append('SetAttitude */Satellite/', satName,' Target Slew Mode FixedRate MaxSlewTime ',num2str(slewTime),' SlewTimingBetweenTgts SlewAfterTargetAcq RateMagnitude ',num2str(slewRate));
        root.ExecuteCommand(slewsettings);
        if satName=='CLICK-B'
            changeAxis=append('SetAttitude */Satellite/', satName,' Target BodyVectors Satellite/', sat2Name,' Axis 1.0 0.0 0.0 Axis 0.0 0.0 1.0');
        elseif satName=='CLICK-C'
            changeAxis=append('SetAttitude */Satellite/', satName,' Target BodyVectors Satellite/', sat2Name,' Axis 1.0 0.0 0.0 Axis 0.0 0.0 -1.0');
        end
        root.ExecuteCommand(changeAxis);
        firstTime=false;
    end
    % otherwise just add the time intervals
    scheduleTimes=append('SetAttitude */Satellite/', satName,' Target Times Add Satellite/', sat2Name,' "',time_out,'" "',time_slewin,'"');
    root.ExecuteCommand(scheduleTimes);
end