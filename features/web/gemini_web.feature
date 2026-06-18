# mutation-stamp: sha256=cd3998be38b4dbb94a8ca3f6b12d12deb9402d0ec321f5f3d531df93f7db549c
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-18T12:58:40Z","feature_name":"Gemini web provider","feature_path":"features/web/gemini_web.feature","background_hash":"1bbaaa5b74478580377aaf1cdca2c61009fe6d440cd42b6bc24681d801488cf3","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

Feature: Gemini web provider
  # Slice completion requires BOTH layers:
  # (a) JarizzCore — WebProviderAdapter protocol; AppShellController
  #     holds an adapter instance and calls navigate(to:) on first show.
  # (b) JarizzApp adapter — WKWebView with WKWebsiteDataStore.default();
  #     ASWebAuthenticationSession (prefersEphemeralWebBrowserSession=false,
  #     presentationContextProvider set to the panel window) triggered when
  #     the web view navigates to a Google auth URL; WKUIDelegate for
  #     non-auth window.open() calls (web-008).
  # Simulation-friendly scenarios use MockWebProviderAdapter and cannot
  # be satisfied by a plain constant on AppShellController.
  #
  # Cookie scope:
  # - ASWebAuthenticationSession with prefersEphemeralWebBrowserSession=false
  #   uses Safari's cookie store; an existing Google session in Safari is
  #   reused without re-entering credentials.
  # - WKWebView uses WKWebsiteDataStore.default(), a store separate from
  #   Safari's. Auth results must be explicitly bridged (cookie injection or
  #   re-navigation to Gemini) after ASWebAuthenticationSession completes.
  # - Chrome's cookie store is never accessible; Chrome sign-in state has
  #   no effect on jarizz authentication.

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
  Scenario: User can complete Google sign-in via ASWebAuthenticationSession
    Given the panel is visible
    And the user is not signed in to Google
    When the user initiates Google sign-in
    Then jarizz presents an ASWebAuthenticationSession for Google sign-in
    And after sign-in completes the user is signed in to Google in the panel

  # web-003
  # manual-only: requires live Google authentication
  # Cookie note: ASWebAuthenticationSession uses Safari's store; auth result
  # must be bridged into WKWebView's separate store for Gemini to see it.
  Scenario: ASWebAuthenticationSession reuses an existing Google account from Safari
    Given the panel is visible
    And the user is not signed in to Google in the panel
    And the user is signed in to Google in Safari
    When jarizz presents an ASWebAuthenticationSession
    Then the session completes without re-entering credentials
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
  Scenario: Passkey sign-in works through ASWebAuthenticationSession
    Given the panel is visible
    And the user is not signed in to Google
    When the user initiates passkey sign-in
    Then jarizz presents an ASWebAuthenticationSession that supports passkeys
    And after sign-in completes the user is signed in to Google in the panel

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

  # web-013
  # simulation-friendly: verifies startAuthSession is called, not a boolean flag
  # Requires WebProviderAdapter.startAuthSession(for:callbackScheme:) and
  # authSessionTriggerCount; authSessionIsNonEphemeral verified alongside count.
  Scenario: Web provider triggers an ASWebAuthenticationSession when sign-in is initiated
    Given the panel is visible
    When the user initiates Google sign-in
    Then the web provider auth session trigger count is "1"
    And the web provider auth session is not ephemeral

  # web-014
  # simulation-friendly: verifies auth result is bridged into the web view
  # Requires WebProviderAdapter.handleAuthCallback(url:) and hasBridgedAuthResult.
  Scenario: Auth result is bridged into the web view after the session completes
    Given the panel is visible
    And the user has initiated Google sign-in
    When the auth session completes with callback URL "com.jarizz.auth://callback"
    Then the web provider has bridged the auth result to the web view
