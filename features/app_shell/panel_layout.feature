# mutation-stamp: sha256=a92ead9296bfbeccd7802f8f3bdfa58907527c6a73406ee3142b3ef985e49ba9
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-15T12:27:10Z","feature_name":"Panel layout and appearance","feature_path":"features/app_shell/panel_layout.feature","background_hash":"8704f147f53c0d58881140caacf25e69a73c07d0e8e7e785f3b31b3b1be135c2","implementation_hash":"unknown","scenarios":[{"index":1,"name":"Panel center aligns with the center of the screen frame containing the mouse pointer","scenario_hash":"6aaee4e92ffb42eb4ee1dbfd35dd611db4b668c4d97f08fbc41363b2cc8eb1b1","mutation_count":12,"result":{"Total":12,"Killed":12,"Survived":0,"Errors":0},"tested_at":"2026-06-15T12:27:10Z"},{"index":2,"name":"Panel size defaults to 50 percent of the screen frame dimensions","scenario_hash":"1472dd46435b1e64c0a5b4e2b043d21547389d173b5d7cb5dc5978328d9e8d9f","mutation_count":8,"result":{"Total":8,"Killed":8,"Survived":0,"Errors":0},"tested_at":"2026-06-15T12:27:10Z"}]}
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
  Scenario Outline: Panel center aligns with the center of the screen frame containing the mouse pointer
    Given the mouse pointer is on a screen with frame origin "<origin_x>" "<origin_y>" and size "<width>" by "<height>"
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel center x is "<center_x>"
    And the panel center y is "<center_y>"

    Examples:
      | origin_x | origin_y | width | height | center_x | center_y |
      | 0        | 0        | 2560  | 1440   | 1280     | 720      |
      | 2560     | 0        | 1920  | 1080   | 3520     | 540      |

  # app-shell-014
  Scenario Outline: Panel size defaults to 50 percent of the screen frame dimensions
    Given the mouse pointer is on a screen with frame size "<width>" by "<height>"
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel width is "<panel_width>"
    And the panel height is "<panel_height>"

    Examples:
      | width | height | panel_width | panel_height |
      | 2560  | 1440   | 1280        | 720          |
      | 1920  | 1080   | 960         | 540          |
