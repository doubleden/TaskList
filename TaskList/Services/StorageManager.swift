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
    
    let persistentContainer: NSPersistentContainer = {
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
            taskList = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    func save(_ taskName: String) {
        let task = ToDoTask(context: persistentContainer.viewContext)
        task.title = taskName
        taskList.append(task)
        saveContext()
    }
    
    func deleteTask(at index: Int) {
        let removedTask = taskList.remove(at: index)
        persistentContainer.viewContext.delete(removedTask)
        saveContext()
    }
    
    func edit(_ taskName: String, at index: Int) {
        let task = taskList[index]
        task.title = taskName
        saveContext()
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
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
