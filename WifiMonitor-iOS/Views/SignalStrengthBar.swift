import SwiftUI

/// WiFi signal strength visualization bar
struct SignalStrengthBar: View {
    
    /// Signal strength (0.0 - 1.0)
    let strength: Double
    
    /// Bar height
    var height: CGFloat = 20
    
    /// Whether to show percentage label
    var showPercentage: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Bar background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color(.systemGray5))
                    .frame(height: height)
                
                // Bar fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(gradientColor)
                    .frame(width: geometry.size.width * CGFloat(strength), height: height)
                    .animation(.easeInOut(duration: 0.3), value: strength)
                
                // Optional percentage label
                if showPercentage {
                    Text("\(Int(strength * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 1)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .frame(height: height)
    }
    
    /// Gradient color based on signal strength
    private var gradientColor: LinearGradient {
        let percentage = Int(strength * 100)
        let colors: [Color]
        
        switch percentage {
        case 75...100:
            colors = [.green, .green.opacity(0.8)]
        case 50..<75:
            colors = [.yellow, .green]
        case 25..<50:
            colors = [.orange, .yellow]
        default:
            colors = [.red, .orange]
        }
        
        return LinearGradient(
            colors: colors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

/// Compact signal bar for watchOS and small spaces
struct CompactSignalBar: View {
    let strength: Double
    
    private let numberOfBars = 5
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<numberOfBars, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor(for: index))
                    .frame(width: 8, height: barHeight(for: index))
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let baseHeight: CGFloat = 8
        let increment: CGFloat = 4
        return baseHeight + (CGFloat(index) * increment)
    }
    
    private func barColor(for index: Int) -> Color {
        let threshold = Double(index + 1) / Double(numberOfBars)
        let isActive = strength >= threshold - 0.1
        
        if isActive {
            return signalColor
        } else {
            return Color(.systemGray4)
        }
    }
    
    private var signalColor: Color {
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

/// WiFi icon with animated signal strength
struct AnimatedWiFiIcon: View {
    let strength: Double
    let isConnected: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            if isConnected {
                // Animated WiFi waves
                ForEach(0..<3, id: \.self) { index in
                    WaveArc(index: index, strength: strength)
                        .opacity(arcOpacity(for: index))
                        .animation(.easeInOut(duration: 0.5), value: strength)
                }
                
                // Center dot
                Circle()
                    .fill(signalColor)
                    .frame(width: 8, height: 8)
                    .offset(y: 12)
            } else {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 30))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 40, height: 40)
    }
    
    private func arcOpacity(for index: Int) -> Double {
        let threshold = Double(index + 1) / 3.0
        return strength >= threshold ? 1.0 : 0.3
    }
    
    private var signalColor: Color {
        let percentage = Int(strength * 100)
        switch percentage {
        case 75...100: return .green
        case 50..<75: return .yellow
        case 25..<50: return .orange
        default: return .red
        }
    }
}

/// Single arc for WiFi icon
struct WaveArc: View {
    let index: Int
    let strength: Double
    
    var body: some View {
        Arc(startAngle: .degrees(225), endAngle: .degrees(315))
            .stroke(
                arcColor,
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: arcSize, height: arcSize)
    }
    
    private var arcSize: CGFloat {
        CGFloat(16 + (index * 10))
    }
    
    private var arcColor: Color {
        let threshold = Double(index + 1) / 3.0
        if strength >= threshold {
            let percentage = Int(strength * 100)
            switch percentage {
            case 75...100: return .green
            case 50..<75: return .yellow
            case 25..<50: return .orange
            default: return .red
            }
        }
        return Color(.systemGray4)
    }
}

/// Arc shape
struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = min(rect.width, rect.height) / 2
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Preview

#Preview("Signal Bar") {
    VStack(spacing: 20) {
        SignalStrengthBar(strength: 0.9)
        SignalStrengthBar(strength: 0.65)
        SignalStrengthBar(strength: 0.4)
        SignalStrengthBar(strength: 0.15)
    }
    .padding()
}

#Preview("Compact Signal") {
    HStack(spacing: 30) {
        CompactSignalBar(strength: 1.0)
        CompactSignalBar(strength: 0.6)
        CompactSignalBar(strength: 0.3)
    }
}
