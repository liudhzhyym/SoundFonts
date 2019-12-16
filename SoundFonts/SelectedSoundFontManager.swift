// Copyright © 2018 Brad Howes. All rights reserved.

import Foundation
import os

extension SettingKeys {
    static let lastSelectedSoundFont = SettingKey<Data>("lastSelectedSoundFont", defaultValue: Data())
}

enum SelectedSoundFontEvent {
    case changed(old: SoundFont, new: SoundFont)
}

final class SelectedSoundFontManager: SubscriptionManager<SelectedSoundFontEvent> {
    private let log = Logging.logger("SelSF")

    private(set) var selected: SoundFont

    init(activePatchManager: ActivePatchManager) {
        self.selected = Self.restore() ?? activePatchManager.active.soundFontPatch.soundFont
        os_log(.info, log: log, "selected: %s", selected.description)
    }

    func setSelected(_ soundFont: SoundFont) {
        os_log(.info, log: log, "setSelected: %s", soundFont.description)
        let old = selected
        selected = soundFont
        self.save()
        notify(.changed(old: old, new: soundFont))
    }

    static func restore() -> SoundFont? {
        let decoder = JSONDecoder()
        let data = Settings[.lastSelectedSoundFont]
        return try? decoder.decode(SoundFont.self, from: data)
    }

    func save() {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(self.selected) {
                Settings[.lastSelectedSoundFont] = data
            }
        }
    }
}
