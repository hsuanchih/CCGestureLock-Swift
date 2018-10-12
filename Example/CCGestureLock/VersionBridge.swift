//
//  VersionBridge.swift
//  CCGestureLock_Example
//
//  Created by Hsuan-Chih Chuang on 2018/10/12.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

#if swift(>=4.2)
public typealias UIApplicationLaunchOptionsKey = UIApplication.LaunchOptionsKey
public func UIEdgeInsetsMake(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
}
#endif
