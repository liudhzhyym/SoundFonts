// Copyright © 2018 Brad Howes. All rights reserved.

import UIKit
import os

/**
 Manager of the strip informational strip between the keyboard and the SoundFont patches / favorites screens. Supports
 left/right swipes to switch the upper view, and two-finger left/right pan to adjust the keyboard range.
 */
public final class InfoBarController: UIViewController {
    private let log = Logging.logger("InfoBar")

    @IBOutlet private weak var status: UILabel!
    @IBOutlet private weak var patchInfo: UILabel!
    @IBOutlet private weak var lowestKey: UIButton!
    @IBOutlet private weak var addSoundFont: UIButton!
    @IBOutlet private weak var highestKey: UIButton!
    @IBOutlet private weak var touchView: UIView!
    @IBOutlet private weak var showGuide: UIButton!
    @IBOutlet private weak var showSettings: UIButton!
    @IBOutlet private weak var editVisibility: UIButton!

    @IBOutlet private weak var showMoreButtons: UIButton!
    @IBOutlet private weak var moreButtons: UIView!
    @IBOutlet private weak var moreButtonsXConstraint: NSLayoutConstraint!

    private let doubleTap = UITapGestureRecognizer()
    private var panOrigin: CGPoint = CGPoint.zero
    private var fader: UIViewPropertyAnimator?
    private var activePatchManager: ActivePatchManager!
    private var soundFonts: SoundFonts!
    private var isMainApp: Bool!

    public override func viewDidLoad() {
        highestKey.isHidden = true
        lowestKey.isHidden = true

        doubleTap.numberOfTouchesRequired = 1
        doubleTap.numberOfTapsRequired = 2
        touchView.addGestureRecognizer(doubleTap)

        let panner = UIPanGestureRecognizer(target: self, action: #selector(panKeyboard))
        panner.minimumNumberOfTouches = 1
        panner.maximumNumberOfTouches = 1
        touchView.addGestureRecognizer(panner)

        if traitCollection.horizontalSizeClass == .compact {
            moreButtonsXConstraint.constant = -moreButtons.frame.width
        }
    }
}

extension InfoBarController {

    @IBAction
    func toggleMoreButtons(_ sender: UIButton) {
        animateMoreButtons()
    }

    @IBAction private func showSettings(_ sender: UIButton) {
        animateMoreButtons()
    }

    @IBAction private func showGuide(_ sender: UIButton) {
        animateMoreButtons()
    }
}

extension InfoBarController: ControllerConfiguration {

    public func establishConnections(_ router: ComponentContainer) {
        activePatchManager = router.activePatchManager
        activePatchManager.subscribe(self, notifier: activePatchChange)
        soundFonts = router.soundFonts
        isMainApp = router.isMainApp
        router.favorites.subscribe(self, notifier: favoritesChange)
        useActivePatchKind(activePatchManager.active)
    }
}

extension InfoBarController: InfoBar {

    /**
     Add an event target to one of the internal UIControl entities.
    
     - parameter event: the event to target
     - parameter target: the instance to notify when the event fires
     - parameter action: the method to call when the event fires
     */
    public func addEventClosure(_ event: InfoBarEvent, _ closure: @escaping UIControl.Closure) {
        switch event {
        case .shiftKeyboardUp:
            highestKey.addClosure(closure)
            highestKey.isHidden = false

        case .shiftKeyboardDown:
            lowestKey.addClosure(closure)
            lowestKey.isHidden = false

        case .doubleTap: doubleTap.addClosure(closure)
        case .addSoundFont: addSoundFont.addClosure(closure)
        case .showGuide: showGuide.addClosure(closure)
        case .showSettings: showSettings.addClosure(closure)
        case .editVisibility: editVisibility.addClosure(closure)
        }
    }

    /**
     Set the text to temporarily show in the center of the info bar.

     - parameter value: the text to display
     */
    public func setStatus(_ value: String) {
        status.text = value
        startStatusAnimation()
    }

    /**
     Set the range of keys to show in the bar
    
     - parameter from: the first key label
     - parameter to: the last key label
     */
    public func setVisibleKeyLabels(from: String, to: String) {
        UIView.performWithoutAnimation {
            lowestKey.setTitle("❰" + from, for: .normal)
            lowestKey.accessibilityLabel = "Keyboard down before " + from
            lowestKey.layoutIfNeeded()
            highestKey.setTitle(to + "❱", for: .normal)
            highestKey.accessibilityLabel = "Keyboard up after " + to
            highestKey.layoutIfNeeded()
        }
    }

    public func hideButtons() {
        animateMoreButtons()
    }
}

// MARK: - Private

extension InfoBarController: SegueHandler {

    public enum SegueIdentifier: String {
        case settings
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if case .settings = segueIdentifier(for: segue) {
            beginSettingsView(segue, sender: sender)
        }
    }

    private func beginSettingsView(_ segue: UIStoryboardSegue, sender: Any?) {
        guard let nc = segue.destination as? UINavigationController,
            let vc = nc.topViewController as? SettingsViewController else { return }

        vc.soundFonts = soundFonts

        // Only reveal keyboard if main app (not AUv3) and settings view is not popover
        vc.isMainApp = isMainApp

        if !isMainApp {
            vc.modalPresentationStyle = .fullScreen
            nc.modalPresentationStyle = .fullScreen
        }

        if let ppc = nc.popoverPresentationController {
            ppc.sourceView = showSettings
            ppc.sourceRect = showSettings.bounds
            ppc.permittedArrowDirections = .any
        }
    }
}

extension InfoBarController {

    private func animateMoreButtons() {
        guard traitCollection.horizontalSizeClass == .compact else { return }
        moreButtonsXConstraint.constant = moreButtons.isHidden ? -moreButtons.frame.width : 0
        view.layoutIfNeeded()

        let willBeHidden = !moreButtons.isHidden
        let newImage = UIImage(named: willBeHidden ? "More" : "MoreFilled", in: Bundle(for: Self.self), compatibleWith: .none)
        let newConstraint = willBeHidden ? -moreButtons.frame.width : 0
        let newAlpha: CGFloat = willBeHidden ? 1.0 : 0.5

        moreButtons.isHidden = false
        let animator = UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0.0,
            options: [],
            animations: {
                self.moreButtonsXConstraint.constant = newConstraint
                self.touchView.alpha = newAlpha
                self.view.layoutIfNeeded()
            },
            completion: { _ in
                self.moreButtons.isHidden = willBeHidden
                self.touchView.alpha = newAlpha
            }
        )

        UIView.transition(with: showMoreButtons, duration: 0.4, options: .transitionCrossDissolve) {
            self.showMoreButtons.setImage(newImage, for: .normal)
        }

        animator.startAnimation()
    }

    private func activePatchChange(_ event: ActivePatchEvent) {
        if case let .active(old: _, new: new, playSample: _) = event {
            useActivePatchKind(new)
        }
    }

    private func favoritesChange(_ event: FavoritesEvent) {
        switch event {
        case let .added(index: _, favorite: favorite): updateInfoBar(with: favorite)
        case let .changed(index: _, favorite: favorite): updateInfoBar(with: favorite)
        case let .removed(index: _, favorite: favorite, bySwiping: _): updateInfoBar(with: favorite.soundFontAndPatch)
        default: break
        }
    }

    private func updateInfoBar(with favorite: LegacyFavorite) {
        if favorite.soundFontAndPatch == activePatchManager.soundFontAndPatch {
            setPatchInfo(name: favorite.name, isFavored: true)
        }
    }

    private func updateInfoBar(with soundFontAndPatch: SoundFontAndPatch) {
        if soundFontAndPatch == activePatchManager.soundFontAndPatch {
            if let patch = activePatchManager.resolveToPatch(soundFontAndPatch) {
                setPatchInfo(name: patch.name, isFavored: false)
            }
        }
    }

    private func useActivePatchKind(_ activePatchKind: ActivePatchKind) {
        if let favorite = activePatchKind.favorite {
            setPatchInfo(name: favorite.name, isFavored: true)
        }
        else if let soundFontAndPatch = activePatchKind.soundFontAndPatch {
            if let patch = activePatchManager.resolveToPatch(soundFontAndPatch) {
                setPatchInfo(name: patch.name, isFavored: false)
            }
        }
        else {
            setPatchInfo(name: "-", isFavored: false)
        }
    }

    private func setPatchInfo(name: String, isFavored: Bool) {
        os_log(.info, log: log, "setPatchInfo: %{public}s %d", name, isFavored)
        patchInfo.text = TableCell.favoriteTag(isFavored) + name
        cancelStatusAnimation()
    }

    private func startStatusAnimation() {
        cancelStatusAnimation()

        status.isHidden = false
        status.alpha = 1.0
        patchInfo.alpha = 0.0

        self.fader = UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
            self.status.alpha = 0.0
            self.patchInfo.alpha = 1.0
        }

        self.fader?.addCompletion { _ in
            self.status.isHidden = true
            self.fader = nil
        }

        self.fader?.startAnimation(afterDelay: 1.0)
    }

    private func cancelStatusAnimation() {
        if let fader = self.fader {
            fader.stopAnimation(true)
            self.fader = nil
        }
    }

    @objc private func panKeyboard(_ panner: UIPanGestureRecognizer) {
        if panner.state == .began {
            panOrigin = panner.translation(in: view)
        }
        else {
            let point = panner.translation(in: view)
            let change = Int((point.x - panOrigin.x) / 40.0)
            if change < 0 {
                for _ in change..<0 {
                    highestKey.sendActions(for: .touchUpInside)
                }
                panOrigin = point
            }
            else if change > 0 {
                for _ in 0..<change {
                    lowestKey.sendActions(for: .touchUpInside)
                }
                panOrigin = point
            }
        }
    }
}
