//
//  CircleF.swift
//  Oem
//
//  Created by Davee on 2018/8/4.
//  Copyright © 2018年 davee. All rights reserved.
//

import UIKit

struct CircleF {
//    var centerX :CGFloat;
//    var centerY :CGFloat;
    var radius :CGFloat;
    var center :CGPoint = CGPoint.zero;
    
    var centerX :CGFloat {
        get { return center.x; }
        set { center.x = newValue; }
    }
    
    var centerY :CGFloat {
        get{ return center.y; }
        set{
            center.y = newValue;
        }
    }
    
    var left :CGFloat {
        return centerX - radius;
    }
    
    var right :CGFloat {
        return centerX + radius;
    }
    
    var top :CGFloat {
        return centerY - radius;
    }
    
    var bottom :CGFloat {
        return centerY + radius;
    }
    
    init() {
        radius = 0;
    }
    
    init(centerX x :CGFloat, centerY y:CGFloat, r:CGFloat) {
        center.x = x;
        center.y = y;
        self.radius = r;
    }
    
    // MARK: - Contains Detection
    
    func contains(point :CGPoint) -> Bool {
        let distance = self.distanceToCenter(point: point);
        return distance <= radius;
    }
    
    // MARK: - Distance To Center
    
    func distanceToCenter(point :CGPoint) -> CGFloat {
        return CGFloat(sqrtf(powf(Float(point.x - center.x), 2) + powf(Float(point.y - center.y), 2)));
    }
    
    
    // MARK: - Point for angle
    
    /// Get real coordinate for specified angle in degrees
    ///
    /// - Parameter angle: angle in degrees
    /// - Returns: return point for this angle
    func position(angle:CGFloat) -> CGPoint {
        return CGPoint(x: posX(angle: angle), y: posY(angle: angle));
    }
    
    /// Get coordinate for specified angle in degrees with custom radius
    ///
    /// - Parameters:
    ///   - a: angle in degrees
    ///   - r: radius customed
    /// - Returns: point for this angle
    func position(forAngle a:CGFloat, withRadius r :CGFloat) -> CGPoint {
        return CGPoint(x: posX(forAngle: a, withRadius: r), y: posY(forAngle: a, withRadius: r));
    }
    
    /// Position for angle in degrees.
    /// Note: angle = 0 indicates right edge
    ///
    /// - Parameter angle: angle in degrees
    /// - Returns: position for angle
    func posX(angle:CGFloat) -> CGFloat {
        var value = cos(toRadians(angle: angle));
        if abs(value) < 1.0e-6 {
            value = 0;
        }
        return (center.x + radius * value);
    }
    
    func posX(forAngle angle:CGFloat, withRadius r:CGFloat) -> CGFloat {
        var value = cos(toRadians(angle: angle));
        if abs(value) < 1.0e-6 {
            value = 0;
        }
        return (center.x + r * value);
    }
    
    func posY(angle:CGFloat) -> CGFloat {
        var value = sin(toRadians(angle: angle));
        if abs(value) < 1.0e-6 {
            value = 0;
        }
        return (center.y + radius * value);
    }
    
    func posY(forAngle angle:CGFloat, withRadius r:CGFloat) -> CGFloat {
        var value = sin(toRadians(angle: angle));
        if abs(value) < 1.0e-6 {
            value = 0;
        }
        return (center.y + r * value);
    }
    
    // MARK: - Angle for point
    
    /// Get angle in radian for specified point
    ///
    /// - Parameter p: point
    /// - Returns: angle in radian
    func radian(forPoint p :CGPoint) -> CGFloat {
        let dy = p.y - center.y;
        let dx = p.x - center.x;
        let radian = atan2f(Float(dy), Float(dx)); // atan2 : [-pi, pi];  atan : [-pi/2, pi/2]
        return CGFloat(radian);
    }
    
    /// Get angle in degrees for specified point
    ///
    /// - Parameter p: point
    /// - Returns: angle in degrees
    func angle(forPoint p :CGPoint) -> CGFloat {
        let radian = self.radian(forPoint: p);
        return toDegrees(radian: radian);
    }
}

extension CircleF {
    public static var unit: CircleF {
        return CircleF(centerX: 0, centerY: 0, r: 1);
    }
}

// 弧度：弧长等于半径的弧所对应的圆心角为1弧度, r = 2pi * r / (360 * r)
func toRadians(angle :CGFloat) -> CGFloat {
    return CGFloat.pi * angle / 180;
}

func toRadians(angle :Double) -> Double {
    return Double.pi * angle / 180;
}

func toDegrees(radian :CGFloat) -> CGFloat {
    return radian * 180 / CGFloat.pi;
}

/// Readjust angle for range [0, 360]
func readjustAngleLoc(angle :inout CGFloat) {
    while angle > 360 {
        angle -= 360;
    }
    while angle < 0 {
        angle += 360;
    }
}
