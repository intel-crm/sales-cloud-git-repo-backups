public class PSG_CustomIterator
   implements Iterator<String>{ 
 
   private List<String> lstCSVLines;
   private Integer currentIndex;
 
   public PSG_CustomIterator(List<String> lstCSVLines){
       this.lstCSVLines = lstCSVLines;
       this.currentIndex = 0;
   }
 
   public boolean hasNext(){ 
       return currentIndex < lstCSVLines.size() - 1;
   }    
 
   public String next(){
       if(hasNext()) {
           currentIndex++;
           return lstCSVLines[currentIndex];
       } else {
           throw new NoSuchElementException();
       }
   } 
}