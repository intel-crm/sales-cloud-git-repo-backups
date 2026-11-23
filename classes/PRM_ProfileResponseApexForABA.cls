public class PRM_ProfileResponseApexForABA {

    @TestVisible
    private static final string ORIGIN = 'PRM_ACMUpdateBatchUtility';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'IPA';
    private static final string ERROR_MESSAGE = 'Too many DML rows';
    static String logEntry='';
    
   /* public static list<Id> getABAAlreadyEligible(List<Id> actSpecificABAList){
        List<Id> abaListEligibleActive=new list<Id>();
    for(PRM_AccountBenefitAssociation__c aba:[select id,PRM_Status_Nm__c,PRM_Source__c,PRM_Partner_Benefit_Id__c from PRM_AccountBenefitAssociation__c where PRM_Partner_Benefit_Id__c in:actSpecificABAList ]){
        if(aba.PRM_Status_Nm__c=='Active'){
            abaListEligibleActive.add(aba.PRM_Partner_Benefit_Id__c);
        }
    }
    return abaListEligibleActive;
}*/

    public static void updateProfileResponse(Map<String, boolean> accountIdReponseMap){
        //Query on PROFILE RESPONSE FOR THESE ACCOUNTS AND GET optin response
        Map<Id,Map<String, PRM_Profile_Responses__c>> updateProfileReponseMap = new Map<Id, Map<String,PRM_Profile_Responses__c>>();
        List<PRM_Profile_Responses__c> profileResponseUpdate = new List<PRM_Profile_Responses__c>();
        Id optInQueId;
        Id notEligibleId;
        for(PRM_Profile_Responses__c reponseRecord :[select id,PRM_Profile_Questions_Id__c, PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Response_Txt__c from PRM_Profile_Responses__c 
                                                     where PRM_Account_Id__c in :accountIdReponseMap.keySet() and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c in :Label.PRM_PointsBnft_Response_codes.split(';')])
        {
            if(optInQueId==null && reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=='PRM_Opt_In' ){optInQueId = reponseRecord.PRM_Profile_Questions_Id__c;}
            if(notEligibleId==null && reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=='PRM_Point_Not_Eligible' ){notEligibleId=reponseRecord.PRM_Profile_Questions_Id__c;}
            
            if(updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(reponseRecord.PRM_Account_Id__c) ){
                updateProfileReponseMap.get(reponseRecord.PRM_Account_Id__c).put(reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,reponseRecord); 
                
            }else{
                updateProfileReponseMap.put(reponseRecord.PRM_Account_Id__c,new Map<String,PRM_Profile_Responses__c>{reponseRecord.PRM_Profile_Questions_Id__r.PRM_Question_Cd__c=>reponseRecord}); 
            }
            
        }
        
        SYstem.debug('updateProfileReponseMap -->'+updateProfileReponseMap);
        
        if(optInQueId==null || notEligibleId ==null){
            for( PRM_Profile_Questions__c pr :  [select Id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c=:Label.PRM_PointsBnft_Response_codes.split(';')]){
                if(optInQueId==null && pr.PRM_Question_Cd__c=='PRM_Opt_In' ){optInQueId = pr.Id;}
                if(notEligibleId==null && pr.PRM_Question_Cd__c=='PRM_Point_Not_Eligible' ){notEligibleId=pr.Id;}
            }
        }
        
        SYstem.debug('optInQueId -->'+optInQueId);
        SYstem.debug('notEligibleId -->'+notEligibleId);
        
        if(accountIdReponseMap.size()>0){
            for(String accountId : accountIdReponseMap.keySet()){
                if(accountIdReponseMap.get(accountId)){
                    profileResponseUpdate.add(createProfileResponse(accountId, optInQueId, string.valueOf(system.today()), (updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In'))?updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id:null));
                    profileResponseUpdate.add(createProfileResponse(accountId, notEligibleId, 'false', (updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible'))?updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id:null));
                }else{
                    profileResponseUpdate.add(createProfileResponse(accountId, optInQueId,'false' , (updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Opt_In'))?updateProfileReponseMap.get(accountId).get('PRM_Opt_In').Id:null));
                    profileResponseUpdate.add(createProfileResponse(accountId, notEligibleId, string.valueOf(system.today()), (updateProfileReponseMap.size()>0 && updateProfileReponseMap.containsKey(accountId) && updateProfileReponseMap.get(accountId).containsKey('PRM_Point_Not_Eligible'))?updateProfileReponseMap.get(accountId).get('PRM_Point_Not_Eligible').Id:null));
                }                
            }
        }
        
        System.debug('updateProfileReponseMap -->'+profileResponseUpdate);
        
        if(profileResponseUpdate.size()>0){
            upsertData(profileResponseUpdate);
        }
        System.debug('updateProfileReponseMap.values -->'+profileResponseUpdate);
    }
    
    
    //create PROFILE RESPONSE
    public static PRM_Profile_Responses__c createProfileResponse(Id accountId, Id questionId, String respText, Id responseId){
        PRM_Profile_Responses__c pr;
        pr = new PRM_Profile_Responses__c();
        pr.Id = responseId;
        System.debug('response id --->'+responseId);
        if(responseId==null){
            pr.PRM_Account_Id__c = accountId;    	   
            pr.PRM_Profile_Questions_Id__c = questionId;
        }        
        pr.PRM_Response_Txt__c = respText;
        return pr;
    }
    
    
    //----------- common method for upsert(Insert/Update) operation -----------------
    public static void upsertData(List<SObject> newLst) {            
        if(newLst!=null && !newLst.isEmpty()) {
           
            Database.UpsertResult[] urList = Database.upsert(newLst, false);
            Integer index  = 0;
            for(Database.UpsertResult ur : urList){
                if(!ur.isSuccess()){
                    Id sId;
                    string sObjectType = '';
                    string tags = '';
                    for(Database.Error err : ur.getErrors()){
                        logEntry+='Error -->'+err.getMessage()+'Record Id -->'+ur.getId();   
                        sId = newLst[index].Id;
                        if(sId != null)
                        {
                            sObjectType = sId.getSObjectType().getDescribe().getName();
                        }                        
                        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT, 'Message', SEVERITY, err.getMessage(), '', sId, sObjectType, tags);
                    }
                }
                index++;
            }
        
        System.debug('newLst -->'+newLst);
    }
    }
    
    /*public static void UpsertResponseWithoutBenefit(Map<Id,List<PRM_AccountBenefitAssociation__c>> actIdabaListMap){
       Set<String> pointsBenefits = new Set<String>();
	   pointsBenefits.addAll(Label.PRM_benefits_for_point_not_eligible_flag.split(';'));
        Set<Id> acctWithPointsBenefit = new Set<Id>();
		Set<Id> acctWithOutPointsBenefit =actIdabaListMap.keySet();
		for(Id acctId : actIdabaListMap.keySet()){
			for(PRM_AccountBenefitAssociation__c aba : actIdabaListMap.get(acctId)){
				if(pointsBenefits.contains(aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c)){
					acctWithPointsBenefit.add(acctId);
				}
			}
		}
		acctWithOutPointsBenefit.removeAll(acctWithPointsBenefit);
		List<PRM_Profile_Responses__c> prList=new list<PRM_Profile_Responses__c>();
        PRM_Profile_Questions__c prQuestion =[select Id,PRM_Question_Cd__c from PRM_Profile_Questions__c where PRM_Question_Cd__c='PRM_Point_Not_Eligible'];
			for(Id accId:acctWithOutPointsBenefit){
						PRM_Profile_Responses__c pr;
						pr = new PRM_Profile_Responses__c();
						pr.PRM_Account_Id__c =accId;         
						pr.PRM_Profile_Questions_Id__c=prQuestion.Id;
   						pr.PRM_Response_Txt__c = 'true';
						prList.add(pr);
            }
			for(PRM_Profile_Responses__c reponseRecord :[select id,PRM_Profile_Questions_Id__c, PRM_Account_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c, PRM_Profile_Questions_Id__r.PRM_Question_Cd__c, PRM_Response_Txt__c from PRM_Profile_Responses__c 
                                                     where PRM_Account_Id__c in :acctWithOutPointsBenefit and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c='PRM_Opt_In']){
					reponseRecord.PRM_Response_Txt__c='false';
					prList.add(reponseRecord);
				}
								
			upsert prList;

}*/

}