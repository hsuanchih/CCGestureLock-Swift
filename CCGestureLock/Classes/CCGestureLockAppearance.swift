//
//  CCGestureLockAppearance.swift
//
//  Created by Hsuan-Chih Chuang on 12/04/2017.
//  Copyright (c) 2017 Hsuan-Chih Chuang. All rights reserved.
//

import Foundation


// MARK: - UICollectionViewDataSource
extension CCGestureLockAppearance: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lockSize.numHorizontalSensors * lockSize.numVerticalSensors
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "\(String(describing:  CCGestureLockCollectionViewCell.self))ID",
            for: indexPath
        )

        cell.accessibilityIdentifier = "Grid section \(indexPath.section), row \(indexPath.row)"
        (cell as? CCGestureLockCollectionViewCell)?.sensorImageView.image = settings[.normal]?.sensor.image
        (cell as? CCGestureLockCollectionViewCell)?.sensorImageView.highlightedImage = (control?.gestureLockState == .normal) ? settings[.selected]?.sensor.image : settings[.error]?.sensor.image
        
        return cell
    }
}



// MARK: - UICollectionViewDelegate
extension CCGestureLockAppearance: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CCGestureLockCollectionViewCell {
            cell.sensorImageView.isHighlighted = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CCGestureLockCollectionViewCell {
            cell.sensorImageView.isHighlighted = false
        }
    }
}



// MARK: - UICollectionViewDelegateFlowLayout
extension CCGestureLockAppearance: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth =
            (collectionView.bounds.width - (edgeInsets.left + edgeInsets.right)) / CGFloat(lockSize.numHorizontalSensors)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return edgeInsets
    }
}


class CCGestureLockAppearance : NSObject {
    
    fileprivate weak var control : CCGestureLock?
    init(control: CCGestureLock) {
        super.init()
        self.control = control
    }
    
    var edgeInsets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
    
    typealias LockSize = CCGestureLock.LockSize
    var lockSize : LockSize = (3, 3)
    
    var settings: [CCGestureLock.GestureLockState : (sensor: CCGestureLockSensor, line: LineAppearance)] = [
        
        .normal : (
            CCGestureLockSensor(
                appearance: CCGestureLockSensor.SensorAppearance(
                    innerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 5, width: 1, color: .darkGray),
                    outerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 0, width: 0, color: .clear)
            ))
            ,
            LineAppearance(
                width: 5.5,
                color: UIColor.darkGray.withAlphaComponent(0.5)
            )
        ),
        
        .selected : (
            CCGestureLockSensor(appearance: CCGestureLockSensor.SensorAppearance(
                innerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 3, width: 5, color: .darkGray),
                outerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 30, width: 5, color: .darkGray)
            ))
            ,
            LineAppearance(
                width: 5.5,
                color: UIColor.darkGray.withAlphaComponent(0.5)
            )
        ),
        
        .error : (
            CCGestureLockSensor(appearance: CCGestureLockSensor.SensorAppearance(
                innerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 3, width: 5, color: .red),
                outerRing: CCGestureLockSensor.SensorAppearance.RingAppearance(radius: 30, width: 5, color: .red)
            ))
            ,
            LineAppearance(
                width: 5.5,
                color: UIColor.darkGray.withAlphaComponent(0.5)
            )
        )
    ]
    
    class LineAppearance : Appearance {
        
        var width : CGFloat
        var color : UIColor
        
        init(width: CGFloat, color: UIColor) {
            self.width = width
            self.color = color
        }
        
        func update(width: CGFloat?, color: UIColor?) {
            self.width = width ?? self.width
            self.color = color ?? self.color
        }
    }

}

protocol Appearance {
    
    var width : CGFloat { get set }
    var color : UIColor { get set }
}
