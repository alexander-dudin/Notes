//
//  PhotoGalleryViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 10/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit
import CocoaLumberjack

//MARK: - Identifiers, Names And Other String Constants
private let reuseIdentifier = "PhotoCollectionViewCell"
private let imagesNames = ["meme1.jpeg", "meme2.jpg", "meme3.jpeg", "meme4.jpg", "meme5.jpeg"]

class PhotoGalleryViewController: UIViewController {
    private var imageArray = [UIImage]()
    
    @IBOutlet private weak var deleteButton: UIBarButtonItem!
    @IBOutlet private weak var addButton: UIBarButtonItem!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBAction private func deleteButtonPressed(_ sender: UIBarButtonItem) {
        if let selected = collectionView.indexPathsForSelectedItems {
            let items = selected.map { $0.item}.sorted().reversed()
            for item in items {
                imageArray.remove(at: item)
            }
            collectionView.deleteItems(at: selected)
        }
        navigationController?.isToolbarHidden = true
    }
    
    @IBAction private func addButtonPressed(_ sender: UIBarButtonItem) {
        let imagePickerController = setupImagePickerViewController()        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()       
    }
    
    //MARK: Utility methods
    
    private func configureCell(for cell: UICollectionViewCell, at indexPath: IndexPath) {
        let customCell = cell as! PhotoCollectionViewCell
        customCell.mainImageView.image = imageArray[indexPath.row]
        customCell.isEditing = isEditing
    }
    
    private func ItemTapped(with index: Int) {
        if !isEditing {
            let photoDetailsViewController = PhotoDetailsViewController()
            photoDetailsViewController.createImageViews(forImages: imageArray, firstPage: index)
            photoDetailsViewController.setStratingPage(at: index)
            navigationController?.pushViewController(photoDetailsViewController, animated: true)
        } else {
            navigationController?.isToolbarHidden = false
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addButton.isEnabled = !editing
        collectionView.allowsMultipleSelection = editing
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
            cell.isEditing = editing
        }
        if !editing {
            navigationController?.isToolbarHidden = true
        }
    }
    
    //MARK: Setup View Controllers Methods
    
    private func setupViewController() {
        navigationController?.isToolbarHidden = true
        imageArray = imagesNames.compactMap { UIImage(named: $0) }
                
        self.collectionView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = CGSize(width: width, height: width)
        collectionView.reloadData()
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func setupImagePickerViewController() -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        return imagePickerController
    }
}

// MARK: Extension: UICollectionViewDataSource

extension PhotoGalleryViewController: UICollectionViewDataSource {    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        configureCell(for: cell, at: indexPath)
        return cell
    }
}

// MARK: Extension: UICollectionViewDelegate

extension PhotoGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItemIndex = indexPath.row
        
        ItemTapped(with: selectedItemIndex)
    } 
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0 {
                navigationController?.isToolbarHidden = true
            }
        }
    }
}

// MARK: Extension: UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PhotoGalleryViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer { picker.dismiss(animated: true) }
        guard let image = info[.originalImage] as? UIImage else { return }
        imageArray.append(image)
        collectionView.insertItems(at: [IndexPath(item: imageArray.count - 1, section: 0)])
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
