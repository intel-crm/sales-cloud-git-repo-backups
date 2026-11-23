@isTest
public class Core_IPS_BES_CommentOutbound_Test {

    @testSetup 
    static void setupMethod() {
        list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Customer', value__c='Customer Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Internal', value__c='Internal Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - B2B API', value__c='B2B API'));
        lstCs.add(new Core_IPS_Labels__c(name='Partner - Agent', value__c='Partner - Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL', Value__c = 'Private to Intel'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Customer', Value__c = 'Customer'));
        lstCs.add(new Core_IPS_Labels__c(name = 'Partner', value__c = 'Partner'));
        lstCs.add(new Core_IPS_Labels__c (name='FAE', value__c='FAE'));
        lstCs.add(new Core_IPS_Labels__c(name='Backend Integration', value__c='Backend Integration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Partner - DFAE', value__c= 'Partner - DFAE'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Backend System', value__c='Backend System'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Email', value__c='Email')); 
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - N/A', value__c='N/A'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_AGENTS', value__c='PRIVATE_TO_AGENTS'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_PARTNERS', value__c='PRIVATE_TO_PARTNERS'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Core_IPS_target_system', value__c='target_system'));
        insert lstCs;  
        
        List<IPS_Case_Comment_Fields__c> caseCommentFields = new List<IPS_Case_Comment_Fields__c>();
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Email', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By_Email__c',
                                                            Comment_Field_Type__c = 'Text', JSON_Field_Name__c = 'authored_by_email', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Id', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By__c',
                                                            Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'authored_by_id', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Name', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By_Name__c',
                                                            Comment_Field_Type__c = 'Text', JSON_Field_Name__c = 'authored_by_name', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author type', Comment_Field_API_Name__c = 'Core_IPS_Comment_Author_Type__c',
                                                            Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'author_type', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Case Comment Source', Comment_Field_API_Name__c = 'Core_IPS_Case_Comment_Source__c',
                                                            Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'comment_source', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Comment text', Comment_Field_API_Name__c = 'Core_IPS_Rich_Comment__c',
                                                            Comment_Field_Type__c = 'Rich Text Area(131072)', JSON_Field_Name__c = 'comment_text', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Comment Type', Comment_Field_API_Name__c = 'Core_IPS_Case_Comment_Type__c',
                                                            Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'comment_type', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Created by Id', Comment_Field_API_Name__c = 'CreatedById',
                                                            Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'created_by_id', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Created by Name', Comment_Field_API_Name__c = 'CreatedBy.Name',
                                                            Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'created_by_name', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'CreatedDate', Comment_Field_API_Name__c = 'CreatedDate',
                                                            Comment_Field_Type__c = 'Date/Time', JSON_Field_Name__c = 'created_datetime', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        insert caseCommentFields;

    }

    @isTest
    public static void testComments(){
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        insert cs;
        
        Test.startTest();
            Core_IPS_Case_Comments__c objCmt = new Core_IPS_Case_Comments__c();
            objCmt.Core_IPS_Case__c = cs.id;
            objCmt.Core_IPS_Comment_Author_Type__c = 'Agent';
            objCmt.Core_IPS_Case_Comment_Type__c = 'Public to Customers'; 
            objCmt.Core_IPS_Rich_Comment__c = 'Test from test class';
            objCmt.Core_IPS_Comment_Authored_By_Name__c = 'Test Farooq'; 
            objCmt.Core_IPS_Comment_Authored_By__c = userInfo.getUserId();
            objCmt.Core_IPS_Case_Comment_Source__c = 'Internal Portal';
        insert objCmt;
        Test.stopTest();
         List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
         outboundObject.add(new Core_IPS_BES_Outbound_Message__c(core_IPS_Outbound_Message_ID__c = '123',
                                                                 Core_IPS_Case_ID__c = cs.Id,
                                                                 Comment_Id__c = objCmt.Id));
        insert outboundObject;
        if(outboundObject.size()>0){
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id});
        }
        
        System.assert(objCmt.Id!=null);
    }

    @isTest
    public static void negitiveTest(){
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_BackendID__c = '121212212333';
        insert cs;
        Test.startTest();
        Core_IPS_Case_Comments__c objCmt1 = new Core_IPS_Case_Comments__c();
            objCmt1.Core_IPS_Case__c = cs.id;
            objCmt1.Core_IPS_Comment_Author_Type__c = 'Agent';
            objCmt1.Core_IPS_Case_Comment_Type__c = 'Public to Customers'; 
            objCmt1.Core_IPS_Comment_Authored_By_Name__c = 'Test Farooq'; 
            objCmt1.Core_IPS_Comment_Authored_By__c = userInfo.getUserId();
            objCmt1.Core_IPS_Case_Comment_Source__c = 'Internal Portal';
        insert objCmt1;
        Test.stopTest();
        List<Core_IPS_BES_Outbound_Message__c> outboundObject1 = new List<Core_IPS_BES_Outbound_Message__c>();
         outboundObject1.add(new Core_IPS_BES_Outbound_Message__c(core_IPS_Outbound_Message_ID__c = '123',
                                                                 Core_IPS_Case_ID__c = cs.Id,
                                                                 Comment_Id__c = objCmt1.Id));
        insert outboundObject1;
        List<IPS_Case_Comment_Fields__c> caseCommentFields = new List<IPS_Case_Comment_Fields__c>();
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Comment Type', Comment_Field_API_Name__c = 'Core_IPS_Case_Comment_Type_',
                                                            Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'comment_type', Object_Name__c = 'Core_IPS_Case_Comments_'));
        insert caseCommentFields;
        if(outboundObject1.size()>0){
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject1[0].Id});
        }
         System.assert(objCmt1.Id!=null);
    }

    @isTest
    public static void testDisconnectedComments(){
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        insert cs;
        
        Test.startTest();
        Core_IPS_Case_Comments__c objCmt = new Core_IPS_Case_Comments__c();
        objCmt.Core_IPS_Case__c = cs.id;
        objCmt.Core_IPS_Comment_Author_Type__c = 'Agent';
        objCmt.Core_IPS_Case_Comment_Type__c = 'Private to Intel'; 
        objCmt.Core_IPS_Rich_Comment__c = '	IPS case is Disconnected from HSD';
        objCmt.Core_IPS_Comment_Authored_By_Name__c = 'Test Farooq'; 
        objCmt.Core_IPS_Comment_Authored_By__c = userInfo.getUserId();
        objCmt.Core_IPS_Case_Comment_Source__c = 'Internal Portal';
        insert objCmt;

        System.debug('cs: ' + cs.Id);
        cs.Core_IPS_New_Backend_System__c = null;
        cs.Core_IPS_BackendID__c = '';
        update cs;
        Test.stopTest();
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c(core_IPS_Outbound_Message_ID__c = '123',
                                                                    Core_IPS_Case_ID__c = cs.Id,
                                                                    Comment_Id__c = objCmt.Id,
                                                                    Core_IPS_BES_Depromote_Id__c = '38724834674',
                                                                    Core_IPS_Old_Backend_String__c = '1231231231'));
        
        insert outboundObject;
        if(outboundObject.size()>0){
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id});
        }
        System.assert(objCmt.Id!=null);
    }

}