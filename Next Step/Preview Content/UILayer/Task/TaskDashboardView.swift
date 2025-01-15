//
//  TaskView.swift
//  Next Step
//
//  Created by Jan on 29/11/2024.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

@Observable
class NavigationViewModel{
    var path: [TaskModel] = []
}


struct TaskDashboardView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @State private var path = NavigationViewModel()
    
    @Query var taskList:[TaskModel]
    
    @State private var searchText = ""
    
    @State private var sortOrder = SortDescriptor(\TaskModel.taskName)
    
    @AppStorage("userID") var userID: String?
    
    @State private var db: DatabaseManager = DatabaseManager()
    
    var body: some View {
        NavigationStack(path: $path.path){
            TaskListingView(sort: sortOrder, serchString:searchText)
            .navigationTitle("Your Task")
            .navigationDestination(for: TaskModel.self){ task in
#if os(iOS)
                TaskViewiOS(task: task, path: path)
#elseif os(macOS)
                TaskViewMacOS(task: task, path: path)
#endif
            }
            .searchable(text: $searchText)
            .toolbar{
                Button("Add destination", systemImage: "plus", action: addTask)
                
                Menu("Sort", systemImage: "arrow.up.arrow.down"){
                    Picker("Sort", selection: $sortOrder){
                        Text("Name")
                            .tag(SortDescriptor(\TaskModel.taskName))
                        
                        Text("Dead Line")
                            .tag(SortDescriptor(\TaskModel.deadline))
                        
                        Text("Creation Date")
                            .tag(SortDescriptor(\TaskModel.creationDate))
                        
                        Text("Progress")
                            .tag(SortDescriptor(\TaskModel.progress))
                        
                    }
                    .pickerStyle(.inline)
                }
            }
        }
        
        createSaveButton()
    }
}

#Preview {
    TaskDashboardView()
}

// MARK: Body
extension TaskDashboardView{
    func createSaveButton() -> some View{
        VStack{
            HStack{
                Spacer()
                
                Button
                {
                    saveDataToDataBase()
                } label: {
                    Text("Save data to database")
                        .padding()
                        .frame(height: 50)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: Functions
extension TaskDashboardView{
    
    func addTask() {
        let task = TaskModel(userID: userID ?? "Not found")
        modelContext.insert(task)
        
        withAnimation {
            path.path.append(task) // Add task to the navigation stack
        }
    }
    
    func saveDataToDataBase(){
        
        let mainTask:[TaskModel] = taskList.filter({$0.isMain})
        
        for task in mainTask{
            db.saveEachTask(task: task)
        }
    }
}
