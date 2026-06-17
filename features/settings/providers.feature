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
