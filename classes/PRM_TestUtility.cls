/*********************************************************************************************************************
Class Name  : PRM_TestUtility
Version       : 1.0
Created Date  : OCT 2018
Function      : Utility Class for 'Core_PRM'

Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------------------------
* Kushal Soni               10/08/2018              Utility Class for 'Core_PRM'

*********************************************************************************************************************/
@isTest
public class PRM_TestUtility{
    
    /*Method to get 'Registration Request' object*/
    public static PRM_Registration_Request__c getPRMRegistrationRequest(){
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.Name = 'RR1';
        regRequest.PRM_EmailVerifiedDateTime__c=System.Today();
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.PRM_Account_Name__c='Intel';
        regRequest.PRM_Company_Email_Domain__c='intel.com';
        regRequest.PRM_Address_Line_1__c='4th Floor,ITPL Main Road';
        regRequest.PRM_Address_Line_2__c='Bengaluru,India'; 
        regRequest.PRM_City__c='Las Vegas';
        regRequest.PRM_State_Province__c='NY';
        regRequest.PRM_Country__c='US';
        regRequest.PRM_Profile_Response__c ='{QuestionCode : IPA_Registration_Source | ResponseCode : IPA_Registration_Source_Web | ResponseValue : Web}';
        return regRequest;
    } 
    
    /*Method to get 'Partner Agreement' object*/
    public static ChannelProgram getChannelProgram(){
        ChannelProgram cp = new ChannelProgram();
        cp.Name='New Partner Program';
        cp.PRM_programCode__c='NPP';
        return cp;
    }
   /*Method to get 'Partner Agreement' object*/
    public static ChannelProgram getChannelPrograms(){
        ChannelProgram cprogram = new ChannelProgram();
        cprogram.Name='Intel Partner Alliance';
        cprogram.PRM_programCode__c='IPA';
        return cprogram;
    } 
    
    /*Method to get 'Partner Agreement' object*/
    public static PRM_PartnerAgreement__c getPartnerAgreement(){
        PRM_PartnerAgreement__c pa = new PRM_PartnerAgreement__c();
        pa.Name='New Partner Program Legal Agreement';
      // pa.Name='Intel Partner Alliance Terms & Condition';
        pa.PRM_Language_Codes__c='ENG';
        pa.PRM_Agreement_Cd__c='CHL_TNC_APAC_ENG';
      	//pa.PRM_Agreement_Cd__c='IPA_TANDC';
        return pa;
    } 
    
    /*Method to get 'Terms and Conditions' object*/
    /*public static Terms_and_Conditions__c getTermsAndConditions(){
        Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
        //tc.PRM_Registration_Requests__c=getPRMRegistrationRequest().Id;
        tc.Name='TCTestReq1';        
        return tc;
    }*/ 
    
    /*Method to get 'Account' object */
     public static Account getAccount(){
         
         
        Account a = new Account();
        a.Name='Intel';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        //a.Company_Domain__c='intel.com';
        return a;
    } 
    
    /*Method to get 'Log Entry' object */
     public static Core_Log_Entry__c getLogData(){
        Core_Log_Entry__c clog = new Core_Log_Entry__c();
        clog.Core_Details__c='aksjnc';
        clog.Core_Message__c='davfpol';
        clog.Core_Origin__c='oll';
        clog.Core_Project__c='intel';
        clog.Core_Scope__c='scope';
        clog.Core_Severity__c='severity';
        clog.Core_Support_Email__c ='testrequest@mailinator.com';
        clog.Core_Support_Link__c='https://www.google.com/';
        clog.Core_Tags__c='tags';
        return clog;
    } 
    
    /*Method to get 'PRM_AccountChannelMembership__c' object */
     public static PRM_AccountChannelMembership__c getMembership(){
        PRM_AccountChannelMembership__c acm = new PRM_AccountChannelMembership__c();
        acm.PRM_Status_Nm__c='Approved';
         acm.PRM_Partner_Role__c='Seller';
        return acm;
    } 
    
    /*Method to get 'Contact' object */
     public static Contact getContact(){
        Contact con = new Contact();
        con.FirstName='Matt';
        con.LastName='Smith';
        con.Email='testrequest@mailinator.com';
        con.Phone='9999779791';
        con.Core_IPA_PartnerRole__c = 'Distributor';
        con.MailingCountry = 'India';
     //   con.Core_IPA_PartnerRole__c = null;
        return con;
    } 
    
     public static PRM_AccountLegalAgreemntAssociation__c getAccountAgreementAssociation(){
        PRM_AccountLegalAgreemntAssociation__c accAgreement = new PRM_AccountLegalAgreemntAssociation__c();
        accAgreement.PRM_Agreement_Sign_Dt__c=System.Today();
        return accAgreement;
    } 
    
    /*To get Partner Types*/
     public static PRM_PartnerType__c getPartnerTypes(){
        PRM_PartnerType__c partnerType=new PRM_PartnerType__c();
        partnerType.Name='Reseller';
        partnerType.PRM_PartneryTypeCode__c='BIZTYCDRSL';
        partnerType.PRM_PartnerRoleCode__c='Seller';
        return partnerType;
    } 
    
    /*To get ERPM Engagement*/
     public static Core_ERPM_Engagement__c getERPMEngagement(){
        Core_ERPM_Engagement__c erpmEng=new Core_ERPM_Engagement__c();
        erpmEng.Name='Intel Technology Provider';
        erpmEng.Core_Technical_Engagement_Code__c='1';
        erpmEng.Core_Engagement_Type__c='SFT';
        return erpmEng;
    } 
    
    // To get Partner Benefit
     public static PRM_PartnerBenefit__c getPartnerBenefit(){
        PRM_PartnerBenefit__c pbenefit= new PRM_PartnerBenefit__c();
        pbenefit.Name='Marketing Studio';
        pbenefit.PRM_Benefit_Cd__c='BFTMKTSTD';
        return pbenefit;
    } 
    
    public static List<User> createUser(){
        String profileNameSet='System Administrator';
            UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Admin' LIMIT 1];
        Set<Id> userProfileIdSet=new Set<Id>();
        for(Profile proId : [SELECT id , Name  FROM Profile  WHERE Name = :profileNameSet]){
            userProfileIdSet.add(proId.Id);
        } 
        
        List<User> lstUser = new List<User>();
        User u = [select id from user where id =: UserInfo.getUserId() limit 1];
        System.runAs(u){
            for(Id profileId : userProfileIdSet){
                User u1 = new User(Alias = 'user13', Email= 'firstNameIPA9562@intel.com',
                                   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                   LocaleSidKey='en_US', ProfileId = profileId,IsActive = true,
                                   TimeZoneSidKey='America/Los_Angeles',UserRoleId = role.Id, UserName = 'FirstNameIPA9565Q@exampleTC.com' + Math.floor(Math.random() * 1000));
                
                lstUser.add(u1);                
            }
            
            insert lstUser;
           
        }  
        return lstUser;
    }
    
}