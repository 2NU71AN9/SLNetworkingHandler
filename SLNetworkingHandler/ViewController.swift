//
//  ViewController.swift
//  SLNetworkingHandler
//
//  Created by RY on 2018/5/25.
//  Copyright © 2018年 KK. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let va = Variable(1)
        Observable.of(1).bind(to: va).disposed(by: bag)
    }
    
    @objc func test() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        SLCoreDataManager.shared.save(model: Cache.self, content: { (cache) in
//            cache?.url = "123123"
//            cache?.timeStamp = 41236741241
//            cache?.response = Data()
//        }, success: {
//            print("保存成功")
//        }) { (_) in
//            print("保存失败")
//        }
        
        
//        SLCoreDataManager.shared.fetch(table: Cache.self, fetchRequestContent: { (request) in
//            
//        }, predicate: { () -> NSPredicate in
//            return NSPredicate(format: "url= '123123' ", "")
//        }, success: { (array) in
//            for cache in array {
//                print(cache.timeStamp)
//            }
//        }) { (_) in
//            
//        }
        
        
        SLNetworkingHandler
            .request(.loadCarBrand)
            .mapModels(Model.self)
            .mapSectionModel("", type: Model.self)
            .subscribe(onNext: { (model) in
                
            }, onError: { (error) in
            })
            .disposed(by: bag)
    }
}

