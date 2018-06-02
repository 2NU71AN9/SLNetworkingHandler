//
//  SLError.swift
//  RxSwiftDemo
//
//  Created by X.T.X on 2017/6/10.
//  Copyright © 2017年 shiliukeji. All rights reserved.
//

import Foundation

public enum SLError: Swift.Error {
    case SLRequestFailed(error: Error?) //网络请求失败
    case SLNoDataOrDataParsingFailed(error: Error?) //无返回数据或数据解析失败
    case SLOperationFailure(resultCode: Int?, resultMsg: String?) //操作失败
    case SLLogout //登出
    case SLFailed(error: Error?) // 失败
    case SLFailedNormal(error: String?) //普通失败
}

// MARK: - 输出error详细信息
extension SLError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .SLRequestFailed(let error):
            return "========>>> 网络请求失败: \(String(describing: error)) <<<========"
        case .SLNoDataOrDataParsingFailed(let error):
            return "========>>> 无返回数据或数据解析失败: \(String(describing: error)) <<<========"
        case .SLOperationFailure(let resultCode, let resultMsg):
            guard let resultCode = resultCode,
                let resultMsg = resultMsg else {
                    return "========>>> 操作失败 <<<========"
            }
            return "========>>> 错误码: " + String(describing: resultCode) + ", 错误信息: " + resultMsg + " <<<========"
        case .SLLogout:
            // FIXME: - =======进行登出操作======
            return "========>>> 登录过期,需登出 <<<========"
        case .SLFailed(let error):
            return "========>>> 失败: \(String(describing: error)) <<<========"
        case .SLFailedNormal(let error):
            return "========>>> \(String(describing: error)) <<<========"
        }
    }
}
