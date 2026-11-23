public class Core_IPS_AddProjSupportOwner_Contr_Clone {
    
   
  
    Public String strISOUserSearch{get;set;}
    Public String strPSOUserSearch{get;set;}
    Public String selISOId{get;set;}
    Public String selPSOId{get;set;}
    Public Boolean renderPage{get;set;}
    Public String renderMessage{get;set;}
    
    public string selectedUser{set;get;}
    public list<SelectOption> countrieLst{set;get;}
    public list<Core_IPS_Project_Member__c> usersList1{set;get;}
    public list<Core_IPS_Project_Member__c> usersList2{set;get;}
    
    
    
    Id projectId;
    ApexPages.StandardController stdcon;
   
    public Core_IPS_AddProjSupportOwner_Contr_Clone(ApexPages.StandardController controller) {
        stdcon = controller;
        projectId = stdcon.getId();       
        init();
    }
        String DFAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        String partnerProfileId = System.Label.Core_IPS_Partner_Profile_Id;
        String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id; /*AND Core_User__r.profileid=: Core_IPS_Partner_AE_Profile_Id*/
    String userQuery1 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId  AND Core_User__c IN  (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =:DFAEPermissionSetId AND Assignee.ProfileId =:PartnerProfileId)  ORDER BY Core_User__r.Name';
   
   String userQuery2 = 'SELECT Id,Core_User__c,Core_User__r.Name, Core_User__r.profileid FROM Core_IPS_Project_Member__c' + 
            ' WHERE Core_Status__c=\'Active\' AND Core_IPS_Contact__r.Core_IPS_Active__c=true AND Core_User__r.isActive=true AND Core_IPS_Project__c=:projectId AND Core_User__r.profileid=:agentPartnerProfileId ORDER BY Core_User__r.Name'; 
    
    public Core_IPS_AddProjSupportOwner_Contr_Clone() {
      
    }
    public List<SelectOption> UserList
    {
        get
        {
             usersList1= Database.query(userQuery1);
              usersList2= Database.query(userQuery2);
            
            UserList = new List<SelectOption>();
             UserList.add(new SelectOption('', '--None--'));    
            for(Core_IPS_Project_Member__c temp : usersList1)
            {
                UserList.add(new SelectOption(temp.Core_User__c, temp.Core_User__r.Name));
            }
             for(Core_IPS_Project_Member__c temp : usersList2)
            {
                UserList.add(new SelectOption(temp.Core_User__c, temp.Core_User__r.Name));
            }
            return UserList;
        }
        set;
    }
    
    //initialize the default 
    private void init() {
        renderPage = true;
        if(String.isBlank(projectId)) {
            renderPage = false;
            renderMessage = Core_IPS_Helper_Utility.getIPSLabel('IPS_Invalid_URL'); return;
        } 
        UserRecordAccess objUserRecAccess = [SELECT RecordId,HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId=:projectId];
        if(objUserRecAccess==null || objUserRecAccess.HasEditAccess!=true) {
            renderPage = false;
            renderMessage = Core_IPS_Helper_Utility.getIPSLabel('IPS_Project_Access_Error'); return;
        }
     
    }
    
    //save and redirect to project
    public Pagereference SaveRedirect() {
        Core_IPS_Project__c objProj = new Core_IPS_Project__c(Id=projectId);
        Boolean isUpdate = false;
        
            objProj.Core_IPS_Partner_Support_Owner__c = selectedUser;
            isUpdate = true;
        
        try{
            if(isUpdate)
                update objProj;
            return stdcon.cancel();
        } catch(Exception ex) {
            System.debug('Error --> ' +  ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Core_IPS_Helper_Utility.getIPSLabel('IPS_Generic_Exception_Msg')));
        }
        return null;
    }
    
    
  
    
  

}