public class Core_IPS_HandleDeepLinksController {
    
    @AuraEnabled
    public static String getObjectNameById(Id recId){    
        return String.valueOf(recId.getsobjecttype());
    }

}