@isTest
public class PRM_PartnerSearchController_Test {
    
    @isTest()
    public static void setup(){
        Test.startTest();
        
        PRM_PartnerSearchResultWrapper ps = new PRM_PartnerSearchResultWrapper();
        PRM_PartnerAccountDetailWrapper pa = new PRM_PartnerAccountDetailWrapper();
        PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper padetails = new PRM_PartnerAccountDetailWrapper.PartnerAdminWrapper();
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='123456';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Builder';
        newAccount.Core_IPA_Badge_Tier__c='Partner';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Program
        List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Partner';
        cpl.ProgramId=cp.Id;
        cplList.add(cpl);
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Prestige';
        cpl2.ProgramId=cp.Id;
        cplList.add(cpl2);
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Prestige';
        cpl3.ProgramId=cp.Id;
        cplList.add(cpl3);
        
        insert cplList;
        
        PRM_Value_Exchange_Data__c vxData = new PRM_Value_Exchange_Data__c();
        vxData.PRM_Sales_Amount_Report_Nbr__c = 12000;
        vxData.PRM_Training_Credit_Points_Report_Nbr__c = 20000;
        vxData.PRM_Account_Id__c = newAccount.id;
        vxData.PRM_One_Partner_Id__c = newPagAccount.id;
        vxData.PRM_Change_Date_Dt__c = System.today();
        vxData.PRM_Country_Market_Type_Nm__c = 'Emerging';
        vxData.PRM_From_Dt__c = Date.Today().addYears(-3);
        vxData.PRM_Partner_Role_Nm__c = 'Builder';
        vxData.PRM_Tier_Id__c = cplList[0].Id;
        vxData.PRM_To_Dt__c = Date.Today().addYears(-2);
        vxData.PRM_Sales_Calculation_Group_Txt__c = 'Component';
        vxData.PRM_Training_Credit_Points_Count_Nbr__c = 100;
       // vxData.PRM_TimePeriod_Nm__c='Q4 2019 - Q3 2020';
        vxData.PRM_Sales_Amount_Nbr__c=10000;
        insert vxData;   
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.MailingCountry= 'INDIA';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cont;
        
        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@mailinator.com';
        con2.Phone='9999779791';
        con2.AccountId = newAccount.Id;
        con2.MailingCountry= 'INDIA';
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
        insert con2;
        
        User u = new User(Alias = 'black', Email='testmail@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                      LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.test@peoplenet.com', contactid = con2.Id);
        
       /*  PRM_AccountLegalAgreemntAssociation__c alaa = new PRM_AccountLegalAgreemntAssociation__c();
        alaa.PRM_Account_Id__c = newAccount.Id;
        
        alaa.PRM_Contact__c = cont.Id;
        alaa.PRM_Agreement_Sign_Dt__c=system.now();
        alaa.PRM_InActive_Ind__c=false;   
        insert alaa;*/
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        contRelation.Name='Partner Admin';
        contRelation.PRM_Contact_Relationship_Cd__c ='PRIMARY';
        contRelation.PRM_Channel_Program_Id__c = cp.Id;
        contRelation.PRM_Default_Relationship_Ind__c = true;
        insert contRelation;
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
  //      acctContRel.PRM_Account_Id__r.Core_User_Defined_Website__c = newAccount.Core_User_Defined_Website__c;
        insert acctContRel;
        
        PRM_Account_Contact_Relationship__c acctContRel2=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel2.PRM_Account_Id__c=newAccount.Id;
        acctContRel2.PRM_Contact_Id__c=con2.Id;
        acctContRel2.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel2.PRM_InActive_Ind__c=false;
        acctContRel2.PRM_Status_Reason_Txt__c='Test';
        insert acctContRel2;
        
  // --------------------------------------------------
  // IPA Membership Attributes (Active + Inactive)
  // --------------------------------------------------
  
        PRM_IPAMembership_Attributes__c activeIpa = new PRM_IPAMembership_Attributes__c(
        PRM_Account_Id__c = newAccount.Id,
        PRM_Point_Status_Txt__c = 'Active',
        PRM_Point_Status_Dt__c = Date.today(),
        PRM_Point_Status_Reason_Txt__c = 'Active IPA',
        PRM_InActive_Ind__c = false
    );
        PRM_IPAMembership_Attributes__c inactiveIpa = new PRM_IPAMembership_Attributes__c(
        PRM_Account_Id__c = newAccount.Id,
        PRM_Point_Status_Txt__c = 'Not Eligible',
        PRM_Point_Status_Dt__c = Date.today().addDays(-10),
        PRM_Point_Status_Reason_Txt__c = 'Inactive IPA',
        PRM_InActive_Ind__c = true
    );
        
        insert new List<PRM_IPAMembership_Attributes__c>{activeIpa, inactiveIpa};
        
        PRM_PartnerAccountDetailWrapper result = PRM_PartnerSearchController.getAccountDetails(newAccount.Id);
        
        System.assertNotEquals(
        null,
        result,
        'Account detail wrapper should not be null'
    );
        
                // Ensure IPA Membership Attributes exist
        System.assertEquals(
            'Active',
            result.pointStatus,
            'Point status should come from active IPA membership only'
        );
        
        System.assertEquals(
            'Active',
            result.pointStatus,
            'Inactive IPA membership record must be ignored'
        );
                
        //PRM_PartnerSearchController.getAccountDetails(newAccount.Id);
        PRM_PartnerSearchController.getAccountDetails(newPagAccount.Id);
        PRM_PartnerSearchController.getAuth();
        System.RunAs(u){
        PRM_PartnerSearchController.getDistributors(newAccount.Name,newAccount.billingCountry, cplList[0].Name);
        PRM_PartnerSearchController.getDistributors(con2.Email,newAccount.BillingCountry, cplList[0].Name);
        
        ps.accountId=newAccount.Id;
        ps.accountName=newAccount.Name;
        ps.accountNumber=newAccount.AccountNumber;
        ps.accountLink=newAccount.Website;
        
        ps.billingCountry=newAccount.BillingCountry;
        ps.billingState=newAccount.BillingState;
        ps.billingZipcode=newAccount.BillingPostalCode;
        ps.partnerRole=newAccount.Core_IPA_Partner_Role__c;
        ps.partnerTier=newAccount.Core_IPA_Badge_Tier__c;
        
        pa.accountName=newAccount.Name;
        pa.accountNumber=newAccount.AccountNumber;
        pa.website=newAccount.Website;
        pa.ipaTCAccepted=true;
        pa.partnerRole='Builder';
        pa.partnerTier='Partner';
        pa.TrainingCreditCurPeriod=1200;
        
      //  padetails.partnerAdminName = cont.Name;
        padetails.partnerAdminEmail = cont.Email;
            
        }
        
        Test.stopTest();  
        List <PRM_PartnerSearchResultWrapper> psList = new List<PRM_PartnerSearchResultWrapper>();
        psList.add(ps);
        PRM_PartnerSearchController.getCountryList(psList);
        try{
            PRM_PartnerSearchController.getAccountDetails(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
            PRM_PartnerSearchController.getCountryList(null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
        try{
            PRM_PartnerSearchController.getDistributors(null,null,null);
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
       
    }
    
    
    
}