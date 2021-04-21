function x =set_precise_field(rec, Field)
%this function retrieves arguments from the Parameter list.
%If your argument is hidden, Boolstring needs to be true.
%xepr_set(rec, "CenterField", "False", "4444")
%Names of arguments are found in the pdf files in:
% /home/xuser/Desktop/dev/python_codes_Xepr2/My resources
arg_vector = javaArray('java.lang.String',1);
arg_vector(1,:) = java.lang.String(num2str(Field));
x =execute(rec,'set_precise_field',arg_vector);
end