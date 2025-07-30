import UIKit

protocol AddTransactionDelegate: AnyObject {
    func didAddTransaction()
}

class AddTransactionViewController: UIViewController {
    // MARK: - Properties
    weak var delegate: AddTransactionDelegate?
    
    private var selectedType: TransactionType?
    private var selectedCategory: TransactionCategory?
    
    // MARK: - UI Components
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let titleLabel = UILabel()
    private let closeButton = UIButton(type: .system)
    
    // Form Fields
    private let titleTextField = UITextField()
    private let categoryTextField = UITextField()
    private let categoryPicker = UIPickerView()
    private let valueTextField = UITextField()
    private let dateTextField = UITextField()
    private let datePicker = UIDatePicker()
    
    private let toolbar = UIToolbar()
    
    // Type Selection Buttons
    private let typeButtonsStackView = UIStackView()
    private let entradaButton = UIButton(type: .system)
    private let saidaButton = UIButton(type: .system)
    
    // Save Button
    private let separator = UIView()
    private let saveButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupCurrencyInput()
        setupDateInput()
        setupActions()
        updateTypeButtons()
        updateCategoryTextField()
    }
    
    // MARK: - UI Setup
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
    private func setupUI() {
        view.backgroundColor = AppColors.gray100

        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "NEW TRANSACTION"
        titleLabel.font = AppFonts.titleXs()
        titleLabel.textColor = AppColors.gray700
        headerView.addSubview(titleLabel)
        
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = AppColors.gray600
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(closeButton)
        
        // Title Field
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.borderStyle = .roundedRect
        titleTextField.backgroundColor = AppColors.gray200
        titleTextField.textColor = AppColors.gray700
        titleTextField.setPadding(left: 8, right: 8)
        titleTextField.attributedPlaceholder = NSAttributedString(
            string: "Title",
            attributes: [
                NSAttributedString.Key.foregroundColor: AppColors.gray400
            ]
        )
        titleTextField.font = AppFonts.textSm(size:16)
        contentView.addSubview(titleTextField)
        
        // Category Text Field
        categoryTextField.placeholder = "Category"
        categoryTextField.borderStyle = .roundedRect
        categoryTextField.backgroundColor = AppColors.gray200
        categoryTextField.textColor = AppColors.gray700
        categoryTextField.font = AppFonts.textSm(size:16)
        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryTextField)
        setupCategoryInput()
        
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
        contentView.addSubview(valueTextField)
        
        // Date Text Field
        dateTextField.placeholder = "00/00/0000"
        dateTextField.borderStyle = .roundedRect
        dateTextField.backgroundColor = AppColors.gray200
        dateTextField.textColor = AppColors.gray700
        dateTextField.font = AppFonts.textSm(size:16)
        dateTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateTextField)
        
        // Date Picker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        // Type Buttons
        typeButtonsStackView.axis = .horizontal
        typeButtonsStackView.distribution = .fillEqually
        typeButtonsStackView.spacing = 12
        typeButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(typeButtonsStackView)
        
        setupTypeButton(entradaButton, title: "Income", image: "caret-up")
        setupTypeButton(saidaButton, title: "Expense", image: "caret-down")
        
        typeButtonsStackView.addArrangedSubview(entradaButton)
        typeButtonsStackView.addArrangedSubview(saidaButton)
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = AppColors.gray500.withAlphaComponent(0.2)
        contentView.addSubview(separator)
        
        // Save Button
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = UIColor.systemPurple
        saveButton.layer.cornerRadius = 8
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(saveButton)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.sizeToFit()
        titleTextField.inputAccessoryView = toolbar
        valueTextField.inputAccessoryView = toolbar
        dateTextField.inputAccessoryView = toolbar
        categoryTextField.inputAccessoryView = toolbar
    }
    
    private func setupTypeButton(_ button: UIButton, title: String, image: String) {
        var config = UIButton.Configuration.plain()
        config.title = title
        
        if let originalImage = UIImage(named: image) {
            let targetSize = CGSize(width: 16, height: 16)
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
            originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            config.image = resizedImage?.withRenderingMode(.alwaysTemplate)
        }
        
        config.imagePlacement = .trailing
        config.titleAlignment = .leading
        config.imagePadding = 8
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFonts.buttonSm()
            return outgoing
        }
        button.configuration = config
        button.layer.cornerRadius = 8
    }
    
    private func setupCategoryInput() {
        categoryTextField.delegate = self
        categoryPicker.delegate = self
        categoryPicker.dataSource = self

        categoryTextField.inputView = categoryPicker

        let tagImageView = UIImageView(image: UIImage(named: "tag"))
        tagImageView.tintColor = AppColors.gray700
        tagImageView.contentMode = .scaleAspectFit
        tagImageView.isUserInteractionEnabled = false

        let leftPaddingView = UIView()
        leftPaddingView.isUserInteractionEnabled = false
        leftPaddingView.addSubview(tagImageView)

        tagImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tagImageView.leadingAnchor.constraint(equalTo: leftPaddingView.leadingAnchor, constant: 12),
            tagImageView.trailingAnchor.constraint(equalTo: leftPaddingView.trailingAnchor, constant: -4),
            tagImageView.centerYAnchor.constraint(equalTo: leftPaddingView.centerYAnchor),
            tagImageView.widthAnchor.constraint(equalToConstant: 24),
            tagImageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        categoryTextField.leftView = leftPaddingView
        categoryTextField.leftViewMode = .always
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Content View
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerView.heightAnchor.constraint(equalToConstant: 44),
            
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            
            // Title Field
            titleTextField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Category Button
            categoryTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 12),
            categoryTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Value Field
            valueTextField.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 12),
            valueTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            valueTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Date Field
            dateTextField.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 12),
            dateTextField.leadingAnchor.constraint(equalTo: valueTextField.trailingAnchor, constant: 8),
            dateTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            dateTextField.heightAnchor.constraint(equalToConstant: 44),
            
            valueTextField.widthAnchor.constraint(equalTo: dateTextField.widthAnchor),

            // Type Buttons
            typeButtonsStackView.topAnchor.constraint(equalTo: valueTextField.bottomAnchor, constant: 28),
            typeButtonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            typeButtonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            typeButtonsStackView.heightAnchor.constraint(equalToConstant: 44),
            
            // Separator
            separator.topAnchor.constraint(equalTo: typeButtonsStackView.bottomAnchor, constant: 28),
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            // Save Button
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 48),
            saveButton.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 28)
        ])
    }
    
    private func setupDateInput() {
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
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        entradaButton.addTarget(self, action: #selector(entradaButtonTapped), for: .touchUpInside)
        saidaButton.addTarget(self, action: #selector(saidaButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func datePickerValueChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    @objc private func doneButtonTapped() {
        dateTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        valueTextField.resignFirstResponder()
        categoryTextField.resignFirstResponder()
    }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func entradaButtonTapped() {
        selectedType = .income
        selectedCategory = nil // Reset category when type changes
        updateTypeButtons()
        updateCategoryTextField()
    }
    
    @objc private func saidaButtonTapped() {
        selectedType = .expense
        selectedCategory = nil // Reset category when type changes
        updateTypeButtons()
        updateCategoryTextField()
    }
    
    @objc private func saveButtonTapped() {
        guard validateForm() else { return }
        // Get current month and year
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        // Get current budget
        guard let currentBudget = CoreDataManager.shared.getCurrentUserBudget(for: currentMonth, year: currentYear) else {
            showAlert(message: "Unable to find current budget")
            return
        }
        
        let title = titleTextField.text!
        let valueString = valueTextField.text!
        let value = Double(valueString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        let date = datePicker.date
        let category = selectedCategory!
        guard let transactionType = self.selectedType else {
            showAlert(message: "Please select a transaction type (Income/Expense).")
            return
        }
        
        // Create transaction using CoreDataManager
        let _ = CoreDataManager.shared.createTransaction(
            title: title,
            amount: value,
            category: category.rawValue,
            type: transactionType,
            date: date,
            budget: currentBudget
        )
        
        // MARK: - Schedule Notification for Expense Transactions on Same Day
        if transactionType == .expense && calendar.isDate(date, inSameDayAs: Date()) {
            // Check notification authorization before scheduling
            NotificationManager.shared.checkAuthorizationStatus { isAuthorized in
                if isAuthorized {
                    NotificationManager.shared.scheduleDailyTransactionReminders(
                        title: title,
                        amount: value,
                        date: date
                    )
                } else {
                    // Request authorization first
                    NotificationManager.shared.requestAuthorization()
                    print("Notification not scheduled - authorization required")
                }
            }
        }
        
        // Notify delegate and dismiss
        delegate?.didAddTransaction()
        dismiss(animated: true)
    }
    
    // MARK: - Helper Methods
    private func updateTypeButtons() {
        let selectedIncomeColor = AppColors.green
        let selectedExpenseColor = AppColors.red
        let unselectedColor = AppColors.gray200
        let selectedTextColor = AppColors.gray100
        
        if selectedType == .income {
            entradaButton.backgroundColor = selectedIncomeColor
            entradaButton.setTitleColor(selectedTextColor, for: .normal)
            entradaButton.tintColor = selectedTextColor
            entradaButton.layer.borderColor = selectedIncomeColor.cgColor
            entradaButton.layer.borderWidth = 1
        } else {
            entradaButton.backgroundColor = selectedType == nil ? selectedIncomeColor.withAlphaComponent(0.1) : unselectedColor
            entradaButton.setTitleColor(selectedIncomeColor, for: .normal)
            entradaButton.tintColor = selectedIncomeColor
            entradaButton.layer.borderColor = (selectedType == nil ? selectedIncomeColor : unselectedColor).cgColor
            entradaButton.layer.borderWidth = 1
        }
        
        if selectedType == .expense {
            saidaButton.backgroundColor = selectedExpenseColor
            saidaButton.setTitleColor(selectedTextColor, for: .normal)
            saidaButton.tintColor = selectedTextColor
            saidaButton.layer.borderColor = selectedExpenseColor.cgColor
            saidaButton.layer.borderWidth = 1
        } else {
            saidaButton.backgroundColor = selectedType == nil ? selectedExpenseColor.withAlphaComponent(0.2) : unselectedColor
            saidaButton.setTitleColor(selectedExpenseColor, for: .normal)
            saidaButton.tintColor = selectedExpenseColor
            saidaButton.layer.borderColor = (selectedType == nil ? selectedExpenseColor : unselectedColor).cgColor
            saidaButton.layer.borderWidth = 1
        }
    }
    
    private func updateCategoryTextField() {
        if let category = selectedCategory {
            categoryTextField.text = category.displayName
            
            let tagImageView = UIImageView(image: category.icon)
            tagImageView.tintColor = AppColors.gray700
            tagImageView.contentMode = .scaleAspectFit
            tagImageView.translatesAutoresizingMaskIntoConstraints = false
            tagImageView.isUserInteractionEnabled = false

            let leftPaddingView = UIView()
            leftPaddingView.isUserInteractionEnabled = false
            leftPaddingView.addSubview(tagImageView)

            NSLayoutConstraint.activate([
                tagImageView.leadingAnchor.constraint(equalTo: leftPaddingView.leadingAnchor, constant: 12),
                tagImageView.trailingAnchor.constraint(equalTo: leftPaddingView.trailingAnchor, constant: -4),
                tagImageView.centerYAnchor.constraint(equalTo: leftPaddingView.centerYAnchor),
                tagImageView.widthAnchor.constraint(equalToConstant: 24),
                tagImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            categoryTextField.leftView = leftPaddingView
            categoryTextField.leftViewMode = .always
            
        } else {
            categoryTextField.text = nil
            categoryTextField.placeholder = "Category"
            let tagImageView = UIImageView(image: UIImage(named: "tag"))
            tagImageView.tintColor = AppColors.gray700
            tagImageView.contentMode = .scaleAspectFit
            tagImageView.translatesAutoresizingMaskIntoConstraints = false
            tagImageView.isUserInteractionEnabled = false

            let leftPaddingView = UIView()
            leftPaddingView.isUserInteractionEnabled = false
            leftPaddingView.addSubview(tagImageView)

            NSLayoutConstraint.activate([
                tagImageView.leadingAnchor.constraint(equalTo: leftPaddingView.leadingAnchor, constant: 12),
                tagImageView.trailingAnchor.constraint(equalTo: leftPaddingView.trailingAnchor, constant: -4),
                tagImageView.centerYAnchor.constraint(equalTo: leftPaddingView.centerYAnchor),
                tagImageView.widthAnchor.constraint(equalToConstant: 24),
                tagImageView.heightAnchor.constraint(equalToConstant: 24)
            ])
            categoryTextField.leftView = leftPaddingView
            categoryTextField.leftViewMode = .always
        }
    }
    
    private func validateForm() -> Bool {
        guard let title = titleTextField.text, !title.isEmpty else {
            showAlert(message: "Please enter a title for the transaction")
            return false
        }
        
        guard let valueText = valueTextField.text, !valueText.isEmpty,
              let _ = Double(valueText.replacingOccurrences(of: ",", with: ".")) else {
            showAlert(message: "Please enter a valid amount")
            return false
        }
        
        guard selectedCategory != nil else {
            showAlert(message: "Please select a category")
            return false
        }
        
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
extension AddTransactionViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == dateTextField {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            if let dateString = textField.text,
               let date = dateFormatter.date(from: dateString) {
                datePicker.date = date
            } else {
                datePicker.date = Date()
            }
            return true
        } else if textField == categoryTextField {
            if let selectedCategory = selectedCategory,
               let index = TransactionCategory.categories(for: selectedType ?? .expense).firstIndex(of: selectedCategory) {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
            } else {
                categoryPicker.selectRow(0, inComponent: 0, animated: false)
            }
            return true
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dateTextField || textField == categoryTextField {
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == dateTextField && (textField.text?.isEmpty ?? true) {
            datePickerValueChanged()
        } else if textField == categoryTextField && (textField.text?.isEmpty ?? true) {
            let categories = TransactionCategory.categories(for: selectedType ?? .expense)
            if !categories.isEmpty {
                selectedCategory = categories[0]
                updateCategoryTextField()
            }
        }
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TransactionCategory.categories(for: selectedType ?? .expense).count
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let categories = TransactionCategory.categories(for: selectedType ?? .expense)
        return categories[row].displayName
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let categories = TransactionCategory.categories(for: selectedType ?? .expense)
        selectedCategory = categories[row]
        updateCategoryTextField()
    }

    // MARK: - Actions (Done button for Picker)
    @objc private func categoryDoneButtonTapped() {
        categoryTextField.resignFirstResponder()
    }
}
