/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardCell: UITableViewCell {
    var containerView: UIView
    var iconView: DashboardIconView
    var stackView: UIStackView
    var errorView: DashboardErrorView
    var displayView: DashboardDisplayView
    
    override public func prepareForReuse() {
        //need to reset everything, but not remove the elements
        //remove any image if it exists,
        //remove the text if it exists, can keep the icon, and name of the cell though
        if let imageView = displayView.imageView {
            stackView.removeArrangedSubview(imageView)
        }
        stackView.removeArrangedSubview(displayView)
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconView = DashboardIconView(frame: CGRect(x: 18, y: 3, width: 74, height: 76))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        displayView = DashboardDisplayView(frame: .zero)
        displayView.translatesAutoresizingMaskIntoConstraints = false
        errorView = DashboardErrorView(frame: .zero)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        self.stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell(model: DashboardCellModel) {
        contentView.addSubview(containerView)
        
        containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 3).isActive = true
        containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 18).isActive = true
        containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -18).isActive = true
        containerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3).isActive = true
        
        containerView.addSubview(iconView)
        iconView.createAssets(iconName: model.iconPath, labelName: model.typeName)
        iconView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 3).isActive = true
        iconView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 18).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 74).isActive = true
        iconView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 3).isActive = true
        
        containerView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        
        containerView.addSubview(displayView)
        displayView.createAssets(message: nil, image: nil)
        let displayHeightConstraint = displayView.heightAnchor.constraint(greaterThanOrEqualToConstant: 58.0)
        displayHeightConstraint.isActive = true
        
        containerView.addSubview(errorView)
        errorView.createAssets(message: nil)
        let constraint = errorView.heightAnchor.constraint(equalToConstant: 24.0)
//        constraint.priority = 
        constraint.isActive = true
        
        //add items to stackView
        if let imageView = displayView.imageView {
            stackView.addArrangedSubview(imageView)
        } else {
            displayHeightConstraint.constant = 82.0
        }
        stackView.addArrangedSubview(displayView)
        stackView.addArrangedSubview(errorView)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsUpdateConstraints()
    }
}
