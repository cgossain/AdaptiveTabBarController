//
//  AdaptiveTabBarControllerDimmingView.swift
//
//  Copyright (c) 2024 Christian Gossain
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

fileprivate extension Int {
    var isEven: Bool {
        self % 2 == 0
    }
}

protocol AdaptiveTabBarControllerDimmingViewListener: AnyObject {
    func dimmingViewWillExpand(_ dimmingView: AdaptiveTabBarControllerDimmingView)
    func dimmingViewDidExpand(_ dimmingView: AdaptiveTabBarControllerDimmingView)
    func dimmingViewWillCollapse(_ dimmingView: AdaptiveTabBarControllerDimmingView)
    func dimmingViewDidCollapse(_ dimmingView: AdaptiveTabBarControllerDimmingView)
}

final class AdaptiveTabBarControllerDimmingView: UIView {
    
    enum ActionsLayoutMode {
        case linear
        case gridCentered(_ maximumItemsPerRow: Int)
        case gridTrailing(_ maximumItemsPerRow: Int)
        case arc
    }
    
    private struct ArcLayoutMetrics {
        static let expansionRadiusCompact = 135.0
        static let expansionRadiusRegular = 200.0
    }
    
    /// The listener.
    weak var listener: AdaptiveTabBarControllerDimmingViewListener?
    
    /// The layout mode to use when expanding the tab bar actions.
    ///
    /// Tab bar actions will be layed out accoding to this mode, centered around the specified `actionsAnchorPoint`.
    var actionsLayoutMode: ActionsLayoutMode = .linear
    
    /// The view around which the tab bar actions will be layed out.
    weak var actionsAnchorView: UIView?
    
    /// Indicates if the action buttons are in the collapsed state or not.
    private(set) var isCollapsed = true
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 36, bottom: 0, trailing: 36)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AdaptiveTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func addTabBarAction(_ action: TabBarAction, condition: AdaptiveTabBarController.ConditionHandler? = nil) {
        let actionButton = TabBarActionButton(action: action, condition: condition)
        actionButton.didTapHandler = { [weak self] in
            self?.collapse(animated: true)
        }
        actionButtons.append(actionButton)
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
        for (idx, actionView) in actionButtons.enumerated() {
            actionView.sizeToFit()
            actionView.center = collapsedCenterPointFor(actionView, at: idx)
            actionView.alpha = 0.0
        }
    }
    
    // MARK: - Helpers
    
    @objc
    private func backgroundTappedGesture(_ sender: UITapGestureRecognizer) {
        collapse(animated: true)
    }
    
    private func willExpand() {
        isCollapsed = false
        listener?.dimmingViewWillExpand(self)
    }
    
    private func didExpand() {
        listener?.dimmingViewDidExpand(self)
    }
    
    private func willCollapse() {
        listener?.dimmingViewWillCollapse(self)
    }
    
    private func didCollapse() {
        actionButtons.forEach {
            $0.removeFromSuperview()
        }
        isCollapsed = true
        listener?.dimmingViewDidCollapse(self)
    }
    
    private func collapsedCenterPointFor(_ action: TabBarActionButton, at idx: Int) -> CGPoint {
        guard let actionsAnchorView,
              let superview = actionsAnchorView.superview else {
            return .zero
        }
        return convert(actionsAnchorView.center, from: superview)
    }
    
    private func expandedCenterPointFor(_ action: TabBarActionButton, at idx: Int) -> CGPoint {
        guard let actionsAnchorView,
              let superview = actionsAnchorView.superview else {
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
            
        case .gridCentered(let maximumItemsPerRow):
            let fittingSize = action.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            let numberOfRows = Int(ceil(Double(showableActionViews.count) / Double(maximumItemsPerRow)))
            let rowIdx = Int(floor(Double(idx) / Double(maximumItemsPerRow)))
            let numberOfItemsInRow = rowIdx < (numberOfRows - 1) ? maximumItemsPerRow : (showableActionViews.count - (rowIdx * maximumItemsPerRow))
            let itemIdxInRow = idx - (rowIdx * maximumItemsPerRow)
            
            let totalHorizontalMargins = layoutMargins.left + layoutMargins.right + fittingSize.width
            let interitemSpacingHorizontal = (self.bounds.width-totalHorizontalMargins)/CGFloat(maximumItemsPerRow - 1)
            let numberOfItemsToReachMaxItemsInRow = maximumItemsPerRow - numberOfItemsInRow
            let xOriginOfFirstItemInRow = (actionsAnchorPoint.x - self.bounds.width/2) + totalHorizontalMargins/2 + CGFloat(numberOfItemsToReachMaxItemsInRow)*(interitemSpacingHorizontal/2)
            
            let interitemSpacingVertical = CGFloat(24)
            let rowHeight = fittingSize.height
            let totalRowHeight = rowHeight + interitemSpacingVertical
            
            let x = xOriginOfFirstItemInRow + CGFloat(itemIdxInRow) * interitemSpacingHorizontal
            let y = totalRowHeight * CGFloat(numberOfRows - 1 - rowIdx) + totalRowHeight
            
            return CGPoint(x: x, y: actionsAnchorPoint.y - CGFloat(y))
            
        case .gridTrailing(let maximumItemsPerRow):
            let fittingSize = action.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            
            let numberOfRows = Int(ceil(Double(showableActionViews.count) / Double(maximumItemsPerRow)))
            let rowIdx = Int(floor(Double(idx) / Double(maximumItemsPerRow)))
            let itemIdxInRow = idx - (rowIdx * maximumItemsPerRow)
            let interitemSpacing = CGFloat(44)
            
            let columnWidth = fittingSize.width
            let totalColumnWidth = columnWidth + interitemSpacing
            
            let rowHeight = fittingSize.height
            let totalRowHeight = rowHeight + interitemSpacing
            
            let x = actionsAnchorPoint.x - CGFloat(itemIdxInRow) * totalColumnWidth
            let y = totalRowHeight * CGFloat(numberOfRows - 1 - rowIdx) + totalRowHeight
            
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
            return AdaptiveTabBarControllerDimmingView.ArcLayoutMetrics.expansionRadiusCompact
        default:
            return AdaptiveTabBarControllerDimmingView.ArcLayoutMetrics.expansionRadiusRegular
        }
    }
    
    private func angleRangeForArcLayout() -> Double {
        let angle = 180 - startAngleForArcLayout()
        return 180 - (2*angle) // produces a range that is centered relative to the start angle
    }
    
    private func startAngleForArcLayout() -> Double {
        return 160
    }
    
    // MARK: - Private
    
    private var actionButtons: [TabBarActionButton] = []
    private var showableActionViews: [TabBarActionButton] {
        actionButtons.filter(\.canShow)
    }
}
