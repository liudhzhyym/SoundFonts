// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

/**
 Generates swipe actions that act on SoundFont instances.
 */
public protocol FontEditorActionGenerator {

    /**
     Obtain a swip action that will edit a SoundFont instance.

     - parameter cell: the table cell to attach to
     - parameter soundFont: the SoundFont instance that will be edited
     - returns: new swipe action
     */
    func createEditSwipeAction(at: IndexPath, cell: TableCell, soundFont: LegacySoundFont) -> UIContextualAction

    /**
     Obtain a swip action that will delete a SoundFont instance.

     - parameter view: the table cell to attach to
     - parameter soundFont: the SoundFont instance that will be edited
     - parameter indexPath: location of the cell to be deleted
     - returns: new swipe action
     */
    func createDeleteSwipeAction(at: IndexPath, cell: TableCell, soundFont: LegacySoundFont)
        -> UIContextualAction
}
