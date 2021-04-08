import CoreGraphics
import PencilKit

// based on the equation here https://www.freecodecamp.org/news/nerding-out-with-bezier-curves-6e3c0bc48e2f/
//
// t = 4 is about as low as one should go, higher the t the smoother the line will be
func cubicBezierCurve(leftAnchor: CGPoint, leftControlPoint: CGPoint, rightAnchor: CGPoint, rightControlPoint: CGPoint, points t: Int = 4) -> [CGPoint] {

    let p0x = leftAnchor.x
    let p1x = leftControlPoint.x
    let p2x = rightControlPoint.x
    let p3x = rightAnchor.x

    let p0y = leftAnchor.y
    let p1y = leftControlPoint.y
    let p2y = rightControlPoint.y
    let p3y = rightAnchor.y


    let points = (0...t).map { value -> CGPoint in
        // t needs to be between 0 and 1
        let t = CGFloat(value) / CGFloat(t)

        // Broke out the equation below because it will be reused for both x & y
        //
        // B(t)x = (1-t)^3 * p0x + 3(1-t)^2 * t * p1x + 3(1-t) * t^2 * p2x + t^3 * p3x
        // B(t)y = (1-t)^3 * p0y + 3(1-t)^2 * t * p1y + 3(1-t) * t^2 * p2y + t^3 * p3y

        let cubed = pow(CGFloat(1 - t), CGFloat(3))

        let squared = 3 * pow(CGFloat(1 - t), CGFloat(2)) * t

        let secondLast = 3 * (1 - t) * pow(CGFloat(t), CGFloat(2))

        let last = pow(CGFloat(t), CGFloat(3))

        let x: CGFloat = (cubed * p0x) + (squared * p1x) + (secondLast * p2x) + (last * p3x)

        let y: CGFloat = (cubed * p0y) + (squared * p1y) + (secondLast * p2y) + (last * p3y)

        return CGPoint(x: x, y: y)
    }

    return points
}

extension SVGPath {

    var cgPoints: [CGPoint] {
        var points = [CGPoint]()
        var startPoint: CGPoint = .zero

        // We want to add move first
        if let startPointCommand = commands.filter({ $0.type == .move }).first {
            // Need to set start point as it will be used for leftAnchor below
            startPoint = CGPoint(
                x: startPointCommand.point.x,
                y: startPointCommand.point.y
            )
            points.append(startPoint)
        }

        commands.forEach { command in
            // Only concerned about cube curve commands
            if case .cubeCurve = command.type {
                let cube = cubicBezierCurve(
                    leftAnchor: startPoint,
                    leftControlPoint: command.control1,
                    rightAnchor: command.point,
                    rightControlPoint: command.control2
                )
                // Set endpoint (rightAnchor) to startPoint so the next loop
                // will use this for the leftAnchor
                startPoint = command.point
                points.append(contentsOf: cube)
            }
        }
        return points
    }
}

extension Array where Element == SVGPath {

    var pkDrawing: PKDrawing {
        var strokes = [PKStroke]()

        forEach { path in
            let cgpoints = path.cgPoints.map { value in
                // Right now not worried about some of these values and have
                // just put in some random values for azimuth, altitude, timeOffset
                PKStrokePoint(
                    location: value,
                    timeOffset: .zero,
                    size: CGSize(width: 4, height: 4),
                    opacity: 1,
                    force: 1,
                    azimuth: 0.80,
                    altitude: 0.80
                )
            }

            let strokePath = PKStrokePath(
                controlPoints: cgpoints,
                creationDate: Date()
            )
            let stroke = PKStroke(
                ink: .init(.marker, color: .green),
                path: strokePath
            )

            strokes.append(stroke)
        }
        return PKDrawing(strokes: strokes)
    }
}

func svgPaths(resource: String) -> [SVGPath] {
    let parsed = SVGParser().parse(resource: resource)
    let path = parsed.paths.map { SVGPath($0) }
    return path
}

let pkDrawing052c9 = svgPaths(resource: "052c9").pkDrawing

// We could save this drawing as data and then save it locally or remotely
let data052c9 = pkDrawing052c9.dataRepresentation()

// Now since we have data all we need to do is toss the data into a PKDrawing
try PKDrawing(data: data052c9)




let pkDrawing05f37 = svgPaths(resource: "05f37").pkDrawing

// We could save this drawing as data and then save it locally or remotely
let data05f37 = pkDrawing05f37.dataRepresentation()

// Now since we have data all we need to do is toss the data into a PKDrawing
try PKDrawing(data: data05f37)
