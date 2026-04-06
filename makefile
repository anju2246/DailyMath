.PHONY: setup generate open build test clean

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

# Remove generated projects, caches, and derived data
clean:
	@rm -rf *.xcodeproj
	@rm -rf *.xcworkspace
	@rm -rf Tuist/Dependencies/Graph
	@tuist clean
