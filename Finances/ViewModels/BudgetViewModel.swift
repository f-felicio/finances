//
//  BudgetViewModel.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import Foundation

class BudgetViewModel: ObservableObject {
    
    // MARK: - Properties
    private let coreDataManager = CoreDataManager.shared
    
    //Dashboard
    @Published var currentBudget: Budget?
    @Published var isInEmptyState = true
    //BudgetsList
    @Published var budgets: [Budget] = []
    
    // MARK: - Computed Properties (Dashboard)
    var budgetAmount: String {
        guard let budget = currentBudget else { return "$ 0.00" }
        
        let transactions = coreDataManager.getTransactions(for: budget)
        let totalExpenses = transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        let totalIncome = transactions.filter { $0.type == "income" }.reduce(0) { $0 + $1.amount }
        let availableBudget = (budget.amount + totalIncome) - totalExpenses
        
        return "\(formatCurrency(availableBudget))"
    }
    
    var budgetUsed: String {
        guard let budget = currentBudget else { return "$ 0.00" }
        
        let transactions = coreDataManager.getTransactions(for: budget)
        let totalExpenses = transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        
        return "\(formatCurrency(totalExpenses))"
    }
    
    var budgetLimit: String {
        guard let budget = currentBudget else { return "∞" }
        return "\(formatCurrency(budget.amount))"
    }
    
    var progressValue: Float {
        guard let budget = currentBudget, budget.amount > 0 else { return 0 }
        
        let transactions = coreDataManager.getTransactions(for: budget)
        let totalExpenses = transactions.filter { $0.type == "expense" }.reduce(0) { $0 + $1.amount }
        
        return min(Float(totalExpenses / budget.amount), 1.0)
    }
    
    // MARK: - Computed Properties (BudgetsList)
    var budgetsCount: String {
        return "\(budgets.count)"
    }
    
    var hasBudgets: Bool {
        return !budgets.isEmpty
    }
    
    var isBudgetsListEmpty: Bool {
        return budgets.isEmpty
    }
    // MARK: - Methods (Dashboard)
    func loadCurrentBudget() {
        let now = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        currentBudget = coreDataManager.getCurrentUserBudget(for: currentMonth, year: currentYear)
        isInEmptyState = (currentBudget == nil)
    }
    
    // MARK: - Methods (BudgetsList)
    func createBudgetForDate(amount: Double, month: Int, year: Int) -> Bool {
        if let budget = coreDataManager.createBudget(amount: amount, month: month, year: year) {
            // Refresh budgets list
            loadAllBudgets()
            
            let now = Date()
            let calendar = Calendar.current
            let currentMonth = calendar.component(.month, from: now)
            let currentYear = calendar.component(.year, from: now)
        
            if month == currentMonth && year == currentYear {
                currentBudget = budget
                isInEmptyState = false
            }
            
            return true
        }
        return false
    }
    
    // MARK: - Methods (BudgetsList)
    func loadAllBudgets() {
        budgets = coreDataManager.getAllUserBudgets()
       
        // Sort by year and month (newest first)
        budgets.sort {
            if $0.year != $1.year {
                return $0.year > $1.year
            }
            return $0.month > $1.month
        }
    }
    func deleteBudget(_ budget: Budget, completion: @escaping () -> Void) {
        coreDataManager.deleteBudget(budget)
        
        // Remove from local array
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets.remove(at: index)
        }
                
        if currentBudget?.id == budget.id {
            loadCurrentBudget()
        }
        completion()
    }
    func formatBudgetDate(_ budget: Budget) -> String {
        var dateComponents = DateComponents()
        dateComponents.year = Int(budget.year)
        dateComponents.month = Int(budget.month)
         
        if let date = Calendar.current.date(from: dateComponents) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            return dateFormatter.string(from: date).capitalized
        } else {
            return "Invalid Date"
        }
    }
     
    func formatBudgetAmount(_ budget: Budget) -> String {
        return formatCurrency(budget.amount)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$ 0.00"
    }
}
