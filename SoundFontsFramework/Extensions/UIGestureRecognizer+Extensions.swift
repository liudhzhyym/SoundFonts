// Copyright © 2020 Brad Howes. All rights reserved.

import UIKit

public extension UIGestureRecognizer {

    typealias Closure = (AnyObject) -> Void

    @discardableResult
    func addClosure(for controlEvents: UIControl.Event = .touchUpInside, _ closure: @escaping Closure) -> UUID {
        let sleeve = BoxedClosure(closure)
        addTarget(sleeve, action: #selector(BoxedClosure.invoke(_:)))
        let key = UUID()
        objc_setAssociatedObject(self, "[\(key)]", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return key
    }

    func removeClosure(key: UUID, for controlEvents: UIControl.Event) {
        guard let sleeve = objc_getAssociatedObject(self, "[\(key)]") else { return }
        removeTarget(sleeve, action: nil)
        objc_setAssociatedObject(self, "[\(key)]", nil, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
}

@objc private class BoxedClosure: NSObject {
    let closure: UIGestureRecognizer.Closure
    init (_ closure: @escaping UIGestureRecognizer.Closure) { self.closure = closure }
    @objc func invoke(_ sender: AnyObject) { closure(sender) }
}
