//
//  BaseStackViewController.swift
//  Example
//
//  Created by Alexander Grebenyuk on 02/03/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import UIKit
import Arranged

let loggingEnabled = true
let logAffectingViewsConstraints = false


// MARK: BaseStackViewController

enum ContentType {
    case view
    case label
}

class BaseStackViewController<T>: UIViewController where T: UIView, T: StackViewAdapter {
    var stackView: T!
    var views = [UIView]()
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!

    // Options
    var animated = true
    var contentType: ContentType = .view {
        didSet {
            if oldValue != contentType {
                refreshContent()
            }
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createStackView() -> T {
        fatalError("abstract method")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Creat stack view

        stackView = createStackView()

        refreshContent()

        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.addSubview(stackView)
        stackView.autoPin(toTopLayoutGuideOf: self, withInset: 16)
        stackView.autoPinEdge(toSuperviewMargin: .leading)
        stackView.autoPinEdge(toSuperviewMargin: .trailing, relation: .greaterThanOrEqual)
        widthConstraint = stackView.autoSetDimension(.width, toSize: 100)
        widthConstraint.isActive = false
        heightConstraint = stackView.autoSetDimension(.height, toSize: 100)
        heightConstraint.isActive = false
        
        // Disambiguate stack view size
        stackView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0).then {
            $0.priority = UILayoutPriority(rawValue: 100)
        })
        stackView.addConstraint(NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0).then {
            $0.priority = UILayoutPriority(rawValue: 100)
        })
        
        // Create background for stack view

        let background = UIView()
        background.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        view.insertSubview(background, belowSubview: stackView)
        background.autoMatch(.width, to: .width, of: stackView)
        background.autoMatch(.height, to: .height, of: stackView)
        background.autoAlignAxis(.horizontal, toSameAxisOf: stackView)
        background.autoAlignAxis(.vertical, toSameAxisOf: stackView)


        // Create controls

        let controls = UIStackView()
        controls.spacing = 2
        controls.axis = .vertical
        controls.isLayoutMarginsRelativeArrangement = true
        controls.alignment = .leading

        controls.addArrangedSubview(AxisPicker(value: self.stackView.axis, presenter: self) { axis in
            self.perform {
                self.stackView.axis = axis
            }
        }.view)
        controls.addArrangedSubview(SpacingPicker(value: self.stackView.spacing, presenter: self) { value in
            self.perform {
                self.stackView.spacing = value
            }
        }.view)
        controls.addArrangedSubview(DistrubituonPicker(value: self.stackView.ar_distribution, presenter: self) { value in
            self.perform {
                self.stackView.ar_distribution = value
            }
        }.view)
        controls.addArrangedSubview(AlignmentPicker(value: self.stackView.ar_alignment, presenter: self) { value in
            self.perform {
                self.stackView.ar_alignment = value
            }
        }.view)
        controls.addArrangedSubview(MarginsPicker(value: self.stackView.layoutMargins, presenter: self) { value in
            self.perform {
                self.stackView.layoutMargins = value
            }
        }.view)
        controls.addArrangedSubview(BaselineRelativeArrangementPicker(value: self.stackView.isBaselineRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.isBaselineRelativeArrangement = value
            }
        }.view)
        controls.addArrangedSubview(LayoutMarginsRelativeArrangementPicker(value: self.stackView.isLayoutMarginsRelativeArrangement
            , presenter: self) { value in
            self.perform {
                self.stackView.isLayoutMarginsRelativeArrangement = value
            }
        }.view)

        let controls2 = UIStackView()
        controls2.spacing = 2
        controls2.axis = .vertical
        controls2.isLayoutMarginsRelativeArrangement = true
        controls2.alignment = .trailing
        controls2.addArrangedSubview(UIButton(type: .system).then {
            $0.setTitle("show all subviews", for: UIControl.State())
            $0.addTarget(self, action: #selector(BaseStackViewController.buttonShowAllTapped(_:)), for: .touchUpInside)
        })
        controls2.addArrangedSubview(AnimatedPicker(value: self.animated, presenter: self) {
            self.animated = $0
        }.view)
        controls2.addArrangedSubview(ContentTypePicker(value: self.contentType, presenter: self) {
            self.contentType = $0
        }.view)
        controls2.addArrangedSubview(SizePicker(value: (false, 0.5), type: .width, presenter: self) { active, ratio in
            self.widthConstraint.isActive = active
            let bound = self.view.bounds.size.width
            self.widthConstraint.constant = ratio * bound
        }.view)
        controls2.addArrangedSubview(SizePicker(value: (false, 0.5), type: .height, presenter: self) { active, ratio in
            self.heightConstraint.isActive = active
            let bound = self.view.bounds.size.width
            self.heightConstraint.constant = ratio * bound
        }.view)

        view.addSubview(controls)
        view.addSubview(controls2)
        controls.autoPin(toBottomLayoutGuideOf: self, withInset: 16)
        controls2.autoPinEdge(.top, to: .top, of: controls)
        controls.autoPinEdge(toSuperviewMargin: .leading)
        controls2.autoPinEdge(toSuperviewMargin: .trailing)
        controls.autoPinEdge(.top, to: .bottom, of: stackView, withOffset: 16, relation: .greaterThanOrEqual)
    }

    func refreshContent() {

        views.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        views.removeAll()

        switch self.contentType {
        case .view:
            views.append(ContentView().then {
                $0.contentSize = CGSize(width: 40, height: 40)
                $0.backgroundColor = UIColor.red
            })

            views.append(ContentView().then {
                $0.contentSize = CGSize(width: 20, height: 100)
                $0.backgroundColor = UIColor.blue
            })

            views.append(ContentView().then {
                $0.contentSize = CGSize(width: 80, height: 60)
                $0.backgroundColor = UIColor.green
            })

        case .label:
            views.append(UILabel().then {
                $0.text = "Sed ut perspiciatis unde omnis iste natus"
                $0.font = UIFont.systemFont(ofSize: 26)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.red
            })

            views.append(UILabel().then {
                $0.text = "Neque porro quisquam est, qui dolorem ipsum"
                $0.font = UIFont.systemFont(ofSize: 20)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.blue
            })

            views.append(UILabel().then {
                $0.text = "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt."
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.numberOfLines = 0
                $0.backgroundColor = UIColor.green
            })
        }

        for (index, view) in views.enumerated() {
            view.accessibilityIdentifier = "content-view-\(index + 1)"
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BaseStackViewController.viewTapped(_:))))
            stackView.addArrangedSubview(view)
        }
        
        if views.first is UILabel {
            // Disambiguate stack view size
            stackView.ar_distribution = .fillEqually
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if loggingEnabled {
            print("\n\n")
            print("===========================")
            print("constraints:")
            printConstraints(constraints(for: stackView))

            if logAffectingViewsConstraints {
                print("")
                print("horizontal")
                print("==========")
                print("\naffecting stack view:")
                printConstraints(stackView.constraintsAffectingLayout(for: .horizontal))
                for view in views {
                    print("\naffecting view \(view.accessibilityIdentifier):")
                    printConstraints(view.constraintsAffectingLayout(for: .horizontal))
                }
                print("")
                print("vertical")
                print("==========")
                print("\naffecting stack view:")
                printConstraints(stackView.constraintsAffectingLayout(for: .vertical))
                for view in views {
                    print("\naffecting view \(view.accessibilityIdentifier):")
                    printConstraints(view.constraintsAffectingLayout(for: .vertical))
                }
            }
        }
    }
    
    @objc func buttonShowAllTapped(_ sender: UIButton) {
        perform {
            self.stackView.subviews.forEach{
                if let stack = self.stackView as? Arranged.StackView {
                    stack.setArrangedView($0, hidden: false)
                } else {
                    $0.isHidden = false
                }
            }
        }
    }

    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
        perform {
            if let stack = self.stackView as? Arranged.StackView {
                stack.setArrangedView(sender.view!, hidden: true)
            } else {
                sender.view?.isHidden = true
            }
        }
    }
    
    func perform(_ closure: @escaping () -> Void) {
        if (animated) {
            UIView.animate(withDuration: 0.33, animations: {
                closure()
                // Arranged.StackView requires call to layoutIfNeeded
                if !(self.stackView is UIStackView) {
                    self.view.layoutIfNeeded()
                }
            }) 
        } else {
            closure()
        }
    }
    
    func printConstraints(_ constraints: [NSLayoutConstraint]) {
        constraints.forEach { print($0) }
    }
    
    func constraints(for item: UIView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: item.constraints)
        for subview in item.subviews {
            constraints.append(contentsOf: subview.constraints)
        }
        return constraints
    }
}


// MARK: ContentView

class ContentView: UIView {
    var contentSize = CGSize(width: 44, height: 44)

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize : CGSize {
        return contentSize
    }
}


// MARK: Then

protocol Then {}

extension Then where Self: Any {
    func then(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension Then where Self: AnyObject {
    func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}
