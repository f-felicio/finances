//
//  DashboardViewController.swift
//  Finances
//
//  Created by Felipe Felicio on 11/07/25.
//

import UIKit
import Combine
import FirebaseAuth

class DashboardViewController: UIViewController {
    
    // MARK: - ViewModels
    private let budgetViewModel = BudgetViewModel()
    private let transactionsViewModel = TransactionsViewModel()
    private let userProfileViewModel = UserProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Components
    private var headerView: ProfileHeaderView!
    private var budgetCard: BudgetCardView!
    private var transactionsList: TransactionsListView!
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let addButton = UIButton()
        
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        setupComponents()
        setupBindings()
        checkUserAuthentication()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData()
    }
    
    // MARK: - Setup Methods
    private func setupInterface() {
        view.backgroundColor = AppColors.gray100
        view.addSubview(contentView)
        setupAddButton()
    }
    
    private func setupComponents() {
        // Initialize components with ViewModels
        headerView = ProfileHeaderView(viewModel: userProfileViewModel)
        budgetCard = BudgetCardView(viewModel: budgetViewModel)
        transactionsList = TransactionsListView(viewModel: transactionsViewModel)
        
        // Add to view
        contentView.addSubview(headerView)
        contentView.addSubview(budgetCard)
        contentView.addSubview(transactionsList)
        
        // Setup component callbacks
        setupComponentCallbacks()
        setupConstraints()
    }
    
    private func setupComponentCallbacks() {
        // Header callbacks
        headerView.onProfileImageTapped = { [weak self] in
            self?.presentImagePicker()
        }
        
        // Budget card callbacks
        budgetCard.onDefineBudgetTapped = { [weak self] in
            self?.presentBudgetListViewController()
        }
        
        budgetCard.onSettingsTapped = { [weak self] in
            self?.presentBudgetListViewController()
        }
        
        // Transactions list callbacks
        transactionsList.onDeleteTransaction = { [weak self] transaction in
            self?.handleDeleteTransaction(transaction)
        }
        
        headerView.onLogoutConfirmationRequested = { [weak self] in
            guard let self = self else { return }
            
            let alert = UIAlertController(
                title: "Logout",
                message: "Are you sure?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(
                UIAlertAction(title: "Logout", style: .destructive) { _ in
                    do {
                        try Auth.auth().signOut()
                        UserDefaults.standard.removeObject(forKey: "user_name")
                        self.navigateToLogin()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
            )
            present(alert, animated: true)
        }
    }
    
    private func setupBindings() {
        // Update transactions when budget changes
        budgetViewModel.$currentBudget.sink { [weak self] budget in
            self?.transactionsViewModel.loadTransactions(for: budget)
        }.store(in: &cancellables)
    }
    
    private func loadData() {
        userProfileViewModel.loadUserData()
        refreshData()
    }
    
    private func refreshData() {
        budgetViewModel.loadCurrentBudget()
        transactionsViewModel.loadTransactions(for: budgetViewModel.currentBudget)
    }
}
// MARK: - UI Setup
extension DashboardViewController {
    
    private func setupAddButton() {
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.backgroundColor = AppColors.gray700
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = AppColors.gray100
        addButton.layer.cornerRadius = 25
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addButton.layer.shadowRadius = 12
        addButton.layer.shadowOpacity = 0.3
        addButton.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        view.addSubview(addButton)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = AppColors.gray300
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Header View
            headerView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            headerView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            headerView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            
            // Budget Card
            budgetCard.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            budgetCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            budgetCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Card height
            budgetCard.heightAnchor.constraint(equalToConstant: 232),
            
            // Transactions List
            transactionsList.topAnchor.constraint(equalTo: budgetCard.bottomAnchor, constant: 20),
            transactionsList.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            transactionsList.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            transactionsList.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}
// MARK: - Actions & Navigation
extension DashboardViewController {
    
    @objc private func addButtonTapped() {
        let addTransactionVC = AddTransactionViewController()
        addTransactionVC.delegate = self
        if let sheet = addTransactionVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false // Lock Expands
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(addTransactionVC, animated: true)
    }
    
    private func presentImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    private func presentBudgetListViewController() {
        let budgetListVC = BudgetListViewController()
        navigationController?.pushViewController(budgetListVC, animated: true)
    }
    
    private func handleDeleteTransaction(_ transaction: Transaction) {
        let alert = UIAlertController(
            title: "Remove Transaction",
            message: "Do you want to delete \"\(transaction.title ?? "this transaction")\"?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.transactionsViewModel.deleteTransaction(transaction) {
                self.refreshData()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func checkUserAuthentication() {
        guard Auth.auth().currentUser != nil else {
            navigateToLogin()
            return
        }
    }
    
    private func navigateToLogin() {
        DispatchQueue.main.async {
            SceneDelegate.shared()?.navigateToLogin()
        }
    }
}

// MARK: - Delegates
extension DashboardViewController: AddTransactionDelegate {
    func didAddTransaction() {
        refreshData()
    }
}

extension DashboardViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            userProfileViewModel.updateProfileImage(selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
