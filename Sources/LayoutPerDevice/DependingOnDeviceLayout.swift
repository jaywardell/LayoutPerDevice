//
//  SizeClassDependent.swift
//  RotatingViewTest
//
//  Created by Joseph Wardell on 11/28/20.
//

import SwiftUI

public struct Layout {
    
    public enum Orientation: Hashable {

        case iPhone
        case iPhoneLandscape
        case iPhonePortrait

        case largeiPhoneLandscape

        case iPhoneLandscapeWithHomeButton
        case iPhonePortraitWithHomeButton
        case largeiPhoneLandscapeWithHomeButton

        case iPhoneLandscapeWithoutHomeButton
        case iPhonePortraitWithoutHomeButton
        case largeiPhoneLandscapeWithoutHomeButton

        case iPad
        case iPadLandscape
        case iPadPortrait

        case iPadWithHomeButton
        case iPadLandscapeWithHomeButton
        case iPadPortraitWithHomeButton

        case iPadWithoutHomeButton
        case iPadLandscapeWithoutHomeButton
        case iPadPortraitWithoutHomeButton

        case mac
        case tv
        case watch
        case any
    }

    let orientation: Orientation
    let view: AnyView
    
    public init<V: View>(_ orientation: Orientation, _ view: V) {
        self.orientation = orientation
        self.view = AnyView(view)
    }
}

public struct DependingOnDeviceLayout {

    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    #endif

    
    let orientations: [Layout.Orientation: AnyView]
      
    public init(_ layouts: Layout...) {
        var orientations = [Layout.Orientation: AnyView]()
        for layout in layouts {
            orientations[layout.orientation] = layout.view
        }
        self.orientations = orientations
    }
    
    var iPadPortraitIgnoringHomeButton: some View {
        orientations[.iPadPortrait] ??
            orientations[.iPad] ??
            orientations[.any] ??
            AnyView(iPadPortraitPlaceholder)
    }

    @ViewBuilder var iPadPortraitWithHomeButton: some View {
            if let withHomeButton = orientations[.iPadPortraitWithHomeButton] {
                withHomeButton
            }
            else if let withHomeButton = orientations[.iPadWithHomeButton] {
                withHomeButton
            }
            else {
                iPadPortraitIgnoringHomeButton
            }
    }
    
    @ViewBuilder var iPadPortraitWithoutHomeButton: some View {
            if let withHomeButton = orientations[.iPadPortraitWithHomeButton] {
                withHomeButton
            }
            else if let withHomeButton = orientations[.iPadWithHomeButton] {
                withHomeButton
            }
            else {
                iPadPortraitIgnoringHomeButton
            }
    }

    var iPadLandscapeIgnoringHomeButton: some View {
        orientations[.iPadLandscape] ??
            orientations[.iPad] ??
            orientations[.any] ??
            AnyView(iPadLandscapePlaceholder)
    }

    @ViewBuilder var iPadLandscapeWithHomeButton: some View {
            if let withHomeButton = orientations[.iPadLandscapeWithHomeButton] {
                withHomeButton
            }
            else if let withHomeButton = orientations[.iPadWithHomeButton] {
                withHomeButton
            }
            else {
                iPadLandscapeIgnoringHomeButton
            }
    }
    
    @ViewBuilder var iPadLandscapeWithoutHomeButton: some View {
            if let withHomeButton = orientations[.iPadLandscapeWithHomeButton] {
                withHomeButton
            }
            else if let withHomeButton = orientations[.iPadWithHomeButton] {
                withHomeButton
            }
            else {
                iPadLandscapeIgnoringHomeButton
            }
    }

    var iPad: some View {
        GeometryReader { geometry in
            ZStack {
                if geometry.size.width < geometry.size.height {
                    if HomeButtonDiscoverer.AssumingTrue.deviceHasPhysicalHomeButton {
                        iPadPortraitWithHomeButton
                    }
                    else {
                        iPadPortraitWithoutHomeButton
                    }
                }
                else {
                    if HomeButtonDiscoverer.AssumingTrue.deviceHasPhysicalHomeButton {
                        iPadLandscapeWithHomeButton
                    }
                    else {
                        iPadLandscapeWithoutHomeButton
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var iPhoneLandscape: some View {
        // check for homebutton-spcific layouts first
        if HomeButtonDiscoverer.AssumingTrue.deviceHasPhysicalHomeButton {
            if let withHomeButton = orientations[.iPhoneLandscapeWithHomeButton] {
                return withHomeButton
            }
        }
        else if let withoutHomeButton = orientations[.iPhoneLandscapeWithoutHomeButton] {
            return withoutHomeButton
        }
    
        // otherwise, travel down the path from more to less specific
        return orientations[.iPhoneLandscape] ??
            orientations[.iPhone] ??
            orientations[.any] ??
            AnyView(iPhoneLandscapePlaceholder)
    }
    
    var largeiPhoneLandscape: some View {
        // check for homebutton-spcific layouts first
        if HomeButtonDiscoverer.AssumingTrue.deviceHasPhysicalHomeButton {
            if let withHomeButton = orientations[.largeiPhoneLandscapeWithHomeButton] {
                return withHomeButton
            }
            // check to see if we have a general "with home button" layout
            else if let withHomeButton = orientations[.iPhoneLandscapeWithHomeButton] {
                return withHomeButton
            }
        }
        else if let withoutHomeButton = orientations[.largeiPhoneLandscapeWithoutHomeButton] {
            return withoutHomeButton
        }
        // check to see if we have a general "without home button" layout
        else if let withoutHomeButton = orientations[.iPhoneLandscapeWithoutHomeButton] {
            return withoutHomeButton
        }

        // otherwise, travel down the path from more to less specific
       return orientations[.largeiPhoneLandscape] ??
            orientations[.iPhoneLandscape] ??
            orientations[.iPhone] ??
            orientations[.any] ??
            AnyView(largeiPhoneLandscapePlaceholder)
    }
    
    var iPhonePortrait: some View {
        // check for homebutton-spcific layouts first
        if HomeButtonDiscoverer.AssumingTrue.deviceHasPhysicalHomeButton {
            if let withHomeButton = orientations[.iPhonePortraitWithHomeButton] {
                return withHomeButton
            }
        }
        else if let withoutHomeButton = orientations[.iPhonePortraitWithoutHomeButton] {
            return withoutHomeButton
        }

        // otherwise, travel down the path from more to less specific
        return orientations[.iPhonePortrait] ??
            orientations[.iPhone] ??
            orientations[.any] ??
            AnyView(iPhonePortraitPlaceholder)
    }
}

// MARK:- DependingOnDeviceLayout: View
extension DependingOnDeviceLayout: View {

    public var body: some View {
        // see https://medium.com/if-let-swift-programming/size-classes-ipad-portrait-landscape-55f59173c65a
        Group {
            #if os(iOS)
            switch (horizontalSizeClass, verticalSizeClass) {
            
            case (.compact, .compact):
                iPhoneLandscape
                
            case (.regular, .compact):
                largeiPhoneLandscape
                
            case (.compact, .regular):
                iPhonePortrait
                
            case (.regular, .regular):
                iPad
                
            default:
                orientations[.any] ??
                AnyView(unknownPlaceholder)
            }
            
            #elseif os(tvOS)
            
            orientations[.tvPlaceholder] ??
            orientations[.any] ??
            AnyView(tvPlaceholder)
            
            #elseif os(watchOS)
            
            orientations[.watchPlaceholder] ??
            orientations[.any] ??
            AnyView(watchPlaceholder)

            
            #elseif os(macOS)
            
            orientations[.mac] ??
            orientations[.any] ??
            AnyView(macPlaceholder)
            
            #endif
        }
    }
}

// MARK:- DependingOnDeviceLayout: Placeholders
extension DependingOnDeviceLayout {

    var iPhoneLandscapePlaceholder: some View {
        Text(".iPhoneLandscape")
    }

    var largeiPhoneLandscapePlaceholder: some View {
        Text(".largeiPhoneLandscape")
    }

    var iPhonePortraitPlaceholder: some View {
        Text(".iPhonePortrait")
    }

    var iPadLandscapePlaceholder: some View {
        Text(".iPadLandscape")
    }

    var iPadPortraitPlaceholder: some View {
        Text(".iPadPortrait")
    }

    var macPlaceholder: some View {
        Text(".mac")
            .padding()
            .frame(minWidth: 144, minHeight: 89)
    }

    var tvPlaceholder: some View {
        Text(".tv")
            .padding()
            .frame(minWidth: 144, minHeight: 89)
    }

    var watchPlaceholder: some View {
        Text(".watch")
            .padding()
            .frame(minWidth: 144, minHeight: 89)
    }
    
    var unknownPlaceholder: some View {
        Text("Unknwon")
    }

}
