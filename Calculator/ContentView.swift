import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var firstNumber: Double?
    @State private var currentOperation: OperationType? = nil
    @State private var isTypingNumber = false
    @State private var history: [HistoryEntry] = []
    @State private var showingHistory = false
    @State private var memoryStoredValue: Double = 0
    @State private var previousStates: [(display: String, firstNumber: Double?, currentOperation: OperationType?)] = []
    
    let buttons: [[CalculatorButton]] = [
        [.memoryClear, .memoryAdd, .memorySubtract, .memoryRecall],
        [.clear, .operation(.sin), .operation(.cos), .operation(.tan)],
        [.operation(.sinInverse), .operation(.cosInverse), .operation(.tanInverse), .operation(.log)],
        [.operation(.ln), .operation(.e), .operation(.pi), .operation(.power)],
        [.digit("7"), .digit("8"), .digit("9"), .operation(.divide)],
        [.digit("4"), .digit("5"), .digit("6"), .operation(.multiply)],
        [.digit("1"), .digit("2"), .digit("3"), .operation(.subtract)],
        [.digit("0"), .decimal, .equal, .operation(.add)]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            Button("Show History") {
                showingHistory.toggle()
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(history: $history)
            }
            Spacer()
            Text(display)
                .font(.largeTitle)
                .padding()
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            self.buttonTapped(button)
                        }) {
                            Text(button.title)
                                .font(.title)
                                .frame(width: self.buttonWidth(button: button), height: 80)
                                .background(button.backgroundColor)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                        }
                    }
                }
            }
        }.padding()
    }
    
    private func buttonWidth(button: CalculatorButton) -> CGFloat {
        return (UIScreen.main.bounds.width - 50) / 4
    }
    
    private func buttonTapped(_ button: CalculatorButton) {
        // Store current state for undo functionality
        previousStates.append((display, firstNumber, currentOperation))
        
        switch button {
        case .digit(let value):
            if isTypingNumber {
                display += value
            } else {
                display = value
                isTypingNumber = true
            }
        case .decimal:
            if !display.contains(".") {
                display += "."
                isTypingNumber = true
            } else if !isTypingNumber {
                display = "0."
                isTypingNumber = true
            }
        case .operation(let operation):
            if currentOperation != nil, firstNumber != nil {
                calculateResult()
            }
            if case .equal = button { // Correctly handle checking for .equal
                calculateResult()
            } else {
                firstNumber = Double(display)
                currentOperation = operation
                isTypingNumber = false
            }
        case .equal:
            calculateResult()
        case .clear:
            clearCalculator()
        case .e:
            display = "\(M_E)"
            isTypingNumber = false
        case .pi:
            display = "\(Double.pi)"
            isTypingNumber = false
        case .memoryAdd:
            memoryStoredValue += Double(display) ?? 0
        case .memorySubtract:
            memoryStoredValue -= Double(display) ?? 0
        case .memoryRecall:
            display = "\(memoryStoredValue)"
            isTypingNumber = true
        case .memoryClear:
            memoryStoredValue = 0
        }
    }

    private func calculateResult() {
        let secondNumber = Double(display) ?? 0
        guard let operation = currentOperation, let firstNumber = firstNumber else { return }
        
        let result: Double
        switch operation {
        case .add:
            result = firstNumber + secondNumber
        case .subtract:
            result = firstNumber - secondNumber
        case .multiply:
            result = firstNumber * secondNumber
        case .divide:
            result = secondNumber != 0 ? firstNumber / secondNumber : Double.nan // Use NaN to represent division by zero
        case .power:
            result = pow(firstNumber, secondNumber)
        default:
            result = performSingleValueOperation(operation: operation, value: firstNumber)
        }
        
        if !result.isNaN {
            display = "\(result)"
            let historyEntry = HistoryEntry(calculation: "\(firstNumber) \(operation.rawValue) \(secondNumber)", result: display)
            history.append(historyEntry)
        } else {
            display = "Error"
        }
        
        isTypingNumber = false
        currentOperation = nil
    }
        
    private func performSingleValueOperation(operation: OperationType, value: Double) -> Double {
        switch operation {
        case .sin:
            return sin(value)
        case .cos:
            return cos(value)
        case .tan:
            return tan(value)
        case .sinInverse:
            return asin(value)
        case .cosInverse:
            return acos(value)
        case .tanInverse:
            return atan(value)
        case .log:
            return value > 0 ? log10(value) : Double.nan
        case .ln:
            return value > 0 ? log(value) : Double.nan
        default:
            return Double.nan
        }
    }
    
    private func clearCalculator() {
        display = "0"
        firstNumber = nil
        currentOperation = nil
        isTypingNumber = false
        previousStates.removeAll()
    }
    
    private func undoLastAction() {
        if let prevState = previousStates.popLast() {
            display = prevState.display
            firstNumber = prevState.firstNumber
            currentOperation = prevState.currentOperation
            isTypingNumber = prevState.display != "0"
        }
    }
}



enum CalculatorButton: Hashable {
    case digit(String), operation(OperationType), equal, decimal, clear
    case memoryAdd, memorySubtract, memoryRecall, memoryClear // Add these lines
    case e, pi
    
    var title: String {
        switch self {
        case .digit(let value):
            return value
        case .operation(let type):
            return type.rawValue
        case .equal:
            return "="
        case .decimal:
            return "."
        case .clear:
            return "C"
        case .memoryAdd:
            return "M+"
        case .memorySubtract:
            return "M-"
        case .memoryRecall:
            return "MR"
        case .memoryClear:
            return "MC"
        case .e:
            return "e"
        case .pi:
            return "π"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .operation, .equal, .memoryAdd, .memorySubtract, .memoryRecall, .memoryClear:
            return .orange
        case .digit, .decimal, .e, .pi:
            return Color(.darkGray)
        case .clear:
            return .red
        }
    }
}


enum OperationType: String {
    case add = "+", subtract = "-", multiply = "*", divide = "/"
    case sin = "sin", cos = "cos", tan = "tan"
    case sinInverse = "sin⁻¹", cosInverse = "cos⁻¹", tanInverse = "tan⁻¹"
    case log = "log", ln = "ln", power = "^", e = "e", pi = "π"
}

#Preview {
    ContentView()
}
