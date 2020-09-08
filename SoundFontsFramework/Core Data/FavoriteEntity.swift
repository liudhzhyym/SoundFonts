// Copyright © 2020 Brad Howes. All rights reserved.

import Foundation
import CoreData
import SoundFontInfoLib

@objc(FavoriteEntity)
public class FavoriteEntity: NSManagedObject {

}

extension FavoriteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteEntity> {
        return NSFetchRequest<FavoriteEntity>(entityName: "Favorite")
    }

    public convenience init(context: NSManagedObjectContext, preset: PresetEntity, keyboardLowestNote: Int) {
        self.init(context: context)
        self.key = UUID()
        self.name = preset.name
        self.preset = preset
        self.gain = 0.0
        self.pan = 0.0
    }

    @NSManaged public private(set) var key: UUID
    @NSManaged public private(set) var name: String
    @NSManaged public private(set) var preset: PresetEntity
    @NSManaged public private(set) var gain: Float
    @NSManaged public private(set) var pan: Float
    @NSManaged public private(set) var keyboardLowestNote: Int16
}