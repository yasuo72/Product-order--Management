# Product & Order Management App
> A production-grade Flutter application built for **Indigital Technology** Technical Assessment.  
> Demonstrates clean layered architecture, BLoC/Cubit state management, resilient networking with Dio interceptors, and strict **multi-user session & local storage isolation**.

---

## 📱 Features Overview

### 1. Authentication & Multi-User Support (PDF 1 & PDF 2)
- **REST API Integration:** `POST https://dummyjson.com/auth/login`.
- **Form Validation:** Reactive input validation (Username $\ge$ 3 characters, Password $\ge$ 6 characters).
- **Session Persistence:** Securely persists JWT authentication token and user profile locally.
- **Quick Test Accounts (Reviewer Feature):** One-tap credential chips on the login screen for `Emily Johnson (emilys)` and `Michael Williams (michaelw)` to evaluate multi-user flows in seconds.

### 2. Product Browsing, Search & Filter (PDF 1)
- **Product Catalog:** Consumes `GET https://dummyjson.com/products`.
- **Live Search with Debounce:** Real-time 350ms debounced queries against `GET /products/search?q={query}`.
- **Category Filter:** Dynamic horizontal category chips (`/products/categories` and `/products/category/{category}`).
- **Pull-to-Refresh:** Pull down anytime to synchronize with the latest product catalog.
- **Pagination (Bonus):** Infinite scroll listener dynamically loads batches of 10 items using `skip` and `limit`.

### 3. Product Details (PDF 1 & PDF 2)
- Consumes `GET https://dummyjson.com/products/{id}`.
- Interactive multi-image gallery with animated indicator dots.
- Rating breakdown, stock status chip (`In Stock` / `Low Stock`), brand, category, price, and savings badge.
- Dynamic bottom sheet with real-time "Add to Cart" and quantity steppers.

### 4. User-Isolated Cart Management (PDF 2 Mandate)
- **Strict User Partitioning:** Cart is stored under `cart_user_${userId}` in local storage.
  - When **Emily** logs in, she sees only Emily's cart.
  - When **Michael** logs in, he sees only Michael's cart.
  - Data is never leaked or shared across accounts.
- **Operations:** Add product, increment (+), decrement (-), remove item, and clear cart.
- **Dynamic Totals:** Computes subtotal, total discount savings, delivery fee, and grand total.
- **Persistence:** Retains full state across app termination and device restarts.

### 5. Dedicated User-Isolated Wishlist (PDF 2 Mandate)
- Partitioned per user (`wishlist_user_${userId}`).
- Instant heart toggle on product cards, details screen, and wishlist screen.
- **"Move to Cart" Action:** Transfers items directly from Wishlist into Cart with a single tap.
- Persistent across restarts.

### 6. Validated Checkout & Order Confirmation (PDF 1 & PDF 2)
- **Strict Form Validation:**
  - Full Name (required, alphabet format check).
  - Mobile Number (valid 10-digit phone number check).
  - Street Address (minimum 8 characters).
  - City (required).
  - Pincode (valid 6-digit numeric check).
- **Payment Method Selection:** Cash on Delivery (COD), Instant UPI / QR, and Credit/Debit Card.
- **Auto-Clearing Cart:** Immediately flushes the user's cart in memory and in local storage upon successful order placement.
- **Order Success Screen:** Displays generated Order ID, delivery breakdown, timestamp, and "Continue Shopping" button.

### 7. Bonus & Pro-Tier Polish
- **Dark Mode Support:** Material 3 Light & Dark mode switchable from the app bar with persisted user preference.
- **Real-Time Connectivity Wrapper:** Live `connectivity_plus` listener displaying an offline status banner with a retry callback.
- **Image Caching & Shimmer:** `cached_network_image` with smooth fallback icons.
- **Comprehensive Unit Tests:** 18 automated unit tests covering `AuthCubit`, `CartCubit`, `WishlistCubit`, and repository isolation.
- **Dio Interceptors:** Automatic Bearer token attachment and 401 Unauthorized detection.

---

## 🏛 Architecture & Project Structure

The project follows **Clean Layered Architecture** with **BLoC / Cubit Pattern**:

```
lib/
├── main.dart                          # App entrypoint, dependency injection
├── app.dart                           # MultiBlocProvider, MaterialApp, Theme listener
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart         # DummyJSON API endpoints
│   │   └── app_colors.dart            # Harmonious color tokens (Light & Dark)
│   ├── network/
│   │   ├── api_client.dart            # Dio configuration with timeouts & logger
│   │   ├── auth_interceptor.dart      # Bearer token injection & 401 handling
│   │   └── network_exceptions.dart    # Centralized exception mapper
│   ├── services/
│   │   ├── storage_service.dart       # SharedPreferences wrapper (user-partitioned)
│   │   └── connectivity_service.dart  # connectivity_plus network stream
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 light/dark ThemeData
│   │   └── theme_cubit.dart           # Theme mode state management
│   └── widgets/
│       ├── connectivity_banner.dart   # Offline status banner with retry
│       ├── empty_state_view.dart      # Clean graphic for empty lists
│       ├── error_state_view.dart      # Reusable error card with retry
│       ├── custom_button.dart         # Button with progress spinner
│       └── custom_text_field.dart     # Input field with validation styling
└── features/
    ├── auth/                          # Login, session, token persistence
    ├── products/                      # Catalog, search, filters, pagination, details
    ├── cart/                          # User-isolated cart and calculations
    ├── wishlist/                      # User-isolated wishlist
    ├── checkout/                      # Validated checkout and order confirmation
    └── main_navigation_screen.dart    # Bottom nav bar with reactive badges
```

### Architectural Decisions Rationale:
1. **BLoC / Cubit vs Provider/GetX:**
   - Cubit provides predictable, unidirectional state flow (`State -> UI -> Event/Method -> New State`).
   - Easily testable in isolation using `bloc_test`.
   - Eliminates unnecessary widget tree rebuilds through targeted `BlocBuilder.buildWhen` filters.
2. **User-Isolated Storage Pattern:**
   - Rather than storing a single global cart in `SharedPreferences`, items are serialized under `cart_user_${userId}` and `wishlist_user_${userId}`.
   - When a user logs in, the `AuthCubit` triggers `CartCubit.initializeForUser(user.username)` and `WishlistCubit.initializeForUser(user.username)`.
   - Logging out clears the session token, but keeps user data segregated and ready for when they log back in.

---

## 📦 Packages & Dependencies Used

| Package | Version | Purpose & Justification |
| :--- | :--- | :--- |
| `flutter_bloc` | `^9.1.1` | State management providing predictable, reactive state transitions. |
| `equatable` | `^3.0.0` | Value equality for states and models, preventing redundant re-renders. |
| `dio` | `^5.11.1` | Robust HTTP client with interceptor support, timeouts, and error parsing. |
| `pretty_dio_logger` | `^1.4.0` | Readable network logging in debug mode for rapid API debugging. |
| `shared_preferences`| `^2.5.5` | Fast, lightweight local storage for tokens and user-partitioned JSON. |
| `cached_network_image` | `^3.4.1` | High-performance image caching with placeholders and error widgets. |
| `connectivity_plus` | `^7.3.1` | Real-time device internet connectivity monitoring. |
| `flutter_rating_bar` | `^4.0.1` | Star rating display on product cards and product details. |
| `intl` | `^0.20.3` | Date and currency formatting on checkout and order confirmation. |
| `google_fonts` | `^8.1.0` | Modern typography (Plus Jakarta Sans). |
| `bloc_test` | `^10.0.0` | Declarative unit testing for Cubits. |
| `mocktail` | `^1.0.5` | Clean mocking without code-generation friction. |

---

## 🚀 Getting Started & How to Run

### Prerequisites
- Flutter SDK (v3.24+ recommended, tested on Flutter 3.35.6 / Dart 3.9.2)
- Android SDK / Emulator or Physical Android Device / Chrome / Windows desktop

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Code Analysis (Zero Warnings Guarantee)
```bash
flutter analyze
```

### 3. Run Automated Unit Tests (18 Tests Pass)
```bash
flutter test
```

### 4. Run the Application
```bash
flutter run
```

### 5. Build Production Release APK
```bash
flutter build apk --release
```
The output APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🔑 Test Credentials (DummyJSON)

| Role | Username | Password |
| :--- | :--- | :--- |
| **Primary Test User** | `emilys` | `emilyspass` |
| **Secondary Test User** | `michaelw` | `michaelwpass` |

*(Tip: Tap the quick-chip buttons on the Login screen to fill credentials automatically!)*

---

## 💡 Assumptions & Limitations
1. **Mock Payment:** As specified in the assignment requirements, no real payment gateway is required. A mock payment selector with instant confirmation is implemented.
2. **API Data Mutability:** DummyJSON does not persist mutations to its backend servers for new orders; therefore, the order confirmation generates a realistic client-side order snapshot while clearing local cart persistence.
3. **Session Refresh:** If a 401 Unauthorized status is received, the app clears the local auth token and redirects gracefully to the login screen.

---

## 🎯 Candidate Interview Talking Points

- **Why Cubit over full BLoC?**  
  *Cubit eliminates event boilerplate while retaining state immutability, stream streams, and testability. For CRUD operations like cart, wishlist, and auth status, Cubits are lighter, cleaner, and faster to comprehend.*
- **How was Multi-User Isolation verified?**  
  *By partitioning local keys as `cart_user_{username}` and `wishlist_user_{username}`. If User A logs in and adds items, logging out and logging in as User B starts with an empty cart. When User A logs back in, User A's exact items are restored.*
- **How is Offline Mode handled?**  
  *A `ConnectivityService` emits real-time connectivity changes. The `ConnectivityBanner` informs the user immediately, while `cached_network_image` continues serving cached thumbnails.*
