@IsTest
public class Core_MDF_GenericRelatedListCntller_Test {
    @TestSetup
    static void createTestData() {
        
        // Create Parent Record (Example: Account)
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Child Record (Example: Contact related to Account)
        Contact con = new Contact(
            LastName = 'Test Contact',
            AccountId = acc.Id,
            Email = 'test@test.com'
        );
        insert con;
    }
    
    @IsTest
    static void testGetRelatedRecords_ValidData() {
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        
        List<SObject> result = Core_MDF_GenericRelatedListController.getRelatedRecords(
            'Contact',              // childObjectApi
            'AccountId',            // relationshipField
            acc.Id,                 // parentId
            'LastName,Email'        // fieldList
        );
        
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.size() > 0);
    }
    
    @IsTest
    static void testGetRelatedRecords_BlankInputs() {
        
        Test.startTest();
        
        List<SObject> result = Core_MDF_GenericRelatedListController.getRelatedRecords(
            '',
            '',
            null,
            ''
        );
        
        Test.stopTest();
        
        System.assertEquals(0, result.size());
    }
    
    @IsTest
    static void testGetFieldLabels_ValidFields() {
        
        Test.startTest();
        
        Map<String,String> labels = Core_MDF_GenericRelatedListController.getFieldLabels(
            'Contact',
            'LastName, Email'
        );
        
        Test.stopTest();
        
        System.assert(labels.containsKey('LastName'));
        System.assert(labels.containsKey('Email'));
    }
    
    @IsTest
    static void testGetFieldLabels_BlankInputs() {
        
        Test.startTest();
        
        Map<String,String> labels = Core_MDF_GenericRelatedListController.getFieldLabels(
            '',
            ''
        );
        
        Test.stopTest();
        
        System.assertEquals(0, labels.size());
    }
}