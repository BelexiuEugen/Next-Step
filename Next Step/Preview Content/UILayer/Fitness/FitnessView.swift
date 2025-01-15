import SwiftUI
import SwiftData

struct FitnessView: View {
    @State private var isGoingToCalculator: Bool = false
    @State private var selectedTechnique: TechniqueModel?

    @Query var techniqueModelList: [TechniqueModel]

    // Modele
    private var beginnerTechniques: [TechniqueModel] {
        techniqueModelList.filter { $0.level == "Beginner" }
    }

    private var intermediateTechniques: [TechniqueModel] {
        techniqueModelList.filter { $0.level == "Intermediate" }
    }

    private var advancedTechniques: [TechniqueModel] {
        techniqueModelList.filter { $0.level == "Advanced" }
    }

    var body: some View {
        NavigationStack {
            List {
                // Beginner Techniques Section
                if !beginnerTechniques.isEmpty {
                    
                    createSection(
                        techniques: beginnerTechniques,
                        name: "Beginner Techniques",
                        textColor: Color.blue
                    )
                    
                }

                // Intermediate Techniques Section
                if !intermediateTechniques.isEmpty {
                    
                    createSection(
                        techniques: intermediateTechniques,
                        name: "Intermediate Techniques",
                        textColor: Color.orange
                    )
                    
                }

                // Advanced Techniques Section
                if !advancedTechniques.isEmpty {
                    
                    createSection(
                        techniques: advancedTechniques,
                        name: "Advanced Techniques",
                        textColor: Color.red
                    )
                    
                }
            }
            .listStyle(.inset) // Modern iOS/macOS list style
            .navigationTitle("Training Techniques")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    
                    Button {
                        isGoingToCalculator.toggle()
                    } label: {
                        Image(systemName: "fork.knife").foregroundColor(.primary)
                    }

                }
            }
            .sheet(item: $selectedTechnique) { technique in
                TechniqueDetailView(technique: technique)
            }
            .navigationDestination(isPresented: $isGoingToCalculator) {
                CalorieCalculatorView()
            }
        }
    }
}


struct TechniqueRow: View {
    let technique: TechniqueModel

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(technique.techniqueName)
                    .font(.body)
                    .fontWeight(.semibold)

                Text(technique.techniqueDetails)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

struct TechniqueDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    let technique: TechniqueModel

    var body: some View {
        
#if os(macOS)
        HStack{
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
#endif
        
        
        VStack(alignment: .leading, spacing: 16) {
            Text(technique.techniqueName)
                .font(.title)
                .fontWeight(.bold)
            
            Text(technique.techniqueDetails)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Technique Details")
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        FitnessView()
    }
}

//MARK: Functions
extension FitnessView{
    func createSection(techniques:[TechniqueModel], name: String, textColor: Color) -> some View{
        Section(header: Text(name).font(.headline).foregroundColor(textColor)) {
            ForEach(beginnerTechniques, id: \.id) { technique in
                Button {
                    selectedTechnique = technique
                } label: {
                    TechniqueRow(technique: technique)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}
