const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});
async function go() {
    const digits : { [key: string]: string } = {
        "one": "1",
        "two": "2",
        "three": "3",
        "four": "4",
        "five": "5",
        "six": "6",
        "seven": "7",
        "eight": "8",
        "nine": "9"
    }
    let sum = 0
    for await (const line of rl) {
        const firstMatch = line.match(/[0-9]|one|two|three|four|five|six|seven|eight|nine/)[0]
        const lastMatch = line.split("").reverse().join("").match(/[0-9]|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin/)[0].split("").reverse().join("")
        const left = digits[firstMatch] || firstMatch
        const right = digits[lastMatch] || lastMatch
        const val = parseInt(left + right)
        console.log(`${line} => ${val}`)
        sum += val
    }

    console.log(sum)
}

go()