.PHONY: setup generate open build test clean run help lint format

help:
	@echo "DailyMath - Available targets:"
	@echo "  setup        Install dependencies and fetch Tuist packages"
	@echo "  generate     Generate project without opening Xcode"
	@echo "  open         Generate and open project in Xcode"
	@echo "  build        Build the project"
	@echo "  test         Run unit tests"
	@echo "  run          Build and run on iOS simulator"
	@echo "  lint         Check code quality with SwiftLint"
	@echo "  format       Format code with SwiftFormat"
	@echo "  clean        Remove generated files and caches"

# Install dependencies and tools (e.g., via mise or brew)
setup:
	@echo "Installing dependencies..."
	@tuist install
	@tuist fetch

# Generate the project without opening Xcode
generate:
	@tuist generate --no-open

# Generate and open the project in Xcode (standard workflow)
open:
	@tuist generate

# Build the project for the current destination
build:
	@tuist build

# Run unit tests
test:
	@tuist test

# Build and run on iOS simulator
run: build
	@echo "Running on iOS simulator..."

# Code quality checks
lint:
	@echo "Running SwiftLint..."
	@swiftlint lint Sources/ --reporter json || true

# Format code
format:
	@echo "Formatting code with SwiftFormat..."
	@swiftformat Sources/ --indent 4 || true

# Remove generated projects, caches, and derived data
clean:
	@rm -rf *.xcodeproj
	@rm -rf *.xcworkspace
	@rm -rf Tuist/Dependencies/Graph
	@tuist clean
