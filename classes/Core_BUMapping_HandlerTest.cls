/****************************************************************************************************************************************
* Class Name  : Core_BUMapping_HandlerTest 
* Version     : 1.0 
* Created Date: 25-08-2022
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Mula Yeshwanth        25/08/2022                   Created Core_BUMapping_HandlerTest to test 
*****************************************************************************************************************************************/
@isTest
public class Core_BUMapping_HandlerTest {
/****************************************************************************************************************************************
Method Name:                                   createBUOwnerRecord
Description:                                   Created createBUOwnerRecord() to test BU Owner is created when shortname is not available
Added By:                                      Mula Yeshwanth      -  25/08/2022
Modified By:                  Date:            Changes: 
Mula Yeshwanth              25/08/2022         Created.
*****************************************************************************************************************************************/
    
    @isTest static void createBUOwnerRecord(){
        //BU Mapping List
        List<Core_BU_Mapping_Table__c> BuMappinglist = new List<Core_BU_Mapping_Table__c>();
        
        Core_BU_Mapping_Table__c BuMapping = new Core_BU_Mapping_Table__c();
        BuMapping.Core_BU_Segment__c = 'Computing';
        BuMapping.Core_BU_Shortname__c = 'DCG';
        Database.insert(BuMapping); 
        
        Core_BU_Mapping_Table__c BuMapping1 = new Core_BU_Mapping_Table__c();
        BuMapping1.Core_BU_Segment__c = 'Computing';
        BuMapping1.Core_BU_Shortname__c = 'YSW';
        Database.insert(BuMapping1);
        
        Core_BU_Owner_Table__c BUOwner = new Core_BU_Owner_Table__c();
        BUOwner.Core_BU_Shortname__c = 'DCG';
        Database.insert(BUOwner);
        
        BuMappinglist.add(BuMapping);
        BuMappinglist.add(BuMapping1);
        
       // test.startTest();
        //        Core_BUMapping_Handler.createBUOwnerRecord(BuMappinglist);
        //    test.stopTest();
        
    }
    
}