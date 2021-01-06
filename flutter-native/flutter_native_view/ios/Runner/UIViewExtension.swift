import UIKit
import Foundation

extension UIView {
    //单击事件
    typealias OnClickListener = (UIView) -> Void
    //长按事件
    typealias OnLongPressListener = (UIView) -> Void
    
    private struct AssociatedKeys {
        static var clickKey = "UIView.click"
        static var longPressKey = "UIView.onpress"
    }

    var clickListener: OnClickListener? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.clickKey) as? OnClickListener
        }
        set (listener) {
            objc_setAssociatedObject(self, &AssociatedKeys.clickKey, listener, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var longPressListener: OnLongPressListener? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.longPressKey) as? OnLongPressListener
        }
        set (listener) {
            objc_setAssociatedObject(self, &AssociatedKeys.longPressKey, listener, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addOnClick(listener: OnClickListener?) -> Void {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(onClick))
        tapGes.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGes)
        self.isUserInteractionEnabled = true
        clickListener = listener
    }
    
    func addOnLongPress(listener: OnLongPressListener?) -> Void {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
        longPress.minimumPressDuration = 1
        self.addGestureRecognizer(longPress)
        self.isUserInteractionEnabled = true
        longPressListener = listener
    }
    
    @objc func onClick(sender: UITapGestureRecognizer) -> Void {
        if let listener = clickListener {
            listener(self)
        }
    }
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer) -> Void {
        print(sender.state);
        if (sender.state == UIGestureRecognizer.State.began) {
            if let listener = longPressListener {
                listener(self)
            }
        }
    }
}
