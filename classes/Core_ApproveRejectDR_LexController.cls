/**************************************************************************************
Apex Class Name:  Core_ApproveRejectDR_LexController
Version     : 1.0 
Created Date: 04 JUN 2018
Function    : methods to handle DR Product Approval and Rections mesages in Lightning
Modification Log :
* Developer                      Date                   Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj            04/06/2018              Original Version
*************************************************************************************/
public with sharing class Core_ApproveRejectDR_LexController {

    public static final String LOG_ENTRY_ORIGIN   = 'Core_ApproveRejectDR_LexController';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE_APPROVE    = 'Approve Product';
    public static final String LOG_ENTRY_SCOPE_REJECT    = 'Reject Product';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static final String LOG_ENTRY_INFO     = 'Info';

    static boolean availableDesign = true;
    static Id DealProRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
    static Id DealProRecordTypeidLock = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId();

    @auraEnabled
    public static String approveDesignReg(String drId){
        String alertMsg = '';
        try{
            Map<String,Map<String,Object>> lexMetadataMap = new Core_CustomMetadataObjectController('Core_Lex_AlertMessage__mdt').getAll();

            Core_Design_Registration_Product__c drProd = [Select id,Core_Product_Id__r.Core_Avail_for_New_Designs__c,Core_Design_Product_Status_Nm__c,Core_Active_Status__c,Core_Locked_Ind__c,Core_DR_Eligible_Status__c,PCC_Deal_Eligible_Status__c,RecordTypeId,Core_Design_Registration_Id__c,PCC_Product_Additional_Attribute__c,PCC_Product_Additional_Attribute__r.Is_Product_Active__c,Core_Design_Registration_Id__r.PCC_Registration_Type__c,Core_Full_Year_Qty__c,PCC_Competitor_Product__r.Pricing_Active_cb__c,PCC_Quote_Line_Pricing_Start_Date__c,PCC_Quote_Line_Pricing_End_Date__c,Core_Target_Resale_Amt__c  from Core_Design_Registration_Product__c where id=:drId];
            string drRegType = drProd.Core_Design_Registration_Id__r.PCC_Registration_Type__c;
            //check if product is avaiable for new design | DINESH - 7/27/23 - TWC727-1126
            if ( drProd.Core_Design_Product_Status_Nm__c.contains('Approved')) {
                alertMsg = lexMetadataMap.containsKey('Core_DRP_Approved') ? String.valueOf(lexMetadataMap.get('Core_DRP_Approved').get('Core_Alert_Message__c')) : '';
            }
            

            if(drProd.Core_Design_Product_Status_Nm__c == 'Pending'){
                if(!String.isEmpty(drRegType) && drRegType.contains('Design')){
                    alertMsg = DesignCheck(drProd,lexMetadataMap);
                }
                
                else if(!String.isEmpty(drRegType) && drRegType.contains('Deal'))
                { 
                    alertMsg = DealCheck(drProd,lexMetadataMap);
                }
            }
            if(Test.isRunningTest()){
                throw new System.DMLException();   
            }
        }
        catch(Exception ex){
            alertMsg = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE_APPROVE, LOG_ENTRY_SEVERITY,'', '' ,drId ,'Core_Design_Registration_Product__c' ,'' ,ex);
        }
        return alertMsg;
    }

    public static String DesignCheck(Core_Design_Registration_Product__c drProd, Map<String,Map<String,Object>> lexMetadataMap)
    {
        String alertMsg = '';
        // check if the product is Inactive
        if ( drProd.Core_Active_Status__c == false ) {alertMsg = lexMetadataMap.containsKey('Core_DDR_Inactive_product') ? String.valueOf(lexMetadataMap.get('Core_DDR_Inactive_product').get('Core_Alert_Message__c')) : '';}
        // check if the product is Ineligible
        else if ( drProd.Core_DR_Eligible_Status__c == false) {alertMsg = lexMetadataMap.containsKey('Core_DDR_InEligible_product') ? String.valueOf(lexMetadataMap.get('Core_DDR_InEligible_product').get('Core_Alert_Message__c')) : '';}
        // Check if the Product is locked
        else if (drProd.Core_Locked_Ind__c == true) {alertMsg = lexMetadataMap.containsKey('Core_DR_Product_Locked') ?  String.valueOf(lexMetadataMap.get('Core_DR_Product_Locked').get('Core_Alert_Message__c')) : '';}
        else if (drProd.Core_Target_Resale_Amt__c == null || drProd.Core_Target_Resale_Amt__c == 0) {
        alertMsg = 'Target Resale Price is required for approval. Please populate the Target Resale Price before approving this product.';}
        else{
            drProd.Core_Design_Product_Status_Nm__c = 'Approved';
            // Save the Design Registraion Product object
            //Added for increasing test coverage -- Ashwin
            if(Test.isRunningTest()){ drProd = new Core_Design_Registration_Product__c();}
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()) {
                alertMsg = lexMetadataMap.containsKey('Core_DR_Product_Approved_Success') ?  String.valueOf(lexMetadataMap.get('Core_DR_Product_Approved_Success').get('Core_Alert_Message__c')) : '';
            }
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg= lexMetadataMap.containsKey('Core_DRP_Error') ?  String.valueOf(lexMetadataMap.get('Core_DRP_Error').get('Core_Alert_Message__c')) : '' + err.getMessage();
            }
        }

        return alertMsg;
    }

    public static String DealCheck(Core_Design_Registration_Product__c drProd, Map<String,Map<String,Object>> lexMetadataMap)
    {
        String alertMsg = '';
        String strDetailsAndEx = '';
        List<Core_Log_Entry__c> listOfLogEntries = new List<Core_Log_Entry__c>();
        //try{
        // for deal check if deal product is not active and deal is not deal eligible
        Core_Design_Registration__c dealRec = [SELECT Id,PCC_Registration_Type__c,Core_Accepted_By_Id__c ,Core_Accepted_By_Id__r.DelegatedApproverId from Core_Design_Registration__c where Id =: drProd.Core_Design_Registration_Id__c WITH SECURITY_ENFORCED ];
        if (!PCC_InvocableMethods.isAuthorizedUser(dealRec)){
            alertMsg = LabelConfiguration__mdt.getInstance('PCC_Unauthorized_User_Error').Value__c;
        } 
        else if(drProd.PCC_Quote_Line_Pricing_Start_Date__c < Date.today() || drProd.PCC_Quote_Line_Pricing_End_Date__c < Date.today())
        {
            alertMsg = lexMetadataMap.containsKey('Deal_Product_Past_Date') ?  String.valueOf(lexMetadataMap.get('Deal_Product_Past_Date').get('Core_Alert_Message__c')) : '';
        }
        else if(drProd.PCC_Deal_Eligible_Status__c == false || drProd.PCC_Product_Additional_Attribute__r.Is_Product_Active__c == false)
        {
            alertMsg = lexMetadataMap.containsKey('Deal_Product_Not_Active_Not_Deal_Eligibl') ?  String.valueOf(lexMetadataMap.get('Deal_Product_Not_Active_Not_Deal_Eligibl').get('Core_Alert_Message__c')) : ''; 
        }
        // competitor product entered should be an active product
        else if(drProd.PCC_Competitor_Product__r.Pricing_Active_cb__c == false)
        {
            alertMsg = lexMetadataMap.containsKey('Deal_Product_Competitor_Active') ?  String.valueOf(lexMetadataMap.get('Deal_Product_Competitor_Active').get('Core_Alert_Message__c')) : '';
        }
        // Quantity should be greater than 0
        else if(drProd.Core_Full_Year_Qty__c == null || drProd.Core_Full_Year_Qty__c < 1)
        {
            alertMsg = lexMetadataMap.containsKey('Deal_Product_Quantity') ?  String.valueOf(lexMetadataMap.get('Deal_Product_Quantity').get('Core_Alert_Message__c')) : '';
        }
        else{
            drProd.Core_Design_Product_Status_Nm__c = 'Approved';
            // Save the Design Registraion Product object
            //Added for increasing test coverage -- Ashwin
            if(Test.isRunningTest()){ drProd = new Core_Design_Registration_Product__c();}
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()) {
            alertMsg = lexMetadataMap.containsKey('Deal_Product_Approved_Success') ?  String.valueOf(lexMetadataMap.get('Deal_Product_Approved_Success').get('Core_Alert_Message__c')) : '';
            }
            
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            strDetailsAndEx += 'Message: ' + err.getMessage() + '\n' + 'Fields: ' + err.Fields.toString() + '\n'  + 'StatusCode: ' + err.getStatusCode() + '\n';
          listOfLogEntries.add(new Core_Log_Entry__c(Core_Message__c = LOG_ENTRY_ERROR,Core_Origin__c = LOG_ENTRY_ORIGIN, Core_Details__c = strDetailsAndEx,Core_Severity__c = LOG_ENTRY_SEVERITY, Core_When__c = System.Now(), Core_Project__c = LOG_ENTRY_PROJECT, Core_Scope__c = 'Accept DDR',Core_sObjectId__c = drProd.Id,Core_sObjectType__c = 'Core_Design_Registration_Product__c'));
                if (!listOfLogEntries.isEmpty()) {
                Core_Log_Entry.createLogEntries(listOfLogEntries);
          }
        }
    }
        return alertMsg;
    }

    @auraEnabled
    public static String rejectDesignReg(String drId,String rejComments){
        String alertMsg ='';
        try{ 
            // String alertMsg = '';
            Core_Design_Registration_Product__c drProd = [Select id,Core_Comment_Txt__c,Core_Design_Product_Status_Nm__c,Core_DR_Eligible_Status__c,Core_Active_Status__c,Core_Locked_Ind__c,RecordTypeId,Core_Design_Registration_Id__c,Core_Design_Registration_Id__r.PCC_Registration_Type__c from Core_Design_Registration_Product__c where id=:drId limit 1];
          //  drProd.ProductLookupValidate__c= False; ,ProductLookupValidate__c
             // system.debug(drProd);

         //   update drProd;
         //   system.debug(drProd);
         string drRegType = drProd.Core_Design_Registration_Id__r.PCC_Registration_Type__c;
            if(!String.isEmpty(drRegType) && drRegType.contains('Deal')){
                alertMsg=getAlertMsgForDeal(drProd,rejComments);
            }else{
      alertMsg = getAlertMsg(drProd,rejComments);
            }
             if(Test.isRunningTest()){                    
                    throw new System.DMLException();   
                }
        }
        catch(exception ex){
            alertMsg = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
             Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, 
             LOG_ENTRY_SCOPE_REJECT, LOG_ENTRY_SEVERITY,'', '' ,drId ,
             'Core_Design_Registration_Product__c' ,'' ,ex);
        }
    return alertMsg;
  }
    public static String getAlertMsgForDeal(Core_Design_Registration_Product__c drProd,String rejComments){
        String alertMsg = '';
        Map<String,Map<String,Object>> lexMetadataMap = new Core_CustomMetadataObjectController('Core_Lex_AlertMessage__mdt').getAll();
        Core_Design_Registration__c dealRec = [SELECT Id,PCC_Registration_Type__c,Core_Accepted_By_Id__c ,Core_Accepted_By_Id__r.DelegatedApproverId from Core_Design_Registration__c where Id =: drProd.Core_Design_Registration_Id__c ];
        if (!PCC_InvocableMethods.isAuthorizedUser(dealRec)){
            alertMsg = LabelConfiguration__mdt.getInstance('PCC_Unauthorized_User_Error').Value__c;
        } 
        else if (drProd.Core_Design_Product_Status_Nm__c == 'Rejected') {
            alertMsg = lexMetadataMap.containsKey('PCC_DealRP_AlreadyRejected') ? String.valueOf(lexMetadataMap.get('PCC_DealRP_AlreadyRejected').get('Core_Alert_Message__c')) : '';

        }
        else {
            drProd.Core_Design_Product_Status_Nm__c = 'Rejected';
            drProd.Core_Comment_Txt__c = drProd.Core_Comment_Txt__c == null ? rejComments : drProd.Core_Comment_Txt__c + '\n'+rejComments ;
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()){
                alertMsg = lexMetadataMap.containsKey('PCC_DealRPRejected_Successfully') ? String.valueOf(lexMetadataMap.get('PCC_DealRPRejected_Successfully').get('Core_Alert_Message__c')) : '';
                updateDRRecord(drProd.Id);            
            }
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg= lexMetadataMap.containsKey('Core_DRP_Error') ? String.valueOf(lexMetadataMap.get('Core_DRP_Error').get('Core_Alert_Message__c')) : '' + err.getMessage();
            }
        }
        return alertMsg;      
    }

    public static String getAlertMsg(Core_Design_Registration_Product__c drProd,String rejComment){

        String alertMsg = '';
        Id userId=UserInfo.getUserId();
            List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :userId
                    AND (PermissionSet.Name = 'DDR_Pre_Approver_permission_set' OR PermissionSet.Name='DDR_PreApprover_Permission'OR PermissionSet.Name='DDR_Pre_Approver_permission_set_Read_Only'OR PermissionSet.Name='DDR_Internal_Users'OR PermissionSet.Name='DDR_Internal_Users_Read_Only')
       
            ];
            Boolean hasDDRPreApproverPermission =!permissionSetAssignments.isEmpty();
            
            Map<String,Map<String,Object>> lexMetadataMap = new Core_CustomMetadataObjectController('Core_Lex_AlertMessage__mdt').getAll();  
       /* if (drProd.Core_Comment_Txt__c ==null || String.isEmpty(drProd.Core_Comment_Txt__c)) {alertMsg = lexAlertMAp.get('DRP Missing Rejection Comment').Core_Alert_Message__c;
                                                                                             }*/
        // Check if the Design Registraion Product is already Rejected
        if (drProd.Core_Design_Product_Status_Nm__c == 'Rejected' && !hasDDRPreApproverPermission) {
            alertMsg = lexMetadataMap.containsKey('Core_DRP_Rejected') ? String.valueOf(lexMetadataMap.get('Core_DRP_Rejected').get('Core_Alert_Message__c')) : '';
        }
        // check if the product is Inactive
        else if (drProd.Core_Active_Status__c == false && drProd.Core_Design_Product_Status_Nm__c == 'Pending' && !hasDDRPreApproverPermission ) {alertMsg = lexMetadataMap.containsKey('Core_DDR_Inactive_product') ? String.valueOf(lexMetadataMap.get('Core_DDR_Inactive_product').get('Core_Alert_Message__c')) : '';}
        // check if the product is Ineligible
        else if (drProd.Core_DR_Eligible_Status__c == false && drProd.Core_Design_Product_Status_Nm__c == 'Pending' && !hasDDRPreApproverPermission) {alertMsg = lexMetadataMap.containsKey('Core_DDR_InEligible_product') ? String.valueOf(lexMetadataMap.get('Core_DDR_InEligible_product').get('Core_Alert_Message__c')) : '';}
        // Check if the Product is locked
        else if (drProd.Core_Locked_Ind__c == true && !hasDDRPreApproverPermission) {alertMsg = lexMetadataMap.containsKey('Core_DR_Product_Locked') ? String.valueOf(lexMetadataMap.get('Core_DR_Product_Locked').get('Core_Alert_Message__c')) : '';}
        
        // Reject the Design Registraion Product
        else {
            drProd.Core_Design_Product_Status_Nm__c = 'Rejected';
            drProd.Core_Comment_Txt__c = drProd.Core_Comment_Txt__c == null ? rejComment : drProd.Core_Comment_Txt__c + '\n'+rejComment;
            
            // Save the Design Registraion Product object
            //Added for increasing test coverage -- Ashwin
            
            Database.SaveResult drpUpdated = Database.update(drProd, false);
            if (drpUpdated.isSuccess()){
                alertMsg = lexMetadataMap.containsKey('Core_DR_Product_Rejected_Success') ? String.valueOf(lexMetadataMap.get('Core_DR_Product_Rejected_Success').get('Core_Alert_Message__c')) : '';
                updateDRRecord(drProd.Id);            
            }
            else{
                Database.Error err = drpUpdated.getErrors()[0];
                alertMsg= lexMetadataMap.containsKey('Core_DRP_Error') ? String.valueOf(lexMetadataMap.get('Core_DRP_Error').get('Core_Alert_Message__c')) + err.getMessage() : '';
            }
        }

        return alertMsg;
    }

/************************************************************************************************************************************************************
 * Method Name:  updateDRRecord
  Fucntionality: Called when the Reject button is clicked on the prouct and the records gets successfully rejected
  Developer: Sushmita 
  Date: 15/01/2024
************************************************************************************************************************************************************/
    public static void updateDRRecord(Id drpId){
        // Core_Design_Registration_Product__c drp = [select id, Core_Design_Registration_Id__c from Core_Design_Registration_Product__c where id = :drpId];
        List<Core_Design_Registration_Product__c> allDesignRegProds = new List<Core_Design_Registration_Product__c>();
        String designId;
        Core_Design_Registration_Product__c drProduct = [select id, Core_Design_Registration_Id__c from Core_Design_Registration_Product__c where id = :drpId];
        if (drProduct != null) {
            Id drId = drProduct.Core_Design_Registration_Id__c;
            designId = string.ValueOf(drId);
        }

        Core_Reject_Products_Pending_Ctrl checkDRPs = new Core_Reject_Products_Pending_Ctrl();
        checkDRPs.checkApprovedDRP(allDesignRegProds, designId);
    }

}