#include <stdio.h>


extern int addstr(char*, char*);
extern int is_palindrome(char*, int);
extern int factstr(char*);
extern void palindrome_check();

int isPalindrome(char*);
int fact(int n);

int main()
{
    char input[1024];
    int result;

    while (1) //while true is not real ;_;
    {
        printf("\nMenu\n");
        printf("1. Add two numbers together\n");
        printf("2. Test if a string is a palindrome (C -> ASM)\n");
        printf("3. Print the factorial of a number\n");
        printf("4. Test if a string is a palindrome (ASM -> C)\n");
        printf("5. Exit\n");
        printf("SELECT FROM ABOVE OPTIONS (1-5)\n");

        int option; // putting option here since it's easier to reset by re-initializing it 
        scanf("%d", &option); // get option
        getchar(); // clear newline

        switch (option)
        {
            case 1:
                printf("%s", "Enter your first number in: ");
                char firstInput[64], secondInput[64]; // setup two different input c-strings
                scanf("%s", firstInput);
                printf("%s", "Enter your second nummber in: "); // use string input to get the input
                scanf("%s", secondInput);

                result = addstr(firstInput, secondInput); // push first string to [ebp + 12] and push second string [ebp + 8]
                printf("Result: %d\n", result); // output the integer result
                break;
            
            case 2:
                printf("%s", "Enter a string: ");
                scanf("%s", input);     // read the input in
                int len;                  // length of the string
                for (len = 0; input[len] != '\0'; len++); //find the length of the string using the worst for loop you've ever seen
                if (is_palindrome(input, len) == 1) // push input to [ebp + 12] and length to [ebp + 8]
                    printf("It is a palindrome\n");
                else
                    printf("It is not a palindrome\n");
                break;

            case 3:
                printf("Enter the number you want the factorial of: ");
                scanf("%s", input);     // take in input as a string
                result = factstr(input);        // pass back the resulting integer
                printf("Your factorial number is: %d\n", result);  //printout the resultingnumber
                break;

            case 4:
                // printf("Enter a string: ");
                // fgets(input, sizeof(input), stdin);
                palindrome_check();     // call palindrome check within asm
                break;
            case 5:
                return 0; //end the program
            default:
                printf("Please select an actual option listed above (1-5)\n");
        }   
    }
    return 0;
}

int isPalindrome(char* monke) // pass the character array that is tested to be a palindrome
{
    int len = 0;    //init the length
    while(monke[len] != '\0')   //use a while loop to increase the length until we reach  the null terminator
    {
        len++;                      // find the length of the string using a for loop 
    }

    int start = 0;  //start is set to 0
    int end = len - 2;  // end is set to the length minus the newline minus the null terminator
    while (start < end) //go while start is less than end
    {
        if (monke[start] != monke[end]) // check if the input's start and end are the same
        {
            return 0; //return 0 if they are the same
        }
        start++; // move start to letter of the right of it
        end--;   // move end to the letter of the left of it
    }
    return 1;                       // return 1 if all characters match and the string is a palindrome
}

int fact(int n)
{
    if (n <= 1) // check if n is less than or equal to 1
        return 1;
    else
        return n * fact(n - 1); // recursively call fact n so we can figure out the factorial within O(log(n)) time 
}
