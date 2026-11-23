@isTest()
public class PRM_Specialty_Benefit_Group_Asso_Test {
    
    static testmethod void testduplicateRecordCheck(){
        Test.startTest();
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        bg.PRM_InActive_Ind__c= false;
        insert bg;
        
        PRM_Benefit_Group__c bg1= new PRM_Benefit_Group__c();
        bg1.name = 'Benefitgroup Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty_Benefit_Group_Association__c sbga= new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c = bg.id;
        sbga.PRM_Specialty_Id__c = spec.id;
        insert sbga;
        
        PRM_Specialty_Benefit_Group_Association__c sbga1= new PRM_Specialty_Benefit_Group_Association__c();
        sbga1.PRM_Benefit_Group_Id__c = bg.id;
        sbga1.PRM_Specialty_Id__c = spec.id;
        
        try{ 
            insert sbga1;
            System.assert(false);
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest(); 
    }
    static testmethod void updatetestduplicateRecordCheck(){
        Test.startTest();
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        bg.PRM_InActive_Ind__c= false;
        insert bg;
        
        PRM_Benefit_Group__c bg1= new PRM_Benefit_Group__c();
        bg1.name = 'Benefitgroup Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty_Benefit_Group_Association__c sbga= new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c = bg.id;
        sbga.PRM_Specialty_Id__c = spec.id;
        insert sbga;
        
        PRM_Specialty_Benefit_Group_Association__c sbga2= new PRM_Specialty_Benefit_Group_Association__c();
        sbga2.PRM_Benefit_Group_Id__c = bg1.id;
        sbga2.PRM_Specialty_Id__c = spec.id;
        insert sbga2;
        
        try{ 
            sbga2.PRM_Benefit_Group_Id__c = bg.id; 
            update sbga2;
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
        
        Test.stopTest(); 
        List<PRM_Specialty_Benefit_Group_Association__c> spbgaList = [select Id,PRM_Benefit_Group_Id__r.Name from PRM_Specialty_Benefit_Group_Association__c where id=:sbga2.Id ];
        System.assertNotEquals('Benefitgroup Test', spbgaList[0].PRM_Benefit_Group_Id__r.Name,'Equal');
    }
    static testmethod void asactiveacheck(){
        Test.startTest();
        List<PRM_Specialty_Benefit_Group_Association__c> sbgaList = new List<PRM_Specialty_Benefit_Group_Association__c>();
        PRM_Benefit_Group__c bg= new PRM_Benefit_Group__c();
        bg.name = 'Benefitgroup Test';
        bg.PRM_InActive_Ind__c= false;
        insert bg;
        
        PRM_Benefit_Group__c bg1= new PRM_Benefit_Group__c();
        bg1.name = 'Benefitgroup Test1';
        bg1.PRM_InActive_Ind__c= false;
        insert bg1;
        
        PRM_Specialty__c spec = new PRM_Specialty__c();
        spec.PRM_Description_Txt__c='This is description';
        spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
        spec.PRM_Role_Nm__c='Service Provider';
        spec.PRM_Tier_Nm__c='Gold';
        spec.PRM_Start_Date_Dt__c= system.today() + 7;
        spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
        spec.PRM_Access_Level_Nm__c='Public';
        insert spec;
        
        PRM_Specialty_Benefit_Group_Association__c sbga1= new PRM_Specialty_Benefit_Group_Association__c();
        sbga1.PRM_Benefit_Group_Id__c = bg1.id;
        sbga1.PRM_Specialty_Id__c = spec.id;
        sbga1.PRM_InActive_Ind__c=False;
        insert sbga1;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Johngoth Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Reddick Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
        insert newAccount;
        
        PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
        asa.PRM_Account_Id__c= newAccount.id;
        asa.PRM_Specialty_Id__c= spec.id;
        insert asa;
        
        PRM_Specialty_Benefit_Group_Association__c sbga= new PRM_Specialty_Benefit_Group_Association__c();
        sbga.PRM_Benefit_Group_Id__c = bg.id;
        sbga.PRM_Specialty_Id__c = spec.id;
        sbgaList.add(sbga);
        
        sbga1.PRM_InActive_Ind__c=TRUE;
        sbgaList.add(sbga1);
        try{ 
            database.upsert(sbgaList,false);
            
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
        
        Test.stopTest(); 
        List<PRM_Specialty_Benefit_Group_Association__c> spbgaList = [select Id,PRM_Benefit_Group_Id__r.Name,PRM_InActive_Ind__c  from PRM_Specialty_Benefit_Group_Association__c where id=:sbga1.Id ];
        String v1 = 'False';
        System.assertEquals(false, spbgaList[0].PRM_InActive_Ind__c,v1);
        
    }
}