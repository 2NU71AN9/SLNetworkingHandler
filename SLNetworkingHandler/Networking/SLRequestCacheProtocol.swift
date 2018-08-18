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
    static func loadDataFromNetworkWithTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void)
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

            // 从缓存获取到数据, 判断是否有效
            guard let obj = array.first,
                let jsonStr = obj.response,
                let nr = NR.deserialize(from: jsonStr),
                Int64(Date().timeIntervalSince1970) - obj.timeStamp <= requestCacheValidTime
                else {
                    // 没找到数据或数据无效则进行网络请求
                    loadDataFromNetworkWithTarget(target, success: success, failure: failure)
                    return
            }
            
            success(nr)
            
            #if DEBUG
            print("""
                从缓存获取到数据=====> \(target)
                =====> \(JSON(jsonStr))
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                """)
            #endif
            
        }, failure: { _ in
            // 没找到数据则进行网络请求
            loadDataFromNetworkWithTarget(target, success: success, failure: failure)
        })
    }
    
    /// 从网络获取数据
    static func loadDataFromNetworkWithTarget(_ target: SLAPIService, success: @escaping (NR) -> Void, failure: @escaping (Error?) -> Void) {
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
                
                if target.cacheData {
                    // 更新本地保存的数据
                    let paramsStr = JSON(arrayLiteral: target.parameters).rawString() ?? ""
                    let url = String(format: "%@%@%@", target.baseURL.absoluteString, target.path, paramsStr)
                    SLCoreDataManager.shared.fetch(table: Cache.self, fetchRequestContent: { (request) in
                        request.fetchLimit = 1
                    }, predicate: { () -> NSPredicate in
                        return NSPredicate(format: "url = %@", url)
                    }, success: { (array) in
                        for cache in array {
                            cache.url = url
                            cache.timeStamp = Int64(Date().timeIntervalSince1970)
                            cache.response = JSON(json).description
                        }
                        try? SLCoreDataManager.shared.context.save()
                    }, failure: { _ in
                        SLCoreDataManager.shared.save(model: Cache.self, content: { (cache) in
                            cache?.url = url
                            cache?.timeStamp = Int64(Date().timeIntervalSince1970)
                            cache?.response = JSON(json).description
                        }, success: {
                            print("保存成功")
                        }, failure: nil)
                    })
                }
                
                break
            case let .failure(error):
                // 网络请求失败
                failure(error)
                break
            }
        }
    }
}
