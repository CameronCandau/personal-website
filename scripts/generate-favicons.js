const fs = require("fs")
const path = require("path")
const sharp = require("../ctf-quartz/node_modules/sharp")

const staticDir = path.resolve(__dirname, "..", "static")
const sourceSvg = path.join(staticDir, "favicon.svg")

const outputs = [
  { name: "favicon-16x16.png", size: 16 },
  { name: "favicon-32x32.png", size: 32 },
  { name: "apple-touch-icon.png", size: 180 },
  { name: "android-chrome-192x192.png", size: 192 },
  { name: "android-chrome-512x512.png", size: 512 },
]

function createIco(entries) {
  const header = Buffer.alloc(6)
  header.writeUInt16LE(0, 0)
  header.writeUInt16LE(1, 2)
  header.writeUInt16LE(entries.length, 4)

  const directory = Buffer.alloc(entries.length * 16)
  let offset = header.length + directory.length

  for (const [index, entry] of entries.entries()) {
    const size = entry.size === 256 ? 0 : entry.size
    const base = index * 16
    directory.writeUInt8(size, base)
    directory.writeUInt8(size, base + 1)
    directory.writeUInt8(0, base + 2)
    directory.writeUInt8(0, base + 3)
    directory.writeUInt16LE(1, base + 4)
    directory.writeUInt16LE(32, base + 6)
    directory.writeUInt32LE(entry.png.length, base + 8)
    directory.writeUInt32LE(offset, base + 12)
    offset += entry.png.length
  }

  return Buffer.concat([header, directory, ...entries.map((entry) => entry.png)])
}

async function renderPng(size, outputPath) {
  const png = await sharp(sourceSvg)
    .resize(size, size)
    .png()
    .toBuffer()

  await fs.promises.writeFile(outputPath, png)
  return png
}

async function main() {
  const icoEntries = []

  for (const output of outputs) {
    const outputPath = path.join(staticDir, output.name)
    const png = await renderPng(output.size, outputPath)
    if (output.size === 16 || output.size === 32) {
      icoEntries.push({ size: output.size, png })
    }
  }

  const faviconIco = createIco(icoEntries)
  await fs.promises.writeFile(path.join(staticDir, "favicon.ico"), faviconIco)
}

main().catch((error) => {
  console.error(error)
  process.exit(1)
})
