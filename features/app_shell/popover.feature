Feature: Popover toggle and dismiss

  Background:
    Given the app is running

  # app-shell-003
  Scenario: Global hotkey shows the popover
    Given the popover is hidden
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the popover is visible

  # app-shell-004
  Scenario: Global hotkey hides the popover
    Given the popover is visible
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the popover is hidden

  # app-shell-005
  Scenario: Menubar icon click shows the popover
    Given the popover is hidden
    When the user clicks the menubar icon
    Then the popover is visible

  # app-shell-006
  Scenario: Menubar icon click hides the popover
    Given the popover is visible
    When the user clicks the menubar icon
    Then the popover is hidden

  # app-shell-007
  Scenario: Popover displays placeholder content
    Given the popover is hidden
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the popover displays the text "jarizz"

  # app-shell-008
  Scenario: Popover dismisses on Escape key
    Given the popover is visible
    When the user presses "Escape"
    Then the popover is hidden

  # app-shell-009
  Scenario: Popover dismisses on outside click
    Given the popover is visible
    When the user clicks outside the popover
    Then the popover is hidden
