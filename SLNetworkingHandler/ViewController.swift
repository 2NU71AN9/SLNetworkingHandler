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

