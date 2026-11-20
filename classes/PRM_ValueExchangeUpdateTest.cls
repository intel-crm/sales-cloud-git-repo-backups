@isTest
public class PRM_ValueExchangeUpdateTest {
    @isTest
    public static void inactiveBenefitTestprofile(){
      
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id OpidAccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.RecordTypeId = recordTypeIdAccount;
        testAccount.Name='John Wick';
        testAccount.BillingCity='City';
        testAccount.BillingStreet='Street';
        testAccount.BillingCountry='India';
        testAccount.BillingPostalCode='Postal code';
        testAccount.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount;
        Account testAccount21 = new Account();
        testAccount21.RecordTypeId = recordTypeIdAccount;
        testAccount21.Name='John Wick11';
        testAccount21.BillingCity='Citysd';
        testAccount21.BillingStreet='Streetad';
        testAccount21.BillingCountry='India';
        testAccount21.BillingPostalCode='Postal code';
        testAccount21.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount21.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount21;
        
        Account testAccount1 = new Account();
        testAccount1.RecordTypeId = recordTypeIdAccount;
        testAccount1.Name='John Wickneww';
        testAccount1.BillingCity='Cityw';
        testAccount1.BillingStreet='Streew';
        testAccount1.BillingCountry='India';
        testAccount1.BillingPostalCode='Postal cwode';
        testAccount1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        testAccount1.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert testAccount1;
        
        Account parent1 = new Account();
        parent1.RecordTypeId = OpidAccRecordTypeId;
        parent1.Name='Cello Ltd';
        parent1.BillingCity='New City';
        parent1.BillingStreet='New Street';
        parent1.BillingCountry='India';
        parent1.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent1;
        
        Account parent2 = new Account();
        parent2.RecordTypeId = OpidAccRecordTypeId;
        parent2.Name='Cello Ltdasd';
        parent2.BillingCity='New Cityss';
        parent2.BillingStreet='New Streetass';
        parent2.BillingCountry='India';
        parent2.BillingPostalCode='999999';
        parent1.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        insert parent2;
        
        ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;
        
        ChannelProgramLevel cplTest = new ChannelProgramLevel(); //Channel Program Level
        cplTest.Name='Gold';
        cplTest.ProgramId=cpTest.Id;
        insert cplTest;
        
        PRM_Value_Exchange_Data__c valueex1=new PRM_Value_Exchange_Data__c();
        valueex1.PRM_Training_Credit_Points_Count_Nbr__c=78;
        valueex1.PRM_Account_Id__c=testaccount21.Id;
        valueex1.PRM_One_Partner_Id__c = parent2.id;                
        valueex1.PRM_Change_Date_Dt__c=system.today()+2;
        valueex1.PRM_Country_Market_Type_Nm__c='Mature';
        valueex1.PRM_From_Dt__c=system.today();
        valueex1.PRM_Partner_Role_Nm__c='Service Provider';
        valueex1.PRM_Tier_Id__c=cplTest.Id;
        valueex1.PRM_To_Dt__c=system.today()+1;
        valueex1.PRM_TimePeriod_Nm__c = 'Q4 2023 - Q3 2024';
        insert valueex1;
        
        PRM_Value_Exchange_Data__c valueex=new PRM_Value_Exchange_Data__c();
        valueex.PRM_Training_Credit_Points_Count_Nbr__c=788;
        valueex.PRM_Account_Id__c=parent1.Id;
        //valueex.PRM_One_Partner_Id__c = parent1.id;                
        valueex.PRM_Change_Date_Dt__c=system.today()+2;
        valueex.PRM_Country_Market_Type_Nm__c='Mature';
        valueex.PRM_From_Dt__c=system.today();
        valueex.PRM_Partner_Role_Nm__c='Service Provider';
        valueex.PRM_Tier_Id__c=cplTest.Id;
        valueex.PRM_To_Dt__c=system.today()+1;
        valueex.PRM_TimePeriod_Nm__c = 'Q4 2023 - Q3 2024';
        insert valueex;
        
         PRM_Value_Exchange_Data__c vxData1 = new PRM_Value_Exchange_Data__c();
        //vxData1.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData1.PRM_Account_Id__c = testAccount1.id;
        vxData1.PRM_One_Partner_Id__c = parent1.id;
        vxData1.PRM_Tier_Id__c = cplTest.Id;
        vxData1.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData1.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData1.PRM_Training_Credit_Points_Count_Nbr__c=5001;
        vxData1.PRM_Change_Date_Dt__c = System.today();
        vxData1.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData1.PRM_To_Dt__c =Date.Today();
        valueex.PRM_TimePeriod_Nm__c = 'Q4 2023 - Q3 2024';  
        insert vxData1;
         
        PRM_Value_Exchange_Data__c vxData11 = new PRM_Value_Exchange_Data__c();
        //vxData11.PRM_Sales_Amount_Nbr__c = 2000000;
        vxData11.PRM_Account_Id__c = testAccount1.id;
        vxData11.PRM_One_Partner_Id__c = parent1.id;
        vxData11.PRM_Tier_Id__c = cplTest.Id;
        vxData11.PRM_Partner_Role_Nm__c = 'Distributor';
        vxData11.PRM_Country_Market_Type_Nm__c = 'NA';
        vxData11.PRM_Training_Credit_Points_Count_Nbr__c=50;
        vxData11.PRM_Change_Date_Dt__c = System.today();
        vxData11.PRM_From_Dt__c = Date.Today().addDays(-2);
        vxData11.PRM_To_Dt__c =Date.Today();
        valueex.PRM_TimePeriod_Nm__c = 'Q4 2023 - Q3 2024';  
        insert vxData11;
        
    
    
    test.startTest();
    Id batchJobId = Database.executeBatch(new PRM_ValueExchangeUpdateBatch('Q4 2023 - Q3 2024'),20);
    test.stopTest();
    }
       
}