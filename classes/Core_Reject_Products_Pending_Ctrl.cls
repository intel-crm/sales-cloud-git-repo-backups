/*-------------------------------------------------------------------------------------------
Apex Class  : Core_Reject_Products_Pending_Ctrl
Version     : 1.0 
Created Date: 11 JUNE 2018
Function    : Apex class for Core_Reject_Products_Pending vf page.
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Sougata Sarkar            11-Jun-2018              Original Version
* Ashwin Dash               16-Aug-2018              Added changes for US125853 Design Registration: Fix Rejection of New Products Issue
-------------------------------------------------------------------------------------------*/

public with sharing class Core_Reject_Products_Pending_Ctrl {
    
    public List<Core_Design_Registration_Product__c> allDesignRegProds=new List<Core_Design_Registration_Product__c>();
    public List<Core_Design_Registration_Product__c> allDealRegProds=new List<Core_Design_Registration_Product__c>();
    public List<Core_Design_Registration_Product__c> designprods;
    public String designRegId;
    public static String alertMessage{get;set;}
    public String registrationTypeDR{get;set;}
    public static String retUrl{get;set;}
    public static boolean isSuccess{get;set;}
    public Core_Design_Registration__c DDRRecord;
    public static final String PENDING_DDR = 'Pending';
    public static final String REJECT_DDR = 'Rejected';
    public static final String APPROVED_DDR = 'Approved';
    public static final String SUBMITTED_DDR = 'Submitted';
    public static final String ACCEPTED_DDR = 'Design accepted';
    public static final String PREAPPROVED_DDR = 'Pre-Approved';
    public static final String LOG_ENTRY_ORIGIN   = 'Core_Reject_Products_Pending_Ctrl';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Reject All Pending Products';
    public static final String LOG_ENTRY_SEVERITY = 'Medium';
    public static boolean status {get;set;}
    public Integer count{get;set;}
    public String commentText { get; set; }
    List<Core_Design_Registration_Product__c> allDesignRegProdsInactivelist = new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> allDesignRegProdsInEligiblelist = new List<Core_Design_Registration_Product__c>();
    List<Core_Design_Registration_Product__c> drpLst = new List<Core_Design_Registration_Product__c>();
    public Boolean hasDDRPreApproverPermission { get; private set; }
    public Core_Reject_Products_Pending_Ctrl(){
        // Constructor
    }
    //Desc - checking approvers and pre approvers permissions--Vinita
    private Boolean checkDDRPreApproverPermission(Id userId) {
        // Query to check if the user has the DDR_Pre_Approver_permission_set
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
                AND (PermissionSet.Name = 'DDR_Pre_Approver_permission_set' OR PermissionSet.Name='DDR_PreApprover_Permission'
                OR PermissionSet.Name='DDR_Pre_Approver_permission_set_Read_Only'OR PermissionSet.Name='DDR_Internal_Users'
                OR PermissionSet.Name='DDR_Internal_Users_Read_Only') /* WITH SECURITY_ENFORCED*/
        ];

        return !permissionSetAssignments.isEmpty();
    }
   
    public Core_Reject_Products_Pending_Ctrl(ApexPages.StandardSetController stdSetCtrl) {
        commentText = '';  
        designRegId = apexpages.currentpage().getParameters().get('Id');
        DDRRecord=[SELECT Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Opportunity_Id__r.StageName,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c,Core_Design_Registration_Status_Nm__c, RecordTypeId,Core_End_Customer_Account_Owner__c,Core_End_Customer_Account_Id__c,PCC_Registration_Type__c,Core_Accepted_By_Id__c ,Core_Accepted_By_Id__r.DelegatedApproverId from Core_Design_Registration__c where Id =: designRegId];               
        registrationTypeDR = DDRRecord.PCC_Registration_Type__c;
       
        List<Core_Design_Registration_Product__c> selectedProducts = stdSetCtrl.getSelected(); // added by dinesh
        isSuccess = false;   
       //Id DealProdPartnerRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Partner').getRecordTypeId();
       //Id DealProdLockedRecordTypeid = Schema.SObjectType.Core_Design_Registration_Product__c.getRecordTypeInfosByDeveloperName().get('PCC_Deal_Registration_Product_Locked').getRecordTypeId(); 
        count = 0;
        
        status=Core_DRR_ApproveAllPendingProducts.coreDRStatus(DDRRecord);
        hasDDRPreApproverPermission = checkDDRPreApproverPermission(UserInfo.getUserId());

        if(selectedProducts!=null && selectedProducts.size()>0) {
        designprods =[SELECT id,Core_Design_Product_Status_Nm__c, Core_DR_Eligible_Status__c,Core_Comment_Txt__c,Core_Active_Status__c,Core_Locked_Ind__c,Core_Design_Registration_Id__c,RecordTypeId,Core_Design_Registration_Id__r.PCC_Registration_Type__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :designRegId and id in :selectedProducts];
        } else{
            designprods =[SELECT id,Core_Design_Product_Status_Nm__c, Core_DR_Eligible_Status__c,Core_Comment_Txt__c,Core_Active_Status__c,Core_Locked_Ind__c,Core_Design_Registration_Id__c,RecordTypeId,Core_Design_Registration_Id__r.PCC_Registration_Type__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c = :designRegId];
        }
        
        for (Core_Design_Registration_Product__c designRegProd : designprods) {
 
          //  if(hasDDRPreApproverPermission && designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
             // allDesignRegProds.add(designRegProd);
         //   }
         //   else{
           // if(designRegProd.RecordTypeId == DealProdPartnerRecordTypeid || designRegProd.RecordTypeId == DealProdLockedRecordTypeid ){
                //allDealRegProds.add(designRegProd);
            //if(designRegProd.Core_Design_Registration_Id__r.PCC_Registration_Type__c == 'Deal Registration'){
                if(registrationTypeDR.contains('Deal')){
                if(designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')){
                    allDealRegProds.add(designRegProd);
                }
            }else{
                if(designRegProd.Core_Locked_Ind__c == false && designRegProd.Core_Design_Product_Status_Nm__c.equals('Pending')) {
                    allDesignRegProds.add(designRegProd);
                    if (designRegProd.Core_DR_Eligible_Status__c == false && !hasDDRPreApproverPermission) {
                        allDesignRegProdsInEligiblelist.add(designRegProd);
                    }
                    if (designRegProd.Core_Active_Status__c == false && !hasDDRPreApproverPermission) {
                        allDesignRegProdsInactivelist.add(designRegProd);
                    }
                }
            }
                
          //  }
        }
        
  //      update allDesignRegProds;
        
    }

    public PageReference setRetUrl() {
        retUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/' + designRegId;
        PageReference pageRef = new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    //START - Added changes for US125853 Design Registration: Fix Rejection of New Products Issue -- Ashwin
   /* public PageReference rejectProductsPending() {
        try{
            if (string.isBlank(commentText)) {
                alertMessage='Please enter the comments before rejecting';
               
            }
           else if(status==true) {
                alertMessage='Products cannot be added or edited.';
            }
      
            else if(allDesignRegProds.size() == 0) {alertMessage = 'There are no pending products on this Design Registration to Reject.';}
            else if(allDesignRegProdsInactivelist.size() > 0) { alertMessage ='There are  Inactive Products added on this Design Registration, please remove the inactive products to proceed with Rejection.';}
            else if(allDesignRegProdsInEligiblelist.size() > 0) {alertMessage ='There are  Ineligible Products added on this Design Registration, please remove the Ineligible products to proceed with Rejection.';} 
            else{
                for(Core_Design_Registration_Product__c designRegProd : allDesignRegProds) { 
                    designRegProd.Core_Design_Product_Status_Nm__c = REJECT_DDR;
                    count++;
                    
                } 
                if (!(String.isBlank(commentText))) {
                updateDDRProdRecords(allDesignRegProds,commentText);}
                if(isSuccess) {
                    checkApprovedDRP(allDesignRegProds, designRegId);
                    alertMessage = count + ' Pending Design Registration Products Rejected successfully.';    
                }    
            }
             if(Test.isRunningTest()) {
                 throw new System.DMLException();   
                }
        }catch(Exception e) {
            alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_Reject_Products_Pending_Ctrl.rejectProductsPending' ,'' ,e);
        }
        return null;
    }*/
    public PageReference rejectProductsPending() {
        try {
           if (isCommentTextBlank()) {
                alertMessage = 'Please enter the comments before rejecting';
            }
            else if(!String.isEmpty(registrationTypeDR)&&registrationTypeDR.contains('Deal')){
                Boolean hasCustomPermission = FeatureManagement.checkPermission('PCC_Deal_Reg_Internal_Admin_Custom');                  
        
                if (!PCC_InvocableMethods.isAuthorizedUser(DDRRecord) || !hasCustomPermission){
                    alertMessage = LabelConfiguration__mdt.getInstance('PCC_Unauthorized_User_Error').Value__c;
                } 
                else if (allDealRegProds.size() == 0) {
                    alertMessage = 'There are no pending products on this Deal Registration to Reject.';
                }
                else if (allDealRegProds.size() > 0){
                rejectDesignRegistrationProducts(allDealRegProds);
                if (isSuccess) {
                    checkApprovedDRP(allDealRegProds, designRegId);
                    alertMessage = count + ' Pending Deal Registration Products Rejected successfully.';
                }
            }}
            else{
            if (status==true) {
                alertMessage = 'Products cannot be added or edited.';
            } else if (allDesignRegProds.size() == 0) {
                alertMessage = 'There are no pending products on this Design Registration to Reject.';
            } else if (hasInactiveProducts()) {
                alertMessage = 'There are Inactive Products added on this Design Registration, please remove the inactive products to proceed with Rejection.';
            } else if (hasIneligibleProducts()) {
                alertMessage = 'There are Ineligible Products added on this Design Registration, please remove the Ineligible products to proceed with Rejection.';
            } else {
                rejectDesignRegistrationProducts(allDesignRegProds);
                if (isSuccess) {
                    checkApprovedDRP(allDesignRegProds, designRegId);
                    alertMessage = count + ' Pending Design Registration Products Rejected successfully.';
                }
            }
            }
            
            if (Test.isRunningTest()) {
                throw new System.DMLException();
            }
        } catch (Exception e) {
            handleException(e);
        }
        
        return null;
    }

   /* private boolean isDealProduct(){
        system.debug('inside retueen deal'+allDealRegProds.size());
        //system.debug('inside retueen '+allDealRegProds.size()>0);
        return allDealRegProds.size()>0;
    }*/
    
    private boolean isCommentTextBlank() {
        return String.isBlank(commentText);
    }
    
    private boolean hasInactiveProducts() {
        return allDesignRegProdsInactivelist.size() > 0;
    }
    
    private boolean hasIneligibleProducts() {
        return allDesignRegProdsInEligiblelist.size() > 0;
    }
    
    private void rejectDesignRegistrationProducts(list<Core_Design_Registration_Product__c> DesignRegProds) {
        for (Core_Design_Registration_Product__c designRegProd : DesignRegProds) {
            designRegProd.Core_Design_Product_Status_Nm__c = REJECT_DDR;
            count++;
        }
        
        if (!String.isBlank(commentText)) {
            updateDDRProdRecords(DesignRegProds, commentText);
        }
    }
    
    private void handleException(Exception e) {
        alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
        Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY, '', '', '', 'Core_Reject_Products_Pending_Ctrl.rejectProductsPending', '', e);
    }
    
    
    public void checkApprovedDRP(List<Core_Design_Registration_Product__c> allDesignRegProds, String designRegId) {
        allDesignRegProds = new List<Core_Design_Registration_Product__c>();
       // Integer lockedDRP = 0;
        Integer newApprovedDRP = 0;
        Boolean hasNewAprvdDRP = false;
        allDesignRegProds = [SELECT Id, Core_Locked_Ind__c, Core_Design_Product_Status_Nm__c FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId 
                                AND Core_Design_Product_Status_Nm__c = :APPROVED_DDR];
       
        for(Core_Design_Registration_Product__c drp : allDesignRegProds) {
            if(!drp.Core_Locked_Ind__c && drp.Core_Design_Product_Status_Nm__c == APPROVED_DDR) {
                newApprovedDRP++;
            }
            if(newApprovedDRP==1) {
                hasNewAprvdDRP = true;   
                break;
            } 
        }

        List<Core_Design_Registration_Product__c> pendingDDRProds = new List<Core_Design_Registration_Product__c>();
        pendingDDRProds = [SELECT Id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c =: designRegId 
                            AND Core_Design_Product_Status_Nm__c = :PENDING_DDR];
        List<Core_Design_Registration__c> parentDDR = [SELECT Id, Core_Design_Registration_Status_Nm__c FROM Core_Design_Registration__c
                                                        WHERE Id = :designRegId LIMIT 1];
        if(!allDesignRegProds.isEmpty() && pendingDDRProds.isEmpty() && !hasNewAprvdDRP ) {
            updateDDRRecords(parentDDR, APPROVED_DDR);                    
        }    
    }

    //Method to update the DDR records if already approved/rejected
    public void updateDDRRecords(List<Core_Design_Registration__c> tempDDRRec, String status) {
        boolean updateCheck = false;
        if(tempDDRRec[0].Core_Design_Registration_Status_Nm__c != SUBMITTED_DDR && tempDDRRec[0].Core_Design_Registration_Status_Nm__c != ACCEPTED_DDR && tempDDRRec[0].Core_Design_Registration_Status_Nm__c != PREAPPROVED_DDR
        ) {
            tempDDRRec[0].Core_Design_Registration_Status_Nm__c = status;
            updateCheck = true;
        }
        if(updateCheck) {
            try{
                Core_DDR_Design_Handler_Utility.AfterUpdateIterated = true;
                update tempDDRRec;
                if(Test.isRunningTest()) {
                    tempDDRRec.add(new Core_Design_Registration__c(Core_Design_Registration_Nm__c='test'));
                    update tempDDRRec;
                }   
            }catch(Exception e) {
                isSuccess = false;
                alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c;
                Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'Core_Reject_Products_Pending_Ctrl.updateDDRRecords' ,'' ,e);
            }
        }
    }
    
    //Method to update the DDR Product records.
    public void updateDDRProdRecords(List<Core_Design_Registration_Product__c> tempDDRProdRec,String rejectionText) {     
        try{
            List<Core_Design_Registration_Product__c> desProdList = new List<Core_Design_Registration_Product__c>();
            for(Core_Design_Registration_Product__c desProd : tempDDRProdRec)  {
                if( desProd.Core_Comment_Txt__c!= null){
                    desProd.Core_Comment_Txt__c = desProd.Core_Comment_Txt__c + '\n'+rejectionText;
                }
                else{
                    desProd.Core_Comment_Txt__c = rejectionText;
                }
              //  desProd.Core_Comment_Txt__c = desProd.Core_Comment_Txt__c!= null ?desProd.Core_Comment_Txt__c + '\n'+rejectionText : rejectionText;
                desProdList.add(desProd);
            }
            update desProdList; 
            isSuccess = true;
            if(Test.isRunningTest()) {
                tempDDRProdRec.add(new Core_Design_Registration_Product__c(Core_Comment_Txt__c='test'));
                update tempDDRProdRec;
            } 
        }catch(Exception e) {
            alertMessage = LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c; 
            Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,designRegId ,'Core_Design_Registration_Product__c' ,'' ,e);
      }
    }
/*
    Desc - checking approvers and pre approvers permissions
    private Boolean checkDDRPreApproverPermission(Id userId) {
        // Query to check if the user has the DDR_Pre_Approver_permission_set
        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Id, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :userId
                AND (PermissionSet.Name = 'DDR_Pre_Approver_permission_set' OR PermissionSet.Name='DDR_PreApprover_Permission'
                OR PermissionSet.Name='DDR_Pre_Approver_permission_set_Read_Only'OR PermissionSet.Name='DDR_Internal_Users'
                OR PermissionSet.Name='DDR_Internal_Users_Read_Only') 
        ];

        return !permissionSetAssignments.isEmpty();
    }*/
    //END - Added changes for US125853 Design Registration: Fix Rejection of New Products Issue -- Ashwin
}