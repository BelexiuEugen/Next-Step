import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct SignUpForm: View {
    
    //@Environment(\.dismiss) var dismiss

    @Environment(\.modelContext) var modelContext
    
    // Basic Informatio about the User
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    
    // Password related
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // Alert related.
    @State private var isPresented: Bool = false;
    @State private var message: String = ""
    
    
    @State private var isAccountCreated = false;
    
    
    @AppStorage("userID") var userID: String?
    
    var body: some View {
        
        NavigationStack{ 
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                createAccountLabel()
                
                // Name TextField
                CustomTextField(placeholder: "First Name", text: $name)
                
                // Surname TextField
                CustomTextField(placeholder: "Last Name", text: $surname)
                
                // Email TextField
                CustomTextField(placeholder: "Email", text: $email)
                
                // Password SecureField
                CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                
                // Confirm Password SecureField
                CustomTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                
                // Sign Up Button
                signUpButton()
                
                
                Spacer()
                
            }
            .padding(.horizontal, 30)
            .background(HelperClass.getSystemBackgroundColor())
            .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
            
            
            .navigationDestination(isPresented: $isAccountCreated) {
                HomeView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// Preview for macOS and iOS
#Preview {
    SignUpForm()
}

// MARK: Body Elements
extension SignUpForm{
    
    func createAccountLabel() -> some View{
        Text("Create Account")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.blue)
            .padding(.bottom, 50)
    }
    
    func signUpButton() -> some View {
        Button{
            if isDataValid(){
                Task{
                    
                    if await isAccountCreatedSuccesfully(){
                    
                       isAccountCreated.toggle()
                    }
                    else{
                        isPresented.toggle();
                    }
                }
            }
            else{
                isPresented.toggle()
            }
        } label: {
            signUpLabel()
        }
        .buttonStyle(.plain)
        .alert("Button Alert", isPresented: $isPresented){
            Button("Ok", role: .cancel){}
        } message: {
            Text(message);
        }
    }
    
    func signUpLabel() -> some View{
        Text("Sign Up")
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.top, 20)
    }
}

// MARK: Sign Up Verification
extension SignUpForm{
    
    func isDataValid() -> Bool{
        
        guard areTextFieldsValid() else{
            return false;
        }
        
        guard isPasswordValid() else {
            return false;
        }
        
        return true;
    }
    
    func areTextFieldsValid() -> Bool{
        
        guard name.count >= 2 && surname.count >= 2 else{
            message = "First name and last name must be at less 2 character long"
            return false;
        }
        
        guard name.count <= 50 else{
            message = "First name  must be shorter than 50 characters"
            return false;
        }
        
        guard surname.count <= 100 else{
            message = "Last name must be shorter than 100 charaters"
            return false;
        }
        
        guard email.count >= 5 else{
            message = "Email must be at less 5 charcter long"
            return false;
        }
        
        return true
    }
    
    func isPasswordValid() -> Bool {
        
        let uppercaseCount = password.filter { $0.isUppercase }.count
        let digitCount = password.filter { $0.isNumber }.count
        let symbolCount = password.filter { "!@#$%^&*()-_+=|\\{}[]:;\"'<>,.?/~`".contains($0) }.count
        
        guard password.count >= 12 && uppercaseCount >= 1 &&
                digitCount >= 1 && symbolCount >= 1 else{
            message = "Your password must have at less 1 upper Case Letter, at less 1 digit, and at less 1 symbol, and must be bigger than 12 character"
            return false;
        }
        
        guard password == confirmPassword else{
            message = "Passwords don't match"
            return false;
        }
        
        return true;
        
    }
}

// MARK: Register User
extension SignUpForm{
    
    func isAccountCreatedSuccesfully() async ->  Bool {
            do{
                try await createUser()
                
                return true;
                
            } catch {
                message = "Failed to create account: \(error.localizedDescription)"
            }
            return false;
        
    }
    
    func createUser() async throws{
        
        do {
            // Attempt to sign up the user
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            
            userID = uid;
            
        } catch let error as NSError {
            // Check for the specific error type
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                print("The email address is already in use. Please log in or choose another email.")
                // Optionally, redirect the user to the login screen
            } else {
                print("Error: \(error.localizedDescription)")
            }
        }
        
        
    }
}
