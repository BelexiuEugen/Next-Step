//
//  UserClass.swift
//  Next Step
//
//  Created by Jan on 21/11/2024.
//

import Foundation
import SwiftData
import FirebaseCore

//@Model
//final class UserManager{
//    
//    
//    
//    @Attribute(.unique) var name: String
//    var isActive: Bool = true
//    var userSettings: UserSettings
//    var userData: UserData
//    var taskList: [TaskItem] = []
//    
//    init(name: String, isActive: Bool, userSettings: UserSettings, userData: UserData, taskList: [TaskItem]) {
//        self.name = name
//        self.isActive = isActive
//        self.userSettings = userSettings
//        self.userData = userData
//        self.taskList = taskList
//    }
//}

//@Model
//final class TaskManager{
//    
//    @Attribute(.unique) var uid: String
//    
//    var taskList: [TaskItem] = []
//    
//    init(ID: String, taskList: [TaskItem]) {
//        self.uid = ID
//        self.taskList = taskList
//    }
//    
//    func getTaskListByID(ID: String){
//        
//    }
//}


@Model
class TaskModel{
    
    var taskID: String?
    var userID: String
    var taskName: String
    var taskDescription: String
    var deadline: Date
    var creationDate:Date
    var progress: CGFloat = 0.0
    var isCompleted: Bool = false
    var isVisible: Bool = false
    var isMain: Bool = true;
    @Relationship(deleteRule: .cascade) var subTasks: [TaskModel] = []
    
    init(taskID: String = "", userID: String = "", taskName: String = "", description: String = "", deadline: Date = .now + 100, creationDate: Date = .now, progress: CGFloat = 0.0, isCompleted: Bool = false, isVisible: Bool = true, isMain: Bool = true, subTasks: [TaskModel] = []) {
        self.taskID = taskID
        self.userID = userID
        self.taskName = taskName
        self.taskDescription = description
        self.deadline = deadline
        self.creationDate = creationDate
        self.progress = progress
        self.isCompleted = isCompleted
        self.isVisible = isVisible
        self.isMain = isMain
        self.subTasks = subTasks
    }
    
    func toDictionary() -> [String: Any] {
            return [
                "taskID": taskID ?? UUID().uuidString,
                "userID": userID,
                "taskName": taskName,
                "taskDescription": taskDescription,
                "deadline": deadline,
                "creationDate": creationDate,
                "progress": progress,
                "isCompleted": isCompleted,
                "isVisible": isVisible,
                "isMain": isMain,
                "subTasks": subTasks.map { $0.toDictionary() }
            ]
        }
    
    static func fromDictionary(_ data: [String: Any], documentID: String) -> TaskModel {

        let subTasksData = data["subTasks"] as? [[String: Any]] ?? []
        
        let subTasks = subTasksData.map { subTaskData -> TaskModel in
            return fromDictionary(subTaskData, documentID: subTaskData["taskID"] as? String ?? UUID().uuidString)
        }
        
        return TaskModel(
            taskID: documentID,
            userID: data["userID"] as? String ?? "Untitled",
            taskName: data["taskName"] as? String ?? "",
            description: data["description"] as? String ?? "",
            deadline: (data["deadline"] as? Timestamp)?.dateValue() ?? Date(),
            creationDate: (data["creationDate"] as? Timestamp)?.dateValue() ?? Date(),
            progress: data["progress"] as? CGFloat ?? 0.0,
            isCompleted: data["isCompleted"] as? Bool ?? false,
            isVisible: data["isVisible"] as? Bool ?? true,
            isMain: data["isMain"] as? Bool ?? true,
            subTasks: subTasks
        )
    }
    
    static func saveDataToDevice(with context: ModelContext){
        do{
            try context.save()
            
        } catch{
            print("there was an error saving the task")
        }
    }
    
    static func exitAccount(with context: ModelContext){
        
        do{
            let allTasks = try context.fetch(FetchDescriptor<TaskModel>())
            let allTechniqueModel = try context.fetch(FetchDescriptor<TechniqueModel>())
            
            // Delete each task
            for task in allTasks {
                context.delete(task)
            }
            
            for techiqueModel in allTechniqueModel{
                context.delete(techiqueModel)
            }
            
            TaskModel.saveDataToDevice(with: context)
            
        }catch{
            print("There was an error deleting the data")
        }
    }
}

@Model
final class TechniqueModel{
    var techniqueName: String
    var techniqueDetails: String
    var level: String
    
    init(TechniqueName: String, TechniqueDetails: String, Level: String) {
        self.techniqueName = TechniqueName
        self.techniqueDetails = TechniqueDetails
        self.level = Level
    }
}
