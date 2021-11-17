# codeGuru Extreme

[Link to contest website](https://codeguru.co.il/Xtreme/).

## Why i made this project
I participated in the 2021 codeGuru Extreme competition as HamsterAx.
Of course I made a lot different survivors and than test them against old participant's survivors to find which is the best.
I didn't want to delete them all because some of them were actually very creative and interesting, so I uploaded them to github.

## Explanation of our code
It would be very hard to explain the code we used in the contest to someone who doesn't familiar with the contest
but I would try to explain our code:

### First round
There are few things you want to achieve with your survivor.
First, "bomb" as much bytes as possible per turn.
Bombing survivors that use basic tactics like:
```asm
[bx], 0xcc
add bx, 2
```
The above survivor example is bombing one byte per turn.
By using the command 'call far', the survivor could bomb 4 bytes per turn, much better.

Second, we want our survivor to change his ip register from time to time.
When using call far the survivor actually bombing with his cs:ip. So we change the ip to be a legal move that would change our ip and "restart" the call far.

To summarize, the tactic is going like that:
1. Copying the code who is "reastarting" the call far to the stack.
2. Switch between the data segment regiser to stack segment register.
3. The survivor call far until he "bombs" himself.
4. The survivor bombs himself with "movsw" command. Changing his ip and restarting the call far.

### Second round
Our second round survivors were a better version of our first round survivor because they "bomb" the area in the same way.
But the most dramatic change was that after bombing with the call far
our survivors checked if other survivors bombed this area as well.
And if they bombed with call far, we read their ip and we took over their survivors.

## What in this project
* hamsterAX - my group final codes.
* my_basic_codes and playground - some of my practice codes.
* basic_codes - vey basic codes of the contest.
* debugger - the real debugger of the contest.
* 2021 zombies - Code written by competition developers, competitors have to take over the code by reverse engineering.

## How to run the survivors
There is two main ways to run the survivors, or by the offline official contest debugger, or by the online one.
It is so much more easy to run on the online debugger
([link to online debugger](https://shooshx.github.io/corewars8086_js/war/page.html)).

## Credits
my teamates:

Hadar Shahar

Amit Farkash