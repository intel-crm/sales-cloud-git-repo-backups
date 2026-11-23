/***************************************************************************
Class Name    : Sales_TransferPrimaryAdminBatch_Test
Version       : 1.0
Created Date  : 21 march 2023         
Modification Log :
* Developer                 Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Ranjit        21/03/2023              Test Class for Sales_TransferPrimaryAdminBatch Class.
*****************************************************************************************************************************************/
@isTest
public class Sales_TransferPrimaryAdminBatch_Test {
/*    @isTest public static void processLicenseRecordsTest(){
        PRM_Execution_Controls__c t = new PRM_Execution_Controls__c();
        t.SetupOwnerId=userInfo.getUserId();
        insert t;
        String errmsg='';
        Account acc = Sales_TestDataFactory.createDefaultAccount();
        insert acc;       
        List<Sales_License_Generator__c> licGen = Sales_TestFactory_Utility.createLiceneseGenerator();
        List<Sales_License_Group__c> lcGrp= Sales_TestFactory_Utility.createLiceneseGroup(licGen[0].Id);
        Core_Product_Ext_Attribute__c extAttribute = new Core_Product_Ext_Attribute__c();
        extAttribute.Core_SW_Lic_Enforcement_Method_Nm__c = 'File';
        extAttribute.Core_Prod_Tool_Type_Nm__c = 'Base';
        extAttribute.Core_SW_Lic_Type_Nm__c = 'FLOAT' ; 
        extAttribute.Core_SW_Prod_Max_Rehost_Cnt__c = 1;
        extAttribute.Core_SW_Prod_Web_Dsc__c='Test';
        extAttribute.Core_SW_Lic_File_Data_Encryption_Std_Cd__c = '1DES' ;
        extAttribute.Core_SW_Prod_Avail_To_TL_ORD_ENBLMT_Ind__c = true;
        extAttribute.Core_SW_Lic_Generator_Parameter_Txt__c = 'testing';
        insert extAttribute;
        Product2 prd =new Product2();
        prd.Name = 'Test Foundation Product';
        prd.Description='Test Foundation Product Entry 2';
        prd.productCode = 'ABC2878';
        prd.isActive = true;
        prd.Core_Item_Orderable_Ind__c = true;
        prd.Core_Item_Class_Nm__c='SV';
        prd.Core_Product_Ext_Attribute_Id__c = extAttribute.Id;
        insert prd;  
        Contact con1 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        Contact con2 = Sales_TestDataFactory.createContactRecord(new Map<String,String>{'AccountId' => acc.Id});
        insert new List<Contact>{con1,con2};
            Sales_License_Admin_Delegate__c licAdmDlg = Sales_TestDataFactory.createLicenseAdminDelegateRecord(new Map<String,String>{
                'Sales_License_PrimaryAdmin_Contact__c' => con1.Id , 'Sales_License_DlgAdmin_Contact__c' => con2.Id
                    }); 
        insert licAdmDlg;
        Sales_Host__c hostObj1 = Sales_TestDataFactory.createComputerRecord(new Map<String,String>{ 'Sales_Contact__c'=>con1.Id, 'Sales_Host_Is_Created_From_Custom_Page__c' => 'true' });
        insert hostObj1;
        Sales_License__c lic = Sales_TestDataFactory.createLicenseRecord(new Map<String,String>{'Sales_License_Host_Node_Id__c'=>hostObj1.Id , 'Sales_License_Primary_Admin_Contact__c'=>con1.Id});      
        lic.Sales_License_Product__c=prd.id;
        lic.Sales_License_Available_Temp_Licenses__c=5;
        lic.Sales_License_Quantity__c=0;
        insert lic;
        System.Test.startTest();
        try{            
            Database.executeBatch(new Sales_TransferPrimaryAdminBatch(con1.id,con2.id),Integer.ValueOf(System.Label.Sales_TransferPrimaryAdminBatchSize));					    
        }catch(Exception e){
            errMsg = e.getMessage();
        }
        System.Test.stopTest();
        System.assertEquals(errMsg,'');
    }
*/
}