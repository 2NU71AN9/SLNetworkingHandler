//
//  SLRequestCacheProtocol.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/8/18.
//  Copyright © 2018年 KK. All rights reserved.
//

import Foundation
import SwiftyJSON
import Moya

protocol SLRequestCacheProtocol {
    /// 从缓存获取数据
    static func loadDataFromCacheWithTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void)
    /// 从网络获取数据
    static func loadDataFromNetworkWothTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void)
}

extension SLRequestCacheProtocol where Self: SLNetworkingHandler {
    
    /// 从缓存获取数据
    static func loadDataFromCacheWithTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void) {
        
        let paramsStr = JSON(arrayLiteral: target.parameters).rawString() ?? ""
        let url = String(format: "%@%@%@", target.baseURL.absoluteString, target.path, paramsStr)
        
        SLCoreDataManager.shared.fetch(table: Cache.self, fetchRequestContent: { (request) in
            request.fetchLimit = 1
        }, predicate: { () -> NSPredicate in
            return NSPredicate(format: "url = %@", url)
        }, success: { (array) in
            
            guard let obj = array.first,
                let data = obj.response,
                let dict = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Any],
//                let json = try? response.mapJSON(),
                let nr = NR.deserialize(from: dict)
                else {
                    failure(nil)
                    return
            }
            success(nr)
            
        }, failure: { _ in
            failure(nil)
        })
    }
    
    /// 从网络获取数据
    static func loadDataFromNetworkWothTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void) {
        // 从网络获取数据
        APIProvider.request(target) { (response) in
            switch response {
            case let .success(result):
                // 网络请求成功
                guard let json = try? result.mapJSON(),
                    let dict = json as? [String: Any],
                    let response = NR.deserialize(from: dict)
                    else {
                        failure(nil)
                        return
                }
                success(response)
                
                SLCoreDataManager.shared.save(model: Cache.self, content: { (cache) in
                    let paramsStr = JSON(arrayLiteral: target.parameters).rawString() ?? ""
                    let url = String(format: "%@%@%@", target.baseURL.absoluteString, target.path, paramsStr)
                    cache?.url = url
                    cache?.response = NSKeyedArchiver.archivedData(withRootObject: dict)
                }, success: {
                    print("保存成功")
                }, failure: nil)
                
                break
            case let .failure(error):
                // 网络请求失败
                failure(error)
                break
            }
        }
    }
}
