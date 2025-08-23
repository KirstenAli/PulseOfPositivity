import Combine

final class PositiveNoteViewModel: ObservableObject {
    @Published var note: String = ""
    private let provider: PositiveNoteProviding
    
    init(provider: PositiveNoteProviding) {
        self.provider = provider
    }
    
    func refresh() {
        note = provider.randomNote()
    }
}

