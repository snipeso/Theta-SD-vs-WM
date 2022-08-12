function [Matrix, Things] = tabulateTable(Trials, Column, Aggregator, Participants, Sessions, SessionGroups)
% puts data from table into a matrix

if exist('SessionGroups', 'var') && ~isempty(SessionGroups)
    nSessions = numel(SessionGroups);
else
    nSessions = numel(Sessions);
    SessionGroups = num2cell(1:nSessions);
end

if strcmp(Aggregator, 'tabulate')
    Data = Trials.(Column);
    if isnumeric(Data)
        Data(isnan(Data)) = [];
    end
    Things = unique(Data);
    Matrix = nan(numel(Participants), nSessions, numel(Things));

    if islogical(Things)
        Things = string(double(Things));
    end
else
    Things = [];
    Matrix = nan(numel(Participants), nSessions);
end

for Indx_P = 1:numel(Participants)
    for Indx_S = 1:nSessions
        CurrentTrials = strcmp(Trials.Participant, Participants{Indx_P}) & ...
            ismember(Trials.Session, Sessions(SessionGroups{Indx_S}));
        Data = Trials.(Column)(CurrentTrials);

        if isnumeric(Data)
            Data(isnan(Data)) = [];
        end

        switch Aggregator
            case 'sum'
                Matrix(Indx_P, Indx_S) = sum(Data, 'omitnan');
            case 'mean'
                Matrix(Indx_P, Indx_S) = mean(Data, 'omitnan');
            case 'top10mean'
                Data = sort(Data);
                Top10 = quantile(Data, .1);
                Matrix(Indx_P, Indx_S) = mean(Data(Data<Top10), 'omitnan');
            case 'bottom10mean'
                Data = sort(Data);
                Bottom10 = quantile(Data, .9);
                Matrix(Indx_P, Indx_S) = mean(Data(Data>Bottom10), 'omitnan');
            case 'median'
                Matrix(Indx_P, Indx_S) = median(Data, 'omitnan');
            case 'std'
                Matrix(Indx_P, Indx_S) = std(Data, 'omitnan');
            case 'tabulate'
                if numel(Things) > 1
                    Table = tabulate(Data);

                    if isempty(Table)
                        continue
                        %                     elseif iscell(Table)
                        %                         Tots(ismember(Things, Table(:, 1))) = [Table{:, 2}];
                        %                         Matrix(Indx_P, Indx_S, :) = Tots;
                        %
                    else
                        Tots = zeros(numel(Things), 1);
                        Tots(ismember(Things, Table(:, 1))) = Table(:, 2);
                        Matrix(Indx_P, Indx_S, :) = Tots;

                    end
                else
                    Matrix(Indx_P, Indx_S) = numel(Data);
                end
        end
    end
end