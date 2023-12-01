const readline = require('readline');
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});
async function go() {
    let sum = 0
    for await (const line of rl) {
        const chars: string[] = [...line]
        const isDigit = (char: string) => (char >= '0' && char <= '9')
        const left = chars.find(char => isDigit(char)) ?? ''
        const right = chars.findLast(char => isDigit(char)) ?? ''
        sum += parseInt(left + right)
    }

    console.log(sum)
}

go()