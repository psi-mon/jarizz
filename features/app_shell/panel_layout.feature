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
