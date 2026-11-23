@isTest
public class PRM_PointsBatchClassTest {
	
    @isTest
    public static void test(){
        //account oPID and location
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        
        PRM_Point_Data_Stage__c pds = new PRM_Point_Data_Stage__c();
        pds.PRM_Available_Points_nbr__c	=200;
        pds.PRM_Expired_Points_nbr__c	=100;
        pds.PRM_Account_Id_txt__c = newAccount.Id;
        pds.PRM_One_Partner_ID_txt__c	=newPagAccount.Id;
        pds.PRM_Points_Earned_nbr__c	=100;
        pds.PRM_Points_Exp_In_Current_Quarter_nbr__c	=200;
        pds.PRM_Points_Redeemed_nbr__c	=200;
        insert pds;
        
        Test.startTest();
        Database.executeBatch(new PRM_PointsBatchClass());
        
        PRM_Point_Data_Stage__c pds1 = new PRM_Point_Data_Stage__c();
        pds1.PRM_Available_Points_nbr__c	=200;
        pds1.PRM_Expired_Points_nbr__c	=100;
        pds1.PRM_Account_Id_txt__c = newAccount.Id;
        pds1.PRM_One_Partner_ID_txt__c	=null;
        pds1.PRM_Points_Earned_nbr__c	=100;
        pds1.PRM_Points_Exp_In_Current_Quarter_nbr__c	=200;
        pds1.PRM_Points_Redeemed_nbr__c	=200;
        insert pds1;
        
        
        Database.executeBatch(new PRM_PointsBatchClass());
        
        
        PRM_Point_Data_Stage__c pds11 = new PRM_Point_Data_Stage__c();
        pds11.PRM_Available_Points_nbr__c	=200;
        pds11.PRM_Expired_Points_nbr__c	=100;
        pds11.PRM_Account_Id_txt__c = newAccount.Id;
        pds11.PRM_One_Partner_ID_txt__c	=newPagAccount.Id;
        pds11.PRM_Points_Earned_nbr__c	=100;
        pds11.PRM_Points_Exp_In_Current_Quarter_nbr__c	=200;
        pds11.PRM_Points_Redeemed_nbr__c	=200;
        insert pds11;
        
		
        Database.executeBatch(new PRM_PointsBatchClass());
        Test.stopTest();
    }
}