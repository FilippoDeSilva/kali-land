# Theming System

This document describes the theming system for the kali-land Desktop.

## Philosophy

The theming system follows these principles:

- **Centralized** theme definitions
- **Token-based** design system
- **Consistent** visual language
- **Extensible** for future themes
- **Runtime** theme switching support

## Theme Structure

Themes are located in `themes/`:

```
themes/
├── default/
│   ├── colors.qml          # Color tokens
│   ├── spacing.qml         # Spacing tokens
│   ├── typography.qml      # Typography tokens
│   ├── effects.qml         # Effects and shadows
│   └── radius.qml          # Border radius tokens
└── wallpapers/
    └── default.jpg         # Default wallpaper
```

## Color Tokens

Colors are defined in `themes/default/colors.qml`:

```qml
pragma Singleton
import QtQuick

QtObject {
    // Background colors
    readonly property color background: "#1e1e2e"
    readonly property color surface: "#313244"
    readonly property color surfaceElevated: "#45475a"
    
    // Foreground colors
    readonly property color foreground: "#cdd6f4"
    readonly property color muted: "#a6adc8"
    
    // Accent colors
    readonly property color accent: "#89b4fa"
    readonly property color accentHover: "#b4befe"
    
    // Status colors
    readonly property color success: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color danger: "#f38ba8"
    
    // Border colors
    readonly property color border: "#45475a"
    readonly property color borderFocus: "#89b4fa"
}
```

## Spacing Tokens

Spacing is defined in `themes/default/spacing.qml`:

```qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int xs: 4
    readonly property int sm: 8
    readonly property int md: 16
    readonly property int lg: 24
    readonly property int xl: 32
    readonly property int xxl: 48
}
```

## Typography Tokens

Typography is defined in `themes/default/typography.qml`:

```qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int fontSizeXS: 10
    readonly property int fontSizeSM: 12
    readonly property int fontSizeMD: 14
    readonly property int fontSizeLG: 16
    readonly property int fontSizeXL: 18
    readonly property int fontSizeXXL: 24
    
    readonly property string fontFamily: "Sans"
    readonly property string fontFamilyMono: "Monospace"
}
```

## Radius Tokens

Border radius is defined in `themes/default/radius.qml`:

```qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int sm: 4
    readonly property int md: 8
    readonly property int lg: 12
    readonly property int xl: 16
    readonly property int full: 9999
}
```

## Effects Tokens

Effects and shadows are defined in `themes/default/effects.qml`:

```qml
pragma Singleton
import QtQuick

QtObject {
    readonly property int shadowSmall: 2
    readonly property int shadowMedium: 4
    readonly property int shadowLarge: 8
    
    readonly property int opacityDisabled: 0.5
    readonly property int opacityHover: 0.8
    readonly property int opacityFocus: 1.0
}
```

## Using Theme Tokens

In QML components, import and use theme tokens:

```qml
import QtQuick
import QtQuick.Controls
import "../theme" as Theme

Rectangle {
    color: Theme.Colors.background
    border.color: Theme.Colors.border
    border.width: 1
    radius: Theme.Radius.md
    
    Text {
        color: Theme.Colors.foreground
        font.pixelSize: Theme.Typography.fontSizeMD
        font.family: Theme.Typography.fontFamily
    }
}
```

## Creating Custom Themes

To create a custom theme:

1. Copy the default theme:
   ```bash
   cp -r themes/default themes/mytheme
   ```

2. Modify the color tokens in `themes/mytheme/colors.qml`

3. Update the theme reference in your Quickshell configuration

4. Reload Quickshell to see changes

## Color Palettes

### Catppuccin Mocha (Default)

The default theme uses the Catppuccin Mocha color palette:

- **Background**: Deep blue-gray (#1e1e2e)
- **Surface**: Lighter blue-gray (#313244)
- **Foreground**: Soft white (#cdd6f4)
- **Accent**: Sky blue (#89b4fa)

### Alternative Palettes

You can create themes based on other popular palettes:

- **Dracula**: Dark, high-contrast theme
- **Gruvbox**: Warm, retro theme
- **Nord**: Cool, arctic theme
- **Tokyo Night**: Modern, dark theme

## Wallpaper Management

Wallpapers are stored in `themes/wallpapers/`:

1. Add your wallpaper to the directory
2. Update the wallpaper script to reference your file
3. The wallpaper system supports:
   - Static images
   - Slideshow rotation
   - Time-based changes

## GTK Theme

For GTK applications, set the GTK theme:

1. Install a GTK theme (e.g., Catppuccin GTK)
2. Configure in `~/.config/gtk-3.0/settings.ini`:
   ```ini
   [Settings]
   gtk-theme-name=Catppuccin-Mocha-Standard-Blue-dark
   gtk-icon-theme-name=Papirus-Dark
   gtk-font-name=Sans 10
   ```

## Terminal Theme

For terminal applications (kitty, foot):

1. Configure terminal colors to match the theme
2. Example kitty configuration in `config/kitty/kitty.conf`:
   ```conf
   foreground #cdd6f4
   background #1e1e2e
   cursor #f5e0dc
   ```

## Theme Switching

To switch themes at runtime:

1. Update the theme configuration
2. Reload Quickshell: `quickshell --reload`
3. The theme will apply immediately

## Best Practices

- **Always use theme tokens** instead of hard-coded values
- **Keep contrast ratios** accessible (WCAG AA minimum)
- **Test in different lighting conditions**
- **Consider color blindness** when choosing accent colors
- **Maintain consistency** across all components
- **Document custom themes** for future reference

## Troubleshooting

### Theme Not Applying

If the theme doesn't apply:

1. Check that theme files exist
2. Verify QML imports are correct
3. Check Quickshell logs for errors
4. Ensure singleton pattern is working

### Colors Look Wrong

If colors appear incorrect:

1. Verify color format (hex with #)
2. Check for color profile issues
3. Test with simple QML component
4. Check Qt version compatibility

### Performance Issues

If theming causes performance issues:

1. Reduce shadow complexity
2. Simplify animations
3. Use solid colors instead of gradients
4. Cache complex components
