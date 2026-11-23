@isTest
public class ER_WelcomeEmailUtility_Test {
    public static boolean IsErrorTest = true;
     @testSetup    
    
    static void setupDataCreation()
    {
        Account acc = PRM_TestUtility.getAccount();
        acc.Name = 'Dell US';
        acc.BillingCity='Bengaluru';
        acc.BillingCountry='India';
        acc.BillingStreet='4th Floor,ITPL,Brookfield';
        acc.BillingPostalCode='560037';
        insert(acc);  
        
        Contact cont= PRM_TestUtility.getContact();
        cont.AccountId=acc.Id;
        insert(cont);
        
        String Core_Permission_Set_API_Nm_c = [SELECT id,Name FROM PermissionSet LIMIT 1].Name;
        String Core_Public_Group_API_Nm_c = [SELECT id,DeveloperName FROM Group LIMIT 1].DeveloperName;
        
        Core_AGS_Role__c objAGSRole = new Core_AGS_Role__c();
        objAGSRole.Name= 'Test_AGS_Role_02';
        objAGSRole.Core_Technical_Name__c = 'Test_AGSRole_02_TechName';
        objAGSRole.Core_IsActive__c = true;
        insert objAGSRole;	
        List<Core_Entitlement__c> objEntitlementList= new List<Core_Entitlement__c>();
        Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
        objEntitlement1.Name = 'Resource & Design Center for Secure Content';
        objEntitlement1.Core_Display_Name__c = 'Resource & Design Center for Secure Content';
        objEntitlement1.Core_IsActive__c = true;
        objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement1.Core_Category__c = '';
        objEntitlement1.Core_Sub_Category__c = '';       
        objEntitlement1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        //insert objEntitlement1;
        objEntitlementList.add(objEntitlement1);
        
        Core_Entitlement__c objEntitlement2 = new Core_Entitlement__c();
        objEntitlement2.Name = 'Resource & Design Center for Secure Content1';
        objEntitlement2.Core_Display_Name__c = 'Resource & Design Center for Secure Content1';
        objEntitlement2.Core_IsActive__c = true;
        objEntitlement2.Core_Category__c = '';
        objEntitlement2.Core_Sub_Category__c = '';       
        objEntitlement2.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement2.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        objEntitlementList.add(objEntitlement2);
        //insert objEntitlementList;
        
        Core_Entitlement__c ento = new Core_Entitlement__c();
        ento.Name = 'OLO Label Orderer';
        ento.Core_Display_Name__c = 'OLO Label Orderer';
        ento.Core_IsActive__c = true;
        ento.Core_Category__c = '';
        ento.Core_Sub_Category__c = '';       
        ento.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        ento.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        objEntitlementList.add(ento);
        insert objEntitlementList;
        
        Business_Types__c bt = new Business_Types__c();
        bt.Name = 'Developer Zone Premier';
        bt.Is_Active__c = true;
        bt.Business_Type_Code__c = 'DZP';
        insert bt;
        
        List<PRM_VXEnttlmntMatrix__c> emList = new List<PRM_VXEnttlmntMatrix__c>();
        PRM_VXEnttlmntMatrix__c em= new PRM_VXEnttlmntMatrix__c(); //Entitlement Matrix
        em.PRM_Entitlement_Id__c = objEntitlement1.id;
        em.PRM_Approval_Type_Nm__c='Automatic';
        em.Business_Types__c = bt.Id;
        emList.add(em);
        
        PRM_VXEnttlmntMatrix__c em1= new PRM_VXEnttlmntMatrix__c();
        em1.PRM_Entitlement_Id__c = ento.id;
        em1.PRM_Approval_Type_Nm__c='Automatic';
        em1.Business_Types__c = bt.Id;
        emList.add(em1);

        insert emList;
        
        List<Core_Contact_Entitlement__c> conEntList = new  List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ceOld=new Core_Contact_Entitlement__c();
        ceOld.Core_Contact_Id__c=cont.Id;
        ceOld.Core_Entitlement_Id__c=objEntitlement1.Id;
        ceOld.Core_Selected__c=false;
        ceOld.Core_Status__c='Pending';
        ceOld.Core_Email_Pending_To_Requester_Ind__c=true;
        //insert ceOld;
        conEntList.add(ceOld);
        
        Core_Contact_Entitlement__c ceOld1=new Core_Contact_Entitlement__c();
        ceOld1.Core_Contact_Id__c=cont.Id;
        ceOld1.Core_Entitlement_Id__c=objEntitlement2.Id;
        ceOld1.Core_Selected__c=false;
        ceOld1.Core_Status__c='Pending';
        ceOld1.Core_Email_Pending_To_Requester_Ind__c=true;
        //insert ceOld1;
        conEntList.add(ceOld1);
        
        Core_Contact_Entitlement__c ceOldO=new Core_Contact_Entitlement__c();
        ceOldO.Core_Contact_Id__c=cont.Id;
        ceOldO.Core_Entitlement_Id__c=ento.Id;
        ceOldO.Core_Selected__c=false;
        ceOldO.Core_Status__c='Pending';
        ceOldO.Core_From_Source__c=true;
        ceOldO.Core_Email_Pending_To_Requester_Ind__c=true;
        
        conEntList.add(ceOldO);
        insert conEntList;
    }
    
    @isTest 
    //When EVdatetime is not null
    public static void updateEntitlmentToComplete(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_IPA_Email_Verification_Date__c=Datetime.now();
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('EVdatetime is not null'+ ce);  
        Test.startTest();
        update ce;
        Test.stopTest();
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        
        System.assertEquals(ceUpd.Core_Email_Pending_To_Requester_Ind__c,true,'Change in  Value on WlcmEmail is sent out!! ');
        
    }
    
    @isTest 
    //When EVdatetime is not null
    public static void updateEntitlmentException(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_IPA_Email_Verification_Date__c=Datetime.now();
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content1' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('EVdatetime is not null'+ ce);
        Test.startTest();
        update ce;
        Test.stopTest();
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        
        System.assertEquals(ceUpd.Core_Email_Pending_To_Requester_Ind__c,true,'Change in  Value on WlcmEmail is sent out!! ');
        
    }
    
     @isTest 
    //When EVtoken is not null
    public static void updateEntitlmentToComplete_withEVToken(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_Email_Verification_Token__c='WRET!@#$%RTREE$#@';
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('EVtoken is not null'+ ce);
        Test.startTest();
        update ce;
        Test.stopTest();
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        
        System.assertEquals(ceUpd.Core_Email_Pending_To_Requester_Ind__c,true,'Change in Value - email with EVtoken is sent out!! ');
        
    }
    
      @isTest 
    //When PWdtoken is not null
    public static void updateEntitlmentToComplete_withPwdToken(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c,Core_Password_Token__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_Password_Token__c='PwdET$%#@';
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('PwdToken is not null'+ ce);
        Test.startTest();
        update ce;
        Test.stopTest();
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='Resource & Design Center for Secure Content' limit 1];
        
        System.assertEquals(ceUpd.Core_Email_Pending_To_Requester_Ind__c,true,'Change in Value - email with Pwdtoken is sent out!! ');
        
    }
    
    @isTest 
    //When EVdatetime is not null
    public static void updateEntitlmentToCompleteOLO(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='OLO Label Orderer' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        ce.Core_From_Source__c=false;
        system.debug('219EVdatetime is not null'+ ce);  
        Test.startTest();
        update ce;
        Test.stopTest();
        PRM_EmailLog__c eLog = [SELECT Id, name, PRM_EmailDeliverabilityStatus__c FROM PRM_EmailLog__c WHERE PRM_ToEmailID__c = 'testrequest@mailinator.com' LIMIT 1];
        System.debug('221elog'+elog);
        //System.debug('email length'+eLog.PRM_ToEmailID__c.length());
        System.assertEquals(eLog.PRM_EmailDeliverabilityStatus__c,true,'Email is sent out!! ');
        
    }
    
}