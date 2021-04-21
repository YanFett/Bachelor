function set_Keysight_mode(Keysight, SAmode)

fprintf(Keysight, [':INST:SEL ', SAmode]);

end