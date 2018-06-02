//
//  SLObservableExtension.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/5/25.
//  Copyright © 2018年 KK. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON
import HandyJSON

typealias NR = NetworkResponse

extension Observable where E == NR {
    
    typealias Complete = ((NR) -> Void)?
    
    
    /// JSON转Model
    ///
    /// - Parameter modelType: 要转换成的model
    /// - Returns:
    func mapModel<T: HandyJSON>(_ modelType: T.Type) -> Observable<T> {
        return map { response in
            if response.code == HttpStatus.success.rawValue {
                /// 成功
                if response.data is [String: Any] {
                    /// 如果是字典
                    guard let model = T.deserialize(from: response.data as? [String: Any])
                        else {
                            throw SLError.SLFailedNormal(error: "数据解析失败")
                    }
                    return model
                    
                }
                else {
                    throw SLError.SLFailedNormal(error: "无数据")
                }
                
            }
            else if response.code == HttpStatus.logout.rawValue {
                /// 登出
                throw SLError.SLLogout
            }
            else {
                /// 直接输出错误
                throw SLError.SLOperationFailure(resultCode: response.code,
                                                 resultMsg: response.message)
            }
            
        }.showError()
    }
    
    
    /// JSON转Model数组
    ///
    /// - Parameter modelType: 要转换成的model
    /// - Returns:
    func mapModels<T: HandyJSON>(_ modelType: T.Type) -> Observable<[T]> {
        return map { response in
            if response.code == HttpStatus.success.rawValue {
                /// 成功
                if response.data is [[String: Any]] {
                    /// 如果是数组
                    guard let models = [T].deserialize(from: response.data as? [[String: Any]]) as? [T]
                        else {
                            throw SLError.SLFailedNormal(error: "数据解析失败")
                    }
                    return models
                }
                else {
                    throw SLError.SLFailedNormal(error: "无数据")
                }
                
            }
            else if response.code == HttpStatus.logout.rawValue {
                /// 登出
                throw SLError.SLLogout
            }
            else {
                /// 直接输出错误
                throw SLError.SLOperationFailure(resultCode: response.code,
                                                 resultMsg: response.message)
            }
        }.showError()
    }
    
    
    // MARK: - ========以下暂时不用==========
    
    /// JSON转Model或Model数组
    ///
    /// - Parameters:
    ///   - modelType: 要转换成的model
    ///   - completeModels: model数组
    ///   - completeModel: model
    /// - Returns:
    private func JSON2Model<T: HandyJSON>(_ modelType: T.Type, completeModels: (([T]) -> Void)? = nil, completeModel: ((T) -> Void)? = nil) -> Observable<NR> {
        
        return map { response in
            if response.code == HttpStatus.success.rawValue {
                /// 成功
                if response.data is [String: Any] {
                    /// 如果是字典
                    guard let model = T.deserialize(from: response.data as? [String: Any])
                        else {
                            throw SLError.SLFailedNormal(error: "数据解析失败")
                    }
                    completeModel?(model)
                    return response
                    
                }
                else if response.data is [[String: Any]] {
                    /// 如果是数组
                    guard let models = [T].deserialize(from: response.data as? [[String: Any]]) as? [T]
                        else {
                            throw SLError.SLFailedNormal(error: "数据解析失败")
                    }
                    completeModels?(models)
                    return response
                    
                }
                else {
                    throw SLError.SLFailedNormal(error: "无数据")
                }
                
            }
            else if response.code == HttpStatus.logout.rawValue {
                /// 登出
                throw SLError.SLLogout
            }
            else {
                /// 直接输出错误
                throw SLError.SLOperationFailure(resultCode: response.code,
                                                 resultMsg: response.message)
            }
            }.showError()
    }
    
    
    /// 成功
    ///
    /// - Parameter complete: 成功的闭包
    /// - Returns: 
    private func isSuccess(_ complete: Complete) -> Observable<NR> {
        return map { response in
            if response.code == HttpStatus.success.rawValue {
                complete?(response)
                return response
            }
            else if response.code == HttpStatus.logout.rawValue {
                /// 登出
                throw SLError.SLLogout
            }
            else {
                /// 直接输出错误
                throw SLError.SLOperationFailure(resultCode: response.code,
                                                 resultMsg: response.message)
            }
        }.showError()
    }
    
    
    /// 过滤失败
    ///
    /// - Parameter complete: 失败的闭包
    /// - Returns:
    func filterFailure(_ complete: Complete) -> Observable<NR> {
        return map { response in
            if response.code == HttpStatus.success.rawValue {
                return response
            }
            else if response.code == HttpStatus.logout.rawValue {
                /// 登出
                let res = NR(code: response.code,
                             message: response.message,
                             data: response.data,
                             error: SLError.SLLogout)
                complete?(res)
                throw res.error!
            }
            else {
                /// 直接输出错误
                let res = NR(code: response.code,
                             message: response.message,
                             data: response.data,
                             error: response.error != nil
                                ? response.error
                                : SLError.SLOperationFailure(resultCode: response.code,
                                                             resultMsg: response.message))
                complete?(res)
                throw res.error!
            }
            }.showError()
    }
}

extension Observable {
    
    /// 输出error
    private func showError() -> Observable<E> {
        return self.do(onError: { (error) in
            print("\(error.localizedDescription)")
        })
    }
}
