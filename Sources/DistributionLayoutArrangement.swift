// The MIT License (MIT)
//
// Copyright (c) 2018 Alexander Grebenyuk (github.com/kean).

import UIKit

/** Manages distribution: constraints along the axis.
 */
class DistributionLayoutArrangement: LayoutArrangement {
    var type: StackViewDistribution = .fill
    var spacing: CGFloat = 0
    var isBaselineRelative = false
    var spacer: LayoutSpacer
    private var gaps = [GapLayoutGuide]()

    override init(canvas: StackView) {
        spacer = LayoutSpacer()
        spacer.accessibilityIdentifier = "ASV-alignment-spanner"

        super.init(canvas: canvas)
    }
    
    override func updateConstraints() {
        super.updateConstraints()

        spacer.removeFromSuperview()
        
        gaps.forEach { $0.removeFromSuperview() }
        gaps.removeAll()
        
        if items.count > 0 {
            updateCanvasConnectingConstraints()
            updateSpacingConstraints()
            updateDistributionConstraints()
        }
        if hiddenItems.count > 0 {
            updateHiddenItemsConstraints()
        }
        if items.count > 0 && (type == .equalSpacing || type == .equalCentering) { // If spacings are weak
            addCanvasFitConstraint(attribute: width)
        }
    }

    private func updateCanvasConnectingConstraints() {
        if visibleItems.count == 0 {
            canvas.addSubview(spacer)
            connectToCanvas(spacer, attribute: leading)
            connectToCanvas(spacer, attribute: trailing)
        } else {
            connectToCanvas(visibleItems.first!, attribute: leading)
            connectToCanvas(visibleItems.last!, attribute: trailing)
        }
    }
    
    private func updateSpacingConstraints() {
        switch type {
        case .fill, .fillEqually, .fillProportionally:
            addSpacings()
        case .equalSpacing, .equalCentering:
            addSpacings(.greaterThanOrEqual)
            updateGapLayoutGuides()
        }
    }

    private func updateGapLayoutGuides() {
        visibleItems.forPair { previous, current in
            let gap = GapLayoutGuide()
            canvas.addSubview(gap)
            gaps.append(gap)

            let toAttr: NSLayoutConstraint.Attribute = isBaselineRelative ? .firstBaseline : leading
            let fromAttr: NSLayoutConstraint.Attribute = isBaselineRelative ? .lastBaseline : trailing
            
            connectItem(gap, attribute: toAttr, item: previous, attribute: (type == .equalCentering ? center : fromAttr))
            connectItem(gap, attribute: fromAttr, item: current, attribute: (type == .equalCentering ? center : toAttr))
        }
        matchItemsSize(gaps, priority: type == .equalCentering ? UILayoutPriority(rawValue:149) : nil)
    }

    private func updateDistributionConstraints() {
        switch type {
        case .fillProportionally:
            fillItemsProportionally()
        case .fillEqually:
            matchItemsSize(visibleItems)
        default: break
        }
    }
        
    private func fillItemsProportionally() {
        func sizeFor(_ item: UIView) -> CGFloat {
            let intrinsic = item.intrinsicContentSize
            return axis == .horizontal ? intrinsic.width : intrinsic.height
        }
        let itemsWithIntrinsic: [UIView] = visibleItems.filter {
            let size = sizeFor($0)
            return size != UIView.noIntrinsicMetric && size > 0
        }
        guard itemsWithIntrinsic.count > 0 else {
            matchItemsSize(visibleItems)
            return
        }
        let totalSpacing = spacing * CGFloat(visibleItems.count - 1)
        let totalSize = itemsWithIntrinsic.reduce(totalSpacing) { total, item in
            return total + sizeFor(item)
        }
        var priority: UILayoutPriority? = (itemsWithIntrinsic.count == 1 && (visibleItems.count == 1 || spacing == 0.0)) ? nil : UILayoutPriority(rawValue: 999)
        visibleItems.forEach {
            let size = sizeFor($0)
            if size != UIView.noIntrinsicMetric && size > 0 {
                constraint(item: $0, attribute: width, toItem: canvas, relation: .equal, multiplier: (size / totalSize), priority: priority, identifier: "ASV-fill-proportionally")
            } else {
                constraint(item: $0, attribute: width, constant: 0, identifier: "ASV-fill-proportionally")
            }
            if let unwrappedPriority = priority {
                priority = UILayoutPriority(rawValue: unwrappedPriority.rawValue - 1)
            }
        }
    }
    
    private func updateHiddenItemsConstraints() {
        hiddenItems.forEach {
            constraint(item: $0, attribute: width, constant: 0, identifier: "ASV-hiding")
        }
    }

    // MARK: Managed Attributes

    private var width: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .width : .height
    }

    private var leading: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .leading : .top
    }

    private var trailing: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .trailing : .bottom
    }

    private var center: NSLayoutConstraint.Attribute {
        return axis == .horizontal ? .centerX : .centerY
    }

    
    // MARK: Helpers
    
    private func addSpacings(_ relation: NSLayoutConstraint.Relation = .equal) {
        func spacingFor(previous: UIView, current: UIView) -> CGFloat {
            if current === visibleItems.first || previous === visibleItems.last {
                return 0.0
            } else {
                return spacing - (spacing / 2.0) * CGFloat([previous, current].filter{ isHidden($0) }.count)
            }
        }
        items.forPair { previous, current in
            let spacing = spacingFor(previous: previous, current: current)
            let toAttr: NSLayoutConstraint.Attribute = isBaselineRelative ? .firstBaseline : leading
            let fromAttr: NSLayoutConstraint.Attribute = isBaselineRelative ? .lastBaseline : trailing
            constraint(item: current, attribute: toAttr, toItem: previous, attribute: fromAttr, relation: relation, constant: spacing, identifier: "ASV-spacing")
        }
    }
    
    private func connectItem(_ item1: UIView, attribute attr1: NSLayoutConstraint.Attribute, item item2: UIView, attribute attr2: NSLayoutConstraint.Attribute) {
        constraint(item: item1, attribute: attr1, toItem: item2, attribute: attr2, identifier: "ASV-distributing-edge")
    }
    
    private func matchItemsSize(_ items: [UIView], priority: UILayoutPriority? = nil) {
        guard items.count > 0 else { return }
        let firstItem = items.first!
        items.dropFirst().forEach {
            constraint(item: $0, attribute: width, toItem: firstItem, priority: priority, identifier: "ASV-fill-equally")
        }
    }
}
