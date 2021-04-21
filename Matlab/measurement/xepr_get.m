function x =xepr_get(rec, string, Boolstring)
%this function retrieves arguments from the Parameter list.
%If your argument is hidden, Boolstring needs to be true.
%xepr_get(rec, "QValue", "True")
%Names of arguments are found in the pdf files in:
% /home/xuser/Desktop/dev/python_codes_Xepr2/My resources
arg_vector = javaArray('java.lang.String',2);
arg_vector(1,:) = java.lang.String(string);
arg_vector(2,:) = java.lang.String(Boolstring);
x =execute(rec,'get',arg_vector);
end