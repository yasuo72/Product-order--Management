# High-Impact Execution Plan: Product & Order Management App

## Executive Summary & Alignment
This execution plan merges the specifications from **PDF 1 (Core Requirements & Bonus Criteria)** and **PDF 2 (Indigital Technology Tech Lead Tanvir Dalal's Specific Mandates)** with a **Pro-Tier Engineering Polish** tailored to demonstrate senior-level maturity for a 1-year Flutter role.

### Critical Mandates Identified Across Both Documents:
1. **Multi-User Isolation (PDF 2 Priority):** Cart and Wishlist states **must never collide** across accounts. Data is partitioned locally by user ID (`cart_${userId}` & `wishlist_${userId}`).
2. **Dedicated Wishlist (PDF 2 Priority):** Full add/remove wishlist capability persisted per user.
3. **Cart & Checkout Lifecycle (PDF 1 & 2):** Add, increment, decrement, remove, calculate total, persist across app restarts, auto-clear on successful checkout, and show order confirmation.
4. **Resilient Network Layer (Bonus):** Dio with custom Interceptors (Bearer token injection, error mapping, 401 auto-logout) and real-time connectivity detection.
5. **Interview-Ready Architecture:** Clean Layered Architecture (`core/`, `features/` with Data, Logic/Cubit, Presentation).

---

## User Review Required

> [!IMPORTANT]
> **State Management Choice**: We will use `flutter_bloc` (`Bloc` / `Cubit`). It is the industry gold standard for scalable enterprise Flutter apps, perfectly matches your draft plan, and provides the cleanest separation of concerns for unit testing (`bloc_test`).

> [!NOTE]
> **Persistence Engine**: We will use `shared_preferences` with typed JSON serialization for session, user-isolated cart (`cart_${userId}`), user-isolated wishlist (`wishlist_${userId}`), and theme mode. This ensures zero native build complexities while providing 100% persistence across restarts.

---

## Architecture & Directory Layout

```
lib/
├── main.dart                          # App entry, multi-bloc providers, theme init
├── app.dart                           # MaterialApp.router or root MaterialApp with theme
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart         # DummyJSON endpoints (login, products, etc.)
│   │   └── app_colors.dart            # Harmonious color palette & typography
│   ├── network/
│   │   ├── api_client.dart            # Dio instance configuration
│   │   ├── auth_interceptor.dart      # Bearer token & 401 handling
│   │   └── network_exceptions.dart    # Structured failure & error messages
│   ├── services/
│   │   ├── storage_service.dart       # SharedPreferences wrapper (user-scoped storage)
│   │   └── connectivity_service.dart  # connectivity_plus helper & stream
│   ├── theme/
│   │   ├── app_theme.dart             # Material 3 Light & Dark mode themes
│   │   └── theme_cubit.dart           # Light/Dark toggle state management
│   └── widgets/
│       ├── connectivity_banner.dart   # Offline warning bar & retry prompt
│       ├── empty_state_view.dart      # Custom illustrations for empty Cart/Wishlist/Search
│       ├── error_state_view.dart      # Friendly error view with retry callback
│       ├── custom_button.dart         # Reusable loading-state button
│       └── custom_text_field.dart     # Polished input fields with validation styling
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── models/user_model.dart
    │   │   └── auth_repository.dart
    │   ├── logic/
    │   │   ├── auth_cubit.dart
    │   │   └── auth_state.dart
    │   └── presentation/
    │       └── login_screen.dart      # Credential validation, test account quick-chips
    ├── products/
    │   ├── data/
    │   │   ├── models/product_model.dart
    │   │   └── product_repository.dart
    │   ├── logic/
    │   │   ├── product_list_cubit.dart (Search, Category filter, Pull-to-refresh, Pagination)
    │   │   ├── product_list_state.dart
    │   │   ├── product_detail_cubit.dart
    │   │   └── product_detail_state.dart
    │   └── presentation/
    │       ├── product_list_screen.dart    # Grid layout, search bar, category chips
    │       ├── product_detail_screen.dart  # Image gallery, specs, rating, Add to Cart & Wishlist
    │       └── widgets/product_card.dart
    ├── cart/
    │   ├── data/
    │   │   ├── models/cart_item_model.dart
    │   │   └── cart_repository.dart        # Reads/writes cart_${userId}
    │   ├── logic/
    │   │   ├── cart_cubit.dart
    │   │   └── cart_state.dart
    │   └── presentation/
    │       ├── cart_screen.dart            # Stepper, swipe to dismiss, price breakdown
    │       └── widgets/cart_item_tile.dart
    ├── wishlist/
    │   ├── data/
    │   │   └── wishlist_repository.dart    # Reads/writes wishlist_${userId}
    │   ├── logic/
    │   │   ├── wishlist_cubit.dart
    │   │   └── wishlist_state.dart
    │   └── presentation/
    │       └── wishlist_screen.dart        # Saved items, one-click Move to Cart
    └── checkout/
        ├── logic/
        │   ├── checkout_cubit.dart
        │   └── checkout_state.dart
        └── presentation/
            ├── checkout_screen.dart        # Validated form: Name, Phone, Address, City, Pin
            └── order_success_screen.dart   # Lottie/custom celebration, clear cart verification
```

---

## Detailed Step-by-Step Implementation Strategy

### Step 1: Project Initialization & Dependency Configuration
- Initialize clean Flutter project in `c:\Users\Rohit\flutter-ass`.
- Configure `pubspec.yaml` with stable, conflict-free dependencies:
  - **State Management**: `flutter_bloc: ^8.1.6`
  - **Networking**: `dio: ^5.7.0`, `pretty_dio_logger: ^1.4.0`
  - **Storage**: `shared_preferences: ^2.3.2`
  - **Network Caching & Connectivity**: `cached_network_image: ^3.4.1`, `connectivity_plus: ^6.1.0`
  - **UI & Icons**: `flutter_rating_bar: ^4.0.1`, `intl: ^0.19.0`, `google_fonts: ^6.2.1`
  - **Testing**: `bloc_test: ^9.1.7`, `mocktail: ^1.0.4`
- Verify project builds cleanly on Windows/Web/Android.

### Step 2: Core Infrastructure (Network, Storage, Theme, Connectivity)
- **Dio Client & AuthInterceptor**:
  - Automatically appends `Authorization: Bearer <token>` when user is authenticated.
  - Automatically logs requests & responses for effortless debugging.
  - Intercepts 401 status to trigger auth reset.
- **Storage Service**:
  - Secure saving and retrieval of `auth_token`, `user_profile`.
  - User-isolated methods: `getCart(userId)`, `saveCart(userId, items)`, `getWishlist(userId)`, `saveWishlist(userId, items)`.
- **Theme Cubit**:
  - Modern Material 3 Light & Dark mode themes with rich indigo/violet accents and polished typography.
- **Connectivity Service**:
  - Streams network status; displays a non-intrusive floating status banner or full offline retry screen.

### Step 3: Feature - Authentication (`features/auth`)
- **API**: `POST https://dummyjson.com/auth/login`
- **Validation**:
  - Username: minimum 3 characters.
  - Password: minimum 6 characters.
- **UI & UX Highlights**:
  - Test account quick-fill buttons: One-tap chips for `emilys` / `emilyspass` and a secondary user (e.g. `michaelw`) so interviewers can test multi-user isolation in 2 seconds without typing.
  - Form validation with reactive error text.
  - Loading spinner on button with disabled interaction.
  - Error snackbar with friendly messages on bad credentials or network issues.

### Step 4: Feature - Products Catalog & Search (`features/products`)
- **API**: `GET https://dummyjson.com/products` with pagination (`limit`, `skip`) and category filters (`GET https://dummyjson.com/products/categories`, `GET https://dummyjson.com/products/category/{category}`).
- **Features**:
  - Search bar with 400ms debounce (`GET https://dummyjson.com/products/search?q={query}`).
  - Horizontal scrollable Category selector chips ("All", "beauty", "fragrances", "furniture", "groceries", etc.).
  - Pull-to-refresh on the grid (`RefreshIndicator`).
  - Shimmer loading skeleton effect while loading.
  - Product Card displaying thumbnail (`cached_network_image`), title, price with discount tag, star rating, category badge, and interactive Wishlist heart icon.
  - Pagination infinite scroll listener.

### Step 5: Feature - Product Details (`features/products/presentation/product_detail_screen.dart`)
- **API**: `GET https://dummyjson.com/products/{id}`
- **Display**:
  - Multi-image page view / carousel with page indicator dots.
  - Product title, brand, category chip, rating with review count.
  - Discounted price, original price strike-through, stock status chip ("In Stock" / "Low Stock").
  - Description and specifications table.
  - Floating Bottom Action Bar:
    - Favorite/Wishlist toggle button with heart animation.
    - "Add to Cart" button (shows quantity stepper if already in cart, with instant badge update).

### Step 6: Feature - User-Isolated Cart Management (`features/cart`)
- **Isolation Guarantee**: Cart items keyed by `cart_${currentUser.id}`.
- **Operations**:
  - Add product (or increment if already present).
  - Increment quantity (+) and Decrement quantity (-).
  - Remove product (with confirmation dialog or swipe-to-dismiss).
  - Compute subtotal, estimated tax/discount, and total price.
- **Persistence**: Every mutation automatically persists to local storage.
- **UI Details**:
  - Cart item card with thumbnail, title, price, and stepper.
  - Sticky bottom checkout sheet with price breakdown and "Proceed to Checkout" button.
  - Polished empty state with "Your cart is empty" graphic and "Explore Products" navigation button.

### Step 7: Feature - User-Isolated Wishlist (`features/wishlist`)
- **Isolation Guarantee**: Saved items keyed by `wishlist_${currentUser.id}`.
- **Operations**:
  - Toggle item in/out of wishlist from Product Card, Product Detail, or Wishlist screen.
  - "Move to Cart" button on wishlist item.
  - Swipe to remove from wishlist.
  - Polished empty state ("Your wishlist is empty").

### Step 8: Feature - Validated Checkout & Order Confirmation (`features/checkout`)
- **Form Fields**:
  - Full Name (required, alphabet characters only).
  - Mobile Number (10 digits validation with Indian format check).
  - Street Address (minimum 10 characters).
  - City (required).
  - Pincode (6 digits validation).
- **Payment Method Selection**: Mock selector (Cash on Delivery, UPI, Credit/Debit Card) for realistic e-commerce experience.
- **Submission Action**:
  - Triggers CheckoutCubit processing state.
  - **Clears the current user's cart in memory and in `cart_${userId}` storage**.
  - Navigates to `OrderSuccessScreen` with animated checkmark/confetti, generated Order ID, estimated delivery date, and "Continue Shopping" button.

### Step 9: Quality Assurance & Polish Additions (Hiring Differentiators)
1. **Multi-User Isolation Switcher**: Add a "Switch User" / "Logout" flow in the app bar / drawer. Logging into `emilys` shows Emily's cart. Logging into `michaelw` shows Michael's distinct cart.
2. **Connectivity Banner & Offline Handling**: Real-time indicator for connectivity loss with friendly retry button.
3. **Unit Tests**:
   - `auth_cubit_test.dart`: login success, invalid credentials, logout.
   - `cart_cubit_test.dart`: add item, increment, isolated persistence, clear cart.
   - `wishlist_cubit_test.dart`: add item, remove item, isolation.
4. **Git Commit History**: Structural, clean semantic commits:
   - `chore: initial project setup and dependencies`
   - `feat(core): setup network client, storage, theme, and connectivity`
   - `feat(auth): implement user authentication, token storage, and login screen`
   - `feat(products): implement product list, search, category filter, and detail screen`
   - `feat(cart): implement user-isolated cart persistence, calculations, and ui`
   - `feat(wishlist): implement user-isolated wishlist management`
   - `feat(checkout): implement form validation and order success flow`
   - `feat(polish): add dark mode, connectivity listener, and unit tests`
   - `docs: comprehensive README with architecture, setup, and interview guide`

### Step 10: Production Deliverables
- **Release APK**: Run `flutter build apk --release`.
- **Structured README.md**:
  - Project Overview & Architecture (Layered BLoC).
  - Quick Start & Run Guide (Prerequisites, Flutter commands).
  - Packages & Justifications table.
  - Multi-user isolation mechanism explanation (specifically addressing Tech Lead Tanvir's prompt).
  - Architectural decisions & interview Q&A talking points.

---

## Verification Plan

### Automated Testing
- Execute `flutter test` to verify all cubit and repository tests pass with 100% success rate.
- Run `flutter analyze` to ensure zero lint errors and zero warnings.

### Functional Verification
1. **Authentication**: Login with `emilys`/`emilyspass`. Verify token is stored and user profile is loaded.
2. **Product Browsing & Search**: Search for "phone", select category "beauty", verify pull-to-refresh and pagination.
3. **Wishlist**: Add items to wishlist; verify heart icon stays active on both card and details screen.
4. **Cart**: Add 2 items; increment item 1 to quantity 3; verify total price updates dynamically; restart app and verify items remain.
5. **Multi-User Isolation**: Logout, log in as `michaelw`, verify cart and wishlist are empty for Michael. Add items for Michael, log back in as `emilys`, verify Emily's items are intact.
6. **Checkout**: Fill invalid phone/pincode to test error messages; fill valid inputs; submit order; verify order success dialog and verify cart is emptied.
7. **Offline Mode**: Toggle network simulation/airplane mode; verify offline notification and graceful retry.
8. **Release Build**: Run `flutter build apk --release` and verify APK output exists in `build/app/outputs/flutter-apk/app-release.apk`.
