import CoreGraphics

public struct PanelGeometry {
    public static func size(for screenFrame: CGRect) -> CGSize {
        CGSize(width: screenFrame.width * 0.5, height: screenFrame.height * 0.5)
    }

    public static func origin(for panelSize: CGSize, in screenFrame: CGRect) -> CGPoint {
        CGPoint(
            x: screenFrame.midX - panelSize.width * 0.5,
            y: screenFrame.midY - panelSize.height * 0.5
        )
    }

    public static func frame(for screenFrame: CGRect) -> CGRect {
        let size = self.size(for: screenFrame)
        let origin = self.origin(for: size, in: screenFrame)
        return CGRect(origin: origin, size: size)
    }
}
