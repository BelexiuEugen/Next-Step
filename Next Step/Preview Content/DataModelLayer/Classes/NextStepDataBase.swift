//
//  NextStepDataBase.swift
//  Next Step
//
//  Created by Jan on 19/12/2024.
//
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import SwiftData

class DatabaseManager{
    
    let db = Firestore.firestore()
    
    func fetchTechniqueModel() async throws -> [TechniqueModel]{
        
        var result: [TechniqueModel] = []
        
        do {
            let snapshot = try await db.collection("workoutDetails")
                .getDocuments()
            
            for document in snapshot.documents{
                
                let data = document.data()
                
                let newTechniqueModel = TechniqueModel(
                    TechniqueName: data["TechniqueName"] as! String,
                    TechniqueDetails: data["TechniqueDetails"] as! String,
                    Level: data["Level"] as! String)
                
                
                result.append(newTechniqueModel)
            }
        } catch{
            print("Error getting documents: \(error.localizedDescription)")
                throw error
        }
        
        return result;
    }
    
    func fetchTasks(ID: String) async throws -> [TaskModel]{
        
        var result:[TaskModel] = []
        
        
        do {
            let snapshot = try await db.collection("tasks")
                .whereField("userID", isEqualTo: ID)
                .getDocuments()
            
            for document in snapshot.documents{
                
                let data = document.data()
                
                let newTask = TaskModel.fromDictionary(data, documentID: document.documentID)
                
                result.append(newTask)
            }
        } catch{
            print("Error getting documents: \(error.localizedDescription)")
                throw error
        }
        
        return result;
    }
    
    func saveEachTask(task: TaskModel){
        

        if let taskID = task.taskID, !taskID.isEmpty {

            let taskRef = db.collection("tasks").document(taskID)
            let taskData = task.toDictionary()
            
            taskRef.updateData(taskData) { error in
                if let error = error {
                    print("Error updating task: \(error)")
                } else {
                    print("Task updated successfully!")
                }
            }
        } else {

            let taskData = task.toDictionary()
            
            let taskRef = db.collection("tasks")
            
            var ref: DocumentReference? = nil
            do{
                ref = taskRef.addDocument(data: taskData){ error in
                    if let error = error{
                        print("Error adding document: \(error.localizedDescription)")
                    }
                    else{
                        print("Document added with ID: \(ref!.documentID)")
                        task.taskID = ref!.documentID
                    }
                }
            }
        }
    }
    
    func deleteFromDataBase(ID: String){
        
        db.collection("tasks").document(ID).delete { error in
                    if let error = error {
                        print("Error deleting document: \(error.localizedDescription)")
                    } else {
                        print("Document successfully deleted!")
                    }
                }
    }
    
}
