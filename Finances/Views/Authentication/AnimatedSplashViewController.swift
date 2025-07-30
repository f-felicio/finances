//
//  AnimatedSplashViewController.swift
//  Finances
//
//  Created by Felipe Felicio on 09/07/25.
//

import FirebaseAuth
import UIKit

class AnimatedSplashViewController: UIViewController {

    @IBOutlet weak var diamondImageView: UIImageView!
    @IBOutlet weak var diamond2ImageView: UIImageView!

    private var hasNavigated = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Put elements out before animation
        setupInitialPosition()

        // Start animation after 0.5 sec
        DispatchQueue.main.async {
            self.startAnimation()
        }
    }

    func setupInitialPosition() {
        diamondImageView.transform = CGAffineTransform(
            translationX: -view.bounds.width,
            y: 0
        )
        diamond2ImageView.transform = CGAffineTransform(
            translationX: view.bounds.width,
            y: 0
        )

        diamondImageView.alpha = 0.0
        diamond2ImageView.alpha = 0.0
    }

    func startAnimation() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                self.diamondImageView.transform = CGAffineTransform.identity
                self.diamondImageView.alpha = 1.0
                self.diamond2ImageView.transform = CGAffineTransform.identity
                self.diamond2ImageView.alpha = 1.0
            },
            completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.checkUserAuthenticationAndNavigate()
                }
            }
        )
    }

    private func checkUserAuthenticationAndNavigate() {
        
        // Avoid multiple navigations
        guard !hasNavigated else {
            return
        }

        hasNavigated = true

    if let currentUser = Auth.auth().currentUser {
        // Verify if the user still exists and is valid
        currentUser.getIDToken { token, error in
            DispatchQueue.main.async {
                if error != nil {
                    // User is invalid or doesn't exist anymore
                    print("❌ User authentication failed, navigating to login")
                    SceneDelegate.shared()?.navigateToLogin()
                } else {
                    // User is valid
                    print("✅ User authentication valid, navigating to dashboard")
                    SceneDelegate.shared()?.navigateToDashboard()
                }
            }
        }
    } else {
        SceneDelegate.shared()?.navigateToLogin()
    }
    }

    private func navigateToDashboard() {
        let dashboardVC = DashboardViewController()
        let navigationController = UINavigationController(
            rootViewController: dashboardVC
        )
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .crossDissolve
        present(navigationController, animated: true) {
            print("✅ User already authenticated, navigated to Dashboard!")
        }
    }
    func navigateToLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(
            withIdentifier: "LoginViewController"
        ) as? LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            loginViewController.modalTransitionStyle = .crossDissolve
            present(loginViewController, animated: true, completion: nil)
        } else {
            print("Error instantiating LoginViewController")
        }
    }
}
