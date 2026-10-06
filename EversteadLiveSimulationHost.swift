import SwiftUI

// =====================================================
// EVERSTEAD 0.35
// LIVE SIMULATION HOST
// =====================================================

@MainActor
final class EversteadLiveSimulationHost: ObservableObject {
    let liveSimulation: EversteadLiveSimulation

    init(game: EversteadGame) {
        self.liveSimulation = EversteadLiveSimulation(game: game)
    }
}

struct EversteadLiveSimulationStatusView: View {
    @ObservedObject var live: EversteadLiveSimulation

    var body: some View {
        HStack(spacing: 10) {
            Label("\(live.simulation.residents.count)", systemImage: "person.3.fill")
            Label("\(live.simulation.households.count)", systemImage: "house.fill")
            Label("\(live.productionSites.count)", systemImage: "gearshape.2.fill")
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
