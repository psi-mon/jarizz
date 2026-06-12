# mutation-stamp: sha256=406ce4514d44194a919690b861332148429e4463428315382bb1a1ddb13876fd
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-12T17:05:48Z","feature_name":"Popover toggle state","feature_path":"features/core/toggle_state.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[{"index":0,"name":"Toggle state transitions between visible and hidden","scenario_hash":"cd6627458e9b093972113683dfd5e9caf18d9f6171f4e8d3a53c18454953b1c6","mutation_count":4,"result":{"Total":4,"Killed":4,"Survived":0,"Errors":0},"tested_at":"2026-06-12T17:05:48Z"}]}
# acceptance-mutation-manifest-end

Feature: Popover toggle state

  # app-shell-011
  Scenario Outline: Toggle state transitions between visible and hidden
    Given the popover state is "<initial>"
    When the popover is toggled
    Then the popover state is "<result>"

    Examples:
      | initial | result  |
      | hidden  | visible |
      | visible | hidden  |
