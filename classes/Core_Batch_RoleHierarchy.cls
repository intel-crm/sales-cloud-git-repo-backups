/**************************************************************************************
Apex Class Name:Core_Batch_RoleHierarchy  
Version     : 1.0 
Created Date: 08 Dec 2016
Description : This Batch Iterates on the User and finds the all subordinates for each Users and Upserts all the assicoiated user accounts to AccountCoverageExport object
*************************************************************************************/
//TODO >> Change Core_B2B_Entitlement__c  = true
public class Core_Batch_RoleHierarchy implements Database.Batchable<sObject>, Database.Stateful {
    
    //Handler for the batch job, all the business logic will be written in this class
    private Core_AccountCoverageBatchHandler batchService = null;
    
    private static final String UNIQUE_INDICATOR = 'RH';
    
    private static final String BATCH_NAME = 'Core_Batch_RoleHierarchy';
    
    private String overrideUser = '';
    
    //<User.Id, exception.errorMessage>
    private Map<String, String> failedUsers = new Map<String, String>();
    
    //Default constructor
    public Core_Batch_RoleHierarchy(){
        //Intialize the Handler
        batchService = new Core_AccountCoverageBatchHandler();        
    }

    //Default constructor
    public Core_Batch_RoleHierarchy(String userId){
        //Intialize the Handler
        this.batchService = new Core_AccountCoverageBatchHandler();        
        this.overrideUser = userId;
    }
    
    
    //list of profile ids for the account owners
    Set<Id> includeProfiles = new Set<Id>();
    
    // start Method - Returns the query locator
    // @batchcontext - context holds parent job id
    public Database.QueryLocator  start(Database.BatchableContext batchcontext) {
       
        System.debug('+++++++++++++++++ Core_Batch_RoleHierarchy STARTED -----------------');
        
        Map<Id, User> mapUser  = null;
        Set<Id> setUserId = new Set<Id>();
        for(Profile p : [SELECT Id FROM Profile WHERE Name IN : Core_AccountCoverage_Profiles__c.getall().keySet()]) {
            includeProfiles.add(p.Id);
        }    
        
        //Reset the Custom Setting to Blank
        Core_AccountCoverageExportUtil.setCustomSettings(BATCH_NAME,'');
        
        //This is to overcome No more than one executeBatch is allowed in unit test classes, refer SF knowledge articles for more information.
        if(Test.isRunningTest()){
            setUserId.add([SELECT Id, UserRole.Name  FROM User WHERE UserRoleId IN (select Id from UserRole where Name = 'UnitTest-Customer-User') Limit 1].Id);
        }else{
            mapUser  = Core_AccountCoverageExportUtil.getNonAdminUsers();    
            setUserId = mapUser.keySet();
            System.debug('#01 mapUser.keyset().size(): ' + setUserId.size());
        }

        String query = 'SELECT Id, Name, FederationIdentifier, Email, UserRoleId, UserRole.Name,  Profile.Name, Core_Login_Id__c, FirstName, LastName, Title, CountryCode, isActive, Phone,MobilePhone, City, LocaleSidKey, Core_User_Country_Code__c  FROM User '+
                       'Where ID IN '+  ( String.isBlank(overrideUser) ? ': setUserId ':'(\''+overrideUser+'\') ' );
        System.debug(' Role Batch Running with Query : '+query+' ORDER BY CompanyName NUlls last ');
        return Database.getQueryLocator(query);
    }
    
    //The default scope which we are running is 1 to avoid SOQL governor limits while finding subordinates recursively
    public void execute(Database.BatchableContext BC, List<User> users){
        System.debug(' Core_Batch_RoleHierarchy Execute Method Invoked   ');
        
        Map<Id, List<User>> userAndSubOrdUsersIds = new  Map<Id, List<User>>();
        List<Core_AccountCoverage_Export__c> acctCovrExpList = new List<Core_AccountCoverage_Export__c>();
        String currUserId = '';
        try{
            System.debug(' Core_Batch_RoleHierarchy ScopeSize >>  '+users.size());
            for(User currUser : users){
                currUserId = currUser.Id;
                System.debug(' Processing for User : '+currUser.Name + ' User Role ID :'+currUser.UserRoleId);

                //if(currUserId != '005o0000002lSqyAAE')
                //    continue;

                //Currently As we are processing user by user (I.e, Database.executeBatch(instance, 1) ) there should not be any problem and above statment is valid if we are running with default scope or more than 1. 
                if(userAndSubOrdUsersIds.get(currUser.Id) == null){
                    userAndSubOrdUsersIds.put(currUser.Id, batchService.getAllSubordinateUsersByUserRoleId(currUser.UserRoleId));
                }
                List<User> subOrdinateUsrs = userAndSubOrdUsersIds.get(currUser.Id);
                Set<Id> subIds = new Set<Id>();
                
                subIds.add(currUser.Id);
                for(User u : subOrdinateUsrs){
                    System.debug(' User Role +++++++++ '+u.UserRole.Name);
                    subIds.add(u.Id);
                }
                
                System.debug(' All suborniate Id\'s >>  '+subIds + ' includeProfiles >>  '+ includeProfiles);    
                Integer recordCount = 0;
                
                for (AggregateResult[] arl : [SELECT Count(Id) CNT  FROM Account  WHERE Core_B2B_Entitlement__c  = true AND OwnerId IN : subIds AND Owner.IsActive = true AND Owner.ProfileId IN : includeProfiles ] ){
                    for(AggregateResult ar: arl){
                        recordCount += (Integer.valueOf(ar.get('CNT')));    
                    }
                }
                System.debug(currUser.Name + ' Total RecordCount  >> '+recordCount);   

                if(recordCount > Limits.getLimitDMLRows()){
                      //If Currentuser currUser.UserRole.Name!= 'Admin equals to admin then don't add to the failed Users List 
                        failedUsers.put(currUserId, ' has '+String.valueOf(recordCount)+' Records');
                }else {
                    for(Account acct : [SELECT Id, Owner.Name, Name, Core_CIM_ID__c, Core_Geo__c, Core_Account_Legal_Name__c, Owner.Core_WWID__c, Owner.Email, OwnerId, Owner.UserRoleId 
                                        FROM Account   
                                        WHERE  Core_B2B_Entitlement__c  = true AND OwnerId IN : subIds AND Owner.IsActive = true AND Owner.ProfileId IN : includeProfiles ]){ 
                        Core_AccountCoverage_Export__c ce = new Core_AccountCoverage_Export__c();
                        
                        //Populate the account details and user details into coverage export object
                        Core_AccountCoverageExportUtil.populateAccountCoverage(ce, acct, currUser);
                        
                        ce.Core_Role_Hierarchy__c = UNIQUE_INDICATOR;
                        
                        acctCovrExpList.add(ce);
                    }
                }
                System.debug('  ++++++++++++++++++++++++++++++++++>>> acctCovrExpList FInal '+acctCovrExpList.size());
                //batchService.upsertAccountsCoverage(acctCovrExpList);
                 List<Database.UpsertResult> dbsr = Database.upsert(acctCovrExpList, Core_AccountCoverage_Export__c.fields.Core_Ext_Id__c);
                System.debug(' >>>>>>>>>>> +'+dbsr);
                
            }
        }catch(Exception e){    
            String errMsg = e.getCause()+ ' '+e.getLineNumber()+ ' '+e.getMessage()+ ' '+e.getStackTraceString();
            System.debug(logginglevel.Error, errMsg);
            failedUsers.put(currUserId, errMsg);
            throw e; 
        }
        
        
    }
    
    
    //Send the email notification 
    public void finish(Database.BatchableContext batchcontext){
        System.debug(' Core_Batch_RoleHierarchy  >> batch completed ');
        
        //Set the Failed UserdIds  to email Body
        Core_AccountCoverageExportUtil.additionalEmailBody = batchService.convertMapToString(failedUsers);
        System.debug(BATCH_NAME+' '+UNIQUE_INDICATOR);
        System.debug(' Failed Users Setting to Email Body  '+Core_AccountCoverageExportUtil.additionalEmailBody);
        
        //Sends the Email Notification and Update the Custom Settings flag
        Core_AccountCoverageExportUtil.sendNotification(batchcontext, BATCH_NAME);
        
        
        if(!Test.isRunningTest() &&  Core_AccountCoverageExportUtil.areAllAccountCoverageBatchesCompleted())
            Database.executeBatch(new Core_Batch_AccountCoverage_Summary(), 1500);
        System.debug('+++++++++++++++++ Core_Batch_RoleHierarchy FINISHED -----------------');
        
    }
    
    
}