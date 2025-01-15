#if os(iOS)

import SwiftUI
import FSCalendar
import SwiftData

struct CalendarView: View {
    
    // TaskModel
    @Query var taskList: [TaskModel]
    @State var allTasks: [TaskModel] = []
    
    // Calendar
    @State private var tasksForSelectedDate: [TaskModel] = []
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            
            FSCalendarView(tasks: $allTasks, selectedDate: $selectedDate, tasksForSelectedDate: $tasksForSelectedDate)
                .frame(height: 300)
                .onChange(of: selectedDate) {
                    updateTasksForSelectedDate()
                }
            
            Text("Selected Date: \(formattedDate(selectedDate))")
                .font(.headline)
                .padding()
            
            showTaskDetails()
        }
        .padding()
        .onAppear {
            updateTasksForSelectedDate()
        }
    }
}

#Preview {
    CalendarView()
}

//MARK: Body

extension CalendarView{
    func createButton(task: TaskModel) -> some View{
        Button{
            task.isCompleted.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .stroke(task.isCompleted ? Color.blue : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    func showTaskDetails() -> some View{
        Group{
            if !tasksForSelectedDate.isEmpty {
                ScrollView {
                    ForEach(tasksForSelectedDate, id: \.self) { task in
                        HStack{
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Task: \(task.taskName)")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(task.isCompleted ? .green : .red)
                                    .frame(alignment: .leading)
                                if !task.taskDescription.isEmpty {
                                    Text("Description: \(task.taskDescription)")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Divider()
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 10)
                            
                            Spacer()
                            
                            createButton(task: task)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                Text("No tasks for this day")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

}

//MARK: Functions

extension CalendarView{
    func updateTasksForSelectedDate() {
        
        allTasks = taskList;
        
        tasksForSelectedDate = taskList.filter { Calendar.current.isDate($0.deadline, inSameDayAs: selectedDate) }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#endif
