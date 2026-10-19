# E-Dumper

E-Dumper is a Flutter prototype for selling used or damaged phones. A user can
choose a phone, describe its condition, see an estimated offer, enter a pickup
address, and view the order status. The app also has sample offers, account
screens, a profile, and an order history.

## Project details

- **Purpose:** Demonstrate a phone buyback app flow from device selection to
  quote and order tracking.
- **Language and framework:** Dart and Flutter, using Material widgets.
- **Platforms:** The Flutter project is configured for Android, iOS, web,
  Windows, macOS, and Linux.
- **Price estimates:** Calculated from example phone values stored in the app.
  Selected damage and a missing original bill reduce the estimate. Prices are
  fixed examples, not live market prices or an AI assessment.
- **Local data:** Account profiles, orders, and pickup addresses use
  `shared_preferences` on the current device. Passwords are hashed locally
  with `crypto`.
- **Demo limits:** There is no server, real authentication service, live buyer,
  payment, or pickup booking. Offers are sample data. Bank details screens are
  present, but saving bank details is not connected to storage yet.

## Where to find the code

Start in `lib`: that folder contains the app's Dart code. The names below use
plain descriptions so you can find a page or feature without knowing Flutter
terms.

### Start the app

- `lib/main.dart` is the starting point when the app runs.
- `lib/app.dart` creates the Flutter app and opens the welcome page.

### Pages (`lib/screens`)

- `welcome_screen.dart` — first screen, with the app logo and start button.
- `getting_started_screen.dart` — short introduction; lets the user continue
  as a guest or open sign-in.
- `login_screen.dart` — sign in or create an account.
- `dashboard_screen.dart` — holds the main navigation and opens Home, Sell,
  Orders, and Profile.
- `home_screen.dart` — home page with offers, notifications, and sales totals.
- `choose_brand_screen.dart` — start selling by choosing a phone brand.
- `device_details_screen.dart` — choose the phone model, storage, and bill status.
- `phone_condition_screen.dart` — select damage or other problems with the phone.
- `price_offer_screen.dart` — see the estimated price and continue with the sale.
- `address_screen.dart` — add or update the pickup address.
- `tracking_screen.dart` — see the order's progress.
- `orders_screen.dart` — see saved orders.
- `profile_screen.dart` — view and update account details and preferences.

The sell flow goes in this order: choose brand → phone details → phone condition
→ price offer → pickup address → order tracking.

### Saved information shapes (`lib/models`)

- `user_profile.dart` — a person's name, email, and phone number.
- `user_address.dart` — pickup address details.
- `bank_details.dart` — bank account and UPI fields.
- `phone_sale_details.dart` — the phone, bill, and condition details used for
  a price estimate.
- `offer.dart` — one sample buying offer.
- `order.dart` — a saved phone sale and its order status.

### App actions and local data (`lib/services`)

- `local_account_service.dart` — creates accounts, signs in, and saves profiles
  on this device.
- `address_service.dart` — saves and loads pickup addresses on this device.
- `order_service.dart` — saves and loads orders on this device.
- `offer_service.dart` — provides the sample offers shown in the app.
- `price_estimate_service.dart` — contains sample phone prices and estimates
  deductions for selected damage or a missing bill.
- `bank_details_service.dart` — bank details storage placeholder; it does not
  save details yet.
- `app_text.dart` — screen text and the `tr(...)` helper used to display it.

### Reusable pieces (`lib/widgets`)

- `app_panel.dart` — shared page background and layout.
- `welcome_header.dart`, `logo.dart`, and `terms_text.dart` — welcome page logo,
  heading, and terms text.
- `screen_header.dart` — shared heading at the top of a page.
- `text_input_field.dart` — labeled text box, including password visibility.
- `action_button.dart` and `get_started_button.dart` — reusable buttons.
- `stats_card.dart` — sales totals and statistic display.
- `grid_background.dart` — decorative grid pattern.

### Colors and project files

- `lib/theme/colors.dart` — shared app colors.
- `test/widget_test.dart` — a Flutter test for the app's basic screen setup.
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, and `linux/` — platform
  setup and native app files. Most app features are in `lib/` instead.
- `pubspec.yaml` — app name, packages, and assets; `pubspec.lock` records the
  exact package versions.
- `.dart_tool/` and `build/` — generated Flutter files; normally you do not
  need to navigate these for app features.

## Run the app

From this folder, run:

```sh
flutter pub get
flutter run
```

Use `flutter devices` to see available targets. To select one explicitly:

```sh
flutter run -d <device-id>
```

## Check the project

```sh
flutter analyze
flutter test
```
