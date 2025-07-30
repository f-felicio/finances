//
//  TransactionsListView.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import UIKit
import Combine

class TransactionsListView: UIView {
    
    // MARK: - Properties
    private let viewModel: TransactionsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let transactionsTitleLabel = UILabel()
    private let transactionsCounterLabel = UILabel()
    private let transactionsCounterContainer = UIView()
    private let transactionsHeaderContainer = UIView()
    private let transactionsSeparator = UIView()
    private let emptyIcon = UIImageView()
    
    private let transactionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = true
        tableView.backgroundColor = AppColors.gray100
        tableView.layer.cornerRadius = 12
        tableView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private let emptyStateView = UIView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Callbacks
    var onDeleteTransaction: ((Transaction) -> Void)?
    
    // MARK: - Initializer
    init(viewModel: TransactionsViewModel) {
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
        setupComponents()
        setupTableView()
        setupConstraints()
    }
    
    private func setupComponents() {
        // Header Container
        transactionsHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        transactionsHeaderContainer.backgroundColor = AppColors.gray100
        transactionsHeaderContainer.layer.cornerRadius = 12
        transactionsHeaderContainer.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        addSubview(transactionsHeaderContainer)
        
        // Title
        transactionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionsTitleLabel.text = "TRANSACTIONS"
        transactionsTitleLabel.font = AppFonts.titleXs()
        transactionsTitleLabel.textColor = AppColors.gray500
        transactionsHeaderContainer.addSubview(transactionsTitleLabel)
        
        // Counter Container
        transactionsCounterContainer.translatesAutoresizingMaskIntoConstraints = false
        transactionsCounterContainer.backgroundColor = AppColors.gray300
        transactionsCounterContainer.layer.cornerRadius = 9
        transactionsHeaderContainer.addSubview(transactionsCounterContainer)
        
        // Counter Label
        transactionsCounterLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionsCounterLabel.text = "0"
        transactionsCounterLabel.font = AppFonts.textSm()
        transactionsCounterLabel.textColor = AppColors.gray600
        transactionsCounterContainer.addSubview(transactionsCounterLabel)
        
        // Separator
        transactionsSeparator.translatesAutoresizingMaskIntoConstraints = false
        transactionsSeparator.backgroundColor = AppColors.gray200.withAlphaComponent(0.2)
        addSubview(transactionsSeparator)
        
        // Table View
        addSubview(transactionsTableView)
        
        // Empty State
        setupEmptyState()
    }
    
    private func setupEmptyState() {
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.backgroundColor = AppColors.gray100
        emptyStateView.layer.cornerRadius = 12
        emptyStateView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        emptyStateView.layer.masksToBounds = true
        addSubview(emptyStateView)
        
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false
        emptyIcon.image = UIImage(named: "empty-file")
        emptyIcon.tintColor = AppColors.gray400
        emptyIcon.contentMode = .scaleAspectFill
        emptyStateView.addSubview(emptyIcon)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.text = "You have not yet imputed expenses or income this month"
        emptyStateLabel.font = AppFonts.textXs()
        emptyStateLabel.textColor = AppColors.gray500
        emptyStateLabel.textAlignment = .left
        emptyStateLabel.numberOfLines = 2
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
//            heightAnchor.constraint(equalToConstant: 120),
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 20),
            emptyIcon.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyIcon.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyIcon.trailingAnchor, constant: 12),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -42),
        ])
    }
    
    private func setupTableView() {
        transactionsTableView.dataSource = self
        transactionsTableView.delegate = self
        transactionsTableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header Container
            transactionsHeaderContainer.topAnchor.constraint(equalTo: topAnchor),
            transactionsHeaderContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            transactionsHeaderContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            transactionsHeaderContainer.heightAnchor.constraint(equalToConstant: 42),
            
            // Title
            transactionsTitleLabel.leadingAnchor.constraint(equalTo: transactionsHeaderContainer.leadingAnchor, constant: 20),
            transactionsTitleLabel.centerYAnchor.constraint(equalTo: transactionsHeaderContainer.centerYAnchor),
            
            // Counter Container
            transactionsCounterContainer.trailingAnchor.constraint(equalTo: transactionsHeaderContainer.trailingAnchor, constant: -20),
            transactionsCounterContainer.centerYAnchor.constraint(equalTo: transactionsHeaderContainer.centerYAnchor),
            transactionsCounterContainer.heightAnchor.constraint(equalToConstant: 18),
            transactionsCounterContainer.widthAnchor.constraint(equalToConstant: 24),
            
            // Counter
            transactionsCounterLabel.centerYAnchor.constraint(equalTo: transactionsCounterContainer.centerYAnchor),
            transactionsCounterLabel.centerXAnchor.constraint(equalTo: transactionsCounterContainer.centerXAnchor),
            
            // Separator
            transactionsSeparator.topAnchor.constraint(equalTo: transactionsHeaderContainer.bottomAnchor),
            transactionsSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            transactionsSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            transactionsSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            // Table View
            transactionsTableView.topAnchor.constraint(equalTo: transactionsSeparator.bottomAnchor),
            transactionsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            transactionsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            transactionsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // Empty State
            emptyStateView.topAnchor.constraint(equalTo: transactionsSeparator.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 72),
        ])
    }
    
    private func setupBindings() {
        // Observa mudanças nas transações
        viewModel.$transactions.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTransactionsList()
            }
        }.store(in: &cancellables)
        
        viewModel.$isEmpty.sink { [weak self] isEmpty in
            DispatchQueue.main.async {
                self?.updateEmptyState(isEmpty: isEmpty)
            }
        }.store(in: &cancellables)
    }
    
    private func updateTransactionsList() {
        transactionsCounterLabel.text = viewModel.transactionsCount
        transactionsTableView.reloadData()
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        transactionsTableView.isHidden = isEmpty
    }
    
    // MARK: - Public Methods
    func refreshData() {
        transactionsTableView.reloadData()
    }
}

// MARK: - UITableView DataSource & Delegate
extension TransactionsListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        
        let transaction = viewModel.transactions[indexPath.row]
        cell.configure(with: transaction)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - TransactionCellDelegate
extension TransactionsListView: TransactionCellDelegate {
    func didTapDelete(on cell: TransactionCell) {
        guard let indexPath = transactionsTableView.indexPath(for: cell) else { return }
        let transaction = viewModel.transactions[indexPath.row]
        onDeleteTransaction?(transaction)
    }
}
