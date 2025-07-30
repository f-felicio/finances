//
//  BudgetCardView.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import UIKit
import Combine

class BudgetCardView: UIView {
    
    // MARK: - Properties
    private let viewModel: BudgetViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let monthLabel = UILabel()
    private let yearLabel = UILabel()
    private let separatorView = UIView()
    private let budgetTitleLabel = UILabel()
    private let budgetAmountLabel = UILabel()
    private let budgetUsedLabel = UILabel()
    private let budgetLimitLabel = UILabel()
    private let budgetUsedValue = UILabel()
    private let budgetLimitValue = UILabel()
    private let budgetProgressView = UIProgressView()
    private let defineBudgetButton = UIButton()
    private let settingsButton = UIButton()
    
    // MARK: - Callbacks
    var onDefineBudgetTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?
    
    // MARK: - Initializer
    init(viewModel: BudgetViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.gray700
        layer.cornerRadius = 8
        clipsToBounds = true
        
        setupComponents()
        setupConstraints()
    }
    
    private func setupComponents() {
        // Month
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.text = "JULY"
        monthLabel.font = AppFonts.titleSm()
        monthLabel.textColor = AppColors.gray100
        addSubview(monthLabel)
        
        // Year
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.text = "/ 2025"
        yearLabel.font = AppFonts.titleXs()
        yearLabel.textColor = AppColors.gray400
        addSubview(yearLabel)
        
        // Separator
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = AppColors.gray600.withAlphaComponent(0.5)
        addSubview(separatorView)
        
        // Settings Button
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(named: "gear"), for: .normal)
        settingsButton.tintColor = AppColors.gray100
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        addSubview(settingsButton)
        
        // Title
        budgetTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        budgetTitleLabel.text = "Available budget"
        budgetTitleLabel.font = AppFonts.textSm()
        budgetTitleLabel.textColor = AppColors.gray400
        addSubview(budgetTitleLabel)
        
        // Amount
        budgetAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        budgetAmountLabel.text = "$ 0,00"
        budgetAmountLabel.font = AppFonts.titleLg()
        budgetAmountLabel.textColor = AppColors.gray100
        addSubview(budgetAmountLabel)
        
        // Define Budget Button (Empty State)
        defineBudgetButton.translatesAutoresizingMaskIntoConstraints = false
        defineBudgetButton.setTitle("Create Budget", for: .normal)
        defineBudgetButton.setTitleColor(AppColors.magenta, for: .normal)
        defineBudgetButton.titleLabel?.font = AppFonts.titleMd()
        defineBudgetButton.layer.borderWidth = 1
        defineBudgetButton.layer.borderColor = AppColors.magenta.cgColor
        defineBudgetButton.layer.cornerRadius = 8.0
        defineBudgetButton.clipsToBounds = true
        defineBudgetButton.layer.backgroundColor = AppColors.magenta.withAlphaComponent(0.1).cgColor
        defineBudgetButton.addTarget(self, action: #selector(defineBudgetButtonTapped), for: .touchUpInside)
        addSubview(defineBudgetButton)
        
        // Progress View (Data State)
        budgetProgressView.translatesAutoresizingMaskIntoConstraints = false
        budgetProgressView.progressTintColor = AppColors.magenta
        budgetProgressView.trackTintColor = UIColor.white.withAlphaComponent(0.3)
        budgetProgressView.clipsToBounds = true
        addSubview(budgetProgressView)
        
        // Used Label
        budgetUsedLabel.translatesAutoresizingMaskIntoConstraints = false
        budgetUsedLabel.text = "Used"
        budgetUsedLabel.font = AppFonts.titleXs()
        budgetUsedLabel.textColor = AppColors.gray400
        budgetUsedLabel.textAlignment = .left
        budgetUsedLabel.numberOfLines = 2
        addSubview(budgetUsedLabel)
        
        // Limit Label
        budgetLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        budgetLimitLabel.text = "Limit"
        budgetLimitLabel.font = AppFonts.titleXs()
        budgetLimitLabel.textColor = AppColors.gray400
        budgetLimitLabel.textAlignment = .right
        budgetLimitLabel.numberOfLines = 2
        addSubview(budgetLimitLabel)
        
        // Used Value
        budgetUsedValue.translatesAutoresizingMaskIntoConstraints = false
        budgetUsedValue.textColor = AppColors.gray100
        budgetUsedValue.textAlignment = .left
        addSubview(budgetUsedValue)
        
        // Limit Value
        budgetLimitValue.translatesAutoresizingMaskIntoConstraints = false
        budgetLimitValue.textColor = AppColors.gray100
        budgetLimitValue.textAlignment = .right
        addSubview(budgetLimitValue)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Month
            monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // Year
            yearLabel.topAnchor.constraint(equalTo: topAnchor, constant: 27),
            yearLabel.leadingAnchor.constraint(equalTo: monthLabel.trailingAnchor, constant: 4),
            yearLabel.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            settingsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            settingsButton.widthAnchor.constraint(equalToConstant: 24),
            settingsButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Separator
            separatorView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 18),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            separatorView.heightAnchor.constraint(equalToConstant: 0.6),
            
            // Title
            budgetTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            budgetTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            
            // Define Budget Button (Empty State)
            defineBudgetButton.topAnchor.constraint(equalTo: budgetTitleLabel.bottomAnchor, constant: 12),
            defineBudgetButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            defineBudgetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            defineBudgetButton.heightAnchor.constraint(equalToConstant: 48),
            
            // Amount
            budgetAmountLabel.topAnchor.constraint(equalTo: budgetTitleLabel.bottomAnchor, constant: 12),
            budgetAmountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            budgetAmountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Used and Limit Labels
            budgetUsedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            budgetUsedLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            
            budgetLimitLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            budgetLimitLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            
            // Used and Limit Values
            budgetUsedValue.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            budgetUsedValue.topAnchor.constraint(equalTo: budgetUsedLabel.bottomAnchor, constant: 4),
            
            budgetLimitValue.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            budgetLimitValue.topAnchor.constraint(equalTo: budgetLimitLabel.bottomAnchor, constant: 4),
            
            // Progress View (Data State)
            budgetProgressView.bottomAnchor.constraint(equalTo: bottomAnchor),
            budgetProgressView.leadingAnchor.constraint(equalTo: leadingAnchor),
            budgetProgressView.trailingAnchor.constraint(equalTo: trailingAnchor),
            budgetProgressView.heightAnchor.constraint(equalToConstant: 8),
        ])
    }
    
    private func setupBindings() {
        // Observes changes in budget state
        viewModel.$isInEmptyState.sink { [weak self] isEmpty in
            DispatchQueue.main.async {
                self?.updateViewState(isEmpty: isEmpty)
            }
        }.store(in: &cancellables)
        
        // Observes changes in values
        viewModel.$currentBudget.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateValues()
            }
        }.store(in: &cancellables)
    }
    
    private func updateViewState(isEmpty: Bool) {
        if isEmpty {
            showEmptyState()
        } else {
            showDataState()
        }
    }
    
    private func showEmptyState() {
        budgetAmountLabel.text = "$ 0,00"
        defineBudgetButton.isHidden = false
        budgetProgressView.isHidden = true
        budgetAmountLabel.isHidden = true
        budgetLimitValue.font = AppFonts.titleLg(size: 20)
    }
    
    private func showDataState() {
        updateValues()
        defineBudgetButton.isHidden = true
        budgetProgressView.isHidden = false
        budgetAmountLabel.isHidden = false
        budgetLimitValue.font = AppFonts.textSm()
    }
    
    private func updateValues() {
        budgetAmountLabel.text = viewModel.budgetAmount
        budgetUsedValue.text = viewModel.budgetUsed
        budgetLimitValue.text = viewModel.budgetLimit
        budgetProgressView.progress = viewModel.progressValue
    }
    
    // MARK: - Actions
    @objc private func defineBudgetButtonTapped() {
        onDefineBudgetTapped?()
    }
    
    @objc private func settingsButtonTapped() {
        onSettingsTapped?()
    }
}
