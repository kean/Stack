//
//  Picker.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit
import ObjectiveC

// MARK: Picker

extension UIViewController {
    func showPicker(_ title: String?, items: [String], selected: Int?, handler: @escaping (_ index: Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for (index, item) in items.enumerated() {
            let checkmark = index == selected ? " ✓" : ""
            alert.addAction(UIAlertAction(title: "\(item)\(checkmark)", style: .default) { _ in
                handler(index)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: Value Pickers

private struct AssociatedKeys {
    static var Controller = "Arranged.Controller"
}

class ValuePicker<Value> {
    weak var presenter: UIViewController!
    var value: Value {
        didSet {
            self.update()
            self.observer(value)
        }
    }
    let button = UIButton(type: .system)
    let observer: (_ value: Value) -> Void
    var view: UIView

    init(value: Value, presenter: UIViewController, observer: @escaping (_ value: Value) -> Void) {
        self.value = value
        self.presenter = presenter
        self.observer = observer
        self.view = button
        self.update()
        objc_setAssociatedObject(button, &AssociatedKeys.Controller, self, .OBJC_ASSOCIATION_RETAIN)
        button.addTarget(self, action: #selector(ValuePicker.buttonTapped(_:)), for: .touchUpInside)
    }

    func update() {
        fatalError("update() has not been implemented")
    }

    @objc func buttonTapped(_ sender: UIButton) {
        self.tapped()
    }

    func tapped() {

    }
}

class AxisPicker : ValuePicker<NSLayoutConstraint.Axis> {
    override init(value: NSLayoutConstraint.Axis, presenter: UIViewController, observer: @escaping (_ value: NSLayoutConstraint.Axis) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("axis:", value: (value == .vertical ? ".Vertical" : ".Horizontal"))
    }

    override func tapped() {
        value = value == .vertical ? .horizontal : .vertical
    }
}

class SpacingPicker : ValuePicker<CGFloat> {
    let values: [CGFloat] = [0.0, 10.0, 20.0, 40.0]
    let items = ["0.0", "10.0", "20.0", "40.0"]

    override init(value: CGFloat, presenter: UIViewController, observer: @escaping (_ value: CGFloat) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("spacing:", value: "\(values[values.index(of: value)!])")
    }

    override func tapped() {
        presenter.showPicker("Spacing", items: items, selected: values.index(of: self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class DistrubituonPicker : ValuePicker<UIStackView.Distribution> {
    let values: [UIStackView.Distribution] = [.fill, .fillEqually, .fillProportionally, .equalSpacing, .equalCentering]
    let items = [".Fill", ".FillEqually", ".FillProportionally", ".EqualSpacing", ".EqualCentering"]

    override init(value: UIStackView.Distribution, presenter: UIViewController, observer: @escaping (_ value: UIStackView.Distribution) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("distribution:", value: "\(items[values.index(of: value)!])")
    }

    override func tapped() {
        presenter.showPicker("Distribution", items: items, selected: values.index(of: self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class AlignmentPicker : ValuePicker<UIStackView.Alignment> {
    let values: [UIStackView.Alignment] = [.fill, .leading, .firstBaseline, .center, .trailing, .lastBaseline]
    let items = [".Fill", ".Leading", ".FirstBaseline", ".Center", ".Trailing", ".LastBaseline"]

    override init(value: UIStackView.Alignment, presenter: UIViewController, observer: @escaping (_ value: UIStackView.Alignment) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("alignment:", value: "\(items[values.index(of: value)!])")
    }

    override func tapped() {
        presenter.showPicker("Alignment", items: items, selected: values.index(of: self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class MarginsPicker : ValuePicker<UIEdgeInsets> {
    let values: [UIEdgeInsets] = [UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) , UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40), UIEdgeInsets.zero]
    let items = ["(8, 8, 8, 8)", "(10, 20, 30, 40)", "(0, 0, 0, 0)"]

    override init(value: UIEdgeInsets, presenter: UIViewController, observer: @escaping (_ value: UIEdgeInsets) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("margins:", value: "\(items[values.index(of: value)!])")
    }

    override func tapped() {
        presenter.showPicker("Margins", items: items, selected: values.index(of: self.value)) { index in
            self.value = self.values[index]
        }
    }
}

class BaselineRelativeArrangementPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: @escaping (_ value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("baselineRelative:", value: "\(value)")
    }

    override func tapped() {
        value = !value
    }
}

class LayoutMarginsRelativeArrangementPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: @escaping (_ value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("marginsRelative:", value: "\(value)")
    }

    override func tapped() {
        value = !value
    }
}

class AnimatedPicker : ValuePicker<Bool> {
    override init(value: Bool, presenter: UIViewController, observer: @escaping (_ value: Bool) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }
    
    override func update() {
        button.setTitle("animated:", value: "\(value)")
    }
    
    override func tapped() {
        value = !value
    }
}

class ContentTypePicker : ValuePicker<ContentType> {
    let values: [ContentType] = [.view, .label]
    let items = [".View", ".Label"]

    override init(value: ContentType, presenter: UIViewController, observer: @escaping (_ value: ContentType) -> Void) {
        super.init(value: value, presenter: presenter, observer: observer)
    }

    override func update() {
        button.setTitle("content type:", value: "\(items[values.index(of: value)!])")
    }

    override func tapped() {
        presenter.showPicker("Content Type", items: items, selected: values.index(of: self.value)) { index in
            self.value = self.values[index]
        }
    }
}

enum SizeType {
    case width, height
}

class SizePicker: ValuePicker<(Bool, CGFloat)> {
    let type: SizeType
    init(value: (Bool, CGFloat), type: SizeType, presenter: UIViewController, observer: @escaping (_ value: (Bool, CGFloat)) -> Void) {
        self.type = type
        super.init(value: value, presenter: presenter, observer: observer)
        
        let prefix = type == .width ? "H:" : "V:"
        button.setTitle("\(prefix) pin", for: UIControl.State())
        button.setTitle("\(prefix) unpin", for: .selected)
        
        let slider = UISlider()
        slider.autoSetDimension(.width, toSize: 100)
        slider.value = Float(value.1)
        slider.addTarget(self, action: #selector(SizePicker.sliderValueChanged(_:)), for: .valueChanged)
        
        let container = UIStackView(arrangedSubviews: [button, slider])
        container.spacing = 8
        view = container
    }
    
    override func update() {
        button.isSelected = value.0
    }
    
    override func tapped() {
        var value = self.value
        value.0 = !value.0
        self.value = value
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        var value = self.value
        value.1 = CGFloat(sender.value)
        self.value = value
    }
}

extension UIButton {
    func setTitle(_ title: String, value: String) {
        let string = NSMutableAttributedString()
        string.append(NSAttributedString(string: title + " ", attributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14) ]))
        string.append(NSAttributedString(string: value, attributes: [ NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14) ]))
        self.setAttributedTitle(string, for: UIControl.State())
    }
}
