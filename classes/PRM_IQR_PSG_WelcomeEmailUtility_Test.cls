@isTest
public class PRM_IQR_PSG_WelcomeEmailUtility_Test {
	
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
        
        Core_Entitlement__c objEntitlement1 = new Core_Entitlement__c();
        objEntitlement1.Name = 'PSG Disti Quoting Access';
        objEntitlement1.Core_Display_Name__c = 'PSG Disti Quoting Access';
        objEntitlement1.Core_IsActive__c = true;
        objEntitlement1.Core_AGS_Role_Id__c = objAGSRole.id;
        objEntitlement1.Core_Category__c = '';
        objEntitlement1.Core_Sub_Category__c = '';       
        objEntitlement1.Core_Permission_Set_API_Nm__c = Core_Permission_Set_API_Nm_c;
        objEntitlement1.Core_Public_Group_API_Nm__c = Core_Public_Group_API_Nm_c;
        insert objEntitlement1;
        
        Core_Contact_Entitlement__c ceOld=new Core_Contact_Entitlement__c();
        ceOld.Core_Contact_Id__c=cont.Id;
        ceOld.Core_Entitlement_Id__c=objEntitlement1.Id;
        ceOld.Core_Selected__c=false;
        ceOld.Core_Status__c='Pending';
        ceOld.Core_Email_Pending_To_Requester_Ind__c=true;
        insert ceOld;
        
    }
    
     @isTest 
    //When EVdatetime is not null
    public static void updateEntitlmentToComplete(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_IPA_Email_Verification_Date__c=Datetime.now();
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('EVdatetime is not null'+ ce);        
        update ce;
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c,Core_Status__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        
        System.assertEquals(ceUpd.Core_Status__c,'Complete','Change in  Value on WlcmEmail is sent out!! ');
        
    }
    
     @isTest 
    //When EVtoken is not null
    public static void updateEntitlmentToComplete_withEVToken(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_Email_Verification_Token__c='WRET!@#$%RTREE$#@';
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('EVtoken is not null'+ ce);
        update ce;
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c,Core_Status__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        
        System.assertEquals(ceUpd.Core_Status__c,'Complete','Change in Value - email with EVtoken is sent out!! ');
        
    }
    
      @isTest 
    //When PWdtoken is not null
    public static void updateEntitlmentToComplete_withPwdToken(){
        Contact testcont =[SELECT id,Core_Email_Verification_Token__c,Core_IPA_Email_Verification_Date__c,Core_Password_Token__c
                           FROM Contact WHERE Email = 'testrequest@mailinator.com' limit 1 ];
        
        testcont.Core_Password_Token__c='PwdET$%#@';
        update testcont;
        
        Core_Contact_Entitlement__c ce =[SELECT Id,Name,Core_Selected__c,Core_Status__c,Core_Email_Pending_To_Requester_Ind__c FROM Core_Contact_Entitlement__c
                                         where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        ce.Core_Selected__c=true;
        ce.Core_Status__c='Complete';
        system.debug('PwdToken is not null'+ ce);
        update ce;
        
        Core_Contact_Entitlement__c ceUpd=[SELECT Id,Name,Core_Email_Pending_To_Requester_Ind__c,Core_Status__c FROM Core_Contact_Entitlement__c
                                           where Core_Entitlement_Nm__c='PSG Disti Quoting Access' limit 1];
        
        System.assertEquals(ceUpd.Core_Status__c,'Complete','Change in Value - email with Pwdtoken is sent out!! ');
        
    }
}