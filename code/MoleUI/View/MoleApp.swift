import SwiftUI

@main
struct MoleApp: App {
    @AppStorage("appLanguage") private var appLanguageRaw = AppLanguage.english.rawValue
    @State private var metricsModel = MetricsModel()
    @State private var cleanModel = CleanModel()
    @State private var optimizeModel = OptimizeModel()
    @State private var purgeModel = PurgeModel()
    @State private var installerModel = InstallerModel()
    @State private var diskModel = DiskModel()
    @State private var appScanModel = AppScanModel()
    @State private var uninstallModel = UninstallModel()
    @State private var safetyController = SafetyController()
    @State private var versionModel = VersionModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, selectedLanguage.locale)
                .environment(metricsModel)
                .environment(cleanModel)
                .environment(optimizeModel)
                .environment(purgeModel)
                .environment(installerModel)
                .environment(diskModel)
                .environment(appScanModel)
                .environment(uninstallModel)
                .environment(safetyController)
                .environment(versionModel)
                .groupBoxStyle(MolePanelGroupBoxStyle())
                .tint(MoleTheme.primary)
                .frame(minWidth: 980, minHeight: 700)
                .onAppear {
                    // Wire up model references for metrics pause coordination
                    // This must be done after models are initialized
                    metricsModel.cleanModel = cleanModel
                    metricsModel.optimizeModel = optimizeModel
                }
        }
        .defaultSize(width: 1120, height: 760)
        .windowResizability(.contentMinSize)
    }

    private var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: appLanguageRaw) ?? .english
    }
}
