import Foundation

let fm = FileManager.default
let home = NSHomeDirectory()
let downloads = "\(home)/Downloads"
let markerPath = "\(home)/.downloads-sorter.installed"
let logPath = "/tmp/downloads-sorter.log"

let df = DateFormatter()
df.dateFormat = "yyyy-MM-dd"
let today = df.string(from: Date())
let dest = "\(downloads)/downloaded_\(today)"

func log(_ msg: String) {
    let ts = ISO8601DateFormatter().string(from: Date())
    let line = "[\(ts)] \(msg)\n"
    if let data = line.data(using: .utf8) {
        if fm.fileExists(atPath: logPath) {
            if let h = FileHandle(forWritingAtPath: logPath) {
                h.seekToEndOfFile()
                h.write(data)
                try? h.close()
            }
        } else {
            try? data.write(to: URL(fileURLWithPath: logPath))
        }
    }
}

guard let markerAttrs = try? fm.attributesOfItem(atPath: markerPath),
      let markerDate = markerAttrs[.modificationDate] as? Date else {
    log("marker missing, abort")
    exit(0)
}

try? fm.createDirectory(atPath: dest, withIntermediateDirectories: true)

let skipExts: Set<String> = ["crdownload", "download", "part", "tmp"]

guard let entries = try? fm.contentsOfDirectory(atPath: downloads) else {
    log("cannot read downloads dir")
    exit(1)
}

for name in entries {
    if name.hasPrefix(".") { continue }
    let ext = (name as NSString).pathExtension.lowercased()
    if skipExts.contains(ext) { continue }

    let src = "\(downloads)/\(name)"
    var isDir: ObjCBool = false
    guard fm.fileExists(atPath: src, isDirectory: &isDir), !isDir.boolValue else { continue }

    guard let attrs = try? fm.attributesOfItem(atPath: src),
          let mtime = attrs[.modificationDate] as? Date else { continue }
    if mtime <= markerDate { continue }

    let target = "\(dest)/\(name)"
    if fm.fileExists(atPath: target) {
        log("skip (exists): \(name)")
        continue
    }

    do {
        try fm.moveItem(atPath: src, toPath: target)
        log("moved: \(name)")
    } catch {
        log("failed: \(name) — \(error.localizedDescription)")
    }
}
