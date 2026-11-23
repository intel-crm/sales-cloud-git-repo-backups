@isTest
public class Pricing_ManageEmailPreference_Mock_Test {
@isTest
static void test_getEmailPreference(){
//using a mock library to create a mock object.
fflib_ApexMocks mocks = new fflib_ApexMocks();

//using the mock object to generate mock selector class of interface of the selector class.

Pricing_PermissionSetAssignment_Selector permissionsetassignmentSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);

Pricing_User_Selector userSelectorMock = (Pricing_User_Selector) mocks.mock(Pricing_User_Selector.class);
Pricing_IQR_Email_Preferences_Selector iqr_email_preferencesSelectorMock = (Pricing_IQR_Email_Preferences_Selector) mocks.mock(Pricing_IQR_Email_Preferences_Selector.class);

Contact con = new Contact();
con.Id = fflib_IDGenerator.generate(Schema.Contact.SObjectType);
con.AccountId = fflib_IDGenerator.generate(Schema.Account.SObjectType);

User usr = new User();
usr.Id = UserInfo.getUserId();
usr.ContactId = con.id;

PermissionSet ps = new PermissionSet();
ps.Name = label.Pricing_Tender_PermissionSets_AllExternal.split(':')[0];

PermissionSetAssignment psa = new PermissionSetAssignment();
psa.PermissionSet = ps;


Pricing_IQR_Email_Preferences__c iqrEmailPreferences2=new Pricing_IQR_Email_Preferences__c
(Pricing_Notification_Name_Nm__c='Quote Team Notification',Pricing_Opt_In_Ind__c=true,Pricing_User__c=UserInfo.getUserId());





//starting the stub where we will tell the mock class that when this selector query is called from
//controller method the record created above should be returned.
mocks.startStubbing();

//next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which
//maps the sobject to the mock class created.

mocks.when(permissionsetassignmentSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);

mocks.when(userSelectorMock.sObjectType()).thenReturn(Schema.User.SObjectType);
mocks.when(iqr_email_preferencesSelectorMock.sObjectType()).thenReturn(Schema.Pricing_IQR_Email_Preferences__c.SObjectType);

//here we are defining the return record which the query should return when the same argument is passed from the
//controller class on test execution.

mocks.when(permissionsetassignmentSelectorMock.selectbyUserId((Id) fflib_Match.anyObject())).thenReturn(new list<PermissionSetAssignment>{psa});
mocks.when(userSelectorMock.selectById()).thenReturn(usr);
mocks.when(iqr_email_preferencesSelectorMock.selectById()).thenReturn(new list<Pricing_IQR_Email_Preferences__c>{iqrEmailPreferences2});
mocks.stopStubbing();
//stoping the stub.

Pricing_IQR_Application.Selector.setMock(permissionsetassignmentSelectorMock);
Pricing_IQR_Application.Selector.setMock(userSelectorMock);
Pricing_IQR_Application.Selector.setMock(iqr_email_preferencesSelectorMock);
Test.startTest();
Pricing_ManageEmailPreference_Mock.getEmailPreference();


Test.stopTest();


// using verify method which works same as the assert
// here it check that the selector method is called how many times.

((Pricing_PermissionSetAssignment_Selector) mocks.verify(permissionsetassignmentSelectorMock,1)).selectbyUserId((Id) fflib_Match.anyObject());
((Pricing_User_Selector) mocks.verify(userSelectorMock,1)).selectById();
((Pricing_IQR_Email_Preferences_Selector) mocks.verify(iqr_email_preferencesSelectorMock,1)).selectById();
//System.assert(returnedQuoteLines.size()==1);
System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
}
@isTest
static void test_getUserPemissionSets(){
//using a mock library to create a mock object.
fflib_ApexMocks mocks = new fflib_ApexMocks();

//using the mock object to generate mock selector class of interface of the selector class.

Pricing_PermissionSetAssignment_Selector permissionsetassignmentSelectorMock = (Pricing_PermissionSetAssignment_Selector) mocks.mock(Pricing_PermissionSetAssignment_Selector.class);
Id userId = fflib_IDGenerator.generate(Schema.User.SObjectType);



//starting the stub where we will tell the mock class that when this selector query is called from
//controller method the record created above should be returned.
mocks.startStubbing();

//next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which
//maps the sobject to the mock class created.

mocks.when(permissionsetassignmentSelectorMock.sObjectType()).thenReturn(Schema.PermissionSetAssignment.SObjectType);

//here we are defining the return record which the query should return when the same argument is passed from the
//controller class on test execution.

mocks.when(permissionsetassignmentSelectorMock.selectByPSName((Id) fflib_Match.anyObject(),(set<String>) fflib_Match.anyObject())).thenReturn(null);
mocks.stopStubbing();
//stoping the stub.

Pricing_IQR_Application.Selector.setMock(permissionsetassignmentSelectorMock);
Test.startTest();
Pricing_ManageEmailPreference_Mock.getUserPemissionSets(userId);


Test.stopTest();


// using verify method which works same as the assert
// here it check that the selector method is called how many times.

((Pricing_PermissionSetAssignment_Selector) mocks.verify(permissionsetassignmentSelectorMock,1)).selectByPSName((Id) fflib_Match.anyObject(),(set<String>) fflib_Match.anyObject());
//System.assert(returnedQuoteLines.size()==1);
System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
}
@isTest
static void test_savePreferences(){
//using a mock library to create a mock object.
fflib_ApexMocks mocks = new fflib_ApexMocks();
fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

//using the mock object to generate mock selector class of interface of the selector class.

Pricing_IQR_Email_Preferences_Selector iqr_email_preferencesSelectorMock = (Pricing_IQR_Email_Preferences_Selector) mocks.mock(Pricing_IQR_Email_Preferences_Selector.class);
Pricing_IQR_Email_Preferences__c pe = new Pricing_IQR_Email_Preferences__c();
pe.Pricing_Opt_In_Ind__c = true;
pe.Pricing_Notification_Name_Nm__c = 'test';
pe.Pricing_Template_API_Name_Nm__c = 'abcd';
pe.Pricing_User__c = UserInfo.getUserId();



//starting the stub where we will tell the mock class that when this selector query is called from
//controller method the record created above should be returned.
mocks.startStubbing();

//next line is mandatory for all selector stubbing since in the fflib_Application there is mockSobject map which
//maps the sobject to the mock class created.

mocks.when(iqr_email_preferencesSelectorMock.sObjectType()).thenReturn(Schema.Pricing_IQR_Email_Preferences__c.SObjectType);

//here we are defining the return record which the query should return when the same argument is passed from the
//controller class on test execution.

mocks.when(iqr_email_preferencesSelectorMock.selectbyIds()).thenReturn(new list<Pricing_IQR_Email_Preferences__c>{pe});
mocks.stopStubbing();
//stoping the stub.

Pricing_IQR_Application.Selector.setMock(iqr_email_preferencesSelectorMock);
Pricing_IQR_Application.unitOfWork.setMock(uowMock);
Test.startTest();
Pricing_ManageEmailPreference_Mock.savePreferences('[{"optInOut" : true,"notificationName" : "Won/Loss Notification"},{"optInOut" : false,"notificationName" : "QuoteTeam Notification"}]');


Test.stopTest();


// using verify method which works same as the assert
// here it check that the selector method is called how many times.

((Pricing_IQR_Email_Preferences_Selector) mocks.verify(iqr_email_preferencesSelectorMock,1)).selectbyIds();
//System.assert(returnedQuoteLines.size()==1);
System.debug('Number of Queries used in this apex code so far: ' + Limits.getQueries());
}




}