#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <string.h>
#include <malloc.h>

extern char* calc_add(char*, long, char*, long);
extern char* calc_sub(char*, long, char*, long);
extern char* calc_mul(char*, long, char*, long, char*, char*);


typedef struct bignum {
    long number_of_digits;
    char *digit;
    int minusFlag;
} bignum;

bignum *stack[1024];
long stackPos = 0;
long e =127;

//////////////////////////////////////////////////////////////////////////////////////////////

// this functin receives two char* in the same length and copies the content of the first into the second
char* copyDigit(char* num1, char*num2){
    long index = 0;
    while (num1[index]){
        num2[index] = num1[index];
        index++;
    }
    return num2;
}

// this function reallocs a char* while receiving the input - when needed
char* spaceInNumber(char* number, long counter){
    if (counter == e){
        e = e * 2 +1;
        char* newNumber = (char*)malloc(e+1);
        long index=0;
        while(number[index]){
            newNumber[index] = number[index];
            index++;
        }
        newNumber[e] ='\0';
        free(number);
        return newNumber;
    }
    return number;
}

// this function returns the amount of digits in a given char*
long countDigits(char* number){
    long index = 0;
    while (number[index]){
        index++;
    }
    return index;
}
// this function returns which number is bigger (ignoring minus), given two bignums (if equal returns 0), and in addition reallocs them into being in the same size (with additional zeros) + 1 extra zero
int whoIsBigger(bignum* big1, bignum* big2)
{
    long diff = 0; // the difference bettwen the number of digits of the numbers
    int bigger = 0;
    if (big1->number_of_digits > big2->number_of_digits){ //  in case big1 has more digits then big2
        bigger = 1;
        diff = (big1->number_of_digits) - (big2->number_of_digits);

        char* newNum2 = (char*)malloc(big1->number_of_digits + 2);
        newNum2[big1->number_of_digits + 1] = '\0';
        long index1 = 0;
        while (diff + 1>0){
            newNum2[index1] = '0';
            diff--;
            index1++;
        }
        long index2 = 0;
        while (big2->number_of_digits>0){
            newNum2[index1] = big2->digit[index2];
            index1++;
            index2++;
            big2->number_of_digits--;
        }
        free(big2->digit);
        big2->digit = newNum2;
        big2->number_of_digits = big1->number_of_digits + 1;

        char* newNum1 = (char*)malloc(big1->number_of_digits + 2);
        newNum1[big1->number_of_digits + 1] = '\0';
        newNum1[0] = '0';
        long index3 = 1;
        while (big1->number_of_digits>0){
            newNum1[index3] = big1->digit[index3 - 1];
            index3++;
            big1->number_of_digits--;
        }
        free(big1->digit);
        big1->digit = newNum1;
        big1->number_of_digits = big2->number_of_digits;
    }
    else if (big1->number_of_digits<big2->number_of_digits){ // in case big2 has more digits then big1
        bigger = 2;
        diff = (big2->number_of_digits) - (big1->number_of_digits);
        char* newNum1 = (char*)malloc(big2->number_of_digits + 2);
        newNum1[big2->number_of_digits + 1] = '\0';
        long index1 = 0;
        while (diff + 1>0){
            newNum1[index1] = '0';
            diff--;
            index1++;
        }
        long index2 = 0;
        while (big1->number_of_digits>0){
            newNum1[index1] = big1->digit[index2];
            index1++;
            index2++;
            big1->number_of_digits--;
        }
        free(big1->digit);
        big1->digit = newNum1;
        big1->number_of_digits = big2->number_of_digits + 1;

        char* newNum2 = (char*)malloc(big2->number_of_digits + 2);
        newNum2[big2->number_of_digits + 1] = '\0';
        newNum2[0] = '0';
        long index3 = 1;
        while (big2->number_of_digits>0){
            newNum2[index3] = big2->digit[index3 - 1];
            index3++;
            big2->number_of_digits--;
        }
        free(big2->digit);
        big2->digit = newNum2;
        big2->number_of_digits = big1->number_of_digits;
    }
    else{ // in case big1 and big2 has the same amount of digits
        char* newNum1 = (char*)malloc(big1->number_of_digits + 2);
        newNum1[big1->number_of_digits + 1] = '\0';
        newNum1[0] = '0';
        long index1 = 1;
        while (big1->number_of_digits>0){
            newNum1[index1] = big1->digit[index1 - 1];
            index1++;
            big1->number_of_digits--;
        }
        free(big1->digit);
        big1->digit = newNum1;
        big1->number_of_digits = big2->number_of_digits + 1;

        char* newNum2 = (char*)malloc(big2->number_of_digits + 2);
        newNum2[big2->number_of_digits + 1] = '\0';
        newNum2[0] = '0';
        long index2 = 1;
        while (big2->number_of_digits>0){
            newNum2[index2] = big2->digit[index2 - 1];
            index2++;
            big2->number_of_digits--;
        }
        free(big2->digit);
        big2->digit = newNum2;
        big2->number_of_digits = big1->number_of_digits;


        for (long i = 0; i<big1->number_of_digits && bigger == 0; i++){
            if (big1->digit[i]>big2->digit[i]){
                bigger = 1;
            }
            else if (big1->digit[i]<big2->digit[i]){
                bigger = 2;
            }
        }
    }
    return bigger;
}
// this function deletes the extra zeros from a given char*
char* deleteZero(char* str, int numOfDigits)
{
    long index = 0;
    long numberOfZeros = 0;
    while (str[index] == '0'){
        index++;
        numberOfZeros++;
    }

    if (numOfDigits == numberOfZeros){
        char* newNum = (char*)malloc(2);
        newNum[0] = '0';
        newNum[1] = '\0';
        free(str);
        return newNum;
    }
    long index1 = 0;
    char* newNum = (char*)malloc(numOfDigits - numberOfZeros + 1);
    newNum[numOfDigits - numberOfZeros] = '\0';
    while (str[numberOfZeros] != '\0'){
        newNum[index1] = str[numberOfZeros];
        index1++;
        numberOfZeros++;
    }
    free(str);
    return newNum;
}

int add_two_bignums(bignum* big1, bignum* big2, int newflag){

    calc_add(big1->digit, big1->number_of_digits, big2->digit, big2->number_of_digits);

    free(big2->digit);
    free(big2);

    // creating the new bignum which is the result and pushing it into the stack
    struct bignum *newCalcNum = (struct bignum*)malloc(sizeof(struct bignum));
    newCalcNum->digit = deleteZero(big1->digit, big1->number_of_digits);
    newCalcNum->number_of_digits = countDigits(newCalcNum->digit);
    newCalcNum->minusFlag = newflag;
    free(big1);
    
    if (newCalcNum->digit[0] == '0' && strlen(newCalcNum->digit) == 1 && newCalcNum->minusFlag)
        newCalcNum->minusFlag=0;
    
    stack[stackPos] = newCalcNum;
    stackPos++;
    return 0;
}


int sub_two_bignums(bignum* big1, bignum* big2, int newflag, int bigger){

    if (bigger == 0 || bigger == 1){
        calc_sub(big1->digit, big1->number_of_digits, big2->digit, big2->number_of_digits);

        free(big2->digit);
        free(big2);

        // creating the new bignum which is the result and pushing it into the stack
        struct bignum *newCalcNum = (struct bignum*)malloc(sizeof(struct bignum));
        newCalcNum->digit = deleteZero(big1->digit, big1->number_of_digits);
        newCalcNum->number_of_digits = countDigits(newCalcNum->digit);
        newCalcNum->minusFlag = newflag;
        free(big1);
        
        if (newCalcNum->digit[0] == '0' && strlen(newCalcNum->digit) == 1 && newCalcNum->minusFlag)
        newCalcNum->minusFlag=0;
        
        stack[stackPos] = newCalcNum;
        stackPos++;

    }
    else{
        calc_sub(big2->digit, big2->number_of_digits, big1->digit, big1->number_of_digits);

        free(big1->digit);
        free(big1);

        // creating the new bignum which is the result and pushing it into the stack
        struct bignum *newCalcNum = (struct bignum*)malloc(sizeof(struct bignum));
        newCalcNum->digit = deleteZero(big2->digit, big2->number_of_digits);
        newCalcNum->number_of_digits = countDigits(newCalcNum->digit);
        newCalcNum->minusFlag = newflag;
        free(big2);
        
        if (newCalcNum->digit[0] == '0' && strlen(newCalcNum->digit) == 1 && newCalcNum->minusFlag)
        newCalcNum->minusFlag=0;
        
        stack[stackPos] = newCalcNum;
        stackPos++;
    }

    return 0;
}

void clearFunc() {
    if (stackPos == 0)
        return;
    stackPos--;

    while (stackPos >= 0) {
        free(stack[stackPos]->digit);
        free(stack[stackPos]);            

        stackPos--;
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////
int main() {

    char input = fgetc(stdin);


    while (input != 'q') {

        int flag = 0;
        long numOfDigits = 0;
        char *number = (char *)malloc(128);
        number[127] = '\0';
        e =127;

        while ((input > 47 && input < 58) || (input == '_')) {
            if (input == '_') {
                flag = 1;
            }
            else {
                number[numOfDigits] = input;
                numOfDigits++;
                number = spaceInNumber(number, numOfDigits);
            }
            input = fgetc(stdin);
        }

        if (numOfDigits > 0) {
            struct bignum *newNumber = (struct bignum *) malloc(sizeof(struct bignum));
            number = (char *)realloc(number, numOfDigits+1); // in case we had additional chars in the end of the string from the spaceInNumber function
            number[numOfDigits] = '\0';
            newNumber->digit = deleteZero(number, numOfDigits); // in case the input had additional zeros in the begining of the number
            newNumber->number_of_digits = countDigits(newNumber->digit);
            newNumber->minusFlag = flag;
            
            if (newNumber->digit[0] == '0' && strlen(newNumber->digit) == 1 && newNumber->minusFlag)
                newNumber->minusFlag=0;
            
            stack[stackPos] = newNumber;
            stackPos++;
        }
        else {
            free(number);
        }
        if (input <= 32){
            input = fgetc(stdin);
            continue;
        }

        switch (input) {
            case '*': {

                stackPos--;
                bignum *big2 = stack[stackPos];
                stackPos--;
                bignum *big1 = stack[stackPos];


                int newflag = 1; // initializing the minus flag to negative

                if ((big1->minusFlag && big2->minusFlag) || (!big1->minusFlag && !big2->minusFlag)) { // checking if the minus value should be positive
                    newflag = 0;
                }

                whoIsBigger(big1, big2); // now their length is equal
                long ansSize = (big1->number_of_digits * 2) + 1;
                char *ans = (char *)malloc(ansSize + 1);
                ans[ansSize] = '\0';
                char *temp = (char *)malloc(ansSize + 1);
                temp[ansSize] = '\0';

                //initializing ans and temp to '0' in each char
                for (int i = 0; i < ansSize; i++){
                    ans[i] = '0';
                    temp[i] = '0';
                }

                calc_mul(big1->digit, big1->number_of_digits, big2->digit, big2->number_of_digits, temp, ans); // sending for multi

                free(big1->digit);
                free(big2->digit);
                free(big1);
                free(big2);
                free(temp);

                // creating the new bignum which is the result and pushing it into the stack
                struct bignum *newCalcNum = (struct bignum *) malloc(sizeof(struct bignum));
                newCalcNum->digit = deleteZero(ans, ansSize);
                newCalcNum->number_of_digits = countDigits(newCalcNum->digit);
                newCalcNum->minusFlag = newflag;
                
                if (newCalcNum->digit[0] == '0' && strlen(newCalcNum->digit) == 1 && newCalcNum->minusFlag)
                newCalcNum->minusFlag=0;
                
                stack[stackPos] = newCalcNum;
                stackPos++;

                break;
            }
            case '/': { // divide big1/big2

                stackPos--;
                bignum *big2 = stack[stackPos];
                stackPos--;
                bignum *big1 = stack[stackPos];

                if (big2->digit[0] == '0' && strlen(big2->digit) == 1){ // in case we were are asked to divide by zero
                    
                    char* o = "can't divide by zero\n";
                    printf("%s",o);
                    free(big2->digit);
                    free(big1->digit);
                    free(big2);
                    free(big1);
                }
                else{ // otherwise
                    //finding the sign of the answer
                    int newflag = 1;
                    if ((big1->minusFlag && big2->minusFlag) || (!big1->minusFlag &&!big2->minusFlag)){ // in case both numbers have the same sign
                        newflag = 0;
                    }

                    struct bignum *bigAns = (struct bignum *) malloc(sizeof(struct bignum)); // initializing the answer
                    char *ans = (char *)malloc(2);
                    bigAns->digit = ans;
                    bigAns->minusFlag = 0;
                    bigAns->number_of_digits = 1;
                    ans[0] = '0';
                    ans[1] = '\0';

                    struct bignum *bigNumTwo = (struct bignum *) malloc(sizeof(struct bignum)); // initalizing the 2 we would double the counter and big2 with
                    char *numTwo = (char*)malloc(2);
                    bigNumTwo->digit = numTwo;
                    bigNumTwo->minusFlag = 0;
                    bigNumTwo->number_of_digits = 1;
                    numTwo[0] = '2';
                    numTwo[1] = '\0';

                    struct bignum *bigCounter = (struct bignum *) malloc(sizeof(struct bignum)); // initializing the counter that will be added to the ans each time
                    char *counter = (char*)malloc(2);
                    bigCounter->digit = counter;
                    bigCounter->minusFlag = 0;
                    bigCounter->number_of_digits = 1;
                    counter[0] = '1';
                    counter[1] = '\0';

                    struct bignum *oldBigCounter = (struct bignum *) malloc(sizeof(struct bignum)); // initializing the bignum that will hold the value of bigCounter one iteration ago
                    char* oldCounter = (char*)malloc(2);
                    oldBigCounter->digit = oldCounter;
                    oldBigCounter->minusFlag = 0;
                    oldBigCounter->number_of_digits = 1;
                    oldCounter[0] = '1';
                    oldCounter[1] = '\0';

                    struct bignum *oldBig2 = (struct bignum *) malloc(sizeof(struct bignum));// initializing the bignum that will hold the value of big2 one iteration ago
                    char* copyOf2 = (char*)malloc(big2->number_of_digits+1);
                    copyOf2[big2->number_of_digits] = '\0';
                    oldBig2->minusFlag = big2->minusFlag;
                    oldBig2->number_of_digits = big2->number_of_digits;
                    oldBig2->digit = copyDigit(big2->digit, copyOf2);

                    struct bignum *bigOriginalBig2 = (struct bignum *) malloc(sizeof(struct bignum));// initializing the bignum that will hold the value of the initial value of big2
                    char* originalBig2 = (char*)malloc(big2->number_of_digits+1);
                    originalBig2[big2->number_of_digits] = '\0';
                    bigOriginalBig2->minusFlag = big2->minusFlag;
                    bigOriginalBig2->number_of_digits = big2->number_of_digits;
                    bigOriginalBig2->digit = copyDigit(big2->digit, originalBig2);

                    //first time - outside of the loop checking who is bigger big1 or big2
                    int bigger = whoIsBigger(big1, big2);
                    big1->digit = deleteZero(big1->digit, big1->number_of_digits);
                    big1->number_of_digits = countDigits(big1->digit);
                    big2 -> digit = deleteZero(big2->digit, big2->number_of_digits);
                    big2->number_of_digits = countDigits(big2->digit);


                    while (bigger != 2){

                        //re-initializing the counter's value to 1
                        free(bigCounter->digit);
                        char *counter2 = (char*)malloc(2);
                        bigCounter->digit = counter2;
                        bigCounter->minusFlag = 0;
                        bigCounter->number_of_digits = 1;
                        counter2[0] = '1';
                        counter2[1] = '\0';
                        
                        //re-initializing the oldBigCounter value to 1
                        free(oldBigCounter->digit);
                        char *counter3 = (char*)malloc(2);
                        oldBigCounter->digit = counter3;
                        oldBigCounter->minusFlag = 0;
                        oldBigCounter->number_of_digits = 1;
                        counter3[0] = '1';
                        counter3[1] = '\0';

                        // re-initializing Oldbig2 to the original value of big2
                        whoIsBigger(bigOriginalBig2, oldBig2);
                        oldBig2->digit = copyDigit(bigOriginalBig2->digit, oldBig2->digit);
                        bigOriginalBig2->digit = deleteZero(bigOriginalBig2->digit, bigOriginalBig2->number_of_digits);
                        oldBig2->digit = deleteZero(oldBig2->digit, oldBig2->number_of_digits);
                        oldBig2->number_of_digits = countDigits(oldBig2->digit);
                        bigOriginalBig2->number_of_digits = oldBig2->number_of_digits;
                        
                        
                        // re-initializing big2 to the original value of big2
                        whoIsBigger(bigOriginalBig2, big2);
                        big2->digit = copyDigit(bigOriginalBig2->digit, big2->digit);
                        bigOriginalBig2->digit = deleteZero(bigOriginalBig2->digit, bigOriginalBig2->number_of_digits);
                        big2->digit = deleteZero(big2->digit, big2->number_of_digits);
                        big2->number_of_digits = countDigits(big2->digit);
                        bigOriginalBig2->number_of_digits = big2->number_of_digits;

                        while (bigger == 1){
                            // saving the old value of bigCounter for each iteration and the old value of big2 as well
                            whoIsBigger(oldBig2, big2);
                            oldBig2->digit = copyDigit(big2->digit, oldBig2->digit);
                            oldBig2->digit = deleteZero(oldBig2->digit, oldBig2->number_of_digits);
                            big2->digit = deleteZero(big2->digit, big2->number_of_digits);
                            big2->number_of_digits = countDigits(big2->digit);
                            oldBig2->number_of_digits = big2->number_of_digits;

                            whoIsBigger(oldBigCounter, bigCounter);
                            oldBigCounter->digit = copyDigit(bigCounter->digit, oldBigCounter->digit);
                            oldBigCounter->digit = deleteZero(oldBigCounter->digit, oldBigCounter->number_of_digits);
                            bigCounter->digit=deleteZero(bigCounter->digit, bigCounter->number_of_digits);
                            bigCounter->number_of_digits = countDigits(bigCounter->digit);
                            oldBigCounter->number_of_digits = bigCounter->number_of_digits;

                            /*//double counter by 2:
                            whoIsBigger(bigCounter, bigNumTwo);
                            long resSize = (bigCounter->number_of_digits * 2) + 1;
                            char *res = (char *)malloc(resSize+1);
                            char *temp = (char *)malloc(resSize+1);
                            for (int i = 0; i < resSize; i++){
                                res[i] = '0';
                                temp[i] = '0';
                            }
                            res[resSize] = '\0';
                            temp[resSize] = '\0';
                            calc_mul(bigCounter->digit, bigCounter->number_of_digits, bigNumTwo->digit, bigNumTwo->number_of_digits, temp, res); // sending for multi
                            free(bigCounter->digit);
                            free(bigNumTwo->digit);
                            free(temp);
                            bigCounter->digit = deleteZero(res, resSize);
                            bigCounter->number_of_digits = countDigits(bigCounter->digit);
                            bigCounter->minusFlag = 0;
                            char *two = (char*)malloc(2);
                            bigNumTwo->digit = two;
                            bigNumTwo->minusFlag = 0;
                            bigNumTwo->number_of_digits = 1;
                            two[0] = '2';
                            two[1] = '\0';*/
                            
                            
                            //double counter by 2 (adding counter to itself)
                            struct bignum *copyOfCounter2 = (struct bignum *) malloc(sizeof(struct bignum));
                            char* copyOf2counter2 = (char*)malloc(bigCounter->number_of_digits+1);
                            copyOf2counter2[bigCounter->number_of_digits] = '\0';
                            copyOfCounter2->minusFlag = bigCounter->minusFlag;
                            copyOfCounter2->number_of_digits = bigCounter->number_of_digits;
                            copyOfCounter2->digit = copyDigit(bigCounter->digit, copyOf2counter2);
                            bigger = whoIsBigger(copyOfCounter2, bigCounter);
                            calc_add(bigCounter->digit, bigCounter->number_of_digits, copyOfCounter2->digit, copyOfCounter2->number_of_digits);
                            bigCounter->digit = deleteZero(bigCounter->digit, bigCounter->number_of_digits);
                            bigCounter->number_of_digits = countDigits(bigCounter->digit);
                            free(copyOfCounter2->digit);
                            free(copyOfCounter2);
                            
                            
                            
                            
                            

                            //double big2 by 2:
                            /*whoIsBigger(big2, bigNumTwo);
                            long resSize2 = (big2->number_of_digits * 2) + 1;
                            char* res2 = (char*)malloc(resSize2+1);
                            char* temp2 = (char*)malloc(resSize2+1);
                            for (int i = 0; i < resSize2; i++){
                                res2[i] = '0';
                                temp2[i] = '0';
                            }
                            res2[resSize2] = '\0';
                            temp2[resSize2] = '\0';
                            calc_mul(big2->digit, big2->number_of_digits, bigNumTwo->digit, bigNumTwo->number_of_digits, temp2, res2); // sending for multi
                            free(big2->digit);
                            free(bigNumTwo->digit);
                            free(temp2);
                            big2->digit = deleteZero(res2, resSize2);
                            big2->number_of_digits = countDigits(big2->digit);
                            char *two2 = (char*)malloc(2);
                            bigNumTwo->digit = two2;
                            bigNumTwo->minusFlag = 0;
                            bigNumTwo->number_of_digits = 1;
                            two2[0] = '2';
                            two2[1] = '\0';*/
                            
                            //double big2 by 2 (adding big2 to itself)
                            struct bignum *copyOfBig2 = (struct bignum *) malloc(sizeof(struct bignum));// initializing the bignum that will hold the value of big2 one iteration ago
                            char* copyOf2num2 = (char*)malloc(big2->number_of_digits+1);
                            copyOf2num2[big2->number_of_digits] = '\0';
                            copyOfBig2->minusFlag = big2->minusFlag;
                            copyOfBig2->number_of_digits = big2->number_of_digits;
                            copyOfBig2->digit = copyDigit(big2->digit, copyOf2num2);
                            bigger = whoIsBigger(copyOfBig2, big2);
                            calc_add(big2->digit, big2->number_of_digits, copyOfBig2->digit, copyOfBig2->number_of_digits);
                            big2->digit = deleteZero(big2->digit, big2->number_of_digits);
                            big2->number_of_digits = countDigits(big2->digit);
                            free(copyOfBig2->digit);
                            free(copyOfBig2);



                            //chacking who is bigger big1 or big2
                            bigger = whoIsBigger(big1, big2);
                            big1->digit = deleteZero(big1->digit, big1->number_of_digits);
                            big1->number_of_digits = countDigits(big1->digit);
                            big2->digit = deleteZero(big2->digit, big2->number_of_digits);
                            big2->number_of_digits = countDigits(big2->digit);
                        }


                        //adding the answer with the one before the last value of the counter
                        whoIsBigger(bigAns, oldBigCounter);
                        calc_add(bigAns->digit, bigAns->number_of_digits, oldBigCounter->digit, oldBigCounter->number_of_digits);
                        bigAns->digit = deleteZero(bigAns->digit, bigAns->number_of_digits);
                        bigAns->number_of_digits = countDigits(bigAns->digit);
                        oldBigCounter->digit = deleteZero(oldBigCounter->digit, oldBigCounter->number_of_digits);
                        oldBigCounter->number_of_digits = countDigits(oldBigCounter->digit);


                        // changing big1's value to the value of big1-oldbig2
                        whoIsBigger(big1, oldBig2);
                        calc_sub(big1->digit, big1->number_of_digits, oldBig2->digit, oldBig2->number_of_digits);
                        big1->digit = deleteZero(big1->digit, big1->number_of_digits);
                        big1->number_of_digits = countDigits(big1->digit);
                        oldBig2->digit = deleteZero(oldBig2->digit, oldBig2->number_of_digits);
                        oldBig2->number_of_digits = countDigits(oldBig2->digit);

                        //chacking who is bigger big1 or bigOriginalBig2
                        bigger = whoIsBigger(big1, bigOriginalBig2);
                        big1->digit = deleteZero(big1->digit, big1->number_of_digits);
                        big1->number_of_digits = countDigits(big1->digit);
                        bigOriginalBig2->digit = deleteZero(bigOriginalBig2->digit, bigOriginalBig2->number_of_digits);
                        bigOriginalBig2->number_of_digits = countDigits(bigOriginalBig2->digit);
                    }



                    // pushing the answer into the stack
                    bigAns->minusFlag = newflag;
                    
                    if (bigAns->digit[0] == '0' && strlen(bigAns->digit) == 1 && bigAns->minusFlag)
                        bigAns->minusFlag=0;
                    
                    stack[stackPos] = bigAns;
                    stackPos++;

                    // freeing all that needs to be freed:
                    free(big1->digit);
                    free(big2->digit);
                    free(bigNumTwo->digit);
                    free(bigCounter->digit);
                    free(oldBigCounter->digit);
                    free(oldBig2->digit);
                    free(bigOriginalBig2->digit);
                    free(big1);
                    free(big2);
                    free(bigNumTwo);
                    free(bigCounter);
                    free(oldBigCounter);
                    free(oldBig2);
                    free(bigOriginalBig2);
                }
                break;
            }
            case '+': {

                stackPos--;
                bignum *big2 = stack[stackPos];
                stackPos--;
                bignum *big1 = stack[stackPos];

                int newflag = 0;

                if ((big1->minusFlag && big2->minusFlag) || (!big1->minusFlag &&!big2->minusFlag)) { // in case both variables are positive or negative we would like to send them to the add function and change the minus flag accordingly
                    if (big1->minusFlag &&big2->minusFlag) { // in case both are positive (otherwise, both are negative)
                        newflag = 1;
                    }
                    whoIsBigger(big1, big2); // now their legnth will be equal + 1 zero
                    add_two_bignums(big1, big2, newflag); // sending them to the adding function
                }
                else { // otherwise, one of the variables is negative and one is positive
                    int bigger = whoIsBigger(big1,
                                             big2); // now their length will be equal +1 zero and we will knwo which is bigger
                    if (bigger == 1 && big1->minusFlag == 1) { // in case big1 is bigger and is negative
                        newflag = 1;
                    }
                    else if (bigger == 1 && big1->minusFlag == 0) { // in case big1 is bigger and is positive
                        newflag = 0;
                    }
                    else if (bigger == 0) { // in case they are equal
                        newflag = 0;
                    }
                    else if (bigger == 2 && big2->minusFlag == 1) { // in case big 2 is bigger and is negative
                        newflag = 1;
                    }
                    else if (bigger == 2 && big2->minusFlag == 0) { // in case big2 is bigger and is positive
                        newflag = 0;
                    }
                    sub_two_bignums(big1, big2, newflag, bigger); // sending them to the subing function
                }

                break;
            }
            case '-': {

                stackPos--;
                bignum *big2 = stack[stackPos];
                stackPos--;
                bignum *big1 = stack[stackPos];

                int newflag = 1;

                if ((big1->minusFlag && big2->minusFlag) || (!big1->minusFlag &&
                                                             !big2->minusFlag)) { // in case both variables are positive or negative we would like to send them to the sub function and change the minus flag accordingly
                    int bigger = whoIsBigger(big1, big2); // now their legnth will be equal + 1 zero
                    if (bigger == 1 && big1->minusFlag && big2->minusFlag) {
                        newflag = 1;
                    }
                    else if (bigger == 1 && !big1->minusFlag && !big2->minusFlag) {
                        newflag = 0;
                    }
                    else if (bigger == 2 && big1->minusFlag && big2->minusFlag) {
                        newflag = 0;
                    }
                    else if (bigger == 2 && !big1->minusFlag && !big2->minusFlag) {
                        newflag = 1;
                    }
                    else {
                        newflag = 0;
                    }

                    sub_two_bignums(big1, big2, newflag, bigger); // sending them to the adding function
                }
                else { // otherwise, one of the variables is negative and one is positive
                    int bigger = whoIsBigger(big1,
                                             big2);// now their length will be equal +1 zero and we will knwo which is bigger

                    if (bigger == 1 && big1->minusFlag == 1) { // in case big1 is bigger and is negative
                        newflag = 1;
                    }
                    else if (bigger == 1 && big1->minusFlag == 0) { // in case big1 is bigger and is positive
                        newflag = 0;
                    }
                    else if (bigger == 2 && big2->minusFlag == 1) { // in case big 2 is bigger and is negative
                        newflag = 0;
                    }
                    else if (bigger == 2 && big2->minusFlag == 0) { // in case big2 is bigger and is positive
                        newflag = 1;
                    }
                    else {
                        if (big1->minusFlag == 1) {
                            newflag = 1;
                        }
                        else {
                            newflag = 0;
                        }
                    }
                    add_two_bignums(big1, big2, newflag); // sending them to the subing function
                }
                break;

            }
            case 'p': {

                if(stackPos!=0){
                    
                    
                    if (stack[stackPos - 1]->minusFlag == 1)
                        printf("-%s\n", stack[stackPos - 1]->digit);
                    else
                        printf("%s\n", stack[stackPos - 1]->digit);
                    }

                break;
            }
            /*case 'q': {
                clearFunc();
                return 0;
            }*/
            case 'c': {
                clearFunc();
                stackPos = 0;
                break;
            }
            default:
                printf("invalid input");
                exit(-1);
        }
        input = fgetc(stdin);
    }
    
    clearFunc();
    return 0;
}