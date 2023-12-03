const fs = require('fs')
const schematic = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n")
    .filter(line => line.length > 0)

function checkCell(y: number, x: number) : boolean {
    if (x < 0 || x >= schematic[y].length)
        return false

    const c = schematic[y][x]
    if (c === '.' || (c >= '0' && c <= '9'))
        return false

    return true
}

function checkRow(y: number, x0: number, x1: number) : boolean {
    if (y < 0 || y >= schematic.length)
        return false

    for(let x = x0; x <= x1; ++x) {
        if (checkCell(y, x))
            return true
    }
    return false
}

function isPartNumber(y: number, x0: number, x1: number) : boolean {
    return checkCell(y, x0 - 1) ||
        checkCell(y, x1) ||
        checkRow(y - 1, x0 - 1, x1) ||
        checkRow(y + 1, x0 - 1, x1)
}

let sum = 0
function checkPartNumber(y: number, x0: number, x1: number) {
    if (!isPartNumber(y, x0, x1))
        return

    const number = parseInt(schematic[y].slice(x0, x1))
    console.log(`found part number ${number}`)
    sum += number
}

for(let y = 0; y < schematic.length; ++y) {
    let x0 : number | null = null
    for(let x = 0; x < schematic[y].length; ++x) {
        const c = schematic[y][x]
        if (c >= '0' && c <= '9') {
            if (x0 == null)
                x0 = x
        } else if (x0 != null) {
            checkPartNumber(y, x0, x)
            x0 = null
        }
    }
    if (x0) {
        checkPartNumber(y, x0, schematic[y].length)
    }
}

console.log(sum)