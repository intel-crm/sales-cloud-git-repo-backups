@isTest
public class Sales_BulkHostProcessLicGenQueueTest{
    /*public static Sales_Host__c createHostRecord(String compName, String LicType, String compType, Id primAdmContactId, String compServ1, String redServ1, String redServ2){
        Sales_Host__c h = new Sales_Host__c();
        h.name=compName;
        h.Sales_isActiveHost__c = true;
        h.Sales_Computer_Name_Txt__c = compName;
        h.Sales_Computer_Type__c = compType;
        h.Sales_License_Type__c = LicType;
        h.Sales_Contact__c = primAdmContactId;
        h.Sales_Companion_Server1_Txt__c = compServ1;
        h.Sales_Redundant_Server1_Txt__c = redServ1;
        h.Sales_Redundant_Server2_Txt__c = redServ2;
        insert h;
        return h;
    }
    @isTest
    static void Sales_BulkHostProcessLicGenQueue(){
        Account accObj = Sales_TestFactory_Utility.createAccount(); 
        Contact con = Sales_TestFactory_Utility.createContact(accObj.id);
        Sales_Host__c host= Sales_LicenseGenIntegration_Utility_Test.createHostRecord('111122223344','FIXED','NIC ID',con.Id,'','','');
        List<Sales_License_Generator__c> licenseGen = new List<Sales_License_Generator__c>();
        Sales_License_Generator__c lGen = new  Sales_License_Generator__c();
        lGen.Name='Gen1';
        lGen.Sales_License_Vendor__c='Mentor Graphics';
        lGen.Sales_License_Generator_txt__c='genlic';
        lGen.Sales_License_Feature_Lyn_Syntx_txt__c='Gen';
        licenseGen.add(lGen);
        insert licenseGen;
        Sales_License_Group__c lgp = new Sales_License_Group__c();
        lgp.Name = 'lgp1';
        lgp.Sales_License_Generator__c = licenseGen[0].id ;
        insert lgp;                     
        Product2 p = new Product2();
        p.Name = ' Test Corporate Product';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        p.Core_Item_Orderable_Ind__c = true;
        p.SBQQ__SubscriptionTerm__c=10;
        p.SBQQ__SubscriptionPricing__c ='Fixed Price';
        p.SBQQ__SubscriptionType__c = 'One-time';
        insert p; 
        Core_Product_Ext_Attribute__c l1 = new Core_Product_Ext_Attribute__c();
        l1.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        l1.Core_Prod_Tool_Type_Nm__c = 'BASE';
        l1.Core_SW_Lic_Type_Nm__c = 'FIXED' ; 
        l1.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        l1.Core_SW_Prod_Web_Dsc__c='Test';
        l1.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        l1.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        l1.Core_SW_Lic_Group_Id__c = lgp.id;
        l1.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        l1.Core_SW_Prod_Expiration_Duration_Nbr__c = 45;
        l1.Core_SW_Prod_Non_Commercial_Purpose_Nm__c='Employee';
        l1.Core_Foundation_Product_Id__c=p.id;
        l1.Core_Product_Id__c=p.id;
        insert l1;   
        Sales_License__c lic=new Sales_License__c();
        lic.Sales_License_Quantity__c=1;
        lic.Sales_License_Product_Name_Txt__c='Test';
        lic.Sales_License_Maintenance_Exp_Dt__c=system.today();
        lic.Sales_License_Expiration_Date_Dt__c=system.today()+1;
        lic.Sales_License_Start_Date_Dt__c=system.today();
        lic.Sales_License_Status__c='Licensed';
        lic.Sales_License_Avbl_Qty_Nbr__c=1;
        lic.Sales_License_Avbl_Rehost_Nbr__c=1;
        lic.Opt_in_out__c=true;
        lic.Sales_License_Web_Display_Flag__c=false;
        lic.Sales_License_Type__c='Optional';
        lic.Sales_License_Product__c=p.id;
        lic.Sales_License_Host_Node_Id__c=host.id;
        insert lic;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new Sales_LicenseGenIntegrationCallout(200,'Success')); 
        Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
        connectSettingRecord.Sales_Access_Token__c='TestToken';
        connectSettingRecord.Sales_Expires_In_Seconds__c=3599;
        connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(3599));
        connectSettingRecord.Name ='SAP License Token Details';
        insert connectSettingRecord;
        set<id> hostId=new set<Id>();
        hostId.add(host.id);
        try{
            System.enqueueJob(new Sales_BulkHostProcessLicGenQueueable(hostId,'isOrderTrigger'));
        }Catch(Exception e){
            e.getMessage();
        }
        test.stopTest();
    }*/
}