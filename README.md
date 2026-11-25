# Import recipes from TikTok and Instagram links in a SwiftUI app

A small SwiftUI app that imports a recipe from a TikTok or Instagram link with the [ClipParse iOS SDK](https://github.com/clipparse/clipparse-ios-sdk). Paste a link, or share a post from the TikTok or Instagram app, and get back the recipe as structured data: the title, ingredients with quantities and units, ordered steps, timings and servings.

The code is meant to be copied: take what you need into your own app.

## Run it

1. Get a free ClipParse API key at [clipparse.com/get-free-key](https://clipparse.com/get-free-key). It takes seconds and doesn't require a credit card.
2. Copy `RecipeImport/Secrets.example.swift` to `RecipeImport/Secrets.swift` and paste your key. `Secrets.swift` is gitignored, and the build needs it.
3. Open `RecipeImport.xcodeproj` in Xcode 15 or later and run the `RecipeImport` scheme. Xcode fetches the SDK with Swift Package Manager.

To run on a device, pick your team under Signing & Capabilities for both targets, and change the bundle identifiers from `com.example.RecipeImport`.

## What's in it

| File | What it does |
| --- | --- |
| [`RecipeImport/RecipeImportModel.swift`](RecipeImport/RecipeImportModel.swift) | Calls the SDK, and turns each outcome and error into a message for the user. Also `amountText`, which formats an ingredient's amount ("2–3 tbsp"). |
| [`RecipeImport/ImportView.swift`](RecipeImport/ImportView.swift) | The screen: a link field, an Import button, and the result. |
| [`RecipeImport/RecipeView.swift`](RecipeImport/RecipeView.swift) | Shows the recipe: thumbnail, servings and times, ingredients and steps grouped by section. |
| [`ShareExtension/ShareViewController.swift`](ShareExtension/ShareViewController.swift) | A share extension, so the app appears in the share sheet for links, from TikTok, Instagram or Safari. It imports the shared post and shows the recipe, reusing the app's `RecipeImportModel` and result view. |

The share extension shows the recipe in the share sheet and doesn't pass it to the app. To keep the recipe in your app, for example to save it, write it to an App Group container that the app reads.

## Learn more

- [Guide: import recipes from TikTok and Instagram links in an iOS app](https://docs.clipparse.com/guides/import-recipes-from-tiktok-instagram-ios) walks through this code step by step.
- The [API reference](https://docs.clipparse.com/) lists every recipe field and outcome.
- [Pricing](https://clipparse.com/pricing) covers what each import costs and the plans past the free tier.

Building for Android? See the [Jetpack Compose example](https://github.com/clipparse/tiktok-instagram-recipe-import-compose).

## License

The code in this repository is under the [MIT License](LICENSE). The ClipParse SDK it depends on has [its own license](https://clipparse.com/sdk-license).
