import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.europe.africa")
                .imageScale(.large)
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Diplomacy")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
