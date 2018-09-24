// The MIT License (MIT)
//
// Copyright (c) 2018 Alexander Grebenyuk (github.com/kean).

import UIKit


class LayoutGuide: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Make sure that layout guides don't interfere with touches
        self.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override class var layerClass: Swift.AnyClass {
        return CATransformLayer.self
    }
    
    override var backgroundColor: UIColor? {
        get { return nil }
        set { return }
    }
}

class GapLayoutGuide: LayoutGuide {}

class LayoutSpacer: LayoutGuide {}


extension Sequence {
    // FIXME: Name might be misleading, it doesn't enumerate over all combinations
    func forPair(_ closure: (_ first: Self.Iterator.Element, _ second: Self.Iterator.Element) -> Void) {
        let _ = reduce(nil as Self.Iterator.Element?) { previous, current in
            if let previous = previous {
                closure(previous, current)
            }
            return current
        }
    }
}


extension NSLayoutConstraint.Attribute {
    var toMargin: NSLayoutConstraint.Attribute {
        switch self {
        case .left: return .leftMargin
        case .right: return .rightMargin
        case .top: return .topMargin
        case .bottom: return .bottomMargin
        case .leading: return .leadingMargin
        case .trailing: return .trailingMargin
        case .centerX: return .centerXWithinMargins
        case .centerY: return .centerYWithinMargins
        default: return self
        }
    }
}
