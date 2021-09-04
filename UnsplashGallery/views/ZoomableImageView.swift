//
//  ZoomableImageView.swift
//  UnsplashGallery
//
//  Created by Saad on 7/12/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import Foundation
import UIKit

class ZoomableImageView: UIScrollView {

    @IBInspectable
    private var imageName: String? {
        didSet {
            guard let imageName = imageName else {
                return
            }
            imageView.image = UIImage(named: imageName)
        }
    }
    
    @IBInspectable
    private var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    convenience init(named: String) {
        self.init(frame: .zero)
        self.imageName = named
    }

    private func commonInit() {
        // Setup image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        // Setup scroll view
        minimumZoomScale = 1
        maximumZoomScale = 3
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        delegate = self
        
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapRecognizer.numberOfTapsRequired = 2
            addGestureRecognizer(doubleTapRecognizer)
        }

    
        @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
            if zoomScale == 1 {
                setZoomScale(2, animated: true)
            } else {
                setZoomScale(1, animated: true)
            }
        }
}

extension ZoomableImageView: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

}
