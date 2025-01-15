//
//  TaskListingView.swift
//  Next Step
//
//  Created by Jan on 03/12/2024.
//

import SwiftUI
import SwiftData
import FirebaseFirestore

struct TaskListingView: View {
    
    @Environment(\.modelContext) var modelContext
    
    @Query(sort: [SortDescriptor(\TaskModel.deadline, order: .reverse),
                  SortDescriptor(\TaskModel.taskName)]) var taskList:[TaskModel]
    
    @State private var db: DatabaseManager = DatabaseManager()
    
    var body: some View {
        
#if os(macOS)
        Text("Your Tasks :")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding()
#endif
        createList()
#if os(macOS)
            .scrollContentBackground(.hidden)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: 500, maxHeight: .infinity)
#endif
    }
    
    init(sort: SortDescriptor<TaskModel>, serchString: String){
        
        _taskList = Query(filter: #Predicate{
            if serchString.isEmpty
            {
                return true
            }
            else{
                return $0.taskName.localizedStandardContains(serchString)
            }
        }, sort: [sort])
    }
}

#Preview {
    TaskListingView(sort: SortDescriptor(\TaskModel.taskName), serchString: "")
}

// MARK: Body
extension TaskListingView{
    func createList() -> some View{
        List{
            ForEach(taskList.filter{$0.isMain}){ task in
                HStack{
                    NavigationLink(value: task){
                        VStack(alignment: .leading){
                            Text(task.taskName)
                                .font(.headline)
                            
                            Text(task.deadline.formatted(date: .long, time: .shortened))
                            
                            
                        }
#if os(macOS)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .background(HelperClass.getSystemBackgroundColor())
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .shadow(radius: 4)
#endif
                    }
                    .listRowSeparator(.hidden)
#if os(macOS)
                    createButton(task: task)
#endif
                }
            }
            .onDelete(perform: deleteTask)
            
        }
    }
    
    func createButton(task: TaskModel) -> some View{
        Button
        {
            deleteMainTask(task)
        } label: {
            Text("Delete")
                .font(.body)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(width: 80, height: 50)
        .buttonStyle(.plain)
    }
}

//MARK: Functions.
extension TaskListingView{
    func deleteTask(_ indexSet: IndexSet){
        for index in indexSet{
            let task = taskList[index]
            modelContext.delete(task)
            
            TaskModel.saveDataToDevice(with: modelContext)
            
            guard task.taskID != "" else {return}
            
            if let taskID = task.taskID{
                db.deleteFromDataBase(ID: taskID)
            }
        }
    }
    
    func deleteMainTask(_ taskToDelete : TaskModel){
        
        modelContext.delete(taskToDelete)
        
        TaskModel.saveDataToDevice(with: modelContext)
        
        guard taskToDelete.taskID != "" else {return}
        
        if let taskID = taskToDelete.taskID{
            db.deleteFromDataBase(ID: taskID)
        }
        
    }
}
