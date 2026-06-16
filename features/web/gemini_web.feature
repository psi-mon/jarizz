# mutation-stamp: sha256=02eeea2ce8c2aa5195705a0ac89d902c34d0938c3a91f3c27ac68dadd1d10fa6
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-16T14:06:05Z","feature_name":"Gemini web provider","feature_path":"features/web/gemini_web.feature","background_hash":"1bbaaa5b74478580377aaf1cdca2c61009fe6d440cd42b6bc24681d801488cf3","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

Feature: Gemini web provider
  # Slice completion requires BOTH layers:
  # (a) JarizzCore — WebProviderAdapter protocol; AppShellController
  #     holds an adapter instance and calls navigate(to:) on first show.
  # (b) JarizzApp adapter — WKWebView replacing PlaceholderView,
  #     WKWebsiteDataStore.default() for persistence, WKUIDelegate for
  #     in-app OAuth popups.
  # Simulation-friendly scenarios use MockWebProviderAdapter and cannot
  # be satisfied by a plain constant on AppShellController.

  Background:
    Given the app is running
    And a web provider is configured with URL "https://gemini.google.com/app"
    And the panel is hidden

  # web-001
  # simulation-friendly
  Scenario: Panel navigates the web provider to the Gemini URL on first show
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider has navigated to "https://gemini.google.com/app"

  # web-002
  # manual-only: requires live Google authentication
  Scenario: User can complete Google sign-in inside the panel
    Given the panel is visible
    And the user is not signed in to Google
    When the user completes Google sign-in inside the panel
    Then the user is signed in to Google inside the panel

  # web-003
  # manual-only: requires live Google authentication
  Scenario: Google authentication popup opens inside the app
    Given the panel is visible
    And the user has initiated Google sign-in
    When Google authentication requires a secondary window
    Then the secondary window opens inside the app
    And the user can complete sign-in without switching to an external browser

  # web-004
  # simulation-friendly
  Scenario: Hiding and showing the panel does not reload the web provider
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    And the user presses the global hotkey "LeftShift+RightCommand+]"
    And the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider navigation count is "1"

  # web-005
  # manual-only: requires live Google authentication and app restart
  Scenario: Google session persists after the app is restarted
    Given the user is signed in to Google inside the panel
    When the user quits the app
    And the user launches the app
    And the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the user is signed in to Google inside the panel

  # web-006
  # simulation-friendly
  Scenario: Panel shows an error message when the network is unavailable
    Given the network is unavailable
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel displays "No network connection — check your internet and try again"

  # web-007
  # simulation-friendly: protocol compliance check for session persistence
  Scenario: Web provider uses persistent session storage
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider uses persistent session storage

  # web-008
  # simulation-friendly: protocol compliance check for in-app OAuth windows
  Scenario: Web provider handles new windows inside the app
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider handles new windows inside the app
