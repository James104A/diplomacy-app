import SwiftUI

// MARK: - Color-Blind Pattern Shapes
// Each power has a unique pattern overlay to distinguish territories by pattern alone.

struct PatternOverlay: View {
    let power: Power
    let size: CGSize

    var body: some View {
        Canvas { context, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height

            switch power.patternName {
            case "stripes":
                drawStripes(context: context, width: w, height: h)
            case "dots":
                drawDots(context: context, width: w, height: h)
            case "crosshatch":
                drawCrosshatch(context: context, width: w, height: h)
            case "chevrons":
                drawChevrons(context: context, width: w, height: h)
            case "diamonds":
                drawDiamonds(context: context, width: w, height: h)
            case "grid":
                drawGrid(context: context, width: w, height: h)
            case "waves":
                drawWaves(context: context, width: w, height: h)
            default:
                break
            }
        }
        .frame(width: size.width, height: size.height)
        .opacity(0.3)
    }

    // MARK: - Pattern Drawers

    private func drawStripes(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 6
        var x: CGFloat = -height
        while x < width + height {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + height, y: height))
            context.stroke(path, with: .color(.black), lineWidth: 1.5)
            x += spacing
        }
    }

    private func drawDots(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 8
        let radius: CGFloat = 1.5
        var y: CGFloat = spacing / 2
        var row = 0
        while y < height {
            var x: CGFloat = (row % 2 == 0) ? spacing / 2 : spacing
            while x < width {
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(.black))
                x += spacing
            }
            y += spacing
            row += 1
        }
    }

    private func drawCrosshatch(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 8
        // Diagonal lines in both directions
        var x: CGFloat = -height
        while x < width + height {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x + height, y: height))
            context.stroke(path, with: .color(.black), lineWidth: 0.8)

            var path2 = Path()
            path2.move(to: CGPoint(x: x + height, y: 0))
            path2.addLine(to: CGPoint(x: x, y: height))
            context.stroke(path2, with: .color(.black), lineWidth: 0.8)
            x += spacing
        }
    }

    private func drawChevrons(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 10
        let amplitude: CGFloat = 4
        var y: CGFloat = 0
        while y < height {
            var path = Path()
            var x: CGFloat = 0
            path.move(to: CGPoint(x: 0, y: y))
            while x < width {
                path.addLine(to: CGPoint(x: x + spacing / 2, y: y - amplitude))
                path.addLine(to: CGPoint(x: x + spacing, y: y))
                x += spacing
            }
            context.stroke(path, with: .color(.black), lineWidth: 1)
            y += spacing
        }
    }

    private func drawDiamonds(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 10
        let size: CGFloat = 3
        var y: CGFloat = spacing / 2
        var row = 0
        while y < height {
            var x: CGFloat = (row % 2 == 0) ? spacing / 2 : spacing
            while x < width {
                var path = Path()
                path.move(to: CGPoint(x: x, y: y - size))
                path.addLine(to: CGPoint(x: x + size, y: y))
                path.addLine(to: CGPoint(x: x, y: y + size))
                path.addLine(to: CGPoint(x: x - size, y: y))
                path.closeSubpath()
                context.stroke(path, with: .color(.black), lineWidth: 0.8)
                x += spacing
            }
            y += spacing
            row += 1
        }
    }

    private func drawGrid(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 8
        var x: CGFloat = 0
        while x < width {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
            context.stroke(path, with: .color(.black), lineWidth: 0.8)
            x += spacing
        }
        var y: CGFloat = 0
        while y < height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
            context.stroke(path, with: .color(.black), lineWidth: 0.8)
            y += spacing
        }
    }

    private func drawWaves(context: GraphicsContext, width: CGFloat, height: CGFloat) {
        let spacing: CGFloat = 10
        let amplitude: CGFloat = 3
        var y: CGFloat = 0
        while y < height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            var x: CGFloat = 0
            while x < width {
                path.addQuadCurve(
                    to: CGPoint(x: x + spacing / 2, y: y),
                    control: CGPoint(x: x + spacing / 4, y: y - amplitude)
                )
                path.addQuadCurve(
                    to: CGPoint(x: x + spacing, y: y),
                    control: CGPoint(x: x + 3 * spacing / 4, y: y + amplitude)
                )
                x += spacing
            }
            context.stroke(path, with: .color(.black), lineWidth: 1)
            y += spacing
        }
    }
}
