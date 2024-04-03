UPPERCASE [A-Z]
DIGIT [0-9]
PUNCTUATION [^\""A-Za-z0-9 ]

%{

	//Dylan Vaughn

#include <iostream>
#include <vector>    
#include <fstream>
#include <string>
#include <algorithm>
#include <sstream>
#include <string.h>
#include <regex>
#include "hashtable.h"
extern int yylex(void);
using namespace std;

#undef yywrap

char Ch; char newLine;
string token; string stemmedToken;
int i = 0; int doc_freq = 0; int token_num = 0;
bool only_whitespace = true; bool reset = true;

// Vector created for finding the stop words
vector<string> stop_words = {"about","an","and","are","as","at","be","by","com","for","from","how","in","is","it","of","on","or","that","the","this","to","was","what","when","where","who","will","with","the","www","text","type","content","date","html","server","gmt"};
bool stop = false;

vector<string> query;
vector<string> quoteQueries;


bool checkForVowel(char vowel) {
   if (vowel == 'a')
      return true;
   if (vowel == 'e')
      return true;
   if (vowel == 'i')
      return true;
   if (vowel == 'o')
      return true;
   if (vowel == 'u')
      return true;
   return false;
}

bool checkForPreviousVowel(char token[]) {
   int b = 0;
   bool flag = false;
   while (!flag) {
      char checkVowel = token[b];
      if (checkForVowel(checkVowel)) {
         flag = true;
         return true;
      }
      else if (b >= strlen(token)) {
         flag = true;
         return false;
      }
      b++;
   }
}

void handleEnding(char token[]) {
   int newLength = 0;
   while (token[newLength] != '\0')
      newLength++;

   if (strcmp(token + strlen(token)-2, "at") == 0) {
      token[newLength] = 'e';
      token[newLength+1] = '\0';
   }
   else if (strcmp(token + strlen(token)-2, "bl") == 0) {
      token[newLength] = 'e';
      token[newLength+1] = '\0';
   }
   else if (strcmp(token + strlen(token)-2, "iz") == 0) {
      token[newLength] = 'e';
      token[newLength+1] = '\0';
   }
   else if (token[newLength-1] == token[newLength-2]) {
      if (!strcmp(token + strlen(token)-2, "ll") == 0) {
         if (!strcmp(token + strlen(token)-2, "ss") == 0) {
            if (!strcmp(token + strlen(token)-2, "zz") == 0) {
               token[newLength-1] = '\0';
            }
         }
      }
   }
}

//determine the number of vowel(s) followed by consonant(s) pairs there are
int m(char token[]) {
   int l = strlen(token);
   int index = 0;
   int vc = 0;
   while (index < l) {
      char a = token[index];
      if (checkForVowel(a)) {
         char b = token[index+1];
         if (!checkForVowel(b))
            vc++;
      }
      index++;
   }
   return vc;
}

void step1a(char token[], int length) {

   //hanlde sses ending
   if (strcmp(token + strlen(token)-4, "sses") == 0) {
      //replace last 2 characters with null
      token[length - 2] = '\0';
   }

   //hanlde ied ending
   else if (strcmp(token + strlen(token)-3, "ied") == 0) {
      if (strlen(token) > 4) {
         //replace last 2 characters with null
         token[length - 2] = '\0';
      }
      else {
         //replace last character with null
         token[length - 1] = '\0';
      }
   }

   //hanlde ies ending
   else if (strcmp(token + strlen(token)-3, "ies") == 0) {
      if (strlen(token) > 4) {
         //replace last 2 characters with null
         token[length - 2] = '\0';
      }
      else {
         //replace last character with null
         token[length - 1] = '\0';
      }
   }
   else if (strcmp(token + strlen(token)-1, "s") == 0) {
      char checkVowel = token[length-2];
      if (!checkForVowel(checkVowel) && checkVowel != 's') {
         if (checkForPreviousVowel(token)) {
            token[length -1] = '\0';
         }
      }
   }
}

void step1b(char token[], char token2[], int length) {

   //eed ending
   if (strcmp(token + strlen(token)-3, "eed") == 0) {
      token2[length-3] = '\0';
   
      if (m(token2) > 0 ) {
         //replace last character with null
         token[length-1] = '\0';
      }
   }

   //eedly ending
   else if (strcmp(token + strlen(token)-5, "eedly") == 0) {
      token2[length-5] = '\0';
      
      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //ed ending
   else if (strcmp(token + strlen(token)-2, "ed") == 0) {
      token2[length-2] = '\0';
      
      if(checkForPreviousVowel(token2)) {
         //replace last 2 characters with null
         token[length-2] = '\0';

         //handle the at, bl, iz endings
         handleEnding(token);
      }
   }

   //edly ending
   else if (strcmp(token + strlen(token)-4, "edly") == 0) {
      token2[length-4] = '\0';
      
      if(checkForPreviousVowel(token2)) {
         //replace last 4 characters with null
         token[length-4] = '\0';

         //handle the at, bl, iz endings
         handleEnding(token);
      }
   }

   //ing ending
   else if (strcmp(token + strlen(token)-3, "ing") == 0) {
      token2[length-3] = '\0';
      
      if(checkForPreviousVowel(token2)) {
         //replace last 3 characters with null
         token[length-3] = '\0';

         //handle the at, bl, iz endings
         handleEnding(token);
      }
   }

   //ingly ending
   else if (strcmp(token + strlen(token)-5, "ingly") == 0) {
      token2[length-5] = '\0';
      
      if(checkForPreviousVowel(token2)) {
         //replace last 5 characters with null
         token[length-5] = '\0';

         //handle the at, bl, iz endings
         handleEnding(token);
      }
   }
}

//change y to i if there is a vowel
void step1c(char token[], char token2[], int length) {
   char a = token[0];
   if (token[length-1] == 'y') {
      token[length-1] = '\0';
      if (checkForPreviousVowel(token)) {
         token[length-1] = 'i';
         token[length] = '\0';
      }
      else {
         token[length-1] = 'y';
         token[length] = '\0';
      }
   }
}

void step2(char token[], char token2[], int length) {

   //handle ational ending
   if (strcmp(token + strlen(token)-7, "ational") == 0) {
      token2[length-7] = '\0';

      if (m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
         token[length-5] = 'e';
      }
   }

   //handle tional ending
   else if (strcmp(token + strlen(token)-6, "tional") == 0) {
      token2[length-6] = '\0';
      
      if (m(token2) > 0) {
         //replace last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle enci ending
   else if (strcmp(token + strlen(token)-4, "enci") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //change last character to e
         token[length-1] = 'e';
      }
   }

   //handle anci ending
   else if (strcmp(token + strlen(token)-4, "anci") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //change last character to e
         token[length-1] = 'e';
      }
   }

   //handle izer ending
   else if (strcmp(token + strlen(token)-4, "izer") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //replace last character with null
         token[length-1] = '\0';
      }
   }

   //handle abli ending
   else if (strcmp(token + strlen(token)-4, "abli") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //change last character to e
         token[length-1] = 'e';
      }
   }

   //handle alli ending
   else if (strcmp(token + strlen(token)-4, "alli") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //change last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle entli ending
   else if (strcmp(token + strlen(token)-5, "entli") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //change last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle eli ending
   else if (strcmp(token + strlen(token)-3, "eli") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 0) {
         //change last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle ousli ending
   else if (strcmp(token + strlen(token)-5, "ousli") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //change last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle ization ending
   else if (strcmp(token + strlen(token)-7, "ization") == 0) {
      token2[length-7] = '\0';

      if(m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
         token[length-5] = 'e';
      }
   }

   //handle ation ending
   else if (strcmp(token + strlen(token)-5, "ation") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 2 characters with null
         token[length-2] = '\0';
         token[length-3] = 'e';
      }
   }

   //handle ator ending
   else if (strcmp(token + strlen(token)-4, "ator") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //replace last character with null
         token[length-1] = '\0';
         token[length-2] = 'e';
      }
   }

   //handle alism ending
   else if (strcmp(token + strlen(token)-5, "alism") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle iveness ending
   else if (strcmp(token + strlen(token)-7, "iveness") == 0) {
      token2[length-7] = '\0';

      if(m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
      }
   }

   //handle fulness ending
   else if (strcmp(token + strlen(token)-7, "fulness") == 0) {
      token2[length-7] = '\0';

      if(m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
      }
   }

   //handle ousness ending
   else if (strcmp(token + strlen(token)-7, "ousness") == 0) {
      token2[length-7] = '\0';

      if(m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
      }
   }

   //hanlde aliti ending
   else if (strcmp(token + strlen(token)-5, "aliti") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle iviti ending
   else if (strcmp(token + strlen(token)-5, "iviti") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 2 characters with null
         token[length-2] = '\0';
         token[length-3] = 'e';
      }
   }

   //handle biliti ending
   else if (strcmp(token + strlen(token)-6, "biliti") == 0) {
      token2[length-6] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
         token[length-4] = 'e';
         token[length-5] = 'l';
      }
   }
}

void step3(char token[], char token2[], int length) {
      
   //handle icate ending
   if (strcmp(token + strlen(token)-5, "icate") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle ative ending
   else if (strcmp(token + strlen(token)-5, "ative") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 5 characters with null
         token[length-5] = '\0';
      }
   }

   //handle alize ending
   else if (strcmp(token + strlen(token)-5, "alize") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle iciti ending
   else if (strcmp(token + strlen(token)-5, "iciti") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle ical ending
   else if (strcmp(token + strlen(token)-4, "ical") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //replace last 2 characters with null
         token[length-2] = '\0';
      }
   }

   //handle ful ending
   else if (strcmp(token + strlen(token)-3, "ful") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 0) {
         //replace last 3 characters with null
         token[length-3] = '\0';
      }
   }

   //handle ness ending
   else if (strcmp(token + strlen(token)-4, "ness") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 0) {
         //replace last 4 characters with null
         token[length-4] = '\0';
      }
   }
}

void step4(char token[], char token2[], int length) {

   //handle al ending
   if (strcmp(token + strlen(token)-2, "al") == 0) {
      token2[length-2] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 2 characters with null
         token[newLength-2] = '\0';
      }
   }

   //handle ance ending
   else if (strcmp(token + strlen(token)-4, "ance") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 4 characters with null
         token[newLength-4] = '\0';
      }
   }

   //handle ence ending
   else if (strcmp(token + strlen(token)-4, "ence") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 4 characters with null
         token[newLength-4] = '\0';
      }
   }

   //handle er ending
   else if (strcmp(token + strlen(token)-2, "er") == 0) {
      token2[length-2] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 2 characters with null
         token[newLength-2] = '\0';
      }
   }

   //handle ic ending
   else if (strcmp(token + strlen(token)-2, "ic") == 0) {
      token2[length-2] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 2 characters with null
         token[newLength-2] = '\0';
      }
   }

   //handle able ending
   else if (strcmp(token + strlen(token)-4, "able") == 0) {
      int newLength = strlen(token2);
      token2[newLength-4] = '\0';

      if(m(token2) > 1) {
         int newLength2 = strlen(token);
         //replace last 4 characters with null
         token[newLength2-4] = '\0';
      }
   }

   //handle ible ending
   else if (strcmp(token + strlen(token)-4, "ible") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 4 characters with null
         token[newLength-4] = '\0';
      }
   }

   //handle ant ending
   else if (strcmp(token + strlen(token)-3, "ant") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ement ending
   else if (strcmp(token + strlen(token)-5, "ement") == 0) {
      token2[length-5] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 5 characters with null
         token[newLength-5] = '\0';
      }
   }

   //handle ment ending
   else if (strcmp(token + strlen(token)-4, "ment") == 0) {
      token2[length-4] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 4 characters with null
         token[newLength-4] = '\0';
      }
   }

   //handle ent ending
   else if (strcmp(token + strlen(token)-3, "ent") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ion ending
   else if (strcmp(token + strlen(token)-3, "ion") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         if (token2[length-4] == 's') {
            token[length-3] = '\0';
         }
         else if (token2[length-4] == 't') {
            int newLength = strlen(token);
            //replace last 3 characters with null
            token[newLength-3] = '\0';
         }
      }
   }

   //handle ou ending
   else if (strcmp(token + strlen(token)-2, "ou") == 0) {
      token2[length-2] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 2 characters with null
         token[newLength-2] = '\0';
      }
   }

   //handle ism ending
   else if (strcmp(token + strlen(token)-3, "ism") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ate ending
   else if (strcmp(token + strlen(token)-3, "ate") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle iti ending
   else if (strcmp(token + strlen(token)-3, "iti") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ous ending
   else if (strcmp(token + strlen(token)-3, "ous") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ive ending
   else if (strcmp(token + strlen(token)-3, "ive") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }

   //handle ize ending
   else if (strcmp(token + strlen(token)-3, "ize") == 0) {
      token2[length-3] = '\0';

      if(m(token2) > 1) {
         int newLength = strlen(token);
         //replace last 3 characters with null
         token[newLength-3] = '\0';
      }
   }
}

//remove e endings
void step5a(char token[], char token2[], int length) {
   if (strcmp(token + strlen(token)-1, "e") == 0) {
      token2[length-1] = '\0';

      if (m(token2) > 1) {
         //replace last character with null
         token[length-1] = '\0';
      }
      else if (m(token2) == 1) {
         int newLength = strlen(token2);
         int index = 1;
         bool cvcFlag = false;
         bool flag1 = false;
         bool flag2 = false;
         bool flag3 = false;

         if (!checkForVowel(token2[newLength-1])) {

            if (!token2[newLength-1] != 'w') {

               if (!token2[newLength-1] != 'x') {

                  if (!token2[newLength-1] != 'y') {

                     while(!checkForVowel(token2[newLength-index]) && !flag1) {
                        index++;
                        if (newLength-index < 0) {
                           flag1 = true;
                        }
                     }
                     while(checkForVowel(token2[newLength-index]) && !flag2) {
                        index++;
                        if (newLength-index < 0) {
                           flag2 = true;
                        }
                     }
                     while(!checkForVowel(token2[newLength-index]) && !flag3) {
                        index++;
                        flag3 = true;
                        cvcFlag = true;
                     }
                  }
               }
            }
         }

         if (!cvcFlag && strlen(token) > 3) {
            //replace last character with null
            token[length-1] = '\0';
         }
      }
   }
}

void step5b(char token[], char token2[], int length) {
   if (token[length-1] == token[length-2]) {
      if (token[length-1] == 'l') {
         token2[length-2] = '\0';
         if (m(token2) > 1) {
            //remove extra l
            token[length-1] = '\0';
         }
      }
   }
}

void PorterStemming(const string & myToken, const int recursive) {

      if (myToken.find(' ') != string::npos) {

         if (recursive == 0) {
            reset = false;
            if (stemmedToken != "")
               quoteQueries.push_back(stemmedToken);
            stemmedToken = "";
         }
         size_t spacePos = myToken.find(' ');

         string first = myToken.substr(0, spacePos);
         string second = myToken.substr(spacePos+1);

         PorterStemming(first, 1);
         PorterStemming(second, 1);
      }
      else {
         int total = 0;
         int length = myToken.length();
         char* token = new char[length + 1];
         char* token2 = new char[length + 1];
         strcpy(token, myToken.c_str());
         strcpy(token2, myToken.c_str());

         step1a(token, length);
         step1b(token, token2, length);
         step1c(token, token2, length);
         step2(token, token2, length);
         step3(token, token2, length);
         step4(token, token2, length);
         step5a(token, token2, length);
         step5b(token, token2, length);

         if(!reset) {
            string tmp = token;
            if (stemmedToken == "")
                  stemmedToken = tmp;
            else {
                  stemmedToken = stemmedToken + " " + tmp; 
            }
         }
         else {
            if (stemmedToken != "") {
               quoteQueries.push_back(stemmedToken);
               stemmedToken = "";
               reset = false;
            }
         }

         //cout << "inserting " << token << endl;
         query.push_back(token);
         token_num++;
         delete[] token;
         delete[] token2;
      }
      return;
}
%}

%x IN_JAVASCRIPT

%%
[\n\t ]+ {
   char newLine = '\n'; 
   //fprintf(yyout, "%c", newLine); 
   only_whitespace = true;
   for (char c : token) {
      if (!isspace(static_cast<unsigned char>(c))) {
         only_whitespace = false;
         break;
      }
   }

   if (!only_whitespace) {
      PorterStemming(token, 0);
      token = "";
      doc_freq++;
   }
   }

{UPPERCASE} {Ch = tolower(yytext[0]); token += Ch;}
"<script>" {
    BEGIN(IN_JAVASCRIPT);
}

"<script".*">" {
    BEGIN(IN_JAVASCRIPT);
}

<IN_JAVASCRIPT>"</script>" {
    BEGIN(INITIAL);
}

<IN_JAVASCRIPT>.|\n {
}
"<style>"[^<]*"<\/style>" { 
   only_whitespace = true;
   for (char c : token) {
      if (!isspace(static_cast<unsigned char>(c))) {
         only_whitespace = false;
         break;
      }
   }

   if (!only_whitespace) {

      //Check if token is size 1 or if it is a stop word
      size_t token_size = token.size();
      stop = find(stop_words.begin(), stop_words.end(), token) != stop_words.end();
      if(token_size == 1 || stop == true) {
         token = "";
      }
      else {
         PorterStemming(token, 0);
         token = "";
         doc_freq++;
      }
   }
   }
"<meta".*"content=" {;}
"<META".*"CONTENT=" {;}
"<"[^>]*> {if((yytext[1] == 'm' || yytext[1] == 'M') && (yytext[6] == 'n' || yytext[6] == 'N')){REJECT;};}
{DIGIT}+ {
    int i = 0; 
    while(yytext[i] >= '0' && yytext[i] <= '9') {
        token += yytext[i];i++;
    }

      //Check if token is size 1 or if it is a stop word
      size_t token_size = token.size();
      stop = find(stop_words.begin(), stop_words.end(), token) != stop_words.end();
      if(token_size == 1 || stop == true) {
         token = "";
      }
      else {
         PorterStemming(token, 0);
         token = "";
         doc_freq++;
      }
    }
{DIGIT}{3}"-"{DIGIT}{3}"-"{DIGIT}{4} {
    for(int i = 0; i < 12; i++) {
        token += yytext[i];
    }
    //Check if token is size 1 or if it is a stop word
    size_t token_size = token.size();
    stop = find(stop_words.begin(), stop_words.end(), token) != stop_words.end();
    if(token_size == 1 || stop == true) {
        token = "";
    }
    else {
        PorterStemming(token, 0);
        token = "";
        doc_freq++;
    }
    newLine = '\n'; 
    fprintf(yyout, "%c", newLine); 
    }
{DIGIT}+"."{DIGIT}* {;}
[\"].*[\"] {
    int i = 1;
    while (yytext[i] != '"') {
        token += yytext[i];
        i++;
    }
    PorterStemming(token, 0);
    token = "";
}
{PUNCTUATION} {
   only_whitespace = true;
   for (char c : token) {
      if (!isspace(static_cast<unsigned char>(c))) {
         only_whitespace = false;
         break;
      }
   }

   if (!only_whitespace) {

      //Check if token is size 1 or if it is a stop word
      size_t token_size = token.size();
      stop = find(stop_words.begin(), stop_words.end(), token) != stop_words.end();
      if(token_size == 1 || stop == true) {
         token = "";
      }
      else {
         PorterStemming(token, 0);
         token = "";
         doc_freq++;
      }
   }
   newLine = '\n'; 
    
   }
[a-z]+ {
   int i = 0; 
   while(yytext[i] >= 'a' && yytext[i] <= 'z') {
      token += yytext[i];i++;
   } 
   only_whitespace = true;
   for (char c : token) {
      if (!isspace(static_cast<unsigned char>(c))) {
         only_whitespace = false;
         break;
      }
   }

   if (!only_whitespace) {

      //Check if token is size 1 or if it is a stop word
      size_t token_size = token.size();
      stop = find(stop_words.begin(), stop_words.end(), token) != stop_words.end();
      if(token_size == 1 || stop == true) {
         token = "";
      }
      else {
         PorterStemming(token, 0);
         token = "";
         doc_freq++;
      }
   }
   }
%%

const unsigned long NUM_KEYS = 30872;
HashTable Ht(NUM_KEYS);

//This is a custom struct to use in my accumulator
struct Bucket {
    string document;
    int wt;
};

//This is a custom comparing function to use to sort my accumulator
bool compareWT(const Bucket &a, const Bucket &b) {
    return a.wt > b.wt;
}

//This is the function to handle the queries
void handleQuery(string dict, string post, vector<Bucket> accumulator) 
{

    //open dict/post files
    ifstream din(dict);
    ifstream pin(post);

    //For each query
    for(int i = 0; i < query.size(); i++) 
    {
        //set pointer to beginning
        din.clear();
        din.seekg(0, std::ios::beg);
        pin.clear();
        pin.seekg(0, std::ios::beg);

        //declare all variables used for the queries
        string queryWord = query[i];
        string word = "";
        int  num_docs = 0;
        int start = 0;
        int line_number = 0;
        int doc_id = 0;
        int wt = 0;
        int totalToken = 0;
        int loc_start = 0;
        string line = "";
        bool found = false;

        streampos dictPos = Ht.Find(queryWord);
        dictPos = dictPos * 32;

        din.seekg(dictPos, ios::beg);

        din >> word >> num_docs >> start;

        //when a match is found, calculate the position in bytes
        if (word == queryWord) 
        {
            found = true;
            streampos postPos = start-1;
            postPos = postPos * 23;
            
            //seek for that position
            pin.seekg(postPos, ios::beg);

            //for each document, take in the values
            for (int j = 0; j < num_docs; j++) 
            {
                pin >> doc_id >> wt >> totalToken >> loc_start;
                string doc = "doc" + to_string(doc_id);
                bool exists = false;

                //save the values into the accumulator
                for(int k = 0; k < accumulator.size(); k++) 
                {
                    if(accumulator[k].document == doc){
                        accumulator[k].wt += wt;
                        exists = true;
                        break;
                        cout << "document match for " << doc << endl;
                    }
                }
                if(!exists) {
                    accumulator.push_back({doc, wt});
                }
            }
        }
        
        //This is if no document is found to have the query
        //if(!found)
            //cout << "no docs" << endl;

    }
    //Call sort with my compare function created
    sort(accumulator.begin(), accumulator.end(), compareWT);

    //open the map file
    ifstream min("output/map.txt");

    //If there are not 10 entries in the accumulator
    //Output the remaining 10 lines as "No more matching documents!"
    if (accumulator.size() < 10) 
    {
        for(int i = 0; i < accumulator.size(); i++) 
        {
            string doc_number = "";
            string doc_name = "";

            min.clear();
            min.seekg(0, std::ios::beg);
            string full_doc = accumulator[i].document;
            string numbers = "";
            for (char c : full_doc) {
                if (isdigit(c))
                    numbers += c;
            }
            //After obtaining just the number of the doc, then find it in map.txt
            int number = stoi(numbers);
            streampos pos = number;
            pos = pos * 17;
            min.seekg(pos, ios::beg);

            min >> doc_number >> doc_name;
            cout << accumulator[i].document << " " << doc_name << " " << accumulator[i].wt << endl;
        }
        for(int i = 0; i < 10-accumulator.size(); i++) {
            cout << "doc" << endl;
            cout << "No No matches!" << endl;
        } 
    }
    //If there are 10 documents in accumulator, then output them
    else 
    {
        for(int i = 0; i < 10; i++) 
        {
            string doc_number = "";
            string doc_name = "";

            min.clear();
            min.seekg(0, std::ios::beg);
            string full_doc = accumulator[i].document;
            string numbers = "";
            for (char c : full_doc) {
                if (isdigit(c))
                    numbers += c;
            }
            //After obtaining just the number of the doc, then find it in map.txt
            int number = stoi(numbers);
            streampos pos = number;
            pos = pos * 17;
            min.seekg(pos, ios::beg);

            min >> doc_number >> doc_name;
            cout << accumulator[i].document << " " << doc_name << " " << accumulator[i].wt << endl;
        }
    }
}

int main(int argc, char **argv)
{ 
    //create the accumulator vector of Bucket and open the temp file
    vector<Bucket> accumulator;
    //ofstream dout("input.html");
    ofstream dout("/tmp/testfile.html");

    if (argc < 2) {
      cout << "there isn't enough command args " << endl;
      return 1;
    }

    int i = 2;
    string arg = argv[1];
    string arg2 = argv[2];

    //cout << arg <<  endl;
    //cout << "word is " << arg2 << endl;

    string inputDir = "";

   while(argv[i] != NULL) {
      
      string arg2 = argv[i];

      if (arg2.find(' ') != string::npos) {
            arg2 = '"' + arg2 + '"';
      }

      dout << arg2 << endl;
      i++;
   }

   //manually set input directory
   inputDir = "output";
    //set path and name to dict and post
    string dict = inputDir + "/" + "dict.txt";
    string post = inputDir + "/" + "post.txt";    

   if (!arg.empty()) {
      if((yyin = fopen(argv[1],"r"))==NULL)
         cout << "\n Error opening input file \n";
   }
    
    //flex retrieve.flex
    //g++ -o retrieve lex.yy.c hashtable.cpp -lfl
    //./retrieve (-q) [words] (-d) (dir)

    yylex();

   if (stemmedToken != "")
      quoteQueries.push_back(stemmedToken);

   //for (int d = 0; d < quoteQueries.size(); d++)
      //cout << "index " << d << ": " << quoteQueries[d] << endl;
   //for (int e = 0; e < query.size(); e++)
      //cout << "word " << e << ": " << query[e] << endl;

    //call the query handler
    handleQuery(dict, post, accumulator);

    
}