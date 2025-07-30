//
//  TransactionCell.swift
//  Finances
//
//  Created by Felipe Felicio on 17/07/25.
//

import UIKit

protocol TransactionCellDelegate: AnyObject {
    func didTapDelete(on cell: TransactionCell)
}

class TransactionCell: UITableViewCell {

    static let identifier = "TransactionCell"

    // Delegate
    weak var delegate: TransactionCellDelegate?

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.backgroundColor = AppColors.gray200.cgColor
        view.layer.cornerRadius = 6
        return view
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.magenta
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.textSm()
        label.textColor = AppColors.gray700
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.textXs()
        label.textColor = AppColors.gray500
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.titleMd()
        label.textAlignment = .right
        label.textColor = AppColors.gray700
        return label
    }()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.tintColor = AppColors.magenta
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializer

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupCell() {
        // Remove colors
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }

    private func setupViews() {
        contentView.addSubview(containerView)

        let titleDateStack = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        titleDateStack.axis = .vertical
        titleDateStack.spacing = 4
        titleDateStack.alignment = .leading
        titleDateStack.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iconContainerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleDateStack)
        containerView.addSubview(valueLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(deleteButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Icon Container
            iconContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconContainerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 32),
            iconContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            // Icon
            iconView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            // Title and Date
            containerView.subviews[2].leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            containerView.subviews[2].centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Remove
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 16),
            
            // Value
            valueLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Arrow
            arrowImageView.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            arrowImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 14),
            arrowImageView.heightAnchor.constraint(equalToConstant: 14),
            
        ])
    }

    // MARK: - Configuration

    public func configure(with transaction: Transaction) {
        titleLabel.text = transaction.title
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        dateLabel.text = formatter.string(from: transaction.date ?? Date())
        
        // Format the amount
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_US")
        valueLabel.text = currencyFormatter.string(from: NSNumber(value: transaction.amount))
        
        // Configure category icon
        if let category = TransactionCategory(rawValue: transaction.category ?? "") {
            iconView.image = category.icon
        } else {
            iconView.image = UIImage(systemName: "questionmark.circle")
        }
        
        // Configure color and arrow
        if transaction.type == "income" {
            arrowImageView.image = UIImage(named: "caret-up")
            arrowImageView.tintColor = AppColors.green
        } else {
            arrowImageView.image = UIImage(named: "caret-down")
            arrowImageView.tintColor = AppColors.red
        }
    }

    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        delegate?.didTapDelete(on: self)
    }
}
