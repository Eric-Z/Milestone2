import SwiftUI
import SwiftData

struct FolderListView: View {
    
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Query private var milestones: [Milestone]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var allFolders: [Folder] = []

    @State private var showEditMode = false
    @State private var showAddFolder = false

    @State private var searchText = ""
    
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(self.allFolders) { folder in
                    FolderView(folder: folder, isEditMode: self.showEditMode)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("BackgroundPrimary"))
            .navigationTitle("Folders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        self.showAddFolder.toggle()
                    } label: {
                        Image(systemName: "folder.badge.plus")
                            .fontWeight(.medium)
                            .foregroundStyle(.labelPrimary)
                            .frame(width: 44, height: 44)
                            .background(.backgroundSecondary)
                            .cornerRadius(22)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 1, blendDuration: 1)) {
                            self.showEditMode.toggle()
                        }
                    } label: {
                        if (self.showEditMode) {
                            Image(systemName: "checkmark")
                                .fontWeight(.medium)
                                .foregroundStyle(.labelPrimary)
                                .frame(width: 56, height: 44)
                                .background(.backgroundSecondary)
                                .cornerRadius(22)
                            
                        } else {
                            Text("Edit")
                                .fontWeight(.medium)
                                .foregroundStyle(.labelPrimary)
                                .frame(width: 56, height: 44)
                                .background(.backgroundSecondary)
                                .cornerRadius(22)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "search")
        .onAppear {
            refresh()
            setupSearchBarAppearance()
        }
        .sheet(isPresented: $showAddFolder) {
            FolderAddView()
        }
    }
    
    // MARK: - 方法
    /**
     刷新文件夹列表
     */
    private func refresh() {
        self.allFolders = []
        self.allFolders.insert(contentsOf: folders, at: 0)
        
        // 添加全部里程碑文件夹
        let systemFolder = Folder(name: Constants.FOLDER_ALL_EN)
        systemFolder.id = Constants.FOLDER_ALL_UUID
        systemFolder.type = .all
        allFolders.insert(systemFolder, at: 0)
        
        // 添加最近删除文件夹
        if self.milestones.first(where: { $0.deleted }) != nil {
            let latestDeleteFolder = Folder(name: Constants.FOLDER_DELETED_EN)
            latestDeleteFolder.id = Constants.FOLDER_DELETED_UUID
            latestDeleteFolder.type = .deleted
            allFolders.insert(latestDeleteFolder, at: allFolders.count)
        }
    }
    
    /**
     自定义取消按钮样式
     */
    private func setupSearchBarAppearance() {
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([
            .foregroundColor: UIColor(named: "LabelPrimary")!,
        ], for: .normal)
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
        
        let folder1 = Folder(name: "Birthday")
        let folder2 = Folder(name: "Travel")
        context.insert(folder1)
        context.insert(folder2)
        
        return FolderListView().modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
