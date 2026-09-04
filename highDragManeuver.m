function highDragManeuver(root,satName,time_slewout,time_out,time_slewin,time_in)
        slew2high = append('AddAttitude */Satellite/', satName,' Profile "',time_slewout,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2high);
        high=strcat('AddAttitude */Satellite/', satName,' Profile "',time_out,'" Fixed YPR 0 -90 0 YPR "Satellite/', satName,' ICR"');
        root.ExecuteCommand(high);
        slew2safe=append('AddAttitude */Satellite/', satName,' Profile "',time_slewin,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2safe);
        safe=append('AddAttitude */Satellite/', satName,' Profile "',time_in,'" SpinSun 0.0 0.0 "',time_in,'"');
        root.ExecuteCommand(safe);
end