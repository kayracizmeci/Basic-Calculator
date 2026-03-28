import SwiftUI

struct ContentView: View {
    private struct Operation: Identifiable {
        let id: String
        let symbol: String
    }

    private struct AlgStep: Identifiable {
        let id = UUID()
        let number: String
        let operation: String
    }

    private let endpoint = "http://127.0.0.1:54823/receive_data"
    private let operations: [Operation] = [
        .init(id: "addition", symbol: "+"),
        .init(id: "subtraction", symbol: "-"),
        .init(id: "division", symbol: "÷"),
        .init(id: "multiplication", symbol: "x"),
        .init(id: "square_root", symbol: "√"),
        .init(id: "percentage", symbol: "%"),
        .init(id: "power", symbol: "^")
    ]
    @State private var num1: String = ""
    @State private var num2: String = ""
    @State private var resultField: String = ""
    @State private var algX: String = ""
    @State private var algStepNumber: String = ""
    @State private var algSaveName: String = ""
    @State private var algSteps: [AlgStep] = []
    @FocusState private var num1Focused: Bool
    private let columns = [GridItem(.fixed(60)), GridItem(.fixed(60)), GridItem(.fixed(60))]

    // Packs the data to send to the server
    private func pack(n1: String, n2: String, calc: String) -> [String: Any] {
        ["mod": "op", "operation": calc, "num1": n1, "num2": n2]
    }

    private func packAlg(_ mod: String, x: String? = nil, steps: [String: Any]? = nil, saveName: String? = nil) -> [String: Any] {
        var payload: [String: Any] = ["mod": "alg", "alg_mod": mod]
        if let x { payload["x"] = x }
        if let steps { payload["steps"] = steps }
        if let saveName { payload["alg_save_name"] = saveName }
        return payload
    }

    private func prefixedError(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.lowercased().hasPrefix("error:") ? trimmed : "Error: \(trimmed)"
    }

    private func fieldName(from detailItem: [String: Any]) -> String {
        guard let loc = detailItem["loc"] as? [Any], let last = loc.last as? String else { return "field" }
        return last
    }

    private func invalidResponseText(from data: Data) -> String {
        let raw = String(data: data, encoding: .utf8) ?? ""
        return raw.isEmpty ? "Error: Invalid Response" : "Error: Invalid Response: \(raw)"
    }

    private func statusText(from json: [String: Any]) -> String? {
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

    private func backendErrorMessage(from json: [String: Any]) -> String {
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

    private func send(payload: [String: Any]) {
        guard let url = URL(string: endpoint) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                guard let data else {
                    self.resultField = "Error: Server Offline"
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.resultField = invalidResponseText(from: data)
                    return
                }
                self.resultField = statusText(from: json) ?? backendErrorMessage(from: json)
            }
        }.resume()
    }

    private func buildAlgStepsPayload() -> [String: Any] {
        var steps: [String: Any] = [:]
        for (index, step) in algSteps.enumerated() {
            steps["\(index + 1)"] = [
                "number": step.number,
                "operation": step.operation
            ]
        }
        return steps
    }

    private func operationLabel(_ operation: String) -> String {
        operations.first(where: { $0.id == operation })?.symbol ?? operation
    }

    @ViewBuilder
    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text).frame(width: 200, height: 40).textFieldStyle(.roundedBorder)
    }

    @ViewBuilder
    private func operationGrid(action: @escaping (String) -> Void) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(operations) { op in
                MathButton(text: op.symbol) { action(op.id) }
            }
        }
    }

    private func addAlgStep(calc: String) {
        let stepNumber = algStepNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !stepNumber.isEmpty else {
            resultField = "Error: Step Number is required"
            return
        }
        algSteps.append(AlgStep(number: stepNumber, operation: calc))
        algStepNumber = ""
    }

    private func requireAlgX() -> String? {
        let value = algX.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else {
            resultField = "Error: Start Value (x) is required"
            return nil
        }
        return value
    }

    private func requireSaveName() -> String? {
        let name = algSaveName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            resultField = "Error: Save Name is required"
            return nil
        }
        return name
    }

    private func runAlgorithmSteps() {
        guard !algSteps.isEmpty else {
            resultField = "Error: Add at least one step"
            return
        }
        guard let x = requireAlgX() else { return }
        send(payload: packAlg("run", x: x, steps: buildAlgStepsPayload()))
    }

    private func saveAlgorithmSteps() {
        guard !algSteps.isEmpty else {
            resultField = "Error: Add at least one step"
            return
        }
        guard let saveName = requireSaveName() else { return }
        send(payload: packAlg("save", steps: buildAlgStepsPayload(), saveName: saveName))
    }

    private func runSavedAlgorithm() {
        guard let saveName = requireSaveName() else { return }
        guard let x = requireAlgX() else { return }
        send(payload: packAlg("run_save", x: x, saveName: saveName))
    }

    private func deleteSavedAlgorithm() {
        guard let saveName = requireSaveName() else { return }
        send(payload: packAlg("delete", saveName: saveName))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(resultField)
                .padding()

            field("Number One", text: $num1).focused($num1Focused)
            field("Number Two", text: $num2)
            operationGrid { send(payload: pack(n1: num1, n2: num2, calc: $0)) }

            Divider()
                .padding(.vertical, 6)

            Text("Algorithm Mode")
                .font(.headline)

            field("Start Value (x)", text: $algX)
            field("Step Number", text: $algStepNumber)
            field("Save Name", text: $algSaveName)
            operationGrid { addAlgStep(calc: $0) }

            ScrollView {
                VStack(alignment: .center, spacing: 6) {
                    Text("Steps: \(algSteps.count)")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                    if algSteps.count > 5 {
                        Text("… +\(algSteps.count - 5) earlier")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    ForEach(Array(algSteps.enumerated().suffix(5)), id: \.element.id) { pair in
                        Text("\(pair.offset + 1). \(operationLabel(pair.element.operation)) \(pair.element.number)")
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(minHeight: 120, maxHeight: 200)

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button("Run") {
                        runAlgorithmSteps()
                    }
                    Button("Save") {
                        saveAlgorithmSteps()
                    }
                    Button("Run Save") {
                        runSavedAlgorithm()
                    }
                }
                HStack(spacing: 8) {
                    Button("Delete") {
                        deleteSavedAlgorithm()
                    }
                    Button("Clear All") {
                        send(payload: packAlg("clear_all"))
                    }
                    Button("Remove Last") {
                        if !algSteps.isEmpty { algSteps.removeLast() }
                    }
                    .help("Remove the last step from the list")
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .frame(minWidth: 280)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { num1Focused = true }
        }
    }
}


// Button Design
struct MathButton: View {
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.title)
                .foregroundColor(.orange)
                .frame(width: 40, height: 30)
                .cornerRadius(15)
        }
    }
}
