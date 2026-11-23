/**************************************************************************************************
Apex Class Name:  Core_DDR_Accept_Approve_Reject_Design 
Version     : 1.0 
Created Date: 16 AUG 2018
Function    :This class is being used for DDR Accept,Approve and Reject Design Detail page buttons. 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------   
Rajesh kumar                 18/06/2018             Original Version
Sougata Sarkar				 29/8/2018				Updated Version
*****************************************************************************************************/
public class Core_DDR_Accept_Approve_Reject_Design {
    
    public static Core_Design_Registration__c getDDRsoqlquery(String designRegId){
        return [select Id, OwnerId, RecordTypeId,Core_Rejection_Reason_Nm__c,Core_End_Customer_Account_Owner__c,Core_Pending_Product_Cnt__c,Core_Approved_Product_Cnt__c, Core_Opportunity_Id__c, Core_Accepted_By_Id__c,Core_End_Customer_Account_Id__c,Core_Partner_Account_Id__c,Core_Is_End_Customer_Account_Covered_Ind__c,Core_Is_End_Customer_Account_Blocked_Ind__c,Core_End_Customer_Sales_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Core_Intel_Technical_Owner_Id__c,Core_Rejection_Comment_Txt__c from Core_Design_Registration__c where Id =: designRegId];               
    }
    
    @auraEnabled
    public static String updateAcceptDesign(String designId){
        String alertMsg = '';
        Core_Design_Registration__c updateDesign = getDDRsoqlquery(designId);
        if(updateDesign.Core_Accepted_By_Id__c <> null){
            alertMsg = 'Design Registration is already been accepted.';
        }else{
            updateDesign.Core_Accepted_By_Id__c = UserInfo.getUserId();
            alertMsg = 'You have successfully accepted the Design.';
            try{
                update updateDesign;
            }catch(Exception e){alertMsg = e.getStackTraceString();}
        }
        return alertMsg;
    }
    
    
    @auraEnabled
    public static picklistMsgWrapper getPicklistValues(String designRegisId, String objectType, String fieldName){
        picklistMsgWrapper picklistWrap = new picklistMsgWrapper();
        Core_Design_Registration__c designRegisUpdate = getDDRsoqlquery(designRegisId);
        
        if(designRegisUpdate.Core_Design_Registration_Status_Nm__c.equalsIgnoreCase('Rejected')){
            picklistWrap.pickListValueList = null;
            picklistWrap.message = 'Design Registration is already Rejected.';
        }else if(designRegisUpdate.Core_Pending_Product_Cnt__c > 0){
            picklistWrap.pickListValueList = null;
            picklistWrap.message = 'There are some Pending Products. Please disposition all of them before Rejecting the Design Registration.';
        }else if(designRegisUpdate.Core_Approved_Product_Cnt__c > 0){
            picklistWrap.pickListValueList = null;
            picklistWrap.message = 'There are some Approved Products. Please Reject all of them before Rejecting the Design Registration.';
        }else if(designRegisUpdate.Core_Opportunity_Id__c <> null){
            picklistWrap.pickListValueList = null;
            picklistWrap.message = 'Rejection is not allowed. The Design Registration was approved in the past.';
        }else{
            picklistWrap.pickListValueList = Core_AcceptReject_Lead_LexController.fetchPicklistValuesByRecType(objectType, fieldName, designRegisUpdate.RecordTypeId);
            picklistWrap.message = 'success';
        }
        picklistWrap.designRegisObj = designRegisUpdate;
        return picklistWrap;
    }
    
    /*
* Method name  : updateDesignRegistration
* Description  : This Method is used to save the design registration once rejection reason and comments have been added. 
* Parameter    : (Core_Design_Registration__c designRegis);
*/
    @auraEnabled
    public static void updateDesignRegistration(Core_Design_Registration__c designRegis){
        Core_Design_Registration__c updateDesign = new Core_Design_Registration__c();
        updateDesign.Id = designRegis.Id;
        updateDesign.Core_Design_Registration_Status_Nm__c = 'Rejected';
        updateDesign.Core_Rejection_Reason_Nm__c = designRegis.Core_Rejection_Reason_Nm__c;
        updateDesign.Core_Rejection_Comment_Txt__c = designRegis.Core_Rejection_Comment_Txt__c;
        update updateDesign;
    }
    
    /*
* Method name  : ApproveDesign
* Description  : This Method used check to complete functionality of Approve Design button link on DDR detail page added by Rajesh. 
* Parameter    : (String DDRrecordId);
*/
    @auraEnabled
    public static String ApproveDesign(String DDRrecordId){
        String alertMessage='';
        Core_Design_Registration__c designReg=getDDRsoqlquery(DDRrecordId);
        system.debug('designReg==========>'+designReg);
        system.debug('Partner Account====>'+designReg.Core_Partner_Account_Id__c);
        List<Core_Design_Registration_Product__c> DDRInactiveProducts= new  List<Core_Design_Registration_Product__c>();
        DDRInactiveProducts=[SELECT Id FROM Core_Design_Registration_Product__c WHERE Core_Design_Registration_Id__c=:DDRrecordId AND Core_Active_Status__c = false];
        // Check if the Design is already Approved //
        if(designReg.Core_Design_Registration_Status_Nm__c=='Approved'){
            alertMessage='Design Registration is already Approved.';
        // Check if there are any Pending Products 
        }else if(designReg.Core_Pending_Product_Cnt__c > 0){       
            alertMessage='There are some Pending Products. Please disposition all of them before Approving the Design Registration.'; 
        // Check if there are any Approved Products
        }else if(designReg.Core_Approved_Product_Cnt__c == 0){
            alertMessage = 'There are NO Approved Products.';
        // Check for Ownership 
        }else if(designReg.Core_Partner_Account_Id__c == null){  
            alertMessage='Please change the Owner to Partner User.';
        // Check for End Customer Account 
        }else if(designReg.Core_End_Customer_Account_Id__c == null){
            alertMessage='Please provide End Customer Account.'; 
       
        }
        // Check if End Customer Account is Blocked 
        else if (designReg.Core_Is_End_Customer_Account_Blocked_Ind__c == true){
            alertMessage='Please provide End Customer Account that is NOT Export Compliance Blocked.'; 
        // Check if End Customer Account has a Sales Group 
        }else if(designReg.Core_End_Customer_Sales_Group_Nm__c == '' || designReg.Core_End_Customer_Sales_Group_Nm__c ==null || designReg.Core_End_Customer_Sales_Group_Nm__c =='Undefined' ){  
            alertMessage='The Sales Group of the account associated with this Design Registration record, is either blank of Undefined. Please change the sales Group or change the account to proceed.'; 
        
        // check if the end customer account owner is uncovered or A&E User
        }else if(designReg.Core_End_Customer_Account_Owner__c=='A&E Account Owner' || designReg.Core_End_Customer_Account_Owner__c=='Uncovered Account'){
             alertMessage='The Account Owner of the account associated with this Design Registration record, is Uncovered or A&E User. Please change the account owner or change the account to proceed.';
         // Check if any product is became Inactive   
        }else if(DDRInactiveProducts.size() > 0){
            alertMessage='There are Inactive Products added on this Design Registration, please remove the inactive products to proceed with Approval.'; 
        }
        // Check if End Customer Account is Covered 
          else if (designReg.Core_Is_End_Customer_Account_Covered_Ind__c== false){
            alertMessage='Please provide End Customer Account that is Covered.';
        }
        else { 
            try{
                designReg.Core_Design_Registration_Status_Nm__c = 'Approved'; 
                designReg.Core_Rejection_Reason_Nm__c = null; 
                designReg.Core_Rejection_Comment_Txt__c = null; 
                designReg.Core_Intel_Technical_Owner_Id__c =UserInfo.getUserId();
                update designReg;
                alertMessage='Design Registration Approved successfully.';
            }
            catch(Exception ex){ alertMessage=ex.getMessage();}
               
            
        }
        return alertMessage; 
    }
    
    public class picklistMsgWrapper{
        @auraEnabled
        public Core_Design_Registration__c designRegisObj{get;set;}
        @auraEnabled
        public List<String> pickListValueList{get;set;}
        @auraEnabled
        public String message{get;set;}
    }
}