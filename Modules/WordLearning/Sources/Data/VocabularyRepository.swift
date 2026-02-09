import Foundation

public protocol VocabularyRepository: Sendable {
    func loadWords() async throws -> [VocabularyWord]
}

public struct LocalVocabularyRepository: VocabularyRepository {
    public init() {}

    public func loadWords() async throws -> [VocabularyWord] {
        [
            VocabularyWord(
                word: "Casa",
                imageURL: URL(string: "https://openclipart.org/image/800px/svg_to_png/166549/simplehut.png")!,
                source: "OpenClipart"
            ),
            VocabularyWord(
                word: "Persona",
                imageURL: URL(string: "https://openclipart.org/image/800px/svg_to_png/21966/rejon_Person_Outline_1.png")!,
                source: "OpenClipart"
            ),
            VocabularyWord(
                word: "Grupo",
                imageURL: URL(string: "https://openclipart.org/image/800px/svg_to_png/139699/Group.png")!,
                source: "OpenClipart"
            ),
            VocabularyWord(
                word: "Reloj",
                imageURL: URL(string: "https://openclipart.org/image/300px/svg_to_png/196813/mono-clock.png")!,
                source: "OpenClipart"
            ),
            VocabularyWord(
                word: "Sombrero",
                imageURL: URL(string: "https://openclipart.org/image/300px/svg_to_png/189636/Chef-Hat--Arvin61r58.png")!,
                source: "OpenClipart"
            )
        ]
    }
}
