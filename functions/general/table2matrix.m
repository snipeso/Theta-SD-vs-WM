function Matrix = table2matrix(Table, ParticipantColumn, Participants, ConditionColumn, Conditions, DataColumn)
% pulls out the values and sorts it into a P x S matrix. Probably a more
% efficient way of doing this.
% For future self, when this crashes because I try to run the old function
% with this name, its now renamed to "table2matrix_questionnaires".

% create empty matrix or cell array, depending on what the datatype is
if isa(Table.(DataColumn)(1), 'double') || isa(Table.(DataColumn)(1), 'single')
    Matrix = nan(numel(Participants), numel(Conditions));
else
    Matrix = cell(numel(Participants), numel(Conditions));
end


for Indx_P = 1:numel(Participants)
    for Indx_S = 1:numel(Conditions)
       
        Indx = strcmp(Table.(ParticipantColumn), Participants{Indx_P} & ...
             strcmp(Table.(ConditionColumn), Conditions{Indx_S}));
        Ans = Table.(DataColumn)(Indx);
        
        % handle problems
        if numel(Ans) < 1
            continue
        elseif numel(Ans) > 1
            error(['Not unique entries for ', DataColumn, ' in ' Participants{Indx_P}, ' ', Conditions{Indx_S} ])
        end
        
        % save in appropriate way
        if isa(Ans, 'double') || isa(Ans, 'single')
            Matrix(Indx_P, Indx_S) = Ans;
        else
            Matrix{Indx_P, Indx_S} = Ans;
        end
        
    end
end
