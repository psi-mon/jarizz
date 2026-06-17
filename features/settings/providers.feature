# mutation-stamp: sha256=08e82cd575d86a716f58c651b7a9ea61d28ec1c85fe37e6c5a2cc5e59b3289e0
# acceptance-mutation-manifest-begin
# {"version":1,"tested_at":"2026-06-17T15:43:29Z","feature_name":"Settings — Providers","feature_path":"features/settings/providers.feature","background_hash":"74234e98afe7498fb5daf1f36ac2d78acc339464f950703b8c019892f982b90b","implementation_hash":"unknown","scenarios":[{"index":1,"name":"User adds a web provider","scenario_hash":"2966a799ca5a281dffe2dda9b7c1a94e9a2ab9b69596ad0cb97bc1b07124d14d","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":2,"name":"User removes a web provider","scenario_hash":"d6601c54fad26bf2000d5bbad32f501fc595404c9a1f0a85b1fb04dc796372fb","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":3,"name":"User edits a web provider","scenario_hash":"19f5dbe4aa1db5d48c9a764376290bce6246e6fd134b64b12b59b58dc1f871c3","mutation_count":4,"result":{"Total":4,"Killed":4,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":4,"name":"User stars a provider as the default","scenario_hash":"9af6cc491c7d8d20db39e088e5275c69c99a010440ba1439fd16d38327246174","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":5,"name":"Starring a provider removes the star from the previous default","scenario_hash":"d3e4430b59c425f20ac31851db3b12b0dc588247a9de0f662a87db534dfe7e55","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":6,"name":"Panel loads the starred provider on show","scenario_hash":"758cf7beb4437d4158a5fb4a77144a52ddbf5c6281baf6acfa8f12c8ed934dc6","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":7,"name":"Panel loads the first provider when none is starred","scenario_hash":"82b84216aa97100998be780a22d1cc8929cee0d85722f2390169d44a32806f79","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":8,"name":"Provider with an invalid URL is rejected","scenario_hash":"45e5bed9e723756809456bfcaf27d932202f21986929e71767ac49b3653128fb","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":9,"name":"Provider with a duplicate URL is rejected","scenario_hash":"2655c8833121184fc57cc8e14753689e524a7869a2df0de17cddac88dc4c31c1","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":11,"name":"Configured providers persist after app restart","scenario_hash":"2d144ee9d9394e17020e74cbcde77f8aabfa86d431b6e91809eb88dd74b5ec96","mutation_count":2,"result":{"Total":2,"Killed":2,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"},{"index":12,"name":"Starred provider persists after app restart","scenario_hash":"d681c49f7b92293a367143cadfffab81a226fa66340160fd03a752441559eb3f","mutation_count":1,"result":{"Total":1,"Killed":1,"Survived":0,"Errors":0},"tested_at":"2026-06-17T15:26:41Z"}]}
# acceptance-mutation-manifest-end

Feature: Settings — Providers
  # Persistence: ~/Library/Application Support/jarizz/settings.json
  # Schema fields per provider: id (UUID), name (non-empty string),
  #   url (valid http/https URL), starred (boolean; at most one true).
  # Provider array order determines display order.
  # All changes apply immediately and auto-save; no explicit Save button.

  # provider-001
  # simulation-friendly
  Scenario: Panel shows a placeholder when no providers are configured
    Given the app is running
    And no providers are configured
    When the user shows the panel
    Then the panel displays "Add a provider in Settings to get started"

  # provider-002
  # simulation-friendly
  Scenario Outline: User adds a web provider
    Given the app is running
    And the Settings window is open on the Providers tab
    When the user adds a provider with name "<name>" and URL "<url>"
    Then the provider "<name>" with URL "<url>" is in the provider list

    Examples:
      | name   | url                           |
      | Gemini | https://gemini.google.com/app |

  # provider-003
  # simulation-friendly
  Scenario Outline: User removes a web provider
    Given the app is running
    And the Settings window is open on the Providers tab
    And a provider with name "<name>" and URL "<url>" exists
    When the user removes the provider "<name>"
    Then the provider "<name>" is not in the provider list

    Examples:
      | name   | url                           |
      | Gemini | https://gemini.google.com/app |

  # provider-004
  # simulation-friendly
  Scenario Outline: User edits a web provider
    Given the app is running
    And the Settings window is open on the Providers tab
    And a provider with name "<old_name>" and URL "<old_url>" exists
    When the user edits the provider name to "<new_name>" and URL to "<new_url>"
    Then the provider "<new_name>" with URL "<new_url>" is in the provider list
    And the provider "<old_name>" is not in the provider list

    Examples:
      | old_name | old_url             | new_name | new_url             |
      | Old Name | https://old.example | New Name | https://new.example |

  # provider-005
  # simulation-friendly
  Scenario Outline: User stars a provider as the default
    Given the app is running
    And the Settings window is open on the Providers tab
    And a provider with name "<name>" exists
    When the user stars the provider "<name>"
    Then the provider "<name>" is starred

    Examples:
      | name   |
      | Gemini |

  # provider-006
  # simulation-friendly
  Scenario Outline: Starring a provider removes the star from the previous default
    Given the app is running
    And the Settings window is open on the Providers tab
    And a provider with name "<first>" is starred
    And a provider with name "<second>" exists
    When the user stars the provider "<second>"
    Then the provider "<second>" is starred
    And the provider "<first>" is not starred

    Examples:
      | first  | second  |
      | Gemini | ChatGPT |

  # provider-007
  # simulation-friendly
  Scenario Outline: Panel loads the starred provider on show
    Given the app is running
    And a provider with name "<name>" and URL "<url>" is starred
    When the user shows the panel
    Then the web provider has navigated to "<url>"

    Examples:
      | name   | url                           |
      | Gemini | https://gemini.google.com/app |

  # provider-008
  # simulation-friendly
  Scenario Outline: Panel loads the first provider when none is starred
    Given the app is running
    And no provider is starred
    And the first provider in the list has URL "<url>"
    When the user shows the panel
    Then the web provider has navigated to "<url>"

    Examples:
      | url                           |
      | https://gemini.google.com/app |

  # provider-009
  # simulation-friendly
  Scenario Outline: Provider with an invalid URL is rejected
    Given the app is running
    And the Settings window is open on the Providers tab
    When the user tries to add a provider with name "Test" and URL "<url>"
    Then the provider is not added
    And the error "Invalid URL" is shown

    Examples:
      | url       |
      | not-a-url |
      | http://   |

  # provider-010
  # simulation-friendly
  Scenario Outline: Provider with a duplicate URL is rejected
    Given the app is running
    And the Settings window is open on the Providers tab
    And a provider with URL "<url>" already exists
    When the user tries to add a provider with name "Duplicate" and URL "<url>"
    Then the provider is not added
    And the error "URL already in use" is shown

    Examples:
      | url                           |
      | https://gemini.google.com/app |

  # provider-011
  # simulation-friendly
  Scenario: Provider with an empty name is rejected
    Given the app is running
    And the Settings window is open on the Providers tab
    When the user tries to add a provider with name "" and URL "https://gemini.google.com/app"
    Then the provider is not added
    And the error "Name is required" is shown

  # provider-012
  # simulation-friendly: tests round-trip serialisation
  Scenario Outline: Configured providers persist after app restart
    Given the app is running
    And a provider with name "<name>" and URL "<url>" has been added
    When the app is restarted
    Then the provider "<name>" with URL "<url>" is in the provider list

    Examples:
      | name   | url                           |
      | Gemini | https://gemini.google.com/app |

  # provider-013
  # simulation-friendly: tests round-trip serialisation
  Scenario Outline: Starred provider persists after app restart
    Given the app is running
    And the provider "<name>" is starred
    When the app is restarted
    Then the provider "<name>" is starred

    Examples:
      | name   |
      | Gemini |
