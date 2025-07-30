//
//  CoreDataManager.swift
//  Finances
//
//  Created by Felipe Felicio on 12/07/25.
//

import CoreData
import UIKit
import FirebaseAuth

// MARK: - Enum for transaction types
enum TransactionType: String, CaseIterable {
    case income = "income"      // Revenue
    case expense = "expense"    // Expense
    
    var displayName: String {
        switch self {
        case .income:
            return "Revenue"
        case .expense:
            return "Expense"
        }
    }
    
    var color: UIColor {
        switch self {
        case .income:
            return .systemGreen
        case .expense:
            return .systemRed
        }
    }
}

// MARK: - CoreDataManager Class
class CoreDataManager {
    
    // MARK: - Singleton Pattern
    // Single instance throughout the app
    static let shared = CoreDataManager()
    
    // Private init prevents creating other instances
    private init() {}
    
    // MARK: - Core Data Stack
    // Lazy = only created when used for the first time
    lazy var persistentContainer: NSPersistentContainer = {
        
        // Creates the container with the .xcdatamodeld file name
        let container = NSPersistentContainer(name: "Finances")
        
        // Loads the database (SQLite)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // In production, you would handle this error more gracefully
                fatalError("Error loading Core Data: \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
    
    // Context = workspace where we perform operations
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    // Saves all context changes to disk
    func saveContext() {
        // Only saves if there are changes (optimization)
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Context saved successfully")
            } catch {
                print("❌ Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Budget Methods
    
    // Fetches the current user's budget for a specific month/year
    func getCurrentUserBudget(for month: Int, year: Int) -> Budget? {
        
        // Gets the authenticated user's ID
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        // Creates a request to fetch Budget
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        
        // Filter: userId = current user AND month = month AND year = year
        request.predicate = NSPredicate(
            format: "userId == %@ AND month == %d AND year == %d",
            userId, month, year
        )
        
        // Limits to 1 result (optimization)
        request.fetchLimit = 1
        
        do {
            let budgets = try context.fetch(request)
            return budgets.first // Returns the first (or nil if empty)
        } catch {
            print("❌ Error fetching budget: \(error)")
            return nil
        }
    }
    
    // Creates a new budget or updates existing one
    @discardableResult
    func createBudget(amount: Double, month: Int, year: Int) -> Budget? {
        // Checks if user is authenticated
        guard let userId = Auth.auth().currentUser?.uid else {
            return nil
        }
        
        // Checks if a budget already exists for this period
        if let existingBudget = getCurrentUserBudget(for: month, year: year) {
            // Updates the existing budget
            existingBudget.amount = amount
            saveContext()
            return existingBudget
        }
        
        // Creates a new budget
        let budget = Budget(context: context)
        budget.id = UUID()
        budget.userId = userId
        budget.amount = amount
        budget.month = Int16(month)  // Core Data uses Int16
        budget.year = Int16(year)
        budget.createdAt = Date()
        
        saveContext()
        return budget
    }
    
    // Deletes a budget (and all related transactions)
    func deleteBudget(_ budget: Budget) {
        context.delete(budget)
        saveContext()
    }
    
    // MARK: - Transaction Methods
    
    // Searches for all transactions of a specific budget
    func getTransactions(for budget: Budget) -> [Transaction] {
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        // Filter: only transactions for this budget
        request.predicate = NSPredicate(format: "budget == %@", budget)
        
        // Sorting: most recent first
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let transactions = try context.fetch(request)
            return transactions
        } catch {
            return []
        }
    }
    
    // Creates a new transaction
    @discardableResult
    func createTransaction(
        title: String,
        amount: Double,
        category: String,
        type: TransactionType,
        date: Date,
        budget: Budget
    ) -> Transaction? {
        
        // Creates new transaction
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.title = title
        transaction.amount = amount
        transaction.category = category
        transaction.type = type.rawValue
        transaction.date = date
        
        // Relationship: connects transaction to budget
        transaction.budget = budget
        
        saveContext()
        return transaction
    }
    
    // Deletes a specific transaction
    func deleteTransaction(_ transaction: Transaction) {
        context.delete(transaction)
        saveContext()
    }
    
    // MARK: - Utility Methods
    
    // Searches for all user budgets
    func getAllUserBudgets() -> [Budget] {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            return []
        }
        
        let request: NSFetchRequest<Budget> = Budget.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [
            NSSortDescriptor(key: "year", ascending: false),
            NSSortDescriptor(key: "month", ascending: false)
        ]
        
        do {
            return try context.fetch(request)
        } catch {
            return []
        }
    }
    
    // Method to clear all data (useful for testing)
    func deleteAllData() {
        // Deletes all budgets
        let budgetRequest: NSFetchRequest<Budget> = Budget.fetchRequest()
        do {
            let budgets = try context.fetch(budgetRequest)
            for budget in budgets {
                context.delete(budget)
            }
        } catch {
            print("❌ Error removing budget: \(error)")
        }
        
        // Deletes all transactions
        let transactionRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            let transactions = try context.fetch(transactionRequest)
            for transaction in transactions {
                context.delete(transaction)
            }
        } catch {
            print("❌ Error removing transactions: \(error)")
        }
        
        saveContext()
    }

    // MARK: - User Management
    func fetchUser() -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        do {
            return try context.fetch(request).first
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func updateUserProfileImage(filename: String) -> User? {
        let user = fetchUser() ?? User(context: context)
        user.profileImageFilename = filename
        if user.id == nil {
            user.id = UUID()
        }
        
        saveContext()
        return user
    }
}
