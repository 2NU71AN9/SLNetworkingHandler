//
//  SLAPIService.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/5/25.
//  Copyright © 2018年 KK. All rights reserved.
//

import Foundation
import Moya

public enum SLAPIService {
    case loadCarBrand
}

extension SLAPIService: TargetType {
    public var baseURL: URL {
        return URL(string: isRelease ? releaseUrl : debugUrl)!
    }
    
    public var path: String {
        switch self {
        case .loadCarBrand:
            return "getXcbrand"
        default:
            return ""
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    /// 单元测试用
    public var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    public var task: Task {
        return .requestParameters(parameters: parameters,
                                  encoding: parameterEncoding)
    }
    
    public var headers: [String : String]? {
        return [
            "Content-Type" : "application/x-www-form-urlencoded"
        ]
    }
    
    ///
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    /// 参数
    public var parameters: [String: Any] {
        return [:]
    }
    
    /// 网络请求时是否显示loading...
    public var showStats: Bool {
        return true
    }
}
