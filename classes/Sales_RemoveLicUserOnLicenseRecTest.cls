@isTest
public with sharing class Sales_RemoveLicUserOnLicenseRecTest {
    /*@isTest
    private static void shouldRemoveLicenseUser(){
        Contact con =Sales_TestDataFactory.createContactRecord();
        insert con;
        Sales_License__c lic=Sales_TestDataFactory.createLicenseRecord();
        lic.Sales_License_Lic_User_Contact_ID__c=con.Id;
        insert lic;
        Test.startTest();
        Boolean returnValue=Sales_RemoveLicUserOnLicenseRecordCtrl.removeLicUserFromUser(lic.Id);
        String isReturnMsg=Sales_RemoveLicUserOnLicenseRecordCtrl.removeHostfromLicenseRecord(lic.Id);
        Test.stopTest();
        System.assert(returnValue);
    }
    @isTest
    private static void shouldRemoveLicenseUser1(){
        Contact con =Sales_TestDataFactory.createContactRecord();
        insert con;
        String companionServerId='142456789014';
        String companionServerId2 = '152456789015';
        Sales_Host__c hostRecord = createHostRecord('Computer1','FIXED','NIC ID',con.Id,companionServerId,companionServerId2,null,null);
        Sales_License__c lic=Sales_TestDataFactory.createLicenseRecord();
        lic.Sales_License_Lic_User_Contact_ID__c=con.Id;
        lic.Sales_License_Host_Node_Id__c=hostRecord.Id;
        lic.Sales_License_Avbl_Rehost_Nbr__c=1;
        insert lic;
        Test.startTest();
        String isReturnMsg=Sales_RemoveLicUserOnLicenseRecordCtrl.removeHostfromLicenseRecord(lic.Id);
        Test.stopTest();
    }
    public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1,String compServ2, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        if(compType=='HOST ID')
            h.Name='AAA36AAA';
        else if(compType=='NIC ID')
            h.Name='176253490832';  
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Companion_Server2_Txt__c = compServ2;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        h.Sales_Host_Is_Created_From_Custom_Page__c = true;
        insert h;
        return h;
    }*/
}