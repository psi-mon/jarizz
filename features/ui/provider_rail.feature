# mutation-stamp: sha256=37c5909ed0cd360cec1454274a210677a48e32689ab9f5f47954c4bde7e6338b
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-24T11:48:03Z","feature_name":"Provider rail overlay","feature_path":"features/ui/provider_rail.feature","background_hash":"c0e5c2e3b93bd517ac3d1c6e2406d0cf5c4cac1ffffa926fab3dd06ef53b850b","implementation_hash":"unknown","scenarios":[{"index":0,"name":"Rail shows one button per configured provider","scenario_hash":"ac630590f6e26459408bb3b3412325a8d9a5bad392208e4c40925678263405d7","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":3,"name":"The active provider button is marked active","scenario_hash":"c4be3ac9482e58189d606c91456d8c9aaa6b6cbec284889b2015a80ade414ade","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":4,"name":"Clicking a provider button switches the active provider","scenario_hash":"2a8588f134902f0d7e5fdad8a901c6bae90eca705f691dbd9e7ceda915b1065c","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":5,"name":"Clicking a provider button navigates to that provider's URL","scenario_hash":"4f80dd5f83e72f8ac843648f7af87c7b4b7effa1ffb1434afa411db5d44c1a7b","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":6,"name":"Clicking the already-active provider button does not navigate again","scenario_hash":"9c4733c478e81e07780c666e1e38c1f5be9fdbe21459accbeb50ccd0a88a2b14","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":7,"name":"Switching away from a provider via the rail and back does not reload it","scenario_hash":"7d5f6ef2b7090fdf30dcec7ecf581a50a83118be1fae7d57877c0f06fa634965","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":10,"name":"Rail collapse state persists across app restart","scenario_hash":"ec200e17734107885bbb49ad97af52975a6ce0076ea8cc1dc5d2bb940ec5d46e","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"},{"index":13,"name":"Each provider button has the provider name as its accessibility label","scenario_hash":"5c45258396412a0188ddf56c5b5c4252957e24540525d1004e7b812ccc5a91c3","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-24T09:28:53Z"}]}
# acceptance-mutation-manifest-end

Feature: Provider rail overlay
  # The rail is a floating overlay anchored to the right edge of the panel.
  # It sits on top of the web content without shrinking the content area.
  # Collapse state is stored as `railCollapsed` in settings.json.
  # Slice note: simulation tests must not pass via protocol constants alone;
  # the JarizzApp adapter must implement overlay visibility and click handling.

  Background:
    Given the app is running
    And the panel is visible

  # rail-001
  # simulation-friendly
  Scenario Outline: Rail shows one button per configured provider
    Given "<count>" providers are configured
    Then the rail has "<count>" provider buttons

    Examples:
      | count |
      | 1     |
      | 6     |

  # rail-002
  # simulation-friendly
  Scenario: Rail is not visible when no providers are configured
    Given no providers are configured
    Then the rail is not visible

  # rail-003
  # simulation-friendly
  Scenario: Rail is not visible when the panel is hidden
    Given the panel is hidden
    Then the rail is not visible

  # rail-004
  # simulation-friendly
  Scenario Outline: The active provider button is marked active
    Given providers "<first>" and "<second>" are configured in that order
    And the active provider is "<first>"
    Then the provider button for "<first>" is active
    And the provider button for "<second>" is not active

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # rail-005
  # simulation-friendly
  Scenario Outline: Clicking a provider button switches the active provider
    Given providers "<first>" and "<second>" are configured in that order
    And the active provider is "<first>"
    When the user clicks the provider button for "<second>"
    Then the active provider is "<second>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # rail-006
  # simulation-friendly: verifies the panel adapter navigates to the clicked provider's URL
  Scenario Outline: Clicking a provider button navigates to that provider's URL
    Given providers "<first>" and "<second>" are configured in that order
    And the active provider is "<first>"
    When the user clicks the provider button for "<second>"
    Then the web provider has navigated to the URL of provider "<second>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # rail-007
  # simulation-friendly: keep-alive — re-clicking the active provider must not navigate again
  Scenario Outline: Clicking the already-active provider button does not navigate again
    Given providers "<first>" and "<second>" are configured in that order
    And the panel is showing the web view for provider "<first>"
    When the user clicks the provider button for "<first>"
    Then the web provider navigation count for provider "<first>" is "1"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # rail-008
  # simulation-friendly: keep-alive — switching away and back must not reload the original provider
  Scenario Outline: Switching away from a provider via the rail and back does not reload it
    Given providers "<first>" and "<second>" are configured in that order
    And the panel is showing the web view for provider "<first>"
    When the user clicks the provider button for "<second>"
    And the user clicks the provider button for "<first>"
    Then the web provider navigation count for provider "<first>" is "1"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # rail-009
  # simulation-friendly
  Scenario: Rail collapses when the collapse control is clicked
    Given the rail is expanded
    When the user clicks the collapse control
    Then the rail is collapsed
    And the provider buttons are not visible
    And the expand control is visible

  # rail-010
  # simulation-friendly
  Scenario: Rail expands when the expand control is clicked
    Given the rail is collapsed
    When the user clicks the expand control
    Then the rail is expanded
    And the provider buttons are visible

  # rail-011
  # simulation-friendly: tests round-trip serialisation of collapse state
  Scenario Outline: Rail collapse state persists across app restart
    Given the rail is "<state>"
    When the app is restarted
    Then the rail is "<state>"

    Examples:
      | state     |
      | collapsed |
      | expanded  |

  # rail-012
  # simulation-friendly: Ctrl+Tab → rail highlight follows active provider
  Scenario: Active provider button highlight follows Ctrl+Tab
    Given providers "Gemini" and "ChatGPT" are configured in that order
    And the active provider is "Gemini"
    When the user presses Ctrl+Tab
    Then the active provider is "ChatGPT"
    And the provider button for "ChatGPT" is active
    And the provider button for "Gemini" is not active

  # rail-013
  # simulation-friendly: rail click → Ctrl+Tab cycles from that provider's position
  Scenario: Ctrl+Tab cycles from the provider last activated by the rail
    Given providers "Gemini", "ChatGPT", and "Copilot" are configured in that order
    And the active provider is "Gemini"
    When the user clicks the provider button for "Copilot"
    And the user presses Ctrl+Tab
    Then the active provider is "Gemini"

  # rail-014
  # simulation-friendly
  Scenario Outline: Each provider button has the provider name as its accessibility label
    Given a provider with name "<name>" is configured
    Then the provider button for "<name>" has accessibility label "<name>"

    Examples:
      | name   |
      | Gemini |

  # rail-015
  # manual-only: requires live overlay rendering
  # Verifies rail is anchored to right edge and web content area is not shrunk
  Scenario: Rail overlay sits on top of web content without shrinking the content area
    Given "1" providers are configured
    Then the rail overlay is visible on the right edge of the panel
    And the web content area fills the panel window

  # rail-016
  # manual-only: requires live overlay rendering
  Scenario: Provider buttons are vertically centered as a group on the rail
    Given "3" providers are configured
    Then the provider buttons are vertically centered as a group on the right edge of the panel
