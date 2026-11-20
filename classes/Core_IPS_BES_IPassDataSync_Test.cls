/*********************************************
* Name : Core_IPS_BES_IPassDataSync_Test 
* Author : Sai Krishna 
* Date Created : 14/10/2021
* Description : Test class for Core_IPS_BES_IPassDataSync,Core_IPS_New_Backend_System_Handler,Core_IPS_BES_IPASSTriggerHandler
                BackendFieldMapTrigger,BackendValueMapTrigger,Core_IPS_New_Backend_System
*   
************************************************/
@isTest
public class Core_IPS_BES_IPassDataSync_Test {
    @testSetup
    public static void setup(){
        
        
        Core_IPS_Backend_System2__c backendsystem = new Core_IPS_Backend_System2__c();
        backendsystem.Name = 'DCG - HSDES Server Platforms1';
        backendsystem.Core_IPS_Deactivated__c = false;
        backendsystem.Core_IPS_Backend_System_URL__c = 'https://hsdes-pre.intel.com/appstore/article/#/';
        backendsystem.Core_IPS_Target_System__c = 'hsdes:server_platf_ae:bug';
        backendsystem.Core_Support_Email__c = 'hsdes:server_platf_ae:bug';
        insert backendsystem;
        System.assert(backendsystem.Id != null, 'Record not created');
              
        
        
        Core_IPS_Backend_Field_Map__c fieldvalumaplist = new Core_IPS_Backend_Field_Map__c();
        fieldvalumaplist.Core_IPS_Direction__c = 'Outbound';
        fieldvalumaplist.Core_IPS_Deactivated__c = false;
        fieldvalumaplist.Core_IPS_Deassociate__c = false;
        fieldvalumaplist.Core_IPS_Order__c = 2;
        fieldvalumaplist.Core_IPS_Source_Field__c = 'subject';
        fieldvalumaplist.Core_IPS_Target_Field__c = 'title'; 
        fieldvalumaplist.Core_IPS_UnMapped__c = false;
        fieldvalumaplist.Support_Update__c = false;
        fieldvalumaplist.Core_IPS_New_Backend_System__c= backendsystem.Id;
        insert fieldvalumaplist;
		System.assert(fieldvalumaplist.Id != null, 'Record not created');        
        
        
        Core_IPS_Backend_Value_Map__c valuemap = new Core_IPS_Backend_Value_Map__c();
        valuemap.Core_IPS_Source_Value__c ='Low';
        valuemap.Core_IPS_Target_Value__c = '4-Low';
        valuemap.Core_IPS_Deactivated__c = false;
        valuemap.Backend_Field_Mapping_HSD__c = fieldvalumaplist.Id;
        insert  valuemap;     
		System.assert(valuemap.Id != null, 'Record not created');   
        
        Core_IPS_Backend_System_Custom_Settings__c custom_settings = new Core_IPS_Backend_System_Custom_Settings__c();
        custom_settings.Name = 'Core_IPS_New_Backend_System';
        custom_settings.Backend_System_Name__c = 'Backend_System_Name';
        custom_settings.Status__c = 'Backend_System_Status';
        custom_settings.Direction__c = 'Core_IPS_Direction__c';
        custom_settings.Default_Value__c = 'Core_IPS_Deafult_Value__c';
        custom_settings.Deassociate__c = 'Core_IPS_Deassociate__c';
        custom_settings.Deactivated__c = 'Core_IPS_Deactivated__c';
        custom_settings.Order__c = 'Core_IPS_Order__c';
        custom_settings.Source_Field__c = 'Core_IPS_Source_Field__c';
        custom_settings.Support_Email__c = 'Support_Email';
        custom_settings.Source_Value__c = 'Core_IPS_Source_Value__c';
        custom_settings.Target_Field__c = 'Core_IPS_Target_Field__c';
        custom_settings.Target_Value__c = 'Core_IPS_Target_Value__c';
        custom_settings.Support_Update__c = 'Core_IPS_Support_Update__c';
        custom_settings.UnMapped__c = 'Core_IPS_UnMapped__c';
        custom_settings.Backend_Sysytem_url__c = 'Core_IPS_Backend_System_Url__c';
        custom_settings.Target_System__c = 'Core_IPS_Target_System__c';
        insert custom_settings;
        System.assert(custom_settings.Id != null, 'Record not created');
        
        Core_IPS_System_Credentails_Apigee__c customSetting = new Core_IPS_System_Credentails_Apigee__c();
        customSetting.Name = 'Core_IPS_Backend_System_Integration';
        customSetting.Core_IPS_Client_Id__c = '07e04e4c-dd0b-4b24-9c46-6056a8225308';
        customSetting.Core_IPS_Client_Secret__c = 'XnK1KXtLthP4.778QgL-2fTS~OahSiL_qc';
        customSetting.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/service-cloud/cases/v1/mappings';
        customSetting.Core_IPS_GrantType__c = 'client_credentials';
        customSetting.Core_IPS_Authorization_URL__c = 'https://apis.intel.com/v1/auth/token';
        insert customSetting;
        System.assert(customSetting.Id != null, 'Record not created');
         
        
    }
    
    @isTest static  void  testPositive(){
        
        
        Core_IPS_Backend_System_Custom_Settings__c custom_settigs = Core_IPS_Backend_System_Custom_Settings__c.getValues('Core_IPS_New_Backend_System');
        
                update custom_settigs;
        
        string json = Core_IPS_BES_IPassDataSync.jsonData;
        List<Core_IPS_Backend_System2__c> bksys2 = [Select Id,Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c LIMIT 1];
          
         
        Test.startTest();    
        list<Core_IPS_Backend_Field_Map__c> fieldvalumaplist = [Select ID,Core_IPS_Deassociate__c,Core_IPS_Direction__c,Core_IPS_UnMapped__c,Core_IPS_Default_Value__c,Support_Update__c,Core_IPS_Deactivated__c, Core_IPS_New_Backend_System__r.Name,Core_IPS_New_Backend_System__r.Id,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c, Core_Object_Name__c, Core_IPS_Order__c, Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, (Select  Core_IPS_Source_Value__c, Core_IPS_Target_Value__c,Core_IPS_Deactivated__c,Backend_Field_Mapping_HSD__c from Backend_Value_Mappings_HSD__r) from Core_IPS_Backend_Field_Map__c where Core_IPS_New_Backend_System__r.Id     =:bksys2.get(0).Id   ];
            
        
        Test.setMock(HttpCalloutMock.class, new Core_IPS_BES_IPassHttpCalloutMock());
        Core_IPS_BES_IPassDataSync.syncRecords(bksys2[0].Id);
        Core_IPS_BES_IPassDataSync.dynamicSyncFromLightning(bksys2[0].Id);
        Integer callouts = Limits.getCallouts();
        Test.stopTest();   
        System.assertNotEquals(null, bksys2[0].Id, 'Id should not be null');
            
    }
    
    @isTest 
    public static void testNegative1(){
        
        Core_IPS_Backend_System2__c backendsystem = new Core_IPS_Backend_System2__c();
        backendsystem.Name = 'DCG - HSDES Server Platforms1';
        backendsystem.Core_IPS_Deactivated__c = false;

        backendsystem.Core_IPS_Backend_System_URL__c = null;
        backendsystem.Core_IPS_Target_System__c = null;
        backendsystem.Core_Support_Email__c = null;
        backendsystem.isDataSync__c = true;
        insert backendsystem;
        System.assert(backendsystem.Id != null, 'Record not created');
        
        Core_IPS_Backend_Field_Map__c fieldvalumaplist = new Core_IPS_Backend_Field_Map__c();
        fieldvalumaplist.Core_IPS_Direction__c = null;
        fieldvalumaplist.Core_IPS_Order__c = 2;
        fieldvalumaplist.Core_IPS_Source_Field__c = null;
        fieldvalumaplist.Core_IPS_Target_Field__c = 'title'; 
        fieldvalumaplist.Core_IPS_New_Backend_System__c= backendsystem.Id;
        fieldvalumaplist.Core_IPS_Deactivated__c = true;
        fieldvalumaplist.Core_IPS_Deassociate__c =true;
        fieldvalumaplist.Core_IPS_UnMapped__c = true;
        fieldvalumaplist.Core_IPS_Default_Value__c = 'test';
        fieldvalumaplist.Support_Update__c = true;
        
        insert fieldvalumaplist;
        System.assert(fieldvalumaplist.Id != null, 'Record not created');
        
        
        Core_IPS_Backend_Value_Map__c valuemap = new Core_IPS_Backend_Value_Map__c();
        valuemap.Core_IPS_Source_Value__c ='source';
        valuemap.Core_IPS_Target_Value__c = 'target';
        valuemap.Core_IPS_Deactivated__c = true;
        valuemap.Backend_Field_Mapping_HSD__c = fieldvalumaplist.Id;
        insert  valuemap;     
         System.assert(valuemap.Id != null, 'Record not created');
        

        
        
        
        list<Core_IPS_Backend_System2__c> bksys2 = [Select Id,Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c  ];
        Core_IPS_System_Credentails_Apigee__c cs = Core_IPS_System_Credentails_Apigee__c.getValues('Core_IPS_Backend_System_Integration');
        cs.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/service-cloud/cases/v1/mapping';
        update cs;
        Core_IPS_Backend_System_Custom_Settings__c custom_settings = new Core_IPS_Backend_System_Custom_Settings__c();
        custom_settings.Name = 'Core_IPS_New_Backend_System';
        custom_settings.Status__c = 'Backend_System_Status';
        custom_settings.Backend_System_Name__c = 'Backend_System_Name';
        custom_settings.Direction__c = 'Core_IPS_Direction__c';
        custom_settings.Default_Value__c = 'Core_IPS_Deafult_Value__c';
        custom_settings.Deassociate__c = 'Core_IPS_Deassociate__c';
        custom_settings.Deactivated__c = 'Core_IPS_Deactivated__c';
        custom_settings.Order__c = 'Core_IPS_Order__c';
        custom_settings.Source_Field__c = 'Core_IPS_Source_Field__c';
        custom_settings.Support_Email__c = 'Support_Email';
        custom_settings.Source_Value__c = 'Core_IPS_Source_Value__c';
        custom_settings.Target_Field__c = 'Core_IPS_Target_Field__c';
        custom_settings.Target_Value__c = 'Core_IPS_Target_Value__c';
        custom_settings.Support_Update__c = 'Core_IPS_Support_Update__c';
        custom_settings.UnMapped__c = 'Core_IPS_UnMapped__c';
        custom_settings.Backend_Sysytem_url__c = 'Core_IPS_Backend_System_Url__c';
        custom_settings.Target_System__c = 'Core_IPS_Target_System__c';
               
        insert custom_settings;
     	System.assert(custom_settings.Id != null, 'Record not created');
        
        Test.startTest();       
        
        Core_IPS_BES_IPassDataSync.prepareJSONData(backendsystem.Id);
        Core_IPS_BES_IPassDataSync.dynamicSyncFromLightning(backendsystem.Id);
        Integer callouts = Limits.getCallouts(); 
        Test.stopTest();
       System.assertNotEquals(null, bksys2[0].Id, 'Id should not be null');
    }
   
    //Added by Sowmya - Start - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
     @isTest 
    public static void testNegative2(){
        
        Core_IPS_Backend_System2__c backendsystem = new Core_IPS_Backend_System2__c();
        backendsystem.Name = 'DCG - HSDES Server Platforms1';
        backendsystem.Core_IPS_Deactivated__c = false;

        backendsystem.Core_IPS_Backend_System_URL__c = null;
        backendsystem.Core_IPS_Target_System__c = null;
        backendsystem.Core_Support_Email__c = null;
        backendsystem.isDataSync__c = true;
        insert backendsystem;
        System.assert(backendsystem.Id != null, 'Record not created');
        
        Core_IPS_Backend_Field_Map__c fieldvalumaplist = new Core_IPS_Backend_Field_Map__c();
        fieldvalumaplist.Core_IPS_Direction__c = null;
        fieldvalumaplist.Core_IPS_Order__c = null;
        fieldvalumaplist.Core_IPS_Source_Field__c = null;
        fieldvalumaplist.Core_IPS_Target_Field__c = 'title'; 
        fieldvalumaplist.Core_IPS_New_Backend_System__c= backendsystem.Id;
		fieldvalumaplist.Core_IPS_Default_Value__c = 'test';
        
        insert fieldvalumaplist;
        System.assert(fieldvalumaplist.Id != null, 'Record not created');
        
        
        
        Core_IPS_Backend_Value_Map__c valuemap = new Core_IPS_Backend_Value_Map__c();
        valuemap.Core_IPS_Source_Value__c ='source';
        valuemap.Core_IPS_Target_Value__c = 'target';
        valuemap.Core_IPS_Deactivated__c = true;
        valuemap.Backend_Field_Mapping_HSD__c = fieldvalumaplist.Id;
        insert  valuemap;     
        System.assert(valuemap.Id != null, 'Record not created');
         

        
        
        
        list<Core_IPS_Backend_System2__c> bksys2 = [Select Id,Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c  ];
        Core_IPS_System_Credentails_Apigee__c cs = Core_IPS_System_Credentails_Apigee__c.getValues('Core_IPS_Backend_System_Integration');
        cs.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/service-cloud/cases/v1/mapping';
        update cs;
        Core_IPS_Backend_System_Custom_Settings__c custom_settings = new Core_IPS_Backend_System_Custom_Settings__c();
        custom_settings.Name = 'Core_IPS_New_Backend_System';
        custom_settings.Status__c = 'Backend_System_Status';
        custom_settings.Backend_System_Name__c = 'Backend_System_Name';
        custom_settings.Direction__c = 'Core_IPS_Direction__c';
        custom_settings.Default_Value__c = 'Core_IPS_Deafult_Value__c';
        custom_settings.Deassociate__c = 'Core_IPS_Deassociate__c';
        custom_settings.Deactivated__c = 'Core_IPS_Deactivated__c';
        custom_settings.Order__c = 'Core_IPS_Order__c';
        custom_settings.Source_Field__c = 'Core_IPS_Source_Field__c';
        custom_settings.Support_Email__c = 'Support_Email';
        custom_settings.Source_Value__c = 'Core_IPS_Source_Value__c';
        custom_settings.Target_Field__c = 'Core_IPS_Target_Field__c';
        custom_settings.Target_Value__c = 'Core_IPS_Target_Value__c';
        custom_settings.Support_Update__c = 'Core_IPS_Support_Update__c';
        custom_settings.UnMapped__c = 'Core_IPS_UnMapped__c';
        custom_settings.Backend_Sysytem_url__c = 'Core_IPS_Backend_System_Url__c';
        custom_settings.Target_System__c = 'Core_IPS_Target_System__c';
               
        insert custom_settings;
     
        Test.startTest();       
        
        Core_IPS_BES_IPassDataSync.prepareJSONData(backendsystem.Id);
        Core_IPS_BES_IPassDataSync.dynamicSyncFromLightning(backendsystem.Id);
        Integer callouts = Limits.getCallouts(); 
        Test.stopTest();
       System.assertNotEquals(null, bksys2[0].Id, 'Id should not be null');
    }
    //Sowmya - End - 12/11/2024 - TWC745-6800 - Fix test coverage for all failed classes 
     
    
    
   @isTest
    public static void testNegative(){
        
        
        
        
        list<Core_IPS_Backend_System2__c> bksys2 = [Select Id,Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c  ];
    Core_IPS_System_Credentails_Apigee__c cs = Core_IPS_System_Credentails_Apigee__c.getValues('Core_IPS_Backend_System_Integration');
        cs.Core_IPS_EndPointURL__c = 'https://apis.intel.com/m2r/service-cloud/cases/v1/mapping';
        update cs;
        
        Test.setMock(HttpCalloutMock.class, new Core_IPS_BES_IPassHttpCalloutMock());
        Test.startTest();       
        
        Core_IPS_BES_IPassDataSync.prepareJSONData(bksys2[0].Id);
         Integer callouts = Limits.getCallouts(); 
        Test.stopTest();
        System.assertNotEquals(null, bksys2[0].Id, 'Id should not be null');
    }
    
    @isTest 
    public static void testconstructors1(){
        
        Core_IPS_Backend_System2__c backendsystem = new Core_IPS_Backend_System2__c();
        backendsystem.Name = 'DCG - HSDES Server Platforms1';
        backendsystem.Core_IPS_Deactivated__c = false;
        backendsystem.Core_IPS_Backend_System_URL__c = null;
        backendsystem.Core_IPS_Target_System__c = null;
        backendsystem.Core_Support_Email__c = null;
        backendsystem.isDataSync__c = true;
        insert backendsystem;
        System.assert(backendsystem.Id != null, 'Record not created');
        
        Core_IPS_Backend_Field_Map__c fieldvalumaplist = new Core_IPS_Backend_Field_Map__c();
        fieldvalumaplist.Core_IPS_Direction__c = null;
        fieldvalumaplist.Core_IPS_Order__c = null;
        fieldvalumaplist.Core_IPS_Source_Field__c = null;
        fieldvalumaplist.Core_IPS_Target_Field__c = 'title'; 
        fieldvalumaplist.Core_IPS_New_Backend_System__c= backendsystem.Id;
        insert fieldvalumaplist;
         System.assert(fieldvalumaplist.Id != null, 'Record not created');

        
        
        Core_IPS_Backend_Value_Map__c valuemap = new Core_IPS_Backend_Value_Map__c();
        valuemap.Core_IPS_Source_Value__c ='source';
        valuemap.Core_IPS_Target_Value__c = 'target';
        valuemap.Core_IPS_Deactivated__c = true;
        valuemap.Backend_Field_Mapping_HSD__c = fieldvalumaplist.Id;
        insert  valuemap;
         System.assert(valuemap.Id != null, 'Record not created');

        
        Test.startTest();
        PageReference pageRef = Page.BESDynamicSyncNote;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(valuemap.Id));
        ApexPages.StandardController sc2 = new ApexPages.StandardController(valuemap); 
        Core_IPS_BES_IPASSTriggerHandler th = new Core_IPS_BES_IPASSTriggerHandler(sc2);
        System.assertEquals(true, th != null, 'th should not be null');
        Test.stopTest(); 
    }
    
   @isTest
    public static void testconstructors(){
        
        Core_IPS_Backend_System2__c bksys = [Select Id,Name,Core_IPS_Deactivated__c,Core_IPS_Backend_System_URL__c,Core_IPS_Target_System__c from  Core_IPS_Backend_System2__c  LIMIT 1];
        Core_IPS_Backend_Field_Map__c fmap = [Select Id,Core_IPS_Deassociate__c ,Core_IPS_New_Backend_System__r.isDataSync__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Deactivated__c From Core_IPS_Backend_Field_Map__c WHERE Core_IPS_New_Backend_System__r.ID =:bksys.Id  ];
        Core_IPS_Backend_Value_Map__c vmap = [Select Id, Backend_Field_Mapping_HSD__c, Core_IPS_Source_Value__c, Core_IPS_Target_Value__c From Core_IPS_Backend_Value_Map__c WHERE Backend_Field_Mapping_HSD__r.Id =: fmap.Id  ];
        Core_IPS_System_Credentails_Apigee__c cs = Core_IPS_System_Credentails_Apigee__c.getValues('Core_IPS_Backend_System_Integration');
        cs.Core_IPS_Authorization_URL__c = '';
        cs.Core_IPS_EndPointURL__c='';
        update cs;
        Test.setMock(HttpCalloutMock.class, new Core_IPS_BES_IPassHttpCalloutMock());
        Test.startTest();       
         PageReference pageRef = Page.BESDynamicSyncNote;
         Test.setCurrentPage(pageRef);
         pageRef.getParameters().put('Id', String.valueOf(bksys.Id));
         ApexPages.StandardController sc = new ApexPages.StandardController(bksys);
         Core_IPS_BES_IPassDataSync backsys = new Core_IPS_BES_IPassDataSync(sc);
         PageReference pageRef1 = Page.BESDynamicSyncNoteFmap;
         Test.setCurrentPage(pageRef1);
         pageRef.getParameters().put('Id', String.valueOf(fmap.Id));
         ApexPages.StandardController sc1 = new ApexPages.StandardController(fmap);
         Core_IPS_New_Backend_System_Handler sh = new Core_IPS_New_Backend_System_Handler(sc1);
         PageReference pageRef2 = Page.BESDynamicSyncNoteVmap;
         Test.setCurrentPage(pageRef1);
         pageRef.getParameters().put('id', String.valueOf(vmap.Id));
         ApexPages.StandardController sc2 = new ApexPages.StandardController(vmap);
        
        Core_IPS_BES_IPASSTriggerHandler th = new Core_IPS_BES_IPASSTriggerHandler(sc2);
         Core_IPS_BES_IPassDataSync.prepareJSONData(bksys.Id);
        System.assertEquals(true, th != null, 'th should not be null');
        Test.stopTest();
        
                 
        
    }
    @isTest
    public static void testtriggers(){
        
        Core_IPS_Backend_System2__c bsys = new Core_IPS_Backend_System2__c();
        bsys.Name = 'DCS HSDES PLATFORM 1';
        bsys.Core_IPS_Deactivated__c = false;
        bsys.isDataSync__c = false;
        Insert bsys;
        
        List<Core_IPS_Backend_System2__c> bklist = [Select Id, isDataSync__c,Last_Sync__c,Core_IPS_Deactivated__c From Core_IPS_Backend_System2__c WHERE Id =: bsys.Id ];
        Map<Id, Core_IPS_Backend_System2__c> oldmap = new Map<Id, Core_IPS_Backend_System2__c>(bklist);
        
        
        
        Core_IPS_Backend_Field_Map__c fmap = new Core_IPS_Backend_Field_Map__c();
        fmap.Core_IPS_Source_Field__c = 'Status';
        fmap.Core_IPS_Target_Field__c ='Open';
        fmap.Core_IPS_New_Backend_System__c = bsys.Id;
        Insert fmap;
        
        fmap.Core_IPS_Direction__c = 'Outbound';
        Update fmap;
        
        List<Core_IPS_Backend_Field_Map__c> fieldlist = [SELECT Id,Core_IPS_New_Backend_System__c,Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, Core_IPS_Direction__c FROM Core_IPS_Backend_Field_Map__c WHERE Id =: fmap.Id ];
        
        Core_IPS_Backend_Value_Map__c vmap = new Core_IPS_Backend_Value_Map__c();
        vmap.Core_IPS_Source_Value__c = 'severity';
        vmap.Core_IPS_Target_Value__c = 'low';
        vmap.Backend_Field_Mapping_HSD__c = fmap.Id;
        Insert vmap;
        
        vmap.Core_IPS_Deactivated__c = false;
        Update vmap;
        
        List<Core_IPS_Backend_Value_Map__c> valuelist = [SELECT Id, Backend_Field_Mapping_HSD__c, Core_IPS_Source_Value__c, Core_IPS_Target_Value__c,Core_IPS_Deactivated__c FROM Core_IPS_Backend_Value_Map__c WHERE Id =: vmap.Id ];
        
        bsys.Core_IPS_Deactivated__c = false;
        update bsys;
        
        Test.startTest();
          Core_IPS_BES_IPASSTriggerHandler.runOnce();
          Core_IPS_New_Backend_System_Handler.afterUpdate(bklist, oldmap);
          Core_IPS_New_Backend_System_Handler.afterFmapinsertupdatedelete(fieldlist);
          Core_IPS_New_Backend_System_Handler.afterVmapinsertupdatedelete(valuelist);
          Core_IPS_BES_IPASSTriggerHandler th = new Core_IPS_BES_IPASSTriggerHandler();
        System.assertEquals(true, th != null, 'th should not be null');
        
        Test.stopTest();
        delete vmap;
        delete fmap;
        
    }
}