import SwiftUI
import SwiftData

struct TaskViewMacOS: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var task : TaskModel
    @Bindable var path : NavigationViewModel
    @State private var newTaskName = ""
    @State private var isChecked = false
    @State private var taskListUpdated = false;
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            createProgressView()
            
            createTaskData()
            
            createSubTasksSection()
            
        }
        .padding()
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500, maxHeight: .infinity)
        .background(HelperClass.getSystemBackgroundColor())
        .onChange(of: taskListUpdated) {}
        .onDisappear(){
            if(task.taskName.isEmpty){
                modelContext.delete(task) // Remove from database context
                path.path.removeAll { $0 == task }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TaskModel.self, configurations: config)
        
        let example = TaskModel(
            taskID: "1", userID: "1", taskName: "Wash face", description: "Just wash face",
            deadline: .now + 10000, creationDate: .now, progress: 0.0, isCompleted: false,
            isVisible: false, subTasks: []
        )
        
        return TaskViewMacOS(task: example, path: NavigationViewModel()).modelContainer(container)
    } catch {
        fatalError("Something went wrong")
    }
}


// MARK: Body
extension TaskViewMacOS{
    
    func createProgressView() -> some View{
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: HelperClass.calculateProgress(task: task))
                .progressViewStyle(LinearProgressViewStyle())
            
            Text("\(Int(HelperClass.calculateProgress(task: task) * 100))%") // Show percentage
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 16)
    }
    
    func createTaskData() -> some View{
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Name:")
                .font(.headline)
            
            TextField("Task Name", text: $task.taskName)
                .padding()
                .foregroundStyle(Color.black)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 5)
                .frame(maxWidth: .infinity)
                .textFieldStyle(.plain)
            
            Text("Details:")
                .font(.headline)
            TextEditor(text: $task.taskDescription)
                .background(Color.white)
                .scrollIndicators(.never)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 5)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 150, maxHeight: 250)
            
            Text("Deadline:")
                .font(.headline)
            DatePicker("Deadline", selection: $task.deadline, displayedComponents: .date)
                .padding()
                .frame(maxWidth: .infinity)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
    }
    
    func createSubTasksSection() -> some View{
        VStack(alignment: .leading, spacing: 12) {
            Text("Sub Tasks")
                .font(.headline)
                .padding(.top, 20)
            
            ForEach(task.subTasks, id: \.id) { subTask in
                createSubTasks(task: subTask);
            }
            
            createNewSubTaskSection()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
    }
    
    func createSubTasks(task: TaskModel) -> some View{
        HStack{
            Button{
                task.isCompleted.toggle()
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
            
            NavigationLink(value: task){
                
                Text(task.taskName)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            }.buttonStyle(.plain)
            
            Button("Delete")
            {
                deleteSubTask(task)
            }
            .padding()
            .buttonStyle(.borderless)
            .frame(width: 80)
            .background(Color.red)
            .foregroundStyle(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    func createNewSubTaskSection() -> some View{
        HStack {
            TextField("Add a new task", text: $newTaskName)
                .padding()
                .background(Color.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 5)
                .frame(maxWidth: .infinity)
                .textFieldStyle(.plain)
            
            Button {
                addTask()
            } label: {
                Text("Add")
                    .padding(16)
                    .frame(height: 50)
                    .frame(width: 80)
                    .foregroundStyle(Color.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 10)
    }
}

//MARK: Functions

extension TaskViewMacOS{
    
    func addTask() {
        guard newTaskName.isEmpty == false else { return }
        
        let newTask = TaskModel(taskName: newTaskName, isMain: false)
        task.subTasks.append(newTask)
        path.path.append(newTask)
        
        TaskModel.saveDataToDevice(with: modelContext)
    }
    
    func deleteSubTask(_ taskToDelete : TaskModel){
        
        modelContext.delete(taskToDelete)
        
        TaskModel.saveDataToDevice(with: modelContext)
        
    }
}
