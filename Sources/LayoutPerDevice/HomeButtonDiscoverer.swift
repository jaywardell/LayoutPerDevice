//
//  HomeButtonDiscoverer.swift
//  Goldfish
//
//  Created by Joseph Wardell on 11/26/20.
//

#if canImport(UIKit)
import UIKit
#endif

final class HomeButtonDiscoverer {
    
    let defaultAssumption: Bool
    
    // MARK:-
    
    private init(_ assumption: Bool) {
        self.defaultAssumption = assumption
    }
    
    private static var mainDiscoverer: HomeButtonDiscoverer?
    private static func main(_ assumption: Bool) -> HomeButtonDiscoverer {
        if let existing = mainDiscoverer {
            // if this method is called more than once,
            // then it needs to have the same assumpotion
            assert(existing.defaultAssumption == assumption)
        }
        
        mainDiscoverer = HomeButtonDiscoverer(assumption)
        return mainDiscoverer!
    }
    
    // MARK:-
    
    static var AssumingFalse: HomeButtonDiscoverer {
        main(false)
    }

    static var AssumingTrue: HomeButtonDiscoverer {
        main(true)
    }

    // MARK:-
    
    var _deviceHasPhysicalHomeButton: Bool?
    var deviceHasPhysicalHomeButton: Bool {
        #if os(iOS)
        
        if let known = _deviceHasPhysicalHomeButton {
            return known
        }

        // it really is possible that this could be called before there's beeen a keyWindow established
        // so we need to have a backup assumption that client code can expect
        guard let keyWindow = UIApplication.shared.keyWindow else { return defaultAssumption }
        
        _deviceHasPhysicalHomeButton = (keyWindow.safeAreaInsets.bottom == 0)
        return _deviceHasPhysicalHomeButton!
        #else
        return false
        #endif
    }
}
