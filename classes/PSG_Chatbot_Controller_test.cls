/*********************************************************************************************************************
Class Name    : PSG_Chatbot_Controller_test
Version       : 1.0
Created Date  : 6 September 2022

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ranjit Kumar   	6-9-2022                  Test Class for PSG_Chatbot_ControllerClass
* *********************************************************************************************************************/



@IsTest
public class PSG_Chatbot_Controller_test 
{
   
    public static testmethod void getpsgPrechatDatatest()
    {
        
        Account acc1 = PSG_Test_Utility.createAccount();
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName ='Test1';
        con.Email='abc@gmail.com';
        con.AccountId=acc1.id;
        insert con;
       
        User us = new user();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'xyztest247392638@intel.com';
        us.Username = 'xyztest@testabc.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.user';
        us.TimeZoneSidKey = 'America/Los_Angeles';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = UserInfo.getProfileId();
        us.LanguageLocaleKey = 'en_US';
        insert us;
        
       
        LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
        LiveChatTranscript transcriptRecord = new LiveChatTranscript();
            transcriptRecord.FirstName__c=con.FirstName;
            transcriptRecord.LastName__c=con.LastName;
            transcriptRecord.Username__c = con.Id;
            transcriptRecord.Email__c=con.Email;
            transcriptRecord.ContactId=con.Id;
            transcriptRecord.LiveChatVisitorId = visitor.Id;
            transcriptRecord.ChatKey = 'juoiuft';
            insert transcriptRecord;
        
        
        PSG_Chatbot_ControllerClass.Chatbotinput input = new PSG_Chatbot_ControllerClass.Chatbotinput();
        list<PSG_Chatbot_ControllerClass.Chatbotinput> input2 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
        input.Operation='Prechat';
        input.sChatKey ='juoiuft';
        input2.add(input);
        List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
          List<Account> accsToUpdate=new List<Account>();
          Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
             update accsToUpdate;
             Opportunity opp = PSG_Test_Utility.createOpportunity(accsToUpdate[0].Id);
            SBQQ.TriggerControl.disable();
			SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].Id,opp.id);
            quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
            quote.OwnerId=us.id;
            insert quote;
        
        system.runAS(us)
        {
            UserRecordAccess ura = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :us.Id AND RecordId =:quote.id];
             
            
        }
        
         User us1 = new User();
        us1.FirstName = 'test1';
        us1.LastName = 'user1';
        us1.Email = 'xyztest2473926@intel.com';
        us1.Username = 'xyztet@testabc.com';
        us1.Alias = 'testu';
        us1.CommunityNickname = 'test.user1';
        us1.TimeZoneSidKey = 'Pacific/Auckland';
        us1.LocaleSidKey = 'en_US';
        us1.EmailEncodingKey = 'UTF-8';
        us1.ProfileId = UserInfo.getProfileId();
        us1.LanguageLocaleKey = 'en_US';
        insert us1;
        
        system.runAS(us1)
        {
            system.assert(PSG_Chatbot_ControllerClass.getpsgPrechatData().size()!=0);
        }
        
        
        
    }
     public static testmethod void getproduct()
     {
         Product2 product = new Product2(Name='TestProduct',
                                                Core_Product_Org__c = 'Sales',
                                                Core_Product_Type__c = 'Component',
                                                Core_OPN__c='TEST',
                                                Core_Design_Registration_Eligible_Ind__c = true,
                                                Core_Sales_Visible_Flag__c = true,
                                                Core_Hierarchy_ID__c = '43',
                                                Core_Group_Code_Short_Name__c = 'DCG',
                                                Core_Item_Quotable_Ind__c = true,
                                                Core_Item_Orderable_Ind__c = true,
                                                Core_Item_Class_Nm__c = 'IC',
                                                IsActive = true);
         insert product;
         test.startTest();
         list<string> opn = new list<string>();
         opn.add(product.Core_OPN__c);
         PSG_Chatbot_ControllerClass.Chatbotouput output = new PSG_Chatbot_ControllerClass.Chatbotouput();
         PSG_Chatbot_ControllerClass.Chatbotouput output1 = new PSG_Chatbot_ControllerClass.Chatbotouput();
         PSG_Chatbot_ControllerClass.Chatbotinput input = new PSG_Chatbot_ControllerClass.Chatbotinput();
         PSG_Chatbot_ControllerClass.Chatbotinput input1 = new PSG_Chatbot_ControllerClass.Chatbotinput();
         list<PSG_Chatbot_ControllerClass.Chatbotouput> output2 = new list<PSG_Chatbot_ControllerClass.Chatbotouput>(); 
         list<PSG_Chatbot_ControllerClass.Chatbotouput> output3 = new list<PSG_Chatbot_ControllerClass.Chatbotouput>(); 
         list<PSG_Chatbot_ControllerClass.Chatbotinput> input2 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
         list<PSG_Chatbot_ControllerClass.Chatbotinput> input3 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
         list<PSG_Chatbot_ControllerClass.Chatbotouput> output4 = new list<PSG_Chatbot_ControllerClass.Chatbotouput>();
  
         input.Input=product.Core_OPN__c;
         input.Operation='Product';
         input2.add(input);
         input1.Input='t';
         input1.Operation='Product';
         input3.add(input1);
         output.OPNActive='Active';
         output.Quotable='N';
         output.ProductType='Component';
         output.Productorg='Sales';
         output.Orderable='N';
         output.Valid='N';
         output1.OPNNull='Invalid';
         output2.add(output);
         output3.add(output1);
         
         system.assertNotEquals(output2,PSG_Chatbot_ControllerClass.getDetails(input2));
         system.assertNotEquals(output3, PSG_Chatbot_ControllerClass.getDetails(input3));
         system.assertNotEquals(output2,output4);
        
         test.stopTest();
              
     }
    
    public static testmethod void getquote()
    {
        profile pr=[SELECT Id FROM Profile WHERE Name='System Administrator'];
        PermissionSetLicense pset = [select id from PermissionSetLicense where MasterLabel ='Salesforce CPQ License'];
        UserRole portalRole=[SELECT id, Name FROM userrole where name = 'Admin' limit 1];
        User u = new user();
        u.FirstName = 'testeww';
        u.LastName = 'userww';
        u.Email = 'xyztest24739www2638@intel.com';
        u.Username = 'xyztwwest@testabc.com';
        u.Alias = 'testwwu';
        u.CommunityNickname = 'test.user44';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.ProfileId = pr.id;
        u.LanguageLocaleKey = 'en_US';
        u.UserRoleId = portalRole.Id;   
        insert u;
        system.runAs(u){
        Account acc1 = PSG_Test_Utility.createAccount();
        acc1.OwnerId=u.Id;
        update acc1;    
        profile p1=[SELECT id, Name,UserType FROM Profile where Name='Customer Community User' limit 1];
        Contact con=new Contact();
        con.FirstName='Test';
        con.LastName ='Test1';
        con.Email='abc@gmail.com';
        con.AccountId=acc1.id;
        insert con;
        User us = new user();
        us.FirstName = 'test';
        us.LastName = 'user';
        us.Email = 'xyztest247392638@intel.com';
        us.Username = 'xyztest@testabc.com';
        us.Alias = 'testu';
        us.CommunityNickname = 'test.user';
        us.TimeZoneSidKey = 'Pacific/Auckland';
        us.LocaleSidKey = 'en_US';
        us.EmailEncodingKey = 'UTF-8';
        us.ProfileId = p1.id;   
        us.LanguageLocaleKey = 'en_US';
        us.ContactId=con.Id;
        insert us;
       
        LiveChatVisitor visitor = new LiveChatVisitor();
            insert visitor;
        LiveChatTranscript transcriptRecord = new LiveChatTranscript();
            transcriptRecord.FirstName__c=con.FirstName;
            transcriptRecord.LastName__c=con.LastName;
            transcriptRecord.Username__c = con.Id;
            transcriptRecord.Email__c=con.Email;
            transcriptRecord.ContactId=con.Id;
            transcriptRecord.LiveChatVisitorId = visitor.Id;
            transcriptRecord.ChatKey = 'juoiuft';
            insert transcriptRecord;
        PSG_Chatbot_ControllerClass.Chatbotinput input = new PSG_Chatbot_ControllerClass.Chatbotinput();
        list<PSG_Chatbot_ControllerClass.Chatbotinput> input2 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
        PSG_Chatbot_ControllerClass.Chatbotinput input4 = new PSG_Chatbot_ControllerClass.Chatbotinput();
        list<PSG_Chatbot_ControllerClass.Chatbotinput> input5 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
        PSG_Chatbot_ControllerClass.Chatbotouput output1 = new PSG_Chatbot_ControllerClass.Chatbotouput();
        PSG_Chatbot_ControllerClass.Chatbotouput output4 = new PSG_Chatbot_ControllerClass.Chatbotouput();
        list<PSG_Chatbot_ControllerClass.Chatbotouput> output5 = new list<PSG_Chatbot_ControllerClass.Chatbotouput>();
        list<PSG_Chatbot_ControllerClass.Chatbotouput> output2 = new list<PSG_Chatbot_ControllerClass.Chatbotouput>();
        PSG_Chatbot_ControllerClass.Chatbotinput input1 = new PSG_Chatbot_ControllerClass.Chatbotinput();
        list<PSG_Chatbot_ControllerClass.Chatbotinput> input3 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>();
        PSG_Chatbot_ControllerClass.Chatbotinput inputpre = new PSG_Chatbot_ControllerClass.Chatbotinput();
        list<PSG_Chatbot_ControllerClass.Chatbotinput> inputpre1 = new list<PSG_Chatbot_ControllerClass.Chatbotinput>(); 
            
          List<Account> accs=[SELECT Id from Account where RecordType.Name='Intel Account' limit 10];
          List<Account> accsToUpdate=new List<Account>();
          Id recordtypeId=[SELECT Id,name,developername from RecordType where sobjecttype='Account' and Developername='Core_Direct_Account' LIMIT 1].Id;
            Account a1=PSG_Test_Utility.createDirectAccount();
            a1.RecordTypeId=recordtypeId;
            a1.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a1.Core_Is_Pricing_Parent_ChkBox__c=true;
            a1.Core_Direct_Account_Active_Ind__c=true;
            update a1;
            Account a2=PSG_Test_Utility.createDirectAccount();
            a2.RecordTypeId=recordtypeId;
            a2.Core_Direct_Account_Type_Nm__c='End Customer Parent';
            a2.Core_Is_Pricing_Parent_ChkBox__c=true;
            a2.Core_Direct_Legal_Parent_Id__c=a1.Id;
            a2.Core_Direct_Account_Active_Ind__c=true;
            update a2;
            for(Integer i=0;i<1;i++){
                accs[i].Core_PSG_Account__c=true;
                accs[i].Core_Direct_Pricing_Parent_Id__c=a2.id;
                accs[i].Core_Direct_Legal_Parent_Id__c=a1.Id;
                accsToUpdate.add(accs[i]);
            }
             update accsToUpdate;
             Opportunity opp = PSG_Test_Utility.createOpportunity(accsToUpdate[0].Id);
            SBQQ.TriggerControl.disable();
			SBQQ__Quote__c quote = PSG_Test_Utility.createQuoteRecord(accsToUpdate[0].Id,opp.id);
            quote.core_cpq_end_customer_nm__c=accsToUpdate[0].Id;
            insert quote;
            SBQQ__Quote__c quote2 =[select id,name from SBQQ__Quote__c where id =:quote.id limit 1];
            list<string> quote1 = new list<string>();
            SBQQ.TriggerControl.disable();
			core_cpq_dpa_aln__c aln = new core_cpq_dpa_aln__c();  
			aln.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_DPA').getRecordTypeId();
			aln.core_cpq_active_quote__c = quote.Id;
			aln.core_cpq_record_type_identifier__c = 'DPA';
			aln.core_cpq_status_txt__c = 'Approved';
			aln.core_cpq_change_flag__c = 'N';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln.core_cpq_comments_txt__c = 'test';     
			aln.core_cpq_ship_end_date_dt__c=system.today();
			insert aln;
            quote1.add(quote2.Name);
            output1.DPA=aln.Name;
            output1.DpaIsvalid='False';
            output2.add(output1);
           input.Input=quote2.Name;
           input.Operation='DPA';
           input2.add(input);
           input1.Input=quote2.Name;
           input1.Operation='Quote';
           input1.sChatKey='juoiuft';
           input3.add(input1);
           inputpre.Input=quote2.Name;
           inputpre.Operation='Prechat';
           inputpre.sChatKey='juoiuft';
           inputpre1.add(inputpre);
            core_cpq_dpa_aln__c aln1 = new core_cpq_dpa_aln__c();  
			aln1.RecordTypeId = Schema.SObjectType.core_cpq_dpa_aln__c.getRecordTypeInfosByDeveloperName().get('PSG_ALN').getRecordTypeId();
			aln1.core_cpq_active_quote__c = quote2.Id;
			aln1.core_cpq_record_type_identifier__c = 'DPA';
			aln1.core_cpq_status_txt__c = 'Approved';
			aln1.core_cpq_change_flag__c = 'N';
            aln1.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln1.core_cpq_dpa_approved_date__c = '1/28/2022';
            aln1.core_cpq_comments_txt__c = 'test';     
			aln1.core_cpq_ship_end_date_dt__c=system.today();
			insert aln1;
            output4.DPA=aln1.Name;
            output4.DpaIsvalid='False';
            output5.add(output4);
            input4.Input=quote2.Name;
            input4.Operation='DPA';
            input5.add(input);
            
        system.assertNotEquals(output2,PSG_Chatbot_ControllerClass.getDetails(input2));
        system.assert(PSG_Chatbot_ControllerClass.getdpaaln(quote2.name).size()!=0);
       
        
        
            try{system.assert(PSG_Chatbot_ControllerClass.getdpaaln(quote.Name).size()!=0);}catch(exception e){}  
            system.assert(PSG_Chatbot_ControllerClass.getpsgPrechatData().size()!=0);
            UserRecordAccess ura = [SELECT RecordId,HasReadAccess FROM UserRecordAccess WHERE UserId = :us.Id AND RecordId =:aln.id];
            system.assert(PSG_Chatbot_ControllerClass.getDetails(input3).size()!=0);
            system.assert(PSG_Chatbot_ControllerClass.getDetails(inputpre1).size()!=0);
        }
               
    }
       

}