import SwiftUI

@main
struct NutriCareProApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if session.currentUser == nil {
                    LoginView()
                } else {
                    HomeView()
                }
            }
            .environmentObject(session)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ClinicalPalette.background.ignoresSafeArea())
        }
    }
}
