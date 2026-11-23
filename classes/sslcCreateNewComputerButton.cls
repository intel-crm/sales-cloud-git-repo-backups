public without sharing class sslcCreateNewComputerButton {
    public static boolean BypassTriggerReassignmentLogic=false;
	public static boolean isCustomOps;

@AuraEnabled //createHost record 
    public static String createHost(Id hostId){
         BypassTriggerReassignmentLogic=true;
        List<Sales_Host__c> hostList = new List<Sales_Host__c>();
        List<Id> mapofInputs = new List<Id>();
        mapofInputs.add(hostId);
        String reutrnMsg;
        //String reutrnMsg = Sales_LicenseGenerationGenericFunctions.hostReassigmentLogic(mapofInputs);
        //if(reutrnMsg!=System.Label.Sales_SuccessHostReassignment){//if any error occured while host reassigning
            for(Sales_Host__c host : [SELECT Id from Sales_Host__c where id  =:hostId]){
                hostList.add(host);
            }  
            if(hostList.size() > 0){ 
                delete hostList;
            }//in case of any exception delete the created host if any
        //}
        if(hostList.size() > 0){
            try{   
                update hostList;
            }
            catch (Exception ex) {
                if(ex.getMessage().contains('_EXCEPTION')){
                    String pureErrorMessage = ex.getMessage().substringAfter('_EXCEPTION,').substringBeforeLast(': [');
                    reutrnMsg = pureErrorMessage;
                }
            }
        }
        return reutrnMsg; 
    }
    
}