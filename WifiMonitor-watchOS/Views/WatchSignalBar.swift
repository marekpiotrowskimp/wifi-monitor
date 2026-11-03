import SwiftUI

/// Compact signal strength bar for Apple Watch
struct WatchSignalBar: View {
    let strength: Double?
    
    private let numberOfBars = 5
    private let barWidth: CGFloat = 6
    private let spacing: CGFloat = 3
    
    var body: some View {
        if let strength = strength {
            HStack(spacing: spacing) {
                ForEach(0..<numberOfBars, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor(for: index, strength: strength))
                        .frame(width: barWidth, height: barHeight(for: index))
                }
            }
            .frame(height: 24)
        } else {
            // Signal not available
            HStack(spacing: 4) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.caption)
                Text("N/A")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
            .frame(height: 24)
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let minHeight: CGFloat = 6
        let maxHeight: CGFloat = 24
        let step = (maxHeight - minHeight) / CGFloat(numberOfBars - 1)
        return minHeight + (CGFloat(index) * step)
    }
    
    private func barColor(for index: Int, strength: Double) -> Color {
        let threshold = Double(index + 1) / Double(numberOfBars)
        let isActive = strength >= (threshold - 0.1)
        
        if isActive {
            return activeColor(for: strength)
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func activeColor(for strength: Double) -> Color {
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

/// Circular signal strength indicator for Apple Watch
struct WatchCircularSignal: View {
    let strength: Double?
    
    var body: some View {
        if let strength = strength {
            ZStack {
                // Background
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                
                // Fill
                Circle()
                    .trim(from: 0, to: CGFloat(strength))
                    .stroke(
                        signalGradient(for: strength),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: strength)
                
                // Value in center
                VStack(spacing: 0) {
                    Text("\(Int(strength * 100))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    Text("%")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 70, height: 70)
        } else {
            // Signal not available
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                
                VStack(spacing: 2) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 20))
                    Text("N/A")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
            }
            .frame(width: 70, height: 70)
        }
    }
    
    private func signalGradient(for strength: Double) -> AngularGradient {
        let percentage = Int(strength * 100)
        let colors: [Color]
        
        switch percentage {
        case 75...100:
            colors = [.green.opacity(0.8), .green]
        case 50..<75:
            colors = [.yellow.opacity(0.8), .green]
        case 25..<50:
            colors = [.orange.opacity(0.8), .yellow]
        default:
            colors = [.red.opacity(0.8), .orange]
        }
        
        return AngularGradient(
            colors: colors,
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360 * strength)
        )
    }
}

/// Mini WiFi icon with strength indicator
struct WatchWiFiIcon: View {
    let strength: Double?
    let isConnected: Bool
    
    var body: some View {
        if isConnected {
            Image(systemName: wifiIconName)
                .font(.system(size: 24))
                .foregroundStyle(signalColor)
                .symbolEffect(.pulse, options: .repeating, isActive: (strength ?? 0) < 0.25)
        } else {
            Image(systemName: "wifi.slash")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
        }
    }
    
    private var wifiIconName: String {
        guard let strength = strength else {
            return "wifi.exclamationmark"
        }
        let percentage = Int(strength * 100)
        switch percentage {
        case 67...100:
            return "wifi"
        case 34..<67:
            return "wifi"
        default:
            return "wifi"
        }
    }
    
    private var signalColor: Color {
        guard let strength = strength else {
            return .secondary
        }
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

// MARK: - Previews

#Preview("Signal Bar") {
    VStack(spacing: 20) {
        WatchSignalBar(strength: 0.9)
        WatchSignalBar(strength: 0.65)
        WatchSignalBar(strength: 0.4)
        WatchSignalBar(strength: 0.15)
        WatchSignalBar(strength: nil)
    }
    .padding()
}

#Preview("Circular Signal") {
    VStack(spacing: 20) {
        WatchCircularSignal(strength: 0.75)
        WatchCircularSignal(strength: nil)
    }
}
