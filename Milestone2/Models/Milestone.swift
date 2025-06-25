import Foundation
import SwiftData

@Model
final class Milestone: Identifiable {
    
    var id: UUID
    var folderId: String?
    var title: String
    var startDate: Date
    var endDate: Date
    var allDay: Bool
    var deleted: Bool
    var pinned: Bool
    
    init(id: UUID = UUID(), folderId: String?, title: String, startDate: Date, endDate: Date, allDay: Bool, deleted: Bool, pinned: Bool) {
        self.id = id
        self.folderId = folderId
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.allDay = allDay
        self.deleted = deleted
        self.pinned = pinned
    }
} 
