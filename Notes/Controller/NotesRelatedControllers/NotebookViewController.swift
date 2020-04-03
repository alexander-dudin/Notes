//
//  NotebookViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 05/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit
import CocoaLumberjack

private let cellReuseIdentifier = "NotebookItem"

class NotebookViewController: UIViewController {
    private var fileNotebook = FileNotebook()
    private let authService = AuthService()
    private var first = true
 
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction private func addNote(_ sender: UIBarButtonItem) {
        let newRowIndex = fileNotebook.notes.count
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    //MARK: View Related Methods
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authService?.delegate = self
        if first {
            updateData()
        }
        first = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        setupRefreshControl()
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }    

    @objc private func updateData() {
        if let authService = authService {
            
            guard !authService.tokenIsEmpty else {
                authService.requestToken(viewController: self)
                return
            }
            
            let newQueue = OperationQueue()
            let dbQueue = OperationQueue()
            let backendQueue = OperationQueue()
            
            let loadNotesOperation = LoadNotesOperation(dbQueue: dbQueue, backendQueue: backendQueue, authService: authService)
            loadNotesOperation.completionBlock = {
                DispatchQueue.main.async {
                    if let loadedNotebook = loadNotesOperation.loadedNotebook {
                        self.fileNotebook = loadedNotebook
                        self.tableView.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    } else {
                        DDLogInfo("no loaded fileNotebook")
                        self.tableView.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
            }
            newQueue.addOperation(loadNotesOperation)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNoteSegue" {
            if let addNoteViewController = segue.destination as? NoteDetailViewController {
                addNoteViewController.delegate = self
                addNoteViewController.fileNotebook = fileNotebook
            }
        } else if segue.identifier == "EditNoteSegue" {
            if let editNoteViewController = segue.destination as? NoteDetailViewController {
                if let cell = sender as? TableViewCell,
                    let indexPath = tableView.indexPath(for: cell) {
                    let note = fileNotebook.notes[indexPath.row]
                    editNoteViewController.delegate = self
                    editNoteViewController.noteToEdit = note
                }
            }
        }
    }
}

//MARK: Extension: UITableViewDelegate

extension NotebookViewController: UITableViewDelegate {
    
    private func configureCellAttributes(for cell: UITableViewCell, at indexPath: IndexPath) {
        guard let customCell = cell as? TableViewCell else {
            DDLogError("tableView cell isn't of class TableViewCell")
            return
        }
        
        customCell.noteColorView.backgroundColor = fileNotebook.notes[indexPath.row].color
        customCell.titleLabel.text = fileNotebook.notes[indexPath.row].title
        customCell.contentLabel.text = fileNotebook.notes[indexPath.row].content
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            configureCellAttributes(for: cell, at: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "EditNoteSegue", sender: cell)
        }
    }
}

//MARK: Extension: UITableViewDataSource

extension NotebookViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNotebook.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! TableViewCell
        configureCellAttributes(for: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let authService = authService {
                let note = fileNotebook.notes[indexPath.row]
                let deleteAnimation = { tableView.deleteRows(at: [indexPath], with: .automatic)}
                let queue = OperationQueue()
                let removeNoteOperation = RemoveNoteOperation(
                    note: note,
                    notebook: fileNotebook,
                    dbQueue: queue,
                    backendQueue: queue,
                    authService: authService,
                    deleteAnimation: deleteAnimation
                )
                queue.addOperation(removeNoteOperation)
            }
        }
    }
}

//MARK: Extension: NoteDetailViewControllerDelegate

extension NotebookViewController: NoteDetailViewControllerDelegate {
    func noteDetailViewControllerDidCancel(_ controller: NoteDetailViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishAdding note: Note) {
        navigationController?.popViewController(animated: true)
        
        if let authService = authService {
            fileNotebook.add(note)
            
            let dbQueue = OperationQueue()
            let backendQueue = OperationQueue()
            let saveNoteOperation = SaveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, authService: authService)
            dbQueue.addOperation(saveNoteOperation)
            
            let rowIndex = fileNotebook.notes.count - 1
            let indexPath = IndexPath(row: rowIndex, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    func noteDetailViewController(_ controller: NoteDetailViewController, didFinishEditing note: Note) {
        navigationController?.popViewController(animated: true)
        fileNotebook.add(note)
        
        if let index = fileNotebook.notes.firstIndex(of: note), let authService = authService {
            let indexPath = IndexPath(row: index, section: 0)
            
            if let cell = tableView.cellForRow(at: indexPath) {
                configureCellAttributes(for: cell, at: indexPath)
                let dbQueue = OperationQueue()
                let backendQueue = OperationQueue()
                let saveNoteOperation = SaveNoteOperation(note: note, notebook: fileNotebook, backendQueue: backendQueue, dbQueue: dbQueue, authService: authService)
                dbQueue.addOperation(saveNoteOperation)
            }
        }
    }
}

//MARK: Extension: AuthServiceDelegate

extension NotebookViewController: AuthServiceDelegate {
    func requestUpdate() {
        updateData()
    }
}
