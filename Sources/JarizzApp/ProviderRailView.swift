import SwiftUI
import JarizzCore

struct ProviderRailView: View {
    @ObservedObject var vm: SettingsViewModel
    var onSelectProvider: (String) -> Void

    var body: some View {
        Group {
            if !vm.controller.settings.providers.isEmpty {
                railContent
            }
        }
    }

    private var railContent: some View {
        VStack(spacing: 2) {
            if !vm.controller.railIsCollapsed {
                ForEach(vm.controller.settings.providers) { provider in
                    providerButton(for: provider)
                }
            }
            toggleButton
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .padding(.trailing, 4)
    }

    private func providerButton(for provider: Provider) -> some View {
        let isActive = vm.controller.providerButtonIsActive(named: provider.name)
        return Button { onSelectProvider(provider.name) } label: {
            Text(displayName(provider.name))
                .font(.caption)
                .lineLimit(1)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .frame(minWidth: 44)
                .background(isActive ? Color.accentColor.opacity(0.25) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(
                            isActive ? Color.accentColor : Color.secondary.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(provider.name)
    }

    private var toggleButton: some View {
        Button {
            if vm.controller.railIsCollapsed { vm.controller.expandRail() }
            else { vm.controller.collapseRail() }
        } label: {
            Image(systemName: vm.controller.railIsCollapsed ? "chevron.left" : "chevron.right")
                .frame(width: 20, height: 20)
        }
        .buttonStyle(.plain)
        .help(vm.controller.railIsCollapsed ? "Expand provider rail" : "Collapse provider rail")
        .accessibilityLabel(vm.controller.railIsCollapsed ? "Expand rail" : "Collapse rail")
    }

    private func displayName(_ name: String) -> String {
        name.count <= 12 ? name : String(name.prefix(11)) + "…"
    }
}
