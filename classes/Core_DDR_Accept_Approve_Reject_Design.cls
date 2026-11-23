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
        return [select Id, OwnerId,Core_Vertical_Market_Nm__c,Core_Intel_Platform_Nm__c,Core_End_Customer_Account_Id__r.RecordType.Name,Core_Product_Segment_Nm__c,Core_Product_Application_Nm__c, RecordTypeId,Core_Rejection_Reason_Nm__c,Core_End_Customer_Account_Owner__c,Core_Pending_Product_Cnt__c,Core_Approved_Product_Cnt__c, Core_Opportunity_Id__c, Core_Accepted_By_Id__c,Core_End_Customer_Account_Id__c,Core_Partner_Account_Id__c,Core_Is_End_Customer_Account_Covered_Ind__c,Core_Is_End_Customer_Account_Blocked_Ind__c,Core_End_Customer_Sales_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Core_Intel_Technical_Owner_Id__c,Core_Rejection_Comment_Txt__c from Core_Design_Registration__c where Id =: designRegId];               
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
* Method name  : ValidateInactiveLOVS
* Description  : This Method is will Gives if any Inactive Lov exists in VM,IP,PS and PA fields. 
* Parameter    : (Core_Design_Registration__c designRegis);
*/
    public static String ValidateInactiveLOVS(Core_Design_Registration__c designReg ){
        List<SelectOption> options =  new List<SelectOption>();    
         List<String> VerticalMarketLovs =  new List<String>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult fieldResult = Core_Design_Registration__c.Core_Vertical_Market_Nm__c.getDescribe();    
        List<Schema.picklistEntry> ple = fieldResult.getPicklistValues();    
        for(Schema.picklistEntry f:ple)    
        {    
            VerticalMarketLovs.add(f.getValue());
        }    
        //Intel Platform Lovs
        
        List<String> IntelPlatformLovs =  new List<String>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult IntelPlatformfieldResult = Core_Design_Registration__c.Core_Intel_Platform_Nm__c.getDescribe();    
        List<Schema.picklistEntry> IntelPltform = IntelPlatformfieldResult.getPicklistValues();    
        for(Schema.picklistEntry f:IntelPltform)    
        {    
            IntelPlatformLovs.add(f.getValue());
        }  
        //Product Segmeent Lovs
         List<String> ProdSegLOvs =  new List<String>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult ProdSegfieldResult = Core_Design_Registration__c.Core_Product_Segment_Nm__c.getDescribe();    
        List<Schema.picklistEntry> ProdSeg = ProdSegfieldResult.getPicklistValues();    
        for(Schema.picklistEntry f:ProdSeg)    
        {    
            ProdSegLOvs.add(f.getValue());
        }  
        
        //Product Application
         List<String> ProdAppLOvs =  new List<String>();    
        options.add(new selectOption('None','--- None ---'));    
        Schema.DescribeFieldResult ProdAppfieldResult = Core_Design_Registration__c.Core_Product_Application_Nm__c.getDescribe();    
        List<Schema.picklistEntry> ProdApp = ProdAppfieldResult.getPicklistValues();    
        for(Schema.picklistEntry f:ProdApp)    
        {    
            ProdAppLOvs.add(f.getValue());
        }  
        String InactiveLovs='';
        //Core_Design_Registration__c designReg=getDDRsoqlquery(DDRrecordId);
		if(designReg.Core_Vertical_Market_Nm__c != null){
         if(!VerticalMarketLovs.contains(designReg.Core_Vertical_Market_Nm__c)){
         
            InactiveLovs='Vertical Market';
         }
		}
	    if(designReg.Core_Intel_Platform_Nm__c != null){
        if(!IntelPlatformLovs.contains(designReg.Core_Intel_Platform_Nm__c)) {
            if(InactiveLovs !=''){
            InactiveLovs=InactiveLovs+'&'+'Intel Platform';
            }else{
                InactiveLovs='Intel Platform';
            }
         }
	    }
		if(designReg.Core_Product_Segment_Nm__c != null){
        if(!ProdSegLOvs.contains(designReg.Core_Product_Segment_Nm__c)){
             if(InactiveLovs !=''){
            InactiveLovs=InactiveLovs+'&'+'Product Segment';
             }else{
                 InactiveLovs='Product Segment';
             }
        }
		}
		if(designReg.Core_Product_Application_Nm__c != null){
        if(!ProdAppLOvs.contains(designReg.Core_Product_Application_Nm__c)){
            if(InactiveLovs !=''){
            InactiveLovs=InactiveLovs+'&'+'Product Application';
            }else{
                 InactiveLovs='Product Application';
            }
        }
		}
       
        return InactiveLovs;
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
        String InactiveLovFields=ValidateInactiveLOVS(designReg);
        system.debug('InactiveLovList*******'+InactiveLovFields);
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
          }else if(InactiveLovFields !=''){
              alertMessage='Current selected values of the following fields'+'"'+InactiveLovFields+'"'+'on this record are inactive. Please select a valid value and retry submission ';
          }
       else if(designReg.Core_End_Customer_Account_Id__r.RecordType.Name=='Inactive Account' 
                  || designReg.Core_End_Customer_Account_Id__r.RecordType.Name=='CoMarketing' ){
            alertMessage='Current selected value of the field'+'"'+ 'End Customer Account'+'"'+' on this record is not a valid value anymore. Please select a valid value and retry submission ';
          
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