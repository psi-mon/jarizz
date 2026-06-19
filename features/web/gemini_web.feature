# mutation-stamp: sha256=5a676251a90064313f408fa1d941be2d3fec72850a9d0d57c9eb648cd408e6c7
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-19T13:50:14Z","feature_name":"Gemini web provider","feature_path":"features/web/gemini_web.feature","background_hash":"1bbaaa5b74478580377aaf1cdca2c61009fe6d440cd42b6bc24681d801488cf3","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

Feature: Gemini web provider
  # Slice completion requires BOTH layers:
  # (a) JarizzCore — WebProviderAdapter protocol; AppShellController
  #     holds an adapter instance and calls navigate(to:) on first show.
  # (b) JarizzApp adapter — WKWebView with WKWebsiteDataStore.default()
  #     for navigation, sign-in, and persistent sessions; WKUIDelegate for
  #     in-app popup windows opened by Google's sign-in flow.
  # Simulation-friendly scenarios use MockWebProviderAdapter and cannot
  # be satisfied by a plain constant on AppShellController.
  #
  # Authentication model:
  # - Google sign-in happens entirely inside the panel WKWebView using the
  #   same WKWebsiteDataStore.default() session store.
  # - No external browser, system sheet, or cross-app cookie bridge is used.
  # - Default browser (Safari or Chrome) has no effect on sign-in.
  # - Session cookies persist in WKWebsiteDataStore.default() across panel
  #   hide/show and app restarts.
  #
  # Passkeys: out of scope for v1. WKWebView passkey support requires
  # additional macOS entitlements. Users should choose "Try another way"
  # in Google's sign-in UI and use email/password instead.

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
  Scenario: User can sign in to Google directly in the panel
    Given the panel is visible
    And the user is not signed in to Google
    When the user enters their Google credentials in the sign-in form
    Then the user is signed in to Google inside the panel

  # web-003 retired: Safari account reuse via ASWebAuthenticationSession —
  # default browser is irrelevant; sign-in happens in-panel via WKWebView

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
  # simulation-friendly: protocol compliance — WKUIDelegate opens secondary
  # windows (e.g. Google sign-in popups) inside the panel, not externally.
  Scenario: Web provider handles new windows inside the app
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web provider handles new windows inside the app

  # web-009 retired: passkey sign-in via ASWebAuthenticationSession —
  # out of scope for v1; users use email/password or "Try another way"

  # web-010 retired: boolean authSessionIsNonEphemeral flag — subsumed into web-013

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

  # web-013 retired: ASWebAuthenticationSession trigger count —
  # auth session approach removed; sign-in is in-panel via WKWebView

  # web-014 retired: auth cookie bridge —
  # auth session approach removed; WKWebsiteDataStore.default() handles persistence
