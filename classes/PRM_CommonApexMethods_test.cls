@isTest
private class PRM_CommonApexMethods_test {
/*@isTest
    private static void testCreateResponse()
    {
          String origin  = 'PRM_CommonApexMethods';
        String severity  = 'Critical';
        String project  = 'IPA';
        String errorMessage  = 'Too many DML rows';
        boolean sourceCheck;
		 String logEntry='';
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id contactRecordType = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Contact).getRecordTypeId();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        List<PRM_Profile_Questions__c> profQuesList = new List<PRM_Profile_Questions__c>();
        List<PRM_Profile_Answer__c> profAnsList = new List<PRM_Profile_Answer__c>();
        
        Account a = PRM_TestUtility.getAccount();
        a.AccountNumber = '435766';
        a.RecordTypeId = accountRecordTypeIntel;
        a.Name='New Account';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        a.Core_IPA_Partner_Role__c = 'Service Provider';
        accList.add(a);
        
        Account acc = PRM_TestUtility.getAccount();
        acc.AccountNumber = '43576612';
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='New Accounttest';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture1';
        acc.BillingCity='New Delhi1';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='1100371';
        acc.BillingStateCode='KA';
        acc.Core_IPA_Partner_Role__c = 'Guest';
        accList.add(acc);
        
        Account a1 = PRM_TestUtility.getAccount();
        a1.AccountNumber = '435788';
        a1.RecordTypeId = accountRecordTypeIntel;
        a1.Name='Test Account';
        a1.Core_Account_Type__c ='Distributor';
        a1.Industry='Agriculture';
        a1.BillingCity='Bengaluru';
        a1.BillingCountryCode='IND';
        a1.BillingStreet='4th Floor,Koramangala';
        a1.BillingPostalCode='560037';
        a1.BillingStateCode='KA';
        a1.Core_IPA_Partner_Role__c = 'FPGA Designer';
        accList.add(a1);
        
        insert accList;
        
        Contact c = PRM_TestUtility.getContact();
        c.AccountId = a.Id;
        c.Email='john.harrison@maildrop.cc';
        c.Core_Preferred_Language__c = 'ENG';
        c.Core_eRPM_Language_Code__c = 'ENG';
        c.RecordTypeId = contactRecordType;
        c.Core_Do_Not_Contact__c = False;
       // c.Core_IPA_Partner_Role__c = 'Service Provider';
         c.Core_IPA_PartnerRole__c = 'Service Provider';
        conList.add(c);
        
        Contact c1 = PRM_TestUtility.getContact();
        c1.AccountId = a1.Id;
        c1.Email='alan.cumberbatch@maildrop.cc';
        c1.Core_Preferred_Language__c = 'ENG';
        c1.Core_eRPM_Language_Code__c = 'ENG';
        c1.RecordTypeId = contactRecordType;
        c1.Core_Do_Not_Contact__c = False;
      //  c1.Core_IPA_Partner_Role__c = 'FPGA Designer';
        c1.Core_IPA_PartnerRole__c = 'FPGA Designer';
        conList.add(c1);
        
        insert conList;
        
        PRM_Profile_Questions__c profileQues =  new PRM_Profile_Questions__c();
        profileQues.PRM_Question_Cd__c = 'a5y8A000000CvASQA0';
        profQuesList.add(profileQues);
        
        PRM_Profile_Questions__c profileQues1 =  new PRM_Profile_Questions__c();
        profileQues1.PRM_Question_Cd__c = 'CSPx2_ServicePlanTodayOrNext';
        profQuesList.add(profileQues1);
        
        PRM_Profile_Questions__c profileQues11 =  new PRM_Profile_Questions__c();
        profileQues11.PRM_Question_Cd__c = 'a5y8A000000CvATQA0';
        
        profQuesList.add(profileQues11);
        
        
        insert profQuesList;
        System.debug('Profile qus ids :'+[select id,PRM_Question_Cd__c  from PRM_Profile_Questions__c]);
        
        PRM_Profile_Answer__c profileAns = new PRM_Profile_Answer__c();
        profileAns.PRM_Answer_Cd__c = 'PRM_Opt_In_True';
        profileAns.PRM_Profile_Questions_Id__c = profileQues.Id;
        profAnsList.add(profileAns);
        
      
        
        PRM_Profile_Answer__c profileAns11 = new PRM_Profile_Answer__c();
        profileAns11.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_False';
        profileAns11.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns11);
        
        PRM_Profile_Answer__c profileAns12 = new PRM_Profile_Answer__c();
        profileAns12.PRM_Answer_Cd__c = 'PRM_Points_Not_Eligible_True';
        profileAns12.PRM_Profile_Questions_Id__c = profileQues11.Id;
        profAnsList.add(profileAns12);
        
        PRM_Profile_Answer__c profileAns1 = new PRM_Profile_Answer__c();
        profileAns1.PRM_Answer_Cd__c = 'CSPx2_ServicePlanTodayOrNext_DBAAS';
        profileAns1.PRM_Profile_Questions_Id__c = profileQues1.Id;
        profAnsList.add(profileAns1);
        
        insert profAnsList;
        
        
        PRM_Profile_Responses__c response = new PRM_Profile_Responses__c();
        response.PRM_Account_Id__c = a.Id;
        response.PRM_Profile_Questions_Id__c = profileQues1.Id;
        response.PRM_Profile_Answer_Id__c = profileAns1.Id;
               
        insert response;
        
         ChannelProgram cpTest = new ChannelProgram();
        cpTest.Name='Intel Partner Alliance';
        cpTest.PRM_programCode__c='IPA';
        insert cpTest;

        List<PRM_PartnerBenefit__c> pbList = new List<PRM_PartnerBenefit__c>();
        PRM_PartnerBenefit__c pbTest2 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest2.Name = 'Points Redemption';
        pbTest2.PRM_Benefit_Cd__c = 'BFTPTSVIEW';
        pbTest2.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest2.PRM_InActive_Ind__c = false;
        pbTest2.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest2);
        
        PRM_PartnerBenefit__c pbTest3 = new PRM_PartnerBenefit__c(); //Partner Benefit
        pbTest3.Name = 'Points Accrual view';
        pbTest3.PRM_Benefit_Cd__c = 'BFTPTSREDM';
        pbTest3.PRM_Channel_Program_Id__c= cpTest.id;
        pbTest3.PRM_InActive_Ind__c = false;
        pbTest3.PRM_Account_Type_Nm__c='Both';
        pbList.add(pbTest3);

       
         List<PRM_AccountBenefitAssociation__c> abaList = new List<PRM_AccountBenefitAssociation__c>();
        List<PRM_AccountBenefitAssociation__c> abaListnew = new List<PRM_AccountBenefitAssociation__c>();
        PRM_AccountBenefitAssociation__c abassociationTest = new PRM_AccountBenefitAssociation__c();
        abassociationTest.PRM_Account_Id__c = acc.id;
        abassociationTest.PRM_Partner_Benefit_Id__c = pbTest2.id;
        abassociationTest.PRM_Status_Nm__c = 'Active';
        abaList.add(abassociationTest);
        
        PRM_AccountBenefitAssociation__c abassociationTest1 = new PRM_AccountBenefitAssociation__c();
        abassociationTest1.PRM_Account_Id__c = a.id;
        abassociationTest1.PRM_Partner_Benefit_Id__c = pbTest3.id;
        abassociationTest1.PRM_Status_Nm__c = 'Active';
        abaListnew.add(abassociationTest1);
       
        PRM_Profile_Responses__c response12 = new PRM_Profile_Responses__c();
        response12.PRM_Account_Id__c = abassociationTest.PRM_Account_Id__c;
        response12.PRM_Response_Txt__c='true';
        response12.PRM_Profile_Questions_Id__c =  'a5y8A000000CvATQA0';
       // response12.PRM_Profile_Answer_Id__c = profileAns12.Id;
        insert response12;
        list<PRM_Profile_Responses__c> upsertLst=new list<PRM_Profile_Responses__c>();
        PRM_Profile_Responses__c response1 = new PRM_Profile_Responses__c();
        response1.PRM_Account_Id__c =abassociationTest1.PRM_Account_Id__c;
        response1.PRM_Response_Txt__c='true';
        response1.PRM_Profile_Questions_Id__c = 'a5y8A000000CvASQA0';
        upsertLst.add(response1);
       // response12.PRM_Profile_Answer_Id__c = profileAns12.Id;
       PRM_Profile_Responses__c response2 =[select PRM_Account_Id__c,PRM_Response_Txt__c,PRM_Profile_Questions_Id__c from PRM_Profile_Responses__c limit 1];
       response2.PRM_Response_Txt__c='false';
       upsertLst.add(response2);
           try{
         List<Database.upsertResult> results =  Database.upsert(upsertLst, false);
  for(Database.upsertResult result:results ){
  system.assert(result.issuccess());
}  
        }catch(Exception e){
                    System.debug('Test class Exception: '+e.getMessage());
                }
        
       
    
           
                
        map<string,boolean> accIdResponseMap=new map<string,boolean>();
        
        accIdResponseMap.put(response1.PRM_Account_Id__c, true);
        accIdResponseMap.put(response12.PRM_Account_Id__c, false);
        Test.startTest();
        PRM_CommonApexMethods.updateProfileResponse(accIdResponseMap);
       Test.stopTest();
        
    }   
    */
    
}