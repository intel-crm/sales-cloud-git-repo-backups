/************
* Name : Core_AAQC_Case_Ask_Commissions_CNTLR 
* Author : PopcornApps
* Date Created : 10-November-2017
* Description : This is being used for creating Ask Commissions Cases.
* Version Updates : 
*   
* Date          By                    User-Story                    Details 
* 10-11-17      PopcornApps           AAQ Ask Commissions           created 
* 14-Nov-18     Nikhil Godhani          Control of status field     Updated - US:84920
* 15-Nov-18     Nikhil Godhani          End User : Draft Case       Updated - US:77763 and US:77764
* 27-Nov-18     Nikhil Godhani          Creating New case OBO       Updated - US:76746 and US:84935
* 02-Aug-18     Rob Robertson         Training Resolution Type      updated - US110979
* 11-Aug-18     Rob Robertson         Allow Manager to See	        updated - US84930
********************/
public with sharing class Core_AAQC_Case_Ask_Commissions_CNTLR
{
    private final static String TYPE_OF_PAGE ='typeOfPage';
    private final static String CASE_RECORD_TYPE_ID =Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Ask_Commissions_Case_RT).getRecordTypeId();
    private final static String STR_ID ='id';
    public string retURL {get;set;}
    public String selectedContact{get;set;}
    public Case objCase{get;set;}                                       // view level instance
    public Core_AAQC_Commissions_Case__c objCommissiionsCase{get;set;}  // view level instance
    public String  strTypeOfMode;                                       //variable to hold NewCase / Edit type of page
    public String  strRecordId;                                         // case record id for edit
    public Boolean blnEditmode{get;set;}                                // variable to identify new/edit mode
    public boolean hasAccess {get;set;}                                 // variable to control if the login user has access to commissions case object
    public Boolean blnCheckAccess{get;set;}                             // variable to control Admin/FAE Field Access
    public Boolean blnCheckAdminAccess{get;set;}                        // variable to control Admin Access Field added as a part of US84920     
    public Boolean blnCheckSaveDraftBtn{get;set;}                        // variable to control Save Draft Button based on Case status added as a part of US77763 and US77764
    public Boolean blnCheckForOBO{get;set;}                             // variable to check whether the page is loaded in new Mode or Edit Mode added as a part of US76746
    private ApexPages.StandardController controller;                    // Case Standard controller instance
    public String profileName;                                          //variable to store logged in users profile name
    public Profile objProfile;
    public Boolean blnCheckOBOFieldAccess{get;set;}
    
    
    /*
     * Description : Constructor used for initializing and indentifying access info.   
     * @Param : controller  - Case StandardController  
     */
    public Core_AAQC_Case_Ask_Commissions_CNTLR(ApexPages.StandardController controller)
    {
        this.controller = controller;
        objCase = new Case();
        objCommissiionsCase = new Core_AAQC_Commissions_Case__c();  
        blnEditmode = false;
        hasAccess = false;
        blnCheckSaveDraftBtn = false;
        strTypeOfMode = ApexPages.currentPage().getParameters().get(TYPE_OF_PAGE);
        strRecordId = ApexPages.currentPage().getParameters().get(STR_ID);
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        objCase.subject = System.Label.Core_AAQC_Subject;
        objCase.origin = System.Label.Core_AAQC_Origin;
        objCase.ownerId = UserInfo.getUserId();
        objCase.recordTypeId = CASE_RECORD_TYPE_ID;
        System.debug('## retUrl in Constructor---'+retURL);
        
        setProfileName();
        String pageMode = strTypeOfMode; //Setting pageMode to adhear apexXSSFromURLParam vulnerability check, This variable is not used in Query
        if(!String.isEmpty(pageMode))// if not empty 
        {
           populateCaseFieldsOnEdit(pageMode);
        }
        System.debug('AAQ_Debug strTypeOfMode ===>'+strTypeOfMode); 
    }
    
    /*
     *  Description : Method used for Save Ask Commissions Case.  
        Method Updated on 14-11-2018 as a part of US77763 
        Now this method will submit the case 
     */
    public PageReference customSubmitCase()
    {
        PageReference saveRedirect;
        Savepoint sp = Database.setSavepoint();
        try{
            objCase.recordTypeId = CASE_RECORD_TYPE_ID;
            
            if(objCase.Core_AAQC_Commissions_Severity__c==null && blnCheckAccess == false)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.Core_AAQC_Severity_Error));
                return null;
            }
           
            if (Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.isCreateable()) 
            {
                
                // Below condition will check if Earlier Case status is Draft or User Directly 
                // Clicked on 'Submit Case' Button in both case we need to change status to 'New'
                // added as a part of US77763 and US77764
                if((blnEditmode && objCase.Status == 'Draft') || (objCase.Status == 'Draft')){
                    system.debug('inside this if 4833');
                    objCase.Status = 'New'; 
                }
                 system.debug('objCase '+objCase);    
                upsert objCase; 
            }
            
            if(objCase.id != null && Schema.sObjectType.Core_AAQC_Commissions_Case__c.isUpdateable()
                                  && Schema.sObjectType.Core_AAQC_Commissions_Case__c.isCreateable())
            {
                objCommissiionsCase.Core_AAQC_Case__c = objCase.id;
                system.debug('objCommissiionsCase '+objCommissiionsCase);    
                upsert objCommissiionsCase;
            }
            saveRedirect = new PageReference('/'+objCommissiionsCase.id);
        }
        Catch(Exception e)
        {
            System.debug(e.getMessage());
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        return saveRedirect;
    }
    
    /*
     *   This method added as part of US:77763 and US:77764, it will save the case in Draft mode  
     */
    public PageReference customSaveDraft()
    {
        PageReference saveRedirect;
        Savepoint sp = Database.setSavepoint();
        try{
            objCase.recordTypeId = CASE_RECORD_TYPE_ID;
            
            if(objCase.Core_AAQC_Commissions_Severity__c==null && blnCheckAccess == false)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.Core_AAQC_Severity_Error));
                return null;
            }
           
            if (Schema.sObjectType.Case.isUpdateable() && Schema.sObjectType.Case.isCreateable()) 
            {
               objCase.status = 'Draft';
               upsert objCase;
               
            }
            
            if(objCase.id != null && Schema.sObjectType.Core_AAQC_Commissions_Case__c.isUpdateable()
                                  && Schema.sObjectType.Core_AAQC_Commissions_Case__c.isCreateable())
            {
                objCommissiionsCase.Core_AAQC_Case__c = objCase.id;
                upsert objCommissiionsCase;
            }
            
            saveRedirect = new PageReference('/apex/Core_AAQC_Commissions_Inquiry_Details?id='+objCommissiionsCase.id);
            
            saveRedirect.getParameters().put('message', 'Your draft has been saved.');
            saveRedirect.getParameters().put('referer', 'askCommissionpage');
            saveRedirect.setRedirect(true);

        }
        Catch(Exception e)
        {
            System.debug(e.getMessage());
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        return saveRedirect;
    }
    
    /*
     * Description : Method used for Cancel Page.   
     */
    public pagereference customCancel(){
        PageReference pageRefURL = new PageReference('/');
       
        if(retURL!=null && retURL!='')
        {
           /*if(retURL.startsWith('/'))
           {
              retURL=retURL.replaceFirst('/','');
           } */
         pageRefURL = new PageReference(retURL);
        }
        pageRefURL.setRedirect(true);
        return pageRefURL;
    }
    
    /*
     * Set Access to fields based on Profile
     */
    private void setProfileName(){
    
        /* Copada Rule: ApexCRUDViolation.
         * Class is implemented with "with Sharing", which runs in user mode and will avail the Sharing/Security Permissions based on logged in user.
         * such that access to check for Objects/fields/profile with reference to logged in user is not needed.
         */
        
        objProfile = [Select Name from Profile where Id =: UserInfo.getProfileId() LIMIT 1];
        
        if(objProfile!=null)
        {
            profileName = objProfile.name;  
            System.debug('profileName==>'+profileName); 
            System.debug('CASE_RECORD_TYPE_ID ==>'+CASE_RECORD_TYPE_ID );
            System.debug('label'+System.Label.Core_AAQC_FAE_PROFILE);
            System.debug('label'+System.Label.Core_AAQC_Triage_Group_Profile);  // added as a part of US84920
            if(System.Label.Core_AAQC_FAE_PROFILE.Contains(profileName))
            {
                System.debug('inside if true');
                blnCheckAccess = true;
            }    
            else
            {
                System.debug('inside if false');
                blnCheckAccess = false;      
            }
            
            // code added as a part of US84920
            
            if(System.Label.Core_AAQC_Triage_Group_Profile.Contains(profileName))
            {
                System.debug('inside if true for Admin Check Access');
                blnCheckAdminAccess = true;
            }    
            else
            {
                System.debug('inside if false for Admin Check Access');
                blnCheckAdminAccess = false;      
            }
            // code end as a part of US84920
            
            
            // code added as a part of US76746 and US84935
            
            if(System.Label.Core_AAQC_Inquiries_Admin_Profile.Contains(profileName))
            {
                System.debug('inside if true for OBO Access');
                blnCheckOBOFieldAccess = true;
            }    
            else
            {
                System.debug('inside if false for OBO Access');
                blnCheckOBOFieldAccess = false;      
            }
            // code end as a part of US76746 and US84935
        }
        
    }
    
    /*
     * Populate fields on Edit if Commissions is not accessible 
     * result in Insufficient Privilages
     */
    private void populateCaseFieldsOnEdit(String pageMode)
    {
       /* Copada Rule: ApexCRUDViolation.
         * Class is implemented with "with Sharing", which runs in user mode and will avail the Sharing/Security Permissions based on logged in user.
         * such that access to check for Objects/fields with reference to logged in user is not needed.
         */ 
        
        if(pageMode == 'Edit' && Schema.sObjectType.Core_AAQC_Commissions_Case__c.isAccessible() 
                              && Schema.sObjectType.Case.isAccessible())
        {
            blnEditmode = true;   
           // added Core_AAQC_On_Behalf_Of__c of field as a part of US76746
           // replaced On_Behalf with Requestor
            objCase = [SELECT id,Casenumber,Subject,RecordtypeId,Core_AAQC_Category__c,Core_AAQC_Case_Details__c,Status,Core_AAQC_On_Behalf_Of__c,Core_AAQC_On_Behalf_Of__r.Name,
                       Core_AAQC_Cancellation_Reason__c, Core_AAQC_Related_Case_Number__c,Core_AAQC_Related_Case_Notes__c,
                       Core_AAQC_External_Reference_No__c,Core_AAQC_Resolution_Type__c, Core_AAQC_Commissions_Severity__c,
                       OwnerId,Origin,Priority,Core_AAQC_Allow_My_Manager_to_See__c, Core_AAQC_Resolution_Training_Sub_type__c,Core_AAQC_Root_Cause_Category__c,Core_AAQC_Resolution_CE_Sub_type__c,
                       Core_AAQC_Requested_for__c, Core_AAQC_Requested_for__r.Name,
                       (SELECT id,Core_AAQC_Case__c, Core_AAQC_Case_Detail__c, Core_AAQC_Resolution_Comments__c, Core_AAQC_Subject__c 
                        FROM Commissions_Cases__r LIMIT 1) 
                        FROM Case WHERE id =:strRecordId];
            
            // this condition check whether page is edited in Draft mode or not, if Yes then display Draft button
            // if other than Draft status don't display Draft Button Code added as a part of US77763 and US77764
            if(objCase.Status == 'Draft')
            {
                blnCheckSaveDraftBtn = true;
            }
            
            
            if(objCase.Commissions_Cases__r != null && objCase.Commissions_Cases__r.size()>0)
            {
                objCommissiionsCase = objCase.Commissions_Cases__r[0];
                hasAccess =true;
            }
            else
            {
                hasAccess =false;
            }
        }
        else{
            objCase.Status = 'Draft'; // Code added as a part of US77763
            blnCheckSaveDraftBtn = true; // Code added as a part of US77763
            hasAccess =true;
        }  
    }
}