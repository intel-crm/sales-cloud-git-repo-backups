/*************************************************************************************************************************************************************************
* Class Name  : PSS_IOTGDataMigrationAPI
* Version     : 1.0 
* Created Date: 6/29/2021
* Modification Log :
*
* Developer         Modification Log                    Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Apoorva              M-01    : Original version       6/29/2021                          API class to call Surveyvista import survey result method
																							for data migration
**************************************************************************************************************************************************************************/
/*IPA2.0: US-TWC729-7976*/
//@RestResource(urlMapping='/IOTGMigration')
@isTest 
global class PSS_IOTGDataMigrationAPI {
    // @HttpPost
    // global static resultWrapper doPost(){
    //     //get the request body
    //     RestRequest req = RestContext.request;
    //     Blob reqBody= req.requestBody;
    //     //system.debug(ArdiraSurvey.ArdiraAPI.insertSurveyResponse(reqBody.toString()));
    //     ArdiraSurvey.ArdiraAPIResult result = ArdiraSurvey.ArdiraAPI.insertSurveyResponse(reqBody.toString());
        
    //     resultWrapper wrapper= new resultWrapper();
    //     wrapper.data = String.valueOf(result.data);
    //     wrapper.errorCode = String.valueOf(result.errorCode);
    //     wrapper.errorMessage = String.valueOf(result.errorMessage);
    //     //if errorcode0 then query the partner solution record with iotg contacts field
    //     //separate email ids with semi colon, query contact records where the email id is matching
    //     //call the sharecontact method from hanuma class
    //     //for testing 
    //     //System.debug(wrapper);
    //     if(String.valueOf(result.errorCode)=='0'){
    //         //id to be fetched
    //         //doubt
          
    //         Map<String,Object> jsonMap=(Map<String,Object>) JSON.deserializeUntyped(reqBody.toString());
    //         String PSS_External_Id=String.valueOf(jsonMap.get('PSS_External_Id__c'));
            
    //             List<ArdiraSurvey__Survey_Result__c> contacts=[Select Id,PSS_IOTG_Contacts__c,PSS_IOTG_unmapped_contacts__c from ArdiraSurvey__Survey_Result__c where 
    //                                                        PSS_External_Id__c =:PSS_External_Id order by createddate desc];
    //        String combinedContacts= contacts.get(0).PSS_IOTG_Contacts__c;
    //         List<String> contactsArray=new List<String>();
    //         if(combinedContacts!=null){
    //             String [] allContacts=combinedContacts.split(';');
                
    //             for(String s:allContacts){
    //                 contactsArray.add(s);
    //             }
    //         }
           
           
    //        String unmappedContacts='';
    //         if(contactsArray.size()>0){
    //             List<Contact> contactList=[Select id,email from contact where email in:contactsArray];
    //             List<User> userList = [select id,Contact.email from user where ContactId in: contactList];
    //             for(String con:contactsArray){
    //                 Boolean found=false;
    //                 for(User c:userList){
    //                     if(con.equals(String.valueOf(c.Contact.email))){
    //                         found=true;
    //                         break;
    //                     }
    //                 }
    //                 if(!found){
    //                     unmappedContacts=unmappedContacts+con+'\n';
    //                 }
    //             }
    //             List<Object> shareContact=PSS_ContactsShare.shareSolution(contactList,contacts.get(0).id);
    //         }
          
            
            
    //         //system.debug('contactList'+contactList);
           
    //        // List<ArdiraSurvey__Survey_Result__c> s=[Select Id, from ArdiraSurvey__Survey_Result__c where PSS_External_Id__c =:PSS_External_Id order by createddate desc];
    //         contacts.get(0).PSS_IOTG_unmapped_contacts__c=unmappedContacts;
    //         update contacts.get(0);
    //     }
    //     return wrapper;
    // }
    
    // global class resultWrapper{
    //     global string data;
    //     global string errorCode;
    //     global string errorMessage;
    // }

}