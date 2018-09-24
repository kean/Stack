// The MIT License (MIT)
//
// Copyright (c) 2018 Alexander Grebenyuk (github.com/kean).

import UIKit

/** Manages alignment: constraints perpendicular to the axis.
 */
class AlignedLayoutArrangement: LayoutArrangement {
    var type: StackViewAlignment = .fill
    private var spacer: LayoutSpacer
    
    override init(canvas: StackView) {
        spacer = LayoutSpacer()
        spacer.accessibilityIdentifier = "ASV-alignment-spanner"
        
        super.init(canvas: canvas)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        spacer.removeFromSuperview()

        if items.count > 0 {
            updateCanvasConnectingConstraints()
            updateAlignmentConstraints()
        }
        if isAnyItemConnectionWeak {
            addItemsAmbiguitySuppressors(items)
        }
        if isAnyCanvasConnectionWeak {
            addCanvasFitConstraint(attribute: height)
        }
    }
    
    private func updateCanvasConnectingConstraints() {
        if shouldCreateSpacer {
            canvas.addSubview(spacer)
            if isAnyItemConnectionWeak {
                constraint(item: spacer, attribute: height, constant: 0, priority: UILayoutPriority(rawValue: 51), identifier: "ASV-spanning-fit")
            }
            connectItemsToSpacer(spacer, items: visibleItems, topWeak: isTopItemConnectionWeak, bottomWeak: isBottomItemConnectionWeak)
        }
        
        // FIXME: Make more readable
        let firstItem = visibleItems.count == 0 ? spacer : items.first!
        var topItem = firstItem
        var bottomItem = shouldCreateSpacer ? spacer : firstItem
        if typeIn([.center, .trailing, .lastBaseline]) {
            swap(&topItem, &bottomItem)
        }
        
        connectToCanvas(topItem, attribute: top, weak: isTopCanvasConnectionWeak)
        connectToCanvas(bottomItem, attribute: bottom, weak: isBottomCanvasConnectionWeak)
        
        if type == .center {
            connectToCanvas(firstItem, attribute: center)
        }
    }
    
    private var isAnyCanvasConnectionWeak: Bool {
        return isTopCanvasConnectionWeak || isBottomCanvasConnectionWeak
    }
    
    private var isTopCanvasConnectionWeak: Bool {
        if shouldCreateSpacer {
            return type == .firstBaseline && visibleItems.count > 0 && axis == .horizontal // .FirstBaseline specific
        }
        return isTopItemConnectionWeak
    }
    
    private var isBottomCanvasConnectionWeak: Bool {
        if shouldCreateSpacer {
            return type == .lastBaseline && visibleItems.count > 0 && axis == .horizontal // .LastBaseline specific
        }
        return isBottomItemConnectionWeak
    }
    
    private var shouldCreateSpacer: Bool {
        return visibleItems.count == 0 || (items.count > 1 && isAnyItemConnectionWeak)
    }
    
    private var isAnyItemConnectionWeak: Bool {
        return isTopItemConnectionWeak || isBottomItemConnectionWeak
    }
    
    private var isTopItemConnectionWeak: Bool {
        return typeIn([.trailing, .center, .firstBaseline, .lastBaseline])
    }
    
    private var isBottomItemConnectionWeak: Bool {
        return typeIn([.leading, .center, .firstBaseline, .lastBaseline])
    }
    
    private func updateAlignmentConstraints() {
        func attributes() -> [NSLayoutConstraint.Attribute] {
            switch type {
            case .fill: return [bottom, top]
            case .leading: return [top]
            case .trailing: return [bottom]
            case .center: return [center]
            case .firstBaseline: return axis == .horizontal ? [.firstBaseline] : []
            case .lastBaseline: return axis == .horizontal ? [.lastBaseline] : []
            }
        }
        attributes().forEach {
            alignItems(items, attribute: $0)
        }
    }

    // MARK: Managed Attributes

    private var height: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .height : .width
    }

    private var top: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .top : .leading
    }

    private var bottom: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .bottom : .trailing
    }

    private var center: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .centerY : .centerX
    }
    
    // MARK: Helpers
    
    private func alignItems(_ items: [UIView], attribute: NSLayoutConstraint.Attribute) {
        let firstItem = items.first!
        items.dropFirst().forEach {
            constraint(item: firstItem, attribute: attribute, toItem: $0, attribute: nil, identifier: "ASV-alignment")
        }
    }
    
    private func connectItemsToSpacer(_ spacer: LayoutSpacer, items: [UIView], topWeak: Bool, bottomWeak: Bool) {
        func connectToSpacer(_ item: UIView, attribute attr: NSLayoutConstraint.Attribute, weak: Bool) {
            let relation = connectionRelation(attr, weak: weak)
            let priority: UILayoutPriority? = weak ? nil : UILayoutPriority(rawValue: 999.5)
            constraint(item: spacer, attribute: attr, toItem: item, relation: relation, priority: priority, identifier: "ASV-spanning-boundary")
        }
        items.forEach {
            connectToSpacer($0, attribute: top, weak: topWeak)
            connectToSpacer($0, attribute: bottom, weak: bottomWeak)
        }
    }
    
    private func addItemsAmbiguitySuppressors(_ items: [UIView]) {
        items.forEach {
            constraint(item: $0, attribute: height, constant: 0, priority: UILayoutPriority(rawValue: 25), identifier: "ASV-ambiguity-suppression")
        }
    }
    
    private func typeIn(_ types: [StackViewAlignment]) -> Bool {
        return types.contains(type)
    }
}
