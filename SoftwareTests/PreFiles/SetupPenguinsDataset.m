% Create a CI-only penguin dataset only when no local dataset is present.
if exist("MockPenguinsProjectRoot", "var")
    projectRoot = MockPenguinsProjectRoot;
else
    projectRoot = fileparts(fileparts(fileparts(mfilename("fullpath"))));
end
datasetPath = fullfile(projectRoot, "penguins.csv");
MockPenguinsCsvCreated = false;

if ~isfile(datasetPath)
    originalRng = rng;
    rng(1942, "twister")

    speciesNames = ["Adelie"; "Chinstrap"; "Gentoo"];
    islandNames = ["Torgersen"; "Dream"; "Biscoe"];
    observationsPerSpecies = [72; 68; 72];
    totalObservations = sum(observationsPerSpecies);
    speciesIndex = repelem((1:numel(speciesNames))', observationsPerSpecies);

    species = speciesNames(speciesIndex);
    island = islandNames(speciesIndex);
    sex = repmat(["FEMALE"; "MALE"], totalObservations / 2, 1);
    sexOffset = double(sex == "MALE");

    billLengthMeans = [39; 49; 47];
    billDepthMeans = [18; 18; 15];
    flipperLengthMeans = [190; 196; 217];
    bodyMassMeans = [3700; 3750; 5000];

    bill_length_mm = billLengthMeans(speciesIndex) + 2 * sexOffset + ...
        2 * randn(totalObservations, 1);
    bill_depth_mm = billDepthMeans(speciesIndex) + sexOffset + ...
        randn(totalObservations, 1);
    flipper_length_mm = flipperLengthMeans(speciesIndex) + ...
        3 * sexOffset + 5 * randn(totalObservations, 1);
    body_mass_g = bodyMassMeans(speciesIndex) + 250 * sexOffset + ...
        250 * randn(totalObservations, 1);
    mockPenguins = table( ...
        species, island, bill_length_mm, bill_depth_mm, flipper_length_mm, ...
        body_mass_g, sex);
    writetable(mockPenguins, datasetPath)

    rng(originalRng)
    MockPenguinsCsvCreated = true;
end
% <matlab:ShareFeedback Share your feedback>

