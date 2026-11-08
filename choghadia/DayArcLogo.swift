// DayArcLogo.swift
// The eight-segment arc logo shared by the app icon, launch screen, and settings footer.

import SwiftUI

struct DayArcLogo: View {
    var size: CGFloat = 46

    // Segment colours — index 0 is the leftmost segment (starts at ~180° / left of arc).
    private let segmentColors: [Color] = [
        Color(hex: "3FBF9F"),  // 0  teal  (Favourable)
        Color(hex: "E26A8D"),  // 1  pink  (Hold off)
        Color(hex: "E26A8D"),  // 2  pink
        Color(hex: "C99A1E"),  // 3  gold  (Neutral)
        Color(hex: "3FBF9F"),  // 4  teal  ← sun sits here at 78.75°
        Color(hex: "3FBF9F"),  // 5  teal
        Color(hex: "E26A8D"),  // 6  pink
        Color(hex: "3FBF9F"),  // 7  teal
    ]

    var body: some View {
        Canvas { ctx, canvasSize in
            // All coordinates are expressed in the original 1024×1024 space,
            // then scaled uniformly to fit the Canvas size.
            let sc = canvasSize.width / 1024
            let cx = CGFloat(512) * sc        // arc centre x
            let cy = CGFloat(730) * sc        // arc centre y (near bottom of canvas)
            let r  = CGFloat(340) * sc        // arc radius
            let sw = CGFloat(52)  * sc        // segment stroke width
            let gap = 11.0                    // angular gap between segments, in degrees

            // ── 1. Rounded-rect background ───────────────────────────────────
            let bgPath = Path(roundedRect: CGRect(origin: .zero, size: canvasSize),
                              cornerRadius: 230 * sc)
            ctx.fill(bgPath, with: .color(Color(hex: "1F1A3D")))

            // ── 2. Eight arc segments ────────────────────────────────────────
            // The prototype defines angles in mathematical convention (y-up, CCW).
            // SwiftUI's addArc uses screen convention (y-down, CW).
            // Conversion: swiftUIAngle = −mathAngle
            //
            // Math start for segment i  = 180 − i×22.5 − gap/2
            // SwiftUI start             = i×22.5 + gap/2 − 180   (negated)
            for i in 0..<8 {
                let startDeg = Double(i)     * 22.5 + gap / 2 - 180
                let endDeg   = Double(i + 1) * 22.5 - gap / 2 - 180
                var seg = Path()
                seg.addArc(center: CGPoint(x: cx, y: cy),
                           radius: r,
                           startAngle: .degrees(startDeg),
                           endAngle:   .degrees(endDeg),
                           clockwise: true)
                ctx.stroke(seg,
                           with: .color(segmentColors[i]),
                           style: StrokeStyle(lineWidth: sw, lineCap: .round))
            }

            // ── 3. Horizon line ──────────────────────────────────────────────
            var hPath = Path()
            hPath.move(to:    CGPoint(x: 186 * sc, y: 800 * sc))
            hPath.addLine(to: CGPoint(x: 838 * sc, y: 800 * sc))
            ctx.stroke(hPath,
                       with: .color(Color(hex: "FBF7F0")),
                       style: StrokeStyle(lineWidth: 40 * sc, lineCap: .round))

            // ── 4. Sun (sits on segment 4 at math angle 78.75°) ──────────────
            // pt(78.75°): x = cx + r·cos(θ),  y = cy − r·sin(θ)
            let θ  = CGFloat(78.75 * .pi / 180)
            let sx = cx + r * cos(θ)
            let sy = cy - r * sin(θ)   // subtract because screen y increases downward

            func sunRect(_ radius: CGFloat) -> CGRect {
                CGRect(x: sx - radius * sc, y: sy - radius * sc,
                       width: radius * 2 * sc, height: radius * 2 * sc)
            }
            ctx.fill(Path(ellipseIn: sunRect(104)), with: .color(Color(hex: "1F1A3D"))) // ink halo
            ctx.fill(Path(ellipseIn: sunRect(84)),  with: .color(Color(hex: "F0A25B"))) // saffron
            ctx.fill(Path(ellipseIn: sunRect(54)),  with: .color(Color(hex: "FFE7B5"))) // cream core
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 230 * size / 1024, style: .continuous))
        .accessibilityHidden(true)
    }
}

#Preview {
    HStack(spacing: 20) {
        DayArcLogo(size: 46)
        DayArcLogo(size: 64)
        DayArcLogo(size: 120)
    }
    .padding()
    .background(Color(hex: "14102B"))
}
