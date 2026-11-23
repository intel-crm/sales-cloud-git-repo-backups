trigger testEmailmethod on PSS_Solution_Contact_Association__c (After update) {

Map<Id,List<Id>> userIdWhatIdMap = new Map<Id,List<Id>>();

List<Id> offeringIds = new List<Id>();

offeringIds.add('a5b8A000000V6Xt');

userIdWhatIdMap.put('0038A00000TWsLBQA1',offeringIds);

system.debug('whatId-->'+offeringIds);
system.debug('userIdWhatIdMap-->'+userIdWhatIdMap);

PMP_Utility.createEmailInstancesWithBulkification('00X3b000001VfXAEA0',userIdWhatIdMap);




Messaging.SingleEmailMessage renderedMailWorkingCopy = Messaging.renderStoredEmailTemplate('00X3b000001VfXAEA0', '0038A00000TWsLBQA1','a5b8A000000V6Xt');
System.debug('renderedMailWorkingCopy --->'+renderedMailWorkingCopy);
// renderStored email template for the remaining emailsToBeSent
Messaging.SingleEmailMessage renderedMailSample = Messaging.renderStoredEmailTemplate('00X3b000001VfXAEA0', null, null);



System.debug('renderedMailSample --->'+renderedMailSample);
string testStr;
Boolean isCheck;

if(testStr == NULL){
isCheck = true;
}

System.debug('isCheck--->'+isCheck);
}