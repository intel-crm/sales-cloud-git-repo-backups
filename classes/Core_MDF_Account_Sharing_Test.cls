/******************************************************************************************************
* Class Name  : Core_MDF_Account_Sharing_Test 
* Version     : 1.0 
* Created Date: 24-08-2020
* Modification Log :
*******************************************************************************************************/
@isTest(SeeAllData = false)
public class Core_MDF_Account_Sharing_Test {
    static testmethod void testMetadata(){
        ChannelProgram channelProgram = Core_MDF_CCP_TestDataUtility.createProgram (Core_MDF_CCP_ConstantClass.CCF_PROGRAM,'Client CoMarketing Fund', true);
        
        Id channelProgramID =channelProgram.Id;
       
        List<Core_MDF_ChannelProgram__mdt> channelProgramMeta= (List<Core_MDF_ChannelProgram__mdt>) System.JSON.deserialize('[{"Label":"'+Core_MDF_CCP_ConstantClass.CCF_PROGRAM+'","Core_MDF_Program_ID__c":"'+channelProgramID+'"}]',List<Core_MDF_ChannelProgram__mdt>.class);
         
        Test.startTest();
        //Assign Test Records created above to the class property
        Core_MDF_Account_Sharing.channelProgramMapping = channelProgramMeta;        
        
         Account intelAccount = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Acc New ', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type,false);
        database.insert(intelAccount);
        
        Account acc1 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Acc 1', channelProgram.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, intelAccount.Id,false);            
        database.insert(acc1);
        
        List<AccountShare> accountShareList = [Select Id,UserOrGroup.Name,RowCause,AccountAccessLevel from AccountShare where AccountId=:acc1.ID and Rowcause = 'Manual'];
        System.assertEquals(12,accountShareList.size());
        Test.stopTest();
        
    }
    
}