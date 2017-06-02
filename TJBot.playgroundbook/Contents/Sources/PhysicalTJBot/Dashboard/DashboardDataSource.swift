/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation

struct DashboardDataSource {
    static let defaultRowAdd = 0
    var items: [DashboardCellModel]
    
    var count: Int {
        return items.count
    }
    
    init() {
        self.items = []
    }
    
    mutating func add(model: DashboardCellModel) {
        items.insert(model, at: 0)
    }
    
    func item(at indexPath: IndexPath) -> DashboardCellModel? {
        guard items.count > 0, indexPath.row < items.count else { return nil }
        
        return items[indexPath.row]
    }
    
    func cellType(at indexPath: IndexPath) -> String {
        guard let model = item(at: indexPath) else { return "DashboardCell" }
        return model.cellType
    }
    
    mutating func clear() {
        items.removeAll()
    }
    
    var indexPaths: [IndexPath] {
        var indSet = [IndexPath]()
        var count = 0
        for _ in items {
            indSet.append(IndexPath(row: count, section: 0))
            count += 1
        }
        return indSet
    }
}
