/****************************************************************************
Class Name  : Core_ContactEntitlementAudienceUpdate
Version     : 1.0 
Created Date: Sept 18 2018
Function    : Updates the Audience field on Contact object when
              there is a change in Contact Entitlement. 
Modification Log :
* Developer                 Date                    Description
* ----------------------------------------------------------------------------      
* Saif Alam              09/18/2018              Original version 
******************************************************************************/

public without sharing class Core_ContactEntitlementAudienceUpdate {
 public static void updateContactAudience(List<Core_Contact_Entitlement__c> oldList, 
                                         List<Core_Contact_Entitlement__c> newList, 
                                         Map<Id,Core_Contact_Entitlement__c> oldMap, 
                                         Map<Id,Core_Contact_Entitlement__c> newMap)
{
   List<ID> contactIDList = new List<ID>(); //Contact ID list
   List<ID> entIDList = new List<ID>();  // Entitlement Detail ID list 
   Map<ID,Contact> contactMap = new  Map<ID,Contact>();
   Map<ID,Core_Entitlement__c> entMap = new Map<ID,Core_Entitlement__c>();
   Boolean updateFlag;
   list<String> allAudienceValues = new List<String>();//list string to hold audience list field values of contact
               
   //First get the list of IDs for Contact and Entitlement Detail objects 
   // needed to build the 2 maps
  for(Core_Contact_Entitlement__c conEntObj : newList){
   //  check if status and selected field changed and status is complete
    if( ((oldMap.get(conEntObj.ID).Core_Status__c != newMap.get(conEntObj.ID).Core_Status__c  ) ||
         (oldMap.get(conEntObj.ID).Core_Selected__c != newMap.get(conEntObj.ID).Core_Selected__c ))
       && ( conEntObj.Core_Status__c == 'Complete' )  
       && ( conEntObj.Core_Type__c == 'Entitlement')){
              contactIDList.add(conEntObj.Core_Contact_Id__c);
              entIDList.add(conEntObj.Core_Entitlement_Id__c);
           }   
    }//for loop

       // Do not proceed further if there are no entries in 2 list 
if (contactIDList.size() >0 || entIDList.size() > 0){
       
     // get the list of valid picklist field values in field Contact_Access_List__c 
	// multi-select picklist field.
       Schema.DescribeSObjectResult objSchema = Contact.sObjectType.getDescribe();
       Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
       List<Schema.Picklistentry>fld =fieldmap.get('Core_Audience_List__c').getDescribe().getpicklistValues();
       List<String> pickList = new List<String>();
         for(Schema.Picklistentry pl : fld){
              pickList.add(pl.getValue());
            }
     
               //Build the contact and entitlement maps
   List<Contact> contactList = [SELECT ID, Name,Core_Audience_List__c  FROM Contact WHERE ID IN :contactIDList];   
   List<Core_Entitlement__c> entitlementList = [SELECT ID,Name FROM Core_Entitlement__c WHERE ID IN :entIDList];
               // convert the lists to maps
               contactMap.putAll(contactList);
               entMap.putAll(entitlementList);
               
               
     //Loop thru each contact entitlement record. Get the the contact record and 
     //entitlement detail record. If entitlement exists in the picklist value and it is not 
     //already selected then append entitlement to contact.core_audience_list multi-select field
        updateFlag = false;
          for(Core_Contact_Entitlement__c conEntObj : newList){
             if ((conEntObj.Core_Type__c == 'Entitlement') && ( conEntObj.Core_Status__c == 'Complete' ))  { 
             //get contact record from map
              Contact contactVar = contactMap.get(conEntObj.Core_Contact_Id__c);
             //get  entitlement name from map
              Core_Entitlement__c entitlementVar = entMap.get(conEntObj.Core_Entitlement_Id__c);
              String entName = '';
              if(entitlementVar != null){entName = entitlementVar.Name;}
              // get the list of audience values of the contact 
              allAudienceValues.clear();
               if((contactVar != null) && (contactVar.Core_Audience_List__c != null) )
                 {allAudienceValues = contactVar.Core_Audience_List__c.split(';');} 
              // adding value
              if (conEntObj.Core_Selected__c == True){ 
                //if entitlement exists in picklist and it is not already selected
                // append value to contact.audience_list
                  if(picklist.contains(entName)&& 
                    ( (contactVar.Core_Audience_List__c == null)||
                      (!allAudienceValues.contains(entName))  )
                    ){       
                     // modify Contact.Audience_list field
                      if(contactVar.Core_Audience_List__c == null)
                      { contactVar.Core_Audience_List__c =entName;}         
                      else{
                      contactVar.Core_Audience_List__c = contactVar.Core_Audience_List__c+';'+entName;
                      }
                      //put contact back in map
                      contactMap.put(conEntObj.Core_Contact_Id__c,contactVar);
                      updateFlag = true;
                       }
                   }
                   else  //remove picklist value
                   {
                     if(picklist.contains(entName)&&
                        ((contactVar.Core_Audience_List__c == null)||
                        (allAudienceValues.contains(entName)))
                       ){
                           if(contactVar.Core_Audience_List__c != null){
                         // modify Contact.Audience_list field. remove the value                 
                    //-----------------------remove from picklist entName-------------
                              list<String> allValues = new List<String>();
                               allValues = contactVar.Core_Audience_List__c.split(';');
                               contactVar.Core_Audience_List__c= null;
                         for(String value :allValues){
                             if(value != entName){
                                 if(contactVar.Core_Audience_List__c == null) {
                                    contactVar.Core_Audience_List__c = value; 
                                 } else{
                                     contactVar.Core_Audience_List__c = contactVar.Core_Audience_List__c +';'+value;
                                 }
                              }
                         }
                    //-------------------------------------------------------------     
                         //put contact back in map
                        contactMap.put(conEntObj.Core_Contact_Id__c,contactVar); 
                        updateFlag = true;
                           }   //if(contactVar.Core_Audience_List__c != null)
                     }
                   }   
              }
               } // end of for(Core_Contact_Entitlement__c conEntObj : Trigger.new)
    
             //Update Contact Records
    if(updateFlag == true){
               Update contactMap.values();
     }
     
     }// if (contactEntAddList.size() >0 || contactEntRemoveList.size() > 0)      
 }
}