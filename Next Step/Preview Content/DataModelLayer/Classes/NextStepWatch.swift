#if os(iOS)
import WatchConnectivity


class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var receivedIndex: Int?
    @Published var arhived: [Int] = []
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("Session became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
            print("Session deactivated.")
            WCSession.default.activate()
    }
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("iOS session activation failed: \(error)")
        } else {
            print("iOS session activated: \(activationState.rawValue)")
        }
    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let index = message["index"] as? Int {
            DispatchQueue.main.async {
                self.receivedIndex = index
                self.arhived.append(index)
            }
                replyHandler(["response": "Task \(index) received and processed successfully!"])
            }
        }
    
    
    
    func sendDataToWatch(tasks: [TaskModel]) async {
        guard WCSession.default.activationState == .activated else {
            print("WCSession is not activated.")
            return
        }
        
        guard WCSession.default.isReachable else {
            print("Watch is not reachable.")
            return
        }
        
        let taskData = tasks.map { task -> [String: Any] in
                return [
                    "taskName": task.taskName,
                    "isCompleted": task.isCompleted
                ]
            }
        
        do {
                let data = try JSONSerialization.data(withJSONObject: taskData, options: [])
                let message = ["taskData": data]
                
                WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
            } catch {
                print("Failed to encode task data: \(error)")
            }

    }
}
#endif

