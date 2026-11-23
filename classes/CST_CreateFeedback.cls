/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class CST_CreateFeedback {
    
    public class CustomerFeedBackFields    {
        @AuraEnabled
        public String Feedback { get; set; } 
        @AuraEnabled
        public String ReasonForChange { get; set; } 
        @AuraEnabled
        public String NewAcctOwner { get; set; } 
        @AuraEnabled
        public String TeamMembers { get; set; } 
        @AuraEnabled
        public String SalesGroup { get; set; } 
        @AuraEnabled
        public String Coverage { get; set; } 
        @AuraEnabled
        public Id CustomerId { get; set; } 
        @AuraEnabled
        public String FeedbackType { get; set; } 
        @AuraEnabled
        public Id RecordTypeId { get; set; } 
        @AuraEnabled
        public String FeedbackBy { get; set; }  
        @AuraEnabled
        public String NewAccTier { get; set; } //acctier
        
        
    }
    
    public class AccountFeedBackFields    {
        @AuraEnabled
        public String Feedback { get; set; } 
        @AuraEnabled
        public String ReasonForChange { get; set; } 
        @AuraEnabled
        public String NewAcctOwner { get; set; } 
        @AuraEnabled
        public String TeamMembers { get; set; } 
        @AuraEnabled
        public String SalesGroup { get; set; } 
        @AuraEnabled
        public String Coverage { get; set; } 
        @AuraEnabled
        public Id AccountId { get; set; } 
        @AuraEnabled
        public String FeedbackType { get; set; } 
        @AuraEnabled
        public Id RecordTypeId { get; set; } 
        @AuraEnabled
        public List<String> AccCategoryList { get; set; }
        @AuraEnabled
        public String NewAccTier { get; set; } //TWC3123-6732
        
        
    }
    
    
    public class FeedBackFields    {
        @AuraEnabled
        public String feedbackBy { get; set; } 
        @AuraEnabled
        public Boolean showFeedbackBy { get; set; } 
        @AuraEnabled
        public String stageName { get; set; } 
        @AuraEnabled
        public Id recordTypeId { get; set; } 
        @AuraEnabled
        public String objectName { get; set; }
        @AuraEnabled
        public String coverage { get; set; }
        @AuraEnabled
        public List<String> feedbackOptions { get; set; } 
        @AuraEnabled
        public List<String> salesGroupOptions { get; set; } 
        @AuraEnabled
        public Boolean showComp { get; set; } 
         @AuraEnabled
        public List<String> accountTierOptions { get; set; } //TWC3123-6732
    }
    
    public with sharing class CST_CheckPerm{
        public Boolean checkPerm(Id custId,String perm,Id feedbackById){
            Boolean validUser=false;
            List<SPM_Account_Detail__c> acctDetails = new List<SPM_Account_Detail__c>();
            Integer count = 0; 
            if(perm == 'DR' && (FeatureManagement.checkPermission('CST_Director') || FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
                List<AggregateResult> results = [select count(DR__c) from SPM_Account_Detail__c where SPM_Customer_ID__c =:custId];
                count = (Integer)results[0].get('expr0');
                if(count>0 && !FeatureManagement.checkPermission('CST_Regional_Admin')) { //TWC3123-6462 added Regional Admin
                    acctDetails = [select DR__c  from SPM_Account_Detail__c where SPM_Customer_ID__c=:custId];
                    for(SPM_Account_Detail__c u:acctDetails){
                        if(u.DR__c == feedbackById){
                            validUser=true;
                            break;
                        }
                    } 
                    
                }
                else if(FeatureManagement.checkPermission('CST_Director') || FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin')){
                    validUser=true;
                }
            } 
            if(perm == 'VP' && (FeatureManagement.checkPermission('CST_Vice_President') || FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
                List<AggregateResult> results = [select count(VP__c) from SPM_Account_Detail__c where SPM_Customer_ID__c =:custId];
                count = (Integer)results[0].get('expr0');
                if(count>0 && !FeatureManagement.checkPermission('CST_Regional_Admin')) { //TWC3123-6462 added Regional Admin
                    acctDetails = [select VP__c, TA_VP__c  from SPM_Account_Detail__c where SPM_Customer_ID__c=:custId];
                    for(SPM_Account_Detail__c u:acctDetails){
                        if(u.VP__c == feedbackById || u.TA_VP__c == feedbackById) { //TWC3123-6460
                            validUser=true;
                            break;
                        }
                    }
                }
                else if(FeatureManagement.checkPermission('CST_Vice_President') || FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin')) {
                    validUser=true;
                }
            } 
            
            return validUser;
        }
    }
    
    
    @AuraEnabled
    public static Map<Boolean,String> createCustomerFeedback(CustomerFeedBackFields customerFeedback){
        Map<Boolean,String> success = new Map<Boolean,String>();
        SPM_Customer_Feedback__c cf = new SPM_Customer_Feedback__c();
        Boolean isValidUser = true; 
        Id feedbackById;       
        List<User> feedbackBy = [SELECT id from User where email=:customerFeedback.feedbackBy and isActive=true];
        
        if(feedbackBy.size() > 0){
            feedbackById = feedbackBy[0].id;
            
        }
        else{
            success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_Email_Error_FeedbackBy'));
            isValidUser=false;
        }
        List<SPM_Customer_Feedback__c> cstFeedback = [SELECT id from SPM_Customer_Feedback__c where Customer_ID__c=:customerFeedback.CustomerId and Feedback_By__c=:feedbackById and Feedback_Type__c=:customerFeedback.FeedbackType];
        CST_CheckPerm cp = new CST_CheckPerm();
        if(customerFeedback.FeedbackType == 'DR' && !cp.checkPerm(customerFeedback.CustomerId,'DR',feedbackById)){
            success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_DR_Cust'));
            isValidUser=false;
        }
        else if(customerFeedback.FeedbackType == 'VP' && !cp.checkPerm(customerFeedback.CustomerId,'VP',feedbackById)){
            success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_VP_Cust'));
            isValidUser=false;
        }
        if(cstFeedback.size()>0){
            success.put(false,Core_CRM_Utility.getCRMLabel('CST_Add_multiple_feedback_Error'));
            isValidUser=false;
        }
        if(customerFeedback.NewAcctOwner != '') 
        {
            List<User> acctOwner = [SELECT id from User where email=:customerFeedback.NewAcctOwner and isActive=true limit 1];        
            if(acctOwner.size() > 0){
                cf.New_Account_Owner__c = acctOwner[0].Id;
            }
            else{
                isValidUser=false;
                success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_Email_Error_AcctOwner'));
                
            }
            
        }
        
        if(isValidUser){
            if(customerFeedback.FeedbackType == 'DR'){
                cf.DR_Feedback__c = customerFeedback.Feedback;
                cf.Feedback__c = customerFeedback.Feedback;//TWC3123-6350
            }
            else if(customerFeedback.FeedbackType == 'VP'){
                cf.VP_Feedback__c = customerFeedback.Feedback;
                cf.Feedback__c = customerFeedback.Feedback;//TWC3123-6350
            }
            if(customerFeedback.ReasonForChange != '') {cf.Reason_for_change__c = customerFeedback.ReasonForChange;}
            if(customerFeedback.TeamMembers != '') {cf.Team_Members__c = customerFeedback.TeamMembers;}
            if(customerFeedback.SalesGroup != '') {cf.New_Sales_Group__c = customerFeedback.SalesGroup;}
            cf.Coverage_Type__c = customerFeedback.Coverage;
            cf.Customer_ID__c = customerFeedback.CustomerId;
            cf.Feedback_Type__c = customerFeedback.FeedbackType;
            //cf.RecordTypeId = customerFeedback.RecordTypeId;
            cf.Feedback_By__c = feedbackById;
           if(customerFeedback.NewAccTier != '') {cf.CST_New_Account_Level__c = customerFeedback.NewAccTier;}//TWC3123-6732
            
            Database.SaveResult srList = Database.insert(cf, false);

            if(srList.isSuccess() && (customerFeedback.Feedback=='Change Ownership' || customerFeedback.Feedback=='Partial' || customerFeedback.Feedback=='Add to Intel Covered' || customerFeedback.Feedback=='Change Account Level')){//TWC3123-5894
                success.put(true,Core_CRM_Utility.getCRMLabel('CST_Nonpropogated_Feedback_Error'));
            }
            else if (srList.isSuccess() && (customerFeedback.Feedback=='Change to Indirect Covered' || customerFeedback.Feedback=='Change to Not Covered' /*|| customerFeedback.Feedback=='Change to Other Led'*/)){//TWC3123-5894
                success.put(true,'');
            }
            else{
                //system.debug('error:'+srList.getErrors());
                success.put(false,Core_CRM_Utility.getCRMLabel('CST_Save_Error'));
            }
        }
        return success;
        
    }
    public static void InsertFeedbackId(Id acctId,String stage){
        SPM_Account_Detail__c ad = new SPM_Account_Detail__c();
        ad.Id=acctId;
        Id feedbackId = [select id from SPM_Account_Feedback__c where Account_ID__c =:acctId and Feedback_Type__c=:stage][0].Id;
        ad.Feedback_Id__c = feedbackId;
        
        update ad;
    }
    
    @AuraEnabled
    public static Map<Boolean,String> createAccountFeedback(AccountFeedBackFields acctFeedback){
        Map<Boolean,String> success = new Map<Boolean,String>();
        Boolean isValidUser = true;
        List<SPM_Account_Feedback__c> actFeedback = [SELECT id,Account_ID__r.SPM_Customer_ID__c from SPM_Account_Feedback__c where Account_Id__c=:acctFeedback.AccountId and Feedback_Type__c=:acctFeedback.FeedbackType];
        List<SPM_Account_Detail__c> actDetail = [SELECT SPM_Customer_ID__c,DR__c,VP__c,TA_VP__c from SPM_Account_Detail__c where Id=:acctFeedback.AccountId];
        Id custId = actDetail[0].SPM_Customer_ID__c;
        Id acctFeedbackBy = UserInfo.getUserId();
        Id dr = actDetail[0].DR__c;
        Id vp = actDetail[0].VP__c;
        Id taVP = actDetail[0].TA_VP__c; //TWC3123-6460
        
        SPM_Account_Feedback__c af = new SPM_Account_Feedback__c();
        
        String query = 'SELECT id from SPM_Customer_Feedback__c where Customer_ID__c =:custId';
        if((acctFeedback.FeedbackType == 'DR' && dr != null )&& !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
            
            query=query + ' and Feedback_By__c=:dr';
        }
        else if((acctFeedback.FeedbackType == 'DR' && dr == null ) && !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
            
            query=query + ' and Feedback_By__c=:acctFeedbackBy';
        }
        else if((acctFeedback.FeedbackType == 'VP' && (vp != null || taVP!= null)) && !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
            
            //TWC3123-6460
            if(acctFeedbackBy == vp && vp!=null){
                query=query + ' and Feedback_By__c=:vp';
            }
            else if(acctFeedbackBy == taVP && tavp!=null){
                query=query + ' and Feedback_By__c=:taVP';
            }
        }
        else if((acctFeedback.FeedbackType == 'VP' && vp == null) && !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
            
            query=query + ' and Feedback_By__c=:acctFeedbackBy';
        }
        
        //Query customer Feedback to check any Feedback is present or not
        
        /*if(!(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))){
             query=query + ' and Feedback_By__c=:acctFeedbackBy';
         }*/
        List<SPM_Customer_Feedback__c> cstFeedback = Database.query(query);  
        if(cstFeedback.size()== 0){
            success.put(false,Core_CRM_Utility.getCRMLabel('CST_Cust_level_feedback_first_Error'));
            isValidUser=false;
        }
        else{
            af.Feedback__c = acctFeedback.Feedback;
            if(acctFeedback.ReasonForChange != '') {af.Reason_for_change__c = acctFeedback.ReasonForChange;}
            if(acctFeedback.FeedbackType == 'DR' && (actDetail[0].DR__c != null && (actDetail[0].DR__c != UserInfo.getUserId() && !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))))){
                success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_DR_Acct'));
                isValidUser=false;
            }
            //TWC3123-6460
            else if(acctFeedback.FeedbackType == 'VP' && ((actDetail[0].VP__c != null || actDetail[0].TA_VP__c != null) && (!(actDetail[0].VP__c == UserInfo.getUserId() || actDetail[0].TA_VP__c == UserInfo.getUserId()) && !(FeatureManagement.checkPermission('CST_Super_Admin') || FeatureManagement.checkPermission('CST_Regional_Admin'))))){
                success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_VP_Acct'));
                isValidUser=false;
            }
            if(actFeedback.size()>0){
                success.put(false,Core_CRM_Utility.getCRMLabel('CST_Add_multiple_feedback_Error'));
                isValidUser=false;
            }
            
            if(acctFeedback.NewAcctOwner != '') 
            {
                List<User> acctOwner = [SELECT id from User where email=:acctFeedback.NewAcctOwner and isActive=true limit 1];        
                if(acctOwner.size() > 0){
                    af.New_Account_Owner__c = acctOwner[0].Id;
                }
                else{
                    isValidUser=false;
                    success.put(false,Core_CRM_Utility.getCRMLabel('CST_Valid_Email_Error_AcctOwner'));
                    
                }
                
            }
            
            if(acctFeedback.TeamMembers != '') {af.Team_Members__c = acctFeedback.TeamMembers;}
            if(acctFeedback.SalesGroup != '') {af.New_Sales_Group__c = acctFeedback.SalesGroup;}
            //af.Coverage_Type__c = acctFeedback.Coverage;
            af.Account_ID__c = acctFeedback.AccountId;
            af.Feedback_Type__c = acctFeedback.FeedbackType;
            af.RecordTypeId = acctFeedback.RecordTypeId;
            if(acctFeedback.NewAccTier != '') {af.CST_New_Account_Level__c = acctFeedback.NewAccTier;}//TWC3123-6732
            
            string accountCategoryValues='';
            if(acctFeedback.AccCategoryList!=null){
                for(String accCat:acctFeedback.AccCategoryList){
                    accountCategoryValues += accCat+';';
                }
            }
            af.CRM_CST_New_Core_Account_Category__c = accountCategoryValues;
            if(isValidUser){
                Id cstId = [Select SPM_Customer_ID__c from SPM_Account_Detail__c where Id=:af.Account_ID__c][0].SPM_Customer_ID__c;
                Database.SaveResult srList = Database.insert(af, false);
                if(srList.isSuccess()){
                    success.put(true,'');
                    InsertFeedbackId(af.Account_ID__c,af.Feedback_Type__c);
                }
                else{
                    success.put(false,Core_CRM_Utility.getCRMLabel('CST_Save_Error'));
                }
            }
        }
        return success;
        
    }
    
    public static FeedBackFields getCustomerDetailsFormat(Id recordId){
        FeedBackFields ff = new FeedBackFields();
        
        List<String> feedbackOptions = new List<String>();
        List<String> salesGroupOptions = new List<String>();
        List<String> accountTierOptions = new List<String>();//TWC3123-6732
        Id recordTypeId;
        Schema.DescribeFieldResult fieldDescribe2 = Schema.getGlobalDescribe().get('SPM_Customer_Feedback__c').getDescribe().fields.getMap().get('New_Sales_Group__c').getDescribe();
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('SPM_Customer_Feedback__c').getDescribe().fields.getMap().get('DR_Feedback__c').getDescribe();
        Schema.DescribeFieldResult fieldDescribeAccTier = Schema.getGlobalDescribe().get('SPM_Customer_Feedback__c').getDescribe().fields.getMap().get('CST_New_Account_Level__c').getDescribe();//TWC3123-6732
       
        SPM_Customer_Category__c cd = [select Customer_Detail__r.RCStage__c, Coverage__c  from SPM_Customer_Category__c WHERE Customer_Detail__c=:recordId LIMIT 1];
        
        if(cd.Customer_Detail__r.RCStage__c == 'DR' || cd.Customer_Detail__r.RCStage__c == 'VP'){
            //recordTypeId = Schema.SObjectType.SPM_Customer_Feedback__c.getRecordTypeInfosByName().get('DR Feedback').getRecordTypeId();
            ff.showComp = CST_CreateFeedback.showCustComponent(recordId);
        }
        if( FeatureManagement.checkPermission('CST_Regional_Admin') ||  FeatureManagement.checkPermission('CST_Super_Admin')){
            ff.showFeedbackBy = true;
        }
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            feedbackOptions.add(entry.getLabel()+'|'+ entry.getLabel());
        }
        for (Schema.PicklistEntry entry : fieldDescribe2.getPicklistValues()) {
            salesGroupOptions.add(entry.getLabel()+'|'+ entry.getLabel());
        }
        //TWC3123-6732 start
        for (Schema.PicklistEntry entry : fieldDescribeAccTier.getPicklistValues()) {
            accountTierOptions.add(entry.getLabel()+'|'+ entry.getLabel());
        }
        //TWC3123-6732 end
        ff.coverage = cd.Coverage__c;  
        
        ff.objectName = 'SPM_Customer_Detail__c';
        ff.stageName = cd.Customer_Detail__r.RCStage__c;
        ff.feedbackOptions = feedbackOptions;
        ff.salesGroupOptions = salesGroupOptions;
        ff.feedbackBy = System.UserInfo.getUserEmail();
        ff.accountTierOptions = accountTierOptions;//TWC3123-6732
        return ff;
    }
    
    public static FeedBackFields getAccountDetailsFormat(Id recordId){
        FeedBackFields ff = new FeedBackFields();
        List<String> feedbackOptions = new List<String>();
        List<String> accTierOptions = new List<String>();//acc tier
        Id recordTypeId;
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get('SPM_Account_Feedback__c').getDescribe().fields.getMap().get('Feedback__c').getDescribe();
        Schema.DescribeFieldResult fieldDescribeAccTier = Schema.getGlobalDescribe().get('SPM_Account_Feedback__c').getDescribe().fields.getMap().get('CST_New_Account_Level__c').getDescribe();//acc tier
        SPM_Account_Detail__c ad = [SELECT SPM_Customer_ID__c FROM SPM_Account_Detail__c WHERE Id=:recordId LIMIT 1];
        SPM_Customer_Category__c cd = [select Customer_Detail__r.RCStage__c, Coverage__c  from SPM_Customer_Category__c WHERE Customer_Detail__c=:ad.SPM_Customer_ID__c LIMIT 1];
        
        if(cd.Customer_Detail__r.RCStage__c == 'DR'){
            ff.stageName = cd.Customer_Detail__r.RCStage__c;
            ff.showComp = true;
            recordTypeId = Schema.SObjectType.SPM_Account_Feedback__c.getRecordTypeInfosByName().get('DR Feedback').getRecordTypeId();
        }
        else if(cd.Customer_Detail__r.RCStage__c == 'VP'){
            ff.stageName = cd.Customer_Detail__r.RCStage__c;
            ff.showComp = CST_CreateFeedback.showAcctComponent(recordId);
            recordTypeId = Schema.SObjectType.SPM_Account_Feedback__c.getRecordTypeInfosByName().get('VP Feedback').getRecordTypeId();
            
        }
        
        
        fieldDescribe = Schema.SObjectType.SPM_Account_Feedback__c.fields.getMap().get('Feedback__c').getDescribe();
        for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
            feedbackOptions.add(entry.getLabel()+'|'+ entry.getLabel());
        }
        //TWC3123-6732 start
        for (Schema.PicklistEntry entry : fieldDescribeAccTier.getPicklistValues()) {
            accTierOptions.add(entry.getLabel()+'|'+ entry.getLabel());
        }
        //TWC3123-6732 end
        if(cd.Coverage__c=='Intel Covered'){
            ff.coverage = 'Intel Covered';//TWC3123-5894
        }
        else{
            ff.coverage = 'Indirect Covered';//TWC3123-5894
        }
        ff.objectName = 'SPM_Account_Detail__c';
        
        ff.feedbackOptions = feedbackOptions;
        ff.recordTypeId=recordTypeId;
        ff.accountTierOptions = accTierOptions;//TWC3123-6732
        return ff;
    }   
    
    public static Boolean showCustComponent(Id recordId){
        Boolean show=false;
        //VP form not visible to other VP bug fix start
        String loggedinVPId = UserInfo.getUserId();
        Boolean feedbackExistForVP= false;
        Boolean drFeedbackExist= false;
        //bug fix end
        SPM_Customer_Detail__c cd = [select Core_Regional_Customer_Id__r.Core_Starting_Stage__c, Core_Regional_Customer_Id__r.Stage__c from SPM_Customer_Detail__c where id=:recordId][0];
        List<SPM_Customer_Feedback__c> cf = [select DR_Feedback__c, VP_Feedback__c,Feedback_By__c from SPM_Customer_Feedback__c where Customer_ID__c =:recordId];
        //bug fix start 
        if(cf.size()>0){
            for(SPM_Customer_Feedback__c customerFeedback:cf){
                if(customerFeedback.Feedback_By__c == loggedinVPId && customerFeedback.DR_Feedback__c!=null){
                    feedbackExistForVP = true;
                }
                if(customerFeedback.DR_Feedback__c!=null){
                    drFeedbackExist = true;
                }
            }       
        }
        //bug fix end
        if(cd.Core_Regional_Customer_Id__r.Stage__c == 'DR'){
            show=true;
        }
        else if(cd.Core_Regional_Customer_Id__r.Stage__c == 'VP' && ((cf==null || cf.size()==0) || (cf.size()>0 && !feedbackExistForVP && !drFeedbackExist) ) ){//bug fix added 
            show=true;
        }
        return show;
    }
    
    public static Boolean showAcctComponent(Id recordId){
        Boolean show=false;
        List<SPM_Account_Feedback__c> af = [select Feedback__c from SPM_Account_Feedback__c where Account_ID__c =:recordId];
        if(af==null || af.size()==0){
            show=true;
        }
        return show;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getAccountCategoryValues() {
        List<Schema.PicklistEntry> entries = SPM_Account_Feedback__c.CRM_CST_New_Core_Account_Category__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
            Map<String, String> valueMap = new Map<String, String>();
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
            values.add(valueMap);
        }
        return values;
    }
    
    @AuraEnabled(cacheable=true)
    public static FeedBackFields getEmbeddingObjectDetails(Id recordId){
        FeedBackFields ff = new FeedBackFields();
        
        
        if(recordId.getSObjectType().getDescribe().getName() == 'SPM_Customer_Detail__c'){
            
            ff = getCustomerDetailsFormat(recordId);
            
        }
        else if(recordId.getSObjectType().getDescribe().getName() == 'SPM_Account_Detail__c'){
            ff = getAccountDetailsFormat(recordId);
        }
        
        return ff;
    }
    
    @InvocableMethod(label='Update Feedback stage')
    public static void updateOpportunities(List<Id> regionalId) {  
        List<SPM_Regional_Customer__c> regionalView = [select id,stage__c from SPM_Regional_Customer__c where id IN: regionalId];
        String queryAccountFeedback =  'select id,Account_ID__r.SPM_Customer_ID__r.Core_Regional_Customer_Id__c,Feedback_Type__c,RecordTypeId from SPM_Account_Feedback__c where Account_ID__r.SPM_Customer_ID__r.Core_Regional_Customer_Id__c  IN: regionalId';
        String queryCustomerFeedback = 'select id,Feedback_Type__c, Customer_ID__r.Core_Regional_Customer_Id__c from SPM_Customer_Feedback__c where Customer_ID__r.Core_Regional_Customer_Id__c  IN: regionalId';
        Map<Id,SPM_Regional_Customer__c>   regionalData =  new Map<Id,SPM_Regional_Customer__c>(regionalView);
        
        
        
        //SPM_FeedbackStageUpdate batchAccountUpdate = new SPM_FeedbackStageUpdate('SPM_Account_Feedback__c',queryAccountFeedback,regionalData);
        //Database.executeBatch(batchAccountUpdate,100);
        SPM_FeedbackStageUpdate batchCustomerUpdate = new SPM_FeedbackStageUpdate('SPM_Customer_Feedback__c',queryCustomerFeedback,regionalData);
        Database.executeBatch(batchCustomerUpdate,100);
        
    }
    
}