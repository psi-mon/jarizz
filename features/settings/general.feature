Feature: Settings — General
  # Persistence: ~/Library/Application Support/jarizz/settings.json
  # Schema fields: hotkey (string), panelSizePercent (integer 20–90)
  # All changes apply immediately and auto-save; no explicit Save button.

  # settings-001
  # manual-only: requires live menubar UI
  Scenario: Right-click on the menubar icon shows a context menu
    Given the app is running
    When the user right-clicks the menubar icon
    Then a context menu appears containing "Settings…"
    And the context menu contains "Quit jarizz"

  # settings-002
  # manual-only: requires live menubar UI
  Scenario: Selecting Settings from the context menu opens the Settings window
    Given the app is running
    When the user right-clicks the menubar icon
    And the user selects "Settings…" from the context menu
    Then the Settings window is visible

  # settings-003
  # simulation-friendly
  Scenario: Global hotkey defaults to LeftShift+RightCommand+] on first launch
    Given the app is launching for the first time with no saved settings
    When the app launches
    Then the global hotkey is "LeftShift+RightCommand+]"

  # settings-004
  # simulation-friendly
  Scenario: Panel size defaults to 50 percent on first launch
    Given the app is launching for the first time with no saved settings
    When the app launches
    Then the panel size is "50" percent of the screen frame

  # settings-005
  # simulation-friendly
  Scenario Outline: Changing the global hotkey applies immediately
    Given the app is running
    When the user sets the global hotkey to "<hotkey>"
    Then the global hotkey is "<hotkey>"

    Examples:
      | hotkey                  |
      | LeftShift+RightOption+P |

  # settings-006
  # simulation-friendly: tests round-trip serialisation
  Scenario Outline: Changed global hotkey persists after app restart
    Given the app is running
    And the global hotkey has been set to "<hotkey>"
    When the app is restarted
    Then the global hotkey is "<hotkey>"

    Examples:
      | hotkey                  |
      | LeftShift+RightOption+P |

  # settings-007
  # simulation-friendly
  Scenario Outline: Changing the panel size applies immediately
    Given the app is running
    When the user sets the panel size to "<percent>" percent
    Then the panel size is "<percent>" percent of the screen frame

    Examples:
      | percent |
      | 30      |
      | 70      |

  # settings-008
  # manual-only: requires live UI rendering
  Scenario Outline: A size preview overlay appears while the slider is adjusted
    Given the Settings window is open on the General tab
    When the user moves the panel size slider to "<percent>" percent
    Then a transparent overlay is shown at "<percent>" percent of the current screen

    Examples:
      | percent |
      | 30      |
      | 70      |

  # settings-009
  # simulation-friendly
  Scenario Outline: Panel size is constrained between 20 and 90 percent
    Given the app is running
    When the user sets the panel size to "<percent>" percent
    Then the panel size is "<percent>" percent of the screen frame

    Examples:
      | percent |
      | 20      |
      | 90      |

  # settings-010
  # simulation-friendly: tests round-trip serialisation
  Scenario Outline: Changed panel size persists after app restart
    Given the app is running
    And the panel size has been set to "<percent>" percent
    When the app is restarted
    Then the panel size is "<percent>" percent of the screen frame

    Examples:
      | percent |
      | 70      |
