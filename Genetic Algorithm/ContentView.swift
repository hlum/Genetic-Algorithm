//
//  ContentView.swift
//  Genetic Algorithm
//
//  Created by cmStudent on 2025/09/13.
//

import SwiftUI

enum Move: String, CaseIterable {
    case up, down, left, right
}

extension Move {
    func apply(to point: Point) -> Point {
        switch self {
        case .up: return Point(x: point.x, y: point.y - 1)
        case .down: return Point(x: point.x, y: point.y + 1)
        case .left: return Point(x: point.x - 1, y: point.y)
        case .right: return Point(x: point.x + 1, y: point.y)
        }
    }
}

extension Array where Element == Move {
    func apply(from start: Point) -> [Point] {
        var path: [Point] = [start]
        var current = start
        for move in self {
            current = move.apply(to: current)
            path.append(current)
        }
        return path
    }
}


struct Point: Hashable {
    let x: Int, y: Int
}


struct Chromosome {
    var moves: [Move]
    var fitness: Double = 0
    var currentPosition: Point
    var path: [Point] = []
}


struct Maze {
    let rows: Int
    let cols: Int
    let walls: Set<Point>
    let start: Point
    let goal: Point
    
    
    init(rows: Int, cols: Int, walls: Set<Point>, start: Point, goal: Point) {
        self.rows = rows
        self.cols = cols
        self.walls = walls
        self.start = start
        self.goal = goal
    }
    
    func isInside(_ point: Point) -> Bool {
        point.x >= 0 && point.x < cols && point.y >= 0 && point.y < rows
    }
    
    func isWall(_ point: Point) -> Bool {
        walls.contains(point)
    }
    
    
    func applyMove(_ point: Point, move: Move) -> Point {
        var newPoint = point
        
        switch move {
        case .up:
            newPoint = Point(x: point.x, y: point.y - 1)
        case .down:
            newPoint = Point(x: point.x, y: point.y + 1)
        case .left:
            newPoint = Point(x: point.x - 1, y: point.y)
        case .right:
            newPoint = Point(x: point.x + 1, y: point.y)
        }
        
        if !isInside(newPoint) || isWall(newPoint) {
            return point
        }
        
        return newPoint
    }
    
    
}


// MARK: - Genetic Algorithm

class GeneticPathfinder: ObservableObject {
    @Published var maze: Maze
    let populationSize = 2
    @Published var pathLength = 50
    let mutationRate = 0.05
    @Published var generations = 2000
    
    @Published var population: [Chromosome] = []
    @Published var currentGeneration: Int = 0
    init(maze: Maze) {
        self.maze = maze
    }
    
    @MainActor
    func run() async {
        population = (0..<populationSize).map { _ in  createRandomChromosome() }
        for generation in 0..<generations {
            currentGeneration = generation

            // Evaluate fitness
            for i in 0..<populationSize {
                population[i].fitness = await evaluateFitness(&population[i])
            }
            
            
            population.sort { $0.fitness > $1.fitness }
            
            print("Gen \(generation): best fitness = \(population[0].fitness)")
            
            if population[0].fitness >= 1.0 {
                print("Path found at generation \(generation)!")
                for move in population[0].moves {
                    print(move.rawValue + "")
                }
                return
            }
            
            
            // Selection and Crossover
            var newPopulation: [Chromosome] = []
            newPopulation.append(population[0]) // Choose the chromosome with best fitness
            
            while newPopulation.count < populationSize {
                let parent1 = tournament(population)
                let parent2 = tournament(population)
                
                let child = crossover(parent1, parent2)
                let mutatedChild = mutate(child)
                
                newPopulation.append(mutatedChild)
            }
            
            population = newPopulation
        }
    }
    
    
    private func mutate(_ chromosome: Chromosome) -> Chromosome {
        var moves = chromosome.moves
        
        for i in 0..<moves.count {
            if Double.random(in: 0...1) < mutationRate {
                moves[i] = Move.allCases.randomElement()!
            }
        }
        return Chromosome(moves: moves, currentPosition: Point(x: 0, y: 0))
    }
    
    private func tournament(_ population: [Chromosome]) -> Chromosome {
        let contenders = (0..<3).map { _ in population.randomElement()! }
        return contenders.max(by: { $0.fitness < $1.fitness })!
    }
    
    
    private func crossover(_ a: Chromosome, _ b: Chromosome) -> Chromosome {
        let point = Int.random(in: 0..<pathLength)
        let moves = Array(a.moves[..<point]) + Array(b.moves[point...])
        return Chromosome(moves: moves, currentPosition: Point(x: 0, y: 0))
    }
    
    
    
    // TODO: Implement scoring fitness based on distance between goal and also not hitting wall
    private func evaluateFitness(_ chromosome: inout Chromosome) async -> Double {
        var position = maze.start
        chromosome.path = [position]

        for move in chromosome.moves {
            
            position = maze.applyMove(position, move: move)
            chromosome.currentPosition = position
            chromosome.path.append(position)

            await MainActor.run {
                self.objectWillChange.send()  // force UI refresh
            }

            if position == maze.goal {
                return 1.0
            }
        }

        let dx = abs(position.x - maze.goal.x)
        let dy = abs(position.y - maze.goal.y)
        let distance = Double(dx + dy)
        return 1.0 / (distance + 1.0)
    }

    
    private func createRandomChromosome() -> Chromosome {
        let moves = (0..<pathLength).map { _ in Move.allCases.randomElement()! }
        return Chromosome(moves: moves, currentPosition: Point(x: 0, y: 0))
    }
}

struct ContentView: View {
    @StateObject private var pathFinder = GeneticPathfinder(
        maze: Maze(
            rows: 30,
            cols: 30,
            walls: Set<Point>([
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
            ]),
            start: Point(x: 0, y: 0),
            goal: Point(x: 29, y: 29)
        )
    )
    
    var body: some View {
        VStack {
            Text("\(pathFinder.currentGeneration)")
            Button("Start") {
                Task { @MainActor in
                    await pathFinder.run()
                }
            }
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height
                
                VStack(spacing: 1) {
                    ForEach(0..<pathFinder.maze.rows, id: \.self) { rowIndex in
                        HStack(spacing: 1) {
                            ForEach(0..<pathFinder.maze.cols, id: \.self) { colIndex in
                                
                                ZStack {
                                    Rectangle()
                                        .fill(cellColor(point: Point(x: colIndex, y: rowIndex), maze: pathFinder.maze))
                                        .frame(
                                            width: screenWidth / CGFloat(pathFinder.maze.cols + 2),
                                            height: screenHeight / CGFloat(pathFinder.maze.rows + 2)
                                        )
                                    
                                    Rectangle()
                                        .fill(pathFinder.population.first?.path.contains(Point(x: colIndex, y: rowIndex)) == true ? .blue : .clear)

                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)

            }
        }
        .padding()
        .background(.black)
    }
    
    
    private func cellColor(point: Point, maze: Maze) -> Color {
        if maze.isWall(point) {
            return .black
        } else if maze.start == point {
            return .green
        } else if maze.goal == point {
            return .red
        }
        
        return .white
    }
}

#Preview {
    ContentView()
}
