/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_Batch_Populate_Territory_Test 
Version     : 1.0 
Created Date: 04 SEP 2015
Function    : 
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kalpana Choudhary         09/04/2015             
*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_Batch_Populate_Territory_Test {
    static testMethod void testPopulateterri(){
        list<territory2type> tTypeList = new list<territory2type>();
            list<territory2> territoryList = new list<territory2>();
            Territory2Model tModel = new Territory2Model();
                tModel.name = 'test';
                tModel.developername = 'test';
                insert tModel;
                // DML not allowed on Territory2Type object. so extracting recrds using Soql.
                Id tBusinessType = [Select id from territory2type where MasterLabel = 'Business Units and Specialists'].Id;
                Id tGeographicType = [Select id from territory2type where MasterLabel = 'Geographic World Wide'].Id;
                Id tNamedType = [Select id from territory2type where MasterLabel = 'Named / Strategic Accounts'].Id;
                territory2 t = new territory2();
                    t.name = 'test';
                    t.developername = 'test';
                    t.Territory2ModelId = tModel.Id;
                    t.territory2typeId = tBusinessType;
                    territoryList.add(t);
                territory2 t1 = new territory2();
                    t1.name = 'test';
                    t1.developername = 'test1';
                    t1.Territory2ModelId = tModel.Id;
                    t1.territory2typeId = tGeographicType;
                    territoryList.add(t1);
                territory2 t2 = new territory2();
                    t2.name = 'test';
                    t2.developername = 'test2';
                    t2.Territory2ModelId = tModel.Id;
                    t2.territory2typeId = tNamedType;
                    territoryList.add(t2);
    
            insert territoryList;
            
            System.runAs(Core_Test_Utility.systemAdminUser) {
                list<Account> acclist = new list<Account>();
                list<Opportunity> opplist = new list<Opportunity>();
                // Create the configuration item so the Insert and Update trigger on Opportunity gets executed
                Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c( 
                    Name='UpdateTerritoryInfoOnOppty', Core_Class_Name__c='Core_OpportunityHandler', Core_Object__c='Opportunity', 
                    Core_Trigger_Events__c='before Insert before update', Core_Active__c=true, Core_Description__c = 'For testing territory information on Opportunity');
        
                insert triggerExec;
            
                // Create a new account  
                Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' limit 1][0].Id;
                Account acct = new Account(Name = 'Test Account territory', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                Account acct1 = new Account(Name = 'Test Account territory1', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                Account acct2 = new Account(Name = 'Test Account territory2', BillingStreet = '123 Fake St',RecordTypeId = newAccountRecTypeId,
                                           BillingCity = 'Springfield', BillingState = 'IL', BillingCountry = 'USA',
                                           BillingPostalCode = '12345', Core_CIM_ID__c = '8675309');
                
                acclist.add(acct);acclist.add(acct1);acclist.add(acct2);
                insert acclist;
                
                //test.starttest();
                // Create a new opportunity using the account created above
                Id newOppRecTypeId = [select Id from RecordType where DeveloperName = 'Core_New_Opportunity' limit 1][0].Id;
                Opportunity opp = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                       AccountId = acclist[0].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
                Opportunity opp1 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                       AccountId = acclist[1].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
                Opportunity opp2 = new Opportunity(Name = 'Test Opportunity1', RecordTypeId = newOppRecTypeId,
                                                       AccountId = acclist[2].Id, StageName = 'Qualify', CloseDate = System.Date.today().addYears(1));
                opplist.add(opp);opplist.add(opp1);opplist.add(opp2);
                insert opplist;
                test.starttest();
                list<ObjectTerritory2Association> objectassocitelist = new list<ObjectTerritory2Association>();
                for(integer j = 0; j< 3 ; j++){
                    ObjectTerritory2Association oTerri2 = new ObjectTerritory2Association();
                    oTerri2.ObjectId = acclist[j].Id;
                    oterri2.territory2Id = territoryList[j].Id;
                    oterri2.AssociationCause  = 'Territory2Manual';
                    objectassocitelist.add(oTerri2);
                }
                insert objectassocitelist;
                Core_Batch_Populate_Territory populateTerri = new Core_Batch_Populate_Territory();
                database.executebatch(populateTerri);
                test.stoptest();
        
        }
      }  
}