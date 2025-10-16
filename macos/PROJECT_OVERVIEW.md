# Laza Flutter E-commerce App - Complete Technical Documentation

## Table of Contents
1. [Project Structure](#1-project-structure)
2. [Feature Architecture](#2-feature-architecture)
3. [Dependency Injection (DI)](#3-dependency-injection-di)
4. [Routing](#4-routing)
5. [Data Flow](#5-data-flow)
6. [Feature Summaries](#6-feature-summaries)
7. [Other Notes](#7-other-notes)

---

## 1. Project Structure

The project follows a **Clean Architecture** pattern with feature-based organization under the `lib/` directory:

```
lib/
├── core/                           # Shared core functionality
│   ├── di/                        # Dependency injection container
│   │   └── injection_container.dart
│   ├── network/                    # Network configuration
│   │   └── dio_interceptor.dart
│   ├── routing/                   # Navigation configuration
│   │   ├── app_router.dart
│   │   └── app_shell.dart
│   ├── services/                  # Core services
│   │   └── local_storage_service.dart
│   ├── utils/                     # Utility classes and constants
│   │   ├── app_colors.dart
│   │   ├── app_styles.dart
│   │   ├── product_grid_config.dart
│   │   └── string_extension.dart
│   └── widgets/                   # Reusable UI components
│       └── bottom_nav_bar.dart
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   ├── Cart/                      # Shopping cart feature
│   ├── Favorites/                 # Favorites management
│   ├── home/                      # Home screen and products
│   ├── onboarding/                # User onboarding
│   ├── ProductDetails/            # Product detail views
│   ├── profile/                   # User profile (empty)
│   ├── reviews/                   # Product reviews (empty)
│   └── spalsh/                    # Splash screen
└── main.dart                      # Application entry point
```

### Core Directory Purposes:

- **`core/di/`**: Contains the GetIt dependency injection setup
- **`core/network/`**: Handles HTTP client configuration and interceptors
- **`core/routing/`**: Manages navigation using GoRouter
- **`core/services/`**: Provides shared services like local storage
- **`core/utils/`**: Contains app-wide constants, colors, and utility functions
- **`core/widgets/`**: Houses reusable UI components

---

## 2. Feature Architecture

Each feature follows a **two-layer architecture** pattern:

### Data Layer
- **`models/`**: Data transfer objects and domain models
- **`datasources/`**: API communication interfaces and implementations
- **`repositories/`**: Business logic abstraction and data orchestration

### Presentation Layer
- **`cubits/`**: State management using BLoC pattern
- **`screens/`**: UI screens and pages
- **`widgets/`**: Feature-specific UI components

### Detailed Feature Breakdown:

#### 2.1 Authentication Feature (`auth/`)
```
auth/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart          # Abstract API interface
│   │   └── auth_remote_data_source_impl.dart     # Dio-based implementation
│   ├── models/
│   │   ├── login_request_model.dart              # Login request DTO
│   │   ├── login_response_model.dart             # Login response DTO
│   │   └── refresh_token_request_model.dart      # Token refresh DTO
│   └── repositories/
│       ├── auth_repository.dart                  # Abstract repository
│       └── auth_repository_impl.dart             # Implementation with token storage
└── presentation/
    ├── cubits/
    │   └── login_cubit/
    │       ├── login_cubit.dart                   # Login state management
    │       └── login_state.dart                   # Login states (loading, success, error)
    └── screens/
        ├── login_screen.dart                     # Login UI
        ├── signup_screen.dart                    # Registration UI
        ├── forget_password.dart                   # Password recovery
        ├── confirm_code.dart                     # OTP verification
        └── new_password.dart                     # Password reset
```

**API Endpoints:**
- `POST /auth/login` - User authentication
- `POST /auth/refresh-token` - Token refresh

#### 2.2 Home Feature (`home/`)
```
home/
├── data/
│   ├── datasources/
│   │   ├── home_remote_data_source.dart          # Abstract API interface
│   │   └── home_remote_data_source_impl.dart     # Products API implementation
│   ├── models/
│   │   ├── product_model.dart                    # Product domain model
│   │   └── products_response_model.dart          # API response wrapper
│   └── repositories/
│       ├── home_repository.dart                  # Abstract repository
│       └── home_repository_impl.dart             # Products data orchestration
└── presentation/
    ├── cubits/
    │   └── home_cubit/
    │       ├── home_cubit.dart                   # Products state management
    │       └── home_state.dart                   # Home states
    ├── screens/
    │   └── home_screen.dart                     # Main products listing
    ├── widgets/
    │   └── home_product_card.dart                # Product card component
    └── widgits/                                 # Note: Typo in folder name
        └── BrandCard.dart                       # Brand display component
```

**API Endpoints:**
- `GET /products` - Fetch products with pagination

#### 2.3 Cart Feature (`Cart/`)
```
Cart/
├── data/
│   ├── models/
│   │   └── cart_item_model.dart                  # Cart item representation
│   ├── repositories/
│   │   └── cart_repository.dart                  # Cart data management
│   └── services/
│       └── cart_service.dart                     # Cart business logic
└── presentation/
    ├── cubits/
    │   ├── cart_cubit.dart                       # Cart state management
    │   └── cart_state.dart                       # Cart states
    └── screens/
        ├── cart_screen.dart                      # Cart display
        └── order_confirmation_screen.dart        # Order completion
```

**Storage:** Uses SharedPreferences for local cart persistence

#### 2.4 Favorites Feature (`Favorites/`)
```
Favorites/
└── presentation/
    ├── cubits/
    │   └── favorites_cubit/
    │       ├── favorites_cubit.dart              # Favorites state management
    │       └── favorites_state.dart             # Favorites states
    ├── screens/
    │   └── favourite_screen.dart               # Favorites display
    └── widgets/
        └── favorite_product_card.dart            # Favorite item component
```

**Storage:** Uses SharedPreferences for local favorites persistence

#### 2.5 Product Details Feature (`ProductDetails/`)
```
ProductDetails/
├── data/
│   ├── datasources/
│   │   └── product_details_datasource.dart       # Product details API
│   ├── models/
│   │   └── product_details_model.dart           # Detailed product model
│   └── repositories/
│       └── product_details_repository.dart      # Product details orchestration
└── presentation/
    ├── cubit/
    │   ├── product_details_cubit.dart           # Product details state
    │   └── product_details_state.dart           # Product details states
    └── screens/
        └── product_details_screen.dart          # Product detail view
```

#### 2.6 Onboarding Feature (`onboarding/`)
```
onboarding/
├── data/
│   └── repositories/
│       ├── gender_repository.dart               # Gender preference interface
│       └── gender_repository_impl.dart          # Gender preference implementation
└── presentation/
    ├── cubits/
    │   └── gender_cubit/
    │       ├── gender_cubit.dart                # Gender selection state
    │       └── gender_state.dart                # Gender selection states
    └── screens/
        └── gender_selection_screen.dart          # Gender preference UI
```

**Storage:** Uses LocalStorageService for gender preference persistence

---

## 3. Dependency Injection (DI)

The project uses **GetIt** for dependency injection with a centralized setup in `lib/core/di/injection_container.dart`.

### DI Registration Order:
1. **Core Services** (registered first as dependencies)
   - `FlutterSecureStorage` - Secure token storage
   - `AuthInterceptor` - HTTP request/response interceptor
   - `Dio` - HTTP client with interceptors
   - `SharedPreferences` - Local storage
   - `LocalStorageService` - Abstraction over SharedPreferences

2. **Data Sources** (API layer)
   - `AuthRemoteDataSource` - Authentication API calls
   - `HomeRemoteDataSource` - Products API calls
   - `ProductDetailsDataSource` - Product details API calls

3. **Repositories** (Business logic layer)
   - `AuthRepository` - Authentication business logic
   - `HomeRepository` - Products business logic
   - `GenderRepository` - Gender preference logic
   - `CartRepository` - Cart management logic
   - `ProductDetailsRepository` - Product details logic

4. **Cubits** (State management layer)
   - `LoginCubit` - Authentication state
   - `HomeCubit` - Products state
   - `GenderCubit` - Gender selection state
   - `FavoritesCubit` - Favorites state
   - `CartCubit` - Cart state
   - `ProductDetailsCubit` - Product details state

5. **App Router** - Navigation configuration

### DI Access Pattern:
```dart
// In main.dart
await setupGetIt();

// In widgets/screens
final cubit = getIt<LoginCubit>();
```

### Registration Types:
- **LazySingleton**: Core services, repositories, data sources
- **Factory**: Cubits (new instance per use)

---

## 4. Routing

The app uses **GoRouter** for navigation with a shell-based architecture.

### Route Structure:
```dart
// Main routes
'/' → SplashScreen
'/login' → LoginScreen
'/signup' → SignUpScreen
'/forgot-password' → ForgotPasswordScreen
'/confirm-code' → ConfirmCodeScreen
'/new-password' → NewPasswordScreen
'/gender-selection' → GenderSelectionScreen

// Shell routes (with bottom navigation)
'/home' → HomeScreen
'/favorites' → FavouriteScreen
'/cart' → CartScreen
'/OrderConfirmationScreen' → OrderConfirmationScreen

// Dynamic routes
'/product-details/:id' → ProductDetailsScreen
```

### Navigation Features:
- **Shell Route**: Main app navigation with bottom nav bar
- **BlocProvider Integration**: Automatic cubit injection for shell routes
- **Route Guards**: Authentication-based navigation
- **Deep Linking**: Support for product detail URLs

### Bottom Navigation:
- **Home** (index 0) - Products listing
- **Favorites** (index 1) - Saved products
- **Cart** (index 2) - Shopping cart
- **Profile** (index 3) - User profile (placeholder)

---

## 5. Data Flow

The app follows a **unidirectional data flow** pattern:

UI → Cubit → Repository → Data Source → API

When the response returns from the server, the flow is reversed:

API → Data Source → Repository → Cubit → UI

This structure ensures a clear separation of concerns and makes the app easier to test, maintain, and scale.

### 5.1 API to UI Flow:
```
API Response → Remote Data Source → Repository → Cubit → UI Widget
```

### 5.2 Detailed Flow Example (Products):

1. **UI Trigger**: User opens home screen
2. **Cubit Action**: `HomeCubit.getProducts()` called
3. **Repository Call**: `HomeRepository.getProducts()` invoked
4. **API Request**: `HomeRemoteDataSource.getProducts()` makes HTTP call
5. **Response Processing**: Raw JSON converted to `ProductModel`
6. **State Emission**: `HomeSuccess(products)` emitted
7. **UI Update**: `BlocBuilder` rebuilds with new products

### 5.3 Authentication Flow:
```
Login Request → AuthDataSource → AuthRepository → Token Storage → AuthInterceptor
```

### 5.4 Local Storage Patterns:

#### SharedPreferences Usage:
- **Favorites**: JSON-serialized `ProductModel` list
- **Cart**: JSON-serialized `CartItemModel` list
- **Gender**: Simple string preference

#### FlutterSecureStorage Usage:
- **Access Token**: JWT authentication token
- **Refresh Token**: Token renewal credential
- **Expiration**: Token expiry timestamp

### 5.5 Error Handling:
- **Network Errors**: Caught by Dio interceptors
- **Business Logic Errors**: Handled in repositories
- **UI Errors**: Displayed via cubit error states

### 5.6 State Management:
- **Loading States**: Show loading indicators
- **Success States**: Display data
- **Error States**: Show error messages
- **Empty States**: Handle no-data scenarios

---

## 6. Feature Summaries

### 6.1 Authentication Feature
**Purpose**: User login, registration, and password management

**Screens**: 5 screens (login, signup, forgot password, confirm code, new password)

**Cubits**: `LoginCubit` with states: Initial, Loading, Success, Failure

**Repositories**: `AuthRepository` with token management

**API Endpoints**: 
- `POST /auth/login`
- `POST /auth/refresh-token`

**Key Features**:
- JWT token-based authentication
- Automatic token refresh via interceptor
- Secure token storage using FlutterSecureStorage
- Password recovery flow

### 6.2 Home Feature
**Purpose**: Product listing and browsing

**Screens**: 1 screen (home with product grid)

**Cubits**: `HomeCubit` with product management and favorites integration

**Repositories**: `HomeRepository` for product data

**API Endpoints**: `GET /products` with pagination

**Key Features**:
- Product grid display with pagination
- Real-time favorites integration
- Product search and filtering
- Brand category display

### 6.3 Cart Feature
**Purpose**: Shopping cart management

**Screens**: 2 screens (cart display, order confirmation)

**Cubits**: `CartCubit` with cart state management

**Repositories**: `CartRepository` with local storage

**Services**: `CartService` for business logic

**Key Features**:
- Add/remove products
- Quantity management
- Price calculation
- Local persistence
- Order confirmation flow

### 6.4 Favorites Feature
**Purpose**: Product favorites management

**Screens**: 1 screen (favorites list)

**Cubits**: `FavoritesCubit` with favorites state

**Storage**: SharedPreferences for persistence

**Key Features**:
- Add/remove favorites
- Persistent storage
- Integration with home screen
- Real-time UI updates

### 6.5 Product Details Feature
**Purpose**: Detailed product view

**Screens**: 1 screen (product details)

**Cubits**: `ProductDetailsCubit` for product state

**Repositories**: `ProductDetailsRepository` for data

**Key Features**:
- Detailed product information
- Image gallery
- Add to cart functionality
- Add to favorites
- Product specifications

### 6.6 Onboarding Feature
**Purpose**: User preference setup

**Screens**: 1 screen (gender selection)

**Cubits**: `GenderCubit` for preference management

**Repositories**: `GenderRepository` with local storage

**Key Features**:
- Gender preference selection
- Persistent user preferences
- Integration with user profile

---

## 7. Other Notes

### 7.1 Global Configurations

#### Theme and Styling:
- **Colors**: Centralized in `AppColors` class
- **Typography**: Google Fonts integration with `AppTextStyles`
- **Responsive Design**: Flutter ScreenUtil for screen adaptation
- **Design Size**: 375x812 (iPhone X dimensions)

#### Network Configuration:
- **Base URL**: `https://accessories-eshop.runasp.net/api/`
- **Timeouts**: 30 seconds for connect and receive
- **Interceptors**: Authentication and error handling
- **Error Handling**: Centralized Dio exception handling

### 7.2 Architecture Patterns

#### Clean Architecture Principles:
- **Separation of Concerns**: Clear layer boundaries
- **Dependency Inversion**: Abstract interfaces for dependencies
- **Single Responsibility**: Each class has one purpose
- **Testability**: Easy to mock and test components

#### SOLID Principles:
- **S**: Single Responsibility - Each class has one job
- **O**: Open/Closed - Open for extension, closed for modification
- **L**: Liskov Substitution - Implementations are substitutable
- **I**: Interface Segregation - Small, focused interfaces
- **D**: Dependency Inversion - Depend on abstractions

### 7.3 State Management Patterns

#### BLoC Pattern Implementation:
- **Cubits**: Lightweight state management
- **States**: Immutable state objects using Equatable
- **Events**: User actions trigger state changes
- **BlocBuilder**: Reactive UI updates

#### State Types:
- **Initial**: Starting state
- **Loading**: Data fetching in progress
- **Success**: Data loaded successfully
- **Error**: Error occurred
- **Empty**: No data available

### 7.4 Data Persistence

#### Local Storage Strategy:
- **SharedPreferences**: Simple key-value storage for user preferences
- **FlutterSecureStorage**: Encrypted storage for sensitive data
- **JSON Serialization**: Complex objects stored as JSON strings

#### Storage Keys:
- `favorites`: User's favorite products
- `cart_items`: Shopping cart contents
- `user_gender`: User's gender preference
- `accessToken`: JWT authentication token
- `refreshToken`: Token renewal credential
- `expiresAtUtc`: Token expiration timestamp

### 7.5 Error Handling Strategy

#### Network Errors:
- **DioException**: HTTP-specific errors
- **Timeout**: Network timeout handling
- **Connection**: Network connectivity issues
- **Server**: API server errors

#### Business Logic Errors:
- **Validation**: Input validation errors
- **Authentication**: Login/authorization failures
- **Data**: Data processing errors

#### UI Error Display:
- **Snackbars**: Temporary error messages
- **Error States**: Dedicated error UI states
- **Retry Mechanisms**: User-initiated retry options

### 7.6 Performance Optimizations

#### Image Handling:
- **Caching**: Automatic image caching
- **Lazy Loading**: Images loaded on demand
- **Placeholders**: Loading placeholders for images

#### State Management:
- **Selective Rebuilds**: Only rebuild affected widgets
- **State Persistence**: Maintain state across navigation
- **Memory Management**: Proper disposal of resources

### 7.7 Testing Strategy

#### Unit Testing:
- **Cubits**: State management logic testing
- **Repositories**: Business logic testing
- **Models**: Data transformation testing

#### Widget Testing:
- **Screens**: UI component testing
- **Widgets**: Reusable component testing

#### Integration Testing:
- **API Integration**: End-to-end API testing
- **Navigation**: Route testing
- **User Flows**: Complete user journey testing

### 7.8 Development Guidelines

#### Code Organization:
- **Feature-based**: Group related functionality
- **Layer separation**: Clear data/presentation boundaries
- **Naming conventions**: Consistent naming patterns

#### Documentation:
- **Code comments**: Explain complex logic
- **API documentation**: Endpoint specifications
- **Architecture docs**: System design documentation

#### Version Control:
- **Git workflow**: Feature branch development
- **Commit messages**: Clear, descriptive commits
- **Code reviews**: Peer review process

### 7.9 Deployment Considerations

#### Build Configuration:
- **Environment variables**: API endpoints and keys
- **Build flavors**: Development, staging, production
- **Code signing**: App signing configuration

#### Platform Support:
- **Android**: Minimum SDK version configuration
- **iOS**: Deployment target settings
- **Web**: Progressive web app features

#### Performance Monitoring:
- **Crash reporting**: Error tracking
- **Analytics**: User behavior tracking
- **Performance**: App performance monitoring

---

## Conclusion

This Flutter e-commerce application demonstrates a well-structured, scalable architecture following Clean Architecture principles. The feature-based organization, comprehensive dependency injection, and robust state management provide a solid foundation for future development and maintenance.

The project successfully implements:
- **Clean Architecture** with clear layer separation
- **BLoC Pattern** for predictable state management
- **Dependency Injection** for loose coupling
- **Local Storage** for offline functionality
- **API Integration** with proper error handling
- **Responsive Design** with consistent theming

This documentation serves as a complete reference for understanding, maintaining, and extending the application.

## 8. Implementation Rules (for AI-assisted code generation)

1.Each new feature must contain two layers:

   data/ → with datasources, models, and repositories
   presentation/ → with cubits and screens

2.Register everything (Cubit, Repo, DataSource) in injection_container.dart

3.Routing:

  Always wrap screens with BlocProvider in routes
  Add all new routes in core/routing/app_router.dart

4.Naming conventions must match the existing pattern (e.g. wishlist_cubit.dart, wishlist_repository.dart, wishlist_screen.dart)

5.Data flow should always follow:

  UI → Cubit → Repository → DataSource → API
  API → DataSource → Repository → Cubit → UI



6.Follow Clean Architecture principles:

 No direct API call in the Cubit
 No business logic in the UI
 Repositories are the bridge between data and domain

7. When generating new features using AI (Cursor, ChatGPT, etc.):
   - Always reference this document to maintain consistency.
   - Follow the same DI registration and routing pattern.
   - Keep naming consistent and descriptive.
