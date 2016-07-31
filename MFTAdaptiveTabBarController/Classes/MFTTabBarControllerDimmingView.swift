//
//  MFTTabBarControllerDimmingView.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import UIKit

private let kExpansionRadius = 140.0

protocol MFTTabBarControllerDimmingViewDelegate: NSObjectProtocol {
    func dimmingViewWillExpand(dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidExpand(dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewWillCollapse(dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidCollapse(dimmingView: MFTTabBarControllerDimmingView)
}

public class MFTTabBarControllerDimmingView: UIView {
    
    var delegate: MFTTabBarControllerDimmingViewDelegate?
    
    public var accessoryButtonSize = CGSizeZero
    public var position: AccessoryButtonPosition = .BottomCenter
    public var anchor: CGPoint {
        switch position {
        case .BottomRight:
            let anchorOffset = accessoryButtonSize.width/2 + 24
            var anchor = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))
            anchor.x -= anchorOffset
            anchor.y -= anchorOffset
            return anchor
            
        case .BottomCenter:
            var anchor = CGPointMake(CGRectGetMidX(bounds), CGRectGetMaxY(bounds) - accessoryButtonSize.height/2)
            return anchor
        }
    }
    
    private(set) var collapsed = true
    private var actions = [MFTTabBarActionView]()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MFTTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MFTTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    // MARK: - Public
    
    public func addTabBarAction(action: MFTTabBarAction) {
        let actionView = MFTTabBarActionView(action: action)
        actionView.didTapHandler = { [unowned self] in
            self.collapse(true)
        }
        actions.append(actionView)
    }
    
    public func collapse(animated: Bool) {
        willCollapse()
        if animated {
            UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveLinear, animations: {
                // move the items to their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
            }, completion: { (finished) in
                // fade out the dimming view
                UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveLinear, animations: {
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
    
    public func expand(animated: Bool) {
        willExpand()
        if animated {
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveLinear, animations: {
                self.alpha = 1.0
            }, completion: { (finished) in
                // make sure the items begin at their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
                // spring them into their expanded positions
                UIView.animateWithDuration(0.6, delay: 0.0, usingSpringWithDamping: 0.45, initialSpringVelocity: 0.7, options: [], animations: {
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
    
    // MARK: - Actions
    
    @objc func backgroundTappedGesture(sender: UITapGestureRecognizer) {
        collapse(true)
    }
    
    // MARK: - Private
    
    private func moveActionViewsToExpandedPositions() {
        for (idx, action) in self.actions.enumerate() {
            addSubview(action)
            action.center = expandedCenterPointForAction(action, at: idx)
            action.alpha = 1.0
        }
    }
    
    private func moveActionViewsToCollapsedPositions() {
        for (idx, action) in self.actions.enumerate() {
            action.center = collapsedCenterPointForAction(action, at: idx)
            action.alpha = 0.0
        }
    }
    
    private func willExpand() {
        collapsed = false
        delegate?.dimmingViewWillExpand(self)
    }
    
    private func didExpand() {
        delegate?.dimmingViewDidExpand(self)
    }
    
    private func willCollapse() {
        delegate?.dimmingViewWillCollapse(self)
    }
    
    private func didCollapse() {
        collapsed = true
        delegate?.dimmingViewDidCollapse(self)
    }
    
    private func collapsedCenterPointForAction(action: MFTTabBarActionView, at: Int) -> CGPoint {
        return anchor
    }
    
    private func expandedCenterPointForAction(action: MFTTabBarActionView, at: Int) -> CGPoint {
        let range = angleRange(forPosition: position)
        let start = startAngle(forPosition: position)
        
        let incrementAngle = range / Double(actions.count - 1)
        let incrementIdx = Double(at)
        let expandedAngleInDegrees = start - (incrementAngle*incrementIdx)
        let expandedAngleInRadians = expandedAngleInDegrees * (M_PI / 180.0)
        
        // convert the position from cylindrical to cartesian coordinates
        let x = kExpansionRadius * cos(expandedAngleInRadians)
        let y = kExpansionRadius * sin(expandedAngleInRadians)
        
        return CGPointMake(anchor.x + CGFloat(x), anchor.y - CGFloat(y))
        
    }
    
    private func angleRange(forPosition position: AccessoryButtonPosition) -> Double {
        switch position {
        case .BottomRight:
            return 90.0
            
        case .BottomCenter:
            return 110.0
        }
    }
    
    private func startAngle(forPosition position: AccessoryButtonPosition) -> Double {
        switch position {
        case .BottomRight:
            return 180.0
            
        case .BottomCenter:
            return 145.0
        }
    }
    
}
