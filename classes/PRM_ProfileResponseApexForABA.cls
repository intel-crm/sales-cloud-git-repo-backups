public with sharing class PRM_ProfileResponseApexForABA {

    @TestVisible
    private static final string ORIGIN = 'PRM_ACMUpdateBatchUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    static String logEntry='';
	
    public static void updateProfileResponse(Map<String, boolean> accountIdReponseMap){
        //Query on PROFILE RESPONSE FOR THESE ACCOUNTS AND GET optin response
        Map<Id,Map<String, PRM_Profile_Responses__c>> updateProfileReponseMap = new Map<Id, Map<String,PRM_Profile_Responses__c>>();
        
        Id optInQueId;
        Id notEligibleId;
        for(PRM_Profile_Responses__c reponseRecord :[select id,PRM_Profile_Questions_Id__c, PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Response_Txt__c from PRM_Profile_Responses__c 
                                                     where PRM_Account_Id__c in :accountIdReponseMap.keySet() and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c in :Label.PRM_PointsBnft_Response_codes.split(';')])
        {
            if(optInQueId==null && reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=='PRM_Opt_In' ){
                optInQueId = reponseRecord.PRM_Profile_Questions_Id__c;}
            if(notEligibleId==null && reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=='PRM_Point_Not_Eligible' ){notEligibleId=reponseRecord.PRM_Profile_Questions_Id__c;}
            
            if(updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(reponseRecord.PRM_Account_Id__c) ){
                updateProfileReponseMap.get(reponseRecord.PRM_Account_Id__c).put(reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,reponseRecord); 
                
            }else{
                updateProfileReponseMap.put(reponseRecord.PRM_Account_Id__c,new Map<String,PRM_Profile_Responses__c>{reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=>reponseRecord}); 
            }
        }
        updateProfileResponse1(optInQueId, notEligibleId, updateProfileReponseMap,accountIdReponseMap);
    }
    
    //cognitive complexity:
  public static void  updateProfileResponse1(Id optInQueId, Id notEligibleId, Map<Id,Map<String, PRM_Profile_Responses__c>> updateProfileReponseMap,Map<String, boolean> accountIdReponseMap){
        List<PRM_Profile_Responses__c> profileResponseUpdate = new List<PRM_Profile_Responses__c>();
        if(optInQueId==null || notEligibleId ==null){
            for( PRM_Profile_Questions__c pr :  [select Id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c=:Label.PRM_PointsBnft_Response_codes.split(';')]){
                if(optInQueId==null && pr.PRM_Question_Cd__c=='PRM_Opt_In' ){optInQueId = pr.Id;}
                if(notEligibleId==null && pr.PRM_Question_Cd__c=='PRM_Point_Not_Eligible' ){notEligibleId=pr.Id;}
            }
        }
        
        // Call the method
        updateProfileResponses(accountIdReponseMap, updateProfileReponseMap, profileResponseUpdate, optInQueId, notEligibleId);

      
        if(profileResponseUpdate.size()>0){
            upsertData(profileResponseUpdate);
        }
    }
    
    public static void updateProfileResponses(Map<String, Boolean> accountIdReponseMap, Map<Id,Map<String, PRM_Profile_Responses__c>> updateProfileReponseMap, List<PRM_Profile_Responses__c> profileResponseUpdate, Id optInQueId, Id notEligibleId) {
    if (accountIdReponseMap.size() > 0) {
        for (String accountId : accountIdReponseMap.keySet()) {
            if (accountIdReponseMap.get(accountId)) {
                createProfileResponseWrapper obj1=new createProfileResponseWrapper();
                obj1.accountId=accountId;
                obj1.questionId=optInQueId;
                obj1.respText=String.valueOf(System.today());
                obj1.responseId=(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In')) ? updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id: null;
                profileResponseUpdate.add(createProfileResponse(obj1));//JB
                //profileResponseUpdate.add(createProfileResponse(accountId, optInQueId, String.valueOf(System.today()),(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In')) ? updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id : null));
		        
                createProfileResponseWrapper obj2=new createProfileResponseWrapper();
                obj2.accountId=accountId;
                obj2.questionId=notEligibleId;
                obj2.respText='false';
                obj2.responseId=(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible')) ? updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id : null;
                profileResponseUpdate.add(createProfileResponse(obj2));//JB               
                //profileResponseUpdate.add(createProfileResponse(accountId, notEligibleId, 'false', (updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible')) ? updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id : null));
            } else {
                createProfileResponseWrapper obj3=new createProfileResponseWrapper();
                obj3.accountId=accountId;
                obj3.questionId=optInQueId;
                obj3.respText='false';
                obj3.responseId=(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In')) ? updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id : null;
                profileResponseUpdate.add(createProfileResponse(obj3));//JB    
                //profileResponseUpdate.add(createProfileResponse(accountId, optInQueId,'false',(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In')) ? updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id : null));
                
                createProfileResponseWrapper obj4=new createProfileResponseWrapper();
                obj4.accountId=accountId;
                obj4.questionId=notEligibleId;
                obj4.respText=String.valueOf(System.today());
                obj4.responseId=(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible')) ? updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id : null;
                profileResponseUpdate.add(createProfileResponse(obj4));//JB
                //profileResponseUpdate.add(createProfileResponse(accountId, notEligibleId,String.valueOf(System.today()),(updateProfileReponseMap.size() > 0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible')) ? updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id : null));
            }
        }
    }
}

    //create PROFILE RESPONSE
    /*public static PRM_Profile_Responses__c createProfileResponse(Id accountId, Id questionId, String respText, Id responseId){
        PRM_Profile_Responses__c pr;
        pr = new PRM_Profile_Responses__c();
        pr.Id = responseId;
        if(responseId==null){
            pr.PRM_Account_Id__c = accountId;    	   
            pr.PRM_Profile_Questions_Id__c = questionId;
        }        
        pr.PRM_Response_Txt__c = respText;
        return pr;
    }*/
    
    public class createProfileResponseWrapper{
        public Id accountId{get;set;}
        public Id questionId{get;set;}
        public String respText{get;set;}
        public Id responseId{get;set;}
    }//JB
    
    public static PRM_Profile_Responses__c createProfileResponse(createProfileResponseWrapper att){
        PRM_Profile_Responses__c pr;
        pr = new PRM_Profile_Responses__c();
        pr.Id = att.responseId;
        if(att.responseId==null){
            pr.PRM_Account_Id__c = att.accountId;    	   
            pr.PRM_Profile_Questions_Id__c = att.questionId;
        }        
        pr.PRM_Response_Txt__c = att.respText;
        return pr;
    }
    
   //----------- common method for upsert(Insert/Update) operation -----------------
   
   public static void upsertData(List<SObject> newLst) {            
    if (newLst == null || newLst.isEmpty()) {
        return;
    } 
    Database.UpsertResult[] urList = Database.upsert(newLst, false);
    logErrors(urList, newLst);

}
 
private static void logErrors(Database.UpsertResult[] urList, List<SObject> newLst) {
    for (Integer i = 0; i < urList.size(); i++) {
        Database.UpsertResult ur = urList[i];
        if (!ur.isSuccess()) {
            logErrorDetails(ur.getErrors(), newLst[i]);
        }
    }
}
 
private static void logErrorDetails(List<Database.Error> errors, SObject obj) {
    for (Database.Error err : errors) {
        String errorMessage = 'Error --> ' + err.getMessage() + ' Record Id --> ' + obj.Id;
        String objectType = '';
        String tags = '';
        if (obj.Id != null) {
            objectType = obj.Id.getSObjectType().getDescribe().getName();
        }
        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, errorMessage, '', obj.Id, objectType, tags);
    }

}

 public static void updateProfilePointsResponse(Map<String, boolean> accountIdReponseMap){
        //Query on PROFILE RESPONSE FOR THESE ACCOUNTS AND GET optin response
        Map<Id,Map<String, PRM_Profile_Responses__c>> updateProfileReponseMap = new Map<Id, Map<String,PRM_Profile_Responses__c>>();
        List<PRM_IPAMembership_Attributes__c> listOfResponses = new List<PRM_IPAMembership_Attributes__c>();
        Map<ID,PRM_IPAMembership_Attributes__c> accountResponses = new Map<ID,PRM_IPAMembership_Attributes__c>();
        for(PRM_IPAMembership_Attributes__c reponseRecord :[SELECT Id,RecordTypeId, PRM_Account_Id__c,PRM_Points_Not_Eligible_Dt__c, PRM_Points_Not_Eligible_Ind__c, PRM_Points_Opt_in_Dt__c, PRM_Points_Opt_in_Ind__c, PRM_Points_Not_Eligible_Reason_Txt__c from PRM_IPAMembership_Attributes__c  where PRM_Account_Id__c in  :accountIdReponseMap.keySet()])
        {
            accountResponses.put(reponseRecord.PRM_Account_Id__c,reponseRecord);

        }
       for (String accountId : accountIdReponseMap.keySet()) {
         PRM_IPAMembership_Attributes__c responseRec = new PRM_IPAMembership_Attributes__c();
         responseRec.id = accountResponses.get(accountId)!=NULL ? accountResponses.get(accountId).Id : null;
         responseRec.PRM_Account_Id__c = accountId;
         responseRec.RecordTypeId = accountResponses.get(accountId)!=NULL ? accountResponses.get(accountId).RecordTypeId : null;
         if(accountIdReponseMap.get(accountId)){
            responseRec.PRM_Points_Not_Eligible_Ind__c = false;
            responseRec.PRM_Points_Not_Eligible_Dt__c = null;
            responseRec.PRM_Points_Opt_in_Ind__c = true;
            responseRec.PRM_Points_Opt_in_Dt__c = System.today();

         }else if (!accountIdReponseMap.get(accountId)){
            responseRec.PRM_Points_Not_Eligible_Ind__c = true;
            responseRec.PRM_Points_Not_Eligible_Dt__c = System.today();
            responseRec.PRM_Points_Opt_in_Ind__c = false;
            responseRec.PRM_Points_Opt_in_Dt__c = null;
         }
        listOfResponses.add(responseRec);
       }
        List<PRM_IPAMembership_Attributes__c> listOfResponsesToUpdate = new List<PRM_IPAMembership_Attributes__c>();
       listOfResponsesToUpdate = PRM_ProfileResponseOptIn.pointStatusCalc_IPAR(listOfResponses,null);
       if(listOfResponses.size()>0){
           Database.UpsertResult[] urList =  database.upsert(listOfResponsesToUpdate,false);
        
       for (Integer i = 0; i < urList.size(); i++) {
        Database.UpsertResult ur = urList[i];
        if (!ur.isSuccess()) {
            logErrorDetails(ur.getErrors(), listOfResponses[i]);
        }
    }
       }
        
    }

}