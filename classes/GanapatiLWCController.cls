public class GanapatiLWCController {
	@AuraEnabled(cacheable=true)
    public static List<String> getIdList(String queryString){
        List<String> idList = new List<String>();
        List<sObject> objList = Database.query(queryString);
        for(sObject obj : objList) {
            idList.add(obj.Id);
        }
        return idList;
    }
}