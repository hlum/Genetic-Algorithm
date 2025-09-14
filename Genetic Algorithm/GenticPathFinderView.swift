//
//  GenticPathFinderView.swift
//  Genetic Algorithm
//
//  Created by cmStudent on 2025/09/14.
//

import SwiftUI

struct ChromosomeView: Identifiable {
    let id = UUID()
    var moves: [Move]
    var fitness: Double = 0
    var currentPosition: Point
    var path: [Point]
    
    var color: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
    
    static func createRandomChromosome(moves: Int, start: Point = Point(x: 0, y: 0)) -> ChromosomeView {
        
        let moves = (0..<moves).map { _ in Move.allCases.randomElement()! }
        let path = moves.apply(from: start)
        
        return ChromosomeView(moves: moves, currentPosition: start, path: path)
    }
}


struct GenticPathFinderView: View {
    
    @State var chromosomes: [ChromosomeView] = [
        ChromosomeView.createRandomChromosome(moves: 100),
        ChromosomeView.createRandomChromosome(moves: 100),
        ChromosomeView.createRandomChromosome(moves: 100)
    ]
    
    @State var rows: Int = 30
    @State var cols: Int = 30
    @State var walls: Set<Point> = [
        Point(x: 1, y: 9),
        Point(x: 7, y: 20),
        Point(x: 29, y: 24),
        Point(x: 14, y: 16),
        Point(x: 16, y: 23),
        Point(x: 5, y: 1),
        Point(x: 26, y: 28),
        Point(x: 21, y: 1),
        Point(x: 18, y: 1),
        Point(x: 22, y: 3),
        Point(x: 9, y: 5),
        Point(x: 22, y: 28),
        Point(x: 4, y: 21),
        Point(x: 17, y: 11),
        Point(x: 7, y: 25),
        Point(x: 9, y: 10),
        Point(x: 21, y: 11),
        Point(x: 21, y: 26),
        Point(x: 25, y: 22),
        Point(x: 12, y: 9),
        Point(x: 13, y: 15),
        Point(x: 26, y: 7),
        Point(x: 11, y: 10),
        Point(x: 27, y: 11),
        Point(x: 1, y: 24),
        Point(x: 17, y: 10),
        Point(x: 11, y: 6),
        Point(x: 25, y: 24),
        Point(x: 23, y: 15),
        Point(x: 10, y: 1),
        Point(x: 9, y: 17),
        Point(x: 11, y: 9),
        Point(x: 17, y: 28),
        Point(x: 4, y: 15),
        Point(x: 20, y: 11),
        Point(x: 27, y: 21),
        Point(x: 25, y: 26),
        Point(x: 1, y: 21),
        Point(x: 10, y: 5),
        Point(x: 25, y: 19),
        Point(x: 21, y: 28),
        Point(x: 25, y: 21),
        Point(x: 27, y: 12),
        Point(x: 10, y: 23),
        Point(x: 25, y: 23),
        Point(x: 28, y: 28),
        Point(x: 5, y: 4),
        Point(x: 12, y: 11),
        Point(x: 14, y: 9),
        Point(x: 12, y: 25),
        Point(x: 1, y: 19),
        Point(x: 13, y: 9),
        Point(x: 26, y: 1),
        Point(x: 17, y: 23),
        Point(x: 17, y: 13),
        Point(x: 5, y: 28),
        Point(x: 27, y: 16),
        Point(x: 10, y: 17),
        Point(x: 17, y: 15),
        Point(x: 18, y: 19),
        Point(x: 22, y: 21),
        Point(x: 27, y: 9),
        Point(x: 17, y: 3),
        Point(x: 4, y: 9),
        Point(x: 17, y: 6),
        Point(x: 9, y: 3),
        Point(x: 20, y: 9),
        Point(x: 9, y: 7),
        Point(x: 5, y: 14),
        Point(x: 13, y: 28),
        Point(x: 11, y: 11),
        Point(x: 12, y: 1),
        Point(x: 20, y: 28),
        Point(x: 12, y: 3),
        Point(x: 24, y: 1),
        Point(x: 11, y: 3),
        Point(x: 8, y: 15),
        Point(x: 4, y: 28),
        Point(x: 19, y: 19),
        Point(x: 8, y: 1),
        Point(x: 7, y: 9),
        Point(x: 25, y: 20),
        Point(x: 6, y: 3),
        Point(x: 9, y: 1),
        Point(x: 10, y: 13),
        Point(x: 14, y: 28),
        Point(x: 27, y: 13),
        Point(x: 17, y: 9),
        Point(x: 5, y: 21),
        Point(x: 17, y: 19),
        Point(x: 15, y: 20),
        Point(x: 12, y: 28),
        Point(x: 8, y: 4),
        Point(x: 9, y: 21),
        Point(x: 16, y: 1),
        Point(x: 12, y: 23),
        Point(x: 24, y: 11),
        Point(x: 3, y: 19),
        Point(x: 6, y: 4),
        Point(x: 8, y: 9),
        Point(x: 5, y: 25),
        Point(x: 21, y: 21),
        Point(x: 2, y: 9),
        Point(x: 13, y: 3),
        Point(x: 28, y: 9),
        Point(x: 23, y: 9),
        Point(x: 6, y: 21),
        Point(x: 3, y: 1),
        Point(x: 1, y: 7),
        Point(x: 19, y: 1),
        Point(x: 11, y: 15),
        Point(x: 25, y: 28),
        Point(x: 7, y: 21),
        Point(x: 20, y: 1),
        Point(x: 28, y: 21),
        Point(x: 15, y: 12),
        Point(x: 7, y: 4),
        Point(x: 13, y: 13),
        Point(x: 7, y: 19),
        Point(x: 6, y: 1),
        Point(x: 11, y: 14),
        Point(x: 15, y: 14),
        Point(x: 2, y: 28),
        Point(x: 22, y: 17),
        Point(x: 20, y: 15),
        Point(x: 20, y: 7),
        Point(x: 13, y: 25),
        Point(x: 13, y: 16),
        Point(x: 15, y: 26),
        Point(x: 28, y: 13),
        Point(x: 12, y: 15),
        Point(x: 10, y: 15),
        Point(x: 15, y: 1),
        Point(x: 19, y: 25),
        Point(x: 9, y: 9),
        Point(x: 3, y: 17),
        Point(x: 1, y: 14),
        Point(x: 23, y: 17),
        Point(x: 8, y: 3),
        Point(x: 1, y: 12),
        Point(x: 18, y: 21),
        Point(x: 11, y: 1),
        Point(x: 27, y: 28),
        Point(x: 17, y: 1),
        Point(x: 13, y: 23),
        Point(x: 29, y: 8),
        Point(x: 17, y: 14),
        Point(x: 14, y: 7),
        Point(x: 19, y: 7),
        Point(x: 11, y: 13),
        Point(x: 27, y: 26),
        Point(x: 27, y: 7),
        Point(x: 5, y: 19),
        Point(x: 20, y: 26),
        Point(x: 20, y: 13),
        Point(x: 19, y: 9),
        Point(x: 2, y: 21),
        Point(x: 21, y: 23),
        Point(x: 13, y: 1),
        Point(x: 9, y: 13),
        Point(x: 26, y: 15),
        Point(x: 7, y: 28),
        Point(x: 27, y: 5),
        Point(x: 5, y: 6),
        Point(x: 28, y: 17),
        Point(x: 28, y: 3),
        Point(x: 29, y: 25),
        Point(x: 26, y: 9),
        Point(x: 25, y: 15),
        Point(x: 24, y: 9),
        Point(x: 23, y: 18),
        Point(x: 6, y: 17),
        Point(x: 0, y: 3),
        Point(x: 17, y: 22),
        Point(x: 29, y: 7),
        Point(x: 25, y: 18),
        Point(x: 19, y: 3),
        Point(x: 2, y: 5),
        Point(x: 25, y: 4),
        Point(x: 11, y: 19),
        Point(x: 1, y: 13),
        Point(x: 19, y: 26),
        Point(x: 15, y: 28),
        Point(x: 25, y: 9),
        Point(x: 24, y: 28),
        Point(x: 15, y: 16),
        Point(x: 14, y: 3),
        Point(x: 10, y: 19),
        Point(x: 4, y: 17),
        Point(x: 13, y: 12),
        Point(x: 15, y: 25),
        Point(x: 16, y: 13),
        Point(x: 17, y: 7),
        Point(x: 12, y: 21),
        Point(x: 15, y: 23),
        Point(x: 21, y: 7),
        Point(x: 27, y: 15),
        Point(x: 8, y: 25),
        Point(x: 17, y: 16),
        Point(x: 10, y: 25),
        Point(x: 8, y: 17),
        Point(x: 26, y: 21),
        Point(x: 22, y: 26),
        Point(x: 16, y: 16),
        Point(x: 25, y: 6),
        Point(x: 21, y: 19),
        Point(x: 18, y: 3),
        Point(x: 12, y: 17),
        Point(x: 1, y: 11),
        Point(x: 26, y: 24),
        Point(x: 24, y: 21),
        Point(x: 18, y: 26),
        Point(x: 27, y: 17),
        Point(x: 5, y: 9),
        Point(x: 23, y: 26),
        Point(x: 1, y: 15),
        Point(x: 23, y: 5),
        Point(x: 21, y: 25),
        Point(x: 18, y: 28),
        Point(x: 11, y: 5),
        Point(x: 4, y: 11),
        Point(x: 9, y: 15),
        Point(x: 3, y: 25),
        Point(x: 1, y: 23),
        Point(x: 23, y: 28),
        Point(x: 28, y: 2),
        Point(x: 22, y: 11),
        Point(x: 9, y: 19),
        Point(x: 27, y: 1),
        Point(x: 1, y: 4),
        Point(x: 25, y: 3),
        Point(x: 3, y: 11),
        Point(x: 2, y: 1),
        Point(x: 25, y: 7),
        Point(x: 3, y: 21),
        Point(x: 17, y: 26),
        Point(x: 25, y: 5),
        Point(x: 11, y: 21),
        Point(x: 17, y: 21),
        Point(x: 18, y: 11),
        Point(x: 1, y: 20),
        Point(x: 26, y: 3),
        Point(x: 20, y: 4),
        Point(x: 23, y: 21),
        Point(x: 19, y: 11),
        Point(x: 7, y: 11),
        Point(x: 18, y: 23),
        Point(x: 9, y: 25),
        Point(x: 15, y: 11),
        Point(x: 3, y: 6),
        Point(x: 3, y: 5),
        Point(x: 29, y: 6),
        Point(x: 26, y: 13),
        Point(x: 5, y: 8),
        Point(x: 19, y: 28),
        Point(x: 5, y: 17),
        Point(x: 1, y: 8),
        Point(x: 7, y: 15),
        Point(x: 5, y: 15),
        Point(x: 0, y: 9),
        Point(x: 21, y: 17),
        Point(x: 4, y: 1),
        Point(x: 28, y: 1),
        Point(x: 28, y: 11),
        Point(x: 11, y: 28),
        Point(x: 9, y: 23),
        Point(x: 26, y: 17),
        Point(x: 18, y: 15),
        Point(x: 23, y: 6),
        Point(x: 23, y: 23),
        Point(x: 14, y: 23),
        Point(x: 11, y: 17),
        Point(x: 15, y: 3),
        Point(x: 25, y: 16),
        Point(x: 4, y: 26),
        Point(x: 21, y: 24),
        Point(x: 25, y: 13),
        Point(x: 23, y: 11),
        Point(x: 21, y: 18),
        Point(x: 15, y: 7),
        Point(x: 23, y: 7),
        Point(x: 7, y: 24),
        Point(x: 15, y: 17),
        Point(x: 23, y: 14),
        Point(x: 7, y: 23),
        Point(x: 6, y: 28),
        Point(x: 21, y: 9),
        Point(x: 28, y: 5),
        Point(x: 7, y: 7),
        Point(x: 19, y: 13),
        Point(x: 7, y: 17),
        Point(x: 11, y: 7),
        Point(x: 17, y: 18),
        Point(x: 19, y: 15),
        Point(x: 5, y: 26),
        Point(x: 21, y: 15),
        Point(x: 23, y: 3),
        Point(x: 18, y: 4),
        Point(x: 26, y: 19),
        Point(x: 6, y: 26),
        Point(x: 4, y: 25),
        Point(x: 18, y: 25),
        Point(x: 2, y: 26),
        Point(x: 15, y: 9),
        Point(x: 10, y: 3),
        Point(x: 22, y: 1),
        Point(x: 11, y: 23),
        Point(x: 29, y: 28),
        Point(x: 13, y: 21),
        Point(x: 24, y: 23),
        Point(x: 3, y: 28),
        Point(x: 1, y: 17),
        Point(x: 1, y: 26),
        Point(x: 25, y: 17),
        Point(x: 19, y: 20),
        Point(x: 1, y: 5),
        Point(x: 14, y: 25),
        Point(x: 29, y: 5),
        Point(x: 24, y: 19),
        Point(x: 24, y: 3),
        Point(x: 29, y: 23),
        Point(x: 10, y: 28),
        Point(x: 4, y: 3),
        Point(x: 4, y: 19),
        Point(x: 25, y: 11),
        Point(x: 26, y: 26),
        Point(x: 7, y: 1),
        Point(x: 1, y: 25),
        Point(x: 2, y: 11),
        Point(x: 5, y: 13),
        Point(x: 19, y: 23),
        Point(x: 8, y: 11),
        Point(x: 10, y: 21),
        Point(x: 26, y: 23),
        Point(x: 0, y: 26),
        Point(x: 12, y: 19),
        Point(x: 2, y: 3),
        Point(x: 2, y: 15),
        Point(x: 16, y: 9),
        Point(x: 24, y: 26),
        Point(x: 16, y: 26),
        Point(x: 15, y: 13),
        Point(x: 15, y: 21),
        Point(x: 9, y: 28),
        Point(x: 3, y: 9),
        Point(x: 6, y: 11),
        Point(x: 24, y: 15),
        Point(x: 13, y: 11),
        Point(x: 13, y: 7),
        Point(x: 7, y: 18),
        Point(x: 8, y: 28),
        Point(x: 22, y: 9),
        Point(x: 25, y: 12),
        Point(x: 28, y: 4),
        Point(x: 3, y: 26),
        Point(x: 8, y: 7),
        Point(x: 1, y: 16),
        Point(x: 6, y: 15),
        Point(x: 21, y: 16),
        Point(x: 23, y: 19),
        Point(x: 11, y: 25),
        Point(x: 21, y: 3),
        Point(x: 17, y: 5),
        Point(x: 6, y: 9),
        Point(x: 23, y: 13),
        Point(x: 16, y: 28),
        Point(x: 4, y: 6),
        Point(x: 1, y: 28),
        Point(x: 23, y: 1),
        Point(x: 3, y: 15),
        Point(x: 16, y: 3),
        Point(x: 15, y: 19),
        Point(x: 18, y: 20),
        Point(x: 15, y: 18),
        Point(x: 5, y: 5),
        Point(x: 5, y: 3),
        Point(x: 17, y: 25),
        Point(x: 29, y: 9),
        Point(x: 10, y: 9),
        Point(x: 14, y: 15),
        Point(x: 13, y: 17),
        Point(x: 25, y: 1),
        Point(x: 1, y: 3),
        Point(x: 8, y: 10),
        Point(x: 20, y: 3),
        Point(x: 14, y: 1),
        Point(x: 7, y: 26)
    ]
    
    @State var start: Point = Point(x: 0, y: 0)
    @State var goal: Point = Point(x: 29, y: 29)
    
    @State private var stepIndex: Int = 0
    @State private var isRunning: Bool = false
    
    
    var body: some View {
        GeometryReader { proxy in
            let screenWidth = proxy.size.width - 10
            let screenHeight = proxy.size.height - 10
            
            let cellWidth = screenWidth / CGFloat(cols)
            let cellHeight = screenHeight / CGFloat(rows)
            
            VStack {
                ZStack {
                    Rectangle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(
                            width: screenWidth,
                            height: screenHeight
                        )
                    
                    
                    ForEach(Array(walls), id: \.self) { wall in
                        
                        Rectangle()
                            .fill(Color.black)
                            .frame(
                                width: cellWidth,
                                height: cellHeight
                            )
                            .position(
                                x: CGFloat(wall.x) * cellWidth + cellWidth / 2,
                                y: CGFloat(wall.y) * cellHeight + cellHeight / 2
                            )
                    }
                    
                    ForEach(chromosomes) { chromosome in
                        let position = positionForChromosome(chromosome, stepIndex: stepIndex)
                        
                        Circle()
                            .fill(chromosome.color)
                            .frame(width: cellWidth * 0.8, height: cellHeight * 0.8)
                            .position(
                                x: CGFloat(position.x) * cellWidth + cellWidth/2,
                                y: CGFloat(position.y) *  cellHeight + cellHeight/2
                            )
                            .animation(.easeInOut(duration: 0.3), value: position)
                        
                    }
                    
                    // Start
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: cellWidth, height: cellHeight)
                        .position(
                            x: CGFloat(start.x) * cellWidth + cellWidth / 2,
                            y: CGFloat(start.y) * cellHeight + cellHeight / 2
                        )
                    
                    // Goal
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: cellWidth, height: cellHeight)
                        .position(
                            x: CGFloat(goal.x) * cellWidth + cellWidth / 2,
                            y: CGFloat(goal.y) * cellHeight + cellHeight / 2
                        )
                }
                
                HStack {
                    Button(isRunning ? "Pause" : "Run") {
                        isRunning.toggle()
                        if isRunning { runAnimation() }
                    }
                    Button("Reset") {
                        stepIndex = 0
                        isRunning = false
                    }
                }
            }
        }
    }
    
    
    private func runAnimation() {
        Task {
            while isRunning && stepIndex < chromosomes.map(\.path.count).max() ?? 0 {
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
                stepIndex += 1
            }
            isRunning = false
        }
    }

    
    
    private func positionForChromosome(_ chromosome: ChromosomeView, stepIndex: Int) -> Point {
        
        if stepIndex < chromosome.moves.count {
            return chromosome.path[stepIndex]
        }
        return chromosome.path.last ?? chromosome.currentPosition
    }
}

#Preview {
    GenticPathFinderView()
}
