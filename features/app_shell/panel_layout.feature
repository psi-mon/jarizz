# mutation-stamp: sha256=fbd199b755597fa60a5105a3fe63de2a24cb87ef01a1eff7cfdefd334a7fcbaf
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-15T11:48:15Z","feature_name":"Panel layout and appearance","feature_path":"features/app_shell/panel_layout.feature","background_hash":"8704f147f53c0d58881140caacf25e69a73c07d0e8e7e785f3b31b3b1be135c2","implementation_hash":"unknown","scenarios":[{"index":1,"name":"Panel appears centered on the screen containing the mouse pointer","scenario_hash":"50992a590258791a109a51de7db2bf1a49d7ffb3a05baf6acb05b7f226bceb6b","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-12T18:50:43Z"},{"index":2,"name":"Panel size defaults to 50 percent of the current screen dimensions","scenario_hash":"0245b6d3c6d1a4134ded4170cfd21dfb6bf5acc8fb921b886184b5428faa6056","mutation_count":8,"result":{"Total":8,"Killed":8,"Survived":0,"Errors":0},"tested_at":"2026-06-12T18:50:43Z"}]}
# acceptance-mutation-manifest-end

Feature: Panel layout and appearance

  Background:
    Given the app is running
    And the panel is hidden

  # app-shell-012
  Scenario: Panel appears with a fade-in animation
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel appears with a fade-in animation

  # app-shell-013
  Scenario Outline: Panel appears centered on the screen containing the mouse pointer
    Given the mouse pointer is on screen "<screen>"
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel is centered on screen "<screen>"

    Examples:
      | screen  |
      | primary |
      | second  |

  # app-shell-014
  Scenario Outline: Panel size defaults to 50 percent of the current screen dimensions
    Given the mouse pointer is on a screen with dimensions "<width>" by "<height>"
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel width is "<panel_width>"
    And the panel height is "<panel_height>"

    Examples:
      | width | height | panel_width | panel_height |
      | 2560  | 1440   | 1280        | 720          |
      | 1920  | 1080   | 960         | 540          |
