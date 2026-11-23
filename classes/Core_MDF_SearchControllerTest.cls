@isTest	
public class Core_MDF_SearchControllerTest {
    
    @isTest
    public static void Core_MDF_SearchController_Test() {
        String objectName='Campaign';
        List<String> fields=new List<String>();
        fields.add('Name');
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', false);
            insert cp1;
        Account ccfacc = Core_MDF_CCP_TestDataUtility.createAccount ('Co-marketing CCF Test Account', 
                                                                         cp1.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
         Account intacc = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', 
                                                                              Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            intacc.Core_Account_Type__c = 'Reseller';
            intacc.Industry = 'Food & Beverage';
            Database.insert(intacc);
            ccfacc.Core_MDF_Parent_Fund_Account__c = intacc.Id;
            ccfacc.Core_MDF_CoMarketingActive__c = true;
            //accList.add(ccfacc);
             insert ccfacc;
              
          Campaign campCAP = Core_MDF_CCP_TestDataUtility.createCampaign('Campaign CAP Campaign','Gaming','Intel® Core™ i7+ Processor','Yes' ,Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', /*Date.newInstance(2021, 01, 01)*/System.Today().addDays(-180), /*Date.newInstance(2022, 06, 30).*/System.Today().addDays(180), 10000, 'Consumer Chromebook', ccfacc.Id, '2-in-1', false);
          campCAP.Core_MDF_Opal_Budget_Type_Txt__c= 'OEM CMP';
          Database.insert(campCAP);
        
             Test.startTest();
             Core_MDF_SearchController.search(objectName,fields,ccfacc.Name);
             Core_MDF_SearchController.search(objectName,fields,'');
             Core_MDF_SearchController.getRecentlyCreatedRecord(campCAP.Id,fields,objectName);
        
            // Unit Test Method should include System.Assert - Indira
            System.assertNotEquals(null,Core_MDF_SearchController.search(objectName, fields, ''),'Search with empty string should return a valid list');

        try{ 
             List<String> fields1=new List<String>();
             fields1.add('ABC');
             objectName = 'BCD';
        	 Core_MDF_SearchController.getRecentlyCreatedRecord(null,fields1,objectName);
             Core_MDF_SearchController.search(objectName,fields1,'@$%*$#2');
        }
        catch(exception e){
            system.assert(e != null);
        }
             Test.stopTest();
    }

}