Verilog edge detect example
=======================

## Edge detect explanation
As you might have noticed on the button verilog exemplar the counter does not always increment by a single digit each time this is because the button is not as reliable as you might expect, there is lots of noise generated also, therefore we need a way to sort through this noise and instead create a single pulse. [Dr Saar Drimer describes this very well in his blogpost](https://www.boldport.com/blog/2015/4/3/edge-detect-ad-nauseam)

## Logic
We shall be using Saar's verilog.

![Alt Text](./diagram_clock.jpeg)

We can then attach a similar counter as to the previous counter to test. You can do this however you like, however I used another verilog file.
