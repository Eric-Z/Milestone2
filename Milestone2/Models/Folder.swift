import Foundation
import SwiftData

@Model
final class Folder: Identifiable {
    
    var id: UUID
    var name: String
    var type: FolderType
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.type = .normal
    }
}
