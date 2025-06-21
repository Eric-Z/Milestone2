import SwiftUI
import SwiftData

struct FolderAddView: View {
    
    @Query private var folders: [Folder]
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
                
                Text("New Folder")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save") {
                    if exists() {
                        showAlert = true
                    } else {
                        let folder = Folder(name: folderName)
                        modelContext.insert(folder)
                        try? modelContext.save()
                        dismiss()
                    }
                }
                .foregroundStyle(.textHighlight1)
                .disabled(folderName.isEmpty)
            }
            .padding()
            
            TextField("Name", text: $folderName)
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
            folderName = ""
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
        return folders.contains { $0.name.lowercased() == folderName.lowercased() }
    }
}

#Preview {
    FolderAddView()
}
