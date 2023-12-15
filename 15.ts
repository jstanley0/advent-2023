const fs = require('fs')
const data = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split(",")

function hash(s: String) {
    let v = 0
    for(let i = 0; i < s.length; ++i) {
        v = ((v + s.charCodeAt(i)) * 17) & 0xFF
    }
    return v
}

console.log(data.map(d => hash(d)).reduce((m, v) => m + v))

type LensInfo = {label: string, focal_length: number}
type BoxContents = LensInfo[]
let boxes: BoxContents[] = []
for(let i = 0; i < 256; ++i)
    boxes.push([])

function printBoxContents() {
    boxes.forEach((box_contents, box_number) => {
        if (box_contents.length > 0) {
            console.log(`${box_number}: ${box_contents.map(lens_info => `[${lens_info.label} ${lens_info.focal_length}]`).join(" ")}`)
        }
    })
    console.log("--")
}

data.forEach(step => {
    //printBoxContents()
    const match = step.match(/(?<label>[a-z]+)(?<op>[=-])(?<fl>\d?)/)
    if (!match || typeof(match.groups) === 'undefined')
        throw new Error(`bad step: ${step}`)
    const { op, label, fl } = match.groups
    const box = hash(label)
    const focal_length = parseInt(fl)
    if (op == '-') {
        const index = boxes[box].findIndex(el => el.label == label)
        if (index >= 0)
            boxes[box].splice(index, 1)
    } else if (op == '=') {
        const index = boxes[box].findIndex(el => el.label == label)
        if (index >= 0)
            boxes[box][index].focal_length = focal_length
        else
            boxes[box].push({label, focal_length})
    }
})

let focusing_power = 0
boxes.forEach((box_contents, box_number) => {
    box_contents.forEach((lens_info, slot_number) => {
        focusing_power += (1 + box_number) * (1 + slot_number) * lens_info.focal_length
    })
})
console.log(focusing_power)