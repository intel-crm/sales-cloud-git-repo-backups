public class testClassforCase {
	@AuraEnabled
    public static List<Case> getItems() {
        //fetch the active records using soql query
        List<Case> caseItems = [SELECT Id,Status FROM Case];
        //return the list of caseitems
        return caseItems;
    } 
}