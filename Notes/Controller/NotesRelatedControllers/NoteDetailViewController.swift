//
//  ViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 23/02/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit
import CocoaLumberjack

class NoteDetailViewController: UIViewController {
    
    //MARK: Stored Properties For Passing Data
    
    weak var delegate: NoteDetailViewControllerDelegate?
    weak var fileNotebook: FileNotebook?
    var noteToEdit: Note?
    
    //MARK: IBOutlets
    
    @IBOutlet weak var noteScrollView: UIScrollView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var noteTitleTextField: UITextField!
    @IBOutlet weak var noteContentTextView: UITextView!
    @IBOutlet weak var noteSelfDestructSwitch: UISwitch!
    @IBOutlet weak var destructionDatePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var noteColorYellow: UIView!
    @IBOutlet weak var noteColorRed: UIView!
    @IBOutlet weak var noteColorBlue: UIView!
    @IBOutlet weak var noteColorCustom: PaletteView!
    @IBOutlet weak var selectedYellowColor: SelectionMarkView!
    @IBOutlet weak var selectedRedColor: SelectionMarkView!
    @IBOutlet weak var selectedBlueColor: SelectionMarkView!
    @IBOutlet weak var selectedCustomColor: SelectionMarkView!
    
    //MARK: IBActions
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if noteSelfDestructSwitch.isOn {
            destructionDatePicker.isHidden = false
            datePickerHeight.constant = 216
        } else {
            destructionDatePicker.isHidden = true
            datePickerHeight.constant = 0
        }
    }
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        var color = UIColor.white
        guard let selectedYellowColor = selectedYellowColor,
            let selectedRedColor = selectedRedColor,
            let selectedBlueColor = selectedBlueColor,
            let selectedCustomColor = selectedCustomColor
            else {
                DDLogError("nil in SelectionColorMarkViews in doneBarButtonTapped")
                return
        }
        
        let marksArray = [selectedYellowColor, selectedRedColor, selectedBlueColor, selectedCustomColor]
        let selectedColorView = marksArray.first{ $0.isSelected == true }
        
        if let note = noteToEdit, let textFieldText = noteTitleTextField.text {
            if selectedColorView == nil {
                color = note.color
            } else {
                color = selectedColorView?.superview?.backgroundColor ?? UIColor.white
            }
            let editedNote = Note(
                uid: note.uid,
                title: textFieldText,
                content: noteContentTextView.text,
                color: color,
                importance: note.importance,
                selfDestructionDay: note.selfDestructionDay
            )
            delegate?.noteDetailViewController(self, didFinishEditing: editedNote)
        } else {
            if let textFieldText = noteTitleTextField.text {
                if selectedColorView != nil {
                    color = selectedColorView?.superview?.backgroundColor ?? UIColor.white
                }
                let note = Note(
                    title: textFieldText,
                    content: noteContentTextView.text,
                    color: color,
                    importance: .defaultPriority
                )
                delegate?.noteDetailViewController(self, didFinishAdding: note)
            }
        }
    }
    
    //MARK: Color Choosing Methods
    
    @IBAction func yellowColorTapped(_ sender: UITapGestureRecognizer) {
        handleTap(senderView: selectedYellowColor)
    }
    
    @IBAction func redColorTapped(_ sender: UITapGestureRecognizer) {
        handleTap(senderView: selectedRedColor)
    }
    
    @IBAction func blueColorTapped(_ sender: UITapGestureRecognizer) {
        handleTap(senderView: selectedBlueColor)
    }
    
    @IBAction func customColorTapped(_ sender: UITapGestureRecognizer) {
        guard let senderView = sender.view as? PaletteView else {
            DDLogError("senderView isn't PaletteView")
            return
        }
        if senderView.customColorIsSelected {
            handleTap(senderView: selectedCustomColor)
        }
    }
    
    @IBAction func customColorLongTap(_ sender: UILongPressGestureRecognizer) {
        guard let customColorSelectionViewController = storyboard?
            .instantiateViewController(withIdentifier: "colorSelection")
            as? CustomColorSelectionViewController else { return }
        
        customColorSelectionViewController.delegate = self
        if noteColorCustom.customColorIsSelected {
            customColorSelectionViewController.preSelectedCustomColor = noteColorCustom.backgroundColor
        }
        
        if sender.state == .began {
            navigationController?.pushViewController(customColorSelectionViewController, animated: true)
        }
    }
    
    //MARK: Setup methods for ViewController
    
    override func viewDidLoad() {
         super.viewDidLoad()
         noteTitleTextField.delegate = self
         noteContentTextView.delegate = self
         setupViewController()
     }
    
    private func setupViewController() {
        if let note = noteToEdit {
            title = "Edit Note"
            noteTitleTextField.text = note.title
            noteContentTextView.text = note.content
            checkColor(for: note)
            doneBarButton.isEnabled = true
        }
        if noteToEdit == nil {
            title = "Create a Note"
        }
    
        let array = [noteColorYellow, noteColorRed, noteColorBlue, noteColorCustom]
        for view in array {
            view?.layer.borderWidth = 1
            view?.layer.borderColor = UIColor.gray.cgColor
        }
        
        // Setup Observers For Keyboard Show/Hide
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustInsetForKeyboard(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: noteContentTextView
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustInsetForKeyboard(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: noteContentTextView
        )
    }
    
    private func checkColor(for note: Note) {
        let noteColor = note.color
        
        guard let selectedYellowColor = selectedYellowColor,
            let selectedRedColor = selectedRedColor,
            let selectedBlueColor = selectedBlueColor,
            let selectedCustomColor = selectedCustomColor
            else {
                DDLogError("nil in SelectionColorMarkViews in checkColor")
                return
        }
        
        let marksArray = [selectedYellowColor, selectedRedColor, selectedBlueColor, selectedCustomColor]
        
        guard let yellow = noteColorYellow.backgroundColor, let red = noteColorRed.backgroundColor, let blue = noteColorBlue.backgroundColor else {
            DDLogError("nil in colorOutlets")
            return
        }
        
        let colorsArray = [yellow, red, blue, UIColor.white]  
        
        if let colorIndex = colorsArray.firstIndex(where: { noteColor.equals($0) }) {
            let mark = marksArray[colorIndex]
            handleTap(senderView: mark)
        } else {
            noteColorCustom.backgroundColor = noteColor
            noteColorCustom.configureColorSelection()
            handleTap(senderView: selectedCustomColor)
        }
    }
    
    //MARK: Other utility methods
    
    @objc func adjustInsetForKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let show = (notification.name == UIResponder.keyboardWillShowNotification)
        
        let adjustmentHeight = (keyboardFrame.height + 20) * (show ? 1 : -1)
        noteScrollView.contentInset.bottom += adjustmentHeight
    }
    
    private func handleTap(senderView: SelectionMarkView) {
        senderView.configureSelection()
        let array = [selectedYellowColor,  selectedRedColor, selectedBlueColor, selectedCustomColor]
        if senderView.isSelected {
            for i in array where i != senderView {
                i?.deselect()
            }
        }
    }    
}

//MARK: Extension: UITextFieldDelegate

extension NoteDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text,
            let stringRange = Range(range, in: oldText) else {
                return false
        }
        
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
        return true
    }    
}

//MARK: Extension: UITextViewDelegate

extension NoteDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK: Extension: CustomColorSelectionViewControllerDelegate

extension NoteDetailViewController: CustomColorSelectionViewControllerDelegate {
    func didSetColor(_ controller: CustomColorSelectionViewController, color: UIColor) {
        navigationController?.popViewController(animated: true)
       
        if noteColorCustom.customColorIsSelected {
            noteColorCustom.backgroundColor = color
        } else {
            noteColorCustom.backgroundColor = color
            noteColorCustom.configureColorSelection()
            handleTap(senderView: selectedCustomColor)
        }
    }
}
