trigger Core_Commissions_Case on Core_AAQC_Commissions_Case__c (before insert) {
public static Id GetAskCommissionsRecordTypeId(){
        return Schema.SObjectType.Case.getRecordTypeInfosByName().get('Ask Commissions Case').getRecordTypeId();
    }
    
    if(trigger.isafter && trigger.isInsert){
        for(Core_AAQC_Commissions_Case__c caseInquiry : Trigger.New){
            if(caseInquiry != null && caseInquiry.Core_AAQC_Case__c != null){
                List<case> lstCase = [select id,Core_AAQC_Commission_Inquiry_Id__c,RecordTypeId from case where id =:caseInquiry.Core_AAQC_Case__c];
                if(lstCase != null && lstCase.size() > 0){
                    
                }
            }
                
        }
    }
}