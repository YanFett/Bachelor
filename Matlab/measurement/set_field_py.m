function z=set_field_py(field)
format long;
%client.execute('set_field', field)
%py.post.set_field(field);
fieldstr = mat2str(field,10);
whitespace = ' '; 
call = ['python2.6 change_field.py',whitespace,fieldstr];
system(call);
z=field;
end
