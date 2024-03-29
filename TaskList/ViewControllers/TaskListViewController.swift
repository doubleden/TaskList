//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 28.03.2024.
//

import UIKit

final class TaskListViewController: UITableViewController {
    private let cellID = "task"
    private let data = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        data.fetchData()
    }
    
    @objc private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            message: "What do you want to do?",
            AndPlaceholder: "New Task"
        ) { [unowned self] inputText in
            data.save(inputText)
            
            let indexPath = IndexPath(row: data.taskList.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = data.taskList[indexPath.row]
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
            data.deleteTask(at: indexPath.row)
            tableView.reloadData()
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = data.taskList[indexPath.row]
        
        showAlert(
            withTitle: "Edit Task",
            message: "What you want to change in to do?",
            AndPlaceholder: task.title ?? "") { [unowned self] inputText in
                data.edit(inputText, at: indexPath.row)
                tableView.reloadData()
            }
    }
}

// MARK: - Private Methods
private extension TaskListViewController {
    func showAlert(
        withTitle title: String,
        message: String,
        AndPlaceholder: String,
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
            textField.placeholder = AndPlaceholder
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
