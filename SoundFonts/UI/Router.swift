// Copyright © 2018 Brad Howes. All rights reserved.

import UIKit

/**
 Collection of UIViewControllers and protocol facades which helps establish inter-controller relationships during the
 application launch. Each view controller is responsible for establishing the connections in their
 `establishConnections` method. The goal should be to have relations between a controller and protocols / facades, and
 not between controllers themselves. This is enforced here through access restrictions to known controllers.
 */
final class Router {

    let soundFonts: SoundFonts = SoundFontsManager()
    let favorites: Favorites = FavoritesManager()

    lazy var activePatchManager = ActivePatchManager(soundFonts: soundFonts)
    lazy var selectedSoundFontManager = SelectedSoundFontManager(activePatchManager: activePatchManager)

    private(set) var mainViewController: MainViewController! { didSet { oneTimeSet(oldValue) } }
    private var soundFontsController: SoundFontsViewController! { didSet { oneTimeSet(oldValue) } }
    private var favoritesController: FavoritesViewController! { didSet { oneTimeSet(oldValue) } }
    private var infoBarController: InfoBarController! { didSet { oneTimeSet(oldValue) } }
    private var keyboardController: KeyboardController! { didSet { oneTimeSet(oldValue) } }

    var infoBar: InfoBar { infoBarController }
    var keyboard: Keyboard { keyboardController }
    var patchesViewManager: PatchesViewManager { soundFontsController }
    var favoritesViewManager: UpperViewSwipingActivity { favoritesController }
    var fontEditorActionGenerator: FontEditorActionGenerator { soundFontsController }

    /**
     Collect the known view controllers and track what we have.
    
     - parameter mvc: the sole MainViewController instances
     - parameter vcs: collection of other instances
     */
    func addViewControllers(_ mvc: MainViewController, _ vcs: [UIViewController]) {
        mainViewController = mvc
        for obj in vcs {
            switch obj {
            case let vc as SoundFontsViewController: soundFontsController = vc
            case let vc as FavoritesViewController: favoritesController = vc
            case let vc as InfoBarController: infoBarController = vc
            case let vc as KeyboardController: keyboardController = vc
            default: assertionFailure("unknown child UIViewController")
            }
        }

        validate()
        establishConnections()
    }

    /**
     Invoke `establishConnections` on each tracked view controller.
     */
    func establishConnections() {
        soundFontsController.establishConnections(self)
        favoritesController.establishConnections(self)
        infoBarController.establishConnections(self)
        keyboardController.establishConnections(self)
        mainViewController.establishConnections(self)
    }
}

extension Router {

    private func validate() {
        precondition(mainViewController != nil, "nil MainViewController")
        precondition(soundFontsController != nil, "nil SoundFontsViewController")
        precondition(favoritesController != nil, "nil FavoritesViewController")
        precondition(infoBarController != nil, "nil InfoBarController")
        precondition(keyboardController != nil, "nil KeyboardController")
    }

    private func oneTimeSet(_ oldValue: UIViewController?) {
        if oldValue != nil {
            preconditionFailure("expected nil value")
        }
    }
}