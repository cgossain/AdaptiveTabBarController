//
//  MFTTabBarControllerDimmingView.swift
//  Pods
//
//  Created by Christian Gossain on 2016-07-25.
//
//

import UIKit

private let MFTExpansionRadiusCompact = 140.0
private let MFTExpansionRadiusRegular = 200.0

protocol MFTTabBarControllerDimmingViewDelegate: NSObjectProtocol {
    func dimmingViewWillExpand(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidExpand(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewWillCollapse(_ dimmingView: MFTTabBarControllerDimmingView)
    func dimmingViewDidCollapse(_ dimmingView: MFTTabBarControllerDimmingView)
}

open class MFTTabBarControllerDimmingView: UIView {
    
    var delegate: MFTTabBarControllerDimmingViewDelegate?
    
    open var accessoryButtonSize = CGSize.zero
    open var position: AccessoryButtonPosition = .bottomCenter
    open var anchor: CGPoint {
        switch position {
        case .bottomRight:
            let anchorOffset = accessoryButtonSize.width/2.0 + 24
            var anchor = CGPoint(x: bounds.maxX, y: bounds.maxY)
            anchor.x -= anchorOffset
            anchor.y -= anchorOffset
            return anchor
            
        case .bottomCenter:
            let anchor = CGPoint(x: bounds.midX, y: bounds.maxY - accessoryButtonSize.height/2.0)
            return anchor
        }
    }
    
    fileprivate(set) var collapsed = true
    fileprivate var actions = [MFTTabBarActionView]()
    
    // MARK: - Lifecycle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        dimmingViewCommonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dimmingViewCommonInit()
    }
    
    private func dimmingViewCommonInit() {
        if #available(iOS 10.0, *) {
            let blurEffectsView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            addSubview(blurEffectsView)
            
            blurEffectsView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            blurEffectsView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            blurEffectsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            blurEffectsView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
        else {
            backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MFTTabBarControllerDimmingView.backgroundTappedGesture(_:))))
    }
    
    // MARK: - Public
    
    open func addTabBarAction(_ action: MFTTabBarAction) {
        let actionView = MFTTabBarActionView(action: action)
        actionView.didTapHandler = { [unowned self] in
            self.collapse(true)
        }
        actions.append(actionView)
    }
    
    open func collapse(_ animated: Bool) {
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
    
    open func expand(_ animated: Bool) {
        willExpand()
        if animated {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: { (finished) in
                // make sure the items begin at their collapsed positions
                self.moveActionViewsToCollapsedPositions()
                
                // spring them into their expanded positions
                UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: [], animations: {
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
        collapse(true)
    }
    
    // MARK: - Private
    
    fileprivate func expansionRadius() -> Double {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            return MFTExpansionRadiusCompact
        default:
            return MFTExpansionRadiusRegular
        }
    }
    
    fileprivate func willExpand() {
        collapsed = false
        delegate?.dimmingViewWillExpand(self)
    }
    
    fileprivate func didExpand() {
        delegate?.dimmingViewDidExpand(self)
    }
    
    fileprivate func willCollapse() {
        delegate?.dimmingViewWillCollapse(self)
    }
    
    fileprivate func didCollapse() {
        collapsed = true
        delegate?.dimmingViewDidCollapse(self)
    }
    
    fileprivate func collapsedCenterPointForAction(_ action: MFTTabBarActionView, at: Int) -> CGPoint {
        return anchor
    }
    
    fileprivate func expandedCenterPointForAction(_ action: MFTTabBarActionView, at: Int) -> CGPoint {
        let range = angleRange(forPosition: position)
        let start = startAngle(forPosition: position)
        
        let incrementAngle = range / Double(actions.count - 1)
        let incrementIdx = Double(at)
        let expandedAngleInDegrees = start - (incrementAngle*incrementIdx)
        let expandedAngleInRadians = expandedAngleInDegrees * (M_PI / 180.0)
        
        // convert the position from cylindrical to cartesian coordinates
        let x = expansionRadius() * cos(expandedAngleInRadians)
        let y = expansionRadius() * sin(expandedAngleInRadians)
        
        return CGPoint(x: anchor.x + CGFloat(x), y: anchor.y - CGFloat(y))
        
    }
    
    fileprivate func angleRange(forPosition position: AccessoryButtonPosition) -> Double {
        switch position {
        case .bottomRight:
            return 90
            
        case .bottomCenter:
            return 140
        }
    }
    
    fileprivate func startAngle(forPosition position: AccessoryButtonPosition) -> Double {
        switch position {
        case .bottomRight:
            return 180
            
        case .bottomCenter:
            return 160
        }
    }
    
}
