import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var vm: PositiveNoteViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    init(provider: PositiveNoteProviding = DefaultPositiveNoteProvider()) {
        _vm = StateObject(wrappedValue: PositiveNoteViewModel(provider: provider))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(vm.note.isEmpty ? "…" : vm.note)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .task {
            vm.refresh()
            scheduleMindfulnessForNextDays()
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else { return }
            vm.refresh()
            playNotificationHaptic()
        }
        .padding()
    }
    
    @MainActor
    private func playNotificationHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
}

#if DEBUG

#Preview("Real provider") {
    ContentView()
}

#endif

