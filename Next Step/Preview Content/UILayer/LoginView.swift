import SwiftUI
import FirebaseAuth
import FirebaseCore
import SwiftData
import FirebaseFirestore


struct LoginView: View {
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isNavigated = false;
    @State private var isUserAuthenticated: Bool = false;
    @State private var isPresented: Bool = false;
    @State private var message: String = ""
    
    @AppStorage("userID") var userID: String?
    
    @State private var db: DatabaseManager = DatabaseManager()
    
    var body: some View {
            
        NavigationStack{
            VStack(spacing: 20) {
                Spacer()
                
                // Logo or Title (Optional)
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.bottom, 50)
                
                // Username TextField
                CustomTextField(placeholder: "email", text: $email)
                
                // Password SecureField
                CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                
                // Create Login and Sign up Link
                createNavigationLink()
                
            }
            #if os(macOS)
            .navigationDestination(isPresented: $isUserAuthenticated, destination: {
                HomeView()
            })
            #elseif os(iOS)
            .fullScreenCover(isPresented: $isUserAuthenticated, content: {
                HomeView()
            })
            #endif
            .padding(.horizontal, 30)
            .background(HelperClass.getSystemBackgroundColor())
            .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
            .alert("Button Alert", isPresented: $isPresented){
                Button("Ok", role: .cancel){}
            } message: {
                Text(message);
            }
        }
    }
}

// MARK: Password & Email Field

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding()
                    .background(HelperClass.dynamicBackgroundColor())
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 5)
                    .textFieldStyle(.plain)
            } else {
                TextField(placeholder, text: $text)
                    .padding()
                    .background(HelperClass.dynamicBackgroundColor())
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 5)
                    .textFieldStyle(.plain)
            }
                
        }
        .padding(.horizontal)
        .frame(height: 50)
    }
}

#Preview {
    LoginView()
}

// MARK: Body :
extension LoginView{
    
    func createNavigationLink() -> some View{
        Group{
            Button {
                if !email.isEmpty && !password.isEmpty {
                        login()
                }
                else{
                    message = "Email or password fields are empty"
                    isPresented.toggle()
                }
            } label: {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.top, 20)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            NavigationLink {
                SignUpForm()
                
            } label: {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .padding()
            
        }
    }
}

// MARK: DatabaseFunctions

extension LoginView{
    
    
    private func login(){
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    message = error.localizedDescription
                    isPresented.toggle()
                } else {
                    self.isUserAuthenticated = true
                    if let userIDFromDataBase = result?.user.uid{
                        loadAccount(uid: userIDFromDataBase)
                        userID = userIDFromDataBase
                    }
                }
            }
        }
    
    private func loadAccount(uid: String) -> Void{
        
        Task{
            try await fetchTasks(ID: uid)
            try await fetchTechniqueModel()
            TaskModel.saveDataToDevice(with: modelContext)
        }
    }
    
    func fetchTasks(ID: String) async throws{
        
        
        let taskList: [TaskModel] = try await db.fetchTasks(ID: ID)
        
        for task in taskList{
            modelContext.insert(task)
        }
    }
    
    func fetchTechniqueModel() async throws{
        
        let techinqueList:[TechniqueModel] = try await db.fetchTechniqueModel();
        
        for techinque in techinqueList{
            modelContext.insert(techinque)
        }
    }
}
