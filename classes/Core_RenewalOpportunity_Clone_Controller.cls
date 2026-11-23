public class Core_RenewalOpportunity_Clone_Controller {
    public Core_RenewalOpportunity_Clone_Controller(){
        Opportunity currentOpportunity;
         /*currentOpportunity = [SELECT Id, Name, Owner.IsActive, Core_Technical_Owner__r.isActive, Account.Name, Account.RecordType.Name,core_Sales_Segments__c, Core_Consumption_Market__c,Core_Product_Application__c,Core_Product_Segment__c,
                              Account.Core_Military_Aerospace_and_Government__c, Core_Military_Aerospace_Govmt_End_Use__c,Core_Intel_Platform__c,Core_First_Customer_Ship_Date__c,CloseDate, Core_Volume__c,Core_Production_End_Date__c,Core_Manufacturing_Geo__c,Core_Solution_Area__c,Pricebook2Id                              
                              FROM Opportunity  WHERE Id = :currentOpportunity.Id WITH SECURITY_ENFORCED]; //TWC3123-5310 - Added WITH SECURITY_ENFORCED
        currentOpportunity.Core_Military_Aerospace_Govmt_End_Use__c = null;
        String accountRecordTypeName = currentOpportunity.Account.RecordType.Name;*/
        
        
    }
    
    /*public static void continueClone(){
        //Getting copied attachment or notes from existing opportunity to Renewal Opp
        if(isAttachmentSelected && showAttachment){
            //Notes & Attachment queries were modified to remove body field in constructor, as it was adding the view state.
            attList=new List<Attachment>([SELECT Id, Body, Name, ParentId, ContentType, Parent.Type,BodyLength,Description from Attachment where parentId=:currentOpportunity.Id]);
            insertCloneOppAttachment(oppRec.Id,attList);
        }
    }*/
    
    public static void insertCloneOppAttachment(Id newOppId, List<Attachment> attList){
         List<Attachment> lstAttachment=new List<Attachment>(); 
            for(Attachment at: attList){
                Attachment cloneAtt= at.clone();
                cloneAtt.ParentId=newOppId;
                lstAttachment.add(cloneAtt);          
            }
          if(lstAttachment!= null && !(lstAttachment.isEmpty())){
                //TWC3123-5310 - Added isCreatable check
                 if(Schema.sObjectType.Attachment.isCreateable()){
                     insert lstAttachment; 
                 }
            }
        
    }
    
    public static void insertCloneAttachments(){
        
    }
    
     public String getAllFields(String sobjectname){
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(sobjectname).getDescribe().SObjectType.getDescribe().fields.getMap();
        
        List<String> accessiblefields = new List<String>();
        for(Schema.SObjectField field : fields.values()){
            if(field.getDescribe().isAccessible())
                accessiblefields.add(field.getDescribe().getName());
        }
        
        String allfields='';
        for(String fieldname : accessiblefields)
            allfields += fieldname+',';
        
        allfields = allfields.subString(0, allfields.length()-1);
        
        return allfields;
    }
    @InvocableMethod(label='Invoke renewal Opp clone')
    public static void invokeRenewalOpp(){
        system.debug('Inside renewal clone invocable method');
        
        
    }
}