//
//  addTaskView.swift
//  Next Step
//
//  Created by Jan on 03/12/2024.
//

import SwiftUI
import SwiftData

struct TaskViewiOS: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Bindable var task : TaskModel
    @Bindable var path : NavigationViewModel
    @State private var newTaskName = ""
    
    @Query var taskList:[TaskModel]
    
    var body: some View {
        
            Form{
                TextField("Task Name", text: $task.taskName)
                TextField("Details", text: $task.taskDescription)
                DatePicker("deadline", selection: $task.deadline)
                
                createProgressView()
                .padding(.bottom, 16)
                
                
                createTaskSection()
            }
            .navigationTitle(task.taskName)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
            .onDisappear(){
                if(task.taskName.isEmpty){
                    modelContext.delete(task) // Remove from database context
                    path.path.removeAll { $0 == task }
                }
            }
    }
}

#Preview {
    do{
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        let container = try ModelContainer(for: TaskModel.self, configurations: config)
        
        let example  = TaskModel(taskID: "1", userID: "1", taskName: "Wash face", description: "just wash face", deadline: .now + 10000, creationDate: .now, progress: 0.0, isCompleted: false, isVisible: false, subTasks: [])
        
        return TaskViewiOS(task: example, path: NavigationViewModel()).modelContainer(container)
    }catch{
        fatalError("Something wrong")
    }
}


// MARK: Body
extension TaskViewiOS{
    
    func createProgressView() -> some View{
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: HelperClass.calculateProgress(task: task))
                .progressViewStyle(LinearProgressViewStyle())
            
            Text("\(Int(HelperClass.calculateProgress(task: task) * 100))%") // Show percentage
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
    
    func createTaskSection() -> some View{
        
        Section("Sub Tasks"){
            ForEach(Array(task.subTasks.enumerated()), id: \.element.id) {index, subTask in
                NavigationLink(value: subTask){
                    Text(subTask.taskName)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button("Complete"){
                                markTaskAsCompleted(task: subTask)
                            }
                            .tint(.green)
                        }
                }
            }
            .onDelete(perform: deleteTask)
            
            HStack{
                TextField("Add a new task ", text: $newTaskName)
                
                Button("add", action: addTask)
            }
        }
        
    }
    
}

// MARK: Functions

extension TaskViewiOS{
    
    func markTaskAsCompleted(task: TaskModel){
        
        task.isCompleted.toggle()
        
        TaskModel.saveDataToDevice(with: modelContext)
        
    }
    
    func addTask(){
        
        guard newTaskName.isEmpty == false else {return}
        
        let newTask = TaskModel(taskName: newTaskName, isMain: false)
        
        task.subTasks.append(newTask)
        
        newTaskName = ""
        
        path.path.append(newTask)
        
        TaskModel.saveDataToDevice(with: modelContext)
        
        
    }
    
    func deleteTask(_ indexSet: IndexSet){
        for index in indexSet{
            let task = taskList[index]
            modelContext.delete(task)
            
            TaskModel.saveDataToDevice(with: modelContext)
        }
    }

}
