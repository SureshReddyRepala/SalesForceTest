//
//  UIFont+CustomFont.swift
//  MyMovies
//
//  Created by Suresh on 10/05/21.
//

import Foundation
import UIKit

extension UIFont {
    
    class func preferredItalicFont(forTextStyle style: UIFont.TextStyle) -> UIFont? {
        return UIFont.preferredFont(forTextStyle: style).italicisedVariant
    }
    
    var italicisedVariant: UIFont? {
        guard let italicDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { return nil }
        return UIFont(descriptor: italicDescriptor, size: pointSize)
    }
    
    class func preferredBoldFont(forTextStyle style: UIFont.TextStyle) -> UIFont? {
        return UIFont.preferredFont(forTextStyle: style).boldVariant
    }
    
    var boldVariant: UIFont? {
        guard let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else { return nil }
        return UIFont(descriptor: boldDescriptor, size: pointSize)
    }
}
