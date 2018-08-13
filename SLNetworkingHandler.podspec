
Pod::Spec.new do |s|

  s.name         = "SLNetworkingHandler"
  s.version      = "1.0.0"
  s.swift_version  = "4.1"
  s.summary      = "网络请求"
  s.description  = "封装Moya+RxSwift+HandyJSON网络请求框架"
  s.homepage     = "https://github.com/2NU71AN9/SLNetworkingHandler" #项目主页，不是git地址
  s.license      = { :type => "MIT", :file => "LICENSE" } #开源协议
  s.author       = { "孙梁" => "1491859758@qq.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/2NU71AN9/SLNetworkingHandler.git", :tag => "v#{s.version}" } #存储库的git地址，以及tag值
  s.source_files  =  "SLNetworkingHandler/Networking/*.{h,m,swift}" #需要托管的源代码路径
  s.requires_arc = true #是否支持ARC
  s.dependency 'SVProgressHUD'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxDataSources'
  s.dependency 'SwiftyJSON'
  s.dependency 'Moya/RxSwift'
  s.dependency 'HandyJSON'

end
