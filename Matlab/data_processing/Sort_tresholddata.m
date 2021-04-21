function match = Sort_tresholddata(directory)
matfiles = dir(fullfile(directory,'*.mat')); % get all files in folder
capExpr = '(?<T>[0-9.]*)T_(?<mW>[0-9.]*)(W|mW)_(?<type>(VNA|SA))_(?<date>[0-9-]*)-(?<id>\w*)'; % regular expression
for i=1:length(matfiles)
    filename=matfiles(i).name(1:end-4); % retrieve filename and cut .mat
    [~,~,~,~,~,matches,~] = regexp(filename,capExpr,'tokens','match'); % apply the regexp and split into tokens. Whatever that output format is....
    if(~isempty(matches))
        matches.T = str2double(matches.T); % convert matches to senseful types
        matches.mW = str2double(matches.mW);
        matches.type = convertCharsToStrings(matches.type);
        matches.date = convertCharsToStrings(matches.date);
        matches.id = convertCharsToStrings(matches.id);
        matches.file = [directory,matfiles(i).name]; % add path
        match(i) = matches; % put into table
    end
end
tmatch = struct2table(match);
tmatch = sortrows(tmatch,'T'); % sort by turns
match = table2struct(tmatch);
end