# mutation-stamp: sha256=7ef09aac1be7ecd2da7a4e4cb1dfb74a689df5ab158a0764e0e88e4f9d833cdb
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-18T12:58:40Z","feature_name":"Menubar icon","feature_path":"features/app_shell/menubar.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[]}
# acceptance-mutation-manifest-end

Feature: Menubar icon

  # app-shell-001
  Scenario: App shows menubar icon on launch
    Given the app is not running
    When the app launches
    Then a menubar status item is visible

  # app-shell-002
  Scenario: App has no Dock icon
    Given the app is not running
    When the app launches
    Then the app does not appear in the Dock
