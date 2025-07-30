//
//  TransactionCell.swift
//  Finances
//
//  Created by Felipe Felicio on 17/07/25.
//

import UIKit

protocol BudgetCellDelegate: AnyObject {
    func didTapDelete(on cell: BudgetCell)
}

class BudgetCell: UITableViewCell {

    static let identifier = "BudgetCell"

    // Delegate
    weak var delegate: BudgetCellDelegate?

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColors.gray700
        return imageView
    }()

    private let monthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.textSm(size: 14)
        label.textColor = AppColors.gray700
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFonts.textXs()
        label.textColor = AppColors.gray600
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

        containerView.addSubview(iconView)
        containerView.addSubview(monthLabel)
        containerView.addSubview(yearLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(deleteButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            // Icon
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),

            // Month and Year
            monthLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            monthLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            yearLabel.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 4),
            yearLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            // Value
            valueLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Remove
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 16),
            deleteButton.heightAnchor.constraint(equalToConstant: 16),
                        
        ])
    }

    // MARK: - Configuration

    public func configure(with budget: Budget) {
        iconView.image = UIImage(named: "calendar")
        
        // Format Date
        var dateComponents = DateComponents()
        dateComponents.year = Int(budget.year)
        dateComponents.month = Int(budget.month)
        if let date = Calendar.current.date(from: dateComponents) {
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMMM"
            monthLabel.text = monthFormatter.string(from: date)
            yearLabel.text = "\(budget.year)"
        } else {
            monthLabel.text = "Month \(budget.month)"
            yearLabel.text = "\(budget.year)"
        }
        // Format value
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_US")
        valueLabel.text = currencyFormatter.string(from: NSNumber(value: budget.amount))
    }

    // MARK: - Actions
    @objc private func deleteButtonTapped() {
        delegate?.didTapDelete(on: self)
    }
}
