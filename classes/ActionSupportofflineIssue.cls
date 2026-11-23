public class ActionSupportofflineIssue {
    Integer count = 0;
    
    public Integer counter{get;set;}
   /* public Integer getcounter(){
    // counter=2;
      counter=4;
   
           
     return counter;
    } */ 
    public ActionSupportofflineIssue (){
           counter=2;
    }           
    public PageReference incrementCounter() {
            count++;
            return null;
    }
                    
    public Integer getCount() {
     
        return count;
    }
    public void testFunction(){
     // counter=2;
    }
}