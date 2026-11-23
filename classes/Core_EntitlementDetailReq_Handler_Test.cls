@isTest
public class Core_EntitlementDetailReq_Handler_Test {
    
    @isTest static void testvalidateReq(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        
        // List<Core_Entitlement_Detail_Request__c> ent = new  List<Core_Entitlement_Detail_Request__c>();
        Test.startTest();
        try{ 
            
            String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
            String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
            String Core_Applicable_Profiles_Txt_c = [SELECT id,Name FROM Profile LIMIT 1].Name;
            
            Core_ERPM_Engagement__c objERPMEngmt = new Core_ERPM_Engagement__c();
            objERPMEngmt.name = 'Test_ERPMEngg_02';
            objERPMEngmt.Core_Technical_DeDup_Number__c = 'Test';
            objERPMEngmt.Core_Technical_Engagement_Code__c = 'Test';
            objERPMEngmt.Core_IsActive__c = true;
            insert objERPMEngmt;
            System.assertNotEquals(null, objERPMEngmt.Id);
            
            Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
            objAGSRole.Name= 'Test_AGS_Role_02';
            objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
            objAGSRole.Core_IsActive__c = true;
            insert objAGSRole;
            System.assertNotEquals(null, objAGSRole.Id);
            
            //Creates a sample 'Entitlement' record
            Core_Entitlement__c objEntitlement = new Core_Entitlement__c();
            objEntitlement.Name = 'Test_Entitlement_02';
            objEntitlement.Core_Display_Name__c = 'Test_Entitlement_02';
            objEntitlement.Core_IsActive__c = true;
            objEntitlement.Core_AGS_Role_Id__c = objAGSRole.id;
            objEntitlement.Core_Category__c = '';
            objEntitlement.Core_Sub_Category__c = '';
            objEntitlement.Core_ERPM_Engagement_Id__c = objERPMEngmt.id;
            objEntitlement.Core_Permission_Set_API_Nm__c = '' ;
            objEntitlement.Core_Public_Group_API_Nm__c = '';
            insert objEntitlement;
            System.assertNotEquals(null, objEntitlement.Id);
            
            List<Core_Entitlement_Detail_Request__c> entReqs = new List<Core_Entitlement_Detail_Request__c>();            
            Core_Entitlement_Detail_Request__c ent1 = new Core_Entitlement_Detail_Request__c();
            ent1.Name = 'Test_Entitlement_01';
            ent1.Core_Display_Nm__c = 'Test_01';
            ent1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
            ent1.Core_Sub_Category_Nm__c = 'Communities';
            ent1.Core_Description_Txt__c = 'Test';
            ent1.Core_Help_Txt__c = 'Entitlement_01';
            ent1.Core_Release_Txt__c = 'IPA October';
            ent1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_01';
            ent1.Core_Engagement_Type__c = 'SFT';
            ent1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_01_Code';
            ent1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_01_DeDup';
            ent1.Core_AGS_Role_Nm__c = 'Test_AGSRole_01';
            ent1.Core_Technical_Nm__c = 'Test_AGSRole_01_TechName';
            ent1.Core_Permission_Set_API_Nm__c = 'Core_IPS_SupportOrgAdmin12';
            ent1.Core_Public_Group_API_Nm__c = 'Test_098';
            ent1.Core_DisplayOnUI_Ind__c = true;
            ent1.Core_Applicable_Profiles_Txt__c = 'System Administrator12';
            // ent1.Core_Status_Nm__c = '';
            //ent.add(ent1);
            //Core_EntitlementDetailReq_Handler.hasrun = false;
            //insert ent1;
            entReqs.add(ent1);            
            
            Core_Entitlement_Detail_Request__c ent2 = new Core_Entitlement_Detail_Request__c();
            //ent2.Id = ent1.ID;
            ent2.Name = 'Test_Entitlement_02';
            ent2.Core_Display_Nm__c = 'Test_Entitlement_02';
            ent2.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
            ent2.Core_Sub_Category_Nm__c = 'Communities';
            ent2.Core_Description_Txt__c = 'Test';
            ent2.Core_Help_Txt__c = 'Entitlement_02';
            ent2.Core_Release_Txt__c = 'IPA October';
            ent2.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_02';
            ent2.Core_Engagement_Type__c = '';
            ent2.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_Cd_02';
            ent2.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_Dedup_02';
            ent2.Core_AGS_Role_Nm__c = 'Test_AGS_Role_02';
            ent2.Core_Technical_Nm__c = 'Test_AGSRole_02_TechName';
            ent2.Core_Permission_Set_API_Nm__c = 'Core_IPS_SupportOrgAdmin56';
            ent2.Core_Public_Group_API_Nm__c = 'Test_123';
            ent2.Core_DisplayOnUI_Ind__c = true;
            ent2.Core_Applicable_Profiles_Txt__c = 'Data Ops123';
            // ent2.Core_Status_Nm__c = '';
            //ent.add(ent1);
            //Core_EntitlementDetailReq_Handler.hasrun = false;
            //insert ent2;
            entReqs.add(ent2);
            
            Core_Entitlement_Detail_Request__c ent3 = new Core_Entitlement_Detail_Request__c();
            //ent2.Id = ent1.ID;
            ent3.Name = 'Test_Entitlement_03';
            ent3.Core_Display_Nm__c = 'Test_Entitlement_03';
            ent3.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
            ent3.Core_Sub_Category_Nm__c = 'Communities';
            ent3.Core_Description_Txt__c = 'Test';
            ent3.Core_Help_Txt__c = 'Entitlement_03';
            ent3.Core_Release_Txt__c = 'IPA October';
            ent3.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
            ent3.Core_Engagement_Type__c = 'SMP';
            ent3.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_Cd_03';
            ent3.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_Dedup_03';
            ent3.Core_AGS_Role_Nm__c = 'Test_AGS_Role_03';
            ent3.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
            ent3.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
            ent3.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
            ent3.Core_DisplayOnUI_Ind__c = true;
            ent3.Core_Applicable_Profiles_Txt__c = Core_Applicable_Profiles_Txt_c;
            entReqs.add(ent3);
            
            Core_Entitlement_Detail_Request__c ent4 = new Core_Entitlement_Detail_Request__c();
            //ent2.Id = ent1.ID;
            ent4.Name = 'Test_Entitlement_04';
            ent4.Core_Display_Nm__c = 'Test_Entitlement_04';
            ent4.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
            ent4.Core_Sub_Category_Nm__c = 'Communities';
            ent4.Core_Description_Txt__c = 'Test';
            ent4.Core_Help_Txt__c = 'Entitlement_03';
            ent4.Core_Release_Txt__c = 'IPA October';
            ent4.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
            ent4.Core_Engagement_Type__c = 'SMP';
            ent4.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_Cd_03';
            ent4.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_Dedup_03';
            ent4.Core_AGS_Role_Nm__c = 'TBD';
            ent4.Core_Technical_Nm__c = 'TBD';
            ent4.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
            ent4.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
            ent4.Core_DisplayOnUI_Ind__c = true;
            ent4.Core_Applicable_Profiles_Txt__c = Core_Applicable_Profiles_Txt_c;
            ent4.Core_Status_Nm__c = 'Approved';
            entReqs.add(ent4);
            insert entReqs;
        }catch(Exception error){
            System.debug(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            //	System.debug(error.getMessage().contains('Permission Set is not available in the system'));
        }
        Test.stopTest();
    }
    
    @isTest static void testerpmenggcheck(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        
        Test.startTest();
        try{ 
            
            Core_Entitlement_Detail_Request__c en = new Core_Entitlement_Detail_Request__c();
            en.Name = 'Test_Entitlement_02';
            en.Core_Display_Nm__c = 'Test_Entitlement_02';
            en.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
            en.Core_Sub_Category_Nm__c = 'Communities';
            en.Core_Description_Txt__c = 'Test';
            en.Core_Help_Txt__c = 'Entitlement_02';
            en.Core_Release_Txt__c = 'IPA October';
            en.Core_ERPM_Engagement_Nm__c = '';
            en.Core_Engagement_Type__c = 'SFT';
            en.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_02_Code';
            en.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_01_DeDup';
            en.Core_AGS_Role_Nm__c = 'Test_AGSRole_02';
            en.Core_Technical_Nm__c = 'Test_AGSRole_02_TechName';
            en.Core_Permission_Set_API_Nm__c = 'Core_IPS_SupportOrgAdmin56';
            en.Core_Public_Group_API_Nm__c = 'Test_123';
            en.Core_DisplayOnUI_Ind__c = true;
            en.Core_Applicable_Profiles_Txt__c = '';
            en.Core_Status_Nm__c = 'Submitted';
            Core_EntitlementDetailReq_Handler.hasrun = false;
            insert en;
        }catch(Exception error){
            System.debug(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            System.assert(error.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            //	System.debug(error.getMessage().contains('Permission Set is not available in the system'));
        }   
        Test.stopTest();      
    }
    
    @isTest static void testapprovalReq(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        
        Test.startTest();
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        String Core_Applicable_Profiles_Txt_c = [SELECT id,Name FROM Profile LIMIT 1].Name;
        
        Core_Entitlement_Detail_Request__c enew = new Core_Entitlement_Detail_Request__c();
        enew.Name = 'Test_Entitlement_02';
        enew.Core_Display_Nm__c = 'Test_Entitlement_02';
        enew.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        enew.Core_Sub_Category_Nm__c = 'Communities';
        enew.Core_Description_Txt__c = 'Test';
        enew.Core_Help_Txt__c = 'Entitlement_02';
        enew.Core_Release_Txt__c = 'IPA October';
        enew.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_02';
        enew.Core_Engagement_Type__c = 'SFT';
        enew.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_02_Code';
        enew.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_01_DeDup';
        enew.Core_AGS_Role_Nm__c = 'Test_AGSRole_02';
        enew.Core_Technical_Nm__c = 'Test_AGSRole_02_TechName';
        enew.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        // ent1.Core_Public_Group_API_Nm__c = 'Test_123';
        enew.Core_DisplayOnUI_Ind__c = true;
        enew.Core_Applicable_Profiles_Txt__c = Core_Applicable_Profiles_Txt_c;
        enew.Core_Status_Nm__c = 'Submitted';
        Core_EntitlementDetailReq_Handler.hasrun = false;
        insert enew;	
        
        
        Core_Entitlement_Detail_Request__c entnew1 = new Core_Entitlement_Detail_Request__c();
        entnew1.Id = enew.Id;
        entnew1.Name = 'Test_Entitlement_03';
        entnew1.Core_Display_Nm__c = 'Test_Entitlement_03';
        entnew1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew1.Core_Sub_Category_Nm__c = 'Communities';
        entnew1.Core_Description_Txt__c = 'Test';
        entnew1.Core_Help_Txt__c = 'Entitlement_03';
        entnew1.Core_Release_Txt__c = 'IPA October';
        entnew1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew1.Core_Engagement_Type__c = 'SFT';
        entnew1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew1.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew1.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        // ent1.Core_Public_Group_API_Nm__c = 'Test_123';
        entnew1.Core_DisplayOnUI_Ind__c = true;
        entnew1.Core_Applicable_Profiles_Txt__c = Core_Applicable_Profiles_Txt_c;
        entnew1.Core_Status_Nm__c = 'Approved';
        Core_EntitlementDetailReq_Handler.hasrun = false;
        update entnew1; 
        
		List<Core_Entitlement__c> entDetails = [SELECT id,Name FROM Core_Entitlement__c WHERE Name= :entnew1.Name];
        system.assert(entDetails.size() >0);    
        Test.stopTest();
    }
    @isTest static void testCreateOrUpdateProfileAccess(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
              
        Schema.DescribeFieldResult fieldResult = Core_Entitlement_Profile_Access__c.Core_Entitlements_Allowed__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String entNames = '';
        integer i=0;
        integer pleSize = (ple.size() > 100 ? 100 : ple.size());
        system.debug('picklist entries size==>'+pleSize);
        
        String entName = '';
        for( Schema.PicklistEntry f : ple)
        {
            i++;
            if(i<(pleSize-10)){
                entNames = String.isEmpty(entNames) ? f.getValue():entNames+';'+ f.getValue();
            }else {
                entName = f.getValue();
                break;
            }            
        }
        Test.startTest();
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        Profile prof = [SELECT id,Name FROM Profile LIMIT 1];
        system.debug('entNames==>'+entNames.split(';').size());
        Core_Entitlement_Profile_Access__c profileAcc = new Core_Entitlement_Profile_Access__c();
        profileAcc.Name = prof.Name;
        profileAcc.Core_Entitlements_Allowed__c = entNames;
        profileAcc.Core_Profile_Id__c = prof.Id; 
        insert profileAcc;
        
        system.debug('entName===>'+entName+'Test123');
        Core_Entitlement_Detail_Request__c entnew1 = new Core_Entitlement_Detail_Request__c();
        //entnew1.Id = enew.Id;
        entnew1.Name = entName;
        entnew1.Core_Display_Nm__c = entName+'Test123';
        entnew1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew1.Core_Sub_Category_Nm__c = 'Communities';
        entnew1.Core_Description_Txt__c = 'Test';
        entnew1.Core_Help_Txt__c = entName;
        entnew1.Core_Release_Txt__c = 'IPA October';
        entnew1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew1.Core_Engagement_Type__c = 'SFT';
        entnew1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew1.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew1.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        entnew1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entnew1.Core_DisplayOnUI_Ind__c = true;
        entnew1.Core_Applicable_Profiles_Txt__c = prof.Name;
        entnew1.Core_Status_Nm__c = 'Approved';
        
        Core_EntitlementDetailReq_Handler.hasrun = false;
        insert entnew1; 
        Test.stopTest();
        
       
		List<Core_Entitlement__c> entDetails = [SELECT id,Name FROM Core_Entitlement__c WHERE Name= :entnew1.Name];
        system.assert(entDetails.size() >0);    
        //Core_EntitlementDetailReq_Handler.createOrUpdateProfileAccess(new Set<Id>{entnew1.Id});
    }
    @isTest static void testCreateOrUpdateProfileAccess1(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
             
        Schema.DescribeFieldResult fieldResult = Core_Entitlement_Profile_Access__c.Core_Entitlements_Allowed__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String entNames = '';
        integer i=0;
        integer pleSize = (ple.size() > 100 ? 100 : ple.size());     
        for( Schema.PicklistEntry f : ple)
        {
            i++;
            if(i<=100){
                entNames = String.isEmpty(entNames) ? f.getValue():entNames+';'+ f.getValue();      
            }
            
        }
        
        Test.startTest();
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        Profile prof = [SELECT id,Name FROM Profile LIMIT 1];
        
        Core_Entitlement_Profile_Access__c profileAcc = new Core_Entitlement_Profile_Access__c();
        profileAcc.Name = prof.Name;
        profileAcc.Core_Entitlements_Allowed__c = entNames;
        profileAcc.Core_Profile_Id__c = prof.Id; 
        insert profileAcc;
        
        //system.debug('entName===>'+entName+'Test123');
        Core_Entitlement_Detail_Request__c entnew1 = new Core_Entitlement_Detail_Request__c();
        //entnew1.Id = enew.Id;
        entnew1.Name = 'Test123';
        entnew1.Core_Display_Nm__c = 'Test123';
        entnew1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew1.Core_Sub_Category_Nm__c = 'Communities';
        entnew1.Core_Description_Txt__c = 'Test';
        entnew1.Core_Help_Txt__c = 'Test123';
        entnew1.Core_Release_Txt__c = 'IPA October';
        entnew1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew1.Core_Engagement_Type__c = 'SFT';
        entnew1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew1.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew1.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        entnew1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entnew1.Core_DisplayOnUI_Ind__c = true;
        entnew1.Core_Applicable_Profiles_Txt__c = prof.Name;
        entnew1.Core_Status_Nm__c = 'Approved';
        
        Core_EntitlementDetailReq_Handler.hasrun = false;
        insert entnew1; 
		test.stopTest();
		
		List<Core_Entitlement__c> entDetails = [SELECT id,Name FROM Core_Entitlement__c WHERE Name= :entnew1.Name];
        system.assert(entDetails.size() >0);        
        //Core_EntitlementDetailReq_Handler.createOrUpdateProfileAccess(new Set<Id>{entnew1.Id});
    }
    @isTest static void testCreateOrUpdateProfileAccess2(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
            
        Schema.DescribeFieldResult fieldResult = Core_Entitlement_Profile_Access__c.Core_Entitlements_Allowed__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String entNames = '';
        integer i=0;
        integer pleSize = (ple.size() > 100 ? 100 : ple.size());
        system.debug('picklist entries size==>'+pleSize);
        String entName = '';
        for( Schema.PicklistEntry f : ple)
        {
            i++;
            if(i<100){
                entNames = String.isEmpty(entNames) ? f.getValue():entNames+';'+ f.getValue();      
            }
            
        }
        
        Test.startTest();
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        Profile prof = [SELECT id,Name FROM Profile LIMIT 1];

        Core_Entitlement_Profile_Access__c profileAcc = new Core_Entitlement_Profile_Access__c();
        profileAcc.Name = prof.Name;
        profileAcc.Core_Entitlements_Allowed__c = entNames;
        profileAcc.Core_Profile_Id__c = prof.Id; 
        insert profileAcc;
        
        system.debug('entName===>'+entName+'Test123');
        List<Core_Entitlement_Detail_Request__c> entReqs = new List<Core_Entitlement_Detail_Request__c>();
        Core_Entitlement_Detail_Request__c entnew1 = new Core_Entitlement_Detail_Request__c();
        //entnew1.Id = enew.Id;
        entnew1.Name ='Auto_Entitlement_Test0002';
        entnew1.Core_Display_Nm__c = 'Auto_Entitlement_Test0002';
        entnew1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew1.Core_Sub_Category_Nm__c = 'Communities';
        entnew1.Core_Description_Txt__c = 'Test';
        entnew1.Core_Help_Txt__c = entName;
        entnew1.Core_Release_Txt__c = 'IPA October';
        entnew1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew1.Core_Engagement_Type__c = 'SFT';
        entnew1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew1.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew1.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        entnew1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entnew1.Core_DisplayOnUI_Ind__c = true;
        entnew1.Core_Applicable_Profiles_Txt__c = prof.Name;
        entnew1.Core_Status_Nm__c = 'Approved';
        
        entReqs.add(entnew1);
      
        Core_Entitlement_Detail_Request__c entnew2 = new Core_Entitlement_Detail_Request__c();
        //entnew1.Id = enew.Id;
        entnew2.Name ='Auto_Entitlement_Test0003';
        entnew2.Core_Display_Nm__c = 'Auto_Entitlement_Test0003';
        entnew2.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew2.Core_Sub_Category_Nm__c = 'Communities';
        entnew2.Core_Description_Txt__c = 'Test';
        entnew2.Core_Help_Txt__c = entName;
        entnew2.Core_Release_Txt__c = 'IPA October';
        entnew2.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew2.Core_Engagement_Type__c = 'SFT';
        entnew2.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew2.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew2.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew2.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew2.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        entnew2.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entnew2.Core_DisplayOnUI_Ind__c = true;
        entnew2.Core_Applicable_Profiles_Txt__c = prof.Name;
        entnew2.Core_Status_Nm__c = 'Approved';
        
        entReqs.add(entnew2);
        
        Core_EntitlementDetailReq_Handler.hasrun = false;
        insert entReqs; 
        test.stopTest();
        
        List<Core_Entitlement__c> entDetails = [SELECT id,Name FROM Core_Entitlement__c WHERE Name IN : new Set<String>{entnew1.Name, entnew2.Name}];
        system.assert(entDetails.size() >0);
        //Core_EntitlementDetailReq_Handler.createOrUpdateProfileAccess(new Set<Id>{entnew1.Id});
    }
    @isTest static void testRequestUpdateEvents(){
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataAPIService MetadataAPIService = new MetadataAPIService();
        
        Test.startTest();
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        Profile prof = [SELECT id,Name FROM Profile LIMIT 1];
        
        String entName = 'Auto_Entitlement_Test_0001';
        Core_Entitlement_Detail_Request__c entnew1 = new Core_Entitlement_Detail_Request__c();
        //entnew1.Id = enew.Id;
        entnew1.Name = entName;
        entnew1.Core_Display_Nm__c = entName+'Test123';
        entnew1.Core_Category_Nm__c = 'Intel Partner Alliance (IPA)';
        entnew1.Core_Sub_Category_Nm__c = 'Communities';
        entnew1.Core_Description_Txt__c = 'Test';
        entnew1.Core_Help_Txt__c = entName;
        entnew1.Core_Release_Txt__c = 'IPA October';
        entnew1.Core_ERPM_Engagement_Nm__c = 'Test_ERPMEngg_03';
        entnew1.Core_Engagement_Type__c = 'SFT';
        entnew1.Core_Technical_Engagement_Cd__c = 'Test_ERPMEngg_03_Code';
        entnew1.Core_Technical_DeDup_Number__c = 'Test_ERPMEngg_03_DeDup';
        entnew1.Core_AGS_Role_Nm__c = 'Test_AGSRole_03';
        entnew1.Core_Technical_Nm__c = 'Test_AGSRole_03_TechName';
        entnew1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        entnew1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        entnew1.Core_DisplayOnUI_Ind__c = true;
        entnew1.Core_Applicable_Profiles_Txt__c = prof.Name;
        entnew1.Core_Status_Nm__c = 'submitted';
        
        Core_EntitlementDetailReq_Handler.hasrun = false;
        insert entnew1; 
        
        Core_EntitlementDetailReq_Handler.hasrun = false;
        entnew1.Core_Status_Nm__c = 'Approved';
        update entnew1;
        test.stopTest();
        
        List<Core_Entitlement__c> entDetails = [SELECT id,Name FROM Core_Entitlement__c WHERE Name= :entName];
        system.assert(entDetails.size() >0);
        
        //Core_EntitlementDetailReq_Handler.createOrUpdateProfileAccess(new Set<Id>{entnew1.Id});
    }
    
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        { 
            if(request instanceof MetadataAPIService.readMetadata_element){
                MetadataAPIService.readCustomFieldResponse_element resp = new MetadataAPIService.readCustomFieldResponse_element();
                resp.result = new MetadataAPIService.ReadCustomFieldResult();
                resp.result.records = new List<MetadataAPIService.CustomField>();
                MetadataAPIService.CustomField fld = new MetadataAPIService.CustomField();
                system.debug('Request==>'+request);
                fld.fullName = ((MetadataAPIService.readMetadata_element) request).fullNames[0];
                system.debug('FullName==>'+fld.fullName);
                fld.valueSet = new MetadataAPIService.ValueSet();
                fld.valueSet.valueSetDefinition = new MetadataAPIService.ValueSetValuesDefinition();
                fld.valueSet.valueSetDefinition.value = new List<MetadataAPIService.CustomValue>();
                String[] fldNameLst = fld.fullName.split('\\.');
                system.debug('FullNameArr==>'+fldNameLst);
                for(Schema.PicklistEntry ple: Schema.getGlobalDescribe().get(fldNameLst[0]).getDescribe().fields.getMap().get(fldNameLst[1]).getDescribe().getPicklistValues()){
                    MetadataAPIService.CustomValue cv = new MetadataAPIService.CustomValue();
                    cv.fullName = ple.getValue();
                    cv.label = ple.getLabel();
                    fld.valueSet.valueSetDefinition.value.add(cv);
                }
                resp.result.records.add(fld);
                //response.put('response_x', new MetadataAPIService.readCustomFieldResponse_element());
                response.put('response_x', resp);
            }
            else if(request instanceof MetadataAPIService.updateMetadata_element){
                response.put('response_x', new MetadataAPIService.updateMetadataResponse_element());
            }
            
            
            return;
        }
    } 
}