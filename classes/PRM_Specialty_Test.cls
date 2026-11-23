/****************************************************************************************************************************
Apex Class Name     : PRM_Specialty_Test 
Version             : 1.0
Created Date        : 09 Jan 2020

Modification Log    :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------------
* Teja Munagala      09-Jan-2020                   Added a new method specActiveCheck to restrict Name change and Inative Specialty check

****************************************************************************************************************************/
@isTest()
public class PRM_Specialty_Test {
    
    public static testmethod void specActiveCheck(){
        Id i;
        Test.startTest(); 
        try{
            List<PRM_Specialty__c> speciality = new List<PRM_Specialty__c>();
            
            Account newAccount = new Account();//Account
            newAccount.Name='Joh pointing';
            newAccount.BillingCity='city';
            newAccount.BillingStreet='Street1';
            newAccount.BillingCountry='India';
            newAccount.BillingPostalCode='Postal code1';
            newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
            newAccount.Core_IPA_Partner_Speciality__c='';
            newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c=true;
            insert newAccount;
            
            PRM_Specialty__c spec = new PRM_Specialty__c();
            spec.name='Visual Retail Specialist';
            spec.PRM_Description_Txt__c='This is description';
            spec.PRM_Funding_BU_Nm__c='CCG Sales Group';
            spec.PRM_Role_Nm__c='Service Provider';
            spec.PRM_Tier_Nm__c='Gold';
            spec.PRM_Start_Date_Dt__c= system.today() + 7;
            spec.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
            spec.PRM_Access_Level_Nm__c='Public';
            insert spec;
            
            PRM_Specialty__c spec1 = new PRM_Specialty__c();
            spec1.name='Retail Visual Solutions Specialist';
            spec1.PRM_Description_Txt__c='This is description';
            spec1.PRM_Funding_BU_Nm__c='CCG Sales Group';
            spec1.PRM_Role_Nm__c='Service Provider';
            spec1.PRM_Tier_Nm__c='Gold';
            spec1.PRM_Start_Date_Dt__c= system.today() + 7;
            spec1.PRM_End_Date_Dt__c= spec.PRM_Start_Date_Dt__c + 5;
            spec1.PRM_Access_Level_Nm__c='Public';
            insert spec1;
            i = spec1.Id;
            PRM_Account_Specialty_Association__c asa = new PRM_Account_Specialty_Association__c();
            asa.PRM_Account_Id__c= newAccount.id;
            asa.PRM_Specialty_Id__c= spec.id;
            asa.PRM_InActive_Ind__c= false;
            insert asa;
            
            PRM_Account_Specialty_Association__c asa1 = new PRM_Account_Specialty_Association__c();
            asa1.PRM_Account_Id__c= newAccount.id;
            asa1.PRM_Specialty_Id__c= spec1.id;
            asa1.PRM_InActive_Ind__c= false;
            insert asa1;
            
            spec.Name='Industrial Solutions Builder Specialist';
            speciality.add(spec);
            spec1.PRM_Inactive_Ind__c=true;
            speciality.add(spec1);
            update speciality;
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
        
        Test.stopTest();
        List<PRM_Specialty__c> spcList = [select ID,PRM_Inactive_Ind__c from PRM_Specialty__c where Id=:i ];
        System.assert(spcList[0].PRM_Inactive_Ind__c = true);
    }
}