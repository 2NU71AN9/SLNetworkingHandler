//
//  SLUIView+Extension.swift
//  MRA
//
//  Created by X.T.X on 2017/10/23.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import Then
import RxCocoa
import Kingfisher

// MARK: - =============UIView=============

/**
 设置和获取UIView的frame
 */
public extension UIView {
    
    /// 设置frame的x
    ///
    /// - Parameter x: x
    func sl_x(x: CGFloat) { frame.origin.x = x }
    
    /// 设置frame的y
    ///
    /// - Parameter y: y
    func sl_y(y: CGFloat) { frame.origin.y = y }
    
    /// 设置frame的宽度
    ///
    /// - Parameter width: 宽
    func sl_width(width: CGFloat) { frame.size.width = width }
    
    /// 设置frame的高度
    ///
    /// - Parameter height: 高
    func sl_height(height: CGFloat) { frame.size.height = height }
    
    /// 获取frame的x
    var sl_x: CGFloat { return frame.origin.x }
    
    /// 获取frame的y
    var sl_y: CGFloat { return frame.origin.y }
    
    /// 获取frame的宽度
    var sl_width: CGFloat { return frame.size.width }
    
    /// 获取frame的高度
    var sl_height: CGFloat { return frame.size.height }
    
    /// 获取frame的maxX
    var sl_MaxX: CGFloat { return sl_x + sl_width }
    
    /// 获取frame的maxY
    var sl_MaxY: CGFloat { return sl_y + sl_height }
    
    /// 在屏幕上的位置
    var sl_frameToWindow: CGRect {
        let window = UIApplication.shared.windows[0]
        let rect = self.convert(bounds, to: window)
        return rect
    }
}

// MARK: - 裁切
public extension UIView {
    
    /// 裁切圆角
    ///
    /// - Parameter radius: 弧度
    func sl_clip(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    /// 设置阴影
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - opacity: 透明度
    ///   - offset: 偏移量
    func sl_setShadow(color: UIColor, opacity: Float, offset: CGSize = CGSize(width: 0, height: 0)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
    }
    
    /// 设置边框
    ///
    /// - Parameters:
    ///   - width: 边框宽度
    ///   - color: 边框颜色
    ///   - radius: 弧度
    func sl_setBorder(width: CGFloat, color: UIColor, radius: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        sl_clip(radius: radius)
    }
    
    /// 从xib加载view
    ///
    /// - Returns: view
    static func loadNib() -> UIView? {
        return Bundle.main.loadNibNamed("\(self)", owner: nil, options: nil)?.first as? UIView
    }
}

// MARK: - =============UIImageView=============

public extension UIImageView {
    
    /// 设置头像图片,大小是ImageView的大小
    ///
    /// - Parameter image: image
    func sl_HeadImage(image: UIImage?) {
        guard let image = image else { return }
        self.image = image.sl_image(size: bounds.size, circular: true)
    }
    
    /// 设置普通图片,大小是ImageView的大小
    ///
    /// - Parameter image: 图片
    func sl_image(image: UIImage?) {
        guard let image = image else { return }
        self.image = image.sl_image(size: bounds.size)
    }
    
    /// 设置网络图片
    ///
    /// - Parameters:
    ///   - urlStr: url
    ///   - placeholderImage: 占位图片
    ///   - isAvatar: 是否是圆形图片
    func sl_setImage(urlStr: String?, placeholderImage: UIImage?, isAvatar: Bool = false) {
        guard let urlStr = urlStr,
            let url = URL(string: urlStr) else {
                image = placeholderImage?.sl_image(size: bounds.size, circular: isAvatar)
                return
        }
        kf.setImage(with: url, placeholder: placeholderImage, options: [], progressBlock: nil) { [weak self] (image, _, _, _) in
            self?.image = image?.sl_image(size: self?.bounds.size, circular: isAvatar)
        }
    }
}

// MARK: - =============UITextField=============

public extension UITextField {
    
    /// 添加弹回键盘按钮
    func setCompleteBtn() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        let btn = UIButton()
        btn.setTitle("完成", for: .normal)
        btn.sizeToFit()
        btn.setTitleColor(UIColor.red, for: .normal)
        btn.addTarget(self, action: #selector(completeBtnAction), for: .touchUpInside)
        
        let barBtn = UIBarButtonItem(customView: btn)
        toolBar.items = [UIBarButtonItem(), UIBarButtonItem(), barBtn]
        inputAccessoryView = toolBar
    }
    
    /// 点击弹回键盘
    @objc private func completeBtnAction() {
        resignFirstResponder()
    }
}

class SLNoPasteTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(paste(_:)):
            return false //粘贴
        case #selector(select(_:)):
            return false //选择
        case #selector(selectAll(_:)):
            return false //全选
        case #selector(cut(_:)):
            return false //剪切
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
}

public extension UITextField {
    
    /// 限制输入框的可输入的最大长度
    func setTextMaxCount(_ count: Int) {
        _ = rx.text.orEmpty
            .subscribe(onNext: {[weak self] (text) in
                if text.sl_length > count {
                    var str = text
                    str.removeLast()
                    self?.text = str
                }
            })
    }
    
//    /// 通过runtime添加属性
//    fileprivate struct RuntimeKey {
//        static var maxLengthKey: Int?
//    }
//
//    /// 限制输入框的可输入的最大长度
//    var sl_MaxLength: Int? {
//        /// 使用运行时添加属性
//        set {
//            if let newValue = newValue {
//                objc_setAssociatedObject(self, &RuntimeKey.maxLengthKey, newValue as Int?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//                autocorrectionType = .no
//                autocapitalizationType = .none
//                delegate = self as? UITextFieldDelegate
//            }
//        }
//        get {
//            return objc_getAssociatedObject(self, &RuntimeKey.maxLengthKey) as? Int
//        }
//    }
}

// MARK: - =============UITextView=============

public extension UITextView {
    
    /// 设置textView的placeholer,在设置完textview的frame,textAlignment,font后使用
    ///
    /// - Parameters:
    ///   - text: 提示内容
    ///   - topGap: 距离顶部的距离
    func sl_placeholder(_ text: String?, topGap: CGFloat? = 4) {
        guard let text = text else { return }
        let textLabel = UILabel().then {
            $0.text = text
            $0.font = font
            $0.textAlignment = textAlignment
            $0.textColor = UIColor.lightGray
            $0.isHidden = hasText
            addSubview($0)
            $0.snp.makeConstraints{ make in
                make.top.equalToSuperview().offset(topGap!)
                make.centerX.equalToSuperview()
                make.size.equalTo(contentSize)
                switch textAlignment {
                case .left:
                    make.leading.equalToSuperview().offset(4)
                case .center:
                    make.centerX.equalToSuperview()
                case .right:
                    make.trailing.equalToSuperview().offset(-4)
                default:
                    make.leading.equalToSuperview().offset(4)
                }
            }
        }
        _ = rx.text.orEmpty.subscribe { [weak self] (event) in
            textLabel.isHidden = self?.hasText ?? true
        }
    }
}

// MARK: - =============UIButton=============

/// button中图片的位置枚举
///
/// - left: 图片在左
/// - right: 图片在右
/// - top: 图片在上
/// - bottom: 图片在下
public enum ImagePosition {
    case left
    case right
    case top
    case bottom
}

/// 设置button中图片的位置
public extension UIButton {
    
    /// 创建带图片的按钮
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - image: 图片
    ///   - state: 状态
    ///   - space: 图片与文字间距
    ///   - position: 图片的位置
    func sl_setPosition(title: String?, image: UIImage?, state: UIControlState = .normal, space: CGFloat = 10, position: ImagePosition = .left) {
        
        imageView?.contentMode = .center
        setImage(image, for: state)
        titleLabel?.contentMode = .center
        setTitle(title, for: state)
        
        setEdgeInsets(title: title ?? "", space: space, position: position)
    }
    
    /// 修改图片位置
    ///
    /// - Parameters:
    ///   - title: 文字
    ///   - space: 间距
    ///   - position: 图片的位置
    private func setEdgeInsets(title: String, space: CGFloat, position: ImagePosition) {
        
        guard let imageSize = imageView?.frame.size,
            let titleFont = titleLabel?.font else { return }
        let titleSize = title.size(withAttributes: [NSAttributedStringKey.font: titleFont])
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        
        switch position {
            
        case .bottom:
            titleInsets = UIEdgeInsets(top: -(imageSize.height + titleSize.height + space),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .top:
            titleInsets = UIEdgeInsets(top: (imageSize.height + titleSize.height + space),
                                       left: -(imageSize.width), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -titleSize.width)
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: -(imageSize.width * 2), bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0,
                                       right: -(titleSize.width * 2 + space))
        case .left:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -space)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        titleEdgeInsets = titleInsets
        imageEdgeInsets = imageInsets
    }
}

public extension UIButton {
    /// 设置文字和文字颜色
    func sl_setTitleWithTitleColor(title: String, color: UIColor, state: UIControlState = .normal) {
        setTitle(title, for: state)
        setTitleColor(color, for: state)
    }
}

// MARK: - =============UILabel=============

public extension UILabel {
    
    /// label添加中划线
    ///
    /// - Parameter text: 文字
    func centerLineText(text: String, value: Int = 2) {
        let arrText = NSMutableAttributedString(string: text)
        // value 越大,划线越粗
        arrText.addAttribute(NSAttributedStringKey.strikethroughStyle, value:value, range:  NSMakeRange(0, arrText.length))
        attributedText = arrText
    }
}
