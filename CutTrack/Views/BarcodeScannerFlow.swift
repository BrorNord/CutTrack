import SwiftUI
import VisionKit
import Vision

struct BarcodeScannerFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var barcode: String?
    @State private var product: ScannedFood?
    @State private var loading = false
    @State private var notFound = false

    var body: some View {
        NavigationStack {
            Group {
                if let product {
                    AddFoodView(preset: product)
                } else if loading {
                    SwiftUI.ProgressView("Looking up product…")
                } else if notFound, let barcode {
                    ContentUnavailableView {
                        Label("Product not found", systemImage: "questionmark.circle")
                    } description: {
                        Text("Barcode \(barcode) is not in the database.")
                    } actions: {
                        Button("Scan another") {
                            self.barcode = nil
                            notFound = false
                        }
                    }
                } else {
                    BarcodeScannerView { code in
                        guard barcode == nil else { return }
                        barcode = code
                        Task { await lookup(code) }
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("Scan barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
            }
        }
    }

    private func lookup(_ code: String) async {
        loading = true
        defer { loading = false }
        do {
            product = try await FoodLookupService().lookup(barcode: code)
            notFound = product == nil
        } catch {
            notFound = true
        }
    }
}

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        guard DataScannerViewController.isSupported,
              DataScannerViewController.isAvailable else {
            return UIHostingController(rootView:
                ContentUnavailableView("Scanner unavailable", systemImage: "camera.fill")
            )
        }

        let controller = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .upce, .code128])],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        try? controller.startScanning()
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onScan: onScan) }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onScan: (String) -> Void
        init(onScan: @escaping (String) -> Void) { self.onScan = onScan }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case let .barcode(code) = item, let payload = code.payloadStringValue {
                    onScan(payload)
                    dataScanner.stopScanning()
                    return
                }
            }
        }
    }
}
