import SwiftUI

struct ContentView: View {
    @StateObject private var vm: PositiveNoteViewModel
    
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
            if vm.note.isEmpty { vm.refresh() }
            scheduleMindfulnessForNextDays()
        }
        .padding()
    }
}

#if DEBUG

#Preview("Real provider") {
    ContentView()
}

#endif

