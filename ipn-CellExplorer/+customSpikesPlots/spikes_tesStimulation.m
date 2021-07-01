function spikePlot = spikes_tesStimulation

spikePlot.x = 'times';
spikePlot.y = 'times';
spikePlot.x_label = 'Time';
spikePlot.y_label = 'Event';
spikePlot.state = '';
spikePlot.filter = '';
spikePlot.filterType = '';                 % [none, equal to, less than, greater than]
spikePlot.filterValue = 0;
spikePlot.event = 'stimulation';
spikePlot.eventType = 'manipulation';      % [events,manipulation,states]
spikePlot.eventAlignment = 'onset';        % [onset, offset, center, peak]
spikePlot.eventSorting = 'amplitude';      % [none, time, amplitude, duration]
spikePlot.eventSecBefore = 2;              % in seconds
spikePlot.eventSecAfter = 2;               % in seconds
spikePlot.plotRaster = 1;
spikePlot.plotAverage = 1;
spikePlot.plotAmplitude = 1;
spikePlot.plotDuration = 0;
spikePlot.plotCount = 0;

end