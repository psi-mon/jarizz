# mutation-stamp: sha256=494a7ea08ab12d29625a075452b38e907e8210e9203ddee4937adf1921196849
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-15T13:13:42Z","feature_name":"Hotkey string parsing","feature_path":"features/core/hotkey_parse.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[{"index":0,"name":"Hotkey string is parsed into key and modifiers","scenario_hash":"e91b7102602d08ce220eca362cb9924004a97f606fb99a6385915eeaacdb528a","mutation_count":3,"result":{"Total":3,"Killed":3,"Survived":0,"Errors":0},"tested_at":"2026-06-12T17:06:03Z"}]}
# acceptance-mutation-manifest-end

Feature: Hotkey string parsing

  # app-shell-010
  Scenario Outline: Hotkey string is parsed into key and modifiers
    When the hotkey string "<hotkey>" is parsed
    Then the key is "<key>"
    And the modifiers are "<modifiers>"

    Examples:
      | hotkey                   | key | modifiers                |
      | LeftShift+RightCommand+] | ]   | leftShift, rightCommand  |
