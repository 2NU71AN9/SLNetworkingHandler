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

