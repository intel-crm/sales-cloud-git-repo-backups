/****************************************************************************************************************************************
* Test Class Name   : Core_MDF_CCP_ConstantClass_Test
* Business Class    : Core_MDF_CCP_ConstantClass
* Description       : To cover Core_MDF_CCP_ConstantClass
* Developer         : Shiva
* Updated     		: Date			developer			description
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
public class Core_MDF_CCP_ConstantClass_Test {

    	 @isTest static void testGetData(){
             Test.startTest();
        //User usr=[Select id from User where LastName = 'Test User' Limit 1];
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1]; 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        system.runAs(usr){
             string cnstName = 'CAMPAIGN_APPROVAL_HISTORY_JSON';
             Core_MDF_CCP_ConstantClass cnstCls = new Core_MDF_CCP_ConstantClass();
             string value = (string)cnstCls.getValue(cnstName);

             Assert.isNotNull(value);
         }
             Core_MDF_CCP_ConstantClass.getAllConstants();
             test.stopTest();
         }

    @isTest static void testToJSON(){
        Test.startTest();
        Core_MDF_CCP_ConstantClass cnstCls = new Core_MDF_CCP_ConstantClass();
        String jsonStr = cnstCls.toJSON();
        Assert.isNotNull(jsonStr, 'toJSON should return a serialized string');
        Assert.isTrue(jsonStr.contains('CAMPAIGN_APPROVAL_HISTORY_JSON') || jsonStr.length() > 0, 'JSON should not be empty');

        Object missing = cnstCls.getValue('NON_EXISTENT_CONSTANT_NAME');
        Assert.isNull(missing, 'getValue should return null for unknown constant');
        Test.stopTest();
    }

    @isTest static void testBuildIupgmIdempotencyKey_AllAccountAccess(){
        Id usrId = UserInfo.getUserId();
        Test.startTest();
        String key = Core_MDF_CCP_ConstantClass.buildIupgmIdempotencyKey(
            usrId, 'IPA', 'Core_MDF_CCP_Internal_IPA_Acct_Mgr', 'EMEA', null, true, 'EMEA', 'Standard');
        Test.stopTest();
        Assert.isNotNull(key, 'Key should not be null');
        Assert.isTrue(key.contains('ALL'), 'Key should contain ALL segment when allAccountAccess is true');
        Assert.isTrue(key.length() <= 255, 'Key should not exceed 255 characters');
    }

    @isTest static void testBuildIupgmIdempotencyKey_WithAccountId(){
        Id usrId = UserInfo.getUserId();
        // Synthetic Account Id - method only stringifies it, no SOQL/DML needed
        Id accId = Id.valueOf('001000000000001AAA');
        Test.startTest();
        String key = Core_MDF_CCP_ConstantClass.buildIupgmIdempotencyKey(
            usrId, 'CCF', 'Core_MDF_CCP_Internal_CCF_Acct_Mgr', 'NAR', accId, false, 'NAR', 'Field');
        Test.stopTest();
        Assert.isNotNull(key, 'Key should not be null');
        Assert.isTrue(key.contains(String.valueOf(accId).left(18)), 'Key should contain the 18-char account id segment');
    }

    @isTest static void testBuildIupgmIdempotencyKey_NullInputs(){
        Test.startTest();
        String key = Core_MDF_CCP_ConstantClass.buildIupgmIdempotencyKey(
            null, null, null, null, null, false, null, null);
        Test.stopTest();
        Assert.isNotNull(key, 'Key should not be null even for null inputs');
        Assert.isTrue(key.contains('NULL'), 'Key should contain NULL segments for null inputs');
    }

    @isTest static void testBuildIupgmIdempotencyKey_TruncatesLongKey(){
        Id usrId = UserInfo.getUserId();
        String longProgram = 'P'.repeat(150);
        String longPsName = 'S'.repeat(150);
        Test.startTest();
        String key = Core_MDF_CCP_ConstantClass.buildIupgmIdempotencyKey(
            usrId, longProgram, longPsName, 'EMEA', null, true, 'EMEA', 'Standard');
        Test.stopTest();
        Assert.areEqual(255, key.length(), 'Key longer than 255 chars should be truncated to 255');
    }

    @isTest static void testNewIupgmCorrelationId(){
        Test.startTest();
        String corrId1 = Core_MDF_CCP_ConstantClass.newIupgmCorrelationId();
        String corrId2 = Core_MDF_CCP_ConstantClass.newIupgmCorrelationId();
        Test.stopTest();
        Assert.isTrue(corrId1.startsWith('COR-'), 'Correlation id should start with COR-');
        Assert.areEqual(16, corrId1.length(), 'Correlation id should be COR- plus 12 hex chars');
        Assert.areNotEqual(corrId1, corrId2, 'Correlation ids should be unique');
        Assert.areEqual(corrId1, corrId1.toUpperCase(), 'Correlation id should be upper-cased');
    }
}