import SwiftUI

struct ContentView: View {
    @State private var num1: String = ""
    @State private var num2: String = ""
    @State private var resultField: String = ""


    private let columns = [
        GridItem(.fixed(60)),
        GridItem(.fixed(60)),
        GridItem(.fixed(60))
    ]

    // Packs the data to send to the server
    private func pack(n1: String, n2: String, calc: String) -> [String: Any] {
        [
            "mod": "op",
            "operation": calc,
            "num1": n1,
            "num2": n2
        ]
    }

    private func sendToPort(calc: String) {
        guard let url = URL(string: "http://127.0.0.1:54823/receive_data") else { return }
        let payload = pack(n1: num1, n2: num2, calc: calc)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                guard let data else {
                    // Controls
                    self.resultField = "Server Offline"
                    return
                }
                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self.resultField = "Invalid Response"
                    return
                }

                if let status = json["status"] as? String, status == "success" {
                    self.resultField = "\(json["result"] ?? "")"
                } else {
                    self.resultField = "\(json["error"] ?? "Error")"
                }
            }
        }.resume()
    }

    var body: some View {
        VStack {
            Text(resultField)
                .padding()

            TextField("Number One", text: $num1)
                .frame(width: 200, height: 40)
                .textFieldStyle(.roundedBorder)
            
            TextField("Number Two", text: $num2)
                .frame(width: 200, height: 40)
                .textFieldStyle(.roundedBorder)
            
            LazyVGrid(columns: columns, spacing: 10) {
                Group {
                    MathButton(text: "+") { sendToPort(calc: "addition") }
                    MathButton(text: "-") { sendToPort(calc: "subtraction") }
                    MathButton(text: "÷") { sendToPort(calc: "division") }
                    MathButton(text: "x") { sendToPort(calc: "multiplication") }
                    MathButton(text: "√") { sendToPort(calc: "square_root") }
                    MathButton(text: "%") { sendToPort(calc: "percentage") }
                    MathButton(text: "^") { sendToPort(calc: "power") }
                }
            }
        }
        .padding()
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
