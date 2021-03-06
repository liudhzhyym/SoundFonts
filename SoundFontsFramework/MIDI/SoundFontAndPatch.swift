// Copyright © 2019 Brad Howes. All rights reserved.

import Foundation

/**
 A unique combination of a SoundFont and one if its patches. This is the normal way to communicate what patch is active
 and what a `favorite` item points to.
 */
public struct SoundFontAndPatch: Codable, Hashable {
    public let soundFontKey: LegacySoundFont.Key
    public let patchIndex: Int
}
