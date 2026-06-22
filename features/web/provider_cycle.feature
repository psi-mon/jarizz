# mutation-stamp: sha256=d5e3fa89172591f7759f42c4a9a9e2eef5894babc3f6ee15e7f18d91969e5a7c
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-19T13:50:14Z","feature_name":"Provider cycle","feature_path":"features/web/provider_cycle.feature","background_hash":"c0e5c2e3b93bd517ac3d1c6e2406d0cf5c4cac1ffffa926fab3dd06ef53b850b","implementation_hash":"unknown","scenarios":[{"index":0,"name":"Ctrl+Tab cycles to the next provider in the list","scenario_hash":"e7b0007f9cccdf503551b5433c15ee2f9a421009ebb4db12a15836186439abbe","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-19T13:50:14Z"},{"index":1,"name":"Cycling wraps from the last provider back to the first","scenario_hash":"96ab4d2012ded03207ac21a1ca005e9a9710d98c88ad14a34617fc8076f92d2c","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-19T13:50:14Z"}]}
# acceptance-mutation-manifest-end

Feature: Provider cycle

  Background:
    Given the app is running
    And the panel is visible

  # cycle-001
  # simulation-friendly
  Scenario Outline: Ctrl+Tab cycles to the next provider in the list
    Given providers "<first>" and "<second>" are configured in that order
    When the user presses Ctrl+Tab
    Then the active provider is "<second>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # cycle-002
  # simulation-friendly
  Scenario Outline: Cycling wraps from the last provider back to the first
    Given providers "<first>" and "<second>" are configured in that order
    When the user presses Ctrl+Tab
    And the user presses Ctrl+Tab
    Then the active provider is "<first>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # cycle-003
  # simulation-friendly
  Scenario: Ctrl+Tab with only one provider configured does nothing
    Given only provider "Gemini" is configured
    When the user presses Ctrl+Tab
    Then the active provider is "Gemini"

  # cycle-005
  # simulation-friendly: verifies AppDelegate wires Ctrl+Tab to switch the displayed web view
  Scenario Outline: Panel switches to the next provider's web view when Ctrl+Tab is pressed
    Given providers "<first>" and "<second>" are configured in that order
    And the panel shows the web view for provider "<first>"
    When the user presses Ctrl+Tab
    Then the panel shows the web view for provider "<second>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # cycle-006
  # simulation-friendly: with three providers, every Ctrl+Tab advances exactly one step in sequence
  Scenario Outline: Panel cycles through all three providers in order without skipping
    Given providers "<p1>", "<p2>", and "<p3>" are configured in that order
    And the panel shows the web view for provider "<p1>"
    When the user presses Ctrl+Tab
    Then the panel shows the web view for provider "<p2>"
    When the user presses Ctrl+Tab
    Then the panel shows the web view for provider "<p3>"
    When the user presses Ctrl+Tab
    Then the panel shows the web view for provider "<p1>"

    Examples:
      | p1     | p2      | p3      |
      | Gemini | ChatGPT | Copilot |

  # cycle-004
  # manual-only: requires live panel with multiple loaded web views
  # Keep-alive: switching away from a provider and back must not reload its
  # web view or reset its session; each provider holds its own persistent
  # WKWebView instance. Verify by staying signed in to provider A, cycling
  # to provider B, cycling back to A — session and page state should be
  # unchanged.
  Scenario: Each provider retains its web session when the user switches away and back
    Given providers "Gemini" and "ChatGPT" are loaded and signed in
    When the user presses Ctrl+Tab
    And the user presses Ctrl+Tab
    Then the "Gemini" provider is in the same session state as before cycling
