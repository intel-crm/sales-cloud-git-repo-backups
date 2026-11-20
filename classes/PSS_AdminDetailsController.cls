//IPA2.0: US-TWC729-7976

/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_AdminDetailsController
* Description : This Class is an apex controller which is called from PSS_AdminReviewPage Component
* Version     : 1.0 
* Created Date: 26-May-2021
* Modification Log :
* Created By  : ONYX Team (Infosys)
********************************************************************************************************************************************************************************************************/
@isTest
public without sharing class PSS_AdminDetailsController {
    
    /**
* Method called when the PSS_AdminReviewPage Component is initialized
* @description-Fetch Suvey Result Details and pass it back to Component
* @param surveyId Id of the Solution for which User Navigated to PSS_AdminReviewPage component
* @return PMP_LightningServerResponse - Class Variables returned back to JS from this Apex controller method
*/
    /*@AuraEnabled(cacheable=true)
    public static PMP_LightningServerResponse  getAdminDetails(Id surveyId) {
        map<string,object> adminDetails = new map<string,object>();
        map<String, Object> mapErrorInfo = new map<string,object>();
        List<PSS_Solutions_Impact_Path_Scoring__c> ple2 = new List<PSS_Solutions_Impact_Path_Scoring__c>();
        ArdiraSurvey__Survey_Result__c currentAdmin = new ArdiraSurvey__Survey_Result__c();
        List<String> plValues = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('ArdiraSurvey__Survey_Result__c');
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('PSS_Programs_Applicable_Nm__c').getDescribe();
        Schema.DescribeFieldResult objFieldInfo2 = objDescribe.fields.getMap().get('PSS_Strategic_Attributes_Nm__c').getDescribe();
        
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> picklistvalues2 = objFieldInfo2.getPicklistValues();
        
        List<String> plValues2 = new List<String>();
        
        //Add the picklist values to list.
        for(Schema.PicklistEntry plv: picklistvalues) {
            plValues.add(plv.getValue());
        }
        plValues.sort();
        
        adminDetails.put('plValues',plValues);
        
        for(Schema.PicklistEntry plv: picklistvalues2) {
            plValues2.add(plv.getValue());
        }
        plValues2.sort();
        
        adminDetails.put('plValues2',plValues2);
        
        
        
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String profileName = profile.Name;
        User user;
        
        if(profileName!=null){
            user=[SELECT Id, Name FROM User where Id=:userinfo.getUserId() Limit 1];
            
        } 
        
        //Get public group members
        Group grp=[SELECT Id FROM Group where DeveloperName='PMP_All_Intel_Admin_Users' LIMIT 1];
        List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
        List<Id> userIds=new List<Id>();
        for (GroupMember groupMember: groupMembers){
            userIds.add(groupMember.UserOrGroupId);
        }
        List<User> admins=[SELECT Id, Name FROM User where Id in :userIds];
        
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()) {
            currentAdmin = [SELECT ArdiraSurvey__Assigned_To_User__c 
                            from ArdiraSurvey__Survey_Result__c 
                            LIMIT 1];
        }
        
        adminDetails.put('loggedInUser',user); 
        adminDetails.put('adminUsers',admins);
        adminDetails.put('currentAdmin',currentAdmin); 
        
        Map<String,String> pickListValuesMap = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = ArdiraSurvey__Survey_Result__c.PSS_Partner_Solution_Lifecycle_Status_Nm__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if (pickListVal.getValue()!= PSS_StaticConstants.DRAFT && pickListVal.getValue()!=PSS_StaticConstants.SOLUTION_CONVERTED_STATUS
                && pickListVal.getValue()!= PSS_StaticConstants.RETIRED){
                    pickListValuesMap.put(pickListVal.getLabel(),pickListVal.getValue());
                }
        }     
        
        Map<String,String> pickListValuesMap2 = new Map<String,String>();
        
        Schema.DescribeFieldResult fieldResult2 = PSS_Solutions_Impact_Path_Scoring__c.GeTm_Admin_Suggested_Select_Benefit__c.getDescribe();
        
        if(Schema.sObjectType.PSS_Solutions_Impact_Path_Scoring__c.isAccessible()){
            
            ple2 = [select id,GeTm_Admin_Suggested_Select_Benefit__r.name from PSS_Solutions_Impact_Path_Scoring__c  LIMIT 49000 ];//Limit added as part of Code scan fixes.
            
        }
        
        for( PSS_Solutions_Impact_Path_Scoring__c    pickListVal : ple2){
            pickListValuesMap2.put(pickListVal.GeTm_Admin_Suggested_Select_Benefit__r.name,pickListVal.GeTm_Admin_Suggested_Select_Benefit__r.name);
        }
        ArdiraSurvey__Survey_Result__c surveyResult = [select id, PSS_AIIP_Score__c,PSS_Company_Id__c,
                                                       PSS_Strategic_Attributes_Nm__c,PSS_Impact_Path_Score__c,
                                                       PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Is_Benefit_Assigned_Ind__c,
                                                       PSS_Programs_Applicable_Nm__c,PSS_System_Suggested_Benefit_Level__c,PSS_Admin_Suggested_Benefit_Level__c,
                                                       ArdiraSurvey__Score_Raw__c, PSS_Follow_up_Date_Dt__c,PSS_System_Suggested_Benefit_Level__r.Name,
                                                       PSS_Review_Scheduled_Date_dt__c,PSS_Admin_Suggested_Benefit_Level__r.Name, PSS_Rejection_Reason_Txt__c 
                                                       from ArdiraSurvey__Survey_Result__c 
                                                       where Id=:surveyId];
        
        adminDetails.put('pickListValuesMap',pickListValuesMap);
        adminDetails.put('pickListValuesMap2',pickListValuesMap2);
        adminDetails.put('surveyResult',surveyResult);
        
        return new PMP_LightningServerResponse(true,mapErrorInfo,adminDetails);
    }*/
    
    /**
* Method called when the user clicks Submit button in PSS_AdminReviewPage Component
* @description-Saves the Value chosen in PSS_AdminReviewPage component
* @param surveyId Id of the Solution for which User Navigated to PSS_AdminReviewPage component
* @param saveMap - Map of Field to its value chosen in PSS_AdminReviewPage component
* @return PMP_LightningServerResponse - Class Variables returned back to JS from this Apex controller method
*/    
    /*@AuraEnabled
    public static String saveAdminDetails(Id surveyId, Map<string,string> saveMap ){
        
        String isBenefitNotTagged = 'yes';
        String errorMsg ='';
        ArdiraSurvey__Survey_Result__c surveyResult = new  ArdiraSurvey__Survey_Result__c();
        
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()) {
            surveyResult = [select id, PSS_AIIP_Score__c,PSS_Conversion_Admin_Log_Details_Txt__c,
                            PSS_Strategic_Attributes_Nm__c,PSS_Is_Benefit_Assigned_Ind__c,PSS_Admin_Suggested_Benefit_Level__r.Id,
                            PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Cancel_Reason_Txt__c ,
                            PSS_Programs_Applicable_Nm__c,PSS_System_Suggested_Benefit_Level__c,PSS_System_Suggested_Benefit_Level__r.Id,PSS_Admin_Suggested_Benefit_Level__c,
                            ArdiraSurvey__Score_Raw__c, PSS_Follow_up_Date_Dt__c,
                            PSS_Review_Scheduled_Date_dt__c,PSS_Company_Id__c,PSS_Intel_Admin_Id__c,PSS_Rejection_Reason_Txt__c
                            from ArdiraSurvey__Survey_Result__c 
                            where id=:surveyId];
        }
        surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c = saveMap.get('PSS_Partner_Solution_Lifecycle_Status_Nm__c');
        
        surveyResult.PSS_Cancel_Reason_Txt__c= saveMap.get('PSS_Cancel_Reason_Txt__c');
        surveyResult.PSS_Rejection_Reason_Txt__c = saveMap.get('PSS_Rejection_Reason_Txt__c');
        if(saveMap.get('PSS_Intel_Admin_Id__c')!=null){
            surveyResult.PSS_Intel_Admin_Id__c = saveMap.get('PSS_Intel_Admin_Id__c');
        }
        if(saveMap.get('PSS_Follow_up_Date_Dt__c')!=null){
            surveyResult.PSS_Follow_up_Date_Dt__c = date.valueof(saveMap.get('PSS_Follow_up_Date_Dt__c'));
        }
        if(saveMap.get('PSS_Review_Scheduled_Date_dt__c')!=null){
            surveyResult.PSS_Review_Scheduled_Date_dt__c = date.valueof(saveMap.get('PSS_Review_Scheduled_Date_dt__c'));
        }
        if(saveMap.get('ArdiraSurvey__Score_Raw__c')!=null){
            surveyResult.ArdiraSurvey__Score_Raw__c = decimal.valueOf(saveMap.get('ArdiraSurvey__Score_Raw__c'));
        }
        
        if(saveMap.get('PSS_Admin_Suggested_Benefit_Level__c') != null){
            PRM_Specialty__c prmSpeciality=[Select id, Name from PRM_Specialty__c where Name=:saveMap.get('PSS_Admin_Suggested_Benefit_Level__c')LIMIT 1];
            surveyResult.PSS_Admin_Suggested_Benefit_Level__c= prmSpeciality.id;
        }
        if(saveMap.get('PSS_System_Suggested_Benefit_Level__c') != null){
            PRM_Specialty__c prmSpeciality1=[Select id, Name from PRM_Specialty__c where Name=:saveMap.get('PSS_System_Suggested_Benefit_Level__c') LIMIT 1];
            surveyResult.PSS_System_Suggested_Benefit_Level__c= prmSpeciality1.id;
        }
        
        surveyResult.PSS_Strategic_Attributes_Nm__c = saveMap.get('PSS_Strategic_Attributes_Nm__c');
        surveyResult.PSS_Programs_Applicable_Nm__c = saveMap.get('PSS_Programs_Applicable_Nm__c');
        
        if(saveMap.get('PSS_Conversion_Admin_Log_Details_Txt__c') != null){
            surveyResult.PSS_Conversion_Admin_Log_Details_Txt__c = String.IsNotBlank(surveyResult.PSS_Conversion_Admin_Log_Details_Txt__c) ? surveyResult.PSS_Conversion_Admin_Log_Details_Txt__c +'\n' + saveMap.get('PSS_Conversion_Admin_Log_Details_Txt__c') + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n' :
            saveMap.get('PSS_Conversion_Admin_Log_Details_Txt__c') + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n';
        }
        String dmlStatus = 'Exception';//
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
            try{
                update surveyResult;
            }Catch(DMLException e){                
                PMP_Utility.logError(e,'PSS_AdminDetailsController');
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages  
                    if(e.getDmlType(i) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION){
                        return 'ValidationError';
                    }
                }
                return dmlStatus;
            }Catch(Exception e){
                PMP_Utility.logError(e,'PSS_AdminDetailsController');
                return dmlStatus;
            }
        }
        
        // Added to fetch the benefit assigned flag and send the response to UI to display warning meassage ---> US941484
        ArdiraSurvey__Survey_Result__c surveyResultAftUpdate = new ArdiraSurvey__Survey_Result__c();
        
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            surveyResultAftUpdate = [SELECT id,PSS_Is_Benefit_Assigned_Ind__c,PSS_Programs_Applicable_Nm__c,
                                     PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Company_Id__c,
                                     PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Admin_Suggested_Benefit_Level__r.Name 
                                     FROM ArdiraSurvey__Survey_Result__c 
                                     WHERE id=:surveyId];
            
        }
        
             //logic to identify partner solution
                Boolean displayBenefitAlert = false; 
                if (surveyResultAftUpdate.PSS_Programs_Applicable_Nm__c != null) {
                    List<String> programs = surveyResultAftUpdate.PSS_Programs_Applicable_Nm__c.split(';');
                    if (programs.size() == 1 && (programs[0] == PSS_StaticConstants.PARTNER_SOLUTION || programs[0] == PSS_StaticConstants.INTEL_SELECT)) {
                        displayBenefitAlert = true;
                    }
                }
                 //logic to identify partner solution
    //Below code added for account benefit tagging sucess message displaying in UI
        if(surveyResultAftUpdate.PSS_Is_Benefit_Assigned_Ind__C && surveyResultAftUpdate.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS && (surveyResultAftUpdate.PSS_Admin_Suggested_Benefit_Level__c != NULL)){
            isBenefitNotTagged ='yes';
            
            errorMsg += surveyResultAftUpdate.PSS_Admin_Suggested_Benefit_Level__r.Name +' '+ System.Label.PSS_Benefit_Assignment_To_Account+ PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n';
        }
        if(!surveyResultAftUpdate.PSS_Is_Benefit_Assigned_Ind__C && surveyResultAftUpdate.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS && !displayBenefitAlert){
            isBenefitNotTagged ='no';
            errorMsg += System.Label.PSS_Conversion_Select_Benefit_Validation_Error+ PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n';
            
        }
        
        if(string.IsNotBlank(errorMsg) && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
            surveyResultAftUpdate.PSS_Conversion_Admin_Log_Details_Txt__c = String.isNotBlank(surveyResultAftUpdate.PSS_Conversion_Admin_Log_Details_Txt__c) ? 
                surveyResultAftUpdate.PSS_Conversion_Admin_Log_Details_Txt__c + '\n' + errorMsg : 
            errorMsg ;
            update surveyResultAftUpdate;
        }
        
        return isBenefitNotTagged;
        
    }*/
    
    
    //added by priyanka --US912153
    /*************************************************************************** 
* Method Name : isDuplicateOffering
* Description : Method to identify duplicate Offerings
*              -1 for duplicate offering within same partner company
*               0 for duplicate offering across the partner exchange
*               1 for non duplicate offering
*               2 for throwing error when MPI record doesn't exist for Solution
* Parameters  : 
*       surveyId - Solution Id to which the User Navigated to PSS_AdminReviewPage component
*       solutionStatus - Status of the Solution to which the User is requesting to change in UI
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
*Sivashankaran Ezhilarasan  29 APRIL 2021           Modified method to have validation logic for US985766 
******************************************************************************/
    
    /*@AuraEnabled
    public static integer isDuplicateOffering(string surveyId, String solutionStatus)
    {
        
        if(solutionStatus == PSS_StaticConstants.SOLUTION_APPROVED_STATUS){ // is status is changed to approved, have the validation in place
            
            
            //to fetch the proposal name and company id  
            ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
            if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){  
                surveyResult = [SELECT id,PSS_Proposal_Name_Txt__c,PSS_OPID_Account_Id__c, PSS_Is_Benefit_Assigned_Ind__c,
                                PSS_Company_Id__c,PSS_Partner_Account_Id__c,ArdiraSurvey__Assigned_To_User__c 
                                from ArdiraSurvey__Survey_Result__c 
                                where id=:surveyId];
            }
            //get the proposal and company id into variable
            
            String strOfferingName ='';
            if(surveyResult.PSS_Proposal_Name_Txt__c!=null){
                strOfferingName=  surveyResult.PSS_Proposal_Name_Txt__c;
                strOfferingName= strOfferingName.trim();}
            String companyId='';
            if(surveyResult.PSS_Company_Id__c!=null){
                companyId=surveyResult.PSS_Company_Id__c;}
            String strPartnerAccnt ='';
            if(surveyResult.PSS_OPID_Account_Id__c!=null){
                strPartnerAccnt = surveyResult.PSS_OPID_Account_Id__c; 
            }   
            
            
            Integer totalCount = 0;//total match offering count
            Integer companyCount = 0; // total match offering count within the same company
            
            //Check whether the Partner Account associated to Solution has any MPI Record (or) not for US985766    
            if(strPartnerAccnt !=NULL && strPartnerAccnt !='')
            {
                Account sPartnerAccntDetails = new Account();
                List<PMP_OPID_MPI_Rel__c> opidMPI = new List<PMP_OPID_MPI_Rel__c>();
                sPartnerAccntDetails = [SELECT Id, Core_IPA_One_Partner_Id__c FROM Account WHERE Id =: strPartnerAccnt];
                 opidMPI =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c,
                            PMP_One_Partner_ID__c FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c = true AND PMP_One_Partner_ID__c =:strPartnerAccnt LIMIT 1];
                
                if(sPartnerAccntDetails.Core_IPA_One_Partner_Id__c != '' && sPartnerAccntDetails.Core_IPA_One_Partner_Id__c != null && (!opidMPI.isEmpty() && opidMPI[0].PMP_Marketing_Profile_Id__c != null))
                {
                    String sOPID = sPartnerAccntDetails.Core_IPA_One_Partner_Id__c;
                    String cmPID = opidMPI[0].PMP_Marketing_Profile_Id__c;
                    List<PMP_Company__c> sMPIRecList = new List<PMP_Company__c>();
                    // List<PMP_OPID_MPI_Rel__c> sMPIRecList = new List<PMP_OPID_MPI_Rel__c>();
                    if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                        */
                        /* sMPIRecList =[select id,Name,Is_Active__c,PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c,
PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c,PMP_One_Partner_ID__c,PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c
FROM PMP_OPID_MPI_Rel__c WHERE Is_Active__c = true AND PMP_One_Partner_ID__c =:sOPID
AND PMP_Marketing_Profile_Id__r.PMP_Benefit_Update_Ind__c = false AND
PMP_Marketing_Profile_Id__r.PMP_Is_Published_Ind__c = true AND 
PMP_Marketing_Profile_Id__r.PMP_Partner_Benefit_Type__c =: PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED];*/ //IPA2.0 - TWC729-7885
                       /* sMPIRecList = [SELECT Id, Name,PMP_One_Partner_ID__c 
                                       from PMP_Company__c 
                                       where PMP_Is_Published_Ind__c=true and 
                                       //PMP_Partner_Benefit_Type__c=:PSS_StaticConstants.SOLUTIONS_MARKETPLACE_ENHANCED and //IPA2.0 - TWC729-7885
                                       Id =: cmPID and PMP_Benefit_Update_Ind__c = false and PMP_Company_Lifecycle_Status_Nm__c ='Published'];//status check added by krishna ch
                    }
                    
                    if(sMPIRecList == null || sMPIRecList.isEmpty())
                    {
                        return 2;
                        
                    }
                }
                else
                {
                    return 2; // OPID doesn't exist and hence Solution not eligible for Conversion
                }
            }
            else
            {
                return 2; // OPID doesn't exist and hence Solution not eligible for Conversion
            }
            
            //check if any offerings exist with the same name - we should validate against working copy
            if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
                
                totalCount = [SELECT count() from PMP_Partner_Offering__c WHERE 
                              (PMP_Partner_Offering_Nm__c = :strOfferingName AND PMP_Working_Copy_Id__c=NULL)]; 
            }
            
            if(totalCount > 0){
                //if companyId is null , means partner will not have offerings as they dont have enhanced benifit
                if(companyId==NULL){
                    return 0;
                }
                else{
                    //check if offering with the same name exist under same partner company
                    if(PMP_Partner_Offering__c.SObjectType.getDescribe().isAccessible()){
                        companyCount = [Select count() from PMP_Partner_Offering__c 
                                        where PMP_Partner_Offering_Nm__c = :strOfferingName and PMP_Company_Id__c = :companyId];
                    }
                    return companyCount > 0 ? -1 : 0 ;
                    
                    
                }
            }
        }
        return 1;// if status is not Approved , good to save the details, no need to check duplicates.
    }*/
    
    
    /*************************************************************************** 
* Description : Method to identify the Intel Admin
*              true if it is a Inte Admin
*              false if it is not a Intel Admin
* @author Sooriya | 6/11/2021 
* @return Boolean
* ****************************************************************************/  
    
    /*@AuraEnabled
    public static Boolean isIntelMPAdmin () {
        Boolean isMPAdmin = false;       
        isMPAdmin = PMP_SearchUtilityController.isIntelAdmin();
        
        return isMPAdmin;
    }*/
    
    
    /*************************************************************************** 
* Description : Main method which will call the PSS_SolutionToOfferingConverter.convertProposal()
*               which will trigger the solution to offering conversion
* @param solutionId Id of the Solution for which User Navigated to PSS_AdminReviewPage component
*         
* @author Sooriya | 6/15/2021 
* ****************************************************************************/  
    
    /*@AuraEnabled
    public static void createOfferingFromSolution (String solutionId) {
        
        String errorMsg='';
        ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
            surveyResult = [SELECT id,PSS_Is_Benefit_Assigned_Ind__c,PSS_Programs_Applicable_Nm__c,
                            PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Company_Id__c,
                            PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                            PSS_Solution_Submitter_UserId_Id__c,ArdiraSurvey__Assigned_To_User__c,
                            PSS_Intel_Admin_Id__c
                            FROM ArdiraSurvey__Survey_Result__c 
                            WHERE id=:solutionId];
        }
        
        //Moved the solution to offering conversion logic from trigger to here
        List<ArdiraSurvey__Survey_Result__c> surveyResultList = New List<ArdiraSurvey__Survey_Result__c>();
        if(surveyResult!= Null && surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_APPROVED_STATUS){
            try{
                surveyResultList.add(surveyResult);
                PSS_SolutionToOfferingConverter.convertProposal(surveyResultList); 
                errorMsg = System.Label.PSS_Offering_Creation_Success + PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n'; 
                createContactEntitlement(solutionId);
            }
            catch(Exception e){
                errorMsg = String.IsNotBlank(errorMsg) ? errorMsg + System.Label.PSS_Technical_Error_Message+ PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n' :
                System.Label.PSS_Technical_Error_Message+ PSS_StaticConstants.LOG_MESSAGE_SEPERATOR + System.Now() + '\n';  
            }
            if(String.IsNotBlank(errorMsg) && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
                ArdiraSurvey__Survey_Result__c solutionUpdate = New ArdiraSurvey__Survey_Result__c (Id=solutionId); 
                solutionUpdate.PSS_Conversion_Admin_Log_Details_Txt__c = String.IsNotBlank(surveyResult.PSS_Conversion_Admin_Log_Details_Txt__c) ? surveyResult.PSS_Conversion_Admin_Log_Details_Txt__c +'\n'+ errorMsg : errorMsg;
                update solutionUpdate;
            }
        }
    }*/
    
    /*************************************************************************** 
* Description : Main method which will call the PSS_ImpactPathScoring_Utility.calculateImpactPathScore() ,
* PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering() methods to Re calculate impact path scoring and
* system suggested benefit,which will trigger from the solution admin review page on Re-evelute button click. 
* @param solutionId Id ,survey map of the Solution
* @author Krishna ch | 7/25/2021 
* ****************************************************************************/  
    
    /*@AuraEnabled
    public static List<ArdiraSurvey__Survey_Result__c> reCalculateImpactPathScoring(Id surveyId, Map<string,string> saveMap ){
        
        ArdiraSurvey__Survey_Result__c surveyResult = new  ArdiraSurvey__Survey_Result__c();
        Map<id,ArdiraSurvey__Survey_Result__c> surveyMap = new Map<id,ArdiraSurvey__Survey_Result__c>();
        List<ArdiraSurvey__Survey_Result__c> resultListToUpdate = new List<ArdiraSurvey__Survey_Result__c>();
        
        
        if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible() && surveyId != NULL) {
            
            surveyResult = [select id, PSS_AIIP_Score__c,PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Impact_Path_Score__c,
                            PSS_Strategic_Attributes_Nm__c,PSS_Is_Benefit_Assigned_Ind__c,
                            PSS_Partner_Solution_Lifecycle_Status_Nm__c,PSS_Cancel_Reason_Txt__c ,
                            PSS_Programs_Applicable_Nm__c,PSS_Solution_Category_Nm__c,PSS_Solution_Revenue_Projection__c,PSS_System_Suggested_Benefit_Level__c,
                            PSS_System_Suggested_Benefit_Level__r.Name,PSS_System_Suggested_Benefit_Level__r.Id,PSS_Admin_Suggested_Benefit_Level__c,
                            PSS_Admin_Suggested_Benefit_Level__r.Name,ArdiraSurvey__Score_Raw__c, PSS_Follow_up_Date_Dt__c,
                            PSS_Review_Scheduled_Date_dt__c,PSS_Company_Id__c,PSS_Intel_Admin_Id__c,PSS_Partner_Account_Id__c,PSS_Rejection_Reason_Txt__c
                            from ArdiraSurvey__Survey_Result__c 
                            where id=:surveyId LIMIT 1];
            
            if(surveyResult != NULL){
                surveyResult.PSS_Strategic_Attributes_Nm__c = saveMap.get('Strategic_Attributes__c');
                if(surveyResult.PSS_Programs_Applicable_Nm__c!=NULL){
                    if(surveyResult.PSS_Programs_Applicable_Nm__c.contains('MRS') || surveyResult.PSS_Programs_Applicable_Nm__c.contains('RRK')){
                        surveyResult.PSS_Solution_Category_Nm__c ='IOTG';
                    }else if (surveyResult.PSS_Programs_Applicable_Nm__c.contains('Intel Select') || surveyResult.PSS_Programs_Applicable_Nm__c.contains('Intel Data Center-Centric Solutions') ){
                        surveyResult.PSS_Solution_Category_Nm__c ='DCG';
                    }else{
                        surveyResult.PSS_Solution_Category_Nm__c=NULL;
                    }
                    surveyResult.PSS_Fail_Fast_Status_Nm__c  = 'Pass';
                }else{
                    surveyResult.PSS_Solution_Category_Nm__c=NULL;
                    surveyResult.PSS_Fail_Fast_Status_Nm__c = 'Fail'; 
                }
                
                
                if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
                    update surveyResult;
                    surveyMap.put(surveyResult.id, surveyResult);
                }
            }
            
            
        }
        if(!surveyMap.isEmpty()){
            resultListToUpdate = PSS_ImpactPathScoring_Utility.calculateImpactPathScore(surveyMap);
            //added code to recalculate benefit level
            resultListToUpdate = PSS_BenefitAssignmentTriggerHelper.convertSolutionToOffering(resultListToUpdate);
        }
        if(!resultListToUpdate.isEmpty()){
            update resultListToUpdate;
        }        
        
        return resultListToUpdate;
    }*/
    
/*************************************************************************** 
* Description : Main method to create Contact Entitlement Record for POE Entitlement to enable Offering Editing for the Solution Submitter 
* which will be invoked from createOfferingFromSolution method and retrigger conversion
* @param solutionId
* @author Divya S | 6/16/2022
* ****************************************************************************/ 
    /*@future
    public static void createContactEntitlement (String solutionId) {
        ArdiraSurvey__Survey_Result__c surveyResult = new ArdiraSurvey__Survey_Result__c();
        Core_Contact_Entitlement__c ccEntitlement = new Core_Contact_Entitlement__c();
        List<Core_Contact_Entitlement__c> updateContactEntitlement = new List<Core_Contact_Entitlement__c>();
        User usr = new User();
        List<Id> adminGroupUserIds = PMP_Utility.intelAdminGrpMembers();
        String partnerUsrContact;

        try{
        surveyResult = [SELECT id,PSS_Is_Benefit_Assigned_Ind__c,PSS_Programs_Applicable_Nm__c,
                        PSS_Conversion_Admin_Log_Details_Txt__c,PSS_Company_Id__c,
                        PSS_Partner_Solution_Lifecycle_Status_Nm__c,
                        PSS_Solution_Submitter_UserId_Id__c,PSS_Solution_Submitter_UserId_Id__r.ContactId,
                        ArdiraSurvey__Assigned_To_User__c,ArdiraSurvey__Assigned_To_User__r.ContactId,PSS_Intel_Admin_Id__c
                        FROM ArdiraSurvey__Survey_Result__c 
                        WHERE id=:solutionId]; 

        //When Admin submits the solution on behalf of Partner then consider Assigned to User field, else Submitter User field
        if(adminGroupUserIds.contains(surveyResult.PSS_Solution_Submitter_UserId_Id__c)) {
            partnerUsrContact = surveyResult.ArdiraSurvey__Assigned_To_User__r.ContactId;
        }
        else{
            partnerUsrContact = surveyResult.PSS_Solution_Submitter_UserId_Id__r.ContactId;
        }
        
        if(surveyResult.PSS_Partner_Solution_Lifecycle_Status_Nm__c == PSS_StaticConstants.SOLUTION_CONVERTED_STATUS && partnerUsrContact != null){
              
                  List<String> entitlementNames = new List<String>();
                  entitlementNames.add(PSS_StaticConstants.ENTITLEMENT_PA);
                  entitlementNames.add(PSS_StaticConstants.ENTITLEMENT_PAD);
                  entitlementNames.add(PSS_StaticConstants.ENTITLEMENT_OE);
                   
                   List<Core_Entitlement__c> entitlementLst = [SELECT Id,Name from Core_Entitlement__c where Name IN :entitlementNames  AND 
                                                    Core_IsActive__c = true];
                   Set<Id> entIds = new Set<Id>();
                   String oe_entitlementId = '';
                   for(Core_Entitlement__c ce : entitlementLst){
                     entIds.add(ce.Id);
                       if(ce.Name == PSS_StaticConstants.ENTITLEMENT_OE){
                           oe_entitlementId = ce.Id;
                       }
                   }
                   
            	   Set<String> statuses = new Set<String>();
            	   statuses.add(PSS_StaticConstants.ENTITLEMENT_STATUS_PENDING);
            	   statuses.add(PSS_StaticConstants.ENTITLEMENT_STATUS_COMPLETE);
            
                   List<Core_Contact_Entitlement__c> conEntLst = [SELECT Id,Core_Entitlement_Id__c,Core_Status__c,Core_Selected__c, Core_Data_Loaded__c 
                                                                  FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c =:partnerUsrContact  
                       									          AND Core_Status__c IN :statuses
                                                                  AND Core_Entitlement_Id__c IN :entIds];
            		
            		//Create new contact entitlement if contact doesn't have any entitlements 
                    if(conEntLst.isEmpty()){
                        ccEntitlement.Core_Contact_Id__c = partnerUsrContact;
                        ccEntitlement.Core_Entitlement_Id__c = oe_entitlementId;
                        ccEntitlement.Core_Selected__c = TRUE;
                        ccEntitlement.Core_Status__c = PSS_StaticConstants.ENTITLEMENT_STATUS_PENDING;
                        ccEntitlement.Core_Data_Loaded__c = TRUE;
                        ccEntitlement.Core_Unique_Id__c = partnerUsrContact+oe_entitlementId;
                        insert ccEntitlement;
                    }
            		//Update existing pending OE Entitlement to retrigger the assignment 
            		else if(conEntLst.size() > 0){
                        for(Core_Contact_Entitlement__c ce : conEntLst){
                            if((ce.Core_Status__c == PSS_StaticConstants.ENTITLEMENT_STATUS_PENDING) && oe_entitlementId.equalsIgnoreCase(ce.Core_Entitlement_Id__c)){
                                ccEntitlement.Id = ce.Id;
                                ccEntitlement.Core_Selected__c = TRUE;
                                ccEntitlement.Core_Status__c = PSS_StaticConstants.ENTITLEMENT_STATUS_PENDING;
                                ccEntitlement.Core_Data_Loaded__c = TRUE;
                                updateContactEntitlement.add(ccEntitlement);
                               
                            }
                        }
                    }
                    if (updateContactEntitlement.size()>0){
                       update updateContactEntitlement;
                    }
            }
      }
      catch(Exception e){
        PMP_Utility.logError(e,'PSS_AdminDetailsController.createContactEntitlement'); 
     }
    }*/
}