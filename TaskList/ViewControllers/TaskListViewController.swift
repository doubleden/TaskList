//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let cellID = "task"
    private let storageManager = StorageManager.shared
    private var taskList: [ToDoTask] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        storageManager.fetchData { [unowned self] taskList in
            self.taskList.append(contentsOf: taskList)
            tableView.reloadData()
        }
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            message: "What do you want to do?") { [unowned self] inputText in
            taskList.append(storageManager.save(inputText))
            let indexPath = IndexPath(row: taskList.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [unowned self] _, _, _ in
            storageManager.delete(taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(
            withTitle: "Edit Task",
            message: "What do you want to change in to do?") { [unowned self] inputText in
                storageManager.edit(taskList[indexPath.row], with: inputText)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Private Methods
private extension TaskListViewController {
    func showAlert(
        withTitle title: String,
        message: String,
        completion: ((_ inputText: String) -> Void)?
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let inputText = alert.textFields?.first?.text, !inputText.isEmpty else { return }
            completion?(inputText)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = title
        }
        present(alert, animated: true)
    }
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = .milkBlue
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}
