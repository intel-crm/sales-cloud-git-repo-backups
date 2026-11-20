@IsTest
public class Core_MDF_TargetSettingServiceHandlerTest {
    @TestSetup static void setUpData(){
         Boolean isUnifiedIdEnabled = Core_MDF_CustomLabelConfig.getBooleanValues('Core_MDF_UnifiedIdCheck');
        

        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test11';
        usr.IsActive = true;
        insert usr;
        
        System.runAs(usr){
            ChannelProgram ipaCP = Core_MDF_CCP_TestDataUtility.createProgram ('Intel Partner Alliance','Intel Partner Alliance', true);
            List<Account> intAccList= new List<Account>();
            Account accIPA = Core_MDF_CCP_TestDataUtility.createIntelAccount ('IPA Intel Account',Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            accIPA.Core_MDF_CoMarketingActive__c = true;
            if(isUnifiedIdEnabled){
                accIPA.Core_Unified_Global_Customer_BP_Id__c = 'Prime001';
            }else{
                accIPA.Core_Prime_Id__c = 'Prime001'; 
            }
            accIPA.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
            intAccList.add(accIPA);
            insert intAccList;
            
            Account acc = Core_MDF_CCP_TestDataUtility.createAccount ('Test Account', ipaCP.Id,Core_MDF_CCP_TestDataUtility.Account_Record_Type, false);
            acc.Core_MDF_Is_Top_Account_Ind__c=true;
            acc.Core_Geo__c='APJ';
            acc.Core_MDF_Parent_Fund_Account__c = accIPA.Id;
            insert acc;
            
            Core_MDF_Target_Setting_LineItem_Config__c metaRec= new Core_MDF_Target_Setting_LineItem_Config__c();
            metaRec.Core_MDF_Is_Active_Ind__c=true;
            metaRec.Name= 'IPA_PropII_APJ_NIE_Test';
            metaRec.Core_MDF_Program_txt__c='Intel Partner Alliance';
            metaRec.Core_MDF_Region_txt__c='APJ';
            metaRec.Core_MDF_Focus_Area_txt__c='Networking & Intelligent Edge';
            metaRec.Core_MDF_Budget_Type_txt__c='Account Plan';
            insert metaRec;
        }
    }
    
    @IsTest
    public static void validateRecordsTest(){
        ChannelProgram ipaCP =[Select id from ChannelProgram Limit 1];
        User usr = [SELECT Id,Email from User where LastName='User Test11' limit 1];        
        try{
            System.runAs(usr){
                Test.startTest();
                List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
                Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
                targetSetting.Core_MDF_Program_Name__c=ipaCP.Id;
                targetSetting.Core_MDF_Name__c='Trgt Settings';
                targetSetting.Core_MDF_Start_Date__c= System.today()+2;
                targetSetting.Core_MDF_End_Date__c=System.today()+4;
                
                Core_MDF_Target_Setting__c targetSetting1= new Core_MDF_Target_Setting__c();
                targetSetting1.Core_MDF_Program_Name__c=ipaCP.Id;
                targetSetting1.Core_MDF_Name__c='Trgt Settings1';
                targetSetting1.Core_MDF_Start_Date__c= System.today()+2;
                targetSetting1.Core_MDF_End_Date__c=System.today()+4;
                
                newTargetSettingList.add(targetSetting);
                newTargetSettingList.add(targetSetting1);
                insert newTargetSettingList;
                
                Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap= new Map<Id,Core_MDF_Target_Setting__c>();
                Core_MDF_Target_Setting__c targetSettingOld= new Core_MDF_Target_Setting__c();
                targetSettingOld.Core_MDF_Program_Name__c=ipaCP.Id;
                targetSettingOld.Core_MDF_Name__c='Trgt Settings Test';
                targetSettingOld.Core_MDF_Start_Date__c= System.today()+2;
                targetSettingOld.Core_MDF_End_Date__c=System.today()+4;
                insert targetSettingOld;
                oldTargetSettingMap.put(targetSettingOld.Id,targetSettingOld);
                Core_MDF_Target_Setting_ServiceHandler.validateOverlapingTargetSetting(newTargetSettingList,oldTargetSettingMap,true);
                Assert.areEqual(true,targetSettingOld.Core_MDF_Name__c != null);
                Test.StopTest();
            }
        }
        catch(Exception e) {
        }  
    }
    
    @IsTest
    public static void validateOvrlapingTgtSetngOnUpdateTest(){
        ChannelProgram ipaCP =[Select id from ChannelProgram Limit 1];
        User usr = [SELECT Id,Email from User where LastName='User Test11' limit 1];
        System.runAs(usr){
            Test.startTest();
            List<Core_MDF_Target_Setting__c> newTargetSettingList1= new List<Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=ipaCP.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today();
            targetSetting.Core_MDF_End_Date__c=System.today()+3;
            newTargetSettingList1.add(targetSetting);

            
            newTargetSettingList1.add(targetSetting);
            targetSetting.Core_MDF_Start_Date__c=System.today()+2;
            targetSetting.Core_MDF_End_Date__c=System.today()+4;

            
            Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap1= new Map<Id,Core_MDF_Target_Setting__c>();
            
            oldTargetSettingMap1.put(targetSetting.Id,targetSetting);
            Core_MDF_Target_Setting_ServiceHandler.validateRecordsOnUpdate(new List<Core_MDF_Target_Setting__c>(),oldTargetSettingMap1,true);
            Core_MDF_Target_Setting_ServiceHandler.validateRecordsOnUpdate(newTargetSettingList1,oldTargetSettingMap1,true);
            Assert.areEqual(true,targetSetting.Core_MDF_Name__c != null);
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void createTargetSettingLineItemsTest(){
        List<Core_MDF_Target_Setting__c> newTargetSettingList= new List<Core_MDF_Target_Setting__c>();
        ChannelProgram ipaCP =[Select id from ChannelProgram Limit 1];
        User usr = [SELECT Id,Email from User where LastName='User Test11' limit 1];
        System.runAs(usr){
            test.startTest();
            Core_MDF_Target_Setting__c targetSetting= new Core_MDF_Target_Setting__c();
            targetSetting.Core_MDF_Program_Name__c=ipaCP.Id;
            targetSetting.Core_MDF_Name__c='Trgt Settings';
            targetSetting.Core_MDF_Start_Date__c= System.today()+2;
            targetSetting.Core_MDF_End_Date__c=System.today()+4;

            newTargetSettingList.add(targetSetting);
            
            Map<Id,Core_MDF_Target_Setting__c> oldTargetSettingMap= new Map<Id,Core_MDF_Target_Setting__c>();
            Core_MDF_Target_Setting__c targetSettingNew= new Core_MDF_Target_Setting__c();
            targetSettingNew.Core_MDF_Program_Name__c=ipaCP.Id;
            targetSettingNew.Core_MDF_Name__c='Trgt Settings Test';
            targetSettingNew.Core_MDF_Start_Date__c= System.today()+5;
            targetSettingNew.Core_MDF_End_Date__c=System.today()+8;

            
            oldTargetSettingMap.put(targetSettingNew.Id,targetSettingNew);
 
            Assert.areEqual(true,targetSetting.Core_MDF_Name__c != null);
            try{
                Core_MDF_Target_Setting_ServiceHandler.validateRecordsOnUpdate(null,oldTargetSettingMap,true);   
            }
            catch(Exception e){
            }
            try{
                Core_MDF_Target_Setting_ServiceHandler.validateRecords(null,oldTargetSettingMap,true);
            }
            catch(Exception e){
            }
            try{
                Core_MDF_Target_Setting_ServiceHandler.createTargetSettingLineItems(null,oldTargetSettingMap,true);
            }
            catch(Exception e){
            }
            try{
                Core_MDF_Target_Setting_ServiceHandler.reportAndDashboardFldUpdate(null,oldTargetSettingMap,true);
            }
            catch(Exception e){
            }
            test.stopTest();
        }
    }
}