import SwiftUI

/// Paste a TikTok or Instagram link, import it, and show the recipe.
struct ImportView: View {
    @StateObject private var model = RecipeImportModel()
    @State private var link = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("TikTok or Instagram link", text: $link)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .onSubmit(startImport)
                    Button(action: startImport) {
                        HStack {
                            Text("Import recipe")
                            if model.isImporting {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(link.isEmpty || model.isImporting)
                } footer: {
                    Text("You can also share a post to this app from TikTok or Instagram.")
                }

                ImportResult(model: model)
            }
            .navigationTitle("Recipe import")
        }
        .navigationViewStyle(.stack)
    }

    private func startImport() {
        Task { await model.importRecipe(from: link) }
    }
}

/// The recipe, or the message explaining why there isn't one.
struct ImportResult: View {
    @ObservedObject var model: RecipeImportModel

    var body: some View {
        if let message = model.message {
            Section {
                Text(message).foregroundStyle(.red)
            }
        }
        if let recipe = model.recipe {
            RecipeSections(recipe: recipe)
        }
    }
}
