// The MIT License (MIT)
//
// Copyright (c) 2018 Alexander Grebenyuk (github.com/kean).

import UIKit

class LayoutArrangement {
    weak var canvas: UIView!
    var items = [UIView]() // Arranged views
    var hiddenItems = Set<UIView>()
    var visibleItems = Array<UIView>()
    
    var axis: NSLayoutConstraint.Axis = .horizontal
    var marginsEnabled: Bool = false

    private var constraints = [NSLayoutConstraint]()

    init(canvas: StackView) {
        self.canvas = canvas
    }

    func updateConstraints() {
        visibleItems = items.filter { !isHidden($0) }
        NSLayoutConstraint.deactivate(constraints.filter { $0.isActive })
        constraints.removeAll()
    }
    
    @discardableResult func constraint(item item1: UIView,
        attribute attr1: NSLayoutConstraint.Attribute,
        toItem item2: UIView? = nil,
        attribute attr2: NSLayoutConstraint.Attribute? = nil,
        relation: NSLayoutConstraint.Relation = .equal,
        multiplier: CGFloat = 1,
        constant c: CGFloat = 0,
        priority: UILayoutPriority? = nil,
        identifier: String) -> NSLayoutConstraint
    {
        let constraint = NSLayoutConstraint(item: item1, attribute: attr1, relatedBy: relation, toItem: item2, attribute: (attr2 != nil ? attr2! : attr1), multiplier: multiplier, constant: c)
        if let priority = priority {
            constraint.priority = priority
        }
        constraint.identifier = identifier
        constraint.isActive = true
        constraints.append(constraint)
        return constraint
    }
    
    // MARK: Helpers
    
    func isHidden(_ item: UIView) -> Bool {
        return hiddenItems.contains(item)
    }
    
    func addCanvasFitConstraint(attribute: NSLayoutConstraint.Attribute) {
        constraint(item: canvas, attribute: attribute, constant: 0, priority: UILayoutPriority(rawValue: 49.0), identifier: "ASV-canvas-fit")
    }
    
    func connectToCanvas(_ item: UIView, attribute attr: NSLayoutConstraint.Attribute, weak: Bool = false) {
        let relation = connectionRelation(attr, weak: weak)
        constraint(item: canvas, attribute: (marginsEnabled ? attr.toMargin : attr), toItem: item, attribute: attr, relation: relation, identifier: "ASV-canvas-connection")
    }
    
    func connectionRelation(_ attr: NSLayoutConstraint.Attribute, weak: Bool) -> NSLayoutConstraint.Relation {
        if !weak { return .equal }
        return (attr == .top || attr == .left || attr == .leading) ? .lessThanOrEqual : .greaterThanOrEqual
    }
}
