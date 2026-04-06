import Foundation
import Combine

extension AuthService: AuthRepository {
	var isAuthenticatedPublisher: AnyPublisher<Bool, Never> {
		$isAuthenticated.eraseToAnyPublisher()
	}

	var isLoadingPublisher: AnyPublisher<Bool, Never> {
		$isLoading.eraseToAnyPublisher()
	}

	var errorMessagePublisher: AnyPublisher<String?, Never> {
		$errorMessage.eraseToAnyPublisher()
	}

	var objectWillChangePublisher: AnyPublisher<Void, Never> {
		objectWillChange.eraseToAnyPublisher()
	}
}
