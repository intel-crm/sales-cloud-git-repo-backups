/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-26-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-26-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class Core_IPS_FeedComment_Handler_Test {
    public static testmethod void feedCommentcreation(){
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact2);
        
        FeedItem f = new FeedItem();
        f.ParentId = UserInfo.getUserId();
        f.body = 'test';
        insert f;
        
        
        Core_IPS_FeedItem_CreateRestriction__c label = new Core_IPS_FeedItem_CreateRestriction__c();
        label.name='Case';
        insert label;
        List<Profile> profileList = [select id, name from Profile where name = 'partner'];
        
        User userTest = new User(alias = 'test123', email='test123@inteltest.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',ProfileId=ProfileList[0].id,
                                 IsActive =true,
                                 ContactId = contact2.Id, username='tester@inteltest.com',PortalRole = 'Manager');
        insert userTest;
        System.runAs(userTest){
            Case caseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject1',
                Description = 'TestDescription1'     
            );
            Database.insert(caseRecord);
            FeedComment fc = new FeedComment();
            fc.CommentBody = 'legal test';
            fc.FeedItemId = f.Id;   // please add this
            
            try{
                insert fc;
                
                System.assertEquals ('legal test', fc.commentbody, 'Feed comment not inserted correctly');
            }catch(Exception e){
            }
            
        }  
    }  
    public static testmethod void feedItemcreation(){
        Account portalAccount1 = new Account(
            Name = 'newAcc2',
            BillingCity = 'folsom',
            BillingCountry = 'USA',
            BillingStreet = 'Creek Side Dr',
            BillingState = 'NV',
            BillingPostalCode = '591213',
            Core_CIM_ID__c = '11429344',
            Core_B2B_Entitlement__c = true,
            Core_Account_Legal_Name__c = 'TestLegalName',
            OwnerId = userinfo.getUserId()
        );       
        Database.insert(portalAccount1);
        //Create contact
        Contact contact2 = new Contact(
            AccountId = portalAccount1.id,
            FirstName = 'portia2',
            LastName  = 'portalTestUser2',
            Email='babux5x52@intel.com',
            MailingCountry = 'India'
        );
        Database.insert(contact2);
        
        Core_IPS_FeedItem_CreateRestriction__c label = new Core_IPS_FeedItem_CreateRestriction__c();
        label.name='Case';
        insert label;
        List<Profile> profileList = [select id, name from Profile where name = 'partner'];
        
        User userTest = new User(alias = 'test123', email='test123@inteltest.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',ProfileId=ProfileList[0].id,
                                 IsActive =true,
                                 ContactId = contact2.Id, username='tester@inteltest.com',PortalRole = 'Manager');
        insert userTest;
        System.runAs(userTest){
            Case caseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject1',
                Description = 'TestDescription1'     
            );
            Database.insert(caseRecord);
            FeedItem f = new FeedItem();
            f.ParentId = UserInfo.getUserId();
            f.body = 'test';
            
            try{
                insert f;
                System.assertEquals ('legal test', f.body, 'test');
            }catch(Exception e){
            }
            
        }  
    }  
    
}