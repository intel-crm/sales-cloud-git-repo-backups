/************
* Name : Core_AAQC_Case_Comment_Controller 
* Author : Nikhil Godhani
* Date Created : 25-October-2018
* Description : This is being used for displaying previous Case Comments on Case Comment Details page view
* Version Updates : 
*   
* Date              By                      User-Story              Details 
* 25-10-18          Nikhil Godhani          US:90414                Edit and NEW BUTTON Override with this VF Page 
* 13-11-18          Nikhil Godhani          US:110974               Add Case Details and status field on Comment Screen
********************/

public with sharing class Core_AAQC_Case_Comment_Controller{

    public Core_AAQC_Case_Comments__c objCaseComment{get;set;}                                      // varaible to view/Edit Case Comment Record
    public Core_AAQC_Commissions_Case__c objCommissionsInquiry{get;set;}                            // varaible to view/Edit Case inquiry Record
    public Case objCase{get;set;}                                                                   // varaible to view/Edit Case status field Record
    public id commissionsInquiryId;                                                                 // varaible to hold case inquiry Id 
    public id caseCommentId{get;set;}                                                               // varaible to check whether page is open in view mode or Edit mode
    public string caseStatus;                                                                       // varaible to check if the case status is changed or not
    public List<Core_AAQC_Case_Comments__c> lstOfCaseComment{get;set;}                              // varaible to display existing case comment records
    public Boolean blnCheckAccess{get;set;}                                                         // variable to control Admin/FAE Field Access
    public String profileName;                                                                      // variable to store logged in users profile name part of US:110974
    public Profile objProfile;                                                                      // variable to store logged in users profil part of US:110974
    
    public Core_AAQC_Case_Comment_Controller(ApexPages.StandardController controller) {
        
        Core_AAQC_Case_Comments__c caseCommentRecord = (Core_AAQC_Case_Comments__c)controller.getRecord();
        CaseCommentId = controller.getId();
        setProfileName();
        
        // Edit Mode, When user edit the existing case comment 
        if(CaseCommentId != null){ 
           
            objCaseComment = [select id,Name,Core_AAQC_Comment__c,Core_AAQC_Commissions_Case__c,CreatedBy.Name,CreatedDate,LastModifiedBy.Name,LastModifiedDate
                                                 from Core_AAQC_Case_Comments__c WHERE id =:CaseCommentId ];
            
            if(objCaseComment!=null && objCaseComment.Core_AAQC_Commissions_Case__c != null)
                commissionsInquiryId = objCaseComment.Core_AAQC_Commissions_Case__c;
        }
        // New Mode, when user create new Case Comment 
        else{
            
            CommissionsInquiryId = caseCommentRecord.Core_AAQC_Commissions_Case__c;
            objCaseComment = new Core_AAQC_Case_Comments__c(Core_AAQC_Commissions_Case__c = CommissionsInquiryId);
        }
        
        if(CommissionsInquiryId != null){
            
            objCommissionsInquiry = [select id,Core_AAQC_Case_Detail__c,Core_AAQC_Status__c,Core_AAQC_Case__c,Core_AAQC_Case__r.Status from Core_AAQC_Commissions_Case__c where id =:CommissionsInquiryId];
            
            // Added as a part of US:110974
            if(objCommissionsInquiry != null){
                objCase = [select id,Status,Core_AAQC_Resolution_Type__c,Core_AAQC_Resolution_Training_Sub_Type__c,Core_AAQC_Resolution_CE_Sub_type__c,Core_AAQC_Cancellation_Reason__c,Core_AAQC_Root_Cause_Category__c 
                                from case where id =:objCommissionsInquiry.Core_AAQC_Case__c];    
                caseStatus = objCase.Status;
            }
            
            lstOfCaseComment = new List<Core_AAQC_Case_Comments__c>([SELECT id,Name,Core_AAQC_Commissions_Case__r.Core_AAQC_Case_Detail__c,Core_AAQC_Comment__c,Core_AAQC_Commissions_Case__c,CreatedBy.Name,LastModifiedBy.Name,CreatedDate,LastModifiedDate
                                                                     FROM Core_AAQC_Case_Comments__c WHERE Core_AAQC_Commissions_Case__c =:CommissionsInquiryId order by LastModifiedDate DESC]);
        }
    }
    
    /*  Method Name : save()
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will save the case comment record and redirect to Case Inquiry details 
    */
    public PageReference save(){ 
        
        PageReference saveRedirect;
        
        try{   
            
            // checked whether case status is updated or not, if it is updated then only update the case object part of US:110974
            if(objCase!= null && Schema.sObjectType.Case.isUpdateable() &&
                                                Schema.sObjectType.Case.isCreateable()){
                system.debug('inside updating case object');
                upsert objCase;
            }
            upsert objCaseComment; 
        }
        catch(System.DMLException e) {
            System.debug(e.getMessage());
            ApexPages.addMessages(e);
            return null;
        }
        //  After successful Save, navigate to the Commission Inquiry page
        saveRedirect = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+commissionsInquiryId);
        saveRedirect.setRedirect(true);
        return saveRedirect;
    }
    
    /*  Method Name : setProfileName
    *   Input Parameters: None
    *   Output Parameters: None  
    *   Author : Nikhil Godhani
    *   Date Created : 13-11-18
    *   Description : This method will check whether logged in user is belog to IT ADMIN Group or not
    */
    private void setProfileName(){
    
        
        objProfile = [Select Name from Profile where Id =: UserInfo.getProfileId() LIMIT 1];
        
        if(objProfile!=null)
        {
            profileName = objProfile.name; 
            
            if(System.Label.Core_AAQC_Triage_Group_Profile.Contains(profileName))
            {
                blnCheckAccess = true;
            }    
            else
            {
                blnCheckAccess = false;      
            }  
        }
        
    }
    
}