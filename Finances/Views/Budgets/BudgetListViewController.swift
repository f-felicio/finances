import UIKit

class BudgetListViewController: UIViewController {
    
    // MARK: - ViewModels
    private let budgetViewModel = BudgetViewModel()
    
    // MARK: - Components
    private var budgetsListView: BudgetsListView!
    
    // MARK: - UI Components
    private let contentView = UIView()
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backButtonView = UIImageView()
    private let addBudgetView = UIView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupComponents()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = AppColors.gray100
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = AppColors.gray300
        view.addSubview(contentView)
        
        setupHeader()
    }
    
    private func setupComponents() {
        // Initialize component with ViewModel
        budgetsListView = BudgetsListView(viewModel: budgetViewModel)
        contentView.addSubview(budgetsListView)
        
        // Setup component callbacks
        setupComponentCallbacks()
        setupConstraints()
    }

    private func setupComponentCallbacks() {
        budgetsListView.onDeleteBudget = { [weak self] budget in
            self?.handleDeleteBudget(budget)
        }
        budgetsListView.onShowAlert = { [weak self] title, message in
            self?.showAlert(title: title, message: message)
        }
    }
    
    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = AppColors.gray100
        view.addSubview(headerView)
        
        // Back Button
        backButtonView.image = UIImage(named: "chevron-left")
        backButtonView.tintColor = AppColors.gray500
        backButtonView.contentMode = .scaleAspectFill
        backButtonView.isUserInteractionEnabled = true
        backButtonView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        backButtonView.addGestureRecognizer(tapGesture)
        headerView.addSubview(backButtonView)
        
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "MONTHLY BUDGETS"
        titleLabel.font = AppFonts.titleSm()
        titleLabel.textColor = AppColors.gray700
        headerView.addSubview(titleLabel)
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Organize your monthly spending limits"
        subtitleLabel.font = AppFonts.textSm()
        subtitleLabel.textColor = AppColors.gray500
        headerView.addSubview(subtitleLabel)

    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 75),
            
            // Back Button
            backButtonView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButtonView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backButtonView.widthAnchor.constraint(equalToConstant: 24),
            backButtonView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: backButtonView.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            // Budgets List View
            budgetsListView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            budgetsListView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            budgetsListView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            budgetsListView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func loadData() {
        budgetViewModel.loadAllBudgets()
    }
    
    private func refreshData() {
        budgetsListView.refreshData()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    private func handleDeleteBudget(_ budget: Budget) {
        let alert = UIAlertController(
            title: "Delete Budget",
            message: "Are you sure you want to delete the budget for \(budgetViewModel.formatBudgetDate(budget))?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.budgetViewModel.deleteBudget(budget) {
                // Budget deleted successfully
                print("✅ Budget deleted successfully")
            }
        })
        
        present(alert, animated: true)
    }
}
