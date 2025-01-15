import SwiftUI
import Charts
import SwiftData
#if os(iOS)
import WatchConnectivity
#endif

// MARK: - Dashboard View
struct DashboardView: View {
    
    #if os(iOS)
    @StateObject private var watchConnectivityManager = WatchConnectivityManager()
    #endif
    
    @Environment(\.modelContext) var modelContext
    @Query var taskList:[TaskModel]
    
    @AppStorage("userID") var userID: String?
    
    @State var isLoggingOut:Bool = false;
    
    // Filter today's tasks
    private var todaysTasks: [TaskModel] {
        taskList.filter { Calendar.current.isDateInToday($0.deadline) }
    }
    
    // Chart Data for Pie Chart
    private var chartData: [(String, Int)] {
        let completed = todaysTasks.filter { $0.isCompleted }.count
        let uncompleted = todaysTasks.count - completed
        return [("Completed", completed), ("Uncompleted", uncompleted)]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - Task List
                createBoardTitle()
                
                createTodayTask()
                
                // MARK: - Pie Chart
                createTaskCompletedTitle()
                
                createChart()
                    .frame(height: 250)
                    .padding()
                    .navigationDestination(isPresented: $isLoggingOut) {
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    }
            }
            .padding()
            .frame(minWidth: 400, minHeight: 600) // macOS-friendly sizing
            .navigationTitle("Dashboard")
            
            
            .toolbar {
                Button("Add destination", systemImage: "rectangle.portrait.and.arrow.right", action: exitAccount)
            }
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Add destination", systemImage: "applewatch", action: connectToWatch)
                }
            }
            .onChange(of: watchConnectivityManager.arhived) {
                watchConnectivityManager.arhived.forEach{ index in
                    toggleTaskCompletion(at: index)
                }
                
                watchConnectivityManager.arhived = []
            }
            
#endif
        }
    }
}



// MARK: - Previews
#Preview{
    DashboardView()
}

// MARK: Body

extension  DashboardView{
    func createSubTaskField(task: TaskModel) -> some View{
        HStack{
            
            Text(task.taskName)
                .font(.body)
            
            Spacer()
            
            Button{
                task.isCompleted.toggle()
#if os(iOS)
                connectToWatch();
                //                watchConnectivityManager.update
#endif
            } label: {
                ZStack {
                    // Outer circle background
                    Circle()
                        .fill(Color.white)
                        .stroke(task.isCompleted ? Color.blue : Color.gray, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    // Checkmark inside the circle (shown when checked)
                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                    
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    func createBoardTitle() -> some View{
        Text("Today's Tasks")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    func createTaskCompletedTitle() -> some View{
        Text("Task Completion")
            .font(.title2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
    }
    
    func createTodayTask() -> some View{
        
        List(todaysTasks) { task in
            createSubTaskField(task: task)
        }
        .listStyle(.plain)
        .frame(maxHeight: 300) // Limit list height
    }
    
    func createChart() -> some View{
        Chart {
            ForEach(chartData, id: \.0) { category, count in
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.5),
                    outerRadius: .ratio(1.0)
                )
                .foregroundStyle(category == "Completed" ? .green : .red)
                .annotation(position: .overlay) {
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: Functions

extension DashboardView {
    func toggleTaskCompletion(at index: Int) {
        guard index >= 0 && index < taskList.count else { return }
        
        let task = todaysTasks[index]
        task.isCompleted.toggle()
        
        DispatchQueue.global().async{
            TaskModel.saveDataToDevice(with: modelContext)
        }
    }
    
    func exitAccount(){

        TaskModel.exitAccount(with: modelContext)
        
        userID = nil;
        isLoggingOut.toggle()
            
    }
}

#if os(iOS)
// MARK: WatchOS Connection
extension DashboardView{
    func connectToWatch() {
        Task {
            await watchConnectivityManager.sendDataToWatch(tasks: todaysTasks)
            }
    }
}
#endif


// MARK: Body


