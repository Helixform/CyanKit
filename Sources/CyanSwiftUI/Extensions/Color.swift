//
//  Created by ktiays on 2022/3/20.
//  Copyright (c) 2022 ktiays. All rights reserved.
//

import SwiftUI
import CyanExtensions

public extension Color {
    
    init(platformColor: PlatformColor) {
        #if canImport(UIKit)
        if #available(iOS 15.0, tvOS 15.0, *) {
            self.init(uiColor: platformColor)
        } else {
            self.init(platformColor)
        }
        #else
        if #available(macOS 12.0, *) {
            self.init(nsColor: platformColor)
        } else {
            self.init(platformColor)
        }
        #endif
    }
    
    @inlinable init(lightColor: PlatformColor, darkColor: PlatformColor) {
        self.init(platformColor: .init(lightColor: lightColor, darkColor: darkColor))
    }
    
}

// MARK: - Constants

// Adaptable Colors
public extension Color {
    
    /// A context-dependent red color that automatically adapts to the current trait environment.
    static let systemRed: Color = .init(platformColor: .systemRed)
    
    /// A context-dependent orange color that automatically adapts to the current trait environment.
    static let systemOrange: Color = .init(platformColor: .systemOrange)
    
    /// A context-dependent yellow color that automatically adapts to the current trait environment.
    static let systemYellow: Color = .init(platformColor: .systemYellow)
    
    /// A context-dependent green color that automatically adapts to the current trait environment.
    static let systemGreen: Color = .init(platformColor: .systemGreen)
    
    /// A context-dependent blue color that automatically adapts to the current trait environment.
    static let systemBlue: Color = .init(platformColor: .systemBlue)
    
    /// A context-dependent indigo color that automatically adapts to the current trait environment.
    static let systemIndigo: Color = .init(platformColor: .systemIndigo)
    
    /// A context-dependent purple color that automatically adapts to the current trait environment.
    static let systemPurple: Color = .init(platformColor: .systemPurple)
    
    /// A context-dependent pink color that automatically adapts to the current trait environment.
    static let systemPink: Color = .init(platformColor: .systemPink)
    
    /// A context-dependent teal color that automatically adapts to the current trait environment.
    static let systemTeal: Color = .init(platformColor: .systemTeal)
    
    /// A context-dependent cyan color that automatically adapts to the current trait environment.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    static let systemCyan: Color = .init(platformColor: .systemCyan)
    
    /// A context-dependent mint color that automatically adapts to the current trait environment.
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    static let systemMint: Color = .init(platformColor: .systemMint)
    
    
    /* Gray Colors */
    
    /// A context-dependent gray color that automatically adapts to the current trait environment.
    static let systemGray: Color = .init(platformColor: .systemGray)
    
    #if canImport(UIKit) && !os(tvOS)
    
    /// A second-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray`.
    /// In dark environments, this gray is slightly darker than `systemGray`.
    static let systemGray2: Color = .init(platformColor: .systemGray2)
    
    /// A third-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray2`.
    /// In dark environments, this gray is slightly darker than `systemGray2`.
    static let systemGray3: Color = .init(platformColor: .systemGray3)
    
    /// A fourth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray3`.
    /// In dark environments, this gray is slightly darker than `systemGray3`.
    static let systemGray4: Color = .init(platformColor: .systemGray4)
    
    /// A fifth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray4`.
    /// In dark environments, this gray is slightly darker than `systemGray4`.
    static let systemGray5: Color = .init(platformColor: .systemGray5)
    
    /// A sixth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment, and is close in color to systemBackground.
    /// In light environments, this gray is slightly lighter than `systemGray5`.
    /// In dark environments, this gray is slightly darker than `systemGray5`.
    static let systemGray6: Color = .init(platformColor: .systemGray6)
    
    #elseif canImport(AppKit)
    
    /// A second-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray`.
    /// In dark environments, this gray is slightly darker than `systemGray`.
    static let systemGray2: Color = .init(lightColor: .init(integalRed: 174, green: 174, blue: 178, alpha: 1),
                                          darkColor: .init(integalRed: 99, green: 99, blue: 102, alpha: 1))
    
    /// A third-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray2`.
    /// In dark environments, this gray is slightly darker than `systemGray2`.
    static let systemGray3: Color = .init(lightColor: .init(integalRed: 199, green: 199, blue: 204, alpha: 1),
                                          darkColor: .init(integalRed: 72, green: 72, blue: 74, alpha: 1))
    
    /// A fourth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray3`.
    /// In dark environments, this gray is slightly darker than `systemGray3`.
    static let systemGray4: Color = .init(lightColor: .init(integalRed: 209, green: 209, blue: 214, alpha: 1),
                                          darkColor: .init(integalRed: 58, green: 58, blue: 60, alpha: 1))
    
    /// A fifth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment.
    /// In light environments, this gray is slightly lighter than `systemGray4`.
    /// In dark environments, this gray is slightly darker than `systemGray4`.
    static let systemGray5: Color = .init(lightColor: .init(integalRed: 229, green: 229, blue: 234, alpha: 1),
                                          darkColor: .init(integalRed: 44, green: 44, blue: 46, alpha: 1))
    
    /// A sixth-level shade of gray that adapts to the environment.
    ///
    /// This color adapts to the current environment, and is close in color to systemBackground.
    /// In light environments, this gray is slightly lighter than `systemGray5`.
    /// In dark environments, this gray is slightly darker than `systemGray5`.
    static let systemGray6: Color = .init(lightColor: .init(integalRed: 242, green: 242, blue: 247, alpha: 1),
                                          darkColor: .init(integalRed: 28, green: 28, blue: 30, alpha: 1))
    
    #endif
    
}

// Fixed Colors
public extension Color {
    
    /// A color object with RGB values of 1.0, 0.0, and 1.0, and an alpha value of 1.0.
    static let magenta: Color = .init(platformColor: .magenta)
    
    /// A color object with a grayscale value of 1/3 and an alpha value of 1.0.
    static let darkGray: Color = .init(platformColor: .darkGray)
    
    /// A color object with a grayscale value of 2/3 and an alpha value of 1.0.
    static let lightGray: Color = .init(platformColor: .lightGray)
    
}

#if os(iOS)
// UI Element Colors
@available(iOS 13.0, *)
public extension Color {
    
    @available(iOS 15.0, *)
    static let tintColor: Color = .init(platformColor: .tintColor)
    
    
    /* Label Colors */
    
    /// The color for text labels that contain primary content.
    static let label: Color = .init(platformColor: .label)
    
    /// The color for text labels that contain secondary content.
    static let secondaryLabel: Color = .init(platformColor: .secondaryLabel)
    
    /// The color for text labels that contain tertiary content.
    static let tertiaryLabel: Color = .init(platformColor: .tertiaryLabel)
    
    /// The color for text labels that contain quaternary content.
    static let quaternaryLabel: Color = .init(platformColor: .quaternaryLabel)
    
    
    /* Link Color */
    
    /// The specified color for links.
    static let link: Color = .init(platformColor: .link)
    
    
    /* Text Colors */
    
    /// The color for placeholder text in controls or text views.
    static let placeholderText: Color = .init(platformColor: .placeholderText)
    
    
    /* Separator Colors */
    
    /// The color for thin borders or divider lines that allows some underlying content to be visible.
    ///
    /// This color may be partially transparent to allow the underlying content to show through.
    /// It adapts to the underlying trait environment.
    static let separator: Color = .init(platformColor: .separator)
    
    /// The color for borders or divider lines that hides any underlying content.
    ///
    /// This color is always opaque. It adapts to the underlying trait environment.
    static let opaqueSeparator: Color = .init(platformColor: .opaqueSeparator)
    
    
    /* Standard Content Background Colors */
    
    /// The color for the main background of your interface.
    ///
    /// Use this color for standard table views and designs that have a white primary background in a light environment.
    static let systemBackground: Color = .init(platformColor: .systemBackground)
    
    /// The color for content layered on top of the main background.
    ///
    /// Use this color for standard table views and designs that have a white primary background in a light environment.
    static let secondarySystemBackground: Color = .init(platformColor: .secondarySystemBackground)
    
    /// The color for content layered on top of secondary backgrounds.
    ///
    /// Use this color for standard table views and designs that have a white primary background in a light environment.
    static let tertiarySystemBackground: Color = .init(platformColor: .tertiarySystemBackground)
    
    
    /* Grouped Content Background Colors */
    
    /// The color for the main background of your grouped interface.
    ///
    /// Use this color for grouped content, including table views and platter-based designs.
    static let systemGroupedBackground: Color = .init(platformColor: .systemGroupedBackground)
    
    /// The color for content layered on top of the main background of your grouped interface.
    ///
    /// Use this color for grouped content, including table views and platter-based designs.
    static let secondarySystemGroupedBackground: Color = .init(platformColor: .secondarySystemGroupedBackground)
    
    /// The color for content layered on top of secondary backgrounds of your grouped interface.
    ///
    /// Use this color for grouped content, including table views and platter-based designs.
    static let tertiarySystemGroupedBackground: Color = .init(platformColor: .tertiarySystemGroupedBackground)
    
    
    /* Fill Colors */
    
    /// An overlay fill color for thin and small shapes.
    ///
    /// Use system fill colors for items situated on top of an existing background color.
    /// System fill colors incorporate transparency to allow the background color to show through.
    ///
    /// Use this color to fill thin or small shapes, such as the track of a slider.
    static let systemFill: Color = .init(platformColor: .systemFill)
    
    /// An overlay fill color for medium-size shapes.
    ///
    /// Use system fill colors for items situated on top of an existing background color.
    /// System fill colors incorporate transparency to allow the background color to show through.
    ///
    /// Use this color to fill medium-size shapes, such as the background of a switch.
    static let secondarySystemFill: Color = .init(platformColor: .secondarySystemFill)
    
    /// An overlay fill color for large shapes.
    ///
    /// Use system fill colors for items situated on top of an existing background color.
    /// System fill colors incorporate transparency to allow the background color to show through.
    ///
    /// Use this color to fill large shapes, such as input fields, search bars, or buttons.
    static let tertiarySystemFill: Color = .init(platformColor: .tertiarySystemFill)
    
    /// An overlay fill color for large areas that contain complex content.
    ///
    /// Use system fill colors for items situated on top of an existing background color.
    /// System fill colors incorporate transparency to allow the background color to show through.
    ///
    /// Use this color to fill large areas that contain complex content, such as an expanded table cell.
    static let quaternarySystemFill: Color = .init(platformColor: .quaternarySystemFill)
    
    
    /* Nonadaptable Colors */
    
    /// The nonadaptable system color for text on a dark background.
    ///
    /// This color doesn’t adapt to changes in the underlying trait environment.
    static let lightText: Color = .init(platformColor: .lightText)
    
    /// The nonadaptable system color for text on a light background.
    ///
    /// This color doesn’t adapt to changes in the underlying trait environment.
    static let darkText: Color = .init(platformColor: .darkText)
    
}
#elseif canImport(AppKit)
@available(macOS 10.10, *)
public extension Color {
    
    /* Label Colors */
    
    /// The primary color to use for text labels.
    ///
    /// Use this color in the most important text labels of your user interface.
    /// You can also use it for other types of primary app content.
    static let label: Color = .init(platformColor: .labelColor)
    
    /// The secondary color to use for text labels.
    ///
    /// Use this color in text fields that contain less important text in your user interface.
    /// For example, you might use this in labels that display subheads or additional information.
    /// You can also use it for other types of secondary app content.
    static let secondaryLabel: Color = .init(platformColor: .secondaryLabelColor)
    
    /// The tertiary color to use for text labels.
    ///
    /// Use this color for disabled text and for other less important text in your interface.
    /// You can also use it for other types of tertiary app content.
    static let tertiaryLabel: Color = .init(platformColor: .tertiaryLabelColor)
    
    /// The quaternary color to use for text labels and separators.
    ///
    /// Use this color for the least important text in your interface and for separators between text items.
    /// For example, you would use this color for secondary text that is disabled.
    /// You can also use it for other types of quaternary app content.
    static let quaternaryLabel: Color = .init(platformColor: .quaternaryLabelColor)
    
    
    /* Text Colors */
    
    /// The color to use for text.
    ///
    /// When text is selected, its color changes to the return value of `selectedText`.
    static let text: Color = .init(platformColor: .textColor)
    
    /// The color to use for placeholder text in controls or text views.
    static let placeholderText: Color = .init(platformColor: .placeholderTextColor)
    
    /// The color to use for selected text.
    static let selectedText: Color = .init(platformColor: .selectedTextColor)
    
    /// The color to use for the background area behind text.
    ///
    /// When text is selected, its background color changes to the return value of `selectedTextBackground`.
    /// With Desktop Tinting, the system modifies this color dynamically by incorporating some of the color from the underlying desktop image.
    /// The system does not apply this dynamic tinting effect to other types of views.
    static let textBackground: Color = .init(platformColor: .textBackgroundColor)
    
    /// The color to use for the background of selected text.
    static let selectedTextBackground: Color = .init(platformColor: .selectedTextBackgroundColor)
    
    /// The color to use for the keyboard focus ring around controls.
    static let keyboardFocusIndicator: Color = .init(platformColor: .keyboardFocusIndicatorColor)
    
    /// The color to use for selected text in an unemphasized context.
    ///
    /// Use this color when the window containing the text is not key, or when the view containing the text does not have key focus.
    @available(macOS 10.14, *)
    static let unemphasizedSelectedTextBackground: Color = .init(platformColor: .unemphasizedSelectedTextBackgroundColor)
    
    /// The color to use for the text background in an unemphasized context.
    ///
    /// Use this color when the window containing the text is not key, or when the view containing the text does not have key focus.
    @available(macOS 10.14, *)
    static let unemphasizedSelectedText: Color = .init(platformColor: .unemphasizedSelectedTextColor)
    
    
    /* Content Colors */
    
    /// The color to use for links.
    static let link: Color = .init(platformColor: .linkColor)
    
    /// The color to use for separators between different sections of content.
    ///
    /// Do not use this color for split view dividers or window chrome dividers.
    @available(macOS 10.14, *)
    static let separator: Color = .init(platformColor: .separatorColor)
    
    /// The color to use for the background of selected and emphasized content.
    @available(macOS 10.14, *)
    static let selectedContentBackground: Color = .init(platformColor: .selectedContentBackgroundColor)
    
    /// The color to use for selected and unemphasized content.
    ///
    /// Use this color when the window containing the content is not key, or when the view containing the content does not have key focus.
    @available(macOS 10.14, *)
    static let unemphasizedSelectedContentBackground: Color = .init(platformColor: .unemphasizedSelectedContentBackgroundColor)
    
    
    /* Menu Colors */
    
    /// The color to use for the text in menu items.
    ///
    /// The system color used for text in selected menu items.
    static let selectedMenuItemText: Color = .init(platformColor: .selectedMenuItemTextColor)
    
    
    /* Table Colors */
    
    /// The color to use for the optional gridlines, such as those in a table view.
    ///
    /// The system color used for gridlines.
    static let gridColor: Color = .init(platformColor: .gridColor)
    
    /// The color to use for text in header cells in table views and outline views.
    ///
    /// The system color used for text in header cells in table and outline views.
    static let headerText: Color = .init(platformColor: .headerTextColor)
    
    /// The colors to use for alternating content, typically found in table views and collection views.
    @available(macOS 10.14, *)
    static let alternatingContentBackgroundColors: [Color] = NSColor.alternatingContentBackgroundColors.map { .init(platformColor: $0) }
    
    
    /* Control Colors */
    
    /// The color to use for the flat surfaces of a control.
    ///
    /// The system color used for the flat surfaces of a control.
    /// By default, the control color is a pattern color that will draw the ruled lines for the window background, which is the same as returned by `windowBackground`.
    ///
    /// If you use controlColor assuming that it is a solid, you may have an incorrect appearance. You should use `lightGray` in its place.
    static let control: Color = .init(platformColor: .controlColor)
    
    /// The user's current accent color preference.
    ///
    /// Users set the accent color in the General pane of system preferences.
    /// Do not make assumptions about the color space associated with this color.
    @available(macOS 10.14, *)
    static let controlAccentColor: Color = .init(platformColor: .controlAccentColor)
    
    /// The color to use for the background of large controls, such as scroll views or table views.
    ///
    /// With Desktop Tinting, the system modifies this color dynamically by incorporating some of the color from the underlying desktop image.
    /// The system does not apply this dynamic tinting effect to other types of views.
    static let controlBackground: Color = .init(platformColor: .controlBackgroundColor)
    
    /// The color to use for text on enabled controls.
    ///
    /// The color used for text on enabled controls.
    static let controlText: Color = .init(platformColor: .controlTextColor)
    
    /// The color to use for text on disabled controls.
    ///
    /// The color used for text on disabled controls.
    static let disabledControlText: Color = .init(platformColor: .disabledControlTextColor)
    
    /// The color to use for the face of a selected control—that is, a control that has been clicked or is being dragged.
    static let selectedControl: Color = .init(platformColor: .selectedControlColor)
    
    /// The color to use for text in a selected control—that is, a control being clicked or dragged.
    static let selectedControlText: Color = .init(platformColor: .selectedControlTextColor)
    
    /// The colors to use for alternating content, typically found in table views and collection views.
    static let alternateSelectedControlText: Color = .init(platformColor: .alternateSelectedControlTextColor)
    
    /// The patterned color to use for the background of a scrubber control.
    @available(macOS 10.12.2, *)
    static let scrubberTexturedBackground: Color = .init(platformColor: .scrubberTexturedBackground)
    
    
    /* Window Colors */
    
    /// The color to use for the window background.
    ///
    /// The window background color.
    /// With Desktop Tinting, the system modifies this color dynamically by incorporating some of the color from the underlying desktop image.
    /// The system does not apply this dynamic tinting effect to other types of views.
    static let windowBackground: Color = .init(platformColor: .windowBackgroundColor)
    
    /// The color to use for text in a window's frame.
    ///
    /// The color used for text in window frames.
    static let windowFrameText: Color = .init(platformColor: .windowFrameTextColor)
    
    /// The color to use in the area beneath your window's views.
    ///
    /// Use this color to fill the backdrop underneath your app's main content.
    ///
    /// With Desktop Tinting, the system modifies this color dynamically by incorporating some of the color from the underlying desktop image.
    /// The system does not apply this dynamic tinting effect to other types of views.
    static let underPageBackground: Color = .init(platformColor: .underPageBackgroundColor)
    
    
    /* Highlights and Shadows */
    
    /// The highlight color to use for the bubble that shows inline search result values.
    @available(macOS 10.13, *)
    static let findHighlight: Color = .init(platformColor: .findHighlightColor)
    
    /// The color to use as a virtual light source on the screen.
    ///
    /// The system color for the virtual light source on the screen.
    static let highlight: Color = .init(platformColor: .highlightColor)
    
    /// The color to use for virtual shadows cast by raised objects on the screen.
    ///
    /// The system color for the virtual shadows case by raised objects on the screen.
    static let shadow: Color = .init(platformColor: .shadowColor)
    
}
#endif
