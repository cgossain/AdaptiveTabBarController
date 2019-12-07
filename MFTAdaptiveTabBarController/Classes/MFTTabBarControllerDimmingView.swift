//
//  MFTTabBarControllerDimmingView.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import UIKit

private let MFTExpansionRadiusCompact = 135.0
private let MFTExpansionRadiusRegular = 200.0

protocol MFTTabBarControllerDimmingViewDelegate: NSObjectProtocol {
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidExpand(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewWillCollapse(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidCollapse(_ dimmingView: MFTTabBarControllerDimmingView)
}

open class MFTTabBarControllerDimmingView: UIView {
    public enum ActionsLayoutMode {
        case linear
        case grid
        case arc
    }
    
    /// The layout mode to use when expanding the tab bar actions.
    ///
    /// Tab bar actions will be layed out accoding to this mode, centered around the specified `actionsAnchorPoint`.
    open var actionsLayoutMode: ActionsLayoutMode = .grid
    
    /// The view around which the tab bar actions will be layed out.
    open var actionsAnchorView: UIView?
    
    
    // MARK: - Internal Properties
    weak var delegate: MFTTabBarControllerDimmingViewDelegate?
    
    private(set) var isCollapsed = true
    
    var maximumItemsPerRow = 3
    
    
    // MARK: - Private Properties
    fileprivate var actions = [MFTTabBarActionView]()
    
    
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 44, bottom: 0, trailing: 44)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MFTTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    
    // MARK: - Public
    open func addAction(_ action: MFTTabBarAction) {
        let actionView = MFTTabBarActionView(action: action)
        actionView.didTapHandler = { [unowned self] in
            self.collapse(animated: true)
        }
        actions.append(actionView)
    }
    
    open func collapse(animated: Bool) {
        willCollapse()
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                // move the items to their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
            }, completion: { (finished) in
                // fade out the dimming view
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                    self.alpha = 0.0
                    
                }, completion: { (finished) in
                    self.didCollapse()
                })
            })
        }
        else {
            // non animated
        }
    }
    
    open func expand(animated: Bool) {
        willExpand()
        if animated {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: { (finished) in
                // make sure the items begin at their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
                // spring them into their expanded positions
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 1.0, options: [], animations: {
                    // move the items to their expanded positions
                    self.moveActionViewsToExpandedPositions()
                    
                }, completion: { (finished) in
                    self.didExpand()
                })
            })
        }
        else {
            // non animated
        }
    }
    
    
    // MARK: - Internal
    func moveActionViewsToExpandedPositions() {
        for (idx, action) in self.actions.enumerated() {
            addSubview(action)
            action.center = expandedCenterPointForAction(action, at: idx)
            action.alpha = 1.0
        }
    }
    
    func moveActionViewsToCollapsedPositions() {
        for (idx, action) in self.actions.enumerated() {
            action.center = collapsedCenterPointForAction(action, at: idx)
            action.alpha = 0.0
        }
    }
    
    
    // MARK: - Actions
    @objc private func backgroundTappedGesture(_ sender: UITapGestureRecognizer) {
        collapse(animated: true)
    }
    
    
    // MARK: - Private
    private func willExpand() {
        isCollapsed = false
        delegate?.dimmingViewWillExpand(self)
    }
    
    private func didExpand() {
        delegate?.dimmingViewDidExpand(self)
    }
    
    private func willCollapse() {
        delegate?.dimmingViewWillCollapse(self)
    }
    
    private func didCollapse() {
        isCollapsed = true
        delegate?.dimmingViewDidCollapse(self)
    }
    
    private func collapsedCenterPointForAction(_ action: MFTTabBarActionView, at idx: Int) -> CGPoint {
        guard let actionsAnchorView = actionsAnchorView, let superview = actionsAnchorView.superview else {
            return .zero
        }
        return convert(actionsAnchorView.center, from: superview)
    }
    
    private func expandedCenterPointForAction(_ action: MFTTabBarActionView, at idx: Int) -> CGPoint {
        guard let actionsAnchorView = actionsAnchorView, let superview = actionsAnchorView.superview else {
            return .zero
        }
        
        let actionsAnchorPoint = convert(actionsAnchorView.center, from: superview)
        
        switch actionsLayoutMode {
        case .linear:
            let incrementSpacing = 100.0
            let incrementIdx = Double(idx)
            
            // convert the position from cylindrical to cartesian coordinates
            let x = 0
            let y = incrementSpacing * (incrementIdx + 1.0)
            
            return CGPoint(x: actionsAnchorPoint.x + CGFloat(x), y: actionsAnchorPoint.y - CGFloat(y))
        case .arc:
            let total = stride(from: 0, to: actions.count, by: 1)
            let median = Double(total.sorted(by: <)[actions.count / 2])
            let range = angleRangeForArcLayout()
            let start = startAngleForArcLayout()
            let incrementAngle = range / Double(actions.count - 1)
            let incrementIdx = Double(idx)
            var expandedAngleInDegrees = start - (incrementAngle*incrementIdx)

            var angleOffset = 0.0
            if Int(median).isEven {
                if (incrementIdx > 0 && incrementIdx < median) {
                    angleOffset -= 2.6 // larger number move item towards the center
                }
                else if (incrementIdx < Double(actions.count) && incrementIdx > median) {
                    angleOffset += 2.6 // larger number move item towards the center
                }
            }

            expandedAngleInDegrees += angleOffset
            let expandedAngleInRadians = expandedAngleInDegrees * (Double.pi / 180.0)

            // lay out the action views equally spaced along an eliptical path
            let x = (1.0 * expansionRadiusForArcLayout()) * cos(expandedAngleInRadians)
            let y = (0.8 * expansionRadiusForArcLayout()) * sin(expandedAngleInRadians) + 28 // displace arc upwards

            return CGPoint(x: actionsAnchorPoint.x + CGFloat(x), y: actionsAnchorPoint.y - CGFloat(y))
            
        default: // grid
            let numberOfRows = Int(ceil(Double(actions.count) / Double(maximumItemsPerRow)))
            var rowIdx = Int(floor(Double(idx) / Double(maximumItemsPerRow)))
            var numberOfItemsInRow = rowIdx < (numberOfRows - 1) ? maximumItemsPerRow : (actions.count - (rowIdx * maximumItemsPerRow))
            var itemIdxInRow = idx - (rowIdx * maximumItemsPerRow)
            var totalHorizontalMargins = layoutMargins.left + layoutMargins.right + action.bounds.width
            var interitemSpacing = (self.bounds.width-totalHorizontalMargins)/CGFloat(maximumItemsPerRow - 1)
            var numberOfItemsToReachMaxItemsInRow = maximumItemsPerRow - numberOfItemsInRow
            var xOfFirstItem = (actionsAnchorPoint.x - self.bounds.width/2) + totalHorizontalMargins/2 + CGFloat(numberOfItemsToReachMaxItemsInRow)*(interitemSpacing/2)
            
            let rowHeight = action.bounds.height
            let rowTotalVerticalMargins = CGFloat(36)
            let totalRowHeight = rowHeight + rowTotalVerticalMargins
            
            var x = xOfFirstItem + CGFloat(itemIdxInRow) * interitemSpacing
            var y = totalRowHeight * CGFloat(numberOfRows - 1 - rowIdx) + totalRowHeight
            
            return CGPoint(x: x, y: actionsAnchorPoint.y - CGFloat(y))
        }
    }
    
    private func expansionRadiusForArcLayout() -> Double {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            return MFTExpansionRadiusCompact
        default:
            return MFTExpansionRadiusRegular
        }
    }
    
    private func angleRangeForArcLayout() -> Double {
        let angle = 180 - startAngleForArcLayout()
        return 180 - (2*angle) // produces a range that is centered relative to the start angle
    }

    private func startAngleForArcLayout() -> Double {
        return 160
    }
}

private extension Int {
    var isEven: Bool {
        return self % 2 == 0
    }
}
