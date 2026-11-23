@isTest
public class ER_RejectionEmailUtility_Test {
    public static boolean IsErrorTest = true;
    @testSetup    
    static void setupDataCreation()
    {
        Core_Entitlement__c ent = new Core_Entitlement__c();
        ent.Name = 'Resource & Design Center for Secure Content';
        ent.Core_Display_Name__c = 'RDC Entitlement';
        insert ent;  
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'DZP';
        insert bt;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = ent.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        insert emList;
        
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id emailVerificationRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> regRequestList = new List<PRM_Registration_Request__c>();
        for(integer i=0; i<10; i++){
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name= 'RDCRejection'+i;
        regRequest.PRM_First_Name__c= 'RDCRejection'+i;
        regRequest.PRM_Last_Name__c= 'RDCRejection'+i;
        regRequest.PRM_Contact_Country__c= 'USA';
        regRequest.PRM_Contact_Login_ID__c= 'test_rdcuser'+i+'@mailinator.com';
        regRequest.PRM_Email_ID__c= 'test_rdcuser'+i+'@mailinator.com';
        regRequest.PRM_Enterprise_ID__c= '3000002446643';
        regRequest.Entitlement_Details__c= entt.Id;
        regRequest.PRM_EV_Token__c= 'EAAAAFEKpZnzESjs92XoY55f4ngu9BUyuOIraFcrFXziDwRdlXdOuIOyDgk3K+dJD7x3mZ83lu3LT3yn9PHHd7Z2q0CXeXQOFnEV2oKB/DivrTpg+TYum1pfXY2/Yq5Vin+38436zR3W4Z7zO9albgNnAljH0lj7JnfGAu90Z8Ju9K4oa1uzPqUoRXcacHaLGediMDSAhLcrvxqNwgthOeJ0loAbLMZYnQQ+3a6YOWAiyAsvUsGEXKfV1M2KNSbYeos8lA==';
        regRequest.PRM_Person_Phone_Number__c= '3232';
        regRequest.PRM_Preferred_Language__c= 'ENG';
        //regRequest.PRM_Profession__c = 'CONSULTANT';
        regRequest.PRM_Status__c= 'New';
        regRequestList.add(regRequest);
        }
        insert regRequestList;
        
    }
    
    @isTest 
    public static void sendRejectionEmail(){
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountApprovalRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> reqlist =[SELECT Id,Name,
                                          RecordTypeId,
                                          PRM_Account_Name__c,
                                          PRM_Address_Line_1__c,PRM_City__c, 
                                          PRM_Country__c,
                                          PRM_State_Province__c,
                                          PRM_Zip_Postal_Code__c,
                                          PRM_Account_URL__c,
                                          PRM_Account_Phone__c,
                                          PRM_Company_Size__c,
                                          PRM_Company_Email_Domain__c,
                                          PRM_EV_flag__c,
                                          //PRM_Job_Function__c,
                                          PRM_Profession__c,
                                          Entitlement_Details__c,
                                          PRM_EmailVerifiedDateTime__c,
                                          PRM_Legal_Agreements__c,
                                          PRM_Status__c,
                                          PRM_Status_Reason__c
                                          FROM PRM_Registration_Request__c];
        for(PRM_Registration_Request__c req:reqlist){
        req.RecordTypeId=accountApprovalRT;
        req.PRM_Account_Name__c= 'Apple; Inc.';
        req.PRM_Address_Line_1__c= '470 Potrero Ave';
        req.PRM_City__c= 'Sunnyvale';
        req.PRM_Country__c= 'USA';
        req.PRM_State_Province__c= 'CA';
        req.PRM_Zip_Postal_Code__c= '94085-4117';
        req.PRM_Account_URL__c= 'www.rdc.com';
        req.PRM_Account_Phone__c  = '9891744632' ;
        req.PRM_Company_Size__c  = '10000+' ;      
        req.PRM_Company_Email_Domain__c  = null;
        req.PRM_EV_flag__c  = false ;
        //req.PRM_Job_Function__c  = 'SALES-MKT' ;  
        req.PRM_Profession__c  = 'CONSULTANT' ; 
        req.Entitlement_Details__c = entt.Id ;                             
        req.PRM_EmailVerifiedDateTime__c  = DateTime.now() ;
        req.PRM_Legal_Agreements__c  = 'DZP_TANDC' ;
        req.PRM_Status__c  = 'Rejected' ;  
        req.PRM_Status_Reason__c  = 'Auto rejected as the Account Project budget does not meet RDC Privilege criteria';
        System.assertEquals(req.PRM_Status__c, 'Rejected');
        } 
        Test.startTest();
        update reqlist;
        Test.stopTest();
        PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c ='test_rdcuser9@mailinator.com'];
        System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,true,'Email is sent out!! ');
        
    }
    
    @isTest 
    public static void sendRejectionEmailLARCanada(){
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountApprovalRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> reqlist =[SELECT Id,Name,
                                          RecordTypeId,
                                          PRM_Account_Name__c,
                                          PRM_Address_Line_1__c,PRM_City__c, 
                                          PRM_Country__c,
                                          PRM_State_Province__c,
                                          PRM_Zip_Postal_Code__c,
                                          PRM_Account_URL__c,
                                          PRM_Account_Phone__c,
                                          PRM_Company_Size__c,
                                          PRM_Company_Email_Domain__c,
                                          PRM_EV_flag__c,
                                          //PRM_Job_Function__c,
                                          PRM_Profession__c,
                                          Entitlement_Details__c,
                                          PRM_EmailVerifiedDateTime__c,
                                          PRM_Legal_Agreements__c,
                                          PRM_Status__c,
                                          PRM_Status_Reason__c
                                          FROM PRM_Registration_Request__c];
        for(PRM_Registration_Request__c req:reqlist){
        req.RecordTypeId=accountApprovalRT;
        req.PRM_Account_Name__c= 'Apple; Inc.';
        req.PRM_Address_Line_1__c= '470 Potrero Ave';
        req.PRM_City__c= 'Sunnyvale';
        req.PRM_Country__c= 'USA';
        req.PRM_State_Province__c= 'CA';
        req.PRM_Zip_Postal_Code__c= '94085-4117';
        req.PRM_Account_URL__c= 'www.rdc.com';
        req.PRM_Account_Phone__c  = '9891744632' ;
        req.PRM_Company_Size__c  = '10000+' ;      
        req.PRM_Company_Email_Domain__c  = null;
        req.PRM_EV_flag__c  = false ;
        //req.PRM_Job_Function__c  = 'SALES-MKT' ;  
        req.PRM_Profession__c  = 'CONSULTANT' ; 
        req.Entitlement_Details__c = entt.Id ;                             
        req.PRM_EmailVerifiedDateTime__c  = DateTime.now() ;
        req.PRM_Legal_Agreements__c  = 'DZP_TANDC' ;
        req.PRM_Status__c  = 'Rejected' ;  
        req.PRM_Status_Reason__c  = 'Auto rejected as the Account belongs to LAR/Canada';
        }
        Test.startTest();
        update reqlist;
        Test.stopTest();
       PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c ='test_rdcuser9@mailinator.com'];
       System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,true,'Email is sent out!! ');
        
    }
     
    @isTest 
    public static void sendRejectionEmailException(){
        Core_Entitlement__c entt = [SELECT id from Core_Entitlement__c WHERE Name='Resource & Design Center for Secure Content' limit 1];
        Id accountApprovalRT = Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Account_Create_Request).getRecordTypeId();
        List<PRM_Registration_Request__c> reqlist =[SELECT Id,Name,
                                          RecordTypeId,
                                          PRM_Account_Name__c,
                                          PRM_Address_Line_1__c,PRM_City__c, 
                                          PRM_Country__c,
                                          PRM_State_Province__c,
                                          PRM_Zip_Postal_Code__c,
                                          PRM_Account_URL__c,
                                          PRM_Account_Phone__c,
                                          PRM_Company_Size__c,
                                          PRM_Company_Email_Domain__c,
                                          PRM_EV_flag__c,
                                          //PRM_Job_Function__c,
                                          PRM_Profession__c,
                                          Entitlement_Details__c,
                                          PRM_EmailVerifiedDateTime__c,
                                          PRM_Legal_Agreements__c,
                                          PRM_Status__c,
                                          PRM_Status_Reason__c
                                          FROM PRM_Registration_Request__c];
        for(PRM_Registration_Request__c req:reqlist){
        req.RecordTypeId=accountApprovalRT;
        req.PRM_Account_Name__c= 'Apple; Inc.';
        req.PRM_Address_Line_1__c= '470 Potrero Ave';
        req.PRM_City__c= 'Sunnyvale';
        req.PRM_Country__c= 'USA';
        req.PRM_State_Province__c= 'CA';
        req.PRM_Zip_Postal_Code__c= '94085-4117';
        req.PRM_Account_URL__c= 'www.rdc.com';
        req.PRM_Account_Phone__c  = '9891744632' ;
        req.PRM_Company_Size__c  = '10000+' ;      
        req.PRM_Company_Email_Domain__c  = null;
        req.PRM_EV_flag__c  = false ;
        //req.PRM_Job_Function__c  = 'SALES-MKT' ;
        req.PRM_Profession__c  = 'CONSULTANT' ;
        req.Entitlement_Details__c = null ;                             
        req.PRM_EmailVerifiedDateTime__c  = DateTime.now() ;
        req.PRM_Legal_Agreements__c  = 'DZP_TANDC' ;
        req.PRM_Status__c  = 'Rejected' ;  
        req.PRM_Status_Reason__c  = 'Auto rejected as the Account Project budget does not meet RDC Privilege criteria';
        }  
        Test.startTest();
        update reqlist;
        Test.stopTest();
        ER_RejectionEmailUtility.SendRejectionEmailNotifications(Null,Null);
        
    }   
}