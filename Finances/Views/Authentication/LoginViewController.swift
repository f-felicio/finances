//
//  LoginViewController.swift
//  Finances
//
//  Created by Felipe Felicio on 09/07/25.
//

import FirebaseAuth
import UIKit

class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var welcomeTitleLabel: UILabel!
    @IBOutlet weak var welcomeSubtitleLabel: UILabel!
    
    private var biometricButton: UIButton!
    private var isBiometricSetup = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        setupKeyboardObservers()
        setupTapGesture()
    }

    // MARK: - Setup Methods
    private func setupInterface() {
        setupBackgroundImage()
        setupWelcomeLabels()
        setupTextFields()
        setupLoginButton()
        setupPasswordVisibility()
        setupBiometricButton()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func setupWelcomeLabels() {
        welcomeTitleLabel.text = "Welcome to Finances!"
        welcomeTitleLabel.font = AppFonts.titleSm()
        welcomeTitleLabel.textColor = AppColors.gray700

        welcomeSubtitleLabel.text =
            "Ready to organize your finances? Access now"
        welcomeSubtitleLabel.font = AppFonts.textSm()
        welcomeSubtitleLabel.textColor = AppColors.gray500
        welcomeSubtitleLabel.numberOfLines = 0

        welcomeTitleLabel.sizeToFit()
        welcomeSubtitleLabel.sizeToFit()
    }

    private func setupBackgroundImage() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerRadius = 12
        backgroundImageView.clipsToBounds = true
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            backgroundImageView.heightAnchor.constraint(equalToConstant: 280)
        ])
    }

    private func setupTextFields() {

        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = AppColors.gray200
        nameTextField.textColor = AppColors.gray700
        nameTextField.setPadding(left: 8, right: 8)
        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Name",
            attributes: [
                NSAttributedString.Key.foregroundColor: AppColors.gray400
            ]
        )

        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.borderStyle = .roundedRect
        emailTextField.backgroundColor = AppColors.gray200
        emailTextField.textColor = AppColors.gray700
        emailTextField.setPadding(left: 8, right: 8)
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email",
            attributes: [
                NSAttributedString.Key.foregroundColor: AppColors.gray400
            ]
        )

        passwordTextField.isSecureTextEntry = true
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = AppColors.gray200
        passwordTextField.textColor = AppColors.gray700
        passwordTextField.setPadding(left: 8, right: 8)
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [
                NSAttributedString.Key.foregroundColor: AppColors.gray400
            ]
        )
    }

    private func setupLoginButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Enter"
        configuration.baseBackgroundColor = AppColors.magenta
        configuration.baseForegroundColor = AppColors.gray100
        configuration.cornerStyle = .large

        loginButton.configuration = configuration
    }

    private func setupPasswordVisibility() {
        showPasswordButton.setImage(
            UIImage(named: "eye-closed"),
            for: .normal
        )
        passwordTextField.isSecureTextEntry = true
    }
    private func setupBiometricButton() {
        let (isAvailable, biometryType, _) = BiometricAuthManager.shared.isBiometricAvailable()
        
        guard isAvailable else { return }
        
        biometricButton = UIButton(type: .system)
        biometricButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure button icon based on biometry type
        let iconName = biometryType == .faceID ? "faceid" : "touchid"
        biometricButton.setImage(UIImage(systemName: iconName), for: .normal)
        biometricButton.tintColor = .white
        biometricButton.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        biometricButton.layer.cornerRadius = 25
        biometricButton.addTarget(self, action: #selector(biometricButtonTapped), for: .touchUpInside)
        
        view.addSubview(biometricButton)
        
        NSLayoutConstraint.activate([
            biometricButton.widthAnchor.constraint(equalToConstant: 50),
            biometricButton.heightAnchor.constraint(equalToConstant: 50),
            biometricButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            biometricButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20)
        ])
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
        ] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height

            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(
                    translationX: 0,
                    y: -keyboardHeight / 1.5
                )
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func biometricButtonTapped() {
        BiometricAuthManager.shared.loadBiometricCredentials { [weak self] email, password, name in
            guard let email = email, let password = password, let name = name else {
                self?.showAlert(title: "Error", message: "No saved credentials found. Please log in first.")
                return
            }
            
            // Auto-login with saved credentials
            self?.authenticateUser(email: email, password: password, name: name, isFromBiometric: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func authenticateUser(email: String, password: String, name: String, isFromBiometric: Bool = false) {
        // Check if user exists (try login first)
        Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] result, error in
            if error != nil {
                // Login failed, try to create account
                self?.createUser(email: email, password: password, name: name)
            } else {
                // Login successful
                UserDefaults.standard.set(name, forKey: "user_name")
                if !isFromBiometric {
                    self?.offerBiometricSetup(email: email, password: password, name:name)
                } else {
                    self?.navigateToDashboard()
                }
            }
        }
    }

    private func createUser(email: String, password: String, name: String) {
        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] result, error in
            if let error = error {
                print(error)
                self?.showAlert(
                    title: "Authentication Failed",
                    message: error.localizedDescription
                )
            } else {
                // Account created successfully
                UserDefaults.standard.set(name, forKey: "user_name")
                self?.navigateToDashboard()
            }
        }
    }

    private func navigateToDashboard() {
        DispatchQueue.main.async {
            SceneDelegate.shared()?.navigateToDashboard()
        }
    }
    private func offerBiometricSetup(email: String, password: String, name: String) {
        let (isAvailable, biometryType, _) = BiometricAuthManager.shared.isBiometricAvailable()
        
        guard isAvailable else {
            navigateToDashboard()
            return
        }
        
        let biometryName = biometryType == .faceID ? "Face ID" : "Touch ID"
        
        let alert = UIAlertController(
            title: "Enable \(biometryName)?",
            message: "Would you like to use \(biometryName) for quick and secure login?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Enable", style: .default) { _ in
            _ = BiometricAuthManager.shared.saveBiometricCredentials(email: email, password: password, name:name)
            self.navigateToDashboard()
        })
        
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel) { _ in
            self.navigateToDashboard()
        })
        
        present(alert, animated: true)
    }
    //MARK: - IBActions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
            let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty
        else {
            showAlert(
                title: "Error",
                message: "Please fill all fields."
            )
            return
        }

        authenticateUser(email: email, password: password, name: name)
    }

    @IBAction func showPasswordButtonTapped(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry.toggle()

        let eyeIcon = passwordTextField.isSecureTextEntry ? "eye" : "eye-closed"
        showPasswordButton.setImage(UIImage(named: eyeIcon), for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
}
