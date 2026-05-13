# 🎓 StudentApp

An iOS application built with **SwiftUI** that allows university students to register and manage their academic information with secure authentication via email/password and external providers (Google and GitHub) through Firebase.

---

## 📱 Screenshots

| Splash | Registration | Login | Profile |
|--------|-------------|-------|---------|
| Animated loading screen | 2-step form | Email + Social | Student data |

---

## 🏗️ Architecture

```
StudentApp/
├── StudentAppApp.swift          # Entry point (@main) + UIApplicationDelegateAdaptor
├── AppDelegate.swift            # OAuth URL callback handling
├── ContentView.swift            # Main router between screens
├── Models/
│   └── Student.swift            # Student data model
├── Managers/
│   ├── DataManager.swift        # UserDefaults persistence
│   ├── AuthManager.swift        # Firebase authentication logic
│   └── GitHubSignInManager.swift # GitHub OAuth via OAuthProvider
└── Views/
    ├── SplashView.swift         # Initial loading screen
    ├── RegistrationView.swift   # 2-step registration form
    ├── LoginView.swift          # Email and social login
    └── HomeView.swift           # Student profile and information
```

---

## 🔄 App Flow

```
┌─────────────┐
│  SplashView │ (1.2s)
└──────┬──────┘
       │
       ├── No registered data? ──► RegistrationView (2 steps)
       │                                   │
       │                                   ▼
       │                          Saves to UserDefaults
       │                                   │
       ├── Active session? ───────────────►┤
       │                                   │
       └── No session? ──► LoginView       │
                               │           │
                               ▼           ▼
                           HomeView ◄──────┘
                               │
                   ┌───────────┴───────────┐
                   │                       │
              Sign Out               Delete Data
          (data is kept)         (back to registration)
```

---

## 💾 Data Persistence

Data is stored locally using **UserDefaults** through `DataManager`:

```swift
// Save student
DataManager.shared.saveStudent(student)

// Validate login
DataManager.shared.validateLogin(correo:contrasena:)

// Session management
DataManager.shared.saveSession()
DataManager.shared.clearSession()
DataManager.shared.isSessionActive()

// Delete everything
DataManager.shared.deleteAllData()
```

### Stored Keys

| Key | Type | Description |
|-----|------|-------------|
| `saved_student` | `Data` (JSON) | Encoded student data |
| `is_registered` | `Bool` | Whether the user completed registration |
| `is_logged_in` | `Bool` | Whether there is an active session |

> ⚠️ **Security note:** For production, it is recommended to migrate the password storage to **Keychain** instead of UserDefaults.

---

## 🔐 Authentication

### 1. Email and Password (local)

Email/password authentication is entirely **local**, without relying on Firebase Auth. Credentials are validated against data stored in UserDefaults.

```swift
func validateLogin(correo: String, contrasena: String) -> Bool {
    guard let student = student else { return false }
    return student.correo.lowercased() == correo.lowercased()
        && student.contrasena == contrasena
}
```

### 2. Google Sign-In

Uses the official **GoogleSignIn** SDK integrated with Firebase Auth.

**Flow:**
```
App → GIDSignIn.signIn() → Google OAuth → idToken + accessToken
    → GoogleAuthProvider.credential() → Auth.auth().signIn()
```

**Key code:**
```swift
GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
    let credential = GoogleAuthProvider.credential(
        withIDToken: idToken,
        accessToken: user.accessToken.tokenString
    )
    Auth.auth().signIn(with: credential)
}
```

### 3. GitHub Sign-In

Uses Firebase's **OAuthProvider** with `getCredentialWith(nil)`, which internally opens an `ASWebAuthenticationSession`.

**Flow:**
```
App → OAuthProvider("github.com") → ASWebAuthenticationSession
    → GitHub OAuth page → Firebase callback URL
    → OAuthCredential → Auth.auth().signIn()
```

**Key code:**
```swift
let provider = OAuthProvider(providerID: "github.com")
provider.scopes = ["user:email"]

provider.getCredentialWith(nil) { credential, error in
    Auth.auth().signIn(with: credential)
}
```

---

## ⚙️ Project Setup

### Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+
- Firebase account
- GitHub account (for OAuth App)

### Dependencies (Swift Package Manager)

| Package | URL | Required modules |
|---------|-----|-----------------|
| Firebase iOS SDK | `https://github.com/firebase/firebase-ios-sdk` | `FirebaseAuth`, `FirebaseCore` |
| Google Sign-In | `https://github.com/google/GoogleSignIn-iOS` | `GoogleSignIn` |

### Installation Steps

**1. Create a Firebase project**
- Go to [console.firebase.google.com](https://console.firebase.google.com)
- Create a new project
- Add an iOS app with your Bundle ID
- Download `GoogleService-Info.plist` and add it to the project in Xcode

**2. Enable providers in Firebase Console**

`Authentication → Sign-in method`

- ✅ Google — just enable it
- ✅ GitHub — requires Client ID and Client Secret from your GitHub OAuth App

**3. Create a GitHub OAuth App**

At [github.com/settings/developers](https://github.com/settings/developers) → OAuth Apps → New OAuth App:

| Field | Value |
|-------|-------|
| Homepage URL | `https://YOUR-PROJECT-ID.firebaseapp.com` |
| Authorization callback URL | `https://YOUR-PROJECT-ID.firebaseapp.com/__/auth/handler` |

Copy the **Client ID** and **Client Secret** into Firebase Console → GitHub provider.

**4. Register URL Schemes in Xcode**

`Target → Info → URL Types` — add **two** schemes:

| Item | URL Scheme | Source |
|------|-----------|--------|
| Item 0 | `com.googleusercontent.apps.XXXXXX` | `REVERSED_CLIENT_ID` in `GoogleService-Info.plist` |
| Item 1 | `app-1-XXXXXXXXXX-ios-XXXXXXXX` | `BUNDLE_URL_SCHEME` in `GoogleService-Info.plist` |

> 💡 Both values are in your `GoogleService-Info.plist`. The first is for Google Sign-In, the second is for Firebase to redirect back to the app after GitHub OAuth.

**5. Configure AppDelegate**

```swift
@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
```

The `AppDelegate` handles OAuth URL callbacks:

```swift
func application(_ app: UIApplication, open url: URL, options: [...]) -> Bool {
    if GIDSignIn.sharedInstance.handle(url) { return true }
    if Auth.auth().canHandle(url) { return true }
    return false
}
```

---

## 🐛 Errors Encountered and Solutions

### Error 1: `Type 'AuthManager' does not conform to protocol 'ObservableObject'`

**Cause:** Missing `import Combine` in `AuthManager.swift`. `@Published` and `ObservableObject` explicitly require the Combine framework in some contexts.

**Fix:**
```swift
import Combine  // ← add this import
import SwiftUI
import FirebaseAuth
```

---

### Error 2: `'onChange(of:perform:)' was deprecated in iOS 17.0`

**Cause:** The single-parameter closure form of `onChange` was deprecated in iOS 17.

**Fix:**
```swift
// ❌ Deprecated
.onChange(of: value) { newValue in }

// ✅ Correct iOS 17+
.onChange(of: value) { _, newValue in }
```

---

### Error 3: `'UIScreen.main' was deprecated in iOS 26.0`

**Cause:** `UIScreen.main` was deprecated. It should not be used to get screen dimensions in SwiftUI.

**Fix:** Use `GeometryReader` to read available width:
```swift
@State private var screenWidth: CGFloat = 393

GeometryReader { geo in
    Color.clear
        .onAppear { screenWidth = geo.size.width }
        .onChange(of: geo.size.width) { _, w in screenWidth = w }
}
```

---

### Error 4: `Argument type 'UIViewController' does not conform to expected type 'AuthUIDelegate'`

**Cause:** `OAuthProvider.getCredentialWith()` requires an `AuthUIDelegate`, not a `UIViewController` directly.

**Fix:** Create a wrapper class implementing `AuthUIDelegate`:
```swift
class AuthUIHandler: NSObject, AuthUIDelegate {
    func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)?) {
        topViewController()?.present(vc, animated: animated, completion: completion)
    }
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        topViewController()?.dismiss(animated: animated, completion: completion)
    }
}
```

---

### Error 5: `SFAuthenticationViewController is deallocating` + infinite loading on buttons

**Cause:** Two combined issues:
1. `isLoading` was a single shared variable for both Google and GitHub — if one failed, it blocked the other.
2. `OAuthProvider.getCredentialWith()` internally used `SFAuthenticationViewController` (deprecated) when `nil` was passed as delegate.

**Fix:**
- Split into `isLoadingGoogle` and `isLoadingGitHub`
- Pass a proper `AuthUIDelegate` instead of `nil`

---

### Error 6: `Unable to process request due to missing initial state` (GitHub)

**Cause:** `ASWebAuthenticationSession` with `prefersEphemeralWebBrowserSession = false` shares a session with Safari. Firebase's handler (`/__/auth/handler`) uses browser `sessionStorage` to maintain OAuth state, which is not available in shared sessions.

**Attempted fix:** Switch to `prefersEphemeralWebBrowserSession = true` — but this caused another problem because `https://` callbacks cannot be intercepted by iOS.

**Real fix:** Register the two URL Schemes required by Firebase (see Error 9).

---

### Error 7: `Error Firebase: Unsuccessful check authorization response from Github: {"status":"404"}`

**Cause:** The GitHub **authorization code** was being passed as if it were an **access token**. These are fundamentally different things:
- **Authorization code** → temporary, single-use, must be exchanged for a token
- **Access token** → what Firebase actually needs to authenticate the user

**Lesson:** `OAuthProvider.credential(providerID:accessToken:)` expects a real access token, not an authorization code.

---

### Error 8: `INVALID_REQUEST_URI` / `INVALID_CREDENTIAL_OR_PROVIDER_ID` (Firebase REST API)

**Cause:** When attempting to call Firebase's `accounts:signInWithIdp` manually, a custom scheme `requestUri` (like `studentapp://`) is not accepted. Additionally, Firebase does not exchange authorization codes — the `code → access_token` exchange must be done beforehand using the Client Secret.

**Lesson:** Never call the Firebase REST API manually for OAuth. Always use the official SDK, which handles all of this internally.

---

### Error 9: `Fatal error: Please register custom URL scheme app-1-XXXXXXXXXX-ios-XXXXXXXX`

**Cause:** Firebase requires its `BUNDLE_URL_SCHEME` to be registered in `Info.plist` so it can redirect back to the app after GitHub OAuth. Without this, the `OAuthProvider` flow never completes.

**Fix:** Register **two** URL Schemes in Xcode → Target → Info → URL Types:
1. `REVERSED_CLIENT_ID` (for Google Sign-In)
2. `BUNDLE_URL_SCHEME` (for Firebase OAuth callbacks — GitHub)

Both values are found in `GoogleService-Info.plist`.

> ✅ **This was the definitive fix** that resolved GitHub Sign-In.

---

### Error 10: `App Delegate does not conform to UIApplicationDelegate protocol`

**Cause:** A pure SwiftUI app with `@main` has no `AppDelegate` by default. Firebase needs the `application(_:open:options:)` method to intercept OAuth URL callbacks.

**Fix:** Create `AppDelegate.swift` and connect it with `@UIApplicationDelegateAdaptor`:

```swift
// AppDelegate.swift
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [...]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) { return true }
        if Auth.auth().canHandle(url) { return true }
        return false
    }
}

// StudentAppApp.swift
@main
struct StudentAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // ...
}
```

---

## ✅ Final GitHub Sign-In Solution

After many attempts, the working solution turned out to be surprisingly simple:

```swift
// GitHubSignInManager.swift
class GitHubSignInManager {
    static let shared = GitHubSignInManager()

    func signIn() async throws -> AuthDataResult {
        let provider = OAuthProvider(providerID: "github.com")
        provider.scopes = ["user:email"]

        return try await withCheckedThrowingContinuation { continuation in
            provider.getCredentialWith(nil) { credential, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let credential = credential else { return }
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let result = result {
                        continuation.resume(returning: result)
                    }
                }
            }
        }
    }
}
```

**What actually solved the problem:**
1. ✅ Register `BUNDLE_URL_SCHEME` in URL Types (in addition to `REVERSED_CLIENT_ID`)
2. ✅ Have a real `AppDelegate` with `application(_:open:options:)`
3. ✅ Use `getCredentialWith(nil)` — Firebase handles everything internally

---

## 🔒 Security Considerations

| Aspect | Current state | Production recommendation |
|--------|--------------|--------------------------|
| Password | UserDefaults (plain text) | Migrate to **Keychain** |
| Session | UserDefaults bool | Use Firebase Auth session tokens |
| Client Secret | Firebase Console (safe) | ✅ Never in client-side code |
| Student data | Local UserDefaults | Consider encryption or Firebase Firestore |

---

## 👨‍💻 Tech Stack

- **SwiftUI** — Declarative UI
- **Firebase Auth** — Google and GitHub authentication
- **GoogleSignIn SDK** — Google OAuth flow
- **UserDefaults** — Local data persistence
- **Combine** — Reactivity with `@Published` and `ObservableObject`
- **ASWebAuthenticationSession** — OAuth web sessions (used internally by Firebase)

---

## 📄 License

MIT License — free for educational and personal use.
