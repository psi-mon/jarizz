Feature: Hotkey string parsing

  # app-shell-010
  Scenario Outline: Hotkey string is parsed into key and modifiers
    When the hotkey string "<hotkey>" is parsed
    Then the key is "<key>"
    And the modifiers are "<modifiers>"

    Examples:
      | hotkey                   | key | modifiers                |
      | LeftShift+RightCommand+] | ]   | leftShift, rightCommand  |
