function sunPointing_highDragManeuver(root,satName,time_slewout,time_out,time_slewin,time_in)
        slew2high = append('AddAttitude */Satellite/', satName,' Profile "',time_slewout,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2high);
        high=strcat('AddAttitude */Satellite/', satName,' Profile "',time_out,'" AlignConstrain Axis 0 0 1 "Satellite/', satName,' Sun" Axis 0 1 0 "Satellite/', satName,' Velocity"');
        root.ExecuteCommand(high);
        slew2low=append('AddAttitude */Satellite/', satName,' Profile "',time_slewin,'" FixedTimeSlew Smooth On "');
        root.ExecuteCommand(slew2low);
        low=append('AddAttitude */Satellite/', satName,' Profile "',time_in,'" AlignConstrain Axis 0 0 1 "Satellite/', satName,' Sun" Axis 1 0 0 "Satellite/', satName,' Velocity"');
        root.ExecuteCommand(low);
end