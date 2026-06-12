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
