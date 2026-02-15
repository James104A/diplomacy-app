import SwiftUI

// ContentView is retained for backward compatibility with Xcode project references.
// The app entry point (DiplomacyApp.swift) now uses AppTabView directly.

struct ContentView: View {
    var body: some View {
        AppTabView()
            .environmentObject(AppState())
    }
}

#Preview {
    ContentView()
}
