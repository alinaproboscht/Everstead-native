import SwiftUI

// =====================================================
// EVERSTEAD 0.36
// ROOT CONNECTION
//
// Wraps the existing ContentView without replacing its
// established 3D interface.
// =====================================================

struct EversteadConnectedRootView: View {

    @StateObject private var runtime = EversteadRuntime()

    var body: some View {
        EversteadConnectedGameShell(runtime: runtime)
    }
}

private struct EversteadConnectedGameShell: View {

    @ObservedObject var runtime: EversteadRuntime

    var body: some View {
        ContentView()
            .environmentObject(runtime)
    }
}
