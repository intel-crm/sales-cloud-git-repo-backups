public class Core_Mass_Claim_Prospect {
    
        
    public List<Core_Prospect__c> selectedLeads{get;set;}
    public String listViewUrl{get;set;}
    public String errMsg{get;set;}
    public List<Core_Prospect__c>ClaimedLeadsUpdate;
    //Fetch the lead partner recordtype id
    public static String partnerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
    
    
    public Core_Mass_Claim_Prospect(ApexPages.StandardSetController stdSetCtrl){
        String listViewId = stdSetCtrl.getFilterId().left(15);
        String objectId = Core_Prospect__c.sobjecttype.getDescribe().getKeyPrefix();
        system.debug('ObjectId'+objectId);
        listViewUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' + objectId + '?fcf=' + listViewId;
        selectedLeads = new List<Core_Prospect__c>();
        selectedLeads = (List<Core_Prospect__c>)stdSetCtrl.getSelected();
        
       
    }
    
    public void ClaimLeads(){
        String SelectatleaseOneLeadMsg = System.Label.Core_Bulk_Lead_Select_One_Record;
        system.debug('Selected'+selectedLeads.size());
        if(selectedLeads.isEmpty()){
            errMsg = SelectatleaseOneLeadMsg;
        }else{
        List<Core_Prospect__c> SelectedLeadDetails=[Select id,OwnerId from Core_Prospect__c Where Id IN: selectedLeads];
        ClaimedLeadsUpdate = new List<Core_Prospect__c>();
        
        List<Lead> NotinPRL= new List<Lead>();
        
        for(Core_Prospect__c L :SelectedLeadDetails){
           
                
                L.OwnerId = UserInfo.getUserId();
              
                ClaimedLeadsUpdate.add(L);
                
          
            
        }
        String NotValidRecords=System.Label.Core_Bulk_Lead_Invalid_Partner_Leads;
        String SuccessMessage=System.Label.Core_Bulk_lead_Claim_Success_Msg;
       
            try{
                update ClaimedLeadsUpdate;
                errMsg='Prospects claimed succcesfully';
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
        
        
    }
    }
}