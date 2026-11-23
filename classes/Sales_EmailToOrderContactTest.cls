/*********************************************************************************************************************
Class Name    : Sales_EmailToOrderContactTest
Version       : 1.0
Created Date  : July 2021
Function      :  
Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Bharath Kumar           07-July-2021             Test class for Sales_EmailToOrderContact 
* *********************************************************************************************************************/
@isTest
public class Sales_EmailToOrderContactTest {
  /*public static testMethod void sendEmailsOnOrderActivation(){
    Test.startTest();
      Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
      User dummyUsr = new User(Alias = 'Dummy', Email='dummyUserTest@intel.com',
         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
         LocaleSidKey='en_US', ProfileId = p.Id,
         TimeZoneSidKey='America/Los_Angeles', UserName= 'dummySalesCreat@testorg.com');
      insert dummyUsr;
      Account acc = Sales_TestFactory_Utility.createAccount();
      Id prcBkId = Test.getStandardPricebookId(); 
       System.runAs(dummyUsr) {
        
      List<Order> orderList = Sales_TestFactory_Utility.createListofOrders(acc.Id, prcBkId, 'Partner License Order'); 
      List<Order> OrdList=[select Id,CreatedById from Order where id=:orderList[0].id];     
      Sales_EmailToOrderContact.sendEmailToOrderCreator(OrdList);   
      }
      Test.stopTest();         
    }*/
  }