import Foundation
import Combine

extension FlashcardStore: FlashcardRepository {
	var objectWillChangePublisher: AnyPublisher<Void, Never> {
		objectWillChange.eraseToAnyPublisher()
	}
}
