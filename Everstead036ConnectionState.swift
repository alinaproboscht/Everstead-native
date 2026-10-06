import SwiftUI
import Combine

// =====================================================
// EVERSTEAD 0.36
// CONTENT VIEW BRIDGE
//
// IMPORTANT:
// The current ContentView 0.24 owns its EversteadGame
// internally. This bridge provides the migration point
// for the shared 0.36 runtime.
//
// To avoid silently running two EversteadGame instances,
// this file does NOT pretend the old ContentView is
// connected. The actual ContentView replacement must
// consume runtime.game before 0.36 can be called fully
// connected.
// =====================================================

@MainActor
enum Everstead036ConnectionState {
    static let requiresContentViewMigration = true
}
