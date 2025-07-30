//
//  TransactionsListView.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import UIKit
import Combine

class BudgetsListView: UIView, UITextFieldDelegate {
    // MARK: - Properties
    private let viewModel: BudgetViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let budgetsTitleLabel = UILabel()
    private let budgetsHeaderContainer = UIView()
    private let budgetsSeparator = UIView()
    private let emptyIcon = UIImageView()
    
    private let budgetsTableView: UITableView = {
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
    
    private let addBudgetView = UIView()
    private let addBudgetHeaderContainer = UIView()
    private let addBudgetTitleLabel = UILabel()
    private let addBudgetSeparator = UIView()
    private let valueTextField = UITextField()
    private let dateTextField = UITextField()
    private let datePicker = UIDatePicker()
    private let saveButton = UIButton(type: .system)
    
    // MARK: - Callbacks
    var onDeleteBudget: ((Budget) -> Void)?
    var onShowAlert: ((String, String) -> Void)?
    
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
        backgroundColor = AppColors.gray300
        
        setupComponents()
        setupCurrencyInput()
        setupDateInput()
        setupTableView()
        setupConstraints()
        setupInputHandling()
    }
    
    private func setupComponents() {
        // Header Container
        budgetsHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        budgetsHeaderContainer.backgroundColor = AppColors.gray100
        budgetsHeaderContainer.layer.cornerRadius = 12
        budgetsHeaderContainer.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner
        ]
        addSubview(budgetsHeaderContainer)
        
        // Title
        budgetsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        budgetsTitleLabel.text = "REGISTERED BUDGETS"
        budgetsTitleLabel.font = AppFonts.titleXs()
        budgetsTitleLabel.textColor = AppColors.gray500
        budgetsHeaderContainer.addSubview(budgetsTitleLabel)
        
        // Separator
        budgetsSeparator.translatesAutoresizingMaskIntoConstraints = false
        budgetsSeparator.backgroundColor = AppColors.gray200.withAlphaComponent(0.2)
        addSubview(budgetsSeparator)
        
        //Add Budget
        setupAddBudget()
        
        // Table View
        addSubview(budgetsTableView)
        
        // Empty State
        setupEmptyState()
    }
    
    private func setupAddBudget() {
        addBudgetView.translatesAutoresizingMaskIntoConstraints = false
        addBudgetView.backgroundColor = AppColors.gray100
        addBudgetView.layer.cornerRadius = 12
        addBudgetView.layer.masksToBounds = true
        addSubview(addBudgetView)
        
        // Header Container
        addBudgetHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        addBudgetView.addSubview(addBudgetHeaderContainer)
        
        // Title
        addBudgetTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addBudgetTitleLabel.text = "NEW BUDGET"
        addBudgetTitleLabel.font = AppFonts.titleXs()
        addBudgetTitleLabel.textColor = AppColors.gray500
        addBudgetHeaderContainer.addSubview(addBudgetTitleLabel)
        
        // Separator
        addBudgetSeparator.translatesAutoresizingMaskIntoConstraints = false
        addBudgetSeparator.backgroundColor = AppColors.gray400.withAlphaComponent(0.2)
        addBudgetHeaderContainer.addSubview(addBudgetSeparator)

        // Value Field
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.borderStyle = .roundedRect
        valueTextField.keyboardType = .decimalPad
        valueTextField.backgroundColor = AppColors.gray200
        valueTextField.textColor = AppColors.gray700
        valueTextField.font = AppFonts.textSm(size:16)
        valueTextField.setPadding(left: 8, right: 8)
        valueTextField.attributedPlaceholder = NSAttributedString(
            string: "0.00",
            attributes: [
                NSAttributedString.Key.foregroundColor: AppColors.gray400
            ]
        )
        addBudgetView.addSubview(valueTextField)

        // Date Text Field
        dateTextField.placeholder = "00/0000"
        dateTextField.borderStyle = .roundedRect
        dateTextField.backgroundColor = AppColors.gray200
        dateTextField.textColor = AppColors.gray700
        dateTextField.font = AppFonts.textSm(size:16)
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        addBudgetView.addSubview(dateTextField)
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Save Button
        saveButton.setTitle("Add", for: .normal)
        saveButton.setTitleColor(AppColors.gray100, for: .normal)
        saveButton.backgroundColor = AppColors.magenta
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = AppFonts.buttonMd()
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        addBudgetView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            // Add Budget View
            addBudgetView.topAnchor.constraint(equalTo: topAnchor),
            addBudgetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            addBudgetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            addBudgetView.heightAnchor.constraint(equalToConstant: 200),
            
            // Header Container
            addBudgetHeaderContainer.topAnchor.constraint(equalTo: topAnchor),
            addBudgetHeaderContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            addBudgetHeaderContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            addBudgetHeaderContainer.heightAnchor.constraint(equalToConstant: 42),
            
            // Title
            addBudgetTitleLabel.leadingAnchor.constraint(equalTo: addBudgetHeaderContainer.leadingAnchor, constant: 20),
            addBudgetTitleLabel.centerYAnchor.constraint(equalTo: addBudgetHeaderContainer.centerYAnchor),
            
            // Separator
            addBudgetSeparator.topAnchor.constraint(equalTo: addBudgetHeaderContainer.bottomAnchor),
            addBudgetSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            addBudgetSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            addBudgetSeparator.heightAnchor.constraint(equalToConstant: 1),

            // Date Field
            dateTextField.topAnchor.constraint(equalTo: addBudgetSeparator.bottomAnchor, constant: 20),
            dateTextField.leadingAnchor.constraint(equalTo: addBudgetView.leadingAnchor, constant: 20),
            dateTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Value Field
            valueTextField.topAnchor.constraint(equalTo: addBudgetSeparator.bottomAnchor, constant: 20),
            valueTextField.leadingAnchor.constraint(equalTo: dateTextField.trailingAnchor, constant: 8),
            valueTextField.trailingAnchor.constraint(equalTo: addBudgetView.trailingAnchor, constant: -20),
            valueTextField.heightAnchor.constraint(equalToConstant: 44),
            
            dateTextField.widthAnchor.constraint(equalTo: valueTextField.widthAnchor),
            
            // Save Button
            saveButton.leadingAnchor.constraint(equalTo: addBudgetView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: addBudgetView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            saveButton.topAnchor.constraint(equalTo: dateTextField.bottomAnchor, constant: 16)
        ])
    }
    private func setupCurrencyInput() {
        let currencyLabel = UILabel()
        currencyLabel.text = "$ "
        currencyLabel.font = valueTextField.font
        currencyLabel.textColor = valueTextField.textColor
        currencyLabel.sizeToFit()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let leftPaddingView = UIView()
        leftPaddingView.addSubview(currencyLabel)
        
        NSLayoutConstraint.activate([
            currencyLabel.leadingAnchor.constraint(equalTo: leftPaddingView.leadingAnchor, constant: 12),
            currencyLabel.trailingAnchor.constraint(equalTo: leftPaddingView.trailingAnchor, constant: 2),
            currencyLabel.centerYAnchor.constraint(equalTo: leftPaddingView.centerYAnchor),
        ])
        valueTextField.leftView = leftPaddingView
        valueTextField.leftViewMode = .always
    }
    private func setupDateInput() {
        datePicker.datePickerMode = .yearAndMonth
        dateTextField.inputView = datePicker
        dateTextField.delegate = self
        
        let calendarImageView = UIImageView(image: UIImage(named: "calendar"))
        calendarImageView.tintColor = AppColors.gray700
        calendarImageView.contentMode = .scaleAspectFit
        
        let leftPaddingView = UIView()
        leftPaddingView.isUserInteractionEnabled = false
            
        leftPaddingView.addSubview(calendarImageView)
        
        calendarImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendarImageView.leadingAnchor.constraint(equalTo: leftPaddingView.leadingAnchor, constant: 6),
            calendarImageView.trailingAnchor.constraint(equalTo: leftPaddingView.trailingAnchor, constant: -4),
            calendarImageView.centerYAnchor.constraint(equalTo: leftPaddingView.centerYAnchor),
            calendarImageView.widthAnchor.constraint(equalToConstant: 24),
            calendarImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        dateTextField.leftView = leftPaddingView
        dateTextField.leftViewMode = .always

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
        emptyStateLabel.text = "You have not created any budgets yet"
        emptyStateLabel.font = AppFonts.textXs()
        emptyStateLabel.textColor = AppColors.gray500
        emptyStateLabel.textAlignment = .left
        emptyStateLabel.numberOfLines = 2
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyIcon.topAnchor.constraint(equalTo: emptyStateView.topAnchor, constant: 20),
            emptyIcon.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 20),
            emptyIcon.widthAnchor.constraint(equalToConstant: 24),
            emptyIcon.heightAnchor.constraint(equalToConstant: 24),
            emptyStateLabel.centerYAnchor.constraint(equalTo: emptyIcon.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyIcon.trailingAnchor, constant: 12),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -20)])
    }
    
    private func setupTableView() {
        budgetsTableView.dataSource = self
        budgetsTableView.delegate = self
        budgetsTableView.register(BudgetCell.self, forCellReuseIdentifier: "BudgetCell")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header Container
            budgetsHeaderContainer.topAnchor.constraint(equalTo: addBudgetView.bottomAnchor, constant: 16),
            budgetsHeaderContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            budgetsHeaderContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            budgetsHeaderContainer.heightAnchor.constraint(equalToConstant: 42),
            
            // Title
            budgetsTitleLabel.leadingAnchor.constraint(equalTo: budgetsHeaderContainer.leadingAnchor, constant: 20),
            budgetsTitleLabel.centerYAnchor.constraint(equalTo: budgetsHeaderContainer.centerYAnchor),
            
            // Separator
            budgetsSeparator.topAnchor.constraint(equalTo: budgetsHeaderContainer.bottomAnchor),
            budgetsSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            budgetsSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            budgetsSeparator.heightAnchor.constraint(equalToConstant: 1),
            
            // Table View
            budgetsTableView.topAnchor.constraint(equalTo: budgetsSeparator.bottomAnchor),
            budgetsTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            budgetsTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            budgetsTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            // Empty State
            emptyStateView.topAnchor.constraint(equalTo: budgetsSeparator.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyStateView.heightAnchor.constraint(equalToConstant: 72),
        ])
    }
    
    private func setupBindings() {
        viewModel.$budgets.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateBudgetsList()
                self?.updateEmptyState(isEmpty: self?.viewModel.isBudgetsListEmpty ?? true)
            }
        }.store(in: &cancellables)
    }
    
    private func updateBudgetsList() {
        budgetsTableView.reloadData()
    }
    // MARK: - Keyboard & Input Handling
    private func setupInputHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        valueTextField.delegate = self
        dateTextField.delegate = self
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
    }
    private func updateTextFieldsFromInputs() {
        updateDateTextField()
    }

    private func updateDateTextField() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        dateTextField.text = formatter.string(from: datePicker.date)
    }
    @objc private func dismissKeyboard() {
        updateTextFieldsFromInputs()
        endEditing(true)
    }

    @objc private func datePickerValueChanged() {
        updateDateTextField()
    }
    
    // MARK: - Form Actions & Validation
    @objc private func saveButtonTapped() {
        guard validateForm() else { return }
        
        // Get values
        guard let amountText = valueTextField.text,
              let amount = Double(amountText.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespacesAndNewlines)),
              amount > 0 else {
            showAlert(title: "Invalid Amount", message: "Please enter a valid amount greater than 0")
            return
        }
        
        // Get selected date
        let selectedDate = datePicker.date
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        // Create budget
        if viewModel.createBudgetForDate(amount: amount, month: month, year: year) {
            clearForm()
            showSuccessMessage()
        } else {
            showAlert(title: "Error", message: "Budget for this month already exists")
        }
    }
    
    private func validateForm() -> Bool {
        guard let amountText = valueTextField.text, !amountText.isEmpty else {
            showAlert(title: "Missing Information", message: "Please enter a budget amount")
            return false
        }
        
        guard let dateText = dateTextField.text, !dateText.isEmpty else {
            showAlert(title: "Missing Information", message: "Please select a month")
            return false
        }
        
        return true
    }
    
    private func clearForm() {
        valueTextField.text = ""
        dateTextField.text = ""
    }
    
    private func showSuccessMessage() {
        // Simple feedback
        saveButton.setTitle("✓ Added", for: .normal)
        saveButton.backgroundColor = AppColors.green
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.saveButton.setTitle("Add", for: .normal)
            self.saveButton.backgroundColor = AppColors.magenta
        }
    }
    
    private func showAlert(title: String, message: String) {
        // Delegate alert to parent view controller
        onShowAlert?(title, message)
    }
    
    private func updateEmptyState(isEmpty: Bool) {
        emptyStateView.isHidden = !isEmpty
        budgetsTableView.isHidden = isEmpty
    }
    
    // MARK: - Public Methods
    func refreshData() {
        viewModel.loadAllBudgets()
    }
}

extension BudgetsListView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.budgets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BudgetCell.identifier, for: indexPath) as? BudgetCell else {
            return UITableViewCell()
        }
        
        let budget = viewModel.budgets[indexPath.row]
        cell.configure(with: budget)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let budgetToDelete = viewModel.budgets[indexPath.row]
            onDeleteBudget?(budgetToDelete)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == dateTextField {
            updateDateTextField()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == valueTextField {
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
// MARK: - TransactionCellDelegate
extension BudgetsListView: BudgetCellDelegate {
    func didTapDelete(on cell: BudgetCell) {
        guard let indexPath = budgetsTableView.indexPath(for: cell) else { return }
        let budget = viewModel.budgets[indexPath.row]
        onDeleteBudget?(budget)
    }
}
