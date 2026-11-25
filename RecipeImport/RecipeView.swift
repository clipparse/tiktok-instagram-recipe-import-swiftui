import ClipParse
import SwiftUI

/// The imported recipe, as sections of a `Form` or `List`.
struct RecipeSections: View {
    let recipe: ClipParse.Recipe

    var body: some View {
        Section {
            if let thumbnail = recipe.thumbnailUrl.flatMap(URL.init(string:)) {
                AsyncImage(url: thumbnail) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.secondary.opacity(0.1)
                }
                .frame(height: 200)
                .clipped()
                .listRowInsets(EdgeInsets())
            }
            Text(recipe.title).font(.title2.bold())
            if let summary = summaryLine {
                Text(summary).foregroundStyle(.secondary)
            }
            if let source = URL(string: recipe.sourceUrl) {
                Link("Open the original post", destination: source)
            }
        }

        ForEach(Array(ingredientGroups.enumerated()), id: \.offset) { _, group in
            Section(group.title ?? "Ingredients") {
                ForEach(Array(group.ingredients.enumerated()), id: \.offset) { _, ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }
        }

        ForEach(Array(stepGroups.enumerated()), id: \.offset) { _, group in
            Section(group.title ?? "Steps") {
                ForEach(Array(group.steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1).").bold()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.text)
                            if let minutes = step.durationMinutes {
                                Text("\(minutes) min").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Servings and times, such as "4 servings · 10 min prep · 25 min cook".
    private var summaryLine: String? {
        var parts: [String] = []
        if let servings = recipe.servings { parts.append("\(servings.formatted()) servings") }
        if let prep = recipe.prepTimeMinutes { parts.append("\(prep) min prep") }
        if let cook = recipe.cookTimeMinutes { parts.append("\(cook) min cook") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    /// Ingredients grouped by their section ("For the sauce"), in post order.
    private var ingredientGroups: [(title: String?, ingredients: [ClipParse.Ingredient])] {
        grouped(recipe.ingredients, by: \.section).map { (title: $0.title, ingredients: $0.items) }
    }

    /// Steps grouped by their section, in post order.
    private var stepGroups: [(title: String?, steps: [ClipParse.Step])] {
        grouped(recipe.steps, by: \.section).map { (title: $0.title, steps: $0.items) }
    }
}

/// Splits items into runs that share the same section, keeping their order.
private func grouped<Item>(_ items: [Item], by section: (Item) -> String?) -> [(title: String?, items: [Item])] {
    var groups: [(title: String?, items: [Item])] = []
    for item in items {
        if let last = groups.last, last.title == section(item) {
            groups[groups.count - 1].items.append(item)
        } else {
            groups.append((section(item), [item]))
        }
    }
    return groups
}

private struct IngredientRow: View {
    let ingredient: ClipParse.Ingredient

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                if let prep = ingredient.prep {
                    Text(prep).font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
            if let amount = amountText(ingredient) {
                Text(amount).foregroundStyle(.secondary)
            }
        }
    }
}
