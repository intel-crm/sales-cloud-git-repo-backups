@isTest
private class IPAMembershipUtilityTest {

    // Fallback strings for labels (used to simulate label-based logic in code)
    static final String LABEL_CHANGE_REQUEST = Label.PRM_ACM_Change_Request_Label != null ? Label.PRM_ACM_Change_Request_Label : 'Change Request';
    static final String LABEL_PENDING = Label.PRM_Status_Pending != null ? Label.PRM_Status_Pending : 'Pending';
    static final String LABEL_SUBMITTED = Label.Core_MDF_Status_Submitted != null ? Label.Core_MDF_Status_Submitted : 'Submitted';
    static final String LABEL_APPROVED = Label.Core_MDF_Status_Approved != null ? Label.Core_MDF_Status_Approved : 'Approved';
    static final String LABEL_COMPLETE = Label.Core_MDF_Complete != null ? Label.Core_MDF_Complete : 'Complete';
    static final String LABEL_REJECTED = Label.Core_MDF_Status_Rejected != null ? Label.Core_MDF_Status_Rejected : 'Rejected';

    @isTest static void testCheckIfMultipleACMExists_NoErrorAnd_Error() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)'
        );
        insert acc;

        // Create Channel Program and Levels
        ChannelProgram cp = new ChannelProgram(Name = 'IPA Program', PRM_programCode__c = 'IPA');
        insert cp;

        ChannelProgramLevel levelMember = new ChannelProgramLevel(Name = 'Prestige', ProgramId = cp.Id);
        insert levelMember;

        ChannelProgramLevel levelGold = new ChannelProgramLevel(Name = 'Partner', ProgramId = cp.Id);
        insert levelGold;

        // Create ACMs with Account
        PRM_AccountChannelMembership__c acm1 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = acc.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = levelMember.Id,
            PRM_Partner_Role__c = 'Builder',
            PRM_Status_Reason_Txt__c='Test'
        );
        insert acm1;

        PRM_AccountChannelMembership__c acm2 = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = acc.Id,
            PRM_Status_Nm__c = 'Pending',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = levelGold.Id,
            PRM_Partner_Role__c = 'Distributor',
            PRM_Status_Reason_Txt__c='JJ'
        );
        insert acm2;

        // IPA Memberships
        PRM_IPA_Membership__c ipaNoErr = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = acm1.Id,
            PRM_Partner_Role__c = 'Solution Integrator',
            PRM_Partner_Tier__c = levelMember.Id,
            PRM_Status__c = LABEL_PENDING
        );

        PRM_IPA_Membership__c ipaErr = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = acm2.Id,
            PRM_Partner_Role__c = 'Guest',
            PRM_Partner_Tier__c = levelGold.Id,
            PRM_Status__c = LABEL_PENDING
        );

        // Run test for checkIfMultipleACMExists
        Test.startTest();
        IPAMembershipUtility.checkIfMultipleACMExists(new List<PRM_IPA_Membership__c>{ ipaNoErr });
        IPAMembershipUtility.checkIfMultipleACMExists(new List<PRM_IPA_Membership__c>{ ipaErr });
        Test.stopTest();
    }

    @isTest static void testCheckIfAlreadyExists_AllPathsAnd_Exception() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            BillingCity = 'City',
            BillingStreet = 'Street',
            BillingCountry = 'India',
            BillingPostalCode = '123456',
            Core_Account_Type__c = 'Cloud Service Provider (CSP)'
        );
        insert acc;

        // Create Channel Program and Levels
        ChannelProgram cp = new ChannelProgram(Name = 'Intel Partner Alliance', PRM_programCode__c = 'IPA');
        insert cp;

        ChannelProgramLevel levelMember = new ChannelProgramLevel(Name = 'Partner', ProgramId = cp.Id);
        insert levelMember;

        ChannelProgramLevel levelGold = new ChannelProgramLevel(Name = 'Prestige', ProgramId = cp.Id);
        insert levelGold;

        // Create ACM
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c(
            PRM_Account_Id__c = acc.Id,
            PRM_Status_Nm__c = 'Approved',
            PRM_Channel_Program_Id__c = cp.Id,
            PRM_Channel_Program_Level_Id__c = levelMember.Id,
            PRM_Partner_Role__c = 'Solution Integrator',
            PRM_Status_Reason_Txt__c='Test'
        );
        insert acm;

        // Child IPA Memberships (simulate existing)
        PRM_IPA_Membership__c existingChild1 = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = acm.Id,
            PRM_Partner_Role__c = 'Guest',
            PRM_Partner_Tier__c = levelGold.Id,
            PRM_Status__c = LABEL_CHANGE_REQUEST
        );

        PRM_IPA_Membership__c existingChild2 = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = acm.Id,
            PRM_Partner_Role__c = 'Distributor',
            PRM_Partner_Tier__c = levelGold.Id,
            PRM_Status__c = LABEL_PENDING
        );

        insert new List<PRM_IPA_Membership__c>{ existingChild1, existingChild2 };

        // Simulate new incoming IPA request (should hit error branches)
        PRM_IPA_Membership__c newMembership = new PRM_IPA_Membership__c(
            PRM_Account_Channel_Membership__c = acm.Id,
            PRM_Partner_Role__c = 'Builder',
            PRM_Partner_Tier__c = levelGold.Id,
            PRM_Status__c = LABEL_PENDING
        );

        Test.startTest();
        IPAMembershipUtility.checkIfAlreadyExists(new List<PRM_IPA_Membership__c>{ newMembership });
      

        // Run null input check (should hit exception)
        
        IPAMembershipUtility.checkIfAlreadyExists(null);
        

        // Incomplete IPA record (should be handled gracefully)
        PRM_IPA_Membership__c incompleteIPA = new PRM_IPA_Membership__c();
        
        IPAMembershipUtility.checkIfAlreadyExists(new List<PRM_IPA_Membership__c>{ incompleteIPA });
        Test.stopTest();
    }
}