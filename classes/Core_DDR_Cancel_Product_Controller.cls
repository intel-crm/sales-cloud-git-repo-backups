/***************************************************************************************************
Apex Class Name : Core_DDR_Cancel_Product_Controller
    Version         : 1.0
    Created Date    : 28-Sep-2017
    Function        : Used to cancel a single DR Product
    VF Page         : Core_DDR_Cancel_Product
    Modifications   :
     ****************************************************************************************************
 * Developer                 Date                Description
 * ----------------------------------------------------------------------------

Created.
     * Ashwin Dash               16-Aug-2018         Added changes for US125853 Design Registration: Fix Cancellation of products.
 * KavyaShree                22-Jul-2020         Security scan fix.
 * Venu Karumuru             08-Aug-2021         Removed code related to US125853, Cleaned up code.
 * Venu Karumuru             09-Sep-2021         Added logic to throw error message when the DR product that is Ineligible or Inactive is being Cancelled.
 * Chaithaly                 23-sep-2024         Added AccessLevel.User_mode to SOQL and DML statements.
 ****************************************************************************************************/

public with sharing Class Core_DDR_Cancel_Product_Controller
{
    public static final String LOG_ENTRY_ORIGIN   = 'Core_DDR_Cancel_Product_Controller';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Cancel Product';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'Info';
    public static Id currentUserId = UserInfo.getUserId();
    public static User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :currentUserId LIMIT 1];
    public static String userProfileName = currentUser.Profile.Name;
    public static string callAlertFunc
    {get; set;}
    
    
    @AuraEnabled
    public static string cancelProduct(Id recId) {
        String status = '';
        String alertMsg='';
        try {
            
            String userProfileId = UserInfo.getProfileId();
            
            List<Core_Design_Registration_Product__c> lstDDRProducts = new List<Core_Design_Registration_Product__c>();
            lstDDRProducts = [SELECT id,Core_Design_Registration_Id__r.Core_Opportunity_Id__c,PCC_Product_Additional_Attribute__r.Eligible_for_Deal_Reg__c,Core_Comment_Txt__c,Core_Design_Registration_Id__r.Core_Opportunity_Id__r.Core_Approval_Status__c, Core_Design_Registration_Id__r.PCC_Registration_Type__c,  Core_Opportunity_Product_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.IsActive, Core_Product_Id__r.Core_Design_Registration_Eligible_Ind__c,Core_Design_Registration_Id__r.Core_Opportunity_Id__r.StageName FROM Core_Design_Registration_Product__c WHERE ID=:recId WITH USER_MODE LIMIT 1];
            // deal prodcts
            //select Id, (select id from sbqq__OpportunityProducts__r) from SBQQ__QuoteLine__c  where SBQQ__Quote__r.SBQQ__Opportunity2__c ='006D3000009uen0IAA' and Pricing_Status_Nm__c ='Pending Further Intel Review'
            //check the quote line item status
            
            Id oppProdId = lstDDRProducts[0].Core_Opportunity_Product_Id__c;
            Id opportunityId = lstDDRProducts[0].Core_Design_Registration_Id__r.Core_Opportunity_Id__c;
            Boolean isDealReg = lstDDRProducts[0].Core_Design_Registration_Id__r.PCC_Registration_Type__c == 'Deal Registration';
            
            
            List<OpportunityLineItem> oppLineItem = new List<OpportunityLineItem>();
            
            if(!isDealReg){
                oppLineItem = !String.isEmpty(oppProdId) ? [Select Id,core_status__c from OpportunityLineItem where Id=:oppProdId WITH USER_MODE limit 1]:null;
            }else{
                List<SBQQ__QuoteLine__c> quotelines = [select Id, (select id from sbqq__OpportunityProducts__r) from SBQQ__QuoteLine__c  where SBQQ__Quote__r.SBQQ__Opportunity2__c =:opportunityId and Pricing_Status_Nm__c   in : LabelConfiguration__mdt.getInstance('PCC_QLIStatus').Value__c.trim().split(';') limit 1];
                if(quotelines.size()>0 ){
                    oppLineItem = quotelines[0].sbqq__OpportunityProducts__r!=null? quotelines[0].sbqq__OpportunityProducts__r :null;
                }
                
            }
            
            // adding check for Deal or Design
            //Added by DINESH as part of TWC727-1596
            
            alertMsg = checkValidation(isDealReg,oppLineItem.size()>0?oppLineItem[0]:null,lstDDRProducts[0]);
            
        } catch (Exception e) {
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Cancel_Product_Controller.cancelProduct' ,'' ,e);
            alertMsg=null;
        }
        return alertMsg;
        
    }
    
    public static string checkValidation(Boolean isDealReg, OpportunityLineItem oppLineItem, Core_Design_Registration_Product__c lstDDRProducts){
        String opptyApprovalStatus = LabelConfiguration__mdt.getInstance('PCC_Deal_SubmittedOpptyStatus').Value__c;
        final String qliStatus = LabelConfiguration__mdt.getInstance('PCC_QLIStatus').Value__c;
        List<String> statusList = QliStatus.split(';');
        String alertMsg='';
        alertMsg= String.isBlank(alertMsg.trim()) && isDealReg && oppLineItem!=null?LabelConfiguration__mdt.getInstance('PCC_Deal_CancelProductError').Value__c:alertMsg;
        
        alertMsg= String.isBlank(alertMsg.trim()) && isDealReg && !OpptyApprovalStatus.split(';').contains(lstDDRProducts.Core_Design_Registration_Id__r.Core_Opportunity_Id__r.Core_Approval_Status__c)?LabelConfiguration__mdt.getInstance('PCC_Deal_SubmittedOpptyAlert').Value__c:alertMsg;
        
        alertMsg=String.isBlank(alertMsg.trim()) && isDealReg && !lstDDRProducts.PCC_Product_Additional_Attribute__r.Eligible_for_Deal_Reg__c?LabelConfiguration__mdt.getInstance('PCC_DealDRPIneligibleAlert').Value__c:alertMsg;
        
        
        
        alertMsg=String.isBlank(alertMsg.trim()) && !isDealReg && lstDDRProducts.Core_Product_Id__r.Core_Design_Registration_Eligible_Ind__c == FALSE?LabelConfiguration__mdt.getInstance('PCC_DRPIneligibleAlert').Value__c:alertMsg;
        
        alertMsg=String.isBlank(alertMsg.trim()) && lstDDRProducts.Core_Product_Id__r.IsActive == FALSE?LabelConfiguration__mdt.getInstance('PCC_DRPInactiveAlert').Value__c:alertMsg;
        
        alertMsg= String.isBlank(alertMsg.trim()) && !isDealReg && (userProfileName=='Partner' || userProfileName=='B2B API Partner')&& lstDDRProducts.Core_Design_Product_Status_Nm__c == 'Rejected'?LabelConfiguration__mdt.getInstance('PCC_CancelButtonForApprovedorRejected').Value__c.replace('{1}',lstDDRProducts.Core_Design_Product_Status_Nm__c):alertMsg;
        alertMsg= String.isBlank(alertMsg.trim()) && !isDealReg && oppLineItem.Id !=null && (oppLineItem.core_status__c == 'Production Win Submitted' || oppLineItem.core_status__c == 'Production Cancelled'
            || oppLineItem.core_status__c == 'Production Win Approved'|| oppLineItem.core_status__c == 'Production Lost'
        || oppLineItem.core_status__c == 'Win Submitted' || oppLineItem.core_status__c == 'Win Approved')?LabelConfiguration__mdt.getInstance('PCC_CancelButtonForOpportunity').Value__c.replace('{1}',oppLineItem.core_status__c):alertMsg;
        
        return alertMsg;
    }
    
    @AuraEnabled
    public static boolean updatingComments(id recId,String cancelComments){
        try{
            // get recordtype Id
            Id lockedRecordTypeId = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();
            List<Core_Design_Registration_Product__c> lstDDRProducts = new List<Core_Design_Registration_Product__c>();
            lstDDRProducts = [SELECT id,Core_Design_Registration_Id__r.PCC_Registration_Type__c,Core_Comment_Txt__c,Core_Opportunity_Product_Id__c, Core_Design_Product_Status_Nm__c, Core_Product_Id__r.IsActive, Core_Product_Id__r.Core_Design_Registration_Eligible_Ind__c FROM Core_Design_Registration_Product__c WHERE ID=:recId WITH USER_MODE LIMIT 1];
            
            Core_Design_Registration_Product__c updateDRP = new Core_Design_Registration_Product__c(id=lstDDRProducts[0].id);
            updateDRP.Core_Design_Product_Status_Nm__c = 'Cancelled';
            updateDRP.Core_Locked_Ind__c = true;
            updateDRP.RecordTypeId = lstDDRProducts[0].Core_Design_Registration_Id__r.PCC_Registration_Type__c =='Deal Registration'?lockedRecordTypeId:Label.Core_DDR_Design_Product_Locked_Record_Type_ID;
            updateDRP.Core_Comment_Txt__c =lstDDRProducts[0].Core_Comment_Txt__c!=null?lstDDRProducts[0].Core_Comment_Txt__c+'\n'+cancelComments:cancelComments;
            
            Database.SaveResult results  = Database.update(updateDRP,false,AccessLevel.User_mode);
            System.enqueueJob(new PCC_UpdateOppLineItem(recId)); // Commented by DINESH
            //updateOppLineItem(recId);  // ADDED by DINESH
            return true;
        }catch (Exception e) {
            system.debug(e.getMessage());
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_DDR_Cancel_Product_Controller.cancelProduct' ,'' ,e);
            return false;
        }
    }
    
    public static void updateOppLineItem(id recId) {
        // Get the Opportunity line item tied to the DDR Product line item
        List<OpportunityLineItem> lstOppLI = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        lstOppLI = [SELECT Id,Core_Design_Registration_Product_Id__r.Core_Comment_Txt__c,Core_Design_Registration_Product_Id__r.Core_Design_Registration_Id__r.PCC_Registration_Type__c, Name, Core_Design_Registration_Product_Id__c, Core_Status__c FROM OpportunityLineItem WHERE Core_Status__c!='Production Cancelled' and Core_Status__c!='Cancelled' and Core_Design_Registration_Product_Id__c =: recId WITH USER_MODE];
        
        if (lstOppLI.size() > 0) {
            // Cancel the Opportunity line item
            for (OpportunityLineItem iOLI : lstOppLI)
            {
                OpportunityLineItem oliUpdate = new OpportunityLineItem( id = iOLI.id);
                if (iOLI.Core_Status__c == 'Production Win Approved'){iOLI.Core_Status__c = 'Production Cancelled';
                }
                else{
                    oliUpdate.Core_Status__c = 'Cancelled';
                }
                //Added by DINESH
                oliUpdate.Core_Loss_Cancel_Reason__c = iOLI.Core_Design_Registration_Product_Id__r.Core_Design_Registration_Id__r.PCC_Registration_Type__c =='Design Registration'?'Design Reg. Product Swap':'Entered in Error';
                oliUpdate.Core_Loss_Cancel_Details__c = iOLI.Core_Design_Registration_Product_Id__r.Core_Comment_Txt__c;
                oliToUpdate.add(oliUpdate);
            }
            
            // Update the cancelled record
            //update oliToUpdate;
            Database.update(oliToUpdate,false,AccessLevel.User_mode);
        }
    }
}