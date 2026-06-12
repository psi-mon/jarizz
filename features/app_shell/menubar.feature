Feature: Menubar icon

  # app-shell-001
  Scenario: App shows menubar icon on launch
    Given the app is not running
    When the app launches
    Then a menubar status item is visible

  # app-shell-002
  Scenario: App has no Dock icon
    Given the app is not running
    When the app launches
    Then the app does not appear in the Dock
