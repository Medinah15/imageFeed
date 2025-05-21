//
//  ImagesListCell.swift
//  imageFeed
//
//  Created by Medina Huseynova on 27.01.25.

import UIKit

public protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

public final class ImagesListCell: UITableViewCell {
    
    // MARK: - Static properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - Delegate
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - @IBOutlet properties
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Actions
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Lifecycle
    public override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask() 
        cellImage.image = nil
        likeButton.setImage(nil, for: .normal)
        dateLabel.text = nil
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "like_button_on" : "like_button_off"
        likeButton.setImage(UIImage(named: likeImageName), for: .normal)
    }
}

