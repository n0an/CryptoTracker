# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is a native iOS/macOS SwiftUI project with no external dependencies. Open `CryptoTracker.xcodeproj` in Xcode and build with ⌘B or run with ⌘R.

## Architecture

**MVVM-style structure using modern Swift patterns:**

- **Model** (`Model/Coin.swift`): `@Observable` class with UserDefaults persistence for price, amount, and historical data
- **Service** (`Services/CoinsData.swift`): `@Observable` class managing coin collection, API calls, and PDF report generation
- **Views** (`Views/`): SwiftUI views consuming data via `@Environment`

**Key patterns:**
- `@Observable` macro (iOS 17+) instead of `ObservableObject`
- `@Environment` injection from app entry point
- Async/await for networking (no Combine)
- `@MainActor` on async methods for thread safety

## Data Flow

1. `CryptoTrackerApp` creates `CoinsData` and injects via `.environment()`
2. Views access `CoinsData` via `@Environment(CoinsData.self)`
3. Coins are hardcoded in `CoinsData.init()` (BTC, ETH, LTC)
4. UserDefaults keys follow pattern: `symbol`, `symbol+amount`, `symbol+history`

## API

Uses CryptoCompare free API (no auth required):
- Multi-price: `https://min-api.cryptocompare.com/data/pricemulti`
- Historical: `https://min-api.cryptocompare.com/data/histoday`

## Key Extension Points

- **Add coins**: Extend the `coins` array in `CoinsData.init()` and add corresponding image to Assets.xcassets
- **Currency formatting**: `Double.asCurrency` extension uses en_US locale
- **PDF reports**: Generated via `generateHTMLReport()` → UIMarkupTextPrintFormatter

## Features

- Biometric auth (Face ID/Touch ID) - optional, controlled by `UserDefaults["secure"]`
- Native SwiftUI Charts for 30-day price history
- PDF export via share sheet
