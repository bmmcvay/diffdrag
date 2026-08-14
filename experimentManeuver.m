function experimentManeuver(root,satName,sat2Name,time_out,time_slewin,slewTime,slewRate,startDateStr,stopDateStr)
% Use the payload. Run the experiment. Targetting targetting Space lasers are a-go. 
    addTarget=append('SetAttitude */Satellite/', satName,' Target Add Satellite/',sat2Name);
    root.ExecuteCommand(addTarget);
    accessOff=append('SetAttitude */Satellite/', satName,' Target Times UseAccess Off');
    root.ExecuteCommand(accessOff);
    removeDefault=append('SetAttitude */Satellite/', satName,' Target Times Remove Satellite/', sat2Name,' "',startDateStr,'" "',stopDateStr,'"');
    root.ExecuteCommand(removeDefault);
    scheduleTimes=append('SetAttitude */Satellite/', satName,' Target Times Add Satellite/', sat2Name,' "',time_out,'" "',time_slewin,'"');
    root.ExecuteCommand(scheduleTimes);
    slewsettings=append('SetAttitude */Satellite/', satName,' Target Slew Mode FixedRate MaxSlewTime ',num2str(slewTime),' SlewTimingBetweenTgts SlewAfterTargetAcq RateMagnitude ',num2str(slewRate));
    root.ExecuteCommand(slewsettings);
    if satName=='CLICK-B'
        changeAxis=append('SetAttitude */Satellite/', satName,' Target BodyVectors Satellite/', sat2Name,' Axis 0.0 0.0 1.0 Axis 1.0 0.0 0.0');
    elseif satName=='CLICK-C'
        changeAxis=append('SetAttitude */Satellite/', satName,' Target BodyVectors Satellite/', sat2Name,' Axis 1.0 0.0 0.0 Axis 0.0 0.0 -1.0');
    end
    root.ExecuteCommand(changeAxis);
end