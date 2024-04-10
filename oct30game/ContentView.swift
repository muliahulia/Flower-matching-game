import SwiftUI

struct ContentView: View {
    @StateObject private var game = CardGameViewModel()
    @State private var showAlert = false
    @State private var showAlertT = false
    @State private var showStartingMenu = true
    let symbols = ["🌸", "🌺", "🌹", "🌼", "🪻", "🥀", "🌷", "🌻", "💐"]
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                if showStartingMenu {
                    Text("Flower Match")
                        .font(Font.custom("Copperplate", size: 40).bold())
                        .foregroundColor(Color.black)
                    Image("border")
                        .resizable()
                        .frame(width: 60.0, height: 60.0)
                    Spacer().frame(height: 30)
                    Button(action: {
                        game.newGame(withSymbols: symbols)
                        showStartingMenu = false
                    }) {
                        Text("Start Game")
                            .foregroundColor(.white)
                            .font(Font.custom("Copperplate", size: 20).bold())
                            .padding()
                    }
                    .background(Color.black)
                    .cornerRadius(20)
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Rules")
                            .foregroundColor(.white)
                            .font(Font.custom("Copperplate", size: 20).bold())
                            .padding()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("  Rules  "),
                            message: Text("Match the flowers together until there are no remaining cards!"),
                            dismissButton: .default(Text("Back to menu"))
                        )
                    }
                    .background(Color.black)
                    .cornerRadius(20)
                    
                    Button(action: {
                        showAlertT = true
                    }){
                        Text("Credits")
                            .foregroundColor(.white)
                            .font(Font.custom("Copperplate", size: 15))
                            .padding()
                    }
                    .alert(isPresented: $showAlertT) {
                        Alert(title: Text("Credits"), message: Text("Julia Smith"), dismissButton: .default(Text("Back to menu"))
                        )
                    }
                        .background(Color.black)
                        .cornerRadius(20)
                    
                }
                
                if !showStartingMenu {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 20) {
                        ForEach(game.cards) { card in
                            CardView(card: card, isFaceUp: game.isCardFaceUp(card)) {
                                game.choose(card)
                            }
                            .aspectRatio(2/3, contentMode: .fit)
                        }
                    }
                    .padding()
                    .alert(isPresented: $game.isGameWon) {
                        Alert(
                            title: Text("Congratulations!"),
                            message: Text("You've matched all the cards!"),
                            dismissButton: .default(Text("Back to menu")) {
                                game.newGame(withSymbols: symbols)
                                showStartingMenu = true
                            }
                        )
                    }
                }
            }
        }
    }
}
                              
                
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardView: View {
    let card: Card
    let isFaceUp: Bool
    let action: () -> Void

    
    var body: some View {
        VStack {
            ZStack {
                if isFaceUp {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white)
                        .background(Color.white)
                        .border(Color.black, width: 4)
                        Text(card.symbol)
                        .font(.largeTitle)
                } else {
                 
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(LinearGradient(gradient: Gradient(colors: [.cyan, .white]), startPoint: .top, endPoint: .bottom)
)
                        .background(Color.black)
                        .border(Color.black, width: 4)
            
                    Image("Flower")
                        .resizable()
                        .frame(width: 90.0, height: 110.0)
        
                }
        
            }
            .frame(width: 90, height: 105)
            .aspectRatio(contentMode: .fill)
            .onTapGesture(perform: action)
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    let symbol: String
    var isMatched = false
}

class CardGameViewModel: ObservableObject {
    @Published private(set) var cards = [Card]()
    private var faceUpCard: Card?
    @Published var isGameWon = false
    
    init() {
        newGame(withSymbols: [])
    }
    
    func newGame(withSymbols symbols: [String]) {
        cards = createDeck(symbols: symbols)
        cards.shuffle()
        faceUpCard = nil     // creating and shuffling da deck
        isGameWon = false
    }
    
    func choose(_ card: Card) {
        guard !isGameWon else { return }
        
        if let chosenIndex = cards.firstIndex(where: { $0.id == card.id }), !cards[chosenIndex].isMatched {
            
            if let potentialMatchIndex = faceUpCard == nil ? nil : cards.firstIndex(where: { $0.id == faceUpCard!.id }) {
                if cards[chosenIndex].symbol == cards[potentialMatchIndex].symbol {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                    if cards.allSatisfy ({ $0.isMatched }) {
                        isGameWon = true
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.cards[chosenIndex].isMatched = false
                        self.cards[potentialMatchIndex].isMatched = false
                    }
                }
                faceUpCard = nil
            } else {
                faceUpCard = cards[chosenIndex]
            }
            cards[chosenIndex].isMatched = true
        }
    }

    
    func isCardFaceUp(_ card: Card) -> Bool {
        return card.id == faceUpCard?.id || card.isMatched

    }
    
    private func createDeck(symbols: [String]) -> [Card] {
        var deck = [Card]()
        for symbol in symbols {
            deck.append(Card(symbol: symbol))
            deck.append(Card(symbol: symbol))
        }
        return deck
    }
}
