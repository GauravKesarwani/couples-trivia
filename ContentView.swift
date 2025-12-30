//
//  ContentView.swift
//  Couples Quiz Game
//
//  Created by Gaurav Kesarwani on 12/25/25.
//

import SwiftUI


enum QuizPhase: Hashable {
    case intro
    case userTurn
    case spouseTurn
    case finished
    case quizUser
    case finishedUserQuiz
    case quizSpouse
    case score
}


struct ShowScore: View {
    let currentPlayerName: String
    let nextPlayerName: String
    let userScore: Int
    let spouseScore: Int
    
    var body: some View {
     
        VStack(spacing: 24) {
            Text("Final Score")
                .font(Font.largeTitle.bold())
            Text("\(currentPlayerName) answered \(userScore) questions correctly.")
            Text("\(nextPlayerName) answered \(spouseScore) questions correctly.")
        }
        .foregroundColor(.white)
        .font(.system(size: 22, weight: .bold, design: .monospaced))
        
    }
    
    
 
}

struct QuizCard: View {
    let question: String
    let currentPlayerName: String
    let nextPlayerName: String
    let correctAnswer: String
    @State private var showAnswer: Bool = false
    let onSubmit: (Bool) -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                  Text(personalizeQuestion(question, userName: currentPlayerName))
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
               
                
                  
                   if (!showAnswer) {
                     Button("Reveal answer !") {
                       showAnswer = true
                     }
                   } else {
                       Text("The correct answer is: \(correctAnswer)")
                         .opacity(showAnswer ? 1 : 0)
                         .font(.title)
                         .foregroundColor(.white)
                       
                       Text("Was that correct?")
                         .foregroundColor(.white)
                         .font(.title)
                       HStack(spacing: 20) {
                         Button("Yes") {
                             onSubmit(true)
                             showAnswer = false
                         }
                         .buttonStyle(.borderedProminent)
                         Button("No", role: .destructive) {
                           onSubmit(false)
                           showAnswer = false
                         }.buttonStyle(.borderedProminent)
                  
                       }
                       .font(.system(size: 24))
                       .padding(15)
                       .foregroundStyle(.white)
                       .imageScale(.large)
                    }
                  
                
                 
            }
        }
    }
   
    
    
    func personalizeQuestion(_ question: String, userName: String) -> String {
        question.replacingOccurrences(
            of: "your",
            with: "\(userName)'s",
            options: [.caseInsensitive]
        )
        
    }
}

private extension View {
    @ViewBuilder
    func applyFocusBinding(_ focused: FocusState<ContentView.Field?>.Binding?, equals value: ContentView.Field?) -> some View {
        if let focused = focused, let value = value {
            self.focused(focused, equals: value)
        } else {
            self
        }
    }
}

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
//    I don't understand this code.
//    var focused: FocusState<ContentView.Field?>.Binding? = nil
//    var focusCase: ContentView.Field? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.white)
                .padding(.horizontal)

            TextField(placeholder, text: $text)
                .textFieldStyle(.roundedBorder)
                // .applyFocusBinding(focused, equals: focusCase)
        }
        .padding()
        .padding(.horizontal)
    }
}

struct QuestionView: View {
    let question: String
    @State private var answer: String = ""
    let onSubmit: (String) -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                FormField(title: question, placeholder: "Type your answer", text: $answer)
                Button("Next") {
                    onSubmit(answer)
                    answer = ""
                }
                .disabled(answer.isEmpty)
                .foregroundColor(.white)
                .background(answer.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                .buttonStyle(.borderedProminent)
               
            }
        }
    }
}

struct QuizFlowView: View {
    let userName: String
    let spouseName: String
    let questions: [String]

    @Binding var userFacts: [String]
    @Binding var spouseFacts: [String]
    @Binding var userResponses: [String]
    @Binding var spouseResponses: [String]
    @State private var userScore: Int = 0
    @State private var spouseScore: Int = 0

    @State private var phase: QuizPhase = .intro
    @State private var currentIndex = 0
    @State private var isUserTurn = true

    private var currentPlayerName: String {
        isUserTurn ? userName : spouseName
    }

    private var nextPlayerName: String {
        isUserTurn ? spouseName : userName
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack {
                switch phase {
                case .intro:
                    Section {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("It's \(currentPlayerName)'s turn.")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                            Text("Answer the questions as accurately as you can.")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                            Text("Later, \(nextPlayerName) will answer the same questions.")
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                            
                            Button("Start Quiz for \(currentPlayerName)") {
                                phase = isUserTurn ? .userTurn : .spouseTurn
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(20)
                        .foregroundColor(.white)
                      
                    }
                case .userTurn:
                    QuestionView(question: questions[currentIndex]) { answer in
                        handleAnswer(
                            answer,
                            responses: &userFacts,
                            nextPhase: .intro,
                            flipTurn: true
                        )
                    }
                    .navigationTitle("Question \(currentIndex + 1) of \(questions.count)")
                    
                case .spouseTurn:
                    QuestionView(question: questions[currentIndex]) { answer in
                        handleAnswer(
                            answer,
                            responses: &spouseFacts,
                            nextPhase: .finished,
                            flipTurn: true
                        )
                    }
                    .navigationTitle("Question \(currentIndex + 1) of \(questions.count)")
                    
                case .finished:
                   
                    Text("Let's quiz \(currentPlayerName) on \(nextPlayerName)'s facts")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        
                    Button("Begin Quiz") {
                        phase = .quizUser
                    }
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.accentColor))
                  
                    
                case .quizUser:
                    QuizCard(question: questions[currentIndex], currentPlayerName: nextPlayerName, nextPlayerName: currentPlayerName, correctAnswer: spouseFacts[currentIndex]) { score in
                        handleScore(score,
                                     isUser: true,
                                     nextPhase: .finishedUserQuiz, flipTurn: true)
                    }
                case .finishedUserQuiz:
                    Text("Let's quiz \(currentPlayerName) on \(nextPlayerName)'s facts")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                    Button("Begin Quiz") {
                        phase = .quizSpouse
                    }
            
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Color.accentColor))
                    
                case .quizSpouse:
                    QuizCard(question: questions[currentIndex], currentPlayerName: nextPlayerName, nextPlayerName: currentPlayerName, correctAnswer: userFacts[currentIndex]) { score in
                        handleScore(score,
                                    isUser: false,
                                     nextPhase: .score, flipTurn: true)
                    }
                case .score:
                    ShowScore(currentPlayerName: currentPlayerName, nextPlayerName: nextPlayerName, userScore: userScore, spouseScore: spouseScore)
                    
                }
            }
        }
    }

    // MARK: - Shared logic
    private func handleAnswer(
        _ answer: String,
        responses: inout [String],
        nextPhase: QuizPhase,
        flipTurn: Bool
    ) {
        responses.append(answer)
        currentIndex += 1

        if currentIndex == questions.count {
            currentIndex = 0
            if flipTurn {
                isUserTurn.toggle()   // 🔁 swap user ↔ spouse
            }
            phase = nextPhase
        }
    }
    
    
    private func handleScore(_ score: Bool,
                             isUser: Bool,
                             nextPhase: QuizPhase,
                             flipTurn: Bool) {
        
        if (score) {
            if (isUser) {
                userScore += 1
            } else {
                spouseScore += 1
            }
        }
        
        
        currentIndex += 1

        if currentIndex == questions.count {
            currentIndex = 0
            if flipTurn {
                isUserTurn.toggle()   // 🔁 swap user ↔ spouse
            }
            phase = nextPhase
        }
        
        
        
    }
    
    
  
}

struct ContentView: View {
    @State private var userName = ""
    @State private var spouseName = ""

    @State private var userFacts: [String] = []
    @State private var spouseFacts: [String] = []
    
    @State private var userResponses: [String] = []
    @State private var spouseResponses: [String] = []

    let questions = [
        "What is your favorite movie?",
        "What is your favorite vacation spot?",
        "What is your go-to comfort food?"
    ]
    
    enum Field {
        case username
    }
    
    @FocusState private var focusedField: Field?


    var body: some View {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        FormField(
                            title: "Your Name",
                            placeholder: "Enter your name",
                            text: $userName,
//                            focused: $focusedField,
//                            focusCase: .username
                        )
                        .onAppear { focusedField = .username }
                        
                        FormField(
                            title: "Spouse's Name",
                            placeholder: "Enter your spouse's name",
                            text: $spouseName
                        )
                        
                        // Start Game Button
                        NavigationLink {
                            QuizFlowView(
                                userName: userName,
                                spouseName: spouseName,
                                questions: questions,
                                userFacts: $userFacts,
                                spouseFacts: $spouseFacts,
                                userResponses: $userResponses,
                                spouseResponses: $spouseResponses
                            )
                        } label: {
                            Text("Start Game")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(userName.isEmpty || spouseName.isEmpty ? Color.accentColor.opacity(0.8) : Color.accentColor)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .padding(.horizontal)
                        }
                        .disabled(userName.isEmpty || spouseName.isEmpty)
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 20)
                }
                .navigationTitle("Couples Quiz")
            }
        }
    }
}


#Preview {
    ContentView()
}

