import CinderCone

public final class Instance {
    private let native: VkInstance

    public init(
        applicationName: String,
        applicationVersion: UInt32,
        engineName: String,
        engineVersion: UInt32,
        apiVersion: UInt32,
        layers: [String] = [],
        extensions: [String] = []
    )
    {
        var appInfo = VkApplicationInfo(
            sType: VK_STRUCTURE_TYPE_APPLICATION_INFO,
            pNext: nil,
            pApplicationName: applicationName,
            applicationVersion: applicationVersion,
            pEngineName: engineName,
            engineVersion: engineVersion,
            apiVersion: apiVersion
        )
        native = layers.withUTF8CStrings { (layerUTF8CStrings) -> VkInstance in
            extensions.withUTF8CStrings { (extensionUTF8CStrings) -> VkInstance in
                print("Layers: \(layerUTF8CStrings)")
                print("Extensions: \(extensionUTF8CStrings)")
                var createInfo = VkInstanceCreateInfo(
                    sType: VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
                    pNext: nil,
                    flags: 0,
                    pApplicationInfo: &appInfo,
                    enabledLayerCount: UInt32(layers.count),
                    ppEnabledLayerNames: layerUTF8CStrings,
                    enabledExtensionCount: UInt32(extensions.count),
                    ppEnabledExtensionNames: extensionUTF8CStrings
                )
                print("Begin: Create instance")
                var instance: VkInstance?
                let result = vkCreateInstance(&createInfo, nil, &instance)
                print("End: Create instance")

                if result != VK_SUCCESS {
                    if result == VK_ERROR_INCOMPATIBLE_DRIVER {
                        print("VK_ERROR_INCOMPATIBLE_DRIVER")
                    }

                    if result == VK_ERROR_EXTENSION_NOT_PRESENT {
                        print("VK_ERROR_EXTENSION_NOT_PRESENT")
                    }

                    fatalError("Failed to create Vulkan instance: \(result.rawValue)")
                }

                return instance!
            }
        }
    }

    deinit {
        vkDestroyInstance(native, nil)
    }
}

protocol UTF8CStringProtocol {
    var nulTerminatedUTF8: ContiguousArray<UInt8> { get }
}

extension String : UTF8CStringProtocol {}

extension Array where Element : UTF8CStringProtocol {
    func withUTF8CStrings<R>(_ body: @noescape (UnsafePointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R {
        var backingPointers = [UnsafeMutablePointer<UInt8>?]()
        var constPointers = [UnsafePointer<CChar>?]()
        var lengths = [Int]()

        backingPointers.reserveCapacity(count)
        constPointers.reserveCapacity(count)
        lengths.reserveCapacity(count)

        for string in self {
            print("\(string)")
            let cstring = string.nulTerminatedUTF8
            print("\(cstring)")
            let length = cstring.count
            print("\(cstring.count)")
            var backingPointer: UnsafeMutablePointer<UInt8>?

            cstring.withUnsafeBufferPointer {
                if let cstringPointer = $0.baseAddress {
                    print("Creating backing pointer")
                    backingPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
                    backingPointer!.initialize(from: cstringPointer, count: length)                    
                    print("Created backing pointer")
                }
                else {
                    backingPointer = nil
                }
            }

            var constPointer: UnsafePointer<CChar>?

            if let pointer = backingPointer {
                print("Creating const pointer")
                constPointer = UnsafePointer<CChar>(pointer)
                print("Created const pointer")
            }
            else {
                constPointer = nil
            }

            backingPointers.append(backingPointer)
            constPointers.append(constPointer)
            lengths.append(length)
        }

        defer {
            for (index, backingPointer) in backingPointers.enumerated() {
                let length = lengths[index]
                print("Cleanup 1")
                backingPointer?.deinitialize(count: length)
                print("Cleanup 2")
                backingPointer?.deallocate(capacity: length)
                print("Cleanup 3")
            }
        }

        return try body(&constPointers)
    }
}
