/***************************************************************************************
Apex Class Name: Core_OppApprovalCtrl
Version        : 1.0 
Created Date   : 24 Aug, 2022
Description    : This Class is used to validate the errors before submitting the opportunity for approval.
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan           24 Aug, 2022               Initial Revision
* Gaurav Kurwade           14 Sep, 2022               Updated
* Jerin Thomas S           25 Nov, 2022               Updated
* Mula Yeshwanth           07 Dec, 2022               Updated 
* Joydeep Banerjee         23 Dec, 2022               Updated
* Areefa Banu              21 Mar, 2023               if there is any Submitted Opportunity Support Request, submit for opportunity approval should not happen.
* Areefa Banu              26 May, 2023               Removed CoE_Status__c from query
* VijayKumar S             01 Jun, 2023               Added new check for Sales group.
*/

public without sharing class  Core_OppApprovalCtrl {
    /*
* Method name  : checklistForApproval
* Description  : validate the errors/warnings before submitting the opportunity for approval. 
* Return Type  : checklistWrapper
* Parameter    : String oppId,String comments
*/   
    @auraEnabled
    public static checklistWrapper checklistForApproval(String oppId,String comments){
        //Custom setting to check Sales group
        Opportunity__c accountConsition = Opportunity__c.getOrgDefaults();
        
        //List<String> errMessageList= new List<String>();
        Map<String, List<String>> errMsgMap = new Map<String, List<String>>();        
        checklistWrapper wrpr = new checklistWrapper();
        try{
            
            boolean hardStop = false;
            boolean softStop = false;
            boolean isPCCDealReg = false;
            boolean isPCCDesign = false;
            
            /*Opportunity hard Stops starts */
            Opportunity oppObject = [select id,AccountId, Core_Intel_Platform__c, Core_Restrict_Opp_Submission__c, Core_Product_Segment__c,Core_Consumption_Market__c, Core_Product_Application__c,Core_Contact_Roles_Count__c, StageName, Core_At_Risk__c,Core_Solution_Type__c, Core_Decimal_Check__c,Core_Combined_Solution_Detail__c, Core_Manufacturing_Geo__c,Core_Production_End_Date__c, Description, Core_First_Customer_Ship_Date__c,Core_Commissionable__c, Core_Volume__c, Core_Exclude_From_KPIs__c,CloseDate, Core_Status_Update__c, Account.RecordType.Name,Core_Product_At_Risk_Not_Closed_Count__c,Core_Competitive_Architecture__c,Core_Pending_Product_Count__c, Core_Product_Count__c,Core_Primary_Customer_Contact__c, Core_Technical_Owner__c, OwnerId, CreatedById, RecordType.Name, RecordType.DeveloperName, Core_Write_In_Product_Count__c, Core_Opportunity_Type__c,Core_Compliance_Status__c,Core_Design_Registration_Id__c,Core_Opportunity_Coverage_Nm__c,Core_Coverage_Type_Nm__c,
                                     Core_Approval_Status__c,Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c ,Amount, Core_VBS_Potential__c,Core_VBS_Status__c,CRM_VBS_Contract_Start_Date__c,CRM_VBS_Contract_Lifetime_in_Months__c,CRM_VBS_Total_Contract_Value__c,Opportunity_Focus__c,CRM_SW_Flag_Ind__c,SBQQ__PrimaryQuote__r.Pricing_Quote_Program_Nm__c,SBQQ__PrimaryQuote__r.SBQQ__Primary__c,SBQQ__PrimaryQuote__r.SBQQ__Status__c from Opportunity where id =: oppId limit 1];//CoE_Status__c
            //OpportunityLineItem oppLine = [select id, Core_Status__c ,OpportunityId from OpportunityLineItem where OpportunityId =: oppObject.Id ] ; 
            if(oppObject != null){ 
                List<OpportunityLineItem> oppLineItemMap = new List<OpportunityLineItem>([select Id,Core_Status__c,Quantity from OpportunityLineItem where OpportunityId =: oppId order by Id ]);         
                isPCCDealReg = oppObject.Core_Opportunity_Coverage_Nm__c == 'Partner-Led Opportunity' && oppObject.Core_Coverage_Type_Nm__c == 'Deal Registration' ? true : false;
                isPCCDesign =  oppObject.RecordType.DeveloperName == 'Core_Design_Opportunity' && oppObject.Core_Design_Registration_Id__c != null  && oppObject.Core_Opportunity_Coverage_Nm__c == Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram')? true : false;
                
                //Joydeep Banerjee - TWC3123-3274 changes starts
                /*Fetching Opportunity Contact Role */
                
                List<OpportunityContactRole> ocr = [select id,Role from OpportunityContactRole where opportunityid =:oppId];
                
                if(ocr.size()>=0){
                    
                    boolean ContactRole = false;
                    for(OpportunityContactRole obj:ocr){
                        if(obj.Role=='Business Decision Maker'){
                            ContactRole=true;
                            break;
                        }
                    }
                
                    
                 //Set<String> excludedStatuses = new Set<String>{'Rejected', 'Denied', 'Approved'}; //'Accepted'
                        
                        if (oppObject.CRM_SW_Flag_Ind__c == true && oppObject.SBQQ__PrimaryQuote__r.SBQQ__Primary__c == true && oppObject.SBQQ__PrimaryQuote__r.SBQQ__Status__c!='Accepted') {
                            
                            hardStop = true;
                            String err=Core_CRM_Utility.getCRMLabel('CRM_SWOppClose'); //You have an open quote, please go to Quotes and close the quote first then close your opportunity.
                           
                            if(errMsgMap.containsKey('hardStop')) {
                                List<String> errList = errMsgMap.get('hardStop');
                                errList.add(err);
                                errMsgMap.put('hardStop', errList);
                            } else {
                                errMsgMap.put('hardStop', new List<String> { err });
                            }   
                        }
                    /*****************************
      Change For  :::  TWC4767-2525::: If none of the SW Quote is marked as primary,Do not allow to submit the oppty
      Added on/by  :::  13/09/24 - Areefa
         *****************************************/
                    
                    List<SBQQ__Quote__c> swquote1 = [SELECT id from SBQQ__Quote__c where SBQQ__Primary__c= true and Pricing_Quote_Program_Nm__c='Software & Services' and SBQQ__Opportunity2__c=:oppId];
                    if(oppObject.CRM_SW_Flag_Ind__c == true && swquote1.isEmpty()){ 
                        hardStop = true;
                        String err=Core_CRM_Utility.getCRMLabel('CRM_SWOpptWithoutPrimaryQuote'); //None of the Software Quotes associated with the Opportunity are not marked as Primary.                       
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }   
                    }
                    
                    /*****************************
Change For:::VBS check before submitting opportunities
Added on/by:: 15/05/24 - Areefa
*****************************************/
                    if(oppObject.Core_VBS_Potential__c && oppObject.Core_VBS_Status__c != 'SOAR1 Un-qualified' && oppObject.Core_VBS_Status__c != 'SOAR4 Contract Not Signed' && oppObject.Core_VBS_Status__c != 'SOAR3 Denied'){
                        
                        if(oppObject.Core_VBS_Status__c != 'SOAR4 Contract Signed'){
                            hardStop = true;
                            String err= System.Label.Core_VBS_Restrict_Submission_for_Opportunity;                            
                            if(errMsgMap.containsKey('hardStop')) {
                                List<String> errList = errMsgMap.get('hardStop');
                                errList.add(err);
                                errMsgMap.put('hardStop', errList);
                            } else {
                                errMsgMap.put('hardStop', new List<String> { err });
                            }
                        }
                        
                        /* Commented as part of TWC4767-3910: CRM:Bypass Contract Start Date greater than Decision Date VR for all profiles 
                        if(oppObject.CRM_VBS_Contract_Start_Date__c != null && oppObject.CRM_VBS_Contract_Start_Date__c < oppObject.CloseDate)
                        {
                            hardStop = true;
                            String err = Core_CRM_Utility.getCRMLabel('Core_VBS_ContactSDt_GrtThanDesicionDt');   //Contract Start Date should be greater than opportunity decision date
                            
                            if(errMsgMap.containsKey('hardStop')) {  
                                List<String> errList = errMsgMap.get('hardStop');
                                errList.add(err);
                                errMsgMap.put('hardStop', errList);
                            } else {
                                errMsgMap.put('hardStop', new List<String> { err });
                        }
                        }*/
                        
                        if(oppObject.CRM_VBS_Contract_Lifetime_in_Months__c != null && oppObject.CRM_VBS_Total_Contract_Value__c != null && oppObject.CRM_VBS_Contract_Lifetime_in_Months__c > 12 && oppObject.Amount > oppObject.CRM_VBS_Total_Contract_Value__c)
                        {
                            hardStop = true;
                            String err = Core_CRM_Utility.getCRMLabel('Core_VBS_TCV_GrtThan_DWAmt');   //Total Contract Value must be more than Design Win Amount if Contract time period is more than 12 months
                            
                            
                            if(errMsgMap.containsKey('hardStop')) {  
                                List<String> errList = errMsgMap.get('hardStop');
                                errList.add(err);
                                errMsgMap.put('hardStop', errList);
                            } else {errMsgMap.put('hardStop', new List<String> { err });
                                   }
                        }
                    }
                    /* TWC4767-3906:CRM: Opportunity Focus field to be blank from Opportunity
                    if(oppObject.Core_VBS_Potential__c==True && oppObject.Opportunity_Focus__c=='Growth' && (oppObject.Core_VBS_Status__c=='SOAR4 Contract Not Signed' || oppObject.Core_VBS_Status__c=='SOAR1 Un-qualified'  || oppObject.Core_VBS_Status__c=='SOAR3 Denied')){
                        softStop = true;
                        String err= Core_CRM_Utility.getCRMLabel('Core_VBS_IntelLedGrowth_OppFocusReq'); 
                        if(errMsgMap.containsKey('softStop')) {
                            List<String> errList = errMsgMap.get('softStop');
                            errList.add(err);
                            errMsgMap.put('softStop', errList);
                        } else {
                            errMsgMap.put('softStop', new List<String> { err }); 
                    }
                    }*/
                    
                    /*****************************
Change For:::System should restrict the sellers from submitting opportunities
Added on/by:: 29/12/22 - Gaurav
*****************************************/
                    if(oppObject.Core_Restrict_Opp_Submission__c==True){
                        
                        hardStop = true;
                        String err= System.Label.Core_Restrict_Submission_for_Opportunity;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });
                               }
                    }
                    //Vijay
                    //checking sales group for give time is same or Not
                    String query = 'Select id , Core_Sales_Groups__c , '+String.escapeSingleQuotes(accountConsition.Core_Field_API_name__c) +' from Account where id = \''+String.escapeSingleQuotes(oppObject.AccountId)+'\' Limit 1';
                    
                    Account accountDetails = Database.query(query);
                    if (accountDetails.get(accountConsition.Core_Field_API_name__c) != null && accountDetails.get('Core_Sales_Groups__c') != accountDetails.get(accountConsition.Core_Field_API_name__c) &&  Date.today() >= accountConsition.Core_Start_Date__c && Date.today() <= accountConsition.Core_End_Date__c && oppObject.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity') {
                        
                        String err= Core_CRM_Utility.getCRMLabel('AccountSalesGroupError');
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });
                               }
                    }
                    /**********************************END************************************/
                    
                    //Areefa
                    //Any Submitted Opportunity Support Request, submit for opportunity approval should not happen
                    /**********************************Start************************************/
                    List<Core_Opportunity_Support__c> opptSuppReq=  new List<Core_Opportunity_Support__c>();      
                    opptSuppReq = [Select Id from Core_Opportunity_Support__c where ( Core_Status__c IN ('Submitted' ,'Pending') OR (Core_Status__c  = 'Approved' AND RecordType.DeveloperName = 'Core_Center_of_Excellence_Request' )) and Opportunity__c =:oppId and RecordType.DeveloperName<> 'CRM_Marketing_Support' limit 1];
                    
                    if(opptSuppReq.size()>0){
                        
                        hardStop = true;
                        String err= System.Label.Core_OpptCantSubmitForApprovelOnOpenOppSuppReq;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                    
                    /**********************************END************************************/
                    //Aashna
                    //TWC3123-4680- Start - validation to make sure that user cannot submit opportunity for Design Win approval with any blank Oppty Team Member Description field.
                    //Jahnavi 
                    //TWC3123-5678-PCC Deal - To bypass the hard stop warning when competitive architecture is blank when opportunity is submitted 
                    /**********************************START************************************************************/
                    List<OpportunityTeamMember> oppsTM = [Select Id, Name, Core_Description_of_Contribution__c from OpportunityTeamMember  where opportunityid =:oppId AND (Opportunity.StageName ='Design' or Opportunity.StageName ='Design Win' ) /*and Opportunity.Core_Design_Registration_Id__c=null*/];
                    
                    List<String> members = new List<String>();
                    if(!isPCCDealReg){
                        for(OpportunityTeamMember teamMember:oppsTM)
                        {
                            if(String.Isblank(teamMember.Core_Description_of_Contribution__c))
                            {
                                members.add(teamMember.name);      
                            }
                        }
                    }
                    if(members.size()>0 ){
                        hardStop = true;
                        String err= Core_CRM_Utility.getCRMLabel('Core_OppTM_Description_cannot_beBlank') +' : '+ String.join(members,', ') + '.';
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }                      
                    /**********************************END**************************************************************/
                    //Added By Hira for Opportunity Solutions validation before DW Submission
                    /**********************************Start************************************************************/
                    /*List<Core_Solution_Areas__c> solutionAreas=[select Id,Name from Core_Solution_Areas__c where Opportunity__c=:oppId AND Core_Status__c IN ('Pending','Resubmit')];
List<String> SolutionNames=new List<String>();
if(solutionAreas.size()>0){
for(Core_Solution_Areas__c solArea:solutionAreas){
SolutionNames.add(solArea.Name);
} 
}

if(SolutionNames.size()>0){
hardstop=true;
String err='This Opportunity has following Pending Solution Records'+' : '+ String.join(SolutionNames,', ') + '.';
if(errMsgMap.containsKey('hardStop')) {
List<String> errList = errMsgMap.get('hardStop');
errList.add(err);
errMsgMap.put('hardStop', errList);
} else {
errMsgMap.put('hardStop', new List<String> { err });
}
}*/
                    
                    /**********************************END**************************************************************/
                    if(oppObject.RecordType.DeveloperName=='Core_Design_Opportunity' && (oppObject.Core_Design_Registration_Id__c == null && (ContactRole==false || oppObject.Core_First_Customer_Ship_Date__c==null))){
                        
                        hardStop = true;
                        String err= System.Label.Core_Design_Design_Exit_Criteria;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                    
                    if(oppObject.RecordType.DeveloperName=='Core_Design_Opportunity' && (oppObject.Core_Design_Registration_Id__c != null && oppObject.Core_First_Customer_Ship_Date__c==null)){
                        
                        hardStop = true;
                        String err= System.Label.Core_DDR_Design_Exit_Criteria;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                    if((oppObject.RecordType.DeveloperName=='Core_Design_Opportunity'|| oppObject.RecordType.DeveloperName=='Core_Deal_Opportunity') && oppObject.Core_Design_Registration_Id__c != null && oppObject.Core_Design_Registration_Id__r.Core_Design_Registration_Status_Nm__c=='Re-Submitted')
                    {   
                        hardStop = true;
                        String err= System.Label.Core_Opp_Approval_Resubmission;
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                    
                    /* 
if(oppLine!= null) {
if (oppLine.Core_Status__c == 'On Hold'){
hardStop = true;
String err= System.Label.Core_OppProd_OnHold_Warning;

if(errMsgMap.containsKey('hardStop')) {
List<String> errList = errMsgMap.get('hardStop');
errList.add(err);
errMsgMap.put('hardStop', errList);
} else {
errMsgMap.put('hardStop', new List<String> { err });
}

} } */
                    
                    if(oppObject.RecordType.DeveloperName=='Core_Deal_Opportunity' && ContactRole==false && oppObject.Core_Design_Registration_Id__c == null ){
                        
                        hardStop = true;
                        String err= System.Label.Core_Deal_Design_Exit_Criteria;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                    String CheckLabel = 'true';
                    if(isPCCDealReg && !CheckLabel.equalsignorecase(System.Label.CRM_ShowPCC_SubmitForApproval_6QPS) && (UserInfo.getUserId() == oppObject.OwnerId || UserInfo.getProfileId() == System.Label.Core_IPS_DataOps) ){
                        
                        hardStop = true;
                        String err= Core_CRM_Utility.getCRMLabel('CRM_ShowPCC_SubmitForApproval_Error');
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                }
                
                //TWC3123-3274 changes ends
                
                List<String> Oppfield = new List<String>();
                if(oppObject.RecordType.DeveloperName=='Core_Deal_Opportunity'){
                    Oppfield = System.Label.Core_Opp_Deal_Fields_Req_Approval.split(';');
                } else if(oppObject.RecordType.DeveloperName=='Core_Design_Opportunity' && oppObject.Core_Design_Registration_Id__c == null && oppObject.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram')){
                    Oppfield = System.Label.Core_Opp_Design_Fields_Req_Approval.split(';');
                } else if(oppObject.RecordType.DeveloperName=='Core_Design_Opportunity' && oppObject.Core_Design_Registration_Id__c != null  
                          && oppObject.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunityPartnerProgram')){
                              Oppfield = System.Label.Core_DDR_Opp_Design_Fields_Req_Approval.split(';'); // [TWC4767-751]Removed "Intel Platform" as part of PCC Design changes Areefa
                          }
                
                if(!Oppfield.isEmpty()){
                    
                    Map<String,Object> valueMap = new Map<String,Object>();
                    
                    for ( String fieldName : Oppfield ) {
                        valueMap.put(fieldName, oppObject.get(fieldName));
                    }
                    //Jahnavi 
                    //TWC3123-5678-PCC Deal - To bypass the hard stop warning when competitive architecture is blank when opportunity is submitted 
                    if(isPCCDealReg && valueMap.containsKey('Core_Competitive_Architecture__c')){                           
                        valueMap.remove('Core_Competitive_Architecture__c');
                    }
                    if(isPCCDealReg && valueMap.containsKey('Core_Contact_Roles_Count__c')){                           
                        valueMap.remove('Core_Contact_Roles_Count__c');
                    }
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Schema.SObjectType leadSchema = schemaMap.get('Opportunity');
                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                    
                    List<String> InCompleteField = new List<String>();
                    
                    for(String field : Oppfield){
                        if(valueMap.containsKey(field)){
                            if(valueMap.get(field) == null || valueMap.get(field) == 0){
                                
                                InCompleteField.add(fieldMap.get(field).getDescribe().getLabel());  
                            }
                        }
                    }
                    // TWC4767-2117 : seperated out
                    if(oppObject.Core_Product_Count__c < 1){ 
                        InCompleteField.add('must include at least one (1) Product'); 
                    }
                    if(!InCompleteField.isEmpty()){ 
                        hardStop = true;
                        String err= 'Please Complete the Following Field: ' + String.join(InCompleteField,', ') + '.';
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { 'Please Complete the Following Field: ' + String.join(InCompleteField,', ') + '.' });
                               } 
                    }    
                }
                //TWC3123-6322:Validation Msg seperation of PCC Design Opps from rest while submission for Approval
                boolean userCheckforPCCDesSub = UserInfo.getUserId() != oppObject.OwnerId && UserInfo.getUserId() != oppObject.CreatedById && UserInfo.getProfileId() != System.Label.Core_IPS_DataOps && UserInfo.getProfileId() != System.Label.Core_System_Admin ;
                boolean userCheckforSub = UserInfo.getUserId() != oppObject.Core_Technical_Owner__c && UserInfo.getUserId() != oppObject.OwnerId && UserInfo.getUserId() != oppObject.CreatedById && UserInfo.getProfileId() != System.Label.Core_IPS_DataOps && UserInfo.getProfileId() != System.Label.Core_System_Admin ;
                
                
                
                if(isPCCDesign && userCheckforPCCDesSub) {  //PCC - Design
                    hardStop = true;
                    String err= Core_CRM_Utility.getCRMLabel('PCC_Design_OppApproval_If_not_Owner');                  
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           } 
                } 
                else if(userCheckforSub) { //Intel-led and PCC - Deal
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_If_not_Owner;
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                
                if(oppObject.Core_Pending_Product_Count__c < 1){ //there is should at least 1 pending product
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_if_no_pending_product;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                    
                }
                
                if(oppObject.Core_Decimal_Check__c == true || Test.isRunningTest()){ //Decimal check
                    hardStop = true;
                    String err= System.Label.Core_Decimal_Validation;
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                    
                }
                /*if(oppObject.RecordType.Name != 'Opportunity'){

hardStop = true;
String err= 'Only Opportunity with record type Opportunity are allowed to be submitted';

if(errMsgMap.containsKey('hardStop')) {
List<String> errList = errMsgMap.get('hardStop');
errList.add(err);
errMsgMap.put('hardStop', errList);
} else {
errMsgMap.put('hardStop', new List<String> { err });
}
}*/
                if(oppObject.Core_Write_In_Product_Count__c != 0 && !isPCCDealReg){
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_Write_in_Product_count;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                
                /*    if( oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Deal') && ( String.isBlank(oppObject.Core_Solution_Type__c) || String.isBlank(oppObject.Core_Combined_Solution_Detail__c))){

hardStop = true;
String err= System.Label.Core_Oppo_Approval_Empty_Sol_type;

if(errMsgMap.containsKey('hardStop')) {
List<String> errList = errMsgMap.get('hardStop');
errList.add(err);
errMsgMap.put('hardStop', errList);
} else {
errMsgMap.put('hardStop', new List<String> { err });
}
}
*/
                
                if(oppObject.Core_Product_At_Risk_Not_Closed_Count__c > 0 && oppObject.Core_At_Risk__c){
                    
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_At_Risk;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                //Added for PCC 6QPS total Qty should not be more than Opp.Product Qty (TWC3123-5772)
                String strList = Core_FC_ProductSchedule_Ctrl.checkTotalQuantity(oppId);
                if(isPCCDealReg && strList != ''){
                    hardStop = true;
                    String err= strList+System.Label.Core_6QPS_Schedule_Error;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                
                if(IsPCCDealReg){
                    Map<Id, List<Core_Opp_FC_Prod_Schedule__c>> allForecastSorted = Core_FC_ProductSchedule_Ctrl.getProdSortForecastMapMethod(String.valueOf(oppId));
                    Boolean showErr=false;
                    String strItemList = '';
                    Integer count = 1;
                    List<Core_Opp_FC_Prod_Schedule__c> tempList = new List<Core_Opp_FC_Prod_Schedule__c>();
                    /*List<Core_Opp_FC_Prod_Schedule__c> tempList2 = new List<Core_Opp_FC_Prod_Schedule__c>([SELECT id,Core_Opp_FC_Opportunity__c,Core_Opp_FC_isdeleted__c,Core_Opp_FC_Claim_Date__c,Core_Opp_FC_Quantity__c,Core_Opp_FC_Sched_Revenue__c,Core_FC_Opportunity_Product__r.Core_Status__c
                                                                                                         FROM Core_Opp_FC_Prod_Schedule__c
                                                                                                          WHERE Core_Opp_FC_Opportunity__c = :oppId AND 
                                                                                                          Core_Opp_FC_isdeleted__c = false AND Core_FC_Opportunity_Product__r.Core_Status__c not in ('Lost','Cancelled')
                                                                                                          ORDER BY Core_Opp_FC_Product__r.Name,Core_Opp_FC_Quarter_Date__c]);*/
                     
                    for(OpportunityLineItem oliId : oppLineItemMap){
                        Decimal totalqty = 0;
                        Decimal totalRevenue =0;
                        tempList = allForecastSorted.get(oliId.id);
                        
                            for(Core_Opp_FC_Prod_Schedule__c fc : tempList){

                                totalqty =totalqty + fc.Core_Opp_FC_Quantity__c;
                               totalRevenue=totalRevenue+fc.Core_Opp_FC_Sched_Revenue__c;                            
                            }
                       
                        if(totalRevenue==0 && totalqty==0 && oliId.Core_Status__c!='Cancelled' && oliId.Core_Status__c!='Lost'){   
                            
                            showErr = true;
                            if(strItemList ==''){
                                strItemList = 'Item#'+String.valueOf(count);                  
                            }
                            else{
                                strItemList = strItemList+'/Item#'+String.valueOf(count);                                      
                            }                            
                        }
                        count++;
                    }
                    if(showErr){
                        hardStop = true;
                        String err= strItemList + System.Label.Core_Oppo_Approval_6QPS;
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {
                            errMsgMap.put('hardStop', new List<String> { err });
                        }
                    }
                }
                
                if(oppObject.Account.RecordType.Name != 'Intel Account'){
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_Account_Record_Type_is_inactive;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                if(oppObject.Core_Compliance_Status__c == 'On Hold – Review in Progress' || oppObject.Core_Compliance_Status__c == 'On Hold – Government Authorization Needed' || oppObject.Core_Compliance_Status__c == 'Not Approved'){
                    
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_Core_Compliance_Status_c;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                if(oppObject.StageName == 'Lost'|| oppObject.StageName == 'Production Lost' || oppObject.StageName == 'Production Cancelled' || oppObject.StageName == 'Cancelled'){
                    
                    hardStop = true;
                    String err= System.Label.Core_Oppo_Approval_Stage;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                if(oppObject.StageName == 'Qualify'|| oppObject.StageName == 'Define' || oppObject.StageName == 'Develop'){
                    
                    hardStop = true;
                    String err= System.Label.Core_Oppo_submit_for_Approval_Stage;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                
                String POP = '%'+Label.Core_Performance_indicator+'%';
                String POP1 = '%'+Label.Core_Performance_indicator1+'%';
                String POP2 = '%'+Label.Core_Performance_indicator2+'%';
                List<Attachment> attachsize=[select id,Name from Attachment where parentId=:oppObject.Id AND (Name LIKE :POP OR Name LIKE :POP1) limit 1];
                List<Note> Notesize=[select id,Title from Note where parentId=: oppObject.Id AND (Title Like:POP OR Title Like:POP1) limit 1];
                List<ContentDocumentLink> contentdocSize=[SELECT ContentDocumentId,ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId=:oppObject.Id  AND (ContentDocument.Title Like:POP OR ContentDocument.Title Like:POP1) limit 1];
                List<Task> taskList = [SELECT id, Subject, Core_Task_Type__c FROM Task WHERE (Subject LIKE :POP OR Subject LIKE:POP1 OR Core_Task_Type__c LIKE:POP2) AND WhatId = :oppObject.Id limit 1];
                
                if(attachsize.isEmpty() && Notesize.isEmpty() && contentdocSize.isEmpty() && taskList.isEmpty()){
                    /*****************************
      Change For::: TWC4767-1769 POP Validation update for PCC
      Added on/by:: 04/12/2024 - shijas
        *****************************************/
                    if(oppObject != null && isPCCDealReg){ 
                        // PCC POP Message block    
                        hardStop = true;
                        String err= System.Label.Core_Oppty_Approval_PCC_POP;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });
                               }
                    } else{
                        if(oppObject.Core_Commissionable__c == 'Yes'){
                        // Non PCC
                        softStop = true;
                        String err= System.Label.Core_Oppo_Approval_POP;
                        if(errMsgMap.containsKey('softStop')) {
                            List<String> errList = errMsgMap.get('softStop');
                            errList.add(err);
                            errMsgMap.put('softStop', errList);
                        } else {
                            errMsgMap.put('softStop', new List<String> { err });
                        }
                    }
                }
                }
                
                if(String.isBlank(oppObject.Description)){
                    //new update start
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Opportunity_Description;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {
                        errMsgMap.put('softStop', new List<String> { err });
                    }
                }
                //commented this method as part of TWC3123-6013
                //Added for PCC 6QPS Quarter Not Aligned Warning Msg (TWC3123-5756)
                /*
    if(isPCCDealReg && Core_FC_ProductSchedule_Ctrl.checkFCQuarterDate(oppId)){
    softStop = true;
    String err= System.Label.Core_6QPS_Quarters_Not_Aligned;
    if(errMsgMap.containsKey('softStop')) {
    List<String> errList = errMsgMap.get('softStop');
    errList.add(err);
    errMsgMap.put('softStop', errList);
    } else {
    errMsgMap.put('softStop', new List<String> { err });
    }
    } */
                
                
                //TWC3123-6080 - Devashish 
                if(isPCCDealReg)
                {      
                    
                    Core_FC_ProductSchedule_Ctrl.FCWrapper fcWrap = Core_FC_ProductSchedule_Ctrl.getFCWrapdata(oppId);
                    
                    String fcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
                    String dummyFcDisplayWrapStr = JSON.serialize(fcWrap.fcDisplayWrapList);
                    String actionType = 'None';
                    
                    List<Integer> ProdNumList = Core_FC_ProductSchedule_Ctrl.checkQLDates(fcDisplayWrapStr,dummyFcDisplayWrapStr,oppObject,actionType,'Submit');
                    String oliRowNum='';
                    if(ProdNumList.size() != 0)
                    {
                        for(Integer i=0; i<ProdNumList.size(); i++)
                        {
                            if(oliRowNum != '')
                            {
                                oliRowNum = oliRowNum+'/'+'Item#'+ProdNumList[i]+' ';
                            }
                            else
                            {
                                oliRowNum = 'Item#'+ProdNumList[i]+' ';
                             }
                        }
                        
                        hardStop = true;
                        String err= oliRowNum + System.Label.Core_PCC_6QPSEditQtyRestriction;
                        
                        if(errMsgMap.containsKey('hardStop'))
                        {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        }
                        else {errMsgMap.put('hardStop', new List<String> { err });
                             }
                    }
                }
                
                if(oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Design') && (oppObject.Core_First_Customer_Ship_Date__c == null || String.valueOf(oppObject.Core_First_Customer_Ship_Date__c) == '' || oppObject.Core_First_Customer_Ship_Date__c < System.Today())){
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_First_Customer_Ship_Date;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                if(oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Design') && (oppObject.Core_Production_End_Date__c == null || oppObject.Core_Production_End_Date__c < system.today() || oppObject.Core_Production_End_Date__c < oppObject.Core_First_Customer_Ship_Date__c)){
                    
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Core_Production_End_Date_c;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }   
                }
                
                Integer Opptupartnersize=[select count() from Core_Opportunity_Partner__c where Core_Opportunity__c =:oppObject.Id]; 
                if(Opptupartnersize < 1){
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Partner;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                
                if(oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Design') && (oppObject.Core_Manufacturing_Geo__c == null || oppObject.Core_Manufacturing_Geo__c == '')){
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Manufacturing_Region;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                    //new update end
                }
                
                /*Opportunity hard Stops ends */
                /*Opportunity Soft Stops start */
                
                if(String.isBlank(oppObject.Core_Competitive_Architecture__c) && oppObject.Core_Design_Registration_Id__c == null){
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Competitive_Architecture_is_Blank;
                    
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                
                if(String.isBlank(oppObject.Core_Status_Update__c)){
                    
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Status_Update;
                    
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                
                Integer DescriptiveFeaturesize=[select count() from Core_Opportunity_Features__c where Core_Opportunity__c =:oppObject.Id];
                if(DescriptiveFeaturesize == 0 && oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Design')){
                    
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Please_enter_the_descriptive_features;
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                
                // ByPassing the below Validation for PartnerPragram [TWC4767-751]                
                if(oppObject.Core_Volume__c == null && oppObject.Core_Opportunity_Type__c.containsIgnoreCase('Design')&& 
                   oppObject.Core_Opportunity_Coverage_Nm__c==Core_CRM_Utility.getCRMLabel('Core_OpportunitySellerProgram')){
                       softStop = true;
                       String err= System.Label.Core_Oppo_Approval_Core_Volume;
                       if(errMsgMap.containsKey('softStop')) {
                           List<String> errList = errMsgMap.get('softStop');
                           errList.add(err);
                           errMsgMap.put('softStop', errList);
                       } else {errMsgMap.put('softStop', new List<String> { err });
                              }
                   }
                
                //Areefa: Bypass for PCC DealReg
                if(oppObject.Core_Exclude_From_KPIs__c && !isPCCDealReg){
                    
                    softStop = true;
                    String err= System.Label.Core_Oppo_Approval_Exclude_from_KPIs;
                    
                    if(errMsgMap.containsKey('softStop')) {
                        List<String> errList = errMsgMap.get('softStop');
                        errList.add(err);
                        errMsgMap.put('softStop', errList);
                    } else {errMsgMap.put('softStop', new List<String> { err });
                           }
                }
                
                if(((oppObject.CloseDate < System.Today() || oppObject.CloseDate > System.Today().addDays(365))
                    && oppObject.Core_Approval_Status__c != 'Approved' )|| Test.isRunningTest()){
                        
                        softStop = true;
                        String err= System.Label.Core_Oppo_Approval_Enter_Decision_Date;
                        
                        if(errMsgMap.containsKey('softStop')) {
                            List<String> errList = errMsgMap.get('softStop');
                            errList.add(err);
                            errMsgMap.put('softStop', errList);
                        } else {errMsgMap.put('softStop', new List<String> { err });
                               }
                    }
            }
            /*Opportunity Soft Stops ends */
            
            /*OpportunityLineItem hard Stops starts */
            List<Opportunitylineitem> oliList = [select id,Core_IsPCCOpportunity_cb__c,SBQQ__QuoteLine__r.Pricing_Status_Nm__c,Core_BU_Mapping_record__c,Core_Vendor__c, Core_bu_short_name__c,Core_Vendor__r.RecordType.name, Core_Status__c, Opportunity.Core_Opportunity_Type__c from Opportunitylineitem where opportunityid =:oppId];
            if(oliList.size()>0){
                /*  To Handle Opp Prod when status is another value than 'Pending','Lost','Cancelled' and separate error for 'On Hold' Status */               
                boolean OnHold =false;
                boolean OnPending=false;
                boolean OnPIFR=false;
                for(Opportunitylineitem olis: oliList){
                    if(olis!= null) {
                        if (olis.Core_Status__c == 'On Hold'){
                            OnHold =true ;
                        }
                        if (olis.Core_Status__c == 'Production Win' || olis.Core_Status__c =='Production Lost' || olis.Core_Status__c =='Production Cancelled' || olis.Core_Status__c =='Win Submitted' || olis.Core_Status__c =='Win Approved'){
                            OnPending=true ;  
                        }
                    } 
                    if(olis.Core_IsPCCOpportunity_cb__c && olis.SBQQ__QuoteLine__r.Pricing_Status_Nm__c!=null && olis.SBQQ__QuoteLine__r.Pricing_Status_Nm__c=='Pending Further Intel Review'){
                        OnPIFR=true;                    
                    } 
                }  
                if (OnPIFR==true && isPCCDealReg) {
                    hardStop = true;
                    String err=System.Label.Core_Oppty_QuoteLine;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                if (OnHold==true) {
                    hardStop = true;
                    String err= System.Label.Core_OppProd_OnHold_Warning;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           }
                }
                if (OnPending==true) {
                    hardStop = true;
                    String err=System.Label.Core_OppProd_Only_Pending_Alert;
                    
                    if(errMsgMap.containsKey('hardStop')) {
                        List<String> errList = errMsgMap.get('hardStop');
                        errList.add(err);
                        errMsgMap.put('hardStop', errList);
                    } else {errMsgMap.put('hardStop', new List<String> { err });
                           } 
                }
                
                /** ENDS **/
                
                for(Opportunitylineitem oli: oliList){
                    if(oli.Core_Vendor__r.RecordType.name =='Inactive Account' && (oli.Core_Status__c == System.Label.Core_OppoLineItemPending || oli.Core_Status__c == System.Label.Core_OppoLineItemOnHold)){
                        hardStop = true;
                        String err= System.Label.Core_VendorInactive;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });
                               }
                        break;
                    }
                } 
                for(Opportunitylineitem oli: oliList){
                    if(oli.Opportunity.Core_Opportunity_Type__c.containsIgnoreCase('Deal') && (oli.Core_Vendor__c == null || String.valueOf(oli.Core_Vendor__c) == '') && !isPCCDealReg){
                        softStop = true;
                        String err= 'Please enter the vendor on the product line item whose products/solution you promote to end customers';
                        
                        if(errMsgMap.containsKey('softStop')) {
                            List<String> errList = errMsgMap.get('softStop');
                            errList.add(err);
                            errMsgMap.put('softStop', errList);
                        } else {errMsgMap.put('softStop', new List<String> { err });
                               }
                        break;
                    }
                }
                for(Opportunitylineitem oli: oliList){
                    if(oli.Core_BU_Mapping_record__c==null){
                        
                        hardStop = true;
                        String err= System.Label.Core_Oppo_Approval_No_Valid_Bu;
                        
                        if(errMsgMap.containsKey('hardStop')) {
                            List<String> errList = errMsgMap.get('hardStop');
                            errList.add(err);
                            errMsgMap.put('hardStop', errList);
                        } else {errMsgMap.put('hardStop', new List<String> { err });
                               }
                        break;
                    }
                }
            }
            /*OpportunityLineItem hard Stops ends */
            //Call the Error Message
            wrpr.hardStopList = errMsgMap.get('hardStop');
            wrpr.softStopList = errMsgMap.get('softStop');
            
            //TWC3123-6361 - Start - Logic to populate QuoteLine related data 
            
            if(oppObject != null && oppObject.RecordType.DeveloperName=='Core_Deal_Opportunity'
               && oppObject.Core_Opportunity_Coverage_Nm__c == 'Intel-Led Opportunity'){
                   
                   List<SBQQ__QuoteLine__c> quoteLines = [ SELECT Name,SBQQ__Product__r.Name, SBQQ__Quote__r.Name,SBQQ__ProductName__c  ,Pricing_Quote_Line_Number__c,Pricing_ECAP_Price_Amt__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId,SBQQ__Quote__r.Pricing_Account_Executive_Nm__c,SBQQ__Quote__r.SBQQ__Opportunity2__c from SBQQ__QuoteLine__c  where SBQQ__Quote__r.Pricing_Quote_Program_Nm__c ='Tender' and SBQQ__Quote__r.Pricing_Program_Type_Nm__c IN ('Small Volume Quotes - Data Center Xeon® CPU' ,'Data Center' ,'Client' ) AND SBQQ__Quote__r.SBQQ__Opportunity2__c <> '' AND Pricing_Status_Nm__c IN ('Won','Lost','Approved') AND SBQQ__Product__r.Name <> 'Write In Product' AND SBQQ__Quote__r.SBQQ__Opportunity2__c=:oppId order by Pricing_Quote_Line_Number__c ];
                   List<OpportunityLineItem> oliListData = [Select id,Product2.name,Opportunity.OwnerId,Core_Status__c,UnitPrice from OpportunityLineItem where OpportunityId  =: oppId and Core_Status__c = 'Pending' order by Product2.name];
                   List<QuoteLineData> qldList = null;
                   QuoteLineData qld = new QuoteLineData() ;
                   
                   
                   if(!quoteLines.isEmpty()){
                       qldList = new List<QuoteLineData>();
                            Integer seq = 0;                
                                             for(OpportunityLineItem oli  :oliListData){
                                                 for(SBQQ__QuoteLine__c qli :quoteLines){
                                                     if(oli.Opportunity.OwnerId == qli.SBQQ__Quote__r.Pricing_Account_Executive_Nm__c
                                                        && oli.Product2.name == qli.SBQQ__Product__r.Name){
                                                            seq = seq+1; 
                                                            qldList.add(new QuoteLineData(qli.SBQQ__ProductName__c,qli.SBQQ__Quote__r.Name,qli.Pricing_Quote_Line_Number__c,oli.UnitPrice,qli.Pricing_ECAP_Price_Amt__c,oli.Id, seq));
                                                        }
                                                 }
                                             }
                                             if(!qldList.isEmpty()){ 
                                                // qldList.sort();
                                                 wrpr.quoteLineData.addAll(qldList);
                                             }
                                             
                                            }
                   
               } 
            //TWC3123-6361 - End - Logic to populate QuoteLine related data 
            
        }catch(exception e){
            String errorMsg= 'Error Message ::: ' + E.getMessage() + ' Due to this issues ::: ' + E.getLineNumber();throw new AuraHandledException(errorMsg);  
            
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
            if(!Test.isRunningTest()){
                Approval.ProcessResult approvalResult = Approval.process(approvalRequest);
                if(approvalResult .isSuccess()){
                }
                else{
                }
            }
        }
        catch (Exception e) {
            /*Core_Exceptions__c ExcepLog = new Core_Exceptions__c( Core_Class_Name__c = 'Core_OppApprovalCtrl', Core_Method_Name__c = 'submitApproval', Core_Exception__c  = 'Line number:'+e.getLineNumber()+', Stack trace: '+e.getMessage(), Core_Login_User_Id__c= userInfo.getUserId());
insert ExcepLog;*/
            String errorMsg = e.getMessage();  throw new AuraHandledException(ErrorMsg);
        }
    }
    
    
    @AuraEnabled
    public static string updateSalesPriceData(List<Object> data) {
        
        List<Core_Log_Entry__c> failedData = new List<Core_Log_Entry__c>();
        List<OpportunityLineItem> dataToUpdate = new List<OpportunityLineItem>();
        
        List<QuoteLineData> quoteLineDataUpdate = (List<QuoteLineData>)System.JSON.deserialize(JSON.serialize(data),List<QuoteLineData>.class);
        
        
        
        try {
            
            for(QuoteLineData qld : quoteLineDataUpdate){
                dataToUpdate.add(new OpportunityLineItem(id =qld.id ,  UnitPrice= qld.approvedECAPPrices ) );
            }
            
            Database.SaveResult[] srList = Database.Update(dataToUpdate,false);
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for (Database.Error e  : sr.getErrors()) {                      
                        failedData.add(new Core_Log_Entry__c(Core_Details__c = e.getMessage() , Core_Message__c = 'Error from  Core_OppApprovalCtrl updating Quote data', Core_Severity__c = 'Info', Core_Origin__c = 'Email_Sending_Process', Core_When__c = System.now()));
                    }
                }
            }
            
            return !failedData.isEmpty() ? 'Success' : JSON.serialize(failedData);
            
        }
        catch (Exception e) {           
            return 'The following error has occurred while updating Opportunity Sales Price data: ' + e.getMessage();
        }
    }
    
    public class checklistWrapper{
        @AuraEnabled
        public List<String> hardStopList = new List<String>();
        @AuraEnabled
        public List<String> softStopList = new List<String>();
        
        @AuraEnabled
        public List<QuoteLineData> quoteLineData = new List<QuoteLineData>();
    }
    
    public class QuoteLineData  {
        
        @AuraEnabled
        public String productNames { get; set; } 
        
        @AuraEnabled
        public Decimal salesPrices { get; set; } 
        
        @AuraEnabled
        public String quoteNumbers { get; set; } 
        
        @AuraEnabled
        public String quoteLineNumbers { get; set; } 
        
        @AuraEnabled
        public Decimal approvedECAPPrices { get; set; } 
        
        @AuraEnabled
        public Id Id { get; set; } 
        
        @AuraEnabled
        public Integer Sequence { get; set; } 
        
        public QuoteLineData(){}
        
        public QuoteLineData(String productName ,String quoteNumber,String quoteLineNumber,Decimal salesPrice,Decimal approvedECAPPrice,Id Id,Integer Sequence ){
            this.productNames = productName;
            this.salesPrices = salesPrice;
            this.quoteNumbers = quoteNumber;
            this.quoteLineNumbers = quoteLineNumber;
            this.approvedECAPPrices = approvedECAPPrice;
            this.Id = Id;
            this.Sequence = Sequence;
            
        }
        
       
    }         
    
    
    
    /*@AuraEnabled
public Integer totalSoftStop;
@AuraEnabled
public Integer totalHardStop;*/
    
    
}