import SwiftUI

struct CalorieCalculatorView: View {
    @State private var weight: Int = 50;
    @State private var height: Int = 100 // User's height input
    @State private var age: Int = 25 // User's age input
    @State private var calorieEstimate: String = "" // Estimated calorie needs
    @State private var selectedGender: String = "Male";
    @State private var selectedActivityLevel = "Moderately active"
    
    let genders = ["Male", "Female"]  // Options for the picker
    let activityLevels = ["Sedentary", "Lightly active", "Moderately active", "Very active", "Super active"]
    
    let activityMultipliers: [String: Double] = [
            "Sedentary": 1.2,
            "Lightly active": 1.375,
            "Moderately active": 1.55,
            "Very active": 1.725,
            "Super active": 1.9
        ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Calorie Calculator")
                .font(.largeTitle)
            
            createSection(textName: "Weight (KG) :", variable: $weight, startPont: 30, endPoint: 201)
            
            createSection(textName: "Height (CM) :", variable: $height, startPont: 50, endPoint: 221)
            
            createSection(textName: "Age :", variable: $age, startPont: 13, endPoint: 101)
            
            createSection(textName: "Gender :", variable: $selectedGender, values: genders)
            
            createSection(textName: "Activity Level :", variable: $selectedActivityLevel, values: activityLevels)

            
            if !calorieEstimate.isEmpty {
                Text("Estimated Calories: \(calorieEstimate)")
                    .font(.headline)
            }
            
            Spacer()

            Button("Calculate") {
                calculateCalories()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
            .buttonStyle(.plain)

        }
        .padding()
    }
}

#Preview{
    CalorieCalculatorView()
}


// MARK: Body
extension CalorieCalculatorView{
    func createSection(textName: String, variable: Binding<Int>, startPont: Int, endPoint: Int) -> some View{
        HStack{
            
            Text(textName)
            
            Spacer()
            
            Picker("", selection: variable){
                ForEach(Array(startPont..<endPoint), id: \.self) { number in
                    Text("\(number)").tag(number)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
            .frame(width: 400)
#elseif os(iOS)
            .pickerStyle(.inline)
            .frame(maxWidth: 260, maxHeight: 100)
#endif
        }
    }
    
    func createSection(textName: String, variable: Binding<String>, values: [String]) -> some View{
        HStack{
            
            Text(textName)
            
            Spacer()
            
            Picker("", selection: variable) {
                ForEach(values, id: \.self) { gender in
                    Text(gender)
                }
            }
#if os(macOS)
            .pickerStyle(.menu)
            .frame(width: 400)
#elseif os(iOS)
            .pickerStyle(.inline)
            .frame(maxWidth: 260, maxHeight: 100)
#endif
        }
    }
}

// MARK: Functions
extension CalorieCalculatorView{
    
    private func calculateCalories() {
        
        let weightFactor = 10 * Double(weight)
        let heightFactor = 6.25 * Double(height)
        let ageFactor = 5 * Double(age)
        let genderConstant: Double = (selectedGender == "Male") ? 5 : -161
        var bmr = weightFactor + heightFactor - ageFactor + genderConstant
        
        bmr = bmr * (activityMultipliers[selectedActivityLevel] ?? 1.55)
        
        calorieEstimate = String(format: "%.2f", bmr)
    }
    
}
