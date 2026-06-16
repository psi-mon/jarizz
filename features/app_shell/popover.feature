Feature: Panel toggle and dismiss

  Background:
    Given the app is running

  # app-shell-003
  Scenario: Global hotkey shows the panel
    Given the panel is hidden
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel is visible

  # app-shell-004
  Scenario: Global hotkey hides the panel
    Given the panel is visible
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel is hidden

  # app-shell-005
  Scenario: Menubar icon click shows the panel
    Given the panel is hidden
    When the user clicks the menubar icon
    Then the panel is visible

  # app-shell-006
  Scenario: Menubar icon click hides the panel
    Given the panel is visible
    When the user clicks the menubar icon
    Then the panel is hidden

  # app-shell-008
  Scenario: Panel dismisses on Escape key
    Given the panel is visible
    When the user presses "Escape"
    Then the panel is hidden

  # app-shell-009
  Scenario: Panel dismisses on outside click
    Given the panel is visible
    When the user clicks outside the panel
    Then the panel is hidden
