@isTest
public class PRM_Part_Com_Enr_Req_Utility_Test {
    @isTest static void updatePartnerComEnrReqStatus() {
        Id intelConRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId();
        Id comEntitlementRecordTypeId = Schema.SObjectType.PRM_VXEnttlmntMatrix__c.getRecordTypeInfosByName().get('Community Entitlements').getRecordTypeId();
		List<Core_Entitlement__c> conEntiInsertList = new List<Core_Entitlement__c>();
        List<PRM_VXEnttlmntMatrix__c> entMatrixInsertList = new List<PRM_VXEnttlmntMatrix__c>();
        
		Test.startTest();
         Set<String> communitiesAvailable = new Set<String>();
        communitiesAvailable.addAll((System.Label.PRM_Available_Communities).split(';'));
        
        Account acc = PRM_TestUtility.getAccount();
        acc.Core_IPA_Partner_Role__c = 'Service Provider';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry ='';
        acc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);    
        
        Contact con = PRM_TestUtility.getContact();
        con.RecordTypeId = intelConRecordTypeId;
        con.Email='testrequest@mailinator.com';
        con.AccountId = acc.Id;
        con.Core_Job_Function__c='Branch Manager';
        con.Core_eRPM_Language_Code__c='Eng';
        con.Core_IPA_PartnerRole__c = 'Service Provider'; 
        con.Core_Login_Id__c = 'abc';        
        insert con;
        //system.debug(con);
        
         Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'IOT Community User';
        ent.Core_Display_Name__c = 'IOT Community User';
        ent.Core_IsActive__c = true;
        conEntiInsertList.add(ent);
        
        Core_Entitlement__c ent1 = new Core_Entitlement__c();
        ent1.Name = 'Cloud Community User';
        ent1.Core_Display_Name__c = 'Cloud Community User';
        ent1.Core_IsActive__c = true;
        conEntiInsertList.add(ent1);
        
        Core_Entitlement__c ent2 = new Core_Entitlement__c();
        ent2.Name = 'FPGA Community User';
        ent2.Core_Display_Name__c = 'FPGA Community User';
        ent2.Core_IsActive__c = true;
        conEntiInsertList.add(ent2);
         if(conEntiInsertList.size() > 0){
            insert conEntiInsertList;
        }
        
        PRM_VXEnttlmntMatrix__c entMatrix = new PRM_VXEnttlmntMatrix__c();
        entMatrix.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix.Communities__c = 'Intel® IOT Solution Partner';
        entMatrix.PRM_Entitlement_Id__c = conEntiInsertList[0].id;
        entMatrixInsertList.add(entMatrix);
       
        PRM_VXEnttlmntMatrix__c entMatrix1 = new PRM_VXEnttlmntMatrix__c();
        entMatrix1.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix1.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix1.Communities__c = 'Intel® Cloud Insider Partner';
       
        entMatrix1.PRM_Entitlement_Id__c = conEntiInsertList[1].id;
        entMatrixInsertList.add(entMatrix1);
        
        PRM_VXEnttlmntMatrix__c entMatrix2 = new PRM_VXEnttlmntMatrix__c();
        entMatrix2.RecordTypeId = comEntitlementRecordTypeId;
        entMatrix2.PRM_Approval_Type_Nm__c = 'Automatic';
        entMatrix2.Communities__c = 'Intel® FPGA Partner';
        entMatrix2.PRM_Entitlement_Id__c = conEntiInsertList[2].id;
        entMatrixInsertList.add(entMatrix2);
        
         if(entMatrixInsertList.size() > 0){
            insert entMatrixInsertList;
        }
        
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c();
        ce1.Core_Contact_Id__c = con.id;
        ce1.Core_Selected__c = true;
        ce1.Core_Entitlement_Id__c =ent.id ;
        ce1.Core_Data_Loaded__c = true;
        insert ce1;
        
        Core_Contact_Entitlement__c ce2 = new Core_Contact_Entitlement__c();
        ce2.Core_Contact_Id__c = con.id;
        ce2.Core_Selected__c = true;
        ce2.Core_Entitlement_Id__c =ent1.id ;
        ce2.Core_Data_Loaded__c = true;
        insert ce2;
        
        Core_Contact_Entitlement__c ce3 = new Core_Contact_Entitlement__c();
         ce3.Core_Contact_Id__c = con.id;
        ce3.Core_Selected__c = true;
        ce3.Core_Entitlement_Id__c =ent2.id ;
        ce3.Core_Data_Loaded__c = true;
        insert ce3;
        
        
        PRM_Partner_Community_Enrollment_Request__c parCom = new PRM_Partner_Community_Enrollment_Request__c();
        parCom.PRM_Contact_Id__c = con.id;
        parCom.PRM_Partner_Community_Nm__c='Intel® FPGA Partner';
        parCom.PRM_Status_Nm__c = 'Pending';
        
        insert parCom;
        //system.debug(parCom);
        
        parCom.PRM_Status_Nm__c = 'Rejected';
        update parCom;
        
        Test.stopTest();
      	System.assertEquals(parCom.PRM_Partner_Community_Nm__c,entMatrixInsertList[2].Communities__c,'Value does not match');
        
    }

}