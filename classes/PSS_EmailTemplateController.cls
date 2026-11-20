/*******************************************************************************************************************************************************************************************************
* Class Name  : PSS_EmailTemplateController
* Description : Contains the methods that are used for Solution visualforce Templates
* Version     : 1.0 
* Created Date: 10-Feb-2021
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
//IPA2.0: US-TWC729-7976
@isTest 
public without sharing class  PSS_EmailTemplateController {
    /*//this list will be populated in PSS_SendEmailToContactsOnAddOrRemove class to populate the contact details.
    public static List<PSS_Solution_Contact_Association__c> sharedContactsListToProcess= new List<PSS_Solution_Contact_Association__c>();
    
    public Id solutionId {get;set;} // this variable would be reffered in vf component
    //public Id contactAssociationId {get;set;} // this variable would be reffered in vf component
    public String loginHomePageURL; // this variable would be reffered in vf component
    
    public String headerMessage {get;set;}
    public ArdiraSurvey__Survey_Result__c solutionData; // this variable will be used in vf component
    public PSS_Solution_Contact_Association__c associationData; //this variable will be used in vf component
    public List<ArdiraSurvey__Survey_Result__c> solutionDataToBeDisplayed = new List<ArdiraSurvey__Survey_Result__c>();
    public List<PSS_Solution_Contact_Association__c> associationDataToBeDisplayed = new List<PSS_Solution_Contact_Association__c>();
    public PSS_EmailTemplateController(){}
    //method to fetch the solutionPreviewURL
    public String solutionPreviewURL;
    public String getSolutionPreviewURL() {
        solutionPreviewURL=getCommunityURL('Marketplace_Community_Name');// fetch community URL
        solutionPreviewURL  = solutionPreviewURL + PMP_Utility.getValue('PSS_View_Solution');
        return solutionPreviewURL;
    }   
    Public String getLoginHomePageURL(){
        loginHomePageURL=getCommunityURL('Marketplace_Community_Name');
        return loginHomePageURL;
    }
    //method to fetch the createSolutionURL
    public String createSolutionURL;
    public String getCreateSolutionURL(){
        createSolutionURL=getCommunityURL('Marketplace_Community_Name');// fetch community URL
        createSolutionURL = createSolutionURL + PMP_Utility.getValue('PSS_Create_Solution_URL');
        return createSolutionURL ;
    }
    
    //method to fetch the editSolutionURL
    public String editSolutionURL;
    public String getEditSolutionURL() {
        
        editSolutionURL=getCommunityURL('Marketplace_Community_Name');// fetch community URL
        editSolutionURL  = editSolutionURL + PMP_Utility.getValue('PSS_Edit_Solution_URL');
        
        return editSolutionURL;
    } 
    //Start Below method added by Krishna to fetch the offering URL and used in email template.
    //method to fetch the OfferingURL
    public String getOfferingURL;
    public String getPublishedOfferingURL;
    public String getOfferingId;
    public String getPublishedOfferingId;
    public String getOfferingURL() {
        getOfferingURL = getCommunityURL('Marketplace_Community_Name');// fetch community URL
        getOfferingId  = getSolutionData().PSS_Offering_Id_Txt__c;
        getOfferingURL = getOfferingURL + PMP_Utility.getValue('View_Offering_URL') +getOfferingId;
        return getOfferingURL;
    } 
     //method to fetch the published OfferingURL
     public String getPublishedOfferingURL() {
        getPublishedOfferingURL = getCommunityURL('Marketplace_Community_Name');// fetch community URL
        getPublishedOfferingId  = getSolutionData().PSS_Partner_Offering__r.PMP_Published_Copy_Id_Txt__c + '?Lang=NA';  
        getPublishedOfferingURL = getPublishedOfferingURL + PMP_Utility.getValue('View_Offering_URL') +getPublishedOfferingId;
        return getPublishedOfferingURL;
    } 
    
    //method to fetch the editSolutionURL
    public String companyURL;
    public String getcompanyURL() {
        
        companyURL=getCommunityURL('PSS_IPA_Community');// fetch community URL
        return companyURL;
    }
    
    //End
    public ArdiraSurvey__Survey_Result__c getSolutionData() {
        //fetch the solution details
        // CRUD check.
        //if(ArdiraSurvey__Survey_Result__c.SObjectType.getDescribe().isAccessible()){
        solutionDataToBeDisplayed = [select id ,name,owner.Name,owner.firstName,PSS_Proposal_Name_Txt__c,PSS_Partner_Name__c,
                                     ownerId,PSS_Offering_Id_Txt__c,PSS_Submitted_by_Txt__c,
                                     CreatedById,PSS_Programs_Applicable_Nm__c, PSS_View_Program_Applicable_Txt__c,
                                     CreatedBy.name,PSS_Solution_Submitter_UserId_Id__c,PSS_Solution_Submitter_UserId_Id__r.firstName,PSS_Solution_Submitter_UserId_Id__r.isActive, 
                                     PSS_Partner_Offering__r.PMP_Published_Copy_Id_Txt__c from ArdiraSurvey__Survey_Result__c WHERE Id =:solutionId  LIMIT 1];
        // }
        if(!solutionDataToBeDisplayed.isEmpty()){
            solutionData = solutionDataToBeDisplayed[0];
        }
        else{
            solutionData = new ArdiraSurvey__Survey_Result__c();
        } 
        //system.debug('solutionData:'+solutionData);
        return solutionData;  
    }
    
    //returns the community URL
    public String getCommunityURL(String communityURL){
        String solutionURL;
        Network myNetwork;
        myNetwork = [SELECT Id FROM Network WHERE Name = :PMP_Utility.getValue(communityURL) ];
        
        if(myNetwork!=Null){
            solutionURL = Network.getLoginUrl(myNetwork.Id);
            //remove the word login from the communiyt URL and append with offering 
            solutionURL = solutionURL.substringBeforeLast('/') ;
        }
        //we need to check if SFDC outofthe box method will return "/s" at the end         
        if(!solutionURL.endsWith('/s')){
            solutionURL = solutionURL + '/s';
        }    
        
        return solutionURL;
    }
    
    public String headerURL;  
    public String getHeaderURL(){
        
        String domainName;
        String orgId;
        Document document;
        
        
        document = [select Id from Document where Name='IntelLogo' LIMIT 1];
        
        
        //domainName = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        //below line added as part of the logo issue in email template - by priyanka 
        domainName=String.valueOf(System.Url.getOrgDomainUrl().toExternalForm());
        //System.debug('....domainName.....'+domainName);
        orgId = UserInfo.getOrganizationId();
        
        if(document!=Null){
            headerURL =domainName+'/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;
            
            
        }
        
        return headerURL;
    }*/
    
    /*******************************************************************************************************************************************************************************************************
* Method Name : getAssociationDataToBeDisplayed
* Description : fetches the shared contacts to be shown in the vf components PSS_Solution_Unshared_Submitter,PSS_Solution_Shared_Submitter.
* Params      : None
* Version     : 1.0 
* Created Date: 8-Sep-2021
* Modification Log :
* Created By  : Priyanka (Infosys)
********************************************************************************************************************************************************************************************************/
    //associationDataToBeDisplayed variable will be used only in PSS_SolutionUnsharedSubmitter, PSS_SolutionSharedSubmitter vf component
    //and this getter method will read the list value 'sharedContactsListToProcess' which will populated in PSS_SendEmailToContactsOnAddOrRemove class. 
    //We have kept this getter method here , as this class is a reusable for all geTM Emails.
    /*public List<PSS_Solution_Contact_Association__c> getAssociationDataToBeDisplayed() {
      //list will be empty for all the getTM vf components except PSS_SolutionUnsharedSubmitter, PSS_SolutionSharedSubmitter.
      associationDataToBeDisplayed=sharedContactsListToProcess;
      return associationDataToBeDisplayed;  //return the list of PSS_Solution_Contact_Association__c object data which is having the contact details.
            
    }*/
    
}