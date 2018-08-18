//
//  SLCoreDataManager.swift
//  XiaocaoPlusNew
//
//  Created by X.T.X on 2018/1/29.
//  Copyright © 2018年 shiliukeji. All rights reserved.
//

import UIKit
import CoreData

class SLCoreDataManager {
    
    /*
     AppDelegate中添加以下代码
     
     func applicationWillTerminate(_ application: UIApplication) {
     SLCoreDataManager.shared.saveContext()
     }
     */
    
    /// 创建的表容器文件名称
    public var CoreDataName: String {
        return "RequestCache"
    }
    
    /// 托管对象上下文
    private var context: NSManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static let shared: SLCoreDataManager = {
        let shared = SLCoreDataManager()
        if #available(iOS 10.0, *) {
            shared.context = shared.persistentContainer.viewContext
        } else {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = shared.persistentStoreCoordinator
            shared.context = context
        }
        return shared
    }()
    private init() {}
    
    /// 获取表名对应的对象
    ///
    /// - Parameter model: 表名
    /// - Returns: 对象
    private func table2Model<T>(model: T.Type) -> T? {
        return NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(model as! AnyClass), into: context) as? T
    }
    
    /// 增 
    ///
    /// - Parameters:
    ///   - model: 要保存的对象
    ///   - content: 对象赋值
    ///   - success: 成功
    ///   - failure: 失败
    public func save<T>(model: T.Type, content: (T?) -> Void, success: (() -> Void)?, failure: ((Error) -> Void)?) {
        
        content(table2Model(model: model))
        
        do {
            try context.save()
            success?()
        } catch {
            failure?(error)
            fatalError("保存失败：\(error)")
        }
        
        /* 例子
         SLCoreDataManager.shared.save(model: User.self, content: { (user) in
         user?.id = 1
         user?.age = 18
         user?.name = "张三"
         }, success: {
         print("成功")
         }) { (error) in
         print("失败")
         }
         */
    }
    
    /// 查. 改和删可对查询出的数组里的对象进行操作,切记最后一定要保存
    ///
    /// - Parameters:
    ///   - fetchRequest: 声明数据的请求 let fetchRequest = NSFetchRequest<User>(entityName:"User") fetchRequest.fetchLimit = 10 //限定查询结果的数量 fetchRequest.fetchOffset = 0 //查询的偏移量
    ///   - predicate: 查询条件 NSPredicate(format: "id= '1' ", "")
    ///   - success: 成功 返回的闭包里包含查询到的数据,可进行'删(context.delete(user))''改(user.password = "abcd")', 完成后重新保存(try context.save())
    ///   - failure: 失败
    public func fetch<T>(table: T.Type, fetchRequestContent: ((NSFetchRequest<T>) -> Void)?,
                  predicate: () -> NSPredicate,
                  success: (([T]) -> Void)?,
                  failure: ((Error) -> Void)?) {
        
        let fetchRequest = NSFetchRequest<T>(entityName: NSStringFromClass(table as AnyClass))
        fetchRequestContent?(fetchRequest)
        
        /* 数据库操作语句
         BETWEEN 介于两者之间,包括上下限 (format: "age BETWEEN { %@ , %@ }", NSNumber(int: 24),NSNumber(int: 25))
         BEGINSWITH 左边表达式以右边表达式开头 (format: "name BEGINSWITH %@","Ja")
         CONTAINS 左边表达式包含右边表达式 (format: "name CONTAINS %@ && age >= %@", "ac",NSNumber(int: 24))
         ENDSWITH 左边表达式以右边表达式结尾
         LIKE 左边表达式和右边表达式相似（简单的正则表达式匹配，?匹配一个字符，*匹配0个或者多个字符）
         MATCHES 可以实现较为复杂的正则表达式匹配 (format: "name MATCHES ‘T[a-z]*k‘")
         用方括号加cd来不区分大小写和变音符号
         IN 左边的表达式在右边的集合里 (format: "name IN {‘Tacmk‘,‘Jack Tomphon‘}")
         */
        fetchRequest.predicate = predicate()
        
        do {
            let fetchobjects = try context.fetch(fetchRequest)
            success?(fetchobjects)
        } catch  {
            failure?(error)
            fatalError("保存失败：\(error)")
        }
        
        /* 例子
         SLCoreDataManager.shared.fetch(table: User.self, fetchRequestContent: { (request) in
         //request.fetchLimit = 3 //限定查询结果的数量
         //request.fetchOffset = 1 //查询的偏移量
         }, predicate: { () -> NSPredicate in
         return NSPredicate(format: "id= '1' ", "")
         }, success: { (array) in
         for info in array {
         //manager.context.delete(info)
         info.name = "李四"
         print(info.name)
         }
         try? SLCoreDataManager.shared.context.save()
         print("成功")
         }, failure: nil)
         */
    }
    
    /// =======================以下解决CoreData不兼容iOS8和iOS9的问题=====================
    private var applicationDocumentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var managedObjectModel: NSManagedObjectModel {
        let modelURL = Bundle.main.url(forResource: CoreDataName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }
    
    /// 持久化存储协调者，主要用于协调托管对象上下文和持久化存储区之间的关系
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        // FIXME: - **.** 保存的数据库文件
        let url = applicationDocumentsDirectory.appendingPathComponent("**.**")
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print("iOS9下创建协调者失败")
        }
        return coordinator
    }
    /// ============================================================================
    
    @available(iOS 10.0, *)
    private var persistentContainer: NSPersistentContainer {
        let container = NSPersistentContainer(name: CoreDataName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

