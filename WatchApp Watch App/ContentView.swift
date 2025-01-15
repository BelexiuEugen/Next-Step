import SwiftUI
import WatchConnectivity

struct ContentView: View {
    
    @StateObject private var connectivityManager = WatchConnectivityManager()
    
    var body: some View {
        VStack {
            
            createList()
                .listStyle(.plain)
                .frame(maxHeight: 300) // Limit list height
                .onAppear {
                    connectivityManager.activateSession()  // Activate the session when the view appears
                }
        }
    }
    
    func createList() -> some View{
        List(connectivityManager.taskList.indices, id: \.self) { index in
            createSubTaskField(task: connectivityManager.taskList[index], index: index)
        }
    }
    
    func refreshList() {
        connectivityManager.taskList = connectivityManager.taskList
    }
}

#Preview {
    ContentView()
}

extension ContentView{
    func createSubTaskField(task: MyTask, index: Int) -> some View{
        HStack{
            
            Text(task.taskName)
                .font(.body)
            
            Spacer()
            
            Button{
                task.isCompleted.toggle()
                refreshList()
                Task{
                    await connectivityManager.updateTask(index: index)
                }
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
}

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    
    @Published var taskList: [MyTask] = []
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func activateSession() {
        WCSession.default.activate()
    }
    
    
    // MARK: - WCSessionDelegate Methods
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Failed to activate WCSession: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            self.taskList = []
            if let data = message["taskData"] as? Data {
                do {

                    let taskData = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                    

                    for task in taskData {
                        if let taskName = task["taskName"] as? String,
                           let isCompleted = task["isCompleted"] as? Bool {
                            self.taskList.append(MyTask(taskName: taskName, isCompleted: isCompleted))

                        }
                    }
                } catch {
                    print("Failed to decode task data: \(error)")
                }
            }
        }
    }
    
    
    
    // MARK: - Sending Data to iOS
    func updateTask(index: Int) async{
        guard WCSession.default.activationState == .activated else {
            print("WCSession is not activated.")
            return
        }

        guard WCSession.default.isReachable else {
            print("iOS is not reachable.")
            return
        }
        
        print("Is iOS reachable: \(WCSession.default.isReachable)")
        
        DispatchQueue.main.async {
            WCSession.default.sendMessage(["index": index], replyHandler: { response in
                print("Index sent successfully to iOS.")
            }, errorHandler: { error in
                print("Error sending index to iOS: \(error.localizedDescription)")
            })
        }
        
    }
}

class MyTask: Identifiable{
    
    @Published var taskName: String
    @Published var isCompleted: Bool
    
    init(taskName: String, isCompleted: Bool) {
        self.taskName = taskName
        self.isCompleted = isCompleted
    }
}
