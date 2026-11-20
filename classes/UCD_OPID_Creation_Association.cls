public with sharing class UCD_OPID_Creation_Association {
    @AuraEnabled(cacheable=false)
    public static String getMessageFromApex(Id recordId) {
        system.debug('recordId-->'+recordId);
        List<Core_Account_Group_Member__c> agm = New List<Core_Account_Group_Member__c>();
        agm = [Select id, Core_Inactive_Ind__c,Core_Intel_Account_Id__c,Core_Intel_Partner_Alliance_PartnerGroup__c,Intel_Record_Type_Text__c,Core_MDA_Ind__c,Core_Partner_Account_Id__c,Primary_Account__c From Core_Account_Group_Member__c Where Core_Intel_Account_Id__c =:recordId AND Core_Inactive_Ind__c = false];
        system.debug('agm-->'+agm);
        
        Account acc = new Account();
        acc = [Select id, name,Unified_Hierarchy_View__c,Core_Intel_Partner_Alliance_PartnerGroup__c from Account where id =:recordId];
        system.debug('acc-->'+acc);
        
        List<Core_OnePartner_Inbound_Message__c> inboundRcd = new List<Core_OnePartner_Inbound_Message__c>();
        inboundRcd = [select id,name,Core_CIM_ID__c,Core_SalesCloud_AccountID__c,Core_Status__c,CreatedDate from Core_OnePartner_Inbound_Message__c where Core_SalesCloud_AccountID__c =:recordId and Core_Status__c = 'NEW'];
        system.debug('inboundRcd-->'+inboundRcd);
        
        List<PRM_AccountChannelMembership__c> activeACM = new List<PRM_AccountChannelMembership__c>();
        activeACM = [Select PRM_Account_Id__c, PRM_Status_Nm__c from PRM_AccountChannelMembership__c where PRM_Status_Nm__c = 'Approved' and PRM_Account_Id__c =:recordId];
        system.debug('activeACM-->'+activeACM);
        
        if(agm != null && !agm.IsEmpty()){
            return 'Please delink the existing 1PID association to create a new one';
        }
        else if(acc.Unified_Hierarchy_View__c != 'Global' && acc.Unified_Hierarchy_View__c != 'Intermediate'){
            return 'Please start 1PID association with Global or Intermediate account only.';
        }
        else if(inboundRcd != null && !inboundRcd.IsEmpty()){
            return 'The 1PID creation/association is in progress and a notification will be sent once the process is completed.';
        }
        /*else if(activeACM == null || activeACM.IsEmpty() && acc.Core_Intel_Partner_Alliance_PartnerGroup__c == false){
            return 'You cannot create a 1PID from a NON IPA account, Please register this Account with IPA and then continue with this action.';
        }*/
        //else{
            //return 'Please select the OPID associate or go ahead with new OPID creation';
            return null;
        //}
        
    }
}