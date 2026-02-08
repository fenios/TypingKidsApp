# UserManagement Module

## Purpose
Local user management for the app, including login, user creation, and session handling.

## Responsibilities
- Define user domain models and roles.
- Hash and validate PINs.
- Manage local users and the active session.
- Provide SwiftUI screens for login and user creation.

## Key Types
- `User`, `UserRole`
- `PinHasher`
- `UserRepository`, `UserSessionRepository`
- `LoginViewModel`, `LoginView`
- `CreateUserViewModel`, `CreateUserView`

## Dependencies
- Persistence
