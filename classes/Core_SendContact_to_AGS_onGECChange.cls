/**************************************************************************************
Apex Class Name:  Core_SendContact_to_AGS_onGECChange
Version     : 1.0 
Created Date: 27 Sep 2021
Function    : To send Contact GEC information to AGS
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda             27/09/2020             Original Version
*************************************************************************************/
public class Core_SendContact_to_AGS_onGECChange {
    
	public static boolean BypassContactSharingMethod=false;

    //dummy method for test class
    public static void dummyMethod() {
        Integer i = 0;
        i++;
    }
 
     /*
     * Method name  : SendUpdatedContactsDatatoLicence
     * Description  : Method to Call PSG License related functions on change of contact name and email
     * Return Type  : void
     * Parameter    : List<Contact> newContactList, Map<Id, Contact> oldMap
     */   
    
        //     public static void SendUpdatedContactsDatatoLicence(List<Contact> newContactList, Map<Id, Contact> oldMap){
		//     List<Contact> ConLst= new List<Contact>();
        //     Set<Id> ContactIdSet =new  Set<Id>();
		//     for(Contact conRec : newContactList){
        //         if(conRec.FirstName != oldMap.get(conRec.Id).FirstName ||conRec.LastName != oldMap.get(conRec.Id).LastName || conRec.Email != oldMap.get(conRec.Id).Email){            
        //           ConLst.add(conRec);              
        //     }   
        //         //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
        //         if(conRec.Core_Account__c!=oldMap.get(conRec.Id).Core_Account__c){
        //             ContactIdSet.add(conRec.id);
        //         }
        // }
            
        //     if(ConLst.size() >0){
        //         ////System.debug('****ConLst'+ConLst);
        //         Sales_UpdateContactDetails.updateContactDetails_LicenseHost(ConLst);
        //         Sales_UpdateContactDetails.updateContactDetails_LicenseAdminDelegate (ConLst);

        //     }
        //     //Added By dnyanada To call PSG Method for Retriggering Sharing Logic
        //     if(ContactIdSet.size()>0){
        //         //Sales_LicenseAdminDelegateUtility.shareLicenseAndHostRecordsForAccountChange(ContactIdSet);
        //         Sales_UpdateSharingonAccountChange.updateSharingOn_LicenseHost(ContactIdSet);
        //     }
        // }


}