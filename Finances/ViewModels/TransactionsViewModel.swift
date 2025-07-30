//
//  TransactionsViewModel.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import Foundation

class TransactionsViewModel: ObservableObject {
    
    // MARK: - Properties
    private let coreDataManager = CoreDataManager.shared
    @Published var transactions: [Transaction] = []
    @Published var isEmpty = true
    
    // MARK: - Computed Properties
    var transactionsCount: String {
        return "\(transactions.count)"
    }
    
    var hasTransactions: Bool {
        return !transactions.isEmpty
    }
    
    // MARK: - Methods
    func loadTransactions(for budget: Budget?) {
        guard let budget = budget else {
            transactions = []
            isEmpty = true
            return
        }
        
        transactions = coreDataManager.getTransactions(for: budget)
        isEmpty = transactions.isEmpty
    }
    
    func deleteTransaction(_ transaction: Transaction, completion: @escaping () -> Void) {
        coreDataManager.deleteTransaction(transaction)
        
        // Remove from local array
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions.remove(at: index)
        }
        isEmpty = transactions.isEmpty
        completion()
    }
}
