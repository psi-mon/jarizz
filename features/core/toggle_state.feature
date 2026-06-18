# mutation-stamp: sha256=01a1ceeef301e665fb541f43ed4fb32ee7e582ad131d47fb46ea6091b3d39a7c
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-18T12:28:16Z","feature_name":"Panel toggle state","feature_path":"features/core/toggle_state.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[{"index":0,"name":"Toggle state transitions between visible and hidden","scenario_hash":"0272d97c2e687e716e244b957d35eeaabc3025a68c4cc8cd55dc18fca8456f12","mutation_count":4,"result":{"Total":4,"Killed":4,"Survived":0,"Errors":0},"tested_at":"2026-06-12T18:50:47Z"}]}
# acceptance-mutation-manifest-end

Feature: Panel toggle state

  # app-shell-011
  Scenario Outline: Toggle state transitions between visible and hidden
    Given the panel state is "<initial>"
    When the panel is toggled
    Then the panel state is "<result>"

    Examples:
      | initial | result  |
      | hidden  | visible |
      | visible | hidden  |
