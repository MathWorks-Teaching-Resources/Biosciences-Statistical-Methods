classdef ExternalLinkHealthTest < matlab.unittest.TestCase

    properties
        TemporaryFolder
    end

    methods (TestClassSetup)

        function addInternalFilesToPath(testCase)
            projectRoot = fileparts(fileparts(mfilename("fullpath")));
            testCase.applyFixture( ...
                matlab.unittest.fixtures.PathFixture( ...
                fullfile(projectRoot, "InternalFiles")));
        end
    end

    methods (TestMethodSetup)

        function createTemporaryFolder(testCase)
            testCase.TemporaryFolder = string(tempname);
            mkdir(testCase.TemporaryFolder)
            testCase.addTeardown(@rmdir, testCase.TemporaryFolder, "s");
        end
    end

    methods (Test)

        function testDeduplicatesFragmentsAndTracksSources(testCase)
            sourceFiles = writeFixtureSources(testCase.TemporaryFolder);
            report = CheckExternalLinks( ...
                SourceFiles=sourceFiles, ...
                OutputFile=fullfile(testCase.TemporaryFolder, "report.md"), ...
                PerformRequests=false);

            testCase.verifyEqual(height(report.References), 8);
            testCase.verifyEqual(height(report.Details), 6);
            testCase.verifyEqual( ...
                report.Details.ReferenceCount( ...
                report.Details.RequestURL == "https://example.com/docs"), 2);
            testCase.verifyEqual( ...
                report.Details.Classification, ...
                repmat("Not checked", 6, 1));
            testCase.verifyTrue(any(report.Details.RequestURL == ...
                "https://www.mathworks.com/help/matlab/ref/legend.html"));
            testCase.verifyTrue(any(report.Details.RequestURL == ...
                "https://www.mathworks.com/help/matlab/ref/hold.html"));
        end

        function testWritesReadableMarkdownReport(testCase)
            sourceFiles = writeFixtureSources(testCase.TemporaryFolder);
            reportFile = fullfile(testCase.TemporaryFolder, "report.md");
            CheckExternalLinks( ...
                SourceFiles=sourceFiles, ...
                OutputFile=reportFile, ...
                PerformRequests=false);
            reportText = fileread(reportFile);

            testCase.verifyTrue(isfile(reportFile));
            testCase.verifyTrue(contains(reportText, "# External Link Health"));
            testCase.verifyTrue(contains(reportText, "## Summary"));
            testCase.verifyTrue(contains(reportText, "## Details"));
            testCase.verifyTrue(contains(reportText, "https://example.com/docs"));
            testCase.verifyTrue( ...
                contains(reportText, "https://example.net/destination"));
            testCase.verifyTrue(contains(reportText, ...
                "https://www.mathworks.com/help/matlab/ref/legend.html"));
        end
    end
end

function sourceFiles = writeFixtureSources(folder)
firstFile = fullfile(folder, "First.m");
secondFile = fullfile(folder, "Second.md");
writelines([ ...
    "%[text] [First](https://example.com/docs#one)" ...
    "%[text] Bare URL: https://example.org/reference(1)." ...
    "%[text] [![Badge](https://example.net/badge.svg)](https://example.net/destination)" ...
    "%[text] [Legend](https://www.mathworks.com/help/matlab/ref/legend.html)function" ...
    "%[text] [Hold](https://www.mathworks.com/help/matlab/ref/hold.html)/**`hold off`**" ...
    ], firstFile);
writelines([ ...
    "[Second](https://example.com/docs#two)" ...
    "Again: https://example.org/reference(1)." ...
    ], secondFile);
sourceFiles = [string(firstFile); string(secondFile)];
end
