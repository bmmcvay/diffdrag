function lowDragManeuver(root,satName,time_slewout,time_out,time_slewin,time_in)
        slew2low = append('AddAttitude */Satellite/', satName,' Profile "',time_slewout,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2low);
        low=strcat('AddAttitude */Satellite/', satName,' Profile "',time_out,'" Fixed YPR 0 0 0 YPR "Satellite/', satName,' ICR"');
        root.ExecuteCommand(low);
        slew2safe=append('AddAttitude */Satellite/', satName,' Profile "',time_slewin,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2safe);
        safe=append('AddAttitude */Satellite/', satName,' Profile "',time_in,'" SpinSun 0.0 0.0 "',time_in,'"');
        root.ExecuteCommand(safe);
end