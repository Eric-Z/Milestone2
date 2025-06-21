import SwiftUI
import SwiftData

struct FolderView: View {
    
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    var folder: Folder
    var isEditMode = false
    
    @State private var showEditFolder = false
    
    var body: some View {
        HStack(spacing: 0) {
            let icon = folder.type == .deleted ? "trash" : "folder"
            
            Image(systemName: icon)
                .fontWeight(.medium)
                .imageScale(.large)
                .foregroundStyle(.textHighlight1)
                .padding(.trailing, 12)
            
            Text("\(folder.name)")
            
            Spacer()
            
            if !isEditMode {
                Text("\(countFolderMilestone())")
                    .fontWeight(.medium)
                    .foregroundStyle(.labelSecondary)
                    .padding(.trailing, 16)
                
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
                    .imageScale(.small)
                    .foregroundStyle(.labelTertiary)
            }
            
            if folder.type == .normal && isEditMode {
                HStack(spacing: 10) {
                    Menu {
                        Button(action: {
                            showEditFolder = true
                        }) {
                            Label("Rename Folder", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            modelContext.delete(folder)
                            try? modelContext.save()
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .fontWeight(.medium)
                            .imageScale(.large)
                            .foregroundStyle(.textHighlight1)
                            .frame(width: 24, alignment: .center)
                    }
                }
                .transition(AnyTransition.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .trailing)
                        .combined(with: AnyTransition.opacity)
                ))
            }
        }
        .sheet(isPresented: $showEditFolder) {
            FolderEditView(folder: folder)
        }
    }
    
    // MARK: -方法
    /**
     统计文件夹下的里程碑数量
     */
    private func countFolderMilestone() -> Int {
        if (folder.name == Constants.FOLDER_ALL_CN || folder.name == Constants.FOLDER_ALL_EN) {
            return milestones.filter { !$0.deleted }.count
        }
        if (folder.name == Constants.FOLDER_DELETED_CN || folder.name == Constants.FOLDER_DELETED_EN) {
            return milestones.filter { $0.deleted }.count
        }
        return milestones.filter { $0.folderId == folder.id.uuidString }.count
    }
}

#Preview {
    FolderView(folder: Folder(name: "Travel"))
}
