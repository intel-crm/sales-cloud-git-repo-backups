/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_Detail_Controller 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     Main Controller to Edit & Detail of Premier Support Projects As IPS External Customer 
**************************************************************************************************************************************************/
public class Core_IPS_Project_Edit_Detail_Controller{
    
    public ApexPages.StandardController stdContr;
    
   //Start -- US240396---26-Dec-18 added the fields and conditions for PSO--by Orion vamsi
    public User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];
    public list<PermissionSetAssignment> userPerSet;
    public boolean fieldDisplay{set;get;}
    public list<Core_IPS_Project_Member__c> usersList1{set;get;}
    public list<Core_IPS_Project_Member__c> usersList2{set;get;}
    String FAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
    String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
    String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; 
    string projectId=ApexPages.currentPage().getParameters().get('id');
     String userQuery1 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId  AND Core_User__c IN  (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:FAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId)  ORDER BY Core_User__r.Name';
   
    String userQuery2 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__r.profileid=:agentPartnerProfileId ORDER BY Core_User__r.Name'; 

    public string selectedVal{set;get;}
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
    public List<Contact> lstCon{set;get;}
    public boolean isEmailOptCheck{set;get;}
    
    public Core_IPS_Project_Edit_Detail_Controller(ApexPages.StandardController stdContr){
        //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
        isEmailOptCheck=false;
        getContactData();
        this.stdContr = stdContr;
        userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId() ];
        
        if(loggedInUser.profileId ==agentPartnerProfileId || userPerSet[0].PermissionSetID == FAEPermissionSetId ){
        fieldDisplay=true;
    }else{
        fieldDisplay=false;
    }
     List<Core_IPS_Project__c> lstProject=[select id,Core_IPS_Partner_Support_Owner__c from Core_IPS_Project__c where id=:projectId];
     if(lstProject.size()>0){
             selectedVal=lstProject.get(0).Core_IPS_Partner_Support_Owner__c;
         }
    }  
    public List<SelectOption> userList
    {
        get
        {    usersList1= Database.query(userQuery1);
             usersList2= Database.query(userQuery2);
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
        objProj.Core_IPS_Partner_Support_Owner__c=selectedVal;
        try{
           update objProj; 
        }
        catch(DmlException e) {
           System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
    //End--- US240396---26-Dec-18 added the fields and conditions for PSO--by Orion vamsi
    // redirect to Project creation page once clicked on Save & New
    public PageReference saveNew() {
        PageReference pgRefer;
        pgRefer = stdContr.save();
        system.debug('con'+stdContr);
        if (pgRefer != null)
        {
            Schema.DescribeSObjectResult describeResult = stdContr.getRecord().getSObjectType().getDescribe(); 
            pgRefer = new PageReference('/' + describeResult.getKeyPrefix() + '/e'); 
            system.debug('pr'+pgRefer);
            pgRefer.setRedirect(true); 
        }
        return pgRefer;      
    }
    //Start --US240404--26-Dec-18 for Disabling InterestedParty checkbox by Popcornapps
    Public void getContactData(){
        System.debug('user Id'+userinfo.getuserid());
        lstCon=[SELECT Id,FirstName,LastName,Email,Core_IPS_Email_Opt_Out__c FROM Contact WHERE ( ID In (SELECT ContactID FROM User WHERE id=:userinfo.getuserid()))];
        system.debug('lstCon==>'+lstCon);
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