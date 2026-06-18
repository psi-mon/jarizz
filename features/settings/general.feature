# mutation-stamp: sha256=8bb5cbdb220c6038f8ad850090d488e6c1c040a91984ad5babffc3e42ef8c636
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-18T12:28:16Z","feature_name":"Settings — General","feature_path":"features/settings/general.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[{"index":4,"name":"Changing the global hotkey applies immediately","scenario_hash":"d0e30d28f9f4c47e92c64f38174966aeef203bbd1e8f9af69267ab78e100b9a8","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"},{"index":5,"name":"Changed global hotkey persists after app restart","scenario_hash":"b0bc3084ca0bb50190e03a015947ff080c7bb7109871c33db3d7b9bc67753e4d","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"},{"index":6,"name":"Changing the panel size applies immediately","scenario_hash":"14b6ff944298e17f8b2bda8a1fe667e0d6c9a8ab9fd7780aa5733e0d32292a57","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"},{"index":7,"name":"A size preview overlay appears while the slider is adjusted","scenario_hash":"134cebb53d1f663868d837d94a69e77171101dc6266dc62186dce5941cec6e30","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"},{"index":8,"name":"Panel size is constrained between 20 and 90 percent","scenario_hash":"0b0d82c19d6373f1b3661699158710775c812eb1b075936e01b1ae324fd64aaa","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"},{"index":9,"name":"Changed panel size persists after app restart","scenario_hash":"84b004eafdb2a84583b8c8d8462c748e4db51847c5e2e25f9d4759ca18e0d1d0","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:26Z"}]}
# acceptance-mutation-manifest-end

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

  # settings-011
  # simulation-friendly
  Scenario: Opening Settings dismisses the main panel if it is visible
    Given the app is running
    And the panel is visible
    When the user opens Settings
    Then the panel is hidden
    And the Settings window is visible
