//
//  StorageManager.swift
//  TaskList
//
//  Created by Denis Denisov on 29/3/24.
//

import CoreData

final class StorageManager {
    
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
    
    func fetchData(_ completion: @escaping([ToDoTask]) -> Void) {
        let fetchRequest = ToDoTask.fetchRequest()
        var taskList: [ToDoTask] = []
        do {
            taskList = try context.fetch(fetchRequest)
            DispatchQueue.main.async {
                completion(taskList)
            }
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
    
    func save(_ taskName: String) -> ToDoTask {
        let task = ToDoTask(context: context)
        task.title = taskName
        saveContext()
        return task
    }
    
    func delete(_ task: ToDoTask) {
        context.delete(task)
        saveContext()
    }
    
    func edit(_ task: ToDoTask, with newTask: String) {
        task.title = newTask
        saveContext()
    }
}
