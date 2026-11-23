/*************************************************************************************************************************************************
* Class Name  : Core_IPS_Project_Edit_Detail_Controller 
* Version     : 1.0 
* Created Date: 2 Dec 2018
* Modification Log :
* Developer                     Date                          Description
* ------------------------------------------------------------------------------------------------------------------------------------------------
* Vamsi                       2 Dec 2018                     Main Controller to Edit & Detail of Premier Support Projects As IPS External Customer 
**************************************************************************************************************************************************/
public class Core_IPS_Project_Edit_Detail_Controller1 {
    
    public ApexPages.StandardController stdContr;
    public list<Core_IPS_Project_Member__c> usersList1{set;get;}
    public list<Core_IPS_Project_Member__c> usersList2{set;get;}
    public List<Contact> lstCon{set;get;}
    public boolean isEmailOptCheck{set;get;}
    String FAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
    String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
    String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; 
    
    string projectId=ApexPages.currentPage().getParameters().get('id');
     String userQuery1 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId  AND Core_User__c IN  (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:FAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId)  ORDER BY Core_User__r.Name';
   
   String userQuery2 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__r.profileid=:agentPartnerProfileId ORDER BY Core_User__r.Name'; 
  
  
   

    
    public Core_IPS_Project_Edit_Detail_Controller1(ApexPages.StandardController stdContr){
        this.stdContr = stdContr;
        getContactData();
       system.debug('projectId====>>>>>>'+projectId);
        system.debug('userQuery1====>>>>>>'+userQuery1);
    system.debug('userQuery2====>>>>>>'+userQuery2);
    }  
    public string vamsi{set;get;}
    public List<SelectOption> userList
    {
        get
        {
             usersList1= Database.query(userQuery1);
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
     Public void getContactData(){
        lstCon=[SELECT Id,FirstName,LastName,Email,Core_IPS_Email_Opt_Out__c FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) and (Core_IPS_Active__c=true))];
        system.debug('lstCon==>'+lstCon);
        if(lstCon != null && !lstCon.isEmpty())
        {
            if(lstCon[0].Core_IPS_Email_Opt_Out__c == True)
            {
                isEmailOptCheck = True;
            }
        }
        }
    
    Public void fieldUpdate(){
        Core_IPS_Project__c objProj = new Core_IPS_Project__c(Id=projectId);
        objProj.Core_IPS_Partner_Support_Owner__c=vamsi;
        
    }
    
  
    // redirect to Project creation page once clicked on Save & New
    public PageReference saveNew() {
        getContactData();
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

}