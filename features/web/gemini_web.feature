Feature: Gemini web provider

  Background:
    Given the app is running
    And the panel is hidden

  # web-001
  # simulation-friendly
  Scenario: Panel loads the Gemini web app on first show
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the panel content URL is "https://gemini.google.com/app"

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
  Scenario: Hiding and showing the panel does not reload the web view
    When the user presses the global hotkey "LeftShift+RightCommand+]"
    And the user presses the global hotkey "LeftShift+RightCommand+]"
    And the user presses the global hotkey "LeftShift+RightCommand+]"
    Then the web view navigation count is "1"

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
