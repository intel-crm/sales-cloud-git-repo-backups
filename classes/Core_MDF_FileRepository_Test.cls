/****************************************************************************************************************************************
* Class Name            : Core_MDF_FileRepository_Test
* Main Class Name       : Core_MDF_FileRepository
* Version               : 1.0  
* Created By            : Accenture - Vikas Soni
* Created Date          : 19-01-2026
* Modification Log      : 
* Developer            Date             Description
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_FileRepository_Test {
    
    @TestSetup
    static void setupTestData() {
        //Admin User to create Channel Program, Account , Create Internal Account Managers, Program Admins 
        List<User> userList = new List<User>();
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.UserRoleId = usRole.Id;
        userList.add(usr);
        insert userList;
        System.runAs(userList[0]){
            Test.startTest();
            // Creating Channel Programs
            List <ChannelProgram> cpList = new List <ChannelProgram>();
            ChannelProgram cpCCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            ChannelProgram cpDCF = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.DCF_PROGRAM,'Data Center CoMarketing Fund', false);
            cpList.add(cpCCF);
            cpList.add(cpDCF);
            insert cpList;
            // Creating Intel Account 
            List<Account> accIntelList = new List<Account>();
            Account accIntel = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Intel Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, FALSE);
            accIntel.Core_MDF_CoMarketingActive__c = true;
            accIntelList.add(accIntel);
            insert accIntelList;
            // Creating Virtual Node Account
            List<Account> accVirtualAccountList = new List<Account>();
            Account coMarketingAccCCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Virtual CCF Account', cpList[0].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accIntelList[0].Id, FALSE);
            Account coMarketingAccDCF = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Virtual DCF Account', cpList[1].Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, accIntelList[0].Id, FALSE);
            accVirtualAccountList.add(coMarketingAccCCF);
            accVirtualAccountList.add(coMarketingAccDCF);
            insert accVirtualAccountList;
            // Getting Internal Account Managers
            Profile ccpCoreAccessProfile = [SELECT Id FROM Profile WHERE Name='CCP - Core Access' LIMIT 1];
            PermissionSet ccfAccmanagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_CCF_Acct_Mgr' LIMIT 1];
            PermissionSet dcfAccmanagerPS = [SELECT Id, Name FROM PermissionSet WHERE Name='Core_MDF_CCP_Internal_DCF_Acct_Mgr' LIMIT 1];
            // Insert Internal Account Manager
            List<User> listUser = new List<user>();
            //CCF Account Manager  
            User ccfAccntMngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'ccfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            User dcfAccntMngr = Core_MDF_CCP_TestDataUtility.createUser(false);
            ccfaccntmngr.Email = 'dcfaccntmngr@example.com';
            ccfaccntmngr.Profile = ccpCoreAccessProfile;
            listUser.add(ccfAccntMngr);
            listUser.add(dcfAccntMngr);
            insert listUser;
            //PS Assignment
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            PermissionSetAssignment assignPermissionSetObjCCF = new PermissionSetAssignment();
            assignPermissionSetObjCCF.AssigneeId = ccfAccntMngr.Id;
            assignPermissionSetObjCCF.PermissionSetId = ccfAccmanagerPS.Id;
            PermissionSetAssignment assignPermissionSetObjDCF = new PermissionSetAssignment();
            assignPermissionSetObjDCF.AssigneeId = dcfAccntMngr.Id;
            assignPermissionSetObjDCF.PermissionSetId = dcfAccmanagerPS.Id;
            psaList.add(assignPermissionSetObjCCF);
            psaList.add(assignPermissionSetObjDCF);
            insert psaList;
            Test.stopTest();
            System.runAs(ccfAccntMngr){
                Campaign campCCF = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp CCF','Gaming','Intel® Core™ i5 Processor','Yes', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', Date.newInstance(2021, 01, 01),Date.newInstance(2021, 06, 29), 10000, 'Always Connected PC', coMarketingAccCCF.Id,'2-in-1', false);
                campCCF.Core_MDF_Technology__c ='Ice Lake';
                campCCF.Core_MDF_Opal_Budget_Type_Txt__c = 'MDF'; 
                insert campCCF;
                
                List<PartnerFundRequest> pfrCCFList = new List<PartnerFundRequest>();
                PartnerFundRequest pfr = Core_MDF_CCP_TestDataUtility.createPartnerFundRequest(String.valueof(campCCF.Id), 
                                                                                               Core_MDF_CCP_TestDataUtility.PartnerFund_RecordType_CCF,
                                                                                               String.valueof(coMarketingAccCCF.id),null,null,'ALBANIA',
                                                                                               'Gaming',
                                                                                               '2-in-1',
                                                                                               'Intel® Core™ i5 Processor',
                                                                                               'Event',
                                                                                               'Channel Partner Owned Event',
                                                                                               'Draft',
                                                                                               false);
                pfr.Core_MDF_Start_Date__c = Date.newInstance(2021, 01, 01);
                pfr.Core_MDF_End_Date__c  = Date.newInstance(2021, 06, 29);
                pfr.Core_MDF_Fund_Request_Status__c = 'Planned';
                pfr.Title = 'Test CCF Activity 1';
                pfr.Core_MDF_Activity_Description__c = 'Test CCF Activity 1';
                pfr.Core_MDF_Channel_Partner_Led__c = True;
                pfr.Core_MDF_Budget_Amount_Local_amt__c=12345;
                pfr.Core_MDF_Budget_Currency_cd__c='USD';
                pfr.Core_MDF_ActivityCategory__c = 'Digital';
                pfr.Core_MDF_Activity_Types__c = 'Email';
                insert pfr;
            }
        }
        
    }
    
    private static ContentDocument createContentVersion(String title, String fileName) {
        List<ContentDocument> doc = Core_MDF_CCP_TestDataUtility.createContentDocument(true);
        
        // Query to get the auto-created ContentDocument Id and other fields
        return [SELECT Id FROM ContentDocument WHERE Id = :doc[0].Id];
    }
    
    private static Core_MDF_Documents__c createMDFDocument(Id activityId, ContentDocument doc) {
        Core_MDF_Documents__c mdfDoc = new Core_MDF_Documents__c(
            Core_MDF_Activity_id__c = activityId,
            Core_MDF_Document_Id__c = doc.Id,
            Core_MDF_Document_Title_txt__c = 'Test MDF Document',
            Core_MDF_File_Extension_txt__c = 'pdf',
            Core_MDF_ContentVersion_Id__c = doc.Id,
            Core_MDF_Is_Deleted_ind__c = false,
            Core_MDF_SFT_File_Available_ind__c = false,
            Core_MDF_App_File_Id__c = '112233'
        );
        insert mdfDoc;
        return mdfDoc;
    }
    
    @isTest
    static void testGetActivityStatusById_Success() {
        // Get test data
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        Test.startTest();
        String status = Core_MDF_FileRepository.getActivityStatusById(pfr.Id);
        Test.stopTest();
        
        System.assertEquals('Planned', status, 'Status should match the expected value');
    }
    
    @isTest
    static void testGetRelatedMDFDocumentsByRecord_Success() {
        // Get test data
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        ContentDocument doc = createContentVersion('Test Document', 'TestDocument.pdf');
        Core_MDF_Documents__c mdfDoc = createMDFDocument(pfr.Id, doc);
        
        Test.startTest();
        List<Core_MDF_FileRepository.MDFDocumentWrapper> results = 
            Core_MDF_FileRepository.getRelatedMDFDocumentsByRecord(pfr.Id);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return one document');
    }
    
    @isTest
    static void testInsertMDFDocuments_Success() {
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        ContentDocument doc = createContentVersion('Test Document', 'TestDocument.pdf');
        Core_MDF_Documents__c mdfDoc = new Core_MDF_Documents__c(
            Core_MDF_Activity_id__c = pfr.Id,
            Core_MDF_Document_Id__c = doc.Id,
            Core_MDF_Document_Title_txt__c = 'Test MDF Document 2',
            Core_MDF_File_Extension_txt__c = 'pdf',
            Core_MDF_ContentVersion_Id__c = doc.Id,
            Core_MDF_Is_Deleted_ind__c = false,
            Core_MDF_SFT_File_Available_ind__c = false,
            Core_MDF_App_File_Id__c = '11223344'
        );
        
        List<Core_MDF_Documents__c> mdfDocs = new List<Core_MDF_Documents__c>{mdfDoc};
        
        Test.startTest();
        Core_MDF_FileRepository.insertMDFDocuments(mdfDocs);
        Test.stopTest();
        
        // Verify insertion
        List<Core_MDF_Documents__c> insertedDocs = [
            SELECT Id, Core_MDF_File_Extension_txt__c, Core_MDF_File_Size_num__c 
            FROM Core_MDF_Documents__c 
            WHERE Core_MDF_Document_Title_txt__c = 'Test MDF Document 2'
        ];
        
        System.assertEquals(1, insertedDocs.size(), 'Document should be inserted');
    }
    
    @isTest
    static void testInsertMDFDocuments_EmptyList() {
        Test.startTest();
        Core_MDF_FileRepository.insertMDFDocuments(new List<Core_MDF_Documents__c>());
        Core_MDF_FileRepository.insertMDFDocuments(null);
        Test.stopTest();
        
        // No exception should be thrown
        System.assert(true, 'Method should handle empty/null lists gracefully');
    }
    
        
    @isTest
    static void testDeleteMDFDocument_Success() {        
        PartnerFundRequest pfr = [SELECT Id FROM PartnerFundRequest LIMIT 1];
        ContentDocument doc = createContentVersion('Test Document', 'TestDocument.pdf');
        Core_MDF_Documents__c mdfDoc = createMDFDocument(pfr.Id, doc);
        
        System.assertEquals(false, mdfDoc.Core_MDF_Is_Deleted_ind__c, 'Document should not be deleted initially');
        
        Test.startTest();
        Core_MDF_FileRepository.deleteMDFDocument(doc.Id);
        Test.stopTest();
        
        // Verify MDF document is marked as deleted
        Core_MDF_Documents__c updatedDoc = [SELECT Core_MDF_Is_Deleted_ind__c FROM Core_MDF_Documents__c WHERE Id = :mdfDoc.Id];
        System.assertEquals(true, updatedDoc.Core_MDF_Is_Deleted_ind__c, 'Document should be marked as deleted');
        
        // Verify ContentDocument is deleted
        List<ContentDocument> contentDocs = [SELECT Id FROM ContentDocument WHERE Id = :doc.Id];
        System.assertEquals(0, contentDocs.size(), 'ContentDocument should be deleted');
    }
}