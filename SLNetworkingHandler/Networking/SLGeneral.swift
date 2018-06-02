//
//  SLGeneral.swift
//  MRA
//
//  Created by X.T.X on 2017/10/23.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import UIKit

// MARK: - =============屏幕相关=============

/// 屏幕宽度
public var SCREEN_WIDTH: CGFloat { return UIScreen.main.bounds.width }
/// 屏幕高度
public var SCREEN_HEIGHT: CGFloat { return UIScreen.main.bounds.height }
/// 屏幕分辨率
public var SCREEN_SCALE: CGFloat { return UIScreen.main.scale }
/// 屏幕大小
public var SCREEN_BOUNS: CGRect { return UIScreen.main.bounds }
/// 屏幕中心点
public var SCREEN_CENTER: CGPoint { return CGPoint(x: SCREEN_WIDTH/2, y: SCREEN_HEIGHT/2) }
/// 屏幕适配
public extension Int {
    /// 屏幕宽度
    var W: CGFloat { return SCREEN_WIDTH/375*CGFloat(self) }
    /// 屏幕高度
    var H: CGFloat { return SCREEN_HEIGHT/667*CGFloat(self) }
}
/// 屏幕适配
public extension CGFloat {
    /// 屏幕宽度
    var W: CGFloat { return SCREEN_WIDTH/375*self }
    /// 屏幕高度
    var H: CGFloat { return SCREEN_HEIGHT/667*self }
}
/// 是否是iPhoneX
public var isiPhoneX: Bool { return UIScreen.main.bounds.height == 812 }

// MARK: - =============frame相关=============

/// 电池栏高度 普通20 iPhoneX 40
public let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
/// 导航栏高度 普通64 iPhoneX 88
public let naviCtrHeight: CGFloat = statusBarHeight + 44
/// tabBar高度
public let tabBarHeight:CGFloat = isiPhoneX ? 83 : 49
/// 可绘制区域,不带tabbar
public let sl_frame_draw = CGRect(x: 0, y: naviCtrHeight, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - naviCtrHeight)
/// 可绘制区域,带tabbar
public let sl_frame_drawWithTabbar = CGRect(x: 0, y: naviCtrHeight, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - naviCtrHeight - tabBarHeight)

// MARK: - =============通知相关=============

/// 用户退出登录通知
public let UserSignOutNotification = "UserSignOutNotification"
/// 用户登录成功通知
public let UserLoginSuccessedNotification = "UserLoginSuccessedNotification"
///
public let PaySuccessNotification = "PaySuccessNotification"

// MARK: - =============别名相关=============

/// 字典别名
//public typealias Dictionary = [String:Any]
/// 字典数组别名
//public typealias ArrayDict = [Dictionary]

// MARK: - =============字符串相关=============

public extension String {
    
    /// 判断字符串是否是身份证
    var isID: Bool {
        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let test: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    /// 判断字符串是否是手机号
    var isPhone: Bool {
        let regex = "^1[3|4|5|7|8][0-9]{9}$"
        let test: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    /// 判断字符串是否是邮箱
    var isMail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let test: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    /// 判断是不是车牌号
    var isCarno: Bool {
        let regex = "^[京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼使领A-Za-z]{1}[A-Za-z]{1}[A-Za-z0-9]{4}[A-Za-z0-9挂学警港澳]{1}$"
        let test: NSPredicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
    
    /// 获取字符串长度
    var sl_length: Int { return (self as NSString).length }
    
    /// 去掉空格
    var sl_noSpace: String {
        let whitespace = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: whitespace)
    }
    
    /// 判断字符串是否为空
    var sl_isEmpty: Bool { return isEmpty || sl_length == 0 }
    
    /// 字符串去null
    var sl_noNull: String { return isEmpty || sl_length == 0 ? "" : self }
    
    /// 判断是否是中文
    func sl_isChinese() -> Bool {
        
        let pred = NSPredicate(format: "SELF MATCHES %@", "(^[\u{4e00}-\u{9fa5}]+$)")
        return pred.evaluate(with:self)

        // 下面方法不准确
//        if self.sl_length < 100 {
//            if let str = CFStringTokenizerCopyBestStringLanguage(self as CFString!, CFRange(location: 0, length: self.sl_length)) as String? {
//                return str == "zh-Hans"
//            }
//            return false
//        }else{
//            if let str = CFStringTokenizerCopyBestStringLanguage(self as CFString!, CFRange(location: 0, length: 100)) as String? {
//                return str == "zh-Hans"
//            }
//            return false
//        }
    }
    
    /// 中文转拼音
    func sl_chineseToPinYin() -> String {
        //转化为可变字符串
        let mString = NSMutableString(string: self)
        //转化为带声调的拼音
        CFStringTransform(mString, nil, kCFStringTransformToLatin, false)
        //转化为不带声调
        CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)
        //转化为不可变字符串
        let string = NSString(string: mString)
        //去除字符串之间的空格
        return string.replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - =============命名空间相关=============

public extension Bundle {
    /// 返回命名空间
    var namespace: String { return infoDictionary?["CFBundleName"] as? String ?? "" }
}

// MARK: - =============类型转换相关=============

public extension Int {
    /// Int -> String
    var sl_ToString: String { return String(describing: self) }
}
public extension Double {
    /// Double -> String
    var sl_ToString: String { return String(describing: self) }
}

/**
 时间转换
 */
/// 日期格式化器 - 不要频繁的释放和创建，会影响性能
private let dateFormatter = DateFormatter()

public extension String {
    
    /// 时间戳 转 0000-00-00 00:00:00
    ///
    /// - Parameter timeStamp: 时间戳
    /// - Returns: 年月日时分秒
    var SL_TimeStampToData: String {
        let timeSta: TimeInterval = (self as NSString).doubleValue
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: timeSta)
        return dateFormatter.string(from: date)
    }
    
    /// 月份转时间Date
    var sl_stringMonthToDate: Date? {
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.date(from: self)
    }
}

public extension Date {
    /// 时间转换成年月
    var sl_month: String {
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.string(from: self)
    }
}

// MARK: - =============日期相关=============

public extension Date {
    
    /// 获取当前年
    var sl_nowYear: Int {
        let curCalendar: Calendar = Calendar.current
        let year: Int = curCalendar.component(.year, from: self)
        return year
    }
    
    /// 获取当前月
    var sl_nowMonth: Int {
        let curCalendar: Calendar = Calendar.current
        let month: Int = curCalendar.component(.month, from: self)
        return month
    }
    
    /// 获取当前日
    var sl_nowDay: Int {
        let curCalendar: Calendar = Calendar.current
        let day: Int = curCalendar.component(.day, from: self)
        return day
    }
}

// MARK: - =============颜色相关=============

public extension UIColor {
    
    /// 十六进制颜色
    ///
    /// - Parameter hex: 16进制的数字
    /// - Returns: UIColor
    class func sl_hexColor(hex: uint) -> UIColor {
        let r = (hex & 0xff0000) >> 16
        let g = (hex & 0x00ff00) >> 8
        let b = hex & 0x0000ff
        return sl_RGBColor(R: Float(r), G: Float(g), B: Float(b))
    }
    
    /// 随机颜色
    ///
    /// - Returns: UIColor
    class func sl_randomColor() -> UIColor {
        return sl_RGBColor(R: Float(arc4random_uniform(256)),
                           G: Float(arc4random_uniform(256)),
                           B: Float(arc4random_uniform(256)))
    }
    
    /// RGB颜色
    ///
    /// - Parameters:
    ///   - R: red
    ///   - G: green
    ///   - B: blue
    ///   - alpha: 透明度
    /// - Returns: UIColor
    class func sl_RGBColor(R: Float, G: Float, B: Float, alpha: Float = 1) -> UIColor {
        return UIColor.init(red: CGFloat(R/255.0), green: CGFloat(G/255.0), blue: CGFloat(B/255.0), alpha: 1)
    }
    
    /// 颜色生成纯色图片
    var sl_2Image: UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

/// 白灰色
public let whiteGrayColor = UIColor.sl_hexColor(hex: 0xefeff4)

// MARK: - =============UIImage相关=============

extension UIImage {
    
    /// 生成指定大小的不透明图像
    ///
    /// - Parameters:
    ///   - size: 图片大小,默认原图片的大小
    ///   - backColor: 背景颜色
    ///   - circular: 是否圆形
    /// - Returns: 生成的图片
    func sl_image(size: CGSize? = nil, backColor: UIColor = UIColor.white, circular: Bool = false) -> UIImage? {
        
        guard let size = (size != nil) ? size : self.size else { return nil }
        
        let rect = CGRect(origin: CGPoint(), size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        backColor.setFill()
        UIRectFill(rect)
        
        if circular {
            /// 创建圆形裁切区域
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
        }
        
        draw(in: rect)
        
        if circular {
            /// 加灰色外圈
            let ovalPath = UIBezierPath(ovalIn: rect)
            ovalPath.lineWidth = 2
            UIColor.lightGray.setStroke()
            ovalPath.stroke()
        }
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func base64String() -> String {
        let data = UIImagePNGRepresentation(self)
        let str = data?.base64EncodedString() ?? ""
        
//        str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }
}

// MARK: - =============获取当前显示的控制器=============

var cur_visible_vc: UIViewController? {

    weak var vc = UIApplication.shared.keyWindow?.rootViewController
    while true {
        if vc?.isKind(of: UITabBarController.self) ?? false {
            vc = (vc as? UITabBarController)?.selectedViewController
        } else if vc?.isKind(of: UINavigationController.self) ?? false {
            vc = (vc as? UINavigationController)?.visibleViewController
        } else if vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }else{
            break
        }
    }
    return vc
}

// MARK: - =============UserDefaults相关=============

extension UserDefaults {
    
    /// 保存自定义的对象,需要对象实现解归档
    ///
    /// - Parameters:
    ///   - object: 要保存的对象
    ///   - key: key
    func saveCustomObject(_ object: NSCoding, key: String) {
        let encodedObject = NSKeyedArchiver.archivedData(withRootObject: object)
        self.set(encodedObject, forKey: key)
        self.synchronize()
    }
    
    /// 根据key获取保存的对象,需要对象实现解归档
    ///
    /// - Parameters:
    ///   - type: 对象类型
    ///   - key: key
    /// - Returns: 对象
    func getCustomObject<T>(type: T.Type, forKey key: String) -> T? {
        
        let decodedObject = self.object(forKey: key) as? Data
        if let decoded = decodedObject {
            let object = NSKeyedUnarchiver.unarchiveObject(with: decoded)
            return object as? T
        }
        return nil
    }
}

extension Dictionary {
    
    /// 添加可选值
    func addOptional(_ item: [String: Any?]) -> Dictionary {
        guard let keys = Array(item.keys) as? [String],
            var dict = self as? [String: Any] else {
            return self
        }
        for key in keys {
            if item[key] != nil {
                dict[key] = item[key]!
            }
        }
        return dict as! Dictionary<Key, Value>
    }
}

