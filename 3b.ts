const fs = require('fs')
const schematic = (fs.readFileSync(process.stdin.fd, { encoding: 'utf8' }) as string)
    .split("\n")
    .filter(line => line.length > 0)

function isDigit(c: string): boolean {
    return c >= '0' && c <= '9'
}

function findAdjacentNumbers(y: number, x: number) : number[] {
    let nums: number[] = []

    function extractNumAt(y: number, x: number) {
        if (x >= 0 && x < schematic[y].length && isDigit(schematic[y][x])) {
            let x0 = x
            while (x0 >= 0 && isDigit(schematic[y][x0]))
                --x0
            ++x0
            let x1 = x
            while(x1 < schematic[y].length && isDigit(schematic[y][x1]))
                ++x1
            const num = parseInt(schematic[y].slice(x0, x1))
            nums.push(num)
        }

    }

    if (y > 0) {
        if (isDigit(schematic[y - 1][x])) {
            extractNumAt(y - 1, x)
        } else {
            extractNumAt(y - 1, x - 1)
            extractNumAt(y - 1, x + 1)
        }
    }
    extractNumAt(y, x - 1)
    extractNumAt(y, x + 1)
    if (y < schematic.length - 1) {
        if (isDigit(schematic[y + 1][x])) {
            extractNumAt(y + 1, x)
        } else {
            extractNumAt(y + 1, x - 1)
            extractNumAt(y + 1, x + 1)
        }
    }

    return nums
}

let sum = 0
for(let y = 0; y < schematic.length; ++y) {
    for(let x = 0; x < schematic[y].length; ++x) {
        const c = schematic[y][x]
        if (c == '*') {
            const nums = findAdjacentNumbers(y, x)
            if (nums.length == 2) {
                sum += nums[0] * nums[1]
            }
        }
    }
}

console.log(sum)