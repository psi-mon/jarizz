# mutation-stamp: sha256=b5550a4a7974a00de46dc0ce8800d1b32e777724fa28b53c56e37d08849bbcaf
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-22T12:10:17Z","feature_name":"Provider cycle","feature_path":"features/web/provider_cycle.feature","background_hash":"c0e5c2e3b93bd517ac3d1c6e2406d0cf5c4cac1ffffa926fab3dd06ef53b850b","implementation_hash":"unknown","scenarios":[{"index":3,"name":"Panel navigates to the next provider's URL when Ctrl+Tab is pressed","scenario_hash":"dd3ecbc54aff953c01241fa667f02bd5a6ad7013a743b731a820c198457aed58","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-22T12:02:22Z"},{"index":4,"name":"Panel navigates through all three providers' URLs without skipping","scenario_hash":"a8124c2d31d021d615e9692000dd2957898f6fcba426ff3b93217a92ba50fb42","mutation_count":3,"result":{"Total":3,"Killed":3,"Survived":0,"Errors":0},"tested_at":"2026-06-22T12:02:22Z"},{"index":0,"name":"Ctrl+Tab cycles to the next provider in the list","scenario_hash":"e7b0007f9cccdf503551b5433c15ee2f9a421009ebb4db12a15836186439abbe","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-19T13:50:14Z"},{"index":1,"name":"Cycling wraps from the last provider back to the first","scenario_hash":"96ab4d2012ded03207ac21a1ca005e9a9710d98c88ad14a34617fc8076f92d2c","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-19T13:50:14Z"}]}
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
  # simulation-friendly: verifies panel web adapter navigates to next provider's URL after Ctrl+Tab
  Scenario Outline: Panel navigates to the next provider's URL when Ctrl+Tab is pressed
    Given providers "<first>" and "<second>" are configured in that order
    And the panel is showing the web view for provider "<first>"
    When the user presses Ctrl+Tab
    Then the web provider has navigated to the URL of provider "<second>"

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # cycle-006
  # simulation-friendly: with three providers, every Ctrl+Tab navigates to the next provider's URL
  Scenario Outline: Panel navigates through all three providers' URLs without skipping
    Given providers "<p1>", "<p2>", and "<p3>" are configured in that order
    And the panel is showing the web view for provider "<p1>"
    When the user presses Ctrl+Tab
    Then the web provider has navigated to the URL of provider "<p2>"
    When the user presses Ctrl+Tab
    Then the web provider has navigated to the URL of provider "<p3>"
    When the user presses Ctrl+Tab
    Then the web provider has navigated to the URL of provider "<p1>"

    Examples:
      | p1     | p2      | p3      |
      | Gemini | ChatGPT | Copilot |

  # cycle-007
  # manual-only: requires live app; verifies AppDelegate registers a local Ctrl+Tab key monitor
  # that calls cycleProvider() and replaces the panel content with the next provider's web view.
  # The simulation scenarios (cycle-005, cycle-006) model the JarizzCore behaviour only;
  # this scenario is the acceptance gate for the AppDelegate adapter layer.
  Scenario: Ctrl+Tab in the running app cycles the visible provider
    Given the app is running with providers "Gemini" and "ChatGPT" configured
    And the panel is visible showing "Gemini"
    When the user presses Ctrl+Tab on the keyboard
    Then the panel is displaying "ChatGPT"

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
