import Cocoa

// Create app icon with WiFi symbol at exact pixel dimensions
func createAppIcon(size: Int, outputPath: String) {
    let cgSize = CGFloat(size)
    
    // Create bitmap representation at exact pixel size (not points)
    let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    
    bitmapRep.size = NSSize(width: cgSize, height: cgSize)
    
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    
    // Background gradient (blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0),  // #007AFF
        NSColor(red: 0.0, green: 0.3, blue: 0.8, alpha: 1.0)     // Darker blue
    ])
    
    // Draw rounded rect background
    let rect = NSRect(x: 0, y: 0, width: cgSize, height: cgSize)
    let cornerRadius = cgSize * 0.22 // iOS style rounded corners
    let path = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
    gradient?.draw(in: path, angle: -90)
    
    // Draw WiFi symbol using SF Symbols
    let config = NSImage.SymbolConfiguration(pointSize: cgSize * 0.5, weight: .medium)
    if let wifiSymbol = NSImage(systemSymbolName: "wifi", accessibilityDescription: nil)?.withSymbolConfiguration(config) {
        let symbolSize = wifiSymbol.size
        let x = (cgSize - symbolSize.width) / 2
        let y = (cgSize - symbolSize.height) / 2
        
        // Draw white WiFi symbol
        NSColor.white.setFill()
        wifiSymbol.draw(at: NSPoint(x: x, y: y), from: .zero, operation: .sourceOver, fraction: 1.0)
    }
    
    NSGraphicsContext.restoreGraphicsState()
    
    // Save as PNG
    if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
        try? pngData.write(to: URL(fileURLWithPath: outputPath))
        print("Created: \(outputPath) (\(size)x\(size) pixels)")
    }
}

// Generate iOS icon (1024x1024)
createAppIcon(size: 1024, outputPath: "WifiMonitor-iOS/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

// Generate watchOS icon (1024x1024)
createAppIcon(size: 1024, outputPath: "WifiMonitor-watchOS/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png")

print("Icons generated successfully!")
