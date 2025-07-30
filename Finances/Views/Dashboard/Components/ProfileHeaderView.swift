//
//  ProfileHeaderView.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import UIKit
import Combine
import FirebaseAuth

class ProfileHeaderView: UIView {
    // MARK: - Properties
    private let viewModel: UserProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    private let greetingLabel = UILabel()
    private let userNameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let logoutButton = UIButton()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        
        return imageView
    }()
    // MARK: - Callbacks
    var onProfileImageTapped: (() -> Void)?
    var onLogoutConfirmationRequested: (() -> Void)?
    
    // MARK: - Initializer
    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        setupLogoutButton()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = AppColors.gray100
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(profileImageView)
        addSubview(greetingLabel)
        addSubview(userNameLabel)
        addSubview(subtitleLabel)
        
        // Configure labels
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.text = "Hello, "
        greetingLabel.font = AppFonts.titleSm()
        greetingLabel.textColor = AppColors.gray700
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = AppFonts.titleSm()
        userNameLabel.textColor = AppColors.gray700
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Let's organize your finances?"
        subtitleLabel.font = AppFonts.textSm()
        subtitleLabel.textColor = AppColors.gray500
        
        setupConstraints()
    }
    private func setupLogoutButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(named: "logout"), for: .normal)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.tintColor = AppColors.gray500
        addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24),
            logoutButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Height constraint
            heightAnchor.constraint(equalToConstant: 75),
            
            // Profile Image
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Greeting Label
            greetingLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            greetingLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            // User Name Label
            userNameLabel.leadingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            
            // Subtitle Label
            subtitleLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            subtitleLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.$userName.sink { [weak self] name in
            DispatchQueue.main.async {
                self?.userNameLabel.text = "\(name)!"
            }
        }.store(in: &cancellables)
        
        viewModel.$profileImage.sink { [weak self] image in
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.store(in: &cancellables)
    }
    private func navigateToLogin() {
        DispatchQueue.main.async {
            SceneDelegate.shared()?.navigateToLogin()
        }
    }
}
// MARK: - Actions & Navigation
extension ProfileHeaderView {
    @objc private func profileImageTapped() {
        onProfileImageTapped?()
    }
    @objc private func logoutButtonTapped() {
        onLogoutConfirmationRequested?()
    }
}
