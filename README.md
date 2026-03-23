# Banking App

A simulated banking app that displays a list of accounts and, upon selection, shows account details with transactions filtered by a date range. Data is fetched via API calls with pagination support.

<img width="1068" height="847" alt="Banking App Screenshot" src="https://github.com/user-attachments/assets/1c10ad7c-7471-465e-8703-a2e0b6bbebc6" />

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** pattern, a natural fit for a project of this scope, keeping the codebase clean and straightforward without unnecessary abstraction layers.

## Design

The UI is built on top of **Apple's design system** complemented by custom components. Leveraging the native design system allows the app to scale seamlessly across all **iPhone, iPad, and Mac** screen sizes, while the custom elements provide visual identity and a unified color scheme.

## Localization

The app is fully localized in **9 languages**:

- English
- Arabic
- Simplified Chinese
- French
- German
- Italian
- Japanese
- Brazilian Portuguese
- Spanish

## Reusable Components

Reusable UI components can be found inside the `Views/Components` folder. All views include **SwiftUI Previews with mocked data**, which serve three purposes:

1. **Visualize** screens and components in isolation.
2. **Test** display and layout across configurations.
3. **Document** usage — each preview acts as a working example of how to use the component.
