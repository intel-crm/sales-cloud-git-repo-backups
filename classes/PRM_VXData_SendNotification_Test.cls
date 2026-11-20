@isTest
public class PRM_VXData_SendNotification_Test {
	/*@testSetup
    public static void testdata(){
        
    }*/
    
    @isTest
    public static void vadataNotifyTest(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_Intel_Account_Record_Type).getRecordTypeId();
        Id recordTypeIdOPIDAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.Label.PRM_ParentAccRecordType).getRecordTypeId();
    	
        //Test Data for Accounts
        List<Account> acc = new List<Account>();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount.Name='Johrt Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_IPA_Partner_Role__c = 'Distributor';
        newAccount.Core_CNDA_Number__c='';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount);
        
        Account newAccount1 = new Account();//Account
        newAccount1.RecordTypeId = recordTypeIdAccount;
        newAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount1.Name='Test 2';
        newAccount1.BillingCity='City';
        newAccount1.BillingStreet='Street';
        newAccount1.BillingCountry='India';
        newAccount1.BillingPostalCode='Postal code';
        newAccount1.Core_IPA_Partner_Role__c = 'FPGA Designer';
        newAccount1.Core_CNDA_Number__c='676875764539878';
        newAccount1.OwnerId = UserInfo.getUserId();
        newAccount1.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount1);
        
        Account newAccount2 = new Account();//Account
        newAccount2.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount2.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        newAccount2.Name='Test 3';
        newAccount2.BillingCity='City';
        newAccount2.BillingStreet='Street';
        newAccount2.BillingCountry='India';
        newAccount2.BillingPostalCode='Postal code';
        newAccount2.Core_IPA_Partner_Role__c = 'FPGA Designer';
        newAccount2.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount2);
        
        Account newAccount3 = new Account();//Account
        newAccount3.RecordTypeId = recordTypeIdOPIDAcc;
        newAccount3.Name='Test 4';
        newAccount3.BillingCity='City';
        newAccount3.BillingStreet='Street';
        newAccount3.BillingCountry='India';
        newAccount3.BillingPostalCode='Postal code';
        newAccount3.Core_IPA_Partner_Role__c = 'Solution Integrator';
        newAccount3.Core_Account_Type__c='Cloud Service Provider (CSP)';
        acc.add(newAccount3);
        insert acc;    
        
        
        //Test Data for Program
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Tier
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        cplList.add(cpl2);
        
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Titanium';
        cpl3.ProgramId=cp.Id;
        cplList.add(cpl3);
        
        insert cplList;
        
        //Test Data for Value Exchange Data
        List<PRM_Value_Exchange_Data__c> vxdataList = new List<PRM_Value_Exchange_Data__c>();
        PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = acc[0].Id;
        vxData1.PRM_Tier_Id__c = cplList[0].Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData1.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        vxdataList.add(vxData1);
        
        PRM_Value_Exchange_Data__c vxData2 = new PRM_Value_Exchange_Data__c();
        vxData2.PRM_Sales_Amount_Nbr__c = 1900000;
        vxData2.PRM_Account_Id__c = acc[1].Id;
        vxData2.PRM_Tier_Id__c = cplList[0].Id;
        vxData2.PRM_Partner_Role_Nm__c = 'Solution Integrator';
        vxData2.PRM_Country_Market_Type_Nm__c = 'Mature';
        vxData2.PRM_Change_Date_Dt__c = System.today();
        vxData2.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData2.PRM_To_Dt__c =Date.Today();
        vxdataList.add(vxData2);
        insert vxdataList;
        PRM_VXData_SendNotification_Messages.sendVxNotification(vxdataList);
        Integer actual = [Select count() from PRM_Value_Exchange_Data__c];
        System.assertEquals(2, actual);
    }
}