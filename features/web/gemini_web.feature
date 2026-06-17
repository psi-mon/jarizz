# mutation-stamp: sha256=77c8c1b140aa0b4a180d4a1ea2a62dd92cfbd5d1ac833b76cd3f630322c2f9fc
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-17T15:43:29Z","feature_name":"Gemini web provider","feature_path":"features/web/gemini_web.feature","background_hash":"1bbaaa5b74478580377aaf1cdca2c61009fe6d440cd42b6bc24681d801488cf3","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

Feature: Gemini web provider
  # Slice completion requires BOTH layers:
  # (a) JarizzCore — WebProviderAdapter protocol; AppShellController
  #     holds an adapter instance and calls navigate(to:) on first show.
  # (b) JarizzApp adapter — WKWebView with WKWebsiteDataStore.default();
  #     ASWebAuthenticationSession (prefersEphemeralWebBrowserSession=false)
  #     for Google sign-in and passkey flows; WKUIDelegate for non-auth
  #     in-app windows (web-008).
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
  Scenario: User can complete Google sign-in via system authentication session
    Given the panel is visible
    And the user is not signed in to Google
    When the user initiates Google sign-in
    Then jarizz presents a system authentication session for Google sign-in
    And after sign-in completes the user is signed in to Google in the panel

  # web-003
  # manual-only: requires live Google authentication
  # supersedes: in-app WKWebView popup for the primary Google auth flow
  # web-008 is retained: WKUIDelegate still handles non-auth window.open() calls
  Scenario: System authentication session can reuse an existing Google account
    Given the panel is visible
    And the user is not signed in to Google in the panel
    When jarizz presents a system authentication session
    Then the session can use an existing signed-in Google account from the system browser
    And after sign-in completes the user is signed in to Google in the panel

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
  # simulation-friendly: protocol compliance check for in-app non-auth windows
  Scenario: Web provider handles new windows inside the app
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider handles new windows inside the app

  # web-009
  # manual-only: requires live Google passkey authentication
  Scenario: Passkey sign-in works through system authentication session
    Given the panel is visible
    And the user is not signed in to Google
    When the user initiates passkey sign-in
    Then jarizz presents a system authentication session that supports passkeys
    And after sign-in completes the user is signed in to Google in the panel

  # web-010
  # simulation-friendly: protocol compliance — prefersEphemeralWebBrowserSession = false
  Scenario: Web provider system auth session is non-ephemeral
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider auth session is not ephemeral

  # web-011
  # manual-only: requires Gemini page loaded with input field present
  Scenario: Gemini input field is focused when the panel becomes visible
    Given Gemini is loaded and the input field is present
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the Gemini input field has focus

  # web-012
  # simulation-friendly: protocol compliance check
  Scenario: Web provider focuses the input field when the panel is shown
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider focuses the input field on show
