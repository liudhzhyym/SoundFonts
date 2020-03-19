// Copyright © 2020 Brad Howes. All rights reserved.

import UIKit
import os

public extension SettingKeys {
    static let showSolfegeLabel = SettingKey<Bool>("showSolfegeLabel", defaultValue: true)
    static let playSample = SettingKey<Bool>("playSample", defaultValue: false)
    static let showKeyLabels = SettingKey<Bool>("showKeyLabels", defaultValue: false)
    static let keyWidth = SettingKey<Float>("keyWidth", defaultValue: 64.0)
}

/**
 Manages window showing various runtime settings and options.
 */
public final class SettingsViewController: UIViewController {
    private let log = Logging.logger("SetVC")

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var upperBackground: UIView!
    @IBOutlet private weak var doneButton: UIBarButtonItem!

    @IBOutlet weak var playSamplesStackView: UIStackView!
    @IBOutlet weak var solfegeStackView: UIStackView!
    @IBOutlet weak var keyLabelsStackView: UIStackView!
    @IBOutlet weak var keyWidthStackView: UIStackView!
    @IBOutlet weak var removeSoundFontsStackView: UIStackView!
    @IBOutlet weak var restoreSoundFontsStackView: UIStackView!
    @IBOutlet weak var versionReviewStackView: UIStackView!

    @IBOutlet private weak var showSolfegeNotes: UISwitch!
    @IBOutlet private weak var playSample: UISwitch!
    @IBOutlet private weak var showKeyLabels: UISwitch!
    @IBOutlet private weak var keyWidthSlider: UISlider!
    @IBOutlet private weak var keyWidthLabel: UILabel!

    @IBOutlet private weak var removeDefaultSoundFontsLabel: UILabel!
    @IBOutlet private weak var removeDefaultSoundFonts: UIButton!
    @IBOutlet private weak var restoreDefaultSoundFontsLabel: UILabel!
    @IBOutlet private weak var restoreDefaultSoundFonts: UIButton!
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var review: UIButton!

    private var revealKeyboardForKeyWidthChanges = false

    public var soundFonts: SoundFonts!
    public var isMainApp = true

    override public func viewWillAppear(_ animated: Bool) {
        precondition(soundFonts != nil, "nil soundFonts")
        super.viewWillAppear(animated)

        revealKeyboardForKeyWidthChanges = false
        if let popoverPresentationVC = self.parent?.popoverPresentationController {
            revealKeyboardForKeyWidthChanges = popoverPresentationVC.arrowDirection == .unknown
        }

        showSolfegeNotes.isOn = Settings[.showSolfegeLabel]
        playSample.isOn = Settings[.playSample]
        showKeyLabels.isOn = Settings[.showKeyLabels]
        updateButtonState()

        keyWidthSlider.maximumValue = 96.0
        keyWidthSlider.minimumValue = 32.0
        keyWidthSlider.isContinuous = true
        keyWidthSlider.value = Settings[.keyWidth]

        let isAUv3 = !isMainApp
        solfegeStackView.isHidden = isAUv3
        keyLabelsStackView.isHidden = isAUv3
        keyWidthStackView.isHidden = isAUv3

        review.isEnabled = isMainApp

        endShowKeyboard()

        preferredContentSize = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    private func beginShowKeyboard() {
        removeSoundFontsStackView.isHidden = true
        restoreSoundFontsStackView.isHidden = true
        versionReviewStackView.isHidden = true
        view.backgroundColor = contentView.backgroundColor?.withAlphaComponent(0.2)
        contentView.backgroundColor = contentView.backgroundColor?.withAlphaComponent(0.0)
    }

    private func endShowKeyboard() {
        removeSoundFontsStackView.isHidden = false
        restoreSoundFontsStackView.isHidden = false
        versionReviewStackView.isHidden = false
        view.backgroundColor = contentView.backgroundColor?.withAlphaComponent(1.0)
        contentView.backgroundColor = contentView.backgroundColor?.withAlphaComponent(1.0)
    }

    @IBAction func keyWidthEditingDidBegin(_ sender: Any) {
        os_log(.info, log: log, "keyWidthEditingDidBegin")
        guard revealKeyboardForKeyWidthChanges else { return }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction],
                                                       animations: self.beginShowKeyboard,
                                                       completion: { _ in self.beginShowKeyboard() })
    }

    @IBAction func keyWidthEditingDidEnd(_ sender: Any) {
        os_log(.info, log: log, "keyWidthEditingDidEnd")
        guard revealKeyboardForKeyWidthChanges else { return }
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction],
                                                       animations: self.endShowKeyboard,
                                                       completion: { _ in self.endShowKeyboard() })
    }
    private func updateButtonState() {
        restoreDefaultSoundFonts.isEnabled = !soundFonts.hasAllBundled
        removeDefaultSoundFonts.isEnabled = soundFonts.hasAnyBundled
    }

    @IBAction
    private func close(_ sender: Any) {
        self.dismiss(animated: true)
    }

    @IBAction func visitAppStore(_ sender: Any) {
        NotificationCenter.default.post(.visitAppStore)
    }

    @IBAction
    private func toggleShowSolfegeNotes(_ sender: Any) {
        Settings[.showSolfegeLabel] = self.showSolfegeNotes.isOn
    }

    @IBAction func togglePlaySample(_ sender: Any) {
        Settings[.playSample] = self.playSample.isOn
    }

    @IBAction func toggleShowKeyLabels(_ sender: Any) {
        Settings[.showKeyLabels] = self.showKeyLabels.isOn
        NotificationCenter.default.post(.showKeyLabelsChanged)
    }

    @IBAction func keyWidthChange(_ sender: Any) {
        let prevValue = Settings[.keyWidth].rounded()
        var newValue = keyWidthSlider.value.rounded()
        if abs(newValue - 64.0) < 4.0 { newValue = 64.0 }
        keyWidthSlider.value = newValue

        if newValue != prevValue {
            os_log(.info, log: log, "new key width: %f", newValue)
            Settings[.keyWidth] = newValue
            NotificationCenter.default.post(.keyWidthChanged)
        }
    }

    @IBAction
    private func removeDefaultSoundFonts(_ sender: Any) {
        soundFonts.removeBundled()
        updateButtonState()
        postNotice(msg: "Removed entries to the built-in sound fonts.")
    }

    @IBAction
    private func restoreDefaultSoundFonts(_ sender: Any) {
        soundFonts.restoreBundled()
        updateButtonState()
        postNotice(msg: "Restored entries to the built-in sound fonts.")
    }

    private func postNotice(msg: String) {
        let alertController = UIAlertController(title: "SoundFonts",
                                                message: msg,
                                                preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel) { _ in }
        alertController.addAction(cancel)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY,
                                                  width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(alertController, animated: true, completion: nil)
    }
}
