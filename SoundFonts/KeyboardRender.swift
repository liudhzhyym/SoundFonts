//
//  KeyboardRender.swift
//  SoundFonts
//
//  Created by Brad Howes on 12/20/18.
//  Copyright © 2018 B-Ray Software. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

final public class KeyboardRender : NSObject {

    //// Drawing Methods

    @objc dynamic public class func drawWhiteKey(keySize: CGSize = CGSize(width: 64, height: 240), roundedCorner: CGFloat = 12, pressed: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }

        //// Color Declarations
        let pressedColor = UIColor(red: 0.000, green: 1.000, blue: 0.895, alpha: 1.000)
        let whiteKeyColor = UIColor(red: 0.912, green: 0.912, blue: 0.912, alpha: 1.000)

        //// Gradient Declarations
        let pressedWhiteGradient = CGGradient(colorsSpace: nil, colors: [pressedColor.cgColor, pressedColor.blended(withFraction: 0.5, of: UIColor.white).cgColor, UIColor.white.cgColor] as CFArray, locations: [0, 0.65, 1])!

        //// Shadow Declarations
        let whiteKeyShadow = NSShadow()
        whiteKeyShadow.shadowColor = UIColor.black.withAlphaComponent(0.57)
        whiteKeyShadow.shadowOffset = CGSize(width: 3, height: 3)
        whiteKeyShadow.shadowBlurRadius = 5

        //// Frames
        let frame = CGRect(x: 0, y: 0, width: keySize.width, height: keySize.height)

        //// Subframes
        let group: CGRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width - 4, height: frame.height - 4)


        //// Group
        //// Key Drawing
        let keyPath = UIBezierPath(roundedRect: CGRect(x: group.minX + fastFloor(group.width * 0.00000 + 0.5), y: group.minY + fastFloor(group.height * 0.00000 + 0.5), width: fastFloor(group.width * 1.00000 + 0.5) - fastFloor(group.width * 0.00000 + 0.5), height: fastFloor(group.height * 1.00000 + 0.5) - fastFloor(group.height * 0.00000 + 0.5)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: roundedCorner, height: roundedCorner))
        keyPath.close()
        context.saveGState()
        context.setShadow(offset: whiteKeyShadow.shadowOffset, blur: whiteKeyShadow.shadowBlurRadius, color: (whiteKeyShadow.shadowColor as! UIColor).cgColor)
        whiteKeyColor.setFill()
        keyPath.fill()
        context.restoreGState()



        if (pressed) {
            //// PressedKey Drawing
            let pressedKeyRect = CGRect(x: group.minX + fastFloor(group.width * 0.00000 + 0.5), y: group.minY + fastFloor(group.height * 0.00000 + 0.5), width: fastFloor(group.width * 1.00000 + 0.5) - fastFloor(group.width * 0.00000 + 0.5), height: fastFloor(group.height * 1.00000 + 0.5) - fastFloor(group.height * 0.00000 + 0.5))
            let pressedKeyPath = UIBezierPath(roundedRect: pressedKeyRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: roundedCorner, height: roundedCorner))
            pressedKeyPath.close()
            context.saveGState()
            pressedKeyPath.addClip()
            context.drawLinearGradient(pressedWhiteGradient,
                start: CGPoint(x: pressedKeyRect.midX, y: pressedKeyRect.maxY),
                end: CGPoint(x: pressedKeyRect.midX, y: pressedKeyRect.minY),
                options: [])
            context.restoreGState()
        }
    }

    @objc dynamic public class func drawBlackKey(keySize: CGSize = CGSize(width: 64, height: 240), roundedCorner: CGFloat = 12, pressed: Bool = false) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        // This non-generic function dramatically improves compilation times of complex expressions.
        func fastFloor(_ x: CGFloat) -> CGFloat { return floor(x) }

        //// Color Declarations
        let blackKeyGapColor = UIColor(red: 0.386, green: 0.383, blue: 0.383, alpha: 1.000)
        let pressedColor = UIColor(red: 0.000, green: 1.000, blue: 0.895, alpha: 1.000)
        let pressedBlackGradientColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Gradient Declarations
        let pressedBlackGradient = CGGradient(colorsSpace: nil, colors: [pressedColor.cgColor, pressedColor.blended(withFraction: 0.5, of: pressedBlackGradientColor).cgColor, pressedBlackGradientColor.cgColor] as CFArray, locations: [0, 0.75, 1])!

        //// Shadow Declarations
        let blackKeyShadow = NSShadow()
        blackKeyShadow.shadowColor = UIColor.black
        blackKeyShadow.shadowOffset = CGSize(width: 3, height: 3)
        blackKeyShadow.shadowBlurRadius = 5

        //// Frames
        let frame = CGRect(x: 0, y: 0, width: keySize.width, height: keySize.height)

        //// Subframes
        let group: CGRect = CGRect(x: frame.minX + 6, y: frame.minY, width: frame.width - 12, height: frame.height)


        //// Group
        //// Gap Drawing
        let gapPath = UIBezierPath(roundedRect: CGRect(x: group.minX + fastFloor(group.width * 0.00000 + 0.5), y: group.minY + fastFloor(group.height * 0.00000 + 0.5), width: fastFloor(group.width * 1.00000 + 0.5) - fastFloor(group.width * 0.00000 + 0.5), height: fastFloor(group.height * 1.00000 + 0.5) - fastFloor(group.height * 0.00000 + 0.5)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: roundedCorner, height: roundedCorner))
        gapPath.close()
        blackKeyGapColor.setFill()
        gapPath.fill()


        //// Key Drawing
        let keyPath = UIBezierPath(roundedRect: CGRect(x: group.minX + fastFloor(group.width * 0.03846 + 0.5), y: group.minY + fastFloor(group.height * 0.00000 + 0.5), width: fastFloor(group.width * 0.96154 + 0.5) - fastFloor(group.width * 0.03846 + 0.5), height: fastFloor(group.height * 0.98333 + 0.5) - fastFloor(group.height * 0.00000 + 0.5)), byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: roundedCorner, height: roundedCorner))
        keyPath.close()
        context.saveGState()
        context.setShadow(offset: blackKeyShadow.shadowOffset, blur: blackKeyShadow.shadowBlurRadius, color: (blackKeyShadow.shadowColor as! UIColor).cgColor)
        UIColor.black.setFill()
        keyPath.fill()
        context.restoreGState()



        if (pressed) {
            //// PressedKey Drawing
            let pressedKeyRect = CGRect(x: group.minX + fastFloor(group.width * 0.03846 + 0.5), y: group.minY + fastFloor(group.height * 0.00000 + 0.5), width: fastFloor(group.width * 0.96154 + 0.5) - fastFloor(group.width * 0.03846 + 0.5), height: fastFloor(group.height * 0.98333 + 0.5) - fastFloor(group.height * 0.00000 + 0.5))
            let pressedKeyPath = UIBezierPath(roundedRect: pressedKeyRect, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: roundedCorner, height: roundedCorner))
            pressedKeyPath.close()
            context.saveGState()
            context.setShadow(offset: blackKeyShadow.shadowOffset, blur: blackKeyShadow.shadowBlurRadius, color: (blackKeyShadow.shadowColor as! UIColor).cgColor)
            context.beginTransparencyLayer(auxiliaryInfo: nil)
            pressedKeyPath.addClip()
            context.drawLinearGradient(pressedBlackGradient,
                start: CGPoint(x: pressedKeyRect.midX, y: pressedKeyRect.maxY),
                end: CGPoint(x: pressedKeyRect.midX, y: pressedKeyRect.minY),
                options: [])
            context.endTransparencyLayer()
            context.restoreGState()

        }
    }

}



private extension UIColor {
    func blended(withFraction fraction: CGFloat, of color: UIColor) -> UIColor {
        var r1: CGFloat = 1, g1: CGFloat = 1, b1: CGFloat = 1, a1: CGFloat = 1
        var r2: CGFloat = 1, g2: CGFloat = 1, b2: CGFloat = 1, a2: CGFloat = 1

        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(red: r1 * (1 - fraction) + r2 * fraction,
            green: g1 * (1 - fraction) + g2 * fraction,
            blue: b1 * (1 - fraction) + b2 * fraction,
            alpha: a1 * (1 - fraction) + a2 * fraction);
    }
}