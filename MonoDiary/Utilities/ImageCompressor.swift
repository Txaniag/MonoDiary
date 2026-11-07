import UIKit

enum ImageCompressor {
    static func compress(_ image: UIImage, maxDimension: CGFloat = 1600, quality: CGFloat = 0.8) -> Data? {
        let size = image.size
        let maxSide = max(size.width, size.height)
        guard maxSide > maxDimension else {
            return image.jpegData(compressionQuality: quality)
        }
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
