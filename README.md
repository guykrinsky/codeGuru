# codeGuru Extreme

[to the contest website](https://assault.cubers.net/download.html)

## Why i made this project
I participated in the 2021 codeGuru Extreme competition as HamsterAx.
Of course I made a lot diffrenet survivors and than test them against old participant's survivors to find which is the best.
I didn't want to delete them all because some of them were actually very creative and interesting, so I upload them to github.

## Explanation of our code
It would be very hard to explain the code to someone who doesn't familiar with the contest
but I would try to explain our code:

### First round
There are few things you want to achive with your survivor.
First, "bomb" as much as possible bytes for turn.
tactics like:
```asm
[bx], 0x90
add bx, 2
```
are bombing one byte per turn. by using the command 'call far', the survivor bombing 4 bytes per turn, much better.
Second, we want our sourviovr to change his ip register every some turn.
when using call farr the sourviovr actually bombing with his cs:ip. so we change the ip to be an ileagal move that would change our ip and "restart" the call far.

so the tactic is going like that:
1. copying the code who is "reastarting" the call far to the stack.
2. switch between the data segment regiser to stack segment register.
3. the sourviovr call far until he "bombs" himself.
4. the sourviovr bombs himself with "movsw" command. changing his ip and restarting the call farr.

### Second round
Our second round survivors were a better version of our first round sourviovr because they "bomb" the area in the same way.
But the most dramatic change was that after bombing with the call far
our sourviovrs checked if other sourviovrs bombed this area as well.
and if they bombed with call far, we read their ip and we took over their sourviovrs.

## What in this project
* hamsterAX - my group final codes.
* my_basic_codes and playground - some of my practice codes.
* basic_codes - vey basic codes of the contest.
* debugger - the real debugger of the contest.
* 2021 zombies - Code written by competition developers, competitors have to take over the code by reverse engineering.

## How to run the sourviovrs
there is two main ways to run the sourviovrs, or by the offline official contest debugger, or by the online one.
It is so much more easy to run on the online debugger.
[to the contest online debugger](https://shooshx.github.io/corewars8086_js/war/page.html)

## creadits
my teamates:
Hadar Shahar
Amit Farkash