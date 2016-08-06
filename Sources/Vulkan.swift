import CinderCone

public struct Vulkan {
    public static func makeVersion(major: UInt32, minor: UInt32, patch: UInt32) -> UInt32 {
        return (((major) << 22) | ((minor) << 12) | (patch))
    }

    public static let KHRSurfaceExtensionName = VK_KHR_SURFACE_EXTENSION_NAME
    public static let XCBSurfaceExtensionName = VK_KHR_XCB_SURFACE_EXTENSION_NAME
}
