# advent_of_code_2019
Casually participating for fun! 

Lost on day 14 part 2, ended up looking at vinc's solution https://github.com/vinc/adventofcode/blob/master/ruby/2019/14/lib.rb
  - Can't believe I lost on this problem, though. Part 1 was extremely easy, then for some reason, I couldn't get part 2 for the life of me. Ended up coming up with my own solution, but whatever. Valuable lessons from this are
   1. Cleanly abstract code for easier understanding
   2. Take breaks, rubberduck, and understand the problem rather than just mindlessly tackling it. It's better to take thirty minutes to think rather than spend a few hours wandering aimlessly. Actively think, understand, and experiment instead of being mindless. It's embarassing to have been stumped and given up on such an easy problem in hindsight. 
   - All that needed to be understood on this problem is what needs to happen logically on each recursive step. 

I'm still going to participate, but focus more on refactoring my old code using Rubocop and looking at more experienced developers' solutions as guidance/inspiration upon completing a problem. 

Difficult moments so far:
1. The moons along every axis, not just individual moons
2. Intcode computer keeps state
3. Edgecase for intcode computer dealing with literal mode cases and relative base 
4. Dealing with calculating large amounts of fuel rather than just 1
5. Thought my Intcode computer was broken and gave up because I didn't want to refactor it-- it was fine. 

My issue on day 17 was that I didn't understand how the problem worked. Even after getting the solution and compressing it, I didn't know what to do. In the end, I just ran the solution input in my grid creator and after outputting all the various positions of where the robot went as a grid, it outputted the answer and crashed. (Since 742673 is out of chr's range). Eh, next time, break when output is nil so you can see what came before the nil...
