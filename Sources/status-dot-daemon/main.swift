import AppKit
import Darwin

// MARK: - Configuration

let port: UInt16 = {
    if let env = ProcessInfo.processInfo.environment["STATUS_DOT_PORT"],
       let p = UInt16(env) {
        return p
    }
    return 33192
}()

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var udpSource: DispatchSourceRead?
    private var sock: Int32 = -1

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupUDPListener()
    }

    // MARK: Status Item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.red.setFill()
            let dotSize: CGFloat = 8
            let dotRect = NSRect(
                x: (rect.width - dotSize) / 2,
                y: (rect.height - dotSize) / 2,
                width: dotSize,
                height: dotSize
            )
            NSBezierPath(ovalIn: dotRect).fill()
            return true
        }
        image.isTemplate = false
        statusItem.button?.image = image

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Hide", action: #selector(hideDot), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: ""))
        statusItem.menu = menu

        // Hide AFTER configuration is complete so button image is set
        statusItem.isVisible = false
    }

    @objc private func hideDot() {
        statusItem.isVisible = false
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: UDP Listener

    private func setupUDPListener() {
        sock = socket(AF_INET, SOCK_DGRAM, 0)
        guard sock >= 0 else {
            fputs("Failed to create socket\n", stderr)
            exit(1)
        }

        var addr = sockaddr_in()
        addr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let bindResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockPtr in
                Darwin.bind(sock, sockPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        guard bindResult == 0 else {
            fputs("Failed to bind to port \(port): \(String(cString: strerror(errno)))\n", stderr)
            close(sock)
            exit(1)
        }

        let source = DispatchSource.makeReadSource(fileDescriptor: sock, queue: .main)
        source.setEventHandler { [weak self] in
            self?.handleUDPData()
        }
        source.setCancelHandler { [weak self] in
            if let s = self?.sock, s >= 0 {
                close(s)
            }
        }
        source.resume()
        udpSource = source

        fputs("status-dot-daemon listening on 127.0.0.1:\(port)\n", stderr)
    }

    private func handleUDPData() {
        var buffer = [UInt8](repeating: 0, count: 256)
        let bytesRead = recv(sock, &buffer, buffer.count, 0)
        guard bytesRead > 0 else { return }

        let command = String(bytes: buffer[..<bytesRead], encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        switch command {
        case "show":
            statusItem.isVisible = true
        case "hide":
            statusItem.isVisible = false
        case "toggle":
            statusItem.isVisible.toggle()
        case "quit":
            NSApplication.shared.terminate(nil)
        default:
            fputs("Unknown command: \(command)\n", stderr)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        udpSource?.cancel()
    }
}

// MARK: - Main

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let delegate = AppDelegate()
app.delegate = delegate
app.run()
