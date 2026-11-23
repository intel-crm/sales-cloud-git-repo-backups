/******************************************************************************************************
* Class Name  : Core_MDF_Account_Sharing_Test 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
*******************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_MDF_Account_Sharing_Test {
     @TestSetup
    static void setupTestData() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        UserRole usRole1 = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        User ownerUser = new User(
            FirstName        = 'Owner',
            LastName         = 'TestUser',
            Email            = 'owner.testuser@example.com',
            Username         = 'owner.testuser@example.com',
            Alias            = 'ownusr',
            ProfileId        = standardProfile.Id,
            TimeZoneSidKey   = 'America/Los_Angeles',
            LocaleSidKey     = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey= 'en_US',
            UserRoleId		 = usRole1.Id
        );
        insert ownerUser;
    }
   

@isTest
static void testMetadata() {

    ChannelProgram channelProgram =
        Core_MDF_CCP_TestDataUtility.createProgram(
            Core_MDF_CCP_ConstantClass.CCF_PROGRAM,
            'Client CoMarketing Fund',
            true
        );

    Id channelProgramID = channelProgram.Id;

    List<Core_MDF_ChannelProgram__mdt> channelProgramMeta =
        (List<Core_MDF_ChannelProgram__mdt>)
        System.JSON.deserialize(
            '[{"Label":"' +
            Core_MDF_CCP_ConstantClass.CCF_PROGRAM +
            '","Core_MDF_Program_ID__c":"' +
            channelProgramID +
            '"}]',
            List<Core_MDF_ChannelProgram__mdt>.class
        );

    // Assign metadata to the main class
    Core_MDF_Account_Sharing.channelProgramMapping =
        channelProgramMeta;

    // Get Dummy Account Owner ID from Custom Label
    Id dummyOwnerId = Id.valueOf(
        System.Label.Core_MDF_Dummy_Account_Owner_Id
    );

    // Verify that the dummy owner exists
    User dummyOwner = [
        SELECT Id
        FROM User
        WHERE Id = :dummyOwnerId
        LIMIT 1
    ];

    // Create Intel Account
    Account intelAccount =
        Core_MDF_CCP_TestDataUtility.createIntelAccount(
            'Test Acc New',
            Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,
            false
        );

    insert intelAccount;

    // Create CoMarketing Account
    Account acc1 =
        Core_MDF_CCP_TestDataUtility.createCoMarketingAccount(
            'Test Acc 1',
            channelProgram.Id,
            Core_MDF_CCP_TestDataUtility.Account_Record_Type,
            intelAccount.Id,
            false
        );

    insert acc1;

    // Change Account Owner to Dummy Account Owner
    acc1.OwnerId = dummyOwner.Id;
    update acc1;

    // Retrieve Account with CreatedById and OwnerId
    Account accountForSharing = [
        SELECT Id, OwnerId, CreatedById,
               Core_MDF_Channel_Program__c,
               Core_Geo__c,
               Core_Sub_Geo__c,
               Core_MDF_CoMarketing_Ultimate_Account__c
        FROM Account
        WHERE Id = :acc1.Id
    ];

    // Verify the condition required by the new method
    System.assertNotEquals(
        accountForSharing.OwnerId,
        accountForSharing.CreatedById,
        'Owner and Creator should be different'
    );

    System.assertEquals(
        dummyOwnerId,
        accountForSharing.OwnerId,
        'Account owner should be Dummy Account Owner'
    );

    Test.startTest();

    // Explicitly invoke the main method
    Core_MDF_Account_Sharing.invokeAccountShareRecordToGeoGroup(
        new List<Account>{accountForSharing}
    );

    Test.stopTest();

    // Verify that creator received Account Read access
    List<AccountShare> creatorShares = [
        SELECT Id, AccountId, UserOrGroupId,
               AccountAccessLevel, RowCause
        FROM AccountShare
        WHERE AccountId = :acc1.Id
        AND UserOrGroupId = :accountForSharing.CreatedById
        AND RowCause = 'Manual'
    ];

    System.assert(
        !creatorShares.isEmpty(),
        'Account share should be created for the external CoMarketing creator'
    );

    System.assertEquals(
        'Read',
        creatorShares[0].AccountAccessLevel,
        'Creator should receive Read access'
    );
}

}