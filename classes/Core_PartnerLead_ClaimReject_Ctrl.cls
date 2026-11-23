public class Core_PartnerLead_ClaimReject_Ctrl {
    
    public List<Lead> selectedLeads{get;set;}
    public String listViewUrl{get;set;}
    public String errMsg{get;set;}
    public List<Lead>ClaimedLeadsUpdate;
    //Fetch the lead partner recordtype id
    public static String partnerRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Lead').getRecordTypeId();
    
    
    public Core_PartnerLead_ClaimReject_Ctrl(ApexPages.StandardSetController stdSetCtrl){
        String listViewId = stdSetCtrl.getFilterId().left(15);
        String objectId = Lead.sobjecttype.getDescribe().getKeyPrefix();
        listViewUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' + objectId + '?fcf=' + listViewId;
        selectedLeads = new List<Lead>();
        selectedLeads = (List<Lead>)stdSetCtrl.getSelected();
        String SelectatleaseOneLeadMsg = System.Label.Core_Bulk_Lead_Select_One_Record;
        if(selectedLeads.isEmpty()){
            errMsg = SelectatleaseOneLeadMsg;
        }
    }
    
    public void ClaimLeads(){
        
        List<Lead> SelectedLeadDetails=[Select id,Status,RecordTypeId from Lead Where Id IN: selectedLeads];
        ClaimedLeadsUpdate = new List<Lead>();
        
        List<Lead> NotinPRL= new List<Lead>();
        
        for(Lead L :SelectedLeadDetails){
            if(L.Status != 'PRL' || L.RecordTypeId != partnerRecTypeId){
                NotinPRL.add(L);
                
            }
            else{    
                L.Core_Partner_Lead_Owner__c = UserInfo.getUserId();
                L.Core_Lead_Status__c = 'Accepted'; 
                L.Core_Lead_State__c = 'In Pursuit';
                ClaimedLeadsUpdate.add(L);
                
            }
            
        }
        String NotValidRecords=System.Label.Core_Bulk_Lead_Invalid_Partner_Leads;
        String SuccessMessage=System.Label.Core_Bulk_lead_Claim_Success_Msg;
        if(NotinPRL.size ()> 0){
            errMsg = NotValidRecords;  
        }
        else if( NotinPRL.isEmpty() && ClaimedLeadsUpdate.size() >0){
            try{
                update ClaimedLeadsUpdate;
                errMsg=SuccessMessage;
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        
    }
    
}