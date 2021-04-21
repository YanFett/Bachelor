function z=set_field_force(rec,field)
xepr_set(rec,'CenterField', "False", field);
xepr_set(rec,'SweepWidth', "False", 0);
xepr_set(rec,'SweepTime', "False", 0);
z = xepr_set(rec,'FieldPosition', "False", field);
end

