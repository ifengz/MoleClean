import SwiftUI

struct SidebarView: View {
    @Binding var selection: SidebarItem?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                brandHeader

                sidebarSection("Monitor", items: [.status, .diskAnalyzer])
                sidebarSection("Cleanup", items: [.clean, .purge, .installer, .optimize, .uninstall])
                sidebarSection("App", items: [.settings])
            }
            .padding(.horizontal, 14)
            .padding(.top, 50)
            .padding(.bottom, 16)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(MoleTheme.parchment)
    }

    private var brandHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(MoleTheme.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Mole Clean")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(MoleTheme.ink)

                Text("System care for macOS")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
    }

    private func sidebarSection(_ title: LocalizedStringKey, items: [SidebarItem]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .textCase(.uppercase)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .tracking(0.8)
                .foregroundStyle(MoleTheme.primary)
                .padding(.horizontal, 4)

            VStack(spacing: 4) {
                ForEach(items) { item in
                    sidebarRow(item)
                }
            }
        }
    }

    private func sidebarRow(_ item: SidebarItem) -> some View {
        let isSelected = selection == item

        return Button {
            selection = item
        } label: {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : MoleTheme.primary)
                    .frame(width: 24, height: 24)

                Text(item.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(isSelected ? Color.white : MoleTheme.ink)

                Spacer(minLength: 6)
            }
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: MoleTheme.radiusSm, style: .continuous)
                    .fill(isSelected ? MoleTheme.primary : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: MoleTheme.radiusSm, style: .continuous)
                    .stroke(isSelected ? Color.white.opacity(0.15) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
