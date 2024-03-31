//
//  StorageManager.swift
//  TaskList
//
//  Created by Denis Denisov on 29/3/24.
//

import CoreData

final class StorageManager {
    
    var taskList: [ToDoTask] = []
    
    static let shared = StorageManager()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private init() {}
    
    func fetchData() {
        let fetchRequest = ToDoTask.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String) {
        let task = ToDoTask(context: context)
        task.title = taskName
        taskList.append(task)
        saveContext()
    }
    
    func deleteTask(at index: Int) {
        let removedTask = taskList.remove(at: index)
        context.delete(removedTask)
        saveContext()
    }
    
    func edit(_ taskName: String, at index: Int) {
        let task = taskList[index]
        task.title = taskName
        saveContext()
    }
}
