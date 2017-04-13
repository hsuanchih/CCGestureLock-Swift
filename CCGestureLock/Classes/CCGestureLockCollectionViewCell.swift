//
//  CCGestureLockCollectionViewCell.swift
//
//  Created by Hsuan-Chih Chuang on 11/04/2017.
//  Copyright (c) 2017 Hsuan-Chih Chuang. All rights reserved.
//

import UIKit

class CCGestureLockCollectionViewCell: UICollectionViewCell {
    
    lazy var sensorImageView = {
        
        return UIImageView(frame: CGRect.zero)
    }()
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        if !contentView.subviews.contains(sensorImageView) {
            contentView.addSubview(sensorImageView)
        }
        sensorImageView.frame = contentView.bounds
    }
}
