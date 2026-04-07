import SwiftUI

struct ContentView: View {
    private typealias JSON = [String: Any]
    private enum ViewMode: String, CaseIterable, Identifiable {
        case classic = "Classic"
        case algorithm = "Algorithm"
        var id: String { rawValue }
    }
    private enum AlgorithmMode: String {
        case run
        case save
        case runSaved = "run_save"
        case delete
        case clearAll = "clear_all"
    }

    private struct Operation: Identifiable {
        let id: String
        let symbol: String
        let isUnary: Bool
    }
    private struct AlgStep: Identifiable {
        let id = UUID()
        let number: String
        let operation: String
    }
    private struct InputStyle {
        let fontSize: CGFloat
        let horizontalPadding: CGFloat
        let height: CGFloat
        let cornerRadius: CGFloat
    }

    private let endpoint = "http://127.0.0.1:54823/receive_data"
    private let operations: [Operation] = [
        .init(id: "addition", symbol: "+", isUnary: false),
        .init(id: "subtraction", symbol: "-", isUnary: false),
        .init(id: "multiplication", symbol: "x", isUnary: false),
        .init(id: "division", symbol: "÷", isUnary: false),
        .init(id: "percentage", symbol: "%", isUnary: false),
        .init(id: "power", symbol: "^", isUnary: false),
        .init(id: "square_root", symbol: "√", isUnary: true)
    ]

    @State private var num1: String = ""
    @State private var num2: String = ""
    @State private var resultField: String = ""
    @State private var algX: String = ""
    @State private var algStepNumber: String = ""
    @State private var algSaveName: String = ""
    @State private var algSteps: [AlgStep] = []
    @State private var mode: ViewMode = .classic
    @FocusState private var num1Focused: Bool

    @Environment(\.colorScheme) private var colorScheme
    private let columns = [GridItem(.fixed(58)), GridItem(.fixed(58)), GridItem(.fixed(58)), GridItem(.fixed(58))]
    private let compactColumns = [GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40)), GridItem(.fixed(40))]

    private var surfaceColor: Color { colorScheme == .dark ? .black : .white }
    private var displayColor: Color {
        colorScheme == .dark
            ? Color(red: 0.11, green: 0.11, blue: 0.11)
            : Color(red: 0.95, green: 0.95, blue: 0.96)
    }
    private var fieldColor: Color { colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.16) : .white }
    private var textColor: Color { colorScheme == .dark ? .white : .black }
    private var secondaryTextColor: Color { colorScheme == .dark ? .gray : .secondary }
    private var accentColor: Color { .orange }
    private var actionColor: Color { colorScheme == .dark ? Color(red: 0.27, green: 0.27, blue: 0.27) : Color(red: 0.90, green: 0.90, blue: 0.91) }
    private let contentAreaHeight: CGFloat = 300
    private var hasAlgSteps: Bool { !algSteps.isEmpty }
    private var hasAlgX: Bool { !trimmed(algX).isEmpty }
    private var hasAlgSaveName: Bool { !trimmed(algSaveName).isEmpty }
    private var lastAlgStepText: String? {
        guard let step = algSteps.enumerated().last else { return nil }
        return "\(step.offset + 1). \(operationLabel(step.element.operation)) \(step.element.number)"
    }
    private var canRunAlgorithm: Bool { hasAlgSteps && hasAlgX }
    private var canSaveAlgorithm: Bool { hasAlgSteps && hasAlgSaveName }
    private var canRunSavedAlgorithm: Bool { hasAlgSaveName && hasAlgX }


    private func operationPayload(for operation: Operation) -> JSON {
        [
            "mod": "op",
            "operation": operation.id,
            "num1": trimmed(num1),
            "num2": operation.isUnary ? "0" : trimmed(num2)
        ]
    }

    private func algorithmPayload(mode: AlgorithmMode, x: String? = nil, steps: JSON? = nil, saveName: String? = nil) -> JSON {
        var payload: JSON = ["mod": "alg", "alg_mod": mode.rawValue]
        if let x { payload["x"] = x }
        if let steps { payload["steps"] = steps }
        if let saveName { payload["alg_save_name"] = saveName }
        return payload
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func validateInputs(for operation: Operation) -> Bool {
        guard !trimmed(num1).isEmpty else {
            resultField = "Error: Number One is required"
            return false
        }
        if !operation.isUnary && trimmed(num2).isEmpty {
            resultField = "Error: Number Two is required"
            return false
        }
        return true
    }


    private func prefixedError(_ message: String) -> String {
        let clean = trimmed(message)
        return clean.lowercased().hasPrefix("error:") ? clean : "Error: \(clean)"
    }

    private func fieldName(from detailItem: [String: Any]) -> String {
        guard let loc = detailItem["loc"] as? [Any], let last = loc.last as? String else { return "field" }
        return last
    }

    private func invalidResponseText(from data: Data) -> String {
        let raw = String(data: data, encoding: .utf8) ?? ""
        return raw.isEmpty ? "Error: Invalid Response" : "Error: Invalid Response: \(raw)"
    }

    private func successText(from json: JSON) -> String? {
        guard let status = json["status"] as? String else { return nil }
        switch status {
        case "success":
            return "\(json["result"] ?? "")"
        case "saved":
            return "Saved: \(json["name"] ?? "")"
        case "deleted":
            return "Deleted: \(json["name"] ?? "")"
        case "all_clean":
            return "All saved algorithms cleared"
        default:
            return nil
        }
    }

    private func backendErrorMessage(from json: JSON) -> String {
        if let error = json["error"] as? String, !error.isEmpty {
            return prefixedError(error)
        }
        if let detail = json["detail"] as? String, !detail.isEmpty {
            return prefixedError(detail)
        }
        if let detailList = json["detail"] as? [[String: Any]] {
            let messages = detailList.compactMap { item -> String? in
                let type = item["type"] as? String
                let msg = item["msg"] as? String
                let field = fieldName(from: item)

                if type == "float_parsing" {
                    return "\(field) must be a valid number. Use '.' for decimals."
                }

                if let msg, !msg.isEmpty {
                    return "\(field): \(msg)"
                }
                return nil
            }
            if !messages.isEmpty { return prefixedError(messages.joined(separator: " | ")) }
        }
        if let status = json["status"] as? String, !status.isEmpty {
            return prefixedError("Request failed (\(status))")
        }
        return prefixedError("Unknown backend error")
    }

    private func responseMessage(from json: JSON) -> String {
        successText(from: json) ?? backendErrorMessage(from: json)
    }

    // MARK: - Transport

    private func makeRequest(with payload: JSON) -> URLRequest? {
        guard let url = URL(string: endpoint) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])
        return request
    }

    private func decodedResponseMessage(from data: Data?) -> String {
        guard let data else { return "Error: Server Offline" }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? JSON else {
            return invalidResponseText(from: data)
        }
        return responseMessage(from: json)
    }

    private func send(payload: JSON) {
        guard let request = makeRequest(with: payload) else { return }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.resultField = decodedResponseMessage(from: data)
            }
        }.resume()
    }

    // MARK: - Actions

    private func calculate(_ operation: Operation) {
        guard validateInputs(for: operation) else { return }
        send(payload: operationPayload(for: operation))
    }

    private func buildAlgStepsPayload() -> JSON {
        Dictionary(
            uniqueKeysWithValues: algSteps.enumerated().map { index, step in
                ("\(index + 1)", ["number": step.number, "operation": step.operation])
            }
        )
    }

    private func operationLabel(_ operation: String) -> String {
        operations.first(where: { $0.id == operation })?.symbol ?? operation
    }

    private func requireNonEmpty(_ value: String, message: String) -> String? {
        let clean = trimmed(value)
        guard !clean.isEmpty else {
            resultField = message
            return nil
        }
        return clean
    }

    private func addAlgStep(_ operationID: String) {
        guard let number = requireNonEmpty(algStepNumber, message: "Error: Step Number is required") else { return }
        algSteps.append(.init(number: number, operation: operationID))
        algStepNumber = ""
    }

    private func requireAlgSteps() -> Bool {
        guard hasAlgSteps else {
            resultField = "Error: Add at least one step"
            return false
        }
        return true
    }

    private func runAlgorithm() {
        guard requireAlgSteps(), let x = requireNonEmpty(algX, message: "Error: Start Value (x) is required") else { return }
        send(payload: algorithmPayload(mode: .run, x: x, steps: buildAlgStepsPayload()))
    }

    private func saveAlgorithm() {
        guard requireAlgSteps(), let name = requireNonEmpty(algSaveName, message: "Error: Save Name is required") else { return }
        send(payload: algorithmPayload(mode: .save, steps: buildAlgStepsPayload(), saveName: name))
    }

    private func runSavedAlgorithm() {
        guard let name = requireNonEmpty(algSaveName, message: "Error: Save Name is required"),
              let x = requireNonEmpty(algX, message: "Error: Start Value (x) is required") else { return }
        send(payload: algorithmPayload(mode: .runSaved, x: x, saveName: name))
    }

    private func deleteSavedAlgorithm() {
        guard let name = requireNonEmpty(algSaveName, message: "Error: Save Name is required") else { return }
        send(payload: algorithmPayload(mode: .delete, saveName: name))
    }

    private func clearClassicInputs() {
        num1 = ""
        num2 = ""
        resultField = ""
    }

    private func removeLastAlgorithmStep() {
        guard hasAlgSteps else { return }
        algSteps.removeLast()
    }

    // MARK: - UI

    private func styledInputField(_ placeholder: String, text: Binding<String>, style: InputStyle) -> some View {
        TextField(placeholder, text: text)
            .textFieldStyle(.plain)
            .font(.system(size: style.fontSize, weight: .medium, design: .rounded))
            .foregroundStyle(textColor)
            .padding(.horizontal, style.horizontalPadding)
            .frame(height: style.height)
            .background(fieldColor)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
    }

    private func operationGrid<ButtonView: View>(
        columns: [GridItem],
        spacing: CGFloat,
        @ViewBuilder button: @escaping (Operation) -> ButtonView
    ) -> some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(operations) { op in
                button(op)
            }
        }
    }

    private func displayPanel() -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(mode.rawValue)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(secondaryTextColor)
            Text(trimmed(resultField).isEmpty ? "0" : resultField)
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(textColor)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(displayColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func modeTabs() -> some View {
        Picker("Mode", selection: $mode) {
            ForEach(ViewMode.allCases) { viewMode in
                Text(viewMode.rawValue).tag(viewMode)
            }
        }
        .pickerStyle(.segmented)
    }

    private func calculatorPanel() -> some View {
        VStack(spacing: 10) {
            styledInputField("Number One", text: $num1, style: .init(fontSize: 16, horizontalPadding: 12, height: 38, cornerRadius: 12))
                .focused($num1Focused)
            styledInputField("Number Two", text: $num2, style: .init(fontSize: 16, horizontalPadding: 12, height: 38, cornerRadius: 12))
            operationGrid(columns: columns, spacing: 8) { operation in
                CalculatorButton(text: operation.symbol, foreground: .white, background: accentColor) {
                    calculate(operation)
                }
            }
            HStack(spacing: 10) {
                CalculatorButton(text: "C", foreground: textColor, background: actionColor, action: clearClassicInputs)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func algorithmPanel() -> some View {
        VStack(spacing: 8) {
            styledInputField("Start Value (x)", text: $algX, style: .init(fontSize: 13, horizontalPadding: 10, height: 30, cornerRadius: 10))
            styledInputField("Step Number", text: $algStepNumber, style: .init(fontSize: 13, horizontalPadding: 10, height: 30, cornerRadius: 10))
            styledInputField("Save Name", text: $algSaveName, style: .init(fontSize: 13, horizontalPadding: 10, height: 30, cornerRadius: 10))

            operationGrid(columns: compactColumns, spacing: 6) { operation in
                SmallRoundButton(text: operation.symbol, background: accentColor) {
                    addAlgStep(operation.id)
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Last Step (\(algSteps.count) total)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(secondaryTextColor)
                    if let lastAlgStepText {
                        Text(lastAlgStepText)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(textColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(10)
            }
            .frame(height: 56)
            .background(displayColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 8) {
                Menu {
                    Button("Run Algorithm", action: runAlgorithm)
                        .disabled(!canRunAlgorithm)
                    Button("Save Algorithm", action: saveAlgorithm)
                        .disabled(!canSaveAlgorithm)
                    Button("Run Saved", action: runSavedAlgorithm)
                        .disabled(!canRunSavedAlgorithm)
                    Button("Delete Saved", action: deleteSavedAlgorithm)
                        .disabled(!hasAlgSaveName)
                    Divider()
                    Button("Clear All Saved") {
                        send(payload: algorithmPayload(mode: .clearAll))
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 28)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                SmallActionButton(text: "Remove Last", background: accentColor, enabled: hasAlgSteps, action: removeLastAlgorithmStep)
            }
            .frame(height: 34)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    var body: some View {
        ZStack {
            surfaceColor.ignoresSafeArea()
            VStack(spacing: 12) {
                displayPanel()
                modeTabs()
                Group {
                    if mode == .classic {
                        calculatorPanel()
                    } else {
                        algorithmPanel()
                    }
                }
                .frame(maxWidth: .infinity, minHeight: contentAreaHeight, maxHeight: contentAreaHeight, alignment: .top)
            }
            .padding(12)
        }
        .frame(minWidth: 300, minHeight: 420)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { num1Focused = true }
        }
    }
}


struct CalculatorButton: View {
    var text: String
    var foreground: Color = .white
    var background: Color = .orange
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(foreground)
                .frame(width: 54, height: 54)
                .background(background)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct SmallActionButton: View {
    var text: String
    var background: Color
    var foreground: Color = .white
    var enabled: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(foreground)
                .frame(width: 82, height: 28)
                .background(enabled ? background : background.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.75)
        .buttonStyle(.plain)
    }
}

struct SmallRoundButton: View {
    var text: String
    var foreground: Color = .white
    var background: Color = .orange
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(foreground)
                .frame(width: 40, height: 40)
                .background(background)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDisplayName("Classic")
            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
#endif
