public class Core_MDF_CustomIterator implements Iterator<sObject>{ 
    
    private List<sObject> sObjectList;
    private Integer currentIndex;
    
    public Core_MDF_CustomIterator(List<sObject> sObjectList){
        this.sObjectList = sObjectList;
        this.currentIndex = 0;
    }
    
        
    public Boolean hasNext(){ 
        return currentIndex < sObjectList.size();
    }   
    
    public sObject next(){
        if(hasNext()) {
            return sObjectList[currentIndex++];
        } else {
            throw new NoSuchElementException('Iterator has no more elements.');
        }
    } 
 
}