public class Sobjecttype {
	@AuraEnabled
    public static String getObjectType(string obj) {
        list<string> stringlist=new list<string>{obj};
        //return Utility.getDescribedObjects(stringlist); 
        return null;   
    }

}