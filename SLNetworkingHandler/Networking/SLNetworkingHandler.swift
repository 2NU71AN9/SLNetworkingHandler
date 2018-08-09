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

class SLNetworkingHandler {
    
    static let APIProvider = MoyaProvider<SLAPIService>(plugins: [SLShowState(),
                                                                  SLPrintParameterAndJson()])
    
    /// 网络请求
    ///
    /// - Parameter APIService: APIService枚举
    /// - Returns:
    static func request(_ APIService: SLAPIService) -> Observable<NR> {

        return Observable<NR>.create { (observer) -> Disposable in
            
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
            .filterFailure(nil)
    }
}
