//Changes by Dylan Vaughn

/* Filename:  hashtable.h
 * Author:    Susan Gauch
 * Date:      2/25/10
 * Purpose:   The header file for a hash table of strings and ints. 
*/

using namespace std;

class HashTable {
public:
   HashTable (const HashTable& ht );
   HashTable(const unsigned long NumKeys); 
   ~HashTable();                          
   void Clear();
   void Print (const char *filename) const;       
   void Insert (const string Key, const float Data); 
   string GetKey(const int Index);
   float GetData (const string Key); 
   void GetUsage (int &Used, int &Collisions, int &Lookups) const;
   unsigned long Find (const string Key);
protected:
   struct StringIntPair 
   {
      string key;
      float data;
   };
private:
   StringIntPair *hashtable;        
   unsigned long size;              
   unsigned long used;
   unsigned long collisions;
   unsigned long lookups;
};
