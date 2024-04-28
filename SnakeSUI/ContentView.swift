//
//  ContentView.swift
//  SnakeSUI
//
//  Created by Paul Makey on 28.04.24.
//

import SwiftUI

struct ContentView: View {
    
    // We will have a timer to control the snake's speed. To make the snake slover or faster, we can change the timer's intervals. The snake size is used instead of a grid. It will help us control the position of the snake and it's food.
    @State private var startPosition: CGPoint = .zero // start position of our swipe
    @State private var isStarted = true // did the user start the swipe?
    @State private var gameIsOver = false // for ending the game when the snake hits the screen borders
    @State private var direction = Direction.down // the direction the snake is going to take
    @State private var posArray = [CGPoint(x: 0, y: 0)] // array of snake's body positions
    @State private var foodPosition = CGPoint(x: 0, y: 0) // the position of the food
    
    // Function determines the position of our rectangles. To position the snake and food in an invisible grid, we need to utilize the snake size to find how many rows and columns we can have inside our view
    private let minX = UIScreen.main.bounds.minX
    private let maxX = UIScreen.main.bounds.maxX
    private let minY = UIScreen.main.bounds.minY
    private let maxY = UIScreen.main.bounds.maxY
    
    private let snakeSize: CGFloat = 10 // width & height of the snake
    private let timer = Timer.publish(
        every: 0.1,
        on: .main,
        in: .common
    ).autoconnect() // to update the snake position every 0.1 seconds
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ForEach(0..<posArray.count, id: \.self) { index in
                    Rectangle()
                        .frame(width: snakeSize, height: snakeSize)
                        .foregroundStyle(.white) // snake color
                        .position(posArray[index])
            }
            
            Rectangle()
                .fill(Color.red) // food color
                .frame(width: snakeSize, height: snakeSize)
                .position(foodPosition)
            
            if gameIsOver {
                VStack(spacing: 10) {
                    Text("Game Over")
                    Text("Your score: \(posArray.count - 1)")
                    
                    Button {
                        AppState.shared.gameID = UUID()
                    } label: {
                        Text("Try again!")
                            .foregroundStyle(.white)
                    }
                }
                .font(.largeTitle)
            }
        }
        .onAppear() {
            foodPosition = changeRectPosition()
            posArray[0] = changeRectPosition()
        }
        .gesture(DragGesture()
            .onChanged { gesture in
                if isStarted {
                    startPosition = gesture.location
                    isStarted.toggle()
                }
            }
            .onEnded { gesture in
                let xDist = abs(gesture.location.x - startPosition.x)
                let yDist = abs(gesture.location.y - startPosition.y)
                
                if startPosition.y < gesture.location.y && yDist > xDist {
                    direction = .down
                } else if startPosition.y > gesture.location.y && yDist > xDist {
                    direction = .up
                } else if startPosition.x > gesture.location.x && yDist < xDist {
                    direction = .right
                } else if startPosition.x < gesture.location.x && yDist < xDist {
                    direction = .left
                }
                
                isStarted.toggle()
            }
        )
        .onReceive(timer) { _ in
            if !gameIsOver {
                changeDirection()
                if posArray[0] == foodPosition {
                    posArray.append(posArray[0])
                    foodPosition = changeRectPosition()
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func changeDirection() {
        var prev = posArray[0]
        
        if posArray[0].x < minX || posArray[0].x > maxX && !gameIsOver {
            gameIsOver.toggle()
        } else if posArray[0].y < minY || posArray[0].y > maxY && gameIsOver {
            gameIsOver.toggle()
        }
        
        if direction == .down {
            posArray[0].y += snakeSize
        } else if direction == .up {
            posArray[0].y -= snakeSize
        } else if direction == .left {
            posArray[0].x += snakeSize
        } else {
            posArray[0].x -= snakeSize
        }
        
        for index in 1..<posArray.count {
            let current = posArray[index]
            posArray[index] = prev
            prev = current
        }
    }
    
    private func changeRectPosition() -> CGPoint {
        let rows = Int(maxX / snakeSize)
        let columns = Int(maxY / snakeSize)
        
        let randomX = Int.random(in: 1..<rows) * Int(snakeSize)
        let randomY = Int.random(in: 1..<columns) * Int(snakeSize)
        
        return CGPoint(x: randomX, y: randomY)
    }
}

#Preview {
    ContentView()
}

// MARK: - Direction
extension ContentView {
    enum Direction {
        case up
        case down
        case left
        case right
    }
}
