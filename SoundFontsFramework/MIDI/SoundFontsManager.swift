// Copyright © 2019 Brad Howes. All rights reserved.

import Foundation
import os
import SoundFontInfoLib

/**
 Manages a collection of SoundFont instances. Changes to the collection are communicated as a SoundFontsEvent event.
 */
public final class SoundFontsManager: SubscriptionManager<SoundFontsEvent> {

    private static let log = Logging.logger("SFLib")

    private static let appArchivePath = FileManager.default.privateDocumentsDirectory
        .appendingPathComponent("SoundFontLibrary.plist")
    private static let sharedArchivePath = FileManager.default.sharedDocumentsDirectory
        .appendingPathComponent("SoundFontLibrary.plist")

    private var log: OSLog { Self.log }
    private let sharedStateMonitor: SharedStateMonitor
    private var collection: SoundFontCollection

    /**
     Attempt to restore the last saved collection.

     - returns: restored SoundFont collection or nil if unable to do so
     */
    private static func restore() -> SoundFontCollection? {
        os_log(.info, log: log, "attempting to restore collection")
        for url in [Self.sharedArchivePath, Self.appArchivePath] {
            os_log(.info, log: log, "trying to read from '%s'", url.path)
            if let data = try? Data(contentsOf: url, options: .dataReadingMapped) {
                os_log(.info, log: log, "restoring from '%s'", url.path)
                if let collection = try? PropertyListDecoder().decode(SoundFontCollection.self, from: data) {
                    os_log(.info, log: log, "restored")
                    return collection
                }
            }
        }

        return nil
    }

    /**
     Create a new collection using the embedded SoundFont files.

     - returns: new SoundFontCollection
     */
    private static func create() -> SoundFontCollection {
        os_log(.info, log: log, "creating new collection")
        let bundle = Bundle(for: SoundFontsManager.self)
        let urls = bundle.paths(forResourcesOfType: "sf2", inDirectory: nil).map { URL(fileURLWithPath: $0) }
        if urls.count == 0 { fatalError("no SF2 files in bundle") }
        return SoundFontCollection(soundFonts: urls.map { addFromBundle(url: $0) })
    }

    /**
     Create a new manager for a collection of SoundFonts. Attempts to load from disk a saved collection, and if that
     fails then creates a new one containing SoundFont instances embedded in the app.

     - parameter sharedStateMonitor: monitor to use to signal when the collection has changed
     */
    public init(sharedStateMonitor: SharedStateMonitor) {
        self.sharedStateMonitor = sharedStateMonitor
        self.collection = Self.restore() ?? Self.create()
        super.init()
        save()
        os_log(.info, log: log, "collection size: %d", collection.count)
    }

    /**
     Reload from disk the managed collection of SoundFonts due to a change made by another process.
     */
    public func reload() {
        os_log(.info, log: log, "reload")
        if let collection = Self.restore() {
            os_log(.info, log: log, "updating collection")
            self.collection = collection
        }
    }
}

// MARK: - SoundFonts Protocol

extension SoundFontsManager: SoundFonts {

    public var count: Int { collection.count }

    public func index(of uuid: UUID) -> Int? { collection.index(of: uuid) }

    public func getBy(index: Int) -> SoundFont { collection.getBy(index: index) }

    public func getBy(key: SoundFont.Key) -> SoundFont? { collection.getBy(key: key) }

    @discardableResult
    public func add(url: URL) -> Result<(Int, SoundFont), SoundFont.Failure> {
        switch SoundFont.makeSoundFont(from: url, saveToDisk: true) {
        case .failure(let failure): return .failure(failure)
        case.success(let soundFont):
            let index = collection.add(soundFont)
            save()
            notify(.added(new: index, font: soundFont))
            return .success((index, soundFont))
        }
    }

    public func remove(index: Int) {
        guard let soundFont = collection.remove(index) else { return }
        save()
        notify(.removed(old: index, font: soundFont))
    }

    public func rename(index: Int, name: String) {
        let (newIndex, soundFont) = collection.rename(index, name: name)
        save()
        notify(.moved(old: index, new: newIndex, font: soundFont))
    }

    public var hasAnyBundled: Bool {
        let bundle = Bundle(for: SoundFontsManager.self)
        let urls = bundle.paths(forResourcesOfType: "sf2", inDirectory: nil).map { URL(fileURLWithPath: $0) }
        let result = urls.first { collection.index(of: $0) != nil } != nil
        return result
    }

    public var hasAllBundled: Bool {
        let bundle = Bundle(for: SoundFontsManager.self)
        let urls = bundle.paths(forResourcesOfType: "sf2", inDirectory: nil).map { URL(fileURLWithPath: $0) }
        let result = urls.first { collection.index(of: $0) == nil } == nil
        return result
    }

    public func removeBundled() {
        os_log(.info, log: log, "removeBundled")
        let bundle = Bundle(for: SoundFontsManager.self)
        let urls = bundle.paths(forResourcesOfType: "sf2", inDirectory: nil).map { URL(fileURLWithPath: $0) }
        for url in urls {
            if let index = collection.index(of: url) {
                os_log(.info, log: log, "removing %s", url.absoluteString)
                remove(index: index)
            }
        }
        save()
    }

    public func restoreBundled() {
        os_log(.info, log: log, "restoreBundled")
        let bundle = Bundle(for: SoundFontsManager.self)
        let urls = bundle.paths(forResourcesOfType: "sf2", inDirectory: nil).map { URL(fileURLWithPath: $0) }
        for url in urls {
            if collection.index(of: url) == nil {
                os_log(.info, log: log, "restoring %s", url.absoluteString)
                let soundFont = Self.addFromBundle(url: url)
                let index = collection.add(soundFont)
                notify(.added(new: index, font: soundFont))
            }
        }
        save()
    }

    /**
     Copy all of the known SF2 files to the local document directory.
     */
    public func exportToLocalDocumentsDirectory() -> (good: Int, total: Int) {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: fm.sharedDocumentsDirectory.path) else {
            return (good: 0, total: 0)
        }

        var good = 0
        var bad = 0
        for path in contents {
            if path.hasSuffix(SoundFont.soundFontDottedExtension) {
                let src = fm.sharedDocumentsDirectory.appendingPathComponent(path)
                let pos = path.lastIndex(of: "_") ?? path.endIndex
                let dst = fm.localDocumentsDirectory.appendingPathComponent(
                    String(path.prefix(upTo: pos)).appending(SoundFont.soundFontDottedExtension))
                do {
                    os_log(.info, log: Self.log, "removing '%s' if it exists", dst.path)
                    try? fm.removeItem(at: dst)
                    os_log(.info, log: Self.log, "copying '%s' to '%s'", src.path, dst.path)
                    try fm.copyItem(at: src, to: dst)
                    good += 1
                } catch let error as NSError {
                    os_log(.error, log: Self.log, "%s", error.localizedDescription)
                    bad += 1
                }
            }
        }
        return (good: good, total: good + bad)
    }

    /**
     Copy all of the known SF2 files to the local document directory.
     */
    public func importFromLocalDocumentsDirectory() -> (good: Int, total: Int) {
        let fm = FileManager.default
        guard let contents = try? fm.contentsOfDirectory(atPath: fm.localDocumentsDirectory.path) else {
            return (good: 0, total: 0)
        }

        var good = 0
        var bad = 0
        for path in contents {
            if path.hasSuffix(SoundFont.soundFontDottedExtension) {
                let src = fm.localDocumentsDirectory.appendingPathComponent(path)
                switch add(url: src) {
                case .success: good += 1
                case .failure: bad += 1
                }
            }
        }

        return (good: good, total: good + bad)
    }
}

extension SoundFontsManager {

    private static let niceNames = [
        "Fluid": "Fluid R3", "Free Font": "FreeFont", "GeneralUser": "MuseScore", "User": "Roland"
    ]

    @discardableResult
    fileprivate static func addFromBundle(url: URL) -> SoundFont {
        guard let info = SoundFontInfo.load(url) else { fatalError() }
        guard let infoName = info.embeddedName else { fatalError() }
        if infoName.isEmpty || info.patches.isEmpty { fatalError() }
        let displayName = niceNames.first { (key, _) in info.embeddedName.hasPrefix(key) }?.value ?? infoName
        return SoundFont(displayName, soundFontInfo: info, resource: url)
    }

    /**
     Save the current collection to disk.
     */
    private func save() {
        do {
            let data = try PropertyListEncoder().encode(collection)
            let log = self.log
            os_log(.info, log: log, "archiving")
            DispatchQueue.global(qos: .userInitiated).async {
                os_log(.info, log: log, "obtained archive")
                do {
                    os_log(.info, log: log, "trying to save to '%s'", Self.sharedArchivePath.path)
                    try data.write(to: Self.sharedArchivePath, options: [.atomicWrite, .completeFileProtection])
                    self.sharedStateMonitor.notifySoundFontsChanged()
                    os_log(.info, log: log, "saving OK")
                } catch {
                    os_log(.error, log: log, "saving FAILED")
                }
            }
        } catch {
            os_log(.error, log: log, "archiving FAILED")
        }
    }
}
