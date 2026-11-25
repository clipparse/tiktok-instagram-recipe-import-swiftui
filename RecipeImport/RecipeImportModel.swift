import ClipParse
import Foundation

/// Imports a recipe from a TikTok or Instagram link, and keeps either the
/// recipe or a message to show the user.
@MainActor
final class RecipeImportModel: ObservableObject {
    @Published var recipe: ClipParse.Recipe?
    @Published var message: String?
    @Published var isImporting = false

    private let client = ClipParseClient(apiKey: Secrets.clipParseAPIKey)

    func importRecipe(from link: String) async {
        recipe = nil
        message = nil
        guard let url = URL(string: link.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            message = "That doesn't look like a link."
            return
        }
        isImporting = true
        defer { isImporting = false }
        do {
            switch try await client.extract(url) {
            case .recipe(let found):
                recipe = found
            case .noRecipe(.multipleRecipesDetected):
                message = "This post has more than one recipe."
            case .noRecipe:
                message = "We couldn't find a recipe in this post."
            @unknown default:
                // An outcome added in a later SDK release.
                message = "We couldn't import a recipe from this post."
            }
        } catch {
            message = importErrorMessage(for: error)
        }
    }
}

/// A message for the user, for each way an import can fail.
func importErrorMessage(for error: Error) -> String {
    switch error {
    case ClipParseError.unsupportedPlatform:
        return "Only TikTok and Instagram links are supported."
    case ClipParseError.postUnavailable:
        return "This post was deleted, is private, or doesn't exist."
    case ClipParseError.unauthorized, ClipParseError.invalidAPIKey, ClipParseError.apiKeyRevoked:
        // A problem with the API key: yours to fix, not the user's.
        print("ClipParse API key error:", error)
        return "Recipe import isn't available right now."
    case ClipParseError.quotaExceeded, ClipParseError.rateLimited:
        return "Too many imports right now. Try again later."
    default:
        return "Something went wrong. Please try again."
    }
}

/// The amount to show for an ingredient, such as "2–3 tbsp" or "3".
func amountText(_ ingredient: ClipParse.Ingredient) -> String? {
    guard let quantity = ingredient.quantity else { return nil }
    var amount = quantity.formatted()
    if let low = ingredient.quantityMin, let high = ingredient.quantityMax {
        amount = "\(low.formatted())–\(high.formatted())"
    }
    switch ingredient.unit {
    case nil, .each:
        return amount
    case let unit?:
        return "\(amount) \(unit.rawValue)"
    }
}
