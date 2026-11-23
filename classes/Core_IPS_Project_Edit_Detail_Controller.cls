/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_Detail_Controller 
* Version     : 1.0 
* Created Date: 2 Dec 2018 
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     Main Controller to Edit & Detail of Premier Support Projects As IPS External Customer 
**************************************************************************************************************************************************/
public with sharing class Core_IPS_Project_Edit_Detail_Controller{
    
    public ApexPages.StandardController stdContr;
    
   //Start -- US240396---26-Dec-18 added the fields and conditions for PSO--by Orion vamsi
    public User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    public list<PermissionSetAssignment> userPerSet;
    public boolean fieldDisplay{set;get;}
    //US230261  added  privateDisplay
    public boolean privateDisplay{set;get;}
    public list<Core_IPS_Project_Member__c> usersList1{set;get;}
    public list<Core_IPS_Project_Member__c> usersList2{set;get;}
    String faePermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
    String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
    String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; 
    string projectId=ApexPages.currentPage().getParameters().get('id').escapeHtml4();
     // SOQL Injection Fix  -  Shipra
     Map<String, Object> bindMap1 = new Map<String, Object>{'status' => 'Active','projectId'  => projectId , 'FAEPermissionSetId' => FAEPermissionSetId, 'PartnerProfileId' => PartnerProfileId};
     Map<String, Object> bindMap2 = new Map<String, Object>{'status' => 'Active','projectId'  => projectId , 'agentPartnerProfileId' => agentPartnerProfileId};

    String status = 'Active';
     String userQuery1 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=:status AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId  AND Core_User__c IN  (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:FAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId)  ORDER BY Core_User__r.Name';
   
    String userQuery2 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=:status AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__r.profileid=:agentPartnerProfileId ORDER BY Core_User__r.Name'; 

    public string selectedVal{set;get;}
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
    public List<Contact> lstCon{set;get;}
    public boolean isEmailOptCheck{set;get;}
    
    public Core_IPS_Project_Edit_Detail_Controller(ApexPages.StandardController stdContr){
        List<Core_IPS_Project__c> lstProject;
        //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
        isEmailOptCheck=false;
        getContactData();
        //Start US230261
        privateDisplay=false;
        this.stdContr = stdContr;
        userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()];
        
        if(loggedInUser.profileId ==agentPartnerProfileId || userPerSet[0].PermissionSetID == FAEPermissionSetId ){
        fieldDisplay=true;
    }else{
        fieldDisplay=false;
    }
    //US230261  added  Core_IPS_Private__c to query 
    if(Core_IPS_Project__c.SObjectType.getDescribe().isAccessible()){
       lstProject=[select id,Core_IPS_Partner_Support_Owner__c,Core_IPS_Private__c from Core_IPS_Project__c where id=:projectId];
    }
         if(lstProject.size()>0){
             //Start US230261 checking for Core_IPS_Private__c val
             if(lstProject[0].Core_IPS_Private__c){
                 privateDisplay=true;
             }
             //End US230261 checking for Core_IPS_Private__c val
             selectedVal=lstProject.get(0).Core_IPS_Partner_Support_Owner__c    ;
         }
    }  
    public List<SelectOption> userList
    {
        get
        {  
            usersList1=  Database.queryWithBinds(userQuery1.escapeHtml4(), bindMap1,AccessLevel.USER_MODE);
             usersList2= Database.queryWithBinds(userQuery2.escapeHtml4(), bindMap2,AccessLevel.USER_MODE);
             userList = new List<SelectOption>();
             userList.add(new SelectOption('', '--None--'));    
            for(Core_IPS_Project_Member__c temp : usersList1)
            {
                userList.add(new SelectOption(temp.Core_User__c, temp.Core_User__r.Name));
            }
             for(Core_IPS_Project_Member__c temp : usersList2)
            {
                userList.add(new SelectOption(temp.Core_User__c, temp.Core_User__r.Name));
            }
            return userList;
        }
        set;
    }
    
    Public void fieldUpdate(){
        Core_IPS_Project__c objProj = new Core_IPS_Project__c(Id=projectId);
        /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
        if (Schema.sObjectType.Core_IPS_Project__c.fields.Core_IPS_Partner_Support_Owner__c.isUpdateable()) {
            objProj.Core_IPS_Partner_Support_Owner__c=selectedVal;
        }
        try{
           update objProj; 
           
        }
        catch(DmlException e) {
        }
    }
    //End--- US240396---26-Dec-18 added the fields and conditions for PSO--by Orion vamsi
    // redirect to Project creation page once clicked on Save & New
    public PageReference saveNew() {
        PageReference pgRefer;
        pgRefer = stdContr.save();
        if (pgRefer != null)
        {
            Schema.DescribeSObjectResult describeResult = stdContr.getRecord().getSObjectType().getDescribe(); 
            pgRefer = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
            pgRefer.setRedirect(true); 
        }
        return pgRefer;      
    }
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
    Public void getContactData(){
        lstCon=[SELECT Id,FirstName,LastName,Email,Core_IPS_Email_Opt_Out__c FROM Contact WHERE ( ID In (SELECT ContactID FROM User WHERE id=:userinfo.getuserid()))];
        
        if(lstCon != null && !lstCon.isEmpty())
        {
            if(lstCon[0].Core_IPS_Email_Opt_Out__c == True)
            {
                isEmailOptCheck = True;
            }
        }
        }
    //End --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
}