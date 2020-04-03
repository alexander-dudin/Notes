//
//  PhotoDetailsViewController.swift
//  Notes
//
//  Created by Alexander Dudin on 13/03/2020.
//  Copyright © 2020 Alexander Dudin. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    private var imageViews = [UIImageView]()
    private var scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var startPage: Int?
    private var currentPage: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isPagingEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        pageControl.numberOfPages = imageViews.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pageControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for (index, imageView) in imageViews.enumerated() {
            imageView.frame.size = scrollView.frame.size
            imageView.frame.origin.x = scrollView.frame.width * CGFloat(index)
            imageView.frame.origin.y = 0
        }
        
        let contentWidth = scrollView.frame.width * CGFloat(imageViews.count)
        let contentHeight = scrollView.frame.height       
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        if let firstPage = startPage {
            scrollToPage(pageNumber: firstPage, animated: false)
            currentPage = startPage
            startPage = nil
        } else if let page = currentPage {
            scrollToPage(pageNumber: page, animated: true)
        }
    }
    
    func createImageViews(forImages images: [UIImage], firstPage: Int) {
        for image in images {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageViews.append(imageView)
            scrollView.addSubview(imageView)
        }
    }
    
    func setStratingPage(at page: Int) {
        startPage = page
    }
    
    private func scrollToPage(pageNumber: Int, animated: Bool) {
        var frame = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
}

extension PhotoDetailsViewController: UIScrollViewDelegate {    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = (scrollView.contentOffset.x / scrollView.frame.width)
        let roundedPageIndex = Int(pageIndex.rounded())
        pageControl.currentPage = roundedPageIndex
        currentPage = roundedPageIndex
    }
}
