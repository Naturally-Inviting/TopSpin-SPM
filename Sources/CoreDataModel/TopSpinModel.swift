import Foundation
import CoreDataModelDescription
import CoreData

fileprivate let matchEntity: CoreDataEntityDescription = .entity(
    name: "MatchMO",
    managedObjectClass: MatchMO.self,
    attributes: [
        .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
        .attribute(name: "date", type: .dateAttributeType, isOptional: true),
        .attribute(name: "playerScore", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "opponentScore", type: .integer16AttributeType, isOptional: true)
    ],
    relationships: [
        .relationship(name: "workout", destination: "WorkoutMO", toMany: false, inverse: "match")
    ]
)

fileprivate let matchSettingEntity: CoreDataEntityDescription = .entity(
    name: "MatchSettingMO",
    managedObjectClass: MatchSettingMO.self,
    attributes: [
        .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
        .attribute(name: "createdDate", type: .dateAttributeType, isOptional: true),
        .attribute(name: "name", type: .stringAttributeType, isOptional: true),
        .attribute(name: "isWinByTwo", type: .booleanAttributeType, isOptional: true),
        .attribute(name: "isTrackingWorkout", type: .booleanAttributeType, isOptional: true),
        .attribute(name: "scoreLimit", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "serviceInterval", type: .integer16AttributeType, isOptional: true)
    ]
)

fileprivate let workoutEntity: CoreDataEntityDescription = .entity(
    name: "WorkoutMO",
    managedObjectClass: WorkoutMO.self,
    attributes: [
        .attribute(name: "id", type: .UUIDAttributeType, isOptional: true),
        .attribute(name: "startDate", type: .dateAttributeType, isOptional: true),
        .attribute(name: "endDate", type: .dateAttributeType, isOptional: true),
        .attribute(name: "activeCalories", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "heartRateAverage", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "heartRateMax", type: .integer16AttributeType, isOptional: true),
        .attribute(name: "heartRateMin", type: .integer16AttributeType, isOptional: true)
    ],
    relationships: [
        .relationship(name: "match", destination: "MatchMO", toMany: false, inverse: "workout")
    ]
)

fileprivate let modelDescription = CoreDataModelDescription(
    entities: [
        matchEntity,
        matchSettingEntity,
        workoutEntity
    ]
)

internal let topSpinModel = modelDescription.makeModel()
