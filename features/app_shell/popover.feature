# mutation-stamp: sha256=3946a0e4eafc7a12d1b360af703cb42d53c6e404203d877062aa4cf8de179c8d
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-12T17:18:15Z","feature_name":"Popover toggle and dismiss","feature_path":"features/app_shell/popover.feature","background_hash":"151a63a15af270e9d7b0dafe5376b29f80e482c8414fb0236be330f9be34738f","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

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

  # app-shell-007
  Scenario: Panel displays placeholder content
    Given the panel is hidden
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel displays the text "jarizz"

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
