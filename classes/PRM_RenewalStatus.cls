/****************************************************************************************************************************************
* Class Name  : PRM_DashboardTabVisibilityController 
* Version     : 1.0 
* Created Date: 26-Jun-2020
* Date                     Description
* ----------------------------------------------------------------------------------------------------------
* 4/06/2020               Created to check the visibility of Renewal link on Manage Benefit Page in IPA Community
*****************************************************************************************************************************************/

Public with sharing class PRM_RenewalStatus{

/***********************************************************************************************************************
        Method:    showMessage        
        Return:    Boolean value to show and hide renewal Link on manage benefit Page
        Purpose:   to show renewal Link on Manage Benefit Page
        
************************************************************************************************************************/  
   
    @auraenabled (cacheable=true)
    Public static boolean showMessage(){
        try{
        boolean showMessage=false;
        if(Boolean.valueOf(System.label.PRM_ShowIPARenewalTab) == false){
            return false;    
        }
        //Map<string,string> accountRoleMap=new map<string,string>();

        //get the partner role and Tier and Entitlement from metadata
        PMP_Dashboard_Tab__mdt dash=PMP_Dashboard_Tab__mdt.getInstance('Renewal');
        list<string> Partnerrole=string.isnotblank(dash.PRM_Partner_Role_Txt__c)?(dash.PRM_Partner_Role_Txt__c).split(';'):null;
        list<string> Tier= string.isnotblank(dash.PMP_Benefit_Code_Txt__c)?(dash.PMP_Benefit_Code_Txt__c).split(';'):null;
        list<string> entitlments=string.isnotblank(dash.PRM_Entitlement_Txt__c)?(dash.PRM_Entitlement_Txt__c).split(';'):null;
        //get the AccountID & partner role from Contact
        User usr=[Select contact.AccountId,contact.Core_IPA_PartnerRole__c from user where id =:Userinfo.getUserid()];
        List<Core_Contact_Entitlement__c> cce = [SELECT Core_Contact_Id__c,Core_Status__c,Core_Selected__c,Core_Display_Nm__c from Core_Contact_Entitlement__c where Core_Contact_Id__c=:usr.ContactId AND Core_Status__c=:Label.PRM_ACR_Status and Core_Selected__c =true and  Core_Display_Nm__c in :entitlments];
            
        //get ACM with same AccountID & Partner Role
        if(usr!=null && string.isnotblank(usr.contact.Core_IPA_PartnerRole__c ) && Partnerrole.size()>0 && Partnerrole.contains(usr.contact.Core_IPA_PartnerRole__c)){
            for(PRM_AccountChannelMembership__c acm:[select id,PRM_Account_Id__c,PRM_Partner_Role__c,PRM_Channel_Program_Level_Id__r.Name from PRM_AccountChannelMembership__c where PRM_Account_Id__c = :usr.Contact.AccountId and PRM_Partner_Role__c in :Partnerrole and PRM_Status_Nm__c='Approved']){
                if(string.isnotblank(acm.PRM_Channel_Program_Level_Id__r.Name) && Tier.size()>0 && Tier.contains(acm.PRM_Channel_Program_Level_Id__r.Name) && (cce[0].Core_Display_Nm__c == 'Employee' || cce[0].Core_Display_Nm__c == 'Partner Admin' || cce[0].Core_Display_Nm__c == 'Partner Admin Delegate')){
                    showMessage=true;
                }
             }
        }
        return showMessage;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

/***********************************************************************************************************************
        Method:    showLink        
        Return:    List of ACR to make sales drill down clickable and not clickable
        Purpose:   To make sales drill down clickable and not clickable
        
************************************************************************************************************************/  

    @AuraEnabled
    public static List<String> showLink(){
        try{
            User usr=[Select ContactId,contact.AccountId,contact.Core_IPA_PartnerRole__c from user where id =:Userinfo.getUserid()];
            List<String> acrRecList = new List<String>();
            if(usr!=null && string.isnotblank(usr.contactId)){
                for(PRM_Account_Contact_Relationship__c acr : [SELECT Id,PRM_Soft_Contact__c,PRM_InActive_Ind__c,PRM_Contact_Id__c,PRM_Account_Id__c,
                PRM_Relationship_Id__r.PRM_Default_Relationship_Ind__c,
                PRM_Relationship_Id__r.PRM_Mandatory_Relationship_Ind__c,PRM_Relationship_Id__r.Name FROM PRM_Account_Contact_Relationship__c 
                WHERE PRM_InActive_Ind__c = false AND PRM_Status_Nm__c = 'Complete' AND PRM_Contact_Id__c =:usr.ContactId]){
                    acrRecList.add(acr.PRM_Relationship_Id__r.Name);
                }
            }
                return acrRecList;            
            }catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }
}