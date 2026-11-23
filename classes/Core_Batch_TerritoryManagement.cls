/*******************************************************************************************************
Apex Class Name:Core_Batch_TerritoryManagement  
Version     : 1.0 
Created Date: 23 Dec 2016
Description :This batch is used to get the query on Users and for each users get associated territories 
********************************************************************************************************/
public class Core_Batch_TerritoryManagement implements Database.Batchable<sObject>, Database.Stateful{
    
    //Handler for the batch job, all the business logic will be written in this class
    private Core_AccountCoverageBatchHandler batchService = null;
    
    private static final String UNIQUE_INDICATOR = 'TM';
    
    private static final String BATCH_NAME = 'Core_Batch_TerritoryManagement';
    
    private String overrideUser = '';
    
    //<User.Id, exception.errorMessage>
    private Map<String, String> failedUsers = new Map<String, String>();
    
    //Default constructor
    public Core_Batch_TerritoryManagement(){
        //Intialize the Handler
        batchService = new Core_AccountCoverageBatchHandler();        
    }
    
    //Default constructor
    public Core_Batch_TerritoryManagement(String userId){
        //Intialize the Handler
        this.batchService = new Core_AccountCoverageBatchHandler();        
        this.overrideUser = userId;
    }
    
    // start Method - Returns the query locator
    // @batchcontext - context holds parent job id
    public Database.QueryLocator  start(Database.BatchableContext batchcontext) {
        System.debug('+++++++++++++++++ Core_Batch_TerritoryManagement STARTED -----------------');
        
        Set<Id> setUserId = new Set<Id>();
        Map<Id, User> mapUser  = null;
        
        //Reset the Custom Setting to Blank
        Core_AccountCoverageExportUtil.setCustomSettings(BATCH_NAME,'');
        
        //This is to overcome No more than one executeBatch is allowed in unit test classes, refer SF knowledge articles for more information.
        if(Test.isRunningTest()){
            setUserId.add([SELECT Id FROM User WHERE UserRoleId IN (select Id from UserRole where Name = 'UnitTest-Customer-User') Limit 1].Id);
            System.debug('setUserId---'+setUserId);
        }else{
            mapUser  = Core_AccountCoverageExportUtil.getUsers();    
            setUserId = mapUser.keySet();
            System.debug('#01 mapUser.keyset().size(): ' + setUserId.size());
            
        }
        Set<ID> userIds=new Set<ID>();
        List<UserTerritory2Association > UT2A=[SELECT UserId FROM UserTerritory2Association where userId in :setUserId ];
        system.debug('UT2A==='+UT2A);
        for(UserTerritory2Association userTerritory:UT2A){
            userIds.add(userTerritory.UserId);
        }
        String query='SELECT Id, Name, FederationIdentifier, Email, UserRoleId, UserRole.Name,  Profile.Name, Core_Login_Id__c, FirstName, LastName, Title, CountryCode, isActive, Phone,MobilePhone, City, LocaleSidKey, Core_User_Country_Code__c  FROM User ' +
            'Where ID IN ' +  ( String.isBlank(overrideUser) ? ': userIds ':'(\''+overrideUser+'\')' );
        
        System.debug(' Role Batch Running with Query : '+query);
        return Database.getQueryLocator(query);
    }
    
    //The default scope which we are running is 1 to avoid SOQL governor limits while finding subordinates recursively
    public void execute(Database.BatchableContext BC, List<User> users){
        List<Core_AccountCoverage_Export__c> acctCovrExpList = new List<Core_AccountCoverage_Export__c>();
        String currUserId = '';
        try{
            System.debug(' Core_Batch_TerritoryManagement Execute Method Invoked ScopeSize >>  '+users.size());
            for(User currUser : users){
                System.debug(' Processing for User : '+currUser.Name + ' User Role ID :'+currUser.UserRoleId);
                
                currUserId = currUser.Id;
                Set<String> T2Ids=new Set<String>();
                Integer recordCount = 0;
                
                //Fetch the territoryIds associated with the current iterating User
                for(UserTerritory2Association ut2a : [SELECT Territory2Id FROM UserTerritory2Association Where UserId =:currUserId ]){
                    T2Ids.add(ut2a.Territory2Id);
                }
                
                System.debug(' Total Territories associated to the User T2Ids '+T2Ids.size());
                // Get the count of Object Id's which matches with the account Id's which has B2B = true
                for (AggregateResult[] arl : [SELECT Count(Id) CNT  FROM ObjectTerritory2Association 
                                                                        WHERE Territory2Id IN : T2Ids AND Territory2.AccountAccessLevel = 'Edit' AND
                                                                        ObjectId IN (SELECT ID FROM Account where Core_B2B_Entitlement__c  = true ) ] )
                {
                    for(AggregateResult ar: arl){
                        recordCount += (Integer.valueOf(ar.get('CNT')));    
                    }
                }
                System.debug(currUser.Name + ' Total RecordCount  >> '+recordCount);   
                //Do Not process if the the records are more than 10000
                if(recordCount > Limits.getLimitDMLRows() ){
                    failedUsers.put(currUserId, ' has '+String.valueOf(recordCount) + ' records');
                }else {
                    Set<ID> objectIds=new Set<ID>();
                    for(List<ObjectTerritory2Association> objTerritoryList : [SELECT ObjectId  FROM ObjectTerritory2Association 
                                                                              WHERE Territory2Id IN : T2Ids AND Territory2.AccountAccessLevel = 'Edit' AND
                                                                              ObjectId IN (SELECT ID FROM Account where Core_B2B_Entitlement__c  = true  ) ])
                    {
                        for(ObjectTerritory2Association obj :objTerritoryList){
                            objectIds.add(obj.ObjectId);
                        }
                    }
                    for(Account acct : [SELECT Id, Core_CIM_ID__c, Core_Geo__c  FROM Account WHERE  Core_B2B_Entitlement__c  = true AND Id in:objectIds])
                    { 
                        Core_AccountCoverage_Export__c ce = new Core_AccountCoverage_Export__c();
                        //Populate the account details and user details into coverage export object
                        Core_AccountCoverageExportUtil.populateAccountCoverage(ce, acct, currUser);
                        ce.Core_Territory_Management__c= UNIQUE_INDICATOR;
                        acctCovrExpList.add(ce);
                    }
                }
                System.debug('  ++++++++++++++++++++++++++++++++++>>> acctCovrExpList FInal '+acctCovrExpList.size());
                Database.upsert(acctCovrExpList, Core_AccountCoverage_Export__c.fields.Core_Ext_Id__c);
                
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
        Database.executeBatch(new Core_Batch_RoleHierarchy(), 1);
        
        System.debug('+++++++++++++++++ Core_Batch_TerritoryManagement FINISHED -----------------');
        
    }
}