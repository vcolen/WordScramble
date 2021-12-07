//
//  ContentView.swift
//  WordScramble
//
//  Created by Victor Colen on 06/12/21.
//

import SwiftUI

struct ContentView: View {
    @State private var newWord = ""
    @State private var rootWord = ""
    @State private var allWords = [String]()
    
    @State private var usedWords = [String]()
    @State private var previousRootWords = [String]()
    @State private var previousScores = [Int]()
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .autocapitalization(.none)
                    }
                    
                    Section("Used Words") {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                    
                    Section("Previous Words") {
                        ForEach(0..<previousRootWords.count) { index in
                            HStack {
                                Image(systemName: "\(previousScores[index]).circle")
                                Text(previousRootWords[index])
                            }
                        }
                    }
                }
                Text("Your score: \(score)")
                    .font(.title)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Word") {
                    restartGame()
                }
            }
        }
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        return true
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Silkworm"
                score = 0
                return
            }
        }
        fatalError("Could not launch app because file start.txt was not found")
    }
    
    func restartGame() {
        storeScore()
        rootWord = allWords.randomElement()!
        score = 0
    }
    
    func storeScore() {
        previousRootWords.insert(rootWord, at: 0)
        print(previousRootWords.count)
        previousScores.insert(score, at: 0)
        print( previousScores.count)
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "Too short.", message: "Your word must be at least 3 characters long.")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "This is the root word!", message: "Stop cheating!")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Try another one")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell \(answer) from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "This word doesn't exist.", message: "You can't just create words.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        
        score += answer.count
        newWord = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
