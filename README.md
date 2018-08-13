# SLNetworkingHandler
封装Moya+RxSwift+HandyJSON网络请求框架

pod 'SLNetworkingHandler'

SLNetworkingHandler
.request(.loadCarBrand)
.mapModels(Model.self) #转换数据模型，可不加
.mapSectionModel("", type: Model.self) #转成DataSource，可不加
.subscribe(onNext: { (model) in

}, onError: { (error) in

})
.disposed(by: bag)
