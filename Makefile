.PHONY: all help get format-check format analyze test verify

all: verify

help:
	@echo "Recova Mobile Client — Build & Verification Targets"
	@echo "  make verify        Run full verification suite (get, format-check, analyze, test)"
	@echo "  make format-check  Verify code formatting without writing changes"
	@echo "  make format        Apply standard Dart code formatting"
	@echo "  make analyze       Run static code analysis"
	@echo "  make test          Run automated unit tests"
	@echo "  make get           Fetch project dependencies"

get:
	flutter pub get

format-check:
	dart format --output=none --set-exit-if-changed .

format:
	dart format .

analyze:
	flutter analyze

test:
	flutter test

verify: get format-check analyze test
