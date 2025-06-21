import SwiftUI
import SwiftData

struct FolderEditView: View {
    
    @Query private var folders: [Folder]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var folder: Folder
    
    @State private var folderName = ""
    @State private var showAlert = false
    @FocusState private var isFocused: Bool
    
    // MARK: - 主视图
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.textHighlight1)
                
                Spacer()
                
                Text("Rename Folder")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    if exists() {
                        showAlert = true
                    } else {
                        folder.name = folderName
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .foregroundStyle(.textHighlight1)
                .disabled(folderName.isEmpty)
            }
            .padding()
            
            SelectableTextField(text: $folderName, isFirstResponder: Binding.constant(true), placeholder: "Name")
                .frame(height: 24)
                .padding(.vertical, 12)
                .padding(.horizontal, Distances.itemPaddingH)
                .background(.areaItem)
                .cornerRadius(21)
                .padding(.horizontal)
                .focused($isFocused)
            
            Spacer()
        }
        .alert("Name Taken", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please choose a different name.")
        }
        .onAppear {
            folderName = folder.name
            showAlert = false
            isFocused = true
        }
    }
    
    // MARK: - 方法
    /**
     检查文件夹名称是否被占用
     */
    private func exists() -> Bool {
        if folderName == Constants.FOLDER_ALL_CN || folderName == Constants.FOLDER_ALL_EN {
            return true
        }
        if folderName == Constants.FOLDER_DELETED_CN || folderName == Constants.FOLDER_DELETED_EN {
            return true
        }
        return folders.contains { $0.name.lowercased() == folderName.lowercased() && $0.id != folder.id}
    }
}

#Preview {
    do {
        let schema = Schema([
            Folder.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let folder1 = Folder(name: "生日")
        let folder2 = Folder(name: "旅游")
        context.insert(folder1)
        context.insert(folder2)
        
        return FolderEditView(folder: folder1).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
