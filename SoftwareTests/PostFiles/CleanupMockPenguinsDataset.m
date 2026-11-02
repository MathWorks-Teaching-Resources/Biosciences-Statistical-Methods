% Remove only a CI dataset created by SetupPenguinsDataset.
if exist("MockPenguinsCsvCreated", "var") && MockPenguinsCsvCreated
    if exist("MockPenguinsProjectRoot", "var")
        projectRoot = MockPenguinsProjectRoot;
    else
        projectRoot = fileparts(fileparts(fileparts(mfilename("fullpath"))));
    end
    delete(fullfile(projectRoot, "penguins.csv"))
end
clear MockPenguinsCsvCreated
% <matlab:ShareFeedback Share your feedback>

