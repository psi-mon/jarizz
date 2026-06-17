import SwiftUI
import JarizzCore

extension Provider: Identifiable {}

struct NoProviderView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Add a provider in Settings to get started")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SettingsView: View {
    @ObservedObject var vm: SettingsViewModel
    var onHotkeyChange: () -> Void
    var onProvidersChange: () -> Void

    var body: some View {
        TabView {
            GeneralSettingsView(vm: vm, onHotkeyChange: onHotkeyChange)
                .tabItem { Label("General", systemImage: "gear") }
            ProvidersSettingsView(vm: vm, onProvidersChange: onProvidersChange)
                .tabItem { Label("Providers", systemImage: "network") }
        }
        .frame(width: 480, height: 360)
        .padding(8)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var vm: SettingsViewModel
    var onHotkeyChange: () -> Void
    @State private var hotkeyText = ""
    @State private var hotkeyError = ""

    var body: some View {
        Form {
            Section("Global Hotkey") {
                TextField("Hotkey", text: $hotkeyText)
                    .onSubmit(applyHotkey)
                if !hotkeyError.isEmpty {
                    Text(hotkeyError).foregroundColor(.red).font(.caption)
                }
                Text("Example: LeftShift+RightCommand+]  — press Return to apply")
                    .font(.caption).foregroundColor(.secondary)
            }
            Section("Panel Size") {
                HStack {
                    Slider(
                        value: Binding(
                            get: { Double(vm.controller.settings.panelSizePercent) },
                            set: { vm.controller.setPanelSizePercent(Int($0)) }
                        ),
                        in: 20...90,
                        step: 5
                    )
                    Text("\(vm.controller.settings.panelSizePercent)%")
                        .frame(width: 44, alignment: .trailing)
                        .monospacedDigit()
                }
            }
        }
        .padding()
        .onAppear { hotkeyText = vm.controller.settings.hotkey }
    }

    private func applyHotkey() {
        guard (try? Hotkey.parse(hotkeyText)) != nil else {
            hotkeyError = "Invalid hotkey — use format LeftShift+RightCommand+]"
            return
        }
        hotkeyError = ""
        vm.controller.setHotkey(hotkeyText)
        onHotkeyChange()
    }
}

struct ProvidersSettingsView: View {
    @ObservedObject var vm: SettingsViewModel
    var onProvidersChange: () -> Void
    @State private var selectedID: UUID?
    @State private var showAdd = false
    @State private var newName = ""
    @State private var newURL = ""
    @State private var addError = ""

    private var selectedProvider: Provider? {
        vm.controller.settings.providers.first { $0.id == selectedID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            List(vm.controller.settings.providers, selection: $selectedID) { provider in
                HStack {
                    Text(provider.starred ? "★" : "☆")
                        .foregroundColor(provider.starred ? .yellow : .secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(provider.name).fontWeight(.medium)
                        Text(provider.url).font(.caption).foregroundColor(.secondary)
                    }
                }
                .tag(provider.id)
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            HStack(spacing: 4) {
                Button("+") { showAdd = true }
                    .help("Add provider")
                Button("-") { removeSelected() }
                    .disabled(selectedProvider == nil)
                    .help("Remove selected provider")
                Spacer()
                Button("Set as Default") { starSelected() }
                    .disabled(selectedProvider == nil || selectedProvider?.starred == true)
            }
            .padding(.top, 2)
        }
        .padding()
        .sheet(isPresented: $showAdd) {
            AddProviderSheet(name: $newName, url: $newURL, error: $addError, onAdd: addProvider, onCancel: cancelAdd)
        }
    }

    private func removeSelected() {
        guard let name = selectedProvider?.name else { return }
        vm.controller.removeProvider(named: name)
        selectedID = nil
        onProvidersChange()
    }

    private func starSelected() {
        guard let name = selectedProvider?.name else { return }
        vm.controller.starProvider(named: name)
        onProvidersChange()
    }

    private func addProvider() {
        do {
            try vm.controller.addProvider(name: newName, url: newURL)
            newName = ""; newURL = ""; addError = ""
            showAdd = false
            onProvidersChange()
        } catch ProviderError.invalidURL   { addError = "Invalid URL" }
          catch ProviderError.duplicateURL { addError = "URL already in use" }
          catch ProviderError.nameRequired { addError = "Name is required" }
          catch                            { addError = "Unknown error" }
    }

    private func cancelAdd() {
        newName = ""; newURL = ""; addError = ""
        showAdd = false
    }
}

struct AddProviderSheet: View {
    @Binding var name: String
    @Binding var url: String
    @Binding var error: String
    var onAdd: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Provider").font(.headline)
            LabeledContent("Name") { TextField("e.g. Gemini", text: $name) }
            LabeledContent("URL")  { TextField("https://…", text: $url) }
            if !error.isEmpty {
                Text(error).foregroundColor(.red).font(.caption)
            }
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Add", action: onAdd).buttonStyle(.borderedProminent)
                    .disabled(name.isEmpty || url.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
