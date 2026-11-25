import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Appears in the share sheet for links. It imports the shared post right
/// here, with the same code as the app, and shows the recipe.
final class ShareViewController: UIViewController {
    private let model = RecipeImportModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        let screen = UIHostingController(rootView: ShareImportView(model: model) { [weak self] in
            self?.extensionContext?.completeRequest(returningItems: nil)
        })
        addChild(screen)
        screen.view.frame = view.bounds
        screen.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(screen.view)
        screen.didMove(toParent: self)

        let provider = (extensionContext?.inputItems.first as? NSExtensionItem)?
            .attachments?
            .first { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }
        guard let provider else {
            model.message = "Share a TikTok or Instagram link."
            return
        }
        provider.loadItem(forTypeIdentifier: UTType.url.identifier) { [model] item, _ in
            Task { @MainActor in
                guard let url = item as? URL else {
                    model.message = "Share a TikTok or Instagram link."
                    return
                }
                await model.importRecipe(from: url.absoluteString)
            }
        }
    }
}

private struct ShareImportView: View {
    @ObservedObject var model: RecipeImportModel
    let done: () -> Void

    var body: some View {
        NavigationView {
            Form {
                if model.isImporting {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Importing the recipe…").padding(.leading, 8)
                        }
                    }
                }
                ImportResult(model: model)
            }
            .navigationTitle("Recipe import")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: done)
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
