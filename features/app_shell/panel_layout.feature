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
