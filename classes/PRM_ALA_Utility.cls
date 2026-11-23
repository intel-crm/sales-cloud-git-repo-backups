public with sharing class PRM_ALA_Utility {

    //public static boolean IPARefresh = Boolean.valueOf(label.PRM_IPARefresh); // IPA Switch Removal
   
    public static List<PRM_AccountLegalAgreemntAssociation__c> PopulateLegalAgreeOnOPID(List<PRM_AccountLegalAgreemntAssociation__c> newIntelAcctAla) {
 Set<String> locationAccntsIdSet = new Set<String>();
 Set<String> opidAccountIds = new Set<String>();
 List<Core_Account_Group_Member__c> opidMemberList = new List<Core_Account_Group_Member__c>();
 Set<Id> opidsWithLegalAggrSet = new Set<Id>();
 Map<Id, Id> opidWithoutLegalAggrLocMap = new Map<Id, Id>();
 Map<Id, String> locAccIdToNameMap = new Map<Id, String>();
 Map<Id, PRM_AccountLegalAgreemntAssociation__c> opidLegalAggrMap = new Map<Id, PRM_AccountLegalAgreemntAssociation__c>();
 List<PRM_AccountLegalAgreemntAssociation__c> finalLegalAggrList = new List<PRM_AccountLegalAgreemntAssociation__c>();

 locationAccntsIdSet.addAll(getLocationAccountIds(newIntelAcctAla));

 if (!locationAccntsIdSet.isEmpty()) {
     opidMemberList.addAll(getOpidMembers(locationAccntsIdSet));
 }
 
 for (Core_Account_Group_Member__c pagm : opidMemberList) {
     opidAccountIds.add(pagm.Core_Partner_Account_Id__c);
 }

 opidsWithLegalAggrSet.addAll(getOpidsWithLegalAgreements(opidAccountIds));

 opidWithoutLegalAggrLocMap.putAll(getOpidsWithoutLegalAgreements(opidMemberList, opidsWithLegalAggrSet, locAccIdToNameMap));

 if (!opidWithoutLegalAggrLocMap.isEmpty()) {
     opidLegalAggrMap.putAll(createLegalAgreements(newIntelAcctAla, opidWithoutLegalAggrLocMap, locAccIdToNameMap));
 }

 if (!opidLegalAggrMap.isEmpty()) {
     finalLegalAggrList.addAll(opidLegalAggrMap.values());
 }

 return finalLegalAggrList;
}

private static Set<String> getLocationAccountIds(List<PRM_AccountLegalAgreemntAssociation__c> newIntelAcctAla) {
  Set<String> locationAccntsIdSet = new Set<String>();
  for (PRM_AccountLegalAgreemntAssociation__c ala : newIntelAcctAla) {
     locationAccntsIdSet.add(ala.PRM_Account_Id__c);
 }
 return locationAccntsIdSet;
}

private static List<Core_Account_Group_Member__c> getOpidMembers(Set<String> locationAccntsIdSet) {
 List<Core_Account_Group_Member__c> opidMemberList = new List<Core_Account_Group_Member__c>();

 opidMemberList = [SELECT Id, Core_Intel_Account_Id__c, Core_Intel_Account_Id__r.Name, Core_Partner_Account_Id__c, Core_Inactive_Ind__c
                  FROM Core_Account_Group_Member__c
                  WHERE Core_Intel_Account_Id__c IN :locationAccntsIdSet AND Core_Inactive_Ind__c = false];

 return opidMemberList;
}

private static Set<Id> getOpidsWithLegalAgreements(Set<String> opidAccountIds) {
 Set<Id> opidsWithLegalAggrSet = new Set<Id>();

 if (!opidAccountIds.isEmpty()) {
     for (PRM_AccountLegalAgreemntAssociation__c legalAgreement : [SELECT Id,PRM_Account_Id__c
                                                          FROM PRM_AccountLegalAgreemntAssociation__c
                                                          WHERE PRM_Partner_Agreement_Id__r.PRM_Agreement_Cd__c = 'IPA_TANDC' AND PRM_Account_Id__c IN :opidAccountIds]) {
          opidsWithLegalAggrSet.add(legalAgreement.PRM_Account_Id__c);
     }
 }
 return opidsWithLegalAggrSet;
}

private static Map<Id, Id> getOpidsWithoutLegalAgreements(List<Core_Account_Group_Member__c> opidMemberList, Set<Id> opidsWithLegalAggrSet, Map<Id, String> locAccIdToNameMap) {
 Map<Id, Id> opidWithoutLegalAggrLocMap = new Map<Id, Id>();

 for (Core_Account_Group_Member__c pagmRec : opidMemberList) {
     if (!opidsWithLegalAggrSet.contains(pagmRec.Core_Partner_Account_Id__c)) {
         opidWithoutLegalAggrLocMap.put(pagmRec.Core_Intel_Account_Id__c, pagmRec.Core_Partner_Account_Id__c);
     }
 }

 return opidWithoutLegalAggrLocMap;
}

private static Map<Id, PRM_AccountLegalAgreemntAssociation__c> createLegalAgreements(List<PRM_AccountLegalAgreemntAssociation__c> newIntelAcctAla, Map<Id, Id> opidWithoutLegalAggrLocMap, Map<Id, String> locAccIdToNameMap) {
 Map<Id, PRM_AccountLegalAgreemntAssociation__c> opidLegalAggrMap = new Map<Id, PRM_AccountLegalAgreemntAssociation__c>();

 for (PRM_AccountLegalAgreemntAssociation__c ala : newIntelAcctAla) {
     PRM_AccountLegalAgreemntAssociation__c opidAla = new PRM_AccountLegalAgreemntAssociation__c();

     opidAla.PRM_Account_Id__c = opidWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c);
     // IPA Refresh 2.0 - TWC729-7874-start
    opidAla.PRM_Signed_By_Email__c = ala.PRM_Signed_By_Email__c;
    opidAla.PRM_Signed_By_Name__c = ala.PRM_Signed_By_Name__c;
     //IPA Refresh 2.0 - TWC729-7874-end
     opidAla.PRM_Agreement_Sign_Dt__c = ala.PRM_Agreement_Sign_Dt__c;
     opidAla.PRM_Partner_Agreement_Id__c = ala.PRM_Partner_Agreement_Id__c;
     opidAla.PRM_InActive_Ind__c = false;
     opidAla.PRM_Notes_Txt__c = 'Terms and Condition acceptance rolled up from the location account' + ' ' + locAccIdToNameMap.get(ala.PRM_Account_Id__c) + ' ' + 'as part of T&C roll up.';

     if (!opidLegalAggrMap.containsKey(opidAla.PRM_Account_Id__c)) {
         opidLegalAggrMap.put(opidWithoutLegalAggrLocMap.get(ala.PRM_Account_Id__c), opidAla);
     }
 }

 return opidLegalAggrMap;
}


    //ATHR Fix - TWC729-9556 - JB
/* public static void updateProfileResponse(List<PRM_AccountLegalAgreemntAssociation__c> intelAcc)
 {
     Set<id> setAccid = new Set<id>();
     Map<Id,String> questionIdCodeMap = new Map<Id,String>();
     Map<String,id> questionCodeIdMap = new  Map<String,id>();    
         
     for(PRM_AccountLegalAgreemntAssociation__c laRec:(List<PRM_AccountLegalAgreemntAssociation__c>)intelAcc){
        setaccId.add(laRec.PRM_Account_Id__c);
        } 
     List<PRM_Profile_Responses__c> profileResponse = new List<PRM_Profile_Responses__c>();
     List<String>  questionType= new List<String>{'PRM_Opt_In','PRM_Point_Not_Eligible'};
     for(PRM_Profile_Questions__c pq: [select id,PRM_Question_Cd__c from PRM_Profile_Questions__c]){              
         questionCodeIdMap.put(pq.PRM_Question_Cd__c,pq.id);
         questionIdCodeMap.put(pq.id,pq.PRM_Question_Cd__c);                   
     }     
     profileResponse = [Select id,PRM_Account_Id__c,PRM_Profile_Answer_Id__c,PRM_Profile_Questions_Id__c,PRM_Profile_Questions_Id__r.PRM_Question_Cd__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__r.PRM_Question_Type_Nm__c,PRM_Profile_Questions_Id__r.PRM_Question_Display_Txt__c,LastModifiedDate,LastModifiedBy.Name,PRM_View_History__c,PRM_InActive_Ind__c,PRM_Reason_Text__c from PRM_Profile_Responses__c Where PRM_Account_Id__c in :setaccId and PRM_Profile_Questions_Id__r.PRM_Question_Cd__c in:questionType order by LastModifiedDate ASC];
    
     PRM_ProfileResponse.pointsCalculation(profileResponse,null); 
     

 }*/
 
    public static void updateProfileResponse_IPAR(List<PRM_AccountLegalAgreemntAssociation__c> intelAcc)
 {
     Set<id> setAccid = new Set<id>();  
     for(PRM_AccountLegalAgreemntAssociation__c laRec:(List<PRM_AccountLegalAgreemntAssociation__c>)intelAcc){
        setaccId.add(laRec.PRM_Account_Id__c);
     } 
     List<PRM_IPAMembership_Attributes__c> profileResponse = new List<PRM_IPAMembership_Attributes__c>(); 
     profileResponse = [Select id,PRM_Account_Id__c,PRM_Points_Opt_in_Ind__c,PRM_Points_Not_Eligible_Ind__c,PRM_Points_Opt_in_Dt__c,PRM_Points_Not_Eligible_Dt__c,PRM_Point_Status_Txt__c,PRM_Point_Status_Dt__c,LastModifiedDate,LastModifiedBy.Name from PRM_IPAMembership_Attributes__c Where PRM_Account_Id__c in :setaccId order by LastModifiedDate ASC];
     List<PRM_IPAMembership_Attributes__c> profRespALAList=PRM_ProfileResponseOptIn.pointStatusCalc_IPAR(profileResponse,null);
     if(!profRespALAList.isEmpty()){
        Database.update(profRespALAList,false);    
            
     }
 }
 
 public static void updateLACode(List<PRM_AccountLegalAgreemntAssociation__c> intelAcc){        
     for(PRM_AccountLegalAgreemntAssociation__c laRec:(List<PRM_AccountLegalAgreemntAssociation__c>)intelAcc){
         if(laRec.PRM_Legal_Agreement_Name_Text__c != laRec.PRM_Partner_Agreement_Name__c){
             laRec.PRM_Legal_Agreement_Name_Text__c=laRec.PRM_Partner_Agreement_Name__c;
         }
                     
     }        
 }
 
}