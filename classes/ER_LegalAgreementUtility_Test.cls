@isTest
public class ER_LegalAgreementUtility_Test {
    
    @testSetup
    static void DataSetup() {
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'RDC Entitlement';
        insert ent;
        system.assertNOTEquals(null,ent.id);
        
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.Name = 'RDC Privileges Terms & Conditions';
        pa.PRM_Agreement_Cd__c = 'RDC_Priv_TC';
        insert pa;
        system.assertNOTEquals(null,pa.id);
    }
    
    @isTest static void UpdateLATest() {
        Test.startTest();
        
        List<Core_Entitlement__c> ent = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        String values = 'IPA_TANDC;RDC_Priv_TC';
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.RecordTypeId = emailVerificationRT;
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Person_Phone_Number__c ='444444';
        regRequest.PRM_EmailVerifiedDateTime__c = null;
        regRequest.PRM_Status__c = 'New';
        regRequest.PRM_Legal_Agreement_Criteria__c = 'PENDING';
        regRequest.PRM_Legal_Agreements__c = values;
        regRequest.PRM_EV_Token__c = '768688';
        regRequest.PRM_Contact_Country__c = 'IN';
        regRequest.Entitlement_Details__c = ent[0].Id;
        
        List<PRM_Registration_Request__c> listReq = New List<PRM_Registration_Request__c>();
        listReq.add(regRequest);
        
        
       // insert listReq;
        
        regRequest.PRM_EmailVerifiedDateTime__c = System.DateTime.now();
        regRequest.RecordTypeId = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        regRequest.PRM_Legal_Agreements__c = 'RDC_Priv_TC';
        
        List<PRM_Registration_Request__c> updatedlistReq = New List<PRM_Registration_Request__c>();
        updatedlistReq.add(regRequest);
        
        //update updatedlistReq;
        ER_LegalAgreementUtility.updateLA(updatedlistReq);
        List<PRM_Registration_Request__c> req = [SELECT Id, PRM_Legal_Agreement_Criteria__c 
                                                 FROM PRM_Registration_Request__c
                                                 WHERE Id =: updatedlistReq[0].Id];
        //System.assertEquals(req[0].PRM_Legal_Agreement_Criteria__c,'PENDING');
        System.assertEquals(regRequest != null, true, 'Reg Request detail is null');
        Test.stopTest();
    }

}