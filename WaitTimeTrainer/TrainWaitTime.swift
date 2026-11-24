// TrainWaitTime.swift — run on a Mac with Xcode (Create ML is macOS-only).
//
//  Trains the wait-time regressor from training_data.csv and writes
//  WaitTimePredictor.mlmodel next to this script. Add the .mlmodel to the
//  QueueSense app target in Xcode; the app loads it at runtime if present
//  and otherwise uses the heuristic fallback in WaitTimePredictor.swift.
//
//  Run from Terminal (macOS):
//      swift TrainWaitTime.swift
//
//  Note: this file is a macOS command-line script, not part of the iOS app
//  target, so it is never compiled for iOS.
import CreateML
import Foundation

let scriptDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let csvURL = scriptDirectory.appendingPathComponent("training_data.csv")
let outputURL = scriptDirectory.appendingPathComponent("WaitTimePredictor.mlmodel")

do {
    let table = try MLDataTable(contentsOf: csvURL)
    print("Loaded \(table.size.rows) training rows, columns: \(table.columnNames)")

    let (trainingTable, testingTable) = table.randomSplit(by: 0.8, seed: 42)
    let regressor = try MLRegressor(
        trainingData: trainingTable,
        targetColumn: "waitMinutes"
    )
    let evaluation = regressor.evaluation(on: testingTable)
    print("Max error: \(evaluation.maximumError) min")
    print("Root mean squared error: \(evaluation.rootMeanSquaredError) min")

    var metadata = MLModelMetadata(
        author: "Himanshu Joshi",
        shortDescription: "Predicts cafeteria wait time in minutes from hour, active orders, item count and longest prep time.",
        version: "1.0"
    )
    metadata.license = "MIT"
    try regressor.write(to: outputURL, metadata: metadata)
    print("Wrote \(outputURL.path)")
    print("Add WaitTimePredictor.mlmodel to the QueueSense target in Xcode.")
} catch {
    print("Training failed: \(error)")
    exit(1)
}
