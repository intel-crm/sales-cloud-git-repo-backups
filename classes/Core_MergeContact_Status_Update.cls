/******************************************************************************************************************************
Apex Class Name:  Core_MergeContact_Status_Update 
Version     : 1.0 
Created Date: 2 June 2017
Function    : contact integration status update to pending after Contact Entitlement Merged.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Prem Ranjan               02/06/2017              updateIntegrationStatus() method calls For contact integration status update to pending.
*******************************************************************************************************************************/

global class Core_MergeContact_Status_Update{

    @future
    public static void updateIntegrationStatus(List<Id> contactIds)
    {
        //Updating Integration Status.
        /*List<Contact> contactlst=new List<Contact>();
        for(Contact con:[select id,Core_AGS_Integration_Status__c,Core_ERPM_Integration_Status__c from Contact where id IN:contactId]){
            con.Core_ERPM_Integration_Status__c='Pending';
            con.Core_AGS_Integration_Status__c='Pending';
            contactlst.add(con);
        }
        if(contactlst.size()>0)
            update contactlst;*/
        
        //eRPM trigger logic -atb
        //Setting erpm/ags int status to pending
        //Set<Id> contactIds = new set<Id>();
        //for(Id conId : contactId){
        //    contactIds.add(conId);
       // }
        if(contactIds.size()>0)
            Core_ERPM_Outbound_Integration.evaluateAndSetERPMOutboundIntegrationStatus(null, new set<Id>(contactIds), true);
    }
}