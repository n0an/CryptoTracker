//
//  CoinDetailView.swift
//  CryptoTracker
//
//  Copyright © 2026 Anton Novoselov. All rights reserved.
//

import SwiftUI
import Charts

struct PriceDataPoint: Identifiable {
    let id = UUID()
    let day: Int
    let price: Double
}

struct CoinDetailView: View {
    @Environment(CoinsData.self) private var coinsData
    @Bindable var coin: Coin
    @State private var showingEditAlert = false
    @State private var amountText = ""

    var chartData: [PriceDataPoint] {
        coin.historicalData.enumerated().map { index, price in
            PriceDataPoint(day: index, price: price)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if !coin.historicalData.isEmpty {
                    Chart(chartData) { dataPoint in
                        AreaMark(
                            x: .value("Day", dataPoint.day),
                            y: .value("Price", dataPoint.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.6), .blue.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        LineMark(
                            x: .value("Day", dataPoint.day),
                            y: .value("Price", dataPoint.price)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartXAxis {
                        AxisMarks(values: [0, 5, 10, 15, 20, 25, 30]) { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let day = value.as(Int.self) {
                                    Text("\(30 - day)d")
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel {
                                if let price = value.as(Double.self) {
                                    Text(price.asCurrency)
                                }
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                } else {
                    ProgressView("Loading chart data...")
                        .frame(height: 300)
                }

                if let image = coin.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }

                Text(coin.priceString)
                    .font(.title2)

                Text("You own: \(coin.amount.formatted(.number.precision(.fractionLength(0...4)))) \(coin.symbol)")
                    .font(.title3)
                    .fontWeight(.bold)

                Text(coin.amountValueString)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding()
        }
        .navigationTitle(coin.symbol)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    amountText = coin.amount != 0 ? "\(coin.amount)" : ""
                    showingEditAlert = true
                }
            }
        }
        .task {
            await coinsData.fetchHistoricalData(for: coin)
        }
        .alert("How much \(coin.symbol) do you own?", isPresented: $showingEditAlert) {
            TextField("0.5", text: $amountText)
                .keyboardType(.decimalPad)
            Button("OK") {
                let cleanedText = amountText.replacingOccurrences(of: ",", with: ".")
                if let amount = Double(cleanedText) {
                    coin.saveAmount(amount)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Specify amount")
        }
    }
}

#Preview {
    NavigationStack {
        CoinDetailView(coin: Coin(symbol: "BTC"))
            .environment(CoinsData())
    }
}
