// og.swift — 重畫分享卡片（1200×630 JPEG）。
// 原圖把「530 KB」燒進像素裡，尺寸一變圖就成了錯誤資訊；改成不會過期的說法。
// 用 CoreGraphics 直接畫，不引入任何影像處理依賴。
import AppKit

let W = 1200.0, H = 630.0
let bg = NSColor(srgbRed: 0x0B / 255, green: 0x0E / 255, blue: 0x14 / 255, alpha: 1)
let ink = NSColor(srgbRed: 0xE6 / 255, green: 0xED / 255, blue: 0xF3 / 255, alpha: 1)
let accent = NSColor(srgbRed: 0x46 / 255, green: 0xE8 / 255, blue: 0xA0 / 255, alpha: 1)
let soft = NSColor(srgbRed: 0x8B / 255, green: 0x96 / 255, blue: 0xA5 / 255, alpha: 1)

// 等寬字：跟網站的 --mono 一致（SF Mono 不一定可載入，退回 Menlo）
func mono(_ size: CGFloat, _ weight: NSFont.Weight = .regular) -> NSFont {
    NSFont(name: "SFMono-Bold", size: size)
        ?? NSFont(name: "Menlo-Bold", size: size)
        ?? NSFont.monospacedSystemFont(ofSize: size, weight: weight)
}
func monoRegular(_ size: CGFloat) -> NSFont {
    NSFont(name: "SFMono-Regular", size: size)
        ?? NSFont(name: "Menlo", size: size)
        ?? NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
}

// 明確開一張 1200×630 的點陣圖再畫：NSImage.lockFocus 會跟著螢幕的 2x 縮放，
// 產出 2400×1260 的檔案，跟 og:image:width/height 宣告的尺寸不符。
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(W), pixelsHigh: Int(H),
                                bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let ctx = NSGraphicsContext(bitmapImageRep: rep) else {
    FileHandle.standardError.write(Data("failed to create bitmap\n".utf8))
    exit(1)
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = ctx
bg.setFill()
NSRect(x: 0, y: 0, width: W, height: H).fill()

func draw(_ text: String, _ font: NSFont, _ color: NSColor, x: CGFloat, baselineFromTop: CGFloat,
          tracking: CGFloat = 0) {
    var attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    if tracking != 0 { attrs[.kern] = tracking }
    let s = NSAttributedString(string: text, attributes: attrs)
    // AppKit 的原點在左下角，但版面是從上往下量的
    s.draw(at: NSPoint(x: x, y: H - baselineFromTop - font.ascender))
}

let L = 84.0
draw("THE LIGHTWEIGHT G HUB & OPTIONS+ ALTERNATIVE", mono(26), accent, x: L, baselineFromTop: 96, tracking: 3.4)
draw("It's a mouse,", mono(92), ink, x: L, baselineFromTop: 178)
draw("not a platform.", mono(92), ink, x: L, baselineFromTop: 296)
draw("$ brew install nibble", mono(40), accent, x: L, baselineFromTop: 452)
draw("Nibble — under 1 MB Logitech mouse control for macOS · MIT", monoRegular(21), soft, x: L, baselineFromTop: 546)

NSGraphicsContext.restoreGraphicsState()

guard let jpeg = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92]) else {
    FileHandle.standardError.write(Data("failed to encode\n".utf8))
    exit(1)
}
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "og.jpg"
try jpeg.write(to: URL(fileURLWithPath: out))
print("wrote \(out) — \(jpeg.count) bytes")
