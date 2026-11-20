public with sharing class  CommunityCaseClosureController{ // Changed by tushar for security venuability 

    public static final String CUSTOMER_REQUESTING_CLOSE = 'Customer Requesting Close';

    public String closureComments{get;set;}    
    public Case newCase{get;set;}
    public Boolean isEditable{get;set;}
    public Boolean showError{get;set;}
    
    public  CommunityCaseClosureController(ApexPages.StandardController controller){                     

        showError = false;
        newCase = (Case)controller.getRecord();
            isEditable = [SELECT HasEditAccess, RecordId 
                          FROM UserRecordAccess 
                          WHERE UserId =:userinfo.getuserId() 
                          AND RecordId = :newCase.Id].HasEditAccess;
        

        if (!isEditable) {
            showError = true;                    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error, 'You have insufficient privileges to edit this Case.  Click "Return" to continue.'));
            return;
        }
        //FLS Check Added - Nishitha
        if(Case.SObjectType.getDescribe().isAccessible()){
            newCase = [SELECT id, Core_Sub_Status__c, Core_IPS_Comment__c, Core_Closure_Comment__c, OwnerId 
                       FROM Case 
                       WHERE id = :newCase.Id];
        }
               
        if (newCase.Core_Sub_Status__c == CUSTOMER_REQUESTING_CLOSE){
            showError = True;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Info, 'Case status already set to "Customer Requested Close". Click "Return" to continue.'));
        } 

    }
    

    public PageReference requestCaseClosure(){
                       
        //FLS Check Added - Nishitha
        if (Schema.sObjectType.Case.fields.Status.isUpdateable()) {            
            newCase.Status                         = 'Open';
        }
        newCase.Core_Sub_Status__c             = CUSTOMER_REQUESTING_CLOSE;
        newCase.Core_Closure_Comment__c        = newCase.Core_Closure_Comment__c;

        
        // BM 8/1 - need to set this here when actuated by the button.
        newCase.Core_Next_Response_Due_Date__c = milestoneutils.getSetNextResponseDueDate(newCase);                                                        
        update newCase;

        Core_IPS_Case_Comments__c newComment = new Core_IPS_Case_Comments__c();
        newComment.Core_IPS_Case__c          = newCase.id;
        newComment.Core_IPS_Rich_Comment__c  = newCase.Core_Closure_Comment__c;
        newComment.Core_IPS_BgColor__c       = 'background-color:#7FFFD4'; 
        newComment.Core_IPS_Notetype__c      = 'Note from Customer';
        // Added for case comments
        newComment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c; 
        newComment.Core_IPS_Comment_Author_Type__c=Core_IPS_AddCommentController.getAuthr(String.valueOf((userinfo.getProfileId()).substring(0,15)),userinfo.getUserid());
        //insert newComment; // Changed by tushar for security venuability 
        if (Schema.sObjectType.Core_IPS_Case_Comments__c.isCreateable() &&
            Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case__c.isCreateable() &&
            Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Rich_Comment__c.isCreateable() &&
            Schema.sObjectType.Core_IPS_Case_Comments__c.fields.Core_IPS_Case_Comment_Type__c.isCreateable()) {
                insert newComment;
            }

        return new PageReference('/' + newCase.id);
    }


    public PageReference cancelOperation(){
        return new PageReference('/' + newCase.id);
    }
}