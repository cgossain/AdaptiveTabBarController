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
    
    var maximumItemsPerRow = 2
    
    
    // MARK: - Private Properties
    private var allActionViews: [MFTTabBarActionView] = []
    private var showableActionViews: [MFTTabBarActionView] { return allActionViews.filter({ $0.canShow }) }
    
    
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
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MFTTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    
    // MARK: - Internal
    func addTabBarAction(_ action: MFTTabBarAction, condition: MFTAdaptiveTabBarController.ConditionHandler? = nil) {
        let actionView = MFTTabBarActionView(action: action, condition: condition)
        actionView.didTapHandler = { [unowned self] in
            self.collapse(animated: true)
        }
        allActionViews.append(actionView)
    }
    
    func collapse(animated: Bool) {
        willCollapse()
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
                // move the items to their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
            }, completion: { (finished) in
                // fade out the dimming view
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.alpha = 0.0
                    
                }, completion: { (finished) in
                    self.didCollapse()
                })
            })
        }
    }
    
    func expand(animated: Bool) {
        willExpand()
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: {
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
    }
    
    func moveActionViewsToExpandedPositions() {
        for (idx, actionView) in showableActionViews.enumerated() {
            addSubview(actionView)
            actionView.sizeToFit()
            actionView.center = expandedCenterPointFor(actionView, at: idx)
            actionView.alpha = 1.0
        }
    }
    
    func moveActionViewsToCollapsedPositions() {
        for (idx, actionView) in allActionViews.enumerated() {
            actionView.sizeToFit()
            actionView.center = collapsedCenterPointFor(actionView, at: idx)
            actionView.alpha = 0.0
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
        allActionViews.forEach {
            $0.removeFromSuperview()
        }
        isCollapsed = true
        delegate?.dimmingViewDidCollapse(self)
    }
    
    private func collapsedCenterPointFor(_ action: MFTTabBarActionView, at idx: Int) -> CGPoint {
        guard let actionsAnchorView = actionsAnchorView, let superview = actionsAnchorView.superview else {
            return .zero
        }
        return convert(actionsAnchorView.center, from: superview)
    }
    
    private func expandedCenterPointFor(_ action: MFTTabBarActionView, at idx: Int) -> CGPoint {
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
            
        case .grid:
            let fittingSize = action.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            let numberOfRows = Int(ceil(Double(showableActionViews.count) / Double(maximumItemsPerRow)))
            var rowIdx = Int(floor(Double(idx) / Double(maximumItemsPerRow)))
//            var numberOfItemsInRow = rowIdx < (numberOfRows - 1) ? maximumItemsPerRow : (showableActionViews.count - (rowIdx * maximumItemsPerRow))
            var itemIdxInRow = idx - (rowIdx * maximumItemsPerRow)
            var interitemSpacing = CGFloat(44)
            
            let columnWidth = fittingSize.width
            let totalColumnWidth = columnWidth + interitemSpacing
            
            let rowHeight = fittingSize.height
            let totalRowHeight = rowHeight + interitemSpacing
            
            var x = actionsAnchorPoint.x - CGFloat(itemIdxInRow) * totalColumnWidth
            var y = totalRowHeight * CGFloat(numberOfRows - 1 - rowIdx) + totalRowHeight
            
            return CGPoint(x: x, y: actionsAnchorPoint.y - CGFloat(y))
            
        case .arc:
            let total = stride(from: 0, to: showableActionViews.count, by: 1)
            let median = Double(total.sorted(by: <)[showableActionViews.count / 2])
            let range = angleRangeForArcLayout()
            let start = startAngleForArcLayout()
            let incrementAngle = range / Double(showableActionViews.count - 1)
            let incrementIdx = Double(idx)
            var expandedAngleInDegrees = start - (incrementAngle*incrementIdx)
            
            var angleOffset = 0.0
            if Int(median).isEven {
                if (incrementIdx > 0 && incrementIdx < median) {
                    angleOffset -= 2.6 // larger number move item towards the center
                }
                else if (incrementIdx < Double(showableActionViews.count) && incrementIdx > median) {
                    angleOffset += 2.6 // larger number move item towards the center
                }
            }
            
            expandedAngleInDegrees += angleOffset
            let expandedAngleInRadians = expandedAngleInDegrees * (Double.pi / 180.0)
            
            // lay out the action views equally spaced along an eliptical path
            let x = (1.0 * expansionRadiusForArcLayout()) * cos(expandedAngleInRadians)
            let y = (0.8 * expansionRadiusForArcLayout()) * sin(expandedAngleInRadians) + 24 // displace arc upwards
            
            return CGPoint(x: actionsAnchorPoint.x + CGFloat(x), y: actionsAnchorPoint.y - CGFloat(y))
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
