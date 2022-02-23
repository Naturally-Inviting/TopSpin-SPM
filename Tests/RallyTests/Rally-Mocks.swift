//
//  File.swift
//  
//
//  Created by William Brandin on 5/13/21.
//

import Foundation
@testable import Rally

public extension RallyEnvironment {
    static var mocked: RallyEnvironment {
        RallyEnvironment(
            isWinByTwo: true,
            scoreLimit: 11,
            serveInterval: .two,
            teams: [
                RallyTeam.teamA,
                RallyTeam.teamB
            ]
        )
    }
}

public extension RallyMatchEnvironment {
    static var mocked: RallyMatchEnvironment {
        RallyMatchEnvironment(matchCount: 3, matchSettings: .mocked)
    }
}

public extension RallyTeam {
    static let teamA = RallyTeam(id: "teamA", teamName: "teamA")
    static let teamB = RallyTeam(id: "teamB", teamName: "teamB")
}
