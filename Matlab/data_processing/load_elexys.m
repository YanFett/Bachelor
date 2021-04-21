function [x_axis,y_axis] = load_elexys(path,contains_imag)
    if(~exist('contains_imag','var'))
    	contains_imag = true;
    end
    [x_axis,~] = eprload([path,'.DTA']);
    fid = fopen([path,'.DTA']);
    A   = fread(fid, Inf, 'uint8');
    fclose(fid);
    Fmt = repmat('%02X ', 1, 16);  % Create format string
    %Fmt(end) = '*';                % Trailing star
    S   = sprintf(Fmt, A);         % One long string
    %length(S)/16
    %S = strrep(S, ' ', '');
    C   = regexp(S, '0D 0A', 'split'); % Split at stars
    C = strrep(C, ' ', '');
    S = strjoin(C(:),'00');
    %length(S)/16
    shift = 0;
    if(contains_imag)
        for(i=1:length(S)/32-shift*2)
            read_i = (i*2)-1 + shift*2;
            start_i = ((read_i-1)*16)+1;
            end_i = read_i*16;
            number = hex2num(extractBetween(S,start_i,end_i));
            num(i,1) = number;

            read_i = (i*2) + shift*2;
            start_i = ((read_i-1)*16)+1;
            end_i = read_i*16;
            number = hex2num(extractBetween(S,start_i,end_i));
            num(i,2) =-number;
        end
    else
        for(i=1:length(S)/16-shift)
        read_i = i + shift;
        start_i = ((read_i-1)*16)+1;
        end_i = read_i*16;
        number = hex2num(extractBetween(S,start_i,end_i));
        num(i,1) = number;
        end
    end
    y_axis = num;
end