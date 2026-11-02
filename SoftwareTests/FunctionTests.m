classdef FunctionTests < matlab.unittest.TestCase

    properties
        ProjectRoot
        TemporaryFolder
    end

    methods (TestMethodSetup)

        function createTemporaryWorkspace(testCase)
            testCase.ProjectRoot = fileparts(fileparts(mfilename("fullpath")));
            testCase.TemporaryFolder = string(tempname);
            mkdir(testCase.TemporaryFolder)
        end
    end

    methods (Test)

        function testSetupCreatesUsableMockDataset(testCase)
            MockPenguinsProjectRoot = testCase.TemporaryFolder;
            run(fullfile(testCase.ProjectRoot, "SoftwareTests", "PreFiles", ...
                "SetupPenguinsDataset.m"))
            mockPenguins = readtable(fullfile( ...
                MockPenguinsProjectRoot, "penguins.csv"));
            testCase.verifyTrue(MockPenguinsCsvCreated);
            run(fullfile(testCase.ProjectRoot, "SoftwareTests", "PostFiles", ...
                "CleanupMockPenguinsDataset.m"))

            testCase.verifyEqual(string(mockPenguins.Properties.VariableNames), ...
                ["species", "island", "bill_length_mm", "bill_depth_mm", ...
                "flipper_length_mm", "body_mass_g", "sex"]);
            testCase.verifyGreaterThanOrEqual( ...
                sum(string(mockPenguins.species) == "Adelie"), 68);
            testCase.verifyGreaterThanOrEqual( ...
                sum(string(mockPenguins.species) == "Chinstrap"), 68);
            testCase.verifyGreaterThanOrEqual( ...
                sum(string(mockPenguins.species) == "Gentoo"), 68);
            testCase.verifyFalse(isfile(fullfile( ...
                MockPenguinsProjectRoot, "penguins.csv")));
        end

        function testSetupPreservesExistingDataset(testCase)
            MockPenguinsProjectRoot = testCase.TemporaryFolder;
            datasetPath = fullfile(MockPenguinsProjectRoot, "penguins.csv");
            writelines("sentinel", datasetPath)
            run(fullfile(testCase.ProjectRoot, "SoftwareTests", "PreFiles", ...
                "SetupPenguinsDataset.m"))
            testCase.verifyFalse(MockPenguinsCsvCreated);
            run(fullfile(testCase.ProjectRoot, "SoftwareTests", "PostFiles", ...
                "CleanupMockPenguinsDataset.m"))

            testCase.verifyTrue(isfile(datasetPath));
            testCase.verifyEqual( ...
                readlines(datasetPath, EmptyLineRule="skip"), "sentinel");
        end
    end % methods

end % classdef
