import SwiftUI
import SwiftData

struct MilestoneListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var milestones: [Milestone]
    
    @State private var filteredMilestones: [Milestone] = []
    
    var folder: Folder;
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Text("\(filteredMilestones.count) Milestones")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                if filteredMilestones.first(where: { $0.pinned }) != nil {
                    HStack(spacing: 0) {
                        Text("Pinned")
                            .bold()
                            .padding(.vertical, 8)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .imageScale(.small)
                            .foregroundStyle(.textHighlight1)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
            }
            .navigationTitle(folder.name)
            .onAppear {
                filterAndSort()
            }
        }
    }
    
    // MARK: - 方法
    /**
     里程碑列表排序
     */
    private func filterAndSort() {
        if folder.id == Constants.FOLDER_DELETED_UUID {
            filteredMilestones = milestones
                .filter { $0.deleted }
        } else {
            filteredMilestones = milestones
                .filter { !$0.deleted }
                .filter { $0.folderId == folder.id.uuidString || folder.id == Constants.FOLDER_ALL_UUID}
        }
        
        let now = Date()
        filteredMilestones = filteredMilestones
            .sorted { (m1: Milestone, m2: Milestone) in
                // 1. 置顶的优先
                if m1.pinned != m2.pinned {
                    return m1.pinned
                }
                
                // 判断是否在期间内
                let m1InPeriod = now >= m1.startDate && now <= m1.endDate
                let m2InPeriod = now >= m2.startDate && now <= m2.endDate
                
                if m1InPeriod != m2InPeriod {
                    return m1InPeriod
                }
                if m1InPeriod && m2InPeriod {
                    let m1DistanceToEnd = m1.endDate.timeIntervalSince(now)
                    let m2DistanceToEnd = m2.endDate.timeIntervalSince(now)
                    return m1DistanceToEnd > m2DistanceToEnd
                }
                
                if !m1InPeriod && !m2InPeriod {
                    let m1BeforeStart = now < m1.startDate
                    let m2BeforeStart = now < m2.startDate
                    if m1BeforeStart != m2BeforeStart {
                        return m1BeforeStart
                    }
                    if m1BeforeStart && m2BeforeStart {
                        return m1.startDate < m2.startDate
                    }
                    return m1.endDate > m2.endDate
                }
                return false
            }
    }
}

#Preview {
    do {
        let schema = Schema([
            Folder.self, Milestone.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = container.mainContext
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let folder = Folder(name: "旅行")
        
        let milestone1 = Milestone(folderId: folder.id.uuidString, title: "冲绳之旅", startDate: formatter.date(from: "2025-04-25")!, endDate: formatter.date(from: "2025-04-28")!, allDay: true, deleted: false, pinned: true)
        let milestone2 = Milestone(folderId: folder.id.uuidString, title: "大阪之旅", startDate: formatter.date(from: "2025-10-31")!, endDate: formatter.date(from: "2025-12-02")!, allDay: true, deleted: false, pinned: true)
        
        context.insert(folder)
        context.insert(milestone1)
        context.insert(milestone2)
        
        return MilestoneListView(folder: folder).modelContainer(container)
    } catch {
        return Text("无法创建 ModelContainer")
    }
}
