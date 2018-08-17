//
//  SLNetworkingHandler.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/5/25.
//  Copyright © 2018年 KK. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import HandyJSON
import Alamofire

public class SLNetworkingHandler {
    
    static let APIProvider = MoyaProvider<SLAPIService>(plugins: [SLShowState(),
                                                                  SLPrintParameterAndJson()])
    
    /// 网络请求
    ///
    /// - Parameter APIService: APIService枚举
    /// - Returns:
    public static func request(_ APIService: SLAPIService) -> Observable<NR> {

        return Observable<NR>.create { (observer) -> Disposable in
            
            // 从缓存获取数据
            if APIService.cacheData,
                let response = loadDataFromCacheWithTarget(APIService) {
                #if DEBUG
                print("""
                    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                    从缓存获取数据=====> \(APIService)
                    
                    """)
                #endif
                observer.onNext(response)
                observer.onCompleted()
                return Disposables.create()
            }
            
            // 从网络获取数据
            APIProvider.request(APIService) { (response) in
                switch response {
                case let .success(result):
                    // 网络请求成功
                    guard let json = try? result.mapJSON(),
                        let response = NR.deserialize(from: json as? [String: Any])
                        else {
                            observer.onNext(NR(code: HttpStatus.noDataOrDataParsingFailed.rawValue,
                                               message: nil,
                                               data: nil,
                                               error: SLError.SLNoDataOrDataParsingFailed(error: nil)))
                        return
                    }
                    observer.onNext(response)
                    observer.onCompleted()
                    break
                case let .failure(error):
                    // 网络请求失败
                    observer.onNext(NR(code: HttpStatus.requestFailed.rawValue,
                                       message: nil,
                                       data: nil,
                                       error: SLError.SLRequestFailed(error: error)))
                    observer.onCompleted()
                    break
                }
            }
            return Disposables.create()
        }
//            .debug()
            .observeOn(MainScheduler.instance)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
            .filterFailure(nil)
    }
    
    /// 从缓存获取数据
    private static func loadDataFromCacheWithTarget(_ target: SLAPIService) -> NR? {
        return nil
    }
}

/// 网络检测
public class SLNetworkStatusManager {
    
    public var networkStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    private var manager: NetworkReachabilityManager?
    
    public static let shared: SLNetworkStatusManager = {
        let shared = SLNetworkStatusManager()
        shared.manager = NetworkReachabilityManager(host: "www.baidu.com")
        return shared
    }()
    private init() {}
    
    /// 开始监测
    public func start() {
        manager?.listener = { [weak self] status in
            self?.networkStatus = status
        }
        manager?.startListening()
    }
    
    func checkNetworkStatus() {
        switch networkStatus {
        case .notReachable:
            print("当前网络=====> 无网络连接")
        case .unknown:
            print("当前网络=====> 未知网络")
        case .reachable(.ethernetOrWiFi):
            print("当前网络=====> 以太网或WIFI")
        case .reachable(.wwan):
            print("当前网络=====> 蜂窝移动网络")
        }
    }
}
