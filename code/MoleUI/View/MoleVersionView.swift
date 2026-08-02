import SwiftUI

/// Mole Clean version information display
struct MoleVersionView: View {
    @Environment(VersionModel.self) var versionChecker
    let bundledCLIVersion: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Version Details", systemImage: "app.badge")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                if versionChecker.isChecking {
                    ProgressView()
                        .controlSize(.small)
                        .frame(width: 16, height: 16)
                } else {
                    Button {
                        Task {
                            await versionChecker.checkForUpdates()
                        }
                    } label: {
                        Label("Check for Updates", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.link)
                }
            }

            HStack(spacing: 12) {
                versionChip(
                    title: "Mole Clean",
                    value: versionChecker.currentVersion ?? "Unknown",
                    systemImage: "app.badge.fill",
                    tint: MoleTheme.primary
                )
                versionChip(
                    title: "Bundled CLI",
                    value: bundledCLIVersion ?? "Unknown",
                    systemImage: "terminal.fill",
                    tint: MoleTheme.primaryDark
                )
            }

            if let latestVersion = versionChecker.latestVersion {
                HStack {
                    Text("Latest release")
                        .foregroundStyle(.secondary)
                    Text(latestVersion)
                        .fontWeight(.medium)

                    if versionChecker.hasUpdate {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .font(.callout)
                if versionChecker.hasUpdate {
                    HStack {
                        Text("Update available")
                            .font(.caption)
                            .foregroundColor(.orange)

                        Spacer()

                        Link("View Release", destination: URL(string: "https://github.com/imnotnoahhh/MoleUI/releases/latest")!)
                            .font(.caption)
                    }
                } else {
                    Text("This build is already on the latest published Mole Clean release.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let updateError = versionChecker.updateError {
                Text("Update check failed: \(updateError)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
            } else {
                Text("Latest release has not been checked yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(MoleTheme.parchment, in: RoundedRectangle(cornerRadius: MoleTheme.radiusMd, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MoleTheme.radiusMd, style: .continuous)
                .stroke(MoleTheme.line, lineWidth: 1)
        )
        .task {
            await versionChecker.loadCurrentVersion()
        }
    }

    private func versionChip(title: LocalizedStringKey, value: String, systemImage: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: MoleTheme.radiusMd, style: .continuous)
                .fill(tint.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: MoleTheme.radiusMd, style: .continuous)
                .stroke(tint.opacity(0.14), lineWidth: 1)
        )
    }
}
