# masm-io

## Using String Primitives and Macros in MASM for I/O Functionality

The assembly program will ask a user for ten signed integers in succession. After each individual number is input, the program validates each number until all ten have been collected. Then, the program displays all ten numbers, their total sum, and the rounded average. 

Behind the scenes, the program makes use of data registers, the Irvine library, and its own macros to process the input data.


### Example:

```
Please provide 10 signed decimal integers.  
Each number needs to be small enough to fit inside a 32 bit register. 
After you have finished inputting the raw numbers I will display 
a list of the integers, their sum, and their average value. 

Please enter an signed number: 156
Please enter an signed number: 51d6fd 
ERROR: You did not enter a signed number or your number was too big. 
Please try again: 34 
Please enter a signed number: -186 
Please enter a signed number: 115616148561615630 
ERROR: You did not enter an signed number or your number was too big. 
Please try again: -145
Please enter a signed number: 5 
Please enter a signed number: +23 
Please enter a signed number: 51 
Please enter a signed number: 0 
Please enter a signed number: 56 
Please enter a signed number: 11 
 
You entered the following numbers: 
156, 34, -186, -145, 5, 23, 51, 0, 56, 11 
The sum of these numbers is: 5 
The rounded average is: 1 
 
```
