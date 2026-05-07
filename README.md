# recova

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Temporary local auth (development)

The project includes a temporary non-Firebase authentication flow to avoid
using the Firebase Console during development. Changes made:

- `lib/services/auth_service.dart` now exposes:
	- `signInWithGoogle()` — existing Google OAuth flow (unchanged)
	- `signInWithEmail(email, password)` — sends credentials to backend `/auth/login`
	- `mockSignInDev(username)` — local simulated login that stores a dev token

To quickly sign in during development without external setup, open the Login
screen and use the "Masuk (Dev)" button. This stores a local token and
navigates to the app. Replace this with your production auth when ready.

Next steps: replace `mockSignInDev` with a proper backend auth or integrate
another identity provider (OAuth server, Supabase, Keycloak, etc.) for
production.
