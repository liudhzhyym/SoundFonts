// Copyright © 2018 Brad Howes. All rights reserved.

import UIKit
import os

/**
 Specialization of UITableViewCell that will display a SoundFont entry or a Patch entry.
 */
public final class TableCell: UITableViewCell, ReusableView, NibLoadableView {
    private lazy var log = Logging.logger("TableCell")

    /// Unicode character to show when a cell refers to a Patch that is in a Favorite
    private static let goldStarPrefix = "✪"

    public static func favoriteTag(_ isFavorite: Bool) -> String { return isFavorite ? goldStarPrefix + " " : "" }

    @IBInspectable public var selectedFontColor: UIColor = .lightGray
    @IBInspectable public var activedFontColor: UIColor = .systemTeal
    @IBInspectable public var favoriteFontColor: UIColor = .systemYellow

    @IBOutlet private weak var name: UILabel!
    @IBOutlet private weak var selectedIndicator: UIView!

    /// For patch cells, we want to always show the `selected` indicator when it holds the active patch. When true,
    /// ignore `setSelected` with a `false` value.
    private var lockSelected: Bool = false

    override public func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = true
    }

    private var selectedIndicatorAnimator: UIViewPropertyAnimator?

    private func stopAnimation() {
        selectedIndicatorAnimator?.stopAnimation(true)
        selectedIndicatorAnimator = nil
        selectedIndicator.alpha = 0.0
    }

    override public func prepareForReuse() {
        stopAnimation()
        lockSelected = false
    }

    /**
     Update the `selected` state of the cell. Customized to animate the `selectedIndicator` view.

     - parameter selected: true if the cell is selected
     - parameter animated: true if animating the selection
     */
    override public func setSelected(_ selected: Bool, animated: Bool) {
        os_log(.info, log: log, "setSelected '%s' selected: %d animated: %d", name.text ?? "", selected, animated)
        super.setSelected(selected, animated: animated)

        if lockSelected && !selected { return }
        stopAnimation()

        let newAlpha: CGFloat = selected ? 1.0 : 0.0
        if !animated || !selected {
            selectedIndicator.alpha = newAlpha
            return
        }

        selectedIndicatorAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeIn) {
            self.selectedIndicator.alpha = newAlpha
        }
        selectedIndicatorAnimator?.addCompletion { (state: UIViewAnimatingPosition) in
            self.selectedIndicator.alpha = state == .end ? newAlpha : (1.0 - newAlpha)
        }
        selectedIndicatorAnimator?.startAnimation()
    }

    /**
     Configure the cell to show font info
    
     - parameter name: the name to show
     - parameter isSelected: true if the font is currently selected with its patches visible on the right
     - parameter isActive: true if a patch from the font is currently being used
     */
    public func updateForFont(name: String, isSelected: Bool, isActive: Bool) {
        os_log(.debug, log: log, "update '%s' isSelected: %d isActive: %d", name, isSelected, isActive)
        self.name.text = name
        self.name.textColor = fontColorWhen(isSelected: isSelected, isActive: isActive, isFavorite: false)
        lockSelected = false
    }

    /**
     Configure the cell to show patch info

     - parameter name: the name to show
     - parameter isActive: true if the patch is currently active
     - parameter isFavorite: true if the patch is a favorite
    */
    public func updateForPatch(name: String, isActive: Bool, isFavorite: Bool) {
        os_log(.debug, log: log, "update '%s' isActive: %d isFavorite: %d", name, isActive, isFavorite)
        self.name.text = Self.favoriteTag(isFavorite) + name
        self.name.textColor = fontColorWhen(isSelected: isActive, isActive: isActive, isFavorite: isFavorite)
        lockSelected = isActive
    }

    private func fontColorWhen(isSelected: Bool, isActive: Bool, isFavorite: Bool) -> UIColor? {
        if isActive { return activedFontColor }
        if isFavorite { return favoriteFontColor }
        if isSelected { return selectedFontColor }
        return .lightGray
    }
}