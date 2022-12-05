//
//  ContentView.swift
//  Assistant GPT
//
//  Created by Luke Drushell on 12/4/22.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let key = API().key
    @State var prompt = ""
    @State var output: [String] = []
    @State private var jsonData = Data()
    
    init() {
            UITextView.appearance().backgroundColor = .clear
        }
    
    @State var sending: Bool = false
    @State var returning: Bool = false
    @State var spinning: Bool = false
    
    @State var messageLoading = false
    
    @FocusState var showKeyboard: Bool
    
    @State var pastPrompt = ""
    
    @State var promptCopy = ""
    
    func sendRequest(redo: Bool) {
        var input = "Tell me a joke about dolphins"
        if !redo {
            if promptCopy == "" { promptCopy = "Say: You forgot to ask me a question!" }
            pastPrompt = promptCopy
            input = promptCopy
            promptCopy = ""
        }
        
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json = ["model": "text-davinci-003", "prompt": "\(redo ? pastPrompt : input)", "temperature" : 0.7, "max_tokens" : 256, "top_p" : 1, "frequency_penalty" : 0, "presence_penalty" : 0] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                let decoded = try! decoder.decode(AIResponse.self, from: data)
                let message = decoded.choices?.first?.text ?? "Uh oh, something has gone wrong!"
                withAnimation {
                    messageLoading = false
                    output.append(message.cleanResponse())
                }
            }
        }.resume()
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading) {
                        ForEach(output, id: \.self, content: { response in
                            Text(response).padding()
                                .frame(width: UIScreen.main.bounds.width * 0.85)
                                .font(.headline)
                                .background(Color("purp"))
                                .cornerRadius(18)
                                .textSelection(.enabled)
                        })
                    }
                    if messageLoading {
                        LoadingSymbol()
                    }
                } .padding(.bottom, 150)
            }
            .onTapGesture {
                showKeyboard = false
            }
            .overlay(alignment: .bottom, content: {
                HStack {
                    if #available(iOS 16.0, *) {
                        TextEditor(text: $prompt)
                            .frame(minWidth: UIScreen.main.bounds.width * 0.8, minHeight: 60, maxHeight: 160)
                            .fixedSize(horizontal: false, vertical: true)
                            .scrollContentBackground(.hidden)
                            .padding(5)
                            .background(Color("purp"))
                            .cornerRadius(18)
                            .focused($showKeyboard)
                    } else {
                        // Fallback on earlier versions
                        TextEditor(text: $prompt)
                            .frame(minWidth: UIScreen.main.bounds.width * 0.8, minHeight: 60, maxHeight: 160)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(5)
                            .background(Color("purp"))
                            .cornerRadius(18)
                            .focused($showKeyboard)
                    }
                    VStack {
                        Button {
                            withAnimation(.easeIn) {
                                promptCopy = prompt
                                prompt = ""
                                sending = true
                                messageLoading = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                sendRequest(redo: false)
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: {
                                returning = true
                                sending = false
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                withAnimation(.easeOut) {
                                    returning = false
                                }
                            })
                        } label: {
                            FlyButton(icon: "arrow.up.circle.fill")
                        }
                        .offset(x: returning ? UIScreen.main.bounds.width * 1 : 0, y: sending ? -80 : 0)
                        Button {
                            spinning = true
                            sendRequest(redo: true)
                        } label: {
                            SpinButton(icon: "arrow.counterclockwise.circle.fill", rotating: $spinning)
                        }
                    }
                }
                .padding(6)
                .background(.regularMaterial)
                .cornerRadius(22)
                .padding()
            })
            .toolbar(content: {
                ToolbarItem(placement: .navigation, content: {
                    Image("OpenAI")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                })
            })
        } .onAppear(perform: {
            let example = pickExample()
            withAnimation {
                prompt = example
                pastPrompt = example
            }
        })
        .edgesIgnoringSafeArea(.top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AIResponse: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let prompt: String?
    let response: String?
    let choices: [Choices]?
    let usage: Usage?
}

struct Choices: Codable, Hashable {
    let text: String
    let index: Int
    let logprops: Int?
    let finish_reason: String
}

struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

extension String {
    func cleanResponse() -> String {
        var input = self
        if input.prefix(2) == "\n\n" {
            input.removeFirst(2)
        }
        let output = input
        return output
    }
}


func pickExample() -> String {
    let examples = ["Explain quantum physics in 30 words", "How does coffee work?", "Write a haiku about love", "What are the 3 most important tips for being a good public speaker?", "Give me a fun party game idea", "What is AI?"]
    return examples.randomElement() ?? "Explain quantum physics in 30 words"
}
