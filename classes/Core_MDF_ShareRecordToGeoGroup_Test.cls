/**************************************************************************************
Apex Class Name:  Core_MDF_ShareRecordToGeoGroup_Test 
Version     : 1.0 
Created Date: 02 08 2018
Function    : Test class for the Core_MDF_ShareRecordToGeoGroup used for Program and geo based sharing.
Author      : Sarah Manuel
Modification Log :
* Change#           Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1   Sarah Manuel         22/10/2019              Original Version
*
*************************************************************************************/
@isTest(SeeAllData=false) 
public class Core_MDF_ShareRecordToGeoGroup_Test {
    
    @isTest static void validateShareRecordToGeoGroup(){
        List<Account> toBeUpdated = new List<Account>();
        
        // Creating channel program with utility class
        ChannelProgram cp1 = Core_MDF_CCP_TestDataUtility.createProgram ('Retail Marketing Funds','Retail Marketing Funds', true);
        ChannelProgram cp2 = Core_MDF_CCP_TestDataUtility.createProgram ('Client Co-Marketing Fund','Client CoMarketing Fund', true);

        // Creating Account with utility class
        Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc2 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 2', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);
                
        Account acc5 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 5', cp2.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc1.Id, false);

        // Updating Accounts 
        acc1.isPartner = true;
        acc1.Core_Geo__c='ASMO';
        acc1.Core_Sub_Geo__c='LAR';
        acc2.Core_MDF_CoMarketingActive__c = true;
        acc2.Core_Geo__c='ASMO';
        acc2.Core_Sub_Geo__c='LAR';
        acc5.Core_MDF_CoMarketingActive__c = true;
        acc5.Core_Geo__c='APJ';
        acc5.Core_Sub_Geo__c='';
        toBeUpdated.add(acc1);
        toBeUpdated.add(acc2);
        toBeUpdated.add(acc5);
        Database.upsert(toBeUpdated);
        
        PartnerMarketingBudget pmb1 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 1', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc2.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), true);
        

		// Creating Account with utility class
        Account acc3 = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account 3', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);
        
        Account acc4 = Core_MDF_CCP_TestDataUtility.createCoMarketingAccount('Test Account 4', cp1.Id, Core_MDF_CCP_TestDataUtility.Account_Record_Type, acc3.Id, false);
        
        // Updating Accounts 
        acc3.isPartner = true;
        acc3.Core_Geo__c='EMEA';
        acc3.Core_MDF_CoMarketingActive__c = true;
        acc4.Core_Geo__c='EMEA';
        toBeUpdated.add(acc3);
        toBeUpdated.add(acc4);
        Database.upsert(toBeUpdated);
        
        Test.startTest();
        PartnerMarketingBudget pmb2 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 2', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc4.Id, cp1.Id, 3000, System.Today(), System.Today().addDays(10), true);
         
        PartnerMarketingBudget pmb3 = Core_MDF_CCP_TestDataUtility.createBudget('Test Budget 3', Core_MDF_CCP_TestDataUtility.Budget_Record_Type, acc5.Id, cp2.Id, 3000, System.Today(), System.Today().addDays(10), true);

        Campaign cmp = Core_MDF_CCP_TestDataUtility.createCampaign('Test Camp 12','Gaming','Intel® Core™ i7 Processor', Core_MDF_CCP_TestDataUtility.Campaign_RecordType_CCF, 'Client CoMarketing Fund', System.today(), System.today().addDays(300), 10000, 'Always Connected PC', acc5.Id,'Desktop', true);
        
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1];
        
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.profileId = systemAdminProfile.Id;
        Database.insert(usr);
        
        System.runAs(usr){
            
            
           // try
            //{
                Boolean isAsmoShared = false;
                Boolean isAsmoLarROShared = false;
                Boolean isEmeaShared = false;
            	Boolean isApjShared = false;
                Boolean isCmpAsmoShared = false;
                Boolean isCmpAsmoROShared = false;
            	Map<String,Id> grpNameIdMap = new Map<String,Id>();
            	Set<String> grpNames = new Set<String>();
                Set<Id> budgetId = new Set<Id>();
                budgetId.add(pmb1.Id);
                budgetId.add(pmb2.Id);
                budgetId.add(pmb3.Id);
                Core_MDF_RecordGeoShare share = new Core_MDF_RecordGeoShare(pmb1.Id,'ASMO','LAR','Retail Marketing Funds');
                Core_MDF_RecordGeoShare share2 = new Core_MDF_RecordGeoShare(pmb2.Id,'EMEA','Retail Marketing Funds');
            	Core_MDF_RecordGeoShare share3 = new Core_MDF_RecordGeoShare(pmb3.Id,'Client Co-Marketing Fund');
                List<Core_MDF_RecordGeoShare> shareLst = new List<Core_MDF_RecordGeoShare>();
                shareLst.add(share);
                shareLst.add(share2);
            	shareLst.add(share3);
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerMarketingBudget', shareLst);
                Core_MDF_ProgramGeoGroupMap__mdt metaRec = [SELECT Core_MDF_Group_Name__c,Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                  		From Core_MDF_ProgramGeoGroupMap__mdt
                                                  		where Core_MDF_Region__c = 'ASMO' and Core_MDF_Sub_Region__c='LAR' and Core_MDF_Program__c = 'Retail Marketing Funds'];
            grpNames.add(metaRec.Core_MDF_Group_Name__c);
            grpNames.add(metaRec.Core_MDF_Group_Name_RO__c);
            
            Core_MDF_ProgramGeoGroupMap__mdt metaRec2 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                  		From Core_MDF_ProgramGeoGroupMap__mdt
                                                  		where Core_MDF_Region__c = 'EMEA' and Core_MDF_Program__c = 'Retail Marketing Funds'];
            grpNames.add(metaRec2.Core_MDF_Group_Name__c);  
            grpNames.add(metaRec2.Core_MDF_Group_Name_RO__c);
            Core_MDF_ProgramGeoGroupMap__mdt metaRec3 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                  		From Core_MDF_ProgramGeoGroupMap__mdt
                                                  		where Core_MDF_Region__c = 'ASMO' and Core_MDF_Program__c = 'Client Co-Marketing Fund'];
            grpNames.add(metaRec3.Core_MDF_Group_Name__c);
            grpNames.add(metaRec3.Core_MDF_Group_Name_RO__c);
            Core_MDF_ProgramGeoGroupMap__mdt metaRec4 = [SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,Core_MDF_Sub_Region__c
                                                  		From Core_MDF_ProgramGeoGroupMap__mdt
                                                  		where Core_MDF_Region__c = '' and Core_MDF_Program__c = 'Client Co-Marketing Fund'];
            grpNames.add(metaRec4.Core_MDF_Group_Name__c);
            for(Group grp : [Select Id, DeveloperName from Group where DeveloperName IN :grpNames])
                {
                    grpNameIdMap.put(grp.DeveloperName,grp.Id);
                }            
               
            List<PartnerMarketingBudgetShare> pmbShare = [SELECT ParentId, UserOrGroupId from PartnerMarketingBudgetShare where ParentId IN :budgetId];
            System.debug('pmbShare::'+pmbShare);   
            for(PartnerMarketingBudgetShare shareRec : pmbShare)
                {
                    System.debug('shareRec:::'+shareRec);
                    if(shareRec.ParentId==pmb1.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec.Core_MDF_Group_Name__c))){
                        isAsmoShared = true;
                    }
                    if(shareRec.ParentId==pmb1.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec.Core_MDF_Group_Name_RO__c))){
                        isAsmoLarROShared = true;
                    }
                    if(shareRec.ParentId==pmb2.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec2.Core_MDF_Group_Name__c))){
                        isEmeaShared = true;
                    }
                    if(shareRec.ParentId==pmb3.Id && shareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec4.Core_MDF_Group_Name__c))){
                        isApjShared = true;
                    }
                        
                }
                System.assertEquals(true,isAsmoShared);
            	System.assertEquals(true,isAsmoLarROShared);
                System.assertEquals(true,isEmeaShared);
            	System.assertEquals(true,isApjShared);
                
                List<CampaignShare> cmpShare = [SELECT CampaignId, UserOrGroupId from CampaignShare where CampaignId = :cmp.Id];
            System.Debug('cmpShare::'+cmpShare);	
            for(CampaignShare cmpShareRec : cmpShare)
                {
                    if(cmpShareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec3.Core_MDF_Group_Name__c))){
                        isCmpAsmoShared = true;
                    }
                    if(cmpShareRec.UserOrGroupId.equals(grpNameIdMap.get(metaRec3.Core_MDF_Group_Name_RO__c))){
                        isCmpAsmoROShared = true;
                    }    
                }
               // System.assertEquals(true,isCmpAsmoShared);
               // System.assertEquals(true,isCmpAsmoROShared);
            
            //}
           /* catch(Exception ex)
            {
                System.debug(ex.getMessage());
            }*/
        }
        test.stopTest();
    }
    
}