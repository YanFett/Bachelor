function setup_sweep(rec, centerfield, sweepwidth, ModAmp, PpModAmp, SweepTime, TimeConstant)
field_vector = javaArray('java.lang.Double',3);
field_vector(1,:) = java.lang.Double(centerfield);
field_vector(2,:) = java.lang.Double(sweepwidth);
field_vector(3,:) = java.lang.Double(ModAmp);
field_vector(4,:) = java.lang.Double(PpModAmp);
field_vector(5,:) = java.lang.Double(SweepTime);
field_vector(6,:) = java.lang.Double(TimeConstant);
execute(rec,'setup_sweep',field_vector);
%Sets up the sweep via the xeprapi server