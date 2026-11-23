public class Core_MDF_CustomIterable implements Iterable<sObject> {
    Public List<sObject> sObjectList = new List<sObject>();
    
    public Core_MDF_CustomIterable(List<sObject> objList){
        this.sObjectList = objList;
    }
    
    public Iterator<sObject> iterator(){
        return new Core_MDF_CustomIterator(sObjectList);
    }
}