//
//  CCGestureLock.swift
//
//  Created by Hsuan-Chih Chuang on 11/04/2017.
//  Copyright (c) 2017 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit


public extension UIControlEvents {
    static var gestureBegan: UIControlEvents { return UIControlEvents(rawValue: 0b0001 << 23) }
    static var gestureComplete: UIControlEvents { return UIControlEvents(rawValue: 0b0001 << 24) }
    static var gestureConnectedNode: UIControlEvents { return UIControlEvents(rawValue: 0b0001 << 25) }
}


public class CCGestureLock: UIControl {
    
    lazy var appearance : CCGestureLockAppearance = {
       return CCGestureLockAppearance(control: self)
    }()
    
    
    
    
    // MARK : - Customizable properties
    // Gesture lock edge insets
    public var edgeInsets : UIEdgeInsets {
        
        get {
            return appearance.edgeInsets
        }
        set (edgeInsets) {
            appearance.edgeInsets = edgeInsets
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // Gesture lock size
    public typealias LockSize = (numHorizontalSensors: Int, numVerticalSensors : Int)
    public var lockSize : LockSize {
        get {
            return appearance.lockSize
        }
        set (lockSize) {
            appearance.lockSize = lockSize
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // Responder size
    public var responderSize = CGSize(width: 60, height: 60)
    
    // Sensor size
    public typealias RingType = CCGestureLockSensor.SensorAppearance.RingType
    public func setSensorAppearance(type: RingType,
        radius: CGFloat? = nil,
        width:  CGFloat? = nil,
        color:  UIColor? = nil, forState state: GestureLockState) {
        
        guard radius != nil || width != nil || color != nil else {
            return
        }
        if let setting = appearance.settings[state] {
            setting.sensor.update(type: type, radius: radius, width: width, color: color)
        }
        collectionView.reloadData()
        
    }
    
    // Line appearance
    public func setLineAppearance(width: CGFloat? = nil, color: UIColor? = nil, forState state: GestureLockState) {
        
        guard width != nil || color != nil else {
            return
        }
        if let setting = appearance.settings[state] {
            setting.line.update(width: width, color: color)
        }
    }
    
    // MARK: - CCGestureLock state management
    public enum GestureLockState {
        case normal
        case selected
        case error
    }
    public var gestureLockState: GestureLockState = .normal {
        
        willSet(gestureLockState) {}
        didSet {
            if gestureLockState == .normal {
                resetLock()
            }
            if gestureLockState == .error {
                
                collectionView.reloadItems(at: selectionPath)
                for indexPath in selectionPath {
                    collectionView.selectItem(
                        at: indexPath,
                        animated: true,
                        scrollPosition: [.centeredVertically, .centeredHorizontally] )
                }
                setNeedsDisplay()
            }
        }
    }
    
    
    
    
    // Private utilities
    private var latestTouchPoint = CGPoint.zero
    
    private lazy var collectionView : UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(
            CCGestureLockCollectionViewCell.self,
            forCellWithReuseIdentifier: "\(String(describing:  CCGestureLockCollectionViewCell.self))ID")
        collectionView.backgroundColor = UIColor.clear
        collectionView.isUserInteractionEnabled = false
        collectionView.allowsMultipleSelection = true
        collectionView.delegate = self.appearance
        collectionView.dataSource = self.appearance
        collectionView.accessibilityIdentifier = "Gesture Lock"
        if #available(iOS 9.0, *) {
            collectionView.semanticContentAttribute = .forceLeftToRight
        }
        return collectionView
    }()
    
    
    // Lock sequence cache
    private var selectionPath = [IndexPath]()
    
    public var lockSequence: [NSNumber] {
        get {
            return selectionPath.map({ (indexPath) -> NSNumber in
                return NSNumber(value: indexPath.item as Int)
            })
        }
    }

    func updateSelectionPath(with indexPath: IndexPath) {
        guard !selectionPath.contains(indexPath) else { return }
        selectionPath.append(indexPath)
        sendActions(for: .gestureConnectedNode)
    }
    
    func resetLock() {
        collectionView.reloadItems(at: selectionPath)
        selectionPath.removeAll()
        setNeedsDisplay()
    }
    
    
    
    
    // MARK: - View drawing & layout
    override open func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(appearance.settings[gestureLockState]!.line.color.cgColor)
        context?.setLineWidth(appearance.settings[gestureLockState]!.line.width)
        var fromCenter: CGPoint, toCenter: CGPoint
        
        for (index, item) in selectionPath.enumerated() {
            fromCenter = centerForSensorAtIndexPath(item)
            context?.move(to: CGPoint(x: fromCenter.x, y: fromCenter.y))
            if index+1 < selectionPath.count {
                toCenter = centerForSensorAtIndexPath(selectionPath[index+1])
                context?.addLine(to: CGPoint(x: toCenter.x, y: toCenter.y))
                context?.strokePath()
            }
        }
        
        if !latestTouchPoint.equalTo(CGPoint.zero) {
            toCenter = latestTouchPoint
            context?.addLine(to: CGPoint(x: toCenter.x, y: toCenter.y))
            context?.strokePath()
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if !self.subviews.contains(collectionView) {
            addSubview(collectionView)
        }
        collectionView.frame = self.bounds
        let layoutAttributes = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0))
        for (_, item) in appearance.settings {
            item.sensor.size = layoutAttributes!.size
        }
    }
    
    
    
    
    // MARK: - Sensor selection path algorithm
    private func updateSelectionPathForSelectedSensor(_ indexPath: IndexPath) {
        
        if let previousSelection = selectionPath.last {
            
            let deltaIndex = abs(indexPath.item - previousSelection.item)
            let deltaRows = abs(previousSelection.item/lockSize.numHorizontalSensors - indexPath.item/lockSize.numHorizontalSensors)
            let divisor = deltaRows > 1 && deltaIndex%deltaRows == 0 ? deltaIndex/deltaRows : deltaIndex
            updateSelectionPath(previousSelection.item, end: indexPath.item, increment: deltaRows == 0 ? 1 : divisor)
            
        } else {
            
            updateSelectionPath(-1, end: indexPath.item, increment: indexPath.item+1)
        }
    }
    
    private func updateSelectionPath(_ start: Int, end: Int, increment: Int) {
        
        if start == end {
            return
        }
        
        let next = start < end ? start + increment : start - increment
        let indexPath = IndexPath(item: next, section: 0)
        if !selectionPath.contains(indexPath) {
            updateSelectionPath(with: indexPath)
            collectionView.selectItem(
                at: indexPath,
                animated: true,
                scrollPosition: UICollectionViewScrollPosition())
        }
        updateSelectionPath(next, end: end, increment: increment)
    }
    
    
    
    
    // MARK: - Sensor touch responder arithmetics
    private func hitTest(_ point: CGPoint) -> IndexPath? {
        
        if let indexPath = collectionView.indexPathForItem(at: point) {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? CCGestureLockCollectionViewCell {
                
                let size = CGSize(
                    width: max(responderSize.width, cell.bounds.size.width*0.4),
                    height: max(responderSize.height, cell.bounds.size.height*0.4)
                )
                
                let center = collectionView.convert(cell.center, to: self)
                let respondArea = CGRect(
                    x: center.x - size.width/2.0,
                    y: center.y - size.height/2.0,
                    width: size.width,
                    height: size.height)
                
                if respondArea.contains(point) {
                    return indexPath
                }
            }
        }
        return nil
    }
    
    private func centerForSensorAtIndexPath(_ indexPath: IndexPath) -> CGPoint {
        if let cell = collectionView.cellForItem(at: indexPath) as? CCGestureLockCollectionViewCell {
            return collectionView.convert(cell.center, to: self)
        }
        return CGPoint.zero
    }
    
    
    
    
    // MARK: - Touch handlers
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if selectionPath.count == 0 {
            if let sensorIndexPath = hitTest(touch.location(in: self)) {
                sendActions(for: .gestureBegan)
                
                updateSelectionPathForSelectedSensor(sensorIndexPath)
                return true
            }
        }
        return false
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        latestTouchPoint = touch.location(in: self)
        if let sensorIndexPath = hitTest(latestTouchPoint) {
            if selectionPath.index(of: sensorIndexPath) == nil {
                updateSelectionPathForSelectedSensor(sensorIndexPath)
                sendActions(for: .valueChanged)
            }
        }
        setNeedsDisplay()
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        latestTouchPoint = CGPoint.zero
        setNeedsDisplay()
        sendActions(for: .gestureComplete)
    }
    

}
