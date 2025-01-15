#if os(iOS)
import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var tasks: [TaskModel]
    @Binding var selectedDate: Date
    @Binding var tasksForSelectedDate: [TaskModel]
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.appearance.headerTitleColor = .blue
        calendar.appearance.weekdayTextColor = .red
        calendar.appearance.titleDefaultColor = colorScheme == .dark ? UIColor.white : UIColor.black
        calendar.firstWeekday = 1
        
        // Set initial scope to Month
        calendar.setScope(.month, animated: true)
        
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.reloadData()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(tasks: $tasks, selectedDate: $selectedDate, tasksForSelectedDate: $tasksForSelectedDate)
    }
    

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        @Binding var tasks: [TaskModel]
        @Binding var selectedDate: Date
        @Binding var tasksForSelectedDate: [TaskModel]

        init(tasks: Binding<[TaskModel]>, selectedDate: Binding<Date>, tasksForSelectedDate: Binding<[TaskModel]>) {
            _tasks = tasks
            _selectedDate = selectedDate
            _tasksForSelectedDate = tasksForSelectedDate
        }

        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            return tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: date) }.count
        }


        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            selectedDate = date
            tasksForSelectedDate = tasks.filter { Calendar.current.isDate($0.deadline, inSameDayAs: date) }
        }


        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {

            if tasks.contains(where: { Calendar.current.isDate($0.deadline, inSameDayAs: date) }) {
                return .blue
            }
            return nil
        }
    }
}
#endif
