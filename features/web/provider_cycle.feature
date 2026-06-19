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
