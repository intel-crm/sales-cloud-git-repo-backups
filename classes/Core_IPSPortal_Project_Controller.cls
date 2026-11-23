/* Ignore this class*/
public with sharing class Core_IPSPortal_Project_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, Map<String, Core_CustomSetController>> loadData(){
        String IPS_PROJ           = 'Premier Support Project';
        String IPS_PROJ_MEM       = 'Premier Support Project Members';
        String IPS_PROJ_PROD      = 'Premier Support Products';
        String AVAILABLE_RECORDS = 'AvailableRecords';
        String EXISTING_RECORDS  = 'ExistingRecords';
        String ACTIVE            = 'Active';
        String IN_ACTIVE         = 'InActive';
        //String loggedInUserAcctId = null;
        //String loggedInUserContId = null;
        Account loggedinUsrAcct = null;
        Map<String, Map<String, Core_CustomSetController>> mStep_SetCntlr;
       boolean isEmailOptCheck=false;
       boolean fieldDisplay;
       User loggedInUser = [Select Id, Name,profileId, ContactId, Contact.AccountId From User where Id =: UserInfo.getUserId()];

       System.debug('loggedInUser--'+loggedInUser);
       String agentPartnerProfileId=System.Label.Core_IPS_Partner_AE_Profile_Id;
       String FAEPermissionSetId = System.Label.Core_IPS_Partner_DFAE_Permission_Set;
        try {
                isEmailOptCheck = getContactData();
                list<PermissionSetAssignment> userPerSet=[Select PermissionSetID From PermissionSetAssignment where AssigneeId=:UserInfo.getUserId() ];
                if(loggedInUser.profileId ==agentPartnerProfileId || userPerSet[0].PermissionSetID == FAEPermissionSetId ){
                    fieldDisplay=true;
                }else{
                    fieldDisplay=false;
                }
                Core_IPS_Project__c  ipsProject = new Core_IPS_Project__c();
            if(loggedInUser.Contact.AccountId == null){
                     System.debug('Invalid community user or user not authorized');
                }
            else{
                    String loggedInUserAcctId = loggedInUser.Contact.AccountId;
                    String loggedInUserContId = loggedInUser.ContactId ;
                    String query = null;
                    String iipsProjectrojId = '';
                //**************************************** STEP 2 ****************************************
                //**************** Show existing Project Members ************/ 
                 query = 'Select Core_IPS_Contact__c,Core_Status__c,Core_IPS_Contact__r.FirstName,Core_IPS_Contact_Account__c, Core_IPS_Contact__r.LastName, Core_IPS_Contact__r.Email, Core_IPS_Contact__r.Account.Name '+
                ' FROM Core_IPS_Project_Member__c WHERE  Core_Status__c = \'ACTIVE\' AND  Core_IPS_Contact__r.AccountId  =\''+loggedInUserAcctId+'\'  AND Core_IPS_Project__c = \''+(ipsProject.Id == null ? '' :ipsProject.Id)+'\'';
                system.debug('Query with existing Project Members=='+query); 
                List<sObject> sobjListPM = Database.query(query);
                system.debug('List of existing Project Members=='+sobjListPM); 
                //***************Show Available contacts for adding to project Members ************/
                 query = 'Select Name,LastName, FirstName,Core_Status__c, Email, Account.Name, Core_IPS_Active__c,Core_IPS_Email_Opt_Out__c From Contact Where AccountId = \''+loggedInUserAcctId+'\' AND ID != \''+loggedInUserContId+'\'  AND Core_IPS_Active__c  = true  ';
                 query += ' AND ID NOT IN ( Select Core_IPS_Contact__c FROM Core_IPS_Project_Member__c where  Core_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\') And ID in (SELECT ContactId FROM User WHERE IsActive = true)';
                 system.debug('Query with  Available contacts for adding to project Members=='+query); 
                 List<sObject> sobjListAPM = Database.query(query);
                 system.debug('List Of  Available contacts for adding to project Members=='+sobjListAPM); 
                 //******************** STEP 3 ******************** //
                //****************Show existing IPS Products************/
                 query = 'Select Name, Core_Supported_Product_Name__c,Core_IPS_Product_Status__c, Core_Intel_Product__c,Product_Application__c, Core_Supported_Product__c  '+
                 'FROM Core_IPS_Product__c where Core_IPS_Product_Status__c = \'ACTIVE\' AND  Core_IPS_Project__c = \''+iipsProjectrojId+'\'';
                 system.debug('Query with existing IPS Products=='+query);  
                 List<sObject> sobjListEprdos = Database.query(query);
                 system.debug('List Of existing IPS Products=='+sobjListEprdos); 
                 //****************Show Available IPS Products************/     
                    query = 'Select Name,Account.Name, Core_Supported_Product__r.Core_Product_Organization__r.Name,core_Product_Application__c, Core_Supported_Product__r.Core_Flag_Status__c, '+
                    'Core_Code_Name__c,  InstallDate, Status, Description, Core_IPS_Asset__c, Core_IPS_Project__c, Core_Supported_Product__c, Core_Product_Organization__c '+
                    'From Asset '+
                    'Where (AccountId = \''+loggedInUserAcctId+'\' or RecordType.Name = \'Public Products\' or Core_IPS_Project__c = Null ) AND status = \'Active\' AND Core_IPS_Supported_Product_EOIS__c = false AND '+
                    'Core_Supported_Product__C NOT IN ( Select Core_Supported_Product__c FROM Core_IPS_Product__c WHERE Core_IPS_Product_Status__c = \'ACTIVE\' AND Core_IPS_Project__c = \''+iipsProjectrojId+'\')';    
                    system.debug('Query with Available IPS Products=='+query); 
                    List<sObject> sobjListAprdos = Database.query(query);
                    system.debug('List Of Available IPS Products=='+sobjListAprdos); 
                }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return mStep_SetCntlr;
    }
    public static boolean getContactData(){
        list<Contact> lstCon = [SELECT Id,FirstName,LastName,Email,Core_IPS_Email_Opt_Out__c FROM Contact WHERE (ID In (SELECT ContactID FROM User WHERE id=:userinfo.getuserid()))];
        boolean isEmailOptCheck = false;
        if(lstCon != null && !lstCon.isEmpty())
        {
            if(lstCon[0].Core_IPS_Email_Opt_Out__c == True)
            {
                isEmailOptCheck = True;
            }
        }
        return isEmailOptCheck;
        }
}