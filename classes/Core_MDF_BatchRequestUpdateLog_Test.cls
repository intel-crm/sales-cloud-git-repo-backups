@isTest
public class Core_MDF_BatchRequestUpdateLog_Test {
    public static Id PaymentShareRecordTypeId = Schema.SObjectType.Core_MDF_Batch_Request_and_Update_Log__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Payment_Share').getRecordTypeId();
    public static Id massOwnerUpdateRecTypeId = Schema.SObjectType.Core_MDF_Batch_Request_and_Update_Log__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Mass_Owner_Update').getRecordTypeId();
    @testSetup
    static void setupTestData() { 
        Profile profileid1 =[select id,name from Profile where name='System Administrator' limit 1];
        User user = Core_MDF_CCP_TestDataUtility.createUser(false);
        UserRole ur = [Select Id,name from UserRole where name='Admin' limit 1];
        user.profileId = profileid1.id;
        user.UserRoleId = ur.id;
        insert user;
        System.runAs(user){
            Account intelAccountRecord = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.intel_Account_Record_Type, false);
            intelAccountRecord.BillingCity = 'Pune';         
            intelAccountRecord.BillingCountry= 'IND';
            intelAccountRecord.Core_Geo__c ='APJ';
            intelAccountRecord.Core_Sub_Geo__c = 'SA';
            intelAccountRecord.BillingStreet= 'Test Street';            
            Database.insert(intelAccountRecord);
                        
            // Create update JSON string
            String updateJson = JSON.serialize(new Map<String, Object>{'Id' => intelAccountRecord.Id,'OwnerId' => user.Id});
            
            // Create update log
            Core_MDF_Batch_Request_and_Update_Log__c updateLog = new Core_MDF_Batch_Request_and_Update_Log__c(
                RecordTypeId = massOwnerUpdateRecTypeId,
                Core_MDF_Status__c = 'Pending',
                Core_MDF_JSON_String_txt__c = updateJson,
                Core_MDF_Object_apiName_nm__c = 'Account',
                Core_MDF_Action_txt__c = 'Update'
            );            
            insert updateLog;
                        
            // Create insert logs for Core_MDF_Payment__Share
            Map<String, Object> wrapperMap = new Map<String, Object>{
                'Core_MDF_Payment__Share' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'ParentId' => intelAccountRecord.Id,
                            'UserOrGroupId' => user.Id,
                            'AccessLevel' => 'Read',
                            'RowCause' => 'Manual'
                            }
                }
            };
            String insertJson = JSON.serialize(wrapperMap);
            
            Core_MDF_Batch_Request_and_Update_Log__c insertLog = new Core_MDF_Batch_Request_and_Update_Log__c(
                RecordTypeId = PaymentShareRecordTypeId,
                Core_MDF_Status__c = 'Pending',
                Core_MDF_JSON_String_txt__c = insertJson,
                Core_MDF_Object_apiName_nm__c = 'Core_MDF_Payment__Share',
                Core_MDF_Action_txt__c = 'Insert'
            );            
            insert insertLog;            
        }
    }
    
    @isTest
    static void testUpdateBatch() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'Core_MDF_Mass_Owner_Update' LIMIT 1];
        List<Id> logIds = new List<Id>();
        for (Core_MDF_Batch_Request_and_Update_Log__c log : [SELECT Id FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Core_MDF_Object_apiName_nm__c = 'Account' LIMIT 1]) {
            logIds.add(log.Id);
        }        
        Test.startTest();
        Core_MDF_BatchRequestUpdateLog batch = new Core_MDF_BatchRequestUpdateLog(logIds, rt.Id, 'Account','Update',50);
        Database.executeBatch(batch, 1);
        Test.stopTest();        
        // Assert
        for (Core_MDF_Batch_Request_and_Update_Log__c log : [SELECT Core_MDF_Error_Message_txt__c,Core_MDF_Status__c FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Id IN :logIds  LIMIT 1]) {
            System.assertEquals('Completed', log.Core_MDF_Status__c);
        }
    }
    
    @isTest
    static void testInsertBatch() {
        RecordType rt = [SELECT Id,DeveloperName FROM RecordType WHERE DeveloperName = 'Core_MDF_Payment_Share' LIMIT 1];
        List<Id> logIds = new List<Id>();
        for (Core_MDF_Batch_Request_and_Update_Log__c log : [SELECT Id FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Core_MDF_Object_apiName_nm__c = 'Core_MDF_Payment__Share' LIMIT 1]) {
            logIds.add(log.Id);
        }        
        Test.startTest();
        Core_MDF_BatchRequestUpdateLog batch = new Core_MDF_BatchRequestUpdateLog(rt.DeveloperName, 'Core_MDF_Payment__Share','Insert',40);
        Database.executeBatch(batch, 1);
        Test.stopTest();        
        // Assert
        for (Core_MDF_Batch_Request_and_Update_Log__c log : [SELECT Core_MDF_Error_Message_txt__c,Core_MDF_JSON_String_txt__c,Core_MDF_Status__c FROM Core_MDF_Batch_Request_and_Update_Log__c WHERE Id IN :logIds LIMIT 1]) {
            System.assert(log.Core_MDF_Error_Message_txt__c.contains('Failed Insert for Key'));
        }
    }
    
    @isTest
    static void testSafeKeyMethod() {
        Core_MDF_Payment__Share share = new Core_MDF_Payment__Share(ParentId = '001000000000001',UserOrGroupId = '005000000000001',RowCause = 'Manual',AccessLevel = 'Read');
        String key = Core_MDF_BatchRequestUpdateLog.safeKey(share);        
        System.assertEquals('001000000000001AAA-005000000000001AAA-Manual-Read',key);
    }
}