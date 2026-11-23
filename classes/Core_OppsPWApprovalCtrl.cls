/*
**************************************************************************************
Apex Class Name: Core_OppsPWApprovalCtrl
Version        : 1.0 
Created Date   : 21 Feb, 2023
Description    : This Class is used to validate the errors before submitting the opportunity for PW approval.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Pratik Padwal           21 Feb, 2023               Initial Revision
* Pratik Padwal           18 April, 2023             TWC3123-4111 - Added validation for PW Quantity and salesprice.
* Areefa Banu			  26 May, 2023				 Removed CoE_Status__c from query
*/

public without sharing class Core_OppsPWApprovalCtrl { //TWC3123-5759 Added without sharing keyword to fix code scan issue
    /*
    * Method name  : checklistForApproval
    * Description  : validate the errors/warnings before submitting the opportunity for PW approval. 
    * Return Type  : checklistWrapper
    * Parameter    : String oppId,String comments,Boolean isPWApproval
    */     
    @auraEnabled
    public static checklistWrapper checklistForApproval(String oppId,String comments,Boolean isPWApproval){
        //Custom setting to check Sales group
        Opportunity__c accountConsition = Opportunity__c.getOrgDefaults();
        List<String> errMessageList= new List<String>();
        Map<String, List<String>> errMsgMap = new Map<String, List<String>>();
        
        checklistWrapper wrpr = new checklistWrapper();
        try{
            
            boolean hardStop = false;
            boolean softStop = false;
            boolean isPartnLedDesign = false;
            boolean isIntelLedDesign = false;
            boolean userCheckSAM = false;
            OpportunityTeamMember otmObj;
             
            /*Opportunity hard Stops starts */
            Opportunity oppObject = [select id, Core_Opportunity_Coverage_Nm__c, Core_Coverage_Type_Nm__c,Core_Intel_Platform__c, Core_Restrict_Opp_Submission__c, Core_Product_Segment__c, Core_Consumption_Market__c, Core_Product_Application__c, Core_Contact_Roles_Count__c, StageName,  Core_At_Risk__c, Core_Solution_Type__c, Core_Decimal_Check__c, Core_Combined_Solution_Detail__c, Core_Manufacturing_Geo__c, Core_Production_End_Date__c, Description, Core_First_Customer_Ship_Date__c, Core_Commissionable__c, Core_Volume__c, Core_Exclude_From_KPIs__c, CloseDate, Core_Status_Update__c, Account.RecordType.Name, Core_Product_At_Risk_Not_Closed_Count__c,Core_Competitive_Architecture__c, Core_Pending_Product_Count__c, Core_Product_Count__c, Core_Primary_Customer_Contact__c, Core_Technical_Owner__c, OwnerId, CreatedById, RecordType.Name, RecordType.DeveloperName, Core_Write_In_Product_Count__c, Core_Opportunity_Type__c, Core_Compliance_Status__c,Core_Design_Registration_Id__c,Core_Approval_Status__c  from Opportunity where id =: oppId limit 1];//CoE_Status__c,
            //List<OpportunityTeamMember> otmObj1 = [select id, UserId from OpportunityTeamMember where OpportunityId  =: oppId and Core_Production_Win_Member_Role__c='Sales Account Manager' and UserId =: UserInfo.getUserId()];
            for(OpportunityTeamMember otm: [select id, UserId from OpportunityTeamMember where OpportunityId  =: oppId and Core_Production_Win_Member_Role__c='Sales Account Manager' and UserId =: UserInfo.getUserId()]){
                otmObj=otm; 
            }
            if(oppObject != null){ 
                isPartnLedDesign =  oppObject.RecordType.DeveloperName == 'Core_Design_Opportunity' && oppObject.Core_Design_Registration_Id__c != null  && oppObject.Core_Opportunity_Coverage_Nm__c == Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram')? true : false;
                isIntelLedDesign = oppObject.RecordType.DeveloperName == 'Core_Design_Opportunity' && oppObject.Core_Opportunity_Coverage_Nm__c == Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram')? true : false;

                //TWC3123-6322:Validation Msg seperation of PCC Design Opps from rest while submission for Approval
                boolean userCheckforPartDesSub = UserInfo.getUserId() != oppObject.OwnerId && UserInfo.getUserId() != oppObject.CreatedById && UserInfo.getProfileId() != System.Label.Core_IPS_DataOps && UserInfo.getProfileId() != System.Label.Core_System_Admin ;
                boolean userCheckforSub = UserInfo.getUserId() != oppObject.Core_Technical_Owner__c && UserInfo.getUserId() != oppObject.OwnerId && UserInfo.getUserId() != oppObject.CreatedById && UserInfo.getProfileId() != System.Label.Core_IPS_DataOps && UserInfo.getProfileId() != System.Label.Core_System_Admin ;
                if(otmObj != null){ 
                    userCheckSAM = UserInfo.getUserId() == otmObj.UserId ? true : false;
                }
                if(isPartnLedDesign && userCheckforPartDesSub && !userCheckSAM){
                    hardStop = true;
                    String err= Core_CRM_Utility.getCRMLabel('PCC_Design_If_not_Owner_not_SAM');                  
                    if(errMsgMap.containsKey('hardStop')) {   List<String> errList = errMsgMap.get('hardStop'); errList.add(err); errMsgMap.put('hardStop', errList);
                    } else { errMsgMap.put('hardStop', new List<String> { err });     } 
                }
                else if(isIntelLedDesign && userCheckforSub && !userCheckSAM) {  
                    hardStop = true;
                    String err= Core_CRM_Utility.getCRMLabel('Design_OppAppl_Ifnot_Owner/Tech/SAM');                  
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {
                        errMsgMap.put('hardStop', new List<String> { err });
                    } 
                } 
                else if(userCheckforSub && !(isPartnLedDesign || isIntelLedDesign)) { 
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_If_not_Owner;
                    if(errMsgMap.containsKey('hardStop')) {  List<String> errList = errMsgMap.get('hardStop'); errList.add(err);  errMsgMap.put('hardStop', errList);   } 
                    else {   errMsgMap.put('hardStop', new List<String> { err }); }
                }
                if(oppObject.StageName == 'Lost'|| oppObject.StageName == 'Production Lost' || oppObject.StageName == 'Production Cancelled' || oppObject.StageName == 'Cancelled'){
                   
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_Stage;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {
                        errMsgMap.put('hardStop', new List<String> { err });
                    }
                }
                // TWC3123-6461 - Start: User should not be able to submit the design oppty for PW having 0 Win Approved Products.
                if (oppObject.RecordType.DeveloperName == Core_CRM_Utility.getCRMLabel('CRM_Opportunity_Design_RecordType')) { 
                    List<OpportunityLineItem> oliList = [select id, core_status__c from opportunitylineitem where core_status__c = 'Win Approved' and OpportunityId = :oppId];
                    if(oliList.isEmpty()) {
                        hardStop = true;
                        String err= Core_CRM_Utility.getCRMLabel('CRM_ErrorMsg_NoWinApprovedProds');
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop'); 
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                }
                // TWC3123-6461 - End
                
                // TWC3123-5182 - Start: Warning message to PW Submission - when team members with viewer 0% role is added at prod win member role
                Integer ProdWinRoleViewerCount = [select COUNT() from OpportunityTeamMember where OpportunityId = :oppId AND Core_Production_Win_Member_Role__c = 'Viewer (0%)'];
                
                if (oppObject.RecordType.DeveloperName == 'Core_Design_Opportunity' && ProdWinRoleViewerCount > 0) {
                    softStop = true;
                    String err = Core_CRM_Utility.getCRMLabel('Core_pw_viewer_role_alert');
                    
                    if (errMsgMap.containsKey('softStop')) { List<String> errList = errMsgMap.get('softStop'); errList.add(err);  errMsgMap.put('softStop', errList);
                    } else { errMsgMap.put('softStop', new List<String> { err }); }
                }
                // TWC3123-5182 - End
                
                //Areefa start : added below code as part of TWC4767-3387
                String query = 'Select id , Core_Sales_Groups__c , '+String.escapeSingleQuotes(accountConsition.Core_Field_API_name__c) +' from Account where id = \''+String.escapeSingleQuotes(oppObject.AccountId)+'\' Limit 1';
                Account accountDetails = Database.query(query);
                    if (accountDetails.get(accountConsition.Core_Field_API_name__c) != null && accountDetails.get('Core_Sales_Groups__c') != accountDetails.get(accountConsition.Core_Field_API_name__c) && Date.today() >= accountConsition.Core_Start_Date__c && Date.today() <= accountConsition.Core_End_Date__c && oppObject.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity' && oppObject.RecordType.DeveloperName == 'Core_Design_Opportunity' && Boolean.valueOf(Core_CRM_Utility.getCRMLabel('Core_PW_ApprovalSubmissionRestrict'))) {
                        hardStop = true;
                        String err= Core_CRM_Utility.getCRMLabel('AccountSalesGroupError');
                        if(errMsgMap.containsKey('hardStop')) { List<String> errList = errMsgMap.get('hardStop'); errList.add(err); errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });    }
                    }
                //Areefa End
              
       
                /* //Commented by Hira as part of TWC3123-5419 	
                //TWC3123-4111- Start - Validation for PW Approval to check PW quantity and sales price should not be blank.
                List<Opportunitylineitem> oppsProduct = [select id,Core_PW_Quantity__c,Core_PW_Sales_Price__c,Product2.name, ListPrice, Core_Status__c from Opportunitylineitem where opportunityid =:oppId AND Core_Status__c='Win Approved'];
               	System.debug('OppsLineItem- '+oppsProduct);
                String productName = '';
                for(Opportunitylineitem lineItem:oppsProduct){
                    if(lineItem.Core_PW_Quantity__c== Null || lineItem.Core_PW_Sales_Price__c== Null)
                    {
                            hardStop = true;
                            String err= System.Label.Core_PW_QuantityAndSalesPrice_cannot_beBlank +': Name:- '+ lineItem.Product2.name;
                            if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                            } else 
                            {
                            errMsgMap.put('hardStop', new List<String> { err });
                            }
                        
                        
                    }
                    system.debug('##############ERRROORRR#########'+errMsgMap);
                    
                }
                //TWC3123-4111 - End
				*/
                 /**********************************END************************************/
                     //Bharath
                     // Start - validation to make sure that user cannot submit opportunity for Production Win approval with any blank Oppty Team Member Description field.
                   /**********************************START************************************************************/
                   
                    List<OpportunityTeamMember> oppsTM = [Select Id, Name, Core_Description_of_Contribution__c from OpportunityTeamMember  where opportunityid =:oppId AND (Opportunity.StageName ='Design Win' )];
                    List<String> members = new List<String>();
                    for(OpportunityTeamMember teamMember:oppsTM)
                    {
                        if(String.Isblank(teamMember.Core_Description_of_Contribution__c))
                        {
                           members.add(teamMember.name);      
                        }
                    }
                    if(members.size()>0){
                        hardStop = true;
                            String err= Core_CRM_Utility.getCRMLabel('Core_OppTM_Description_cannot_beBlank') +' : '+ String.join(members,', ') + '.';
                            if(errMsgMap.containsKey('hardStop')) 
                            {
                                List<String> errList = errMsgMap.get('hardStop');
                                errList.add(err);
                                errMsgMap.put('hardStop', errList);
                            } else 
                            {
                                errMsgMap.put('hardStop', new List<String> { err });
                            }
                    }
                            
                    
                   /**********************************END**************************************************************/
                   
                
                
                
                
                // Start- Added for TWC3123-3676 - Condition based file name check for POP
                List<Attachment> attachsize = new List<Attachment>();
                List<Note> Notesize = new List<Note>();
                List<ContentDocumentLink > contentdocSize = new List<ContentDocumentLink >();
                List<Task> taskList = new List<Task>();
                if(isPWApproval){
                    //String POP3 = '%'+Label.Core_Performance_indicator3+'%';// Commented for TWC3123-3904
                    //Start - TWC3123-3904 Added some new fileName formats.
                    List<String> POPFileNames = new List<String>();
                    if(Label.Core_Performance_indicator3.contains(',')){
                    POPFileNames = Label.Core_Performance_indicator3.split(',');
                    }else{
                    POPFileNames.add(Label.Core_Performance_indicator3); 
                    }
                    //End - TWC3123-3904
                    //TWC3123-3904 changed like filter variable in query.
                    attachsize=[select id,Name from Attachment where parentId=:oppObject.Id AND Name LIKE :POPFileNames limit 1];
                    Notesize=[select id,Title from Note where parentId=: oppObject.Id AND Title Like:POPFileNames limit 1];
                    contentdocSize=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppObject.Id  AND ContentDocument.Title Like:POPFileNames limit 1];
                    taskList = [SELECT id, Subject, Core_Task_Type__c FROM Task WHERE Subject LIKE :POPFileNames AND WhatId = :oppObject.Id limit 1];
                }
//Commented for low touch oppty modify this to exclude POP Validation
//Vijay 3/9/24 :  reverting back to soft error for Commissionable flag (TWC4767-2794)
                if( oppObject.Core_Commissionable__c == 'Yes' && attachsize.isEmpty() && Notesize.isEmpty() && contentdocSize.isEmpty() && taskList.isEmpty()){
                        softStop = true;
                        String err;
                        err= System.Label.Core_Oppo_PWApproval_POP;
                        if(errMsgMap.containsKey('softStop')) {
                            List<String> errList = errMsgMap.get('softStop');
                            errList.add(err); 
                            errMsgMap.put('softStop', errList);
                        } else {
                            errMsgMap.put('softStop', new List<String> { err });
                        }
                }

                /*Opportunity hard Stops ends */
                /*Opportunity Soft Stops start */
                if(((oppObject.CloseDate < System.Today() || oppObject.CloseDate > System.Today().addDays(365))
                   		&& 	oppObject.Core_Approval_Status__c != 'Approved'	)|| Test.isRunningTest()){
                    
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Enter_Decision_Date;
                    
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {
                        errMsgMap.put('softStop', new List<String> { err });
                    }
                }
                  //TWC3123-4020 Production Win Team Member Role Change 
                 /*Fetching Opportunity Team Production Win Member Role */
                 //List<AggregateResult> oct = [select count(id) from OpportunityTeamMember where OpportunityId =:oppId and Production_Win_Member_Role__c=null];
                 integer  ProdWinRoleNullCount= database.countQuery('select count() from OpportunityTeamMember where OpportunityId =:oppId and Core_Production_Win_Member_Role__c=null');
                 
                 boolean ProductionWinMemberRole = false;
                // integer ProdWinRoleNullCount = (Integer) oct[0].get('expr0');
                 if(ProdWinRoleNullCount>0){                    
                    ProductionWinMemberRole=true;                    
                     
                   /* hard Stops starts */
                   if(oppObject.RecordType.DeveloperName=='Core_Design_Opportunity' && ProductionWinMemberRole==true){
                    
                     hardStop = true;
                     String err= System.Label.Core_Oppo_Approval_if_ProductionWinMemberRole_not_selected;
                     
                     if(errMsgMap.containsKey('hardStop')) {
                         List<String> errList = errMsgMap.get('hardStop');
                         errList.add(err);
                         errMsgMap.put('hardStop', errList);
                     } else {
                         errMsgMap.put('hardStop', new List<String> { err });
                     }
                 }
                 /* hard Stops ends */
                }
            }
            /*Opportunity Soft Stops ends */
            wrpr.hardStopList = errMsgMap.get('hardStop');
            wrpr.softStopList = errMsgMap.get('softStop');

        }
        
        catch(exception e){
            String errorMsg= e.getMessage();
            system.debug('1@@errorMsg--->'+errorMsg);
            throw new AuraHandledException(errorMsg);            
        }
        
        return wrpr;
        
    }
    
    /*
    * Method name  : submitApproval
    * Description  : This method call the standard opportunity approval process. 
    * Return Type  : void
    * Parameter    : String oppId,String comments
    */  
    @auraEnabled
    public static void submitApproval(String oppId,String comments){
        try{
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();                
            approvalRequest.setObjectId(OppId);
            approvalRequest.setComments(comments);
            //system.debug('approvalRequest'+approvalRequest);
            //system.debug('comments'+comments);
            if(!Test.isRunningTest()){
                Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                if(approvalResult .isSuccess()){
                    //system.debug('success-'+approvalResult .isSuccess());
                }
                else{
                    //system.debug('failed-'+approvalResult .isSuccess());
                }
            }
        }
        catch (Exception e) {
            /*Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_OppApprovalCtrl', Core_Method_Name__c = 'submitApproval', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getMessage(), Core_Login_User_Id__c= userInfo.getUserId());
            insert ExcepLog;*/
            String errorMsg = e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
        
    }
    
    public class checklistWrapper{
        @AuraEnabled
        public List<String> hardStopList = new List<String>();
        @AuraEnabled
        public List<String> softStopList = new List<String>();
    }
}