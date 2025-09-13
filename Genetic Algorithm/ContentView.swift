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

struct Point: Hashable {
    let x: Int, y: Int
}


struct Chromosome {
    var moves: [Move]
    var fitness: Double = 0
    var currentPosition: Point
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

class GeneticPathfinder {
    let maze: Maze
    let populationSize = 5
    let pathLength = 50
    let mutationRate = 0.05
    let generations = 200
    
    init(maze: Maze) {
        self.maze = maze
    }
    
    func run() {
        var population = (0..<populationSize).map { _ in  createRandomChromosome() }
        
        for generation in 0..<generations {
            // Evaluate fitness
            for i in 0..<populationSize {
                population[i].fitness = evaluateFitness(population[i])
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
    private func evaluateFitness(_ chromosome: Chromosome) -> Double {
        var position = maze.start
        
        for move in chromosome.moves {
            position = maze.applyMove(position, move: move)
            if position == maze.goal {
                return 1.0 // perfect solution
            }
        }
        
        // Fitness score based on distance
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
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .onAppear {
            let maze = Maze(
                rows: 10,
                cols: 10,
                walls: [Point(x: 3, y: 3), Point(x: 3, y: 4), Point(x: 3, y: 5), Point(x: 1, y: 5), Point(x: 2, y: 5), Point(x: 0, y: 5)],
                start: Point(x: 0, y: 0),
                goal: Point(x: 9, y: 9)
            )
            
            
            for row in 0..<maze.rows {
                for col in 0..<maze.cols {
                    print(maze.isWall(Point(x: col, y: row)) ? "#" : ".", terminator: "")
                }
                print()
            }
            
            let solver = GeneticPathfinder(maze: maze)
            solver.run()
        }
    }
}

#Preview {
    ContentView()
}
