//
//  SLAPI.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/5/25.
//  Copyright © 2018年 KK. All rights reserved.
//

import Foundation
import HandyJSON

/// 网络请求返回数据结构
struct NetworkResponse: HandyJSON {
    var code: Int = 0
    var message: String?
    var data: Any?
    var error: SLError?
}

/// 各code代表什么
public enum HttpStatus: Int {
    case success = 200 // 成功
    case logout = 208 // 登出
    case requestFailed = 300 //网络请求失败
    case noDataOrDataParsingFailed = 301 //无数据或解析失败
}

/// 是否是发布版本
public let isRelease: Bool = true
/// 发布域名
public let releaseUrl = "http://www.baidu.com"
/// 测试域名
public let debugUrl = "http://www.baidu.com"
