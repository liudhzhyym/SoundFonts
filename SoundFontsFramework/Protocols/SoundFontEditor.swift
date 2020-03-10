// Copyright © 2019 Brad Howes. All rights reserved.

import UIKit

/**
 Generates swipe actions that act on SoundFont instances.
 */
public protocol FontEditorActionGenerator {

    /**
     Obtain a swip action that will edit a SoundFont instance.

     - parameter view: the table cell to attach to
     - parameter soundFont: the SoundFont instance that will be edited
     - returns: new swipe action
     */
    func createEditSwipeAction(at view: UIView, with soundFont: SoundFont) -> UIContextualAction

    /**
     Obtain a swip action that will delete a SoundFont instance.

     - parameter view: the table cell to attach to
     - parameter soundFont: the SoundFont instance that will be edited
     - parameter indexPath: location of the cell to be deleted
     - returns: new swipe action
     */
    func createDeleteSwipeAction(at view: UIView, with soundFont: SoundFont, indexPath: IndexPath)
        -> UIContextualAction
}
