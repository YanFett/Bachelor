function x =xepr_set(rec, string, Boolstring,Value)
%this function retrieves arguments from the Parameter list.
%If your argument is hidden, Boolstring needs to be true.
%xepr_set(rec, "CenterField", "False", "4444")
%Names of arguments are found in the pdf files in:
% /home/xuser/Desktop/dev/python_codes_Xepr2/My resources
Valuestr = num2str(Value);
arg_vector = javaArray('java.lang.String',3);
arg_vector(1,:) = java.lang.String(string);
arg_vector(2,:) = java.lang.String(Boolstring);
arg_vector(3,:) = java.lang.String(Valuestr);
x =execute(rec,'set',arg_vector);
end