@isTest
/**************************************************************************************
    Apex Class Name : PMP_OfferingTriggerHelper
    Version     : 1.0 
    Created Date: 26th Jan, 2019
    Description : Trigger handler for PMP_Offering_Resource_Trigger
    * Modification Log :
    * Developer                 Date                     Description
    * ----------------------------------------------------------------------------
    * Shahrukh                  26/03/2019               Original Version
    Yashasvi Aggarwal         30/09/2021
    *************************************************************************************/

    public without sharing class PMP_OfferingTriggerHelper{
    // /**
    // * @description : Method to send the list of records to update the offerings
    // * @param List,Map
    // * @return void
    // **/
    // public static void cloneOffering(List<PMP_Partner_Offering__c> offList,map<Id,PMP_Partner_Offering__c> oldMap){
    //     try{
    //             //Declarations
    //             List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
    //             Map<Id,Boolean> featuredOfferingMap = new Map<Id,Boolean>();
    //             Set<Id>  retiredOfferingSet = new Set<Id>();
    //             List<PMP_Partner_Offering__c> removePublicofferingList = new List<PMP_Partner_Offering__c>();
                
    //             /* 
    //         Offering to be published only if it is 
    //             Approved && StartDate is <= Today && Pre Release Count is Zero
    //         */
    //                 for(PMP_Partner_Offering__c off:offList){
    //             if((oldMap.get(off.Id).PMP_Partner_Offering_Lifecycle_Status_Nm__c != PMP_StaticConstants_MasterData.Approved
    //                 && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved
    //                 && off.PMP_Partner_Offering_Start_Dt__c <= system.Today()
    //                 && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero 
    //                 && off.PMP_Pre_Release_Check_Nm__c != PMP_StaticConstants_MasterData.No) // Yes or Blank
    //                 ||     //Adding below conditions for offerings with Pre-release flag set as No
    //                 (off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.No
    //                 && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero
    //                 && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved
    //                 && off.PMP_Partner_Offering_Start_Dt__c <= system.Today()
    //                 && off.PMP_Is_Notified_Ind__c == false))
                    
    //             {
    //                 offeringList.add(off);      // Adding all the offerings which satisfies above criteria to a list
                    
    //             }
    //             if(off.PMP_Featured_Offering_Ind__c!=oldMap.get(off.Id).PMP_Featured_Offering_Ind__c){
    //                 featuredOfferingMap.put(off.Id,off.PMP_Featured_Offering_Ind__c);
    //             }
                
    //             if(off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_Utility.getValue('RetiredStatus'))
    //             {
    //                 retiredOfferingSet.add(off.Id);
    //             }

    //             //TWC1824-1066 --Added by Vardaan - start
                
    //             if(((off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.Yes
    //                 || off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.No)
    //                 && off.PMP_Pre_Release_Item_Count_Num__c > PMP_StaticConstants_MasterData.Zero
    //                 && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved
    //                 && off.PMP_Partner_Offering_Start_Dt__c <= system.Today()
    //                 && (off.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content || 
    //                     off.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Partner_Content)) 
    //                 || off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Rejected)  //TWC1824-3345-- Added by Vardaan to remove Published Offerings whose Working Copies are Rejected
    //                 {
    //                     removePublicofferingList.add(off);      // Adding all the offerings which satisfies above criteria to a list
    //                 }
    //             //TWC1824-1066 --Added by Vardaan - end
    //         }
    //             //system.debug('offeringList before--------'+offeringList);
            
    //         if(!retiredOfferingSet.isEmpty())
    //         {
    //             updateretiredofferings(retiredOfferingSet);
    //         }
    //             if(!offeringList.isEmpty()){
    //                 // US982076-Commented batch class method and calling it in synchronous method
    //                 //String cronId = System.scheduleBatch(new PMP_CreateUpdatePublishOfferings(offeringList), 'MonitorThumbnailImages'+ System.now().getTime(),1);
    //                     updateOfferings(offeringList);  // Passing the offering list to publish the offerings
    //             }
    //             // system.debug('###Batch got scheduled:->');
    //             // system.debug('###featuredOfferingMap:->'+featuredOfferingMap);
    //             if(!featuredOfferingMap.isEmpty()){
    //                 syncFeaturedOffering(featuredOfferingMap);
    //             }
            
    //         if(!removePublicofferingList.isEmpty()){
    //             updateRemovePublicofferingList(removePublicofferingList);
    //         }    

                
            
    //         }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //         Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    //         String[] sendingTo = new String[]{};
    //         sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
    //         semail.setToAddresses(sendingTo);
    //         semail.setSubject('OfferingException');
    //         semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    //     }
    // }

    // /**
    // * @description : Method to update offering record end date to past
    // * @param List
    // * @return void
    // **/
    // public static void updateretiredofferings(Set<Id> offeringSet)
    // {
    //     try{
    //         //Declarations
    //         List<PMP_Partner_Offering__c> publishedOfferingsList = new List<PMP_Partner_Offering__c>();
    //         List<ArdiraSurvey__Survey_Result__c> surveyList= new List<ArdiraSurvey__Survey_Result__c>();
            
            
    //         if(!offeringSet.isEmpty())
    //         {
    //             if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
                    
    //                 for(PMP_Partner_Offering__c offer:[Select Id,PMP_Working_Copy_Id__c,LastModifiedById, PMP_Pre_Release_Item_Count_Num__c,
    //                                                 PMP_Partner_Offering_Visibility_Nm__c,PMP_Pre_Release_Check_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,
    //                                                 PMP_Is_Published_Ind__c,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_End_Dt__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c IN : offeringSet])
    //                 {
    //                     offer.PMP_Partner_Offering_End_Dt__c = System.today()-1;
    //                     offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c = 'Retired';
    //                     publishedOfferingsList.add(offer);
    //                 }
    //             }
                    
    //             if(Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isAccessible()){
                    
    //                     for(ArdiraSurvey__Survey_Result__c sur:[Select Id,PSS_Partner_Offering__c,PSS_Partner_Solution_Lifecycle_Status_Nm__c from ArdiraSurvey__Survey_Result__c where PSS_Partner_Offering__c IN: offeringSet]){
    //                     sur.PSS_Partner_Solution_Lifecycle_Status_Nm__c = 'Retired';
    //                     surveyList.add(sur);    
    //                     }                          
    //             }
                
    //         }
    //         //system.debug('###surveyList'+surveyList);
    //         if(!publishedOfferingsList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
    //             update publishedOfferingsList;  
    //         }
            
    //         if(!surveyList.isEmpty() && Schema.sObjectType.ArdiraSurvey__Survey_Result__c.isUpdateable()){
    //         // system.debug('###enter4'+surveyList);
    //             update surveyList;  
    //         }
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //         Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    //         String[] sendingTo = new String[]{};
    //             sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
    //         semail.setToAddresses(sendingTo);
    //         semail.setSubject('OfferingException');
    //         semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});   
    //     }
    // }

    // /**
    // * @description : Method to update offering records
    // * @param List
    // * @return void
    // **/
    // public static void updateOfferings(List<PMP_Partner_Offering__c> offList){
        
    //     // System.debug('--- Inside update offerings method -----');
    //     try{
    //         //Declarations
    //         Set<Id> offIds = new Set<Id>();
    //         //Set<Id> currentOffIds = new Set<Id>();
    //         Set<Id> offeringUpdateSet = new Set<Id>();
    //         Map<Id,PMP_Partner_Offering__c> offeringMap = new Map<Id,PMP_Partner_Offering__c>();
    //         //List<PMP_Partner_Offering__c> createPublishedOfferingList = new List<PMP_Partner_Offering__c>();
    //         List<PMP_Partner_Offering__c> updatePublishedOfferingList = new List<PMP_Partner_Offering__c>();
    //         //List<PMP_Partner_Offering__c> newOfferingList = new List<PMP_Partner_Offering__c>();
    //         Map<Id,Id> existingOfferingMap = new map<Id,Id>();
    //         Map<Id,Id> offeringPublishedMap = new map<Id,Id>();
    //         Set<Id> existingOffIds = new Set<Id>();
    //         Set<Id> newOfferingIds = new Set<Id>();
    //         List<PMP_Partner_Offering__c> existingOfferingList = new List<PMP_Partner_Offering__c>();
            
    //         List<PMP_Partner_Offering_Category__c> categoriesToBeInsertedList = new List<PMP_Partner_Offering_Category__c>();
    //         List<PMP_Partner_Offering_Specification__c> specsToBeInsertedList = new List<PMP_Partner_Offering_Specification__c>();
    //         List<PMP_Partner_Offering_Translation__c> translationsToBeInsertedList = new List<PMP_Partner_Offering_Translation__c>();
    //         List<PMP_Partner_Offering_Resource__c> resToBeInsertedList = new List<PMP_Partner_Offering_Resource__c>();
            
    //         List<PMP_Partner_Offering_Category__c> catDeletionList =  new List<PMP_Partner_Offering_Category__c>();
    //         List<PMP_Partner_Offering_Specification__c> SpecDeletionList = new List<PMP_Partner_Offering_Specification__c>();
    //         List<PMP_Partner_Offering_Resource__c> ResDeletionList = new List<PMP_Partner_Offering_Resource__c>();
    //         List<PMP_Partner_Offering_Translation__c> transDeletionList = new List<PMP_Partner_Offering_Translation__c>();
    //         //Offering to be used to update post publishing
    //         List<PMP_Partner_Offering__c> workingCopyOfferings = new List<PMP_Partner_Offering__c>();
            
    //             //Offering to be removed after re publishing it on events
    //         List<PMP_Partner_Offering__c> eventOfferingApprovedOfferings = new List<PMP_Partner_Offering__c>();
                        
    //         if(!offList.isEmpty()){
    //             for(PMP_Partner_Offering__c off: offList){
    //                 offIds.add(off.Id);
    //                 offeringMap.put(off.Id,off);
    //                 existingOfferingMap.put(off.Id,off.Id); 
    //                 offeringUpdateSet.add(off.Id);
    //                 // system.debug('offeringUpdateSet'+ offeringUpdateSet);
    //                 /* if(off.PMP_Is_Published_Ind__c==false){
    //                     createPublishedOfferingList.add(off);  //If Published indicator is false we are creating a new offering by adding it in create list
                        
    //                 }else{
                        
    //                     offeringUpdateSet.add(off.Id);
    //                     updatePublishedOfferingList.add(off); //Else we are updating the previously published offering
    //                 }*/
    //                 updatePublishedOfferingList.add(off); //update published offering
    //                 workingCopyOfferings.add(off); // working copy offerings to be used for post update after publishing    
                
    //                 eventOfferingApprovedOfferings.add(off);
    //                 // system.debug('workingCopyOfferings' + workingCopyOfferings);
    //                 // System.debug('updatePublishedOfferingList' + updatePublishedOfferingList);
    //                 //US982076-Image Resizing call out to create resized Thumbnail Image resource record
    //                 // if(System.isBatch()){
    //                 //     PMP_CreateOfferingTab5Service.generateThumbnailImagesSynchronously(off.Id);  //synchronous method if execution is a batch context                  
    //                 // }else{
    //                 //     PMP_CreateOfferingTab5Service.generateThumbnailImages(off.Id); //future method if execution is not a batch context
    //                 // }
    //             }
    //         }
    //         /*
    //             if(!createPublishedOfferingList.isEmpty()){
    //             for(PMP_Partner_Offering__c off:offList){
    //                 PMP_Partner_Offering__c clonedOff = new PMP_Partner_Offering__c();
    //                 clonedOff = off.clone(false,true,true,true);    // Creating clone of approved offering with new salseforce id and copying all the other fields
    //                 clonedOff.PMP_Working_Copy_Id__c = off.Id;        // Stamping Id of the offering which invoked the process on the newly created published copy
                    
    //                 //if the visibility is intel only content then change to public
    //                 if(clonedOff.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {                    
    //                     clonedOff.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
    //                 }
    //                 clonedOff.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_MasterData.Published;//changing offering status to published
    //                 clonedOff.PMP_Pre_Release_Check_Nm__c='';//clearing Pre-release check and Is notified flags for published copy during first publish
    //                 clonedOff.PMP_Is_Notified_Ind__c=false;
    //                 system.debug('****lastMod*******'+off.LastModifiedById);
    //                 system.debug('****created*******'+off.createdById);
    //                 clonedOff.CreatedById = off.LastModifiedById;
    //                 clonedOff.OwnerId = off.LastModifiedById;
    //                 clonedOff.PMP_Offering_Status_Update_Dt__c = system.now();
    //                 newOfferingList.add(clonedOff);
    //                 currentOffIds.add(off.Id);
                    
    //             }
                
    //             if(!newOfferingList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isCreateable()){
    //                 insert newOfferingList;
                    
    //                 List<PMP_Partner_Offering_Category__c> catList = createCategories(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Categories from Approved record to Published Record
                    
    //                 List<PMP_Partner_Offering_Specification__c> specList = createSpecifications(newOfferingList,currentOffIds,existingOfferingMap); //To Clone specifications from Approved record to Published Record
                    
    //                 List<PMP_Partner_Offering_Translation__c> translationList = createTranslations(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Translations from Approved record to Published Record
                    
    //                 List<PMP_Partner_Offering_Resource__c> resList = createResources(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Resources from Approved record to Published Record
                    
                    
    //                 if(!catList.isEmpty()){
    //                     categoriesToBeInsertedList.addAll(catList);  //Adding Categories that needs to be inserted
    //                 }
                    
    //                 if(!specList.isEmpty()){
    //                     specsToBeInsertedList.addAll(specList); //Adding Specifications that needs to be inserted 
    //                 }
                    
    //                 if(!translationList.isEmpty()){
    //                     translationsToBeInsertedList.addAll(translationList); //Adding Translations that needs to be inserted
    //                 }
                    
    //                 if(!resList.isEmpty()){
    //                     system.debug('resList'+resList); 
    //                     resToBeInsertedList.addAll(resList);  //Adding Resources that needs to be inserted 
    //                 }
    //             }         
    //         }
    //         */         
    //         if(!updatePublishedOfferingList.isEmpty()){
    //             List<PMP_Partner_Offering__c> publishedOfferingsList;
    //             if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
    //             publishedOfferingsList = [Select Id,PMP_Working_Copy_Id__c,LastModifiedById, PMP_Is_Not_Available_On_MP_Ind__c , PMP_Pre_Release_Item_Count_Num__c,
    //                                                 PMP_Partner_Offering_Visibility_Nm__c,PMP_Pre_Release_Check_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,
    //                                                 PMP_Is_Published_Ind__c,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_LifecycleStatus_Txt__c from PMP_Partner_Offering__c 
    //                                                 where PMP_Working_Copy_Id__c IN : offeringUpdateSet];
    //             }
    //             if(!publishedOfferingsList.isEmpty()){
    //                 for(PMP_Partner_Offering__c off:publishedOfferingsList){
    //                     offeringPublishedMap.put(off.PMP_Working_Copy_Id__c,off.PMP_Working_Copy_Id__c);
    //                     offeringPublishedMap.put(off.PMP_Working_Copy_Id__c,off.PMP_Working_Copy_Id__c);
    //                     PMP_Partner_Offering__c offer = offeringMap.get(off.PMP_Working_Copy_Id__c).clone(false,false,true,true);
    //                     offer.PMP_Working_Copy_Id__c =  offeringMap.get(off.PMP_Working_Copy_Id__c).Id;   // Stamping Id of the offering which invoked the process on the newly created published copy
    //                         //if the visibility is intel only content then change to public
    //                     if(offer.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {                    
    //                         offer.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
    //                     }
    //                     offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_MasterData.Published; //changing offering status to published
    //                     offer.CreatedById = offeringMap.get(off.PMP_Working_Copy_Id__c).LastModifiedById;
    //                     offer.PMP_Offering_Status_Update_Dt__c = system.now();      //changing the status update date to today
    //                     offer.PMP_Partner_Offering_Sync_Status_Nm__c = '';             // Clearing the PIM status 
    //                     offer.OwnerId = off.LastModifiedById;
    //                     offer.PMP_Is_Published_Ind__c = false;
    //                     offer.PMP_Pre_Release_Check_Nm__c='';//clearing Pre-release check and Is notified flags for published copy during republish
    //                     offer.PMP_Is_Notified_Ind__c=false;
    //                     offer.PMP_Is_Not_Available_On_MP_Ind__c=false; //make not available on MP Indicator false to publish it
    //                     offer.PMP_Partner_Offering_LifecycleStatus_Txt__c= offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c;  //transfer the updated value to show as second column in look filter on events
    //                     offer.Id = off.Id; 
    //                     newOfferingIds.add(off.Id);
    //                     existingOffIds.add(off.PMP_Working_Copy_Id__c);
    //                     existingOfferingList.add(offer);
    //                 }
    //             }
                
    //             if(!existingOfferingList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
    //                 update existingOfferingList;
    //                 //Deleting all the previously existing child records
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
    //                     catDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN : newOfferingIds];
    //                 }   
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
    //                     SpecDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c IN :newOfferingIds];
    //                 } 
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
    //                     ResDeletionList = [select id,PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c IN :newOfferingIds];
    //                 }
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
    //                     transDeletionList = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN :newOfferingIds];      
    //                 }   
    //                 //End Of Deletion
                    
    //                 List<PMP_Partner_Offering_Category__c> catUpdateList = createCategories(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Categories from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Specification__c> specUpdateList = createSpecifications(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Specifications from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Translation__c> translationUpdateList = createTranslations(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Translations from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Resource__c> resUpdateList = createResourcesDocumentLink(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Resources from Approved record to Published Record
                    
                    
    //                 //List of records that needs to be deleted from published version in order to sync with working copy
    //                 if(!catUpdateList.isEmpty()){
    //                     categoriesToBeInsertedList.addAll(catUpdateList);  
    //                 }
                    
    //                 if(!specUpdateList.isEmpty()){
    //                     specsToBeInsertedList.addAll(specUpdateList);
    //                 }
                    
    //                 if(!resUpdateList.isEmpty()){
    //                     resToBeInsertedList.addAll(resUpdateList);
    //                 }
                    
    //                 if(!translationUpdateList.isEmpty()){
    //                     translationsToBeInsertedList.addAll(translationUpdateList);
    //                 }
                    
    //             }
                
    //         }
    //         //Use this method to replace approved working copy with published copy after re publishing the offering on events
    //         if(!eventOfferingApprovedOfferings.isEmpty())
    //         {
    //             replaceEventApprovedOfferings(offeringUpdateSet);
    //         }     
    //         // System.debug('workingCopyOfferings' + workingCopyOfferings);
    //         //Use this method to update working copy data after publishing the offering
    //         if(!workingCopyOfferings.isEmpty()){                
    //             updateWorkingCopyPostPublished(workingCopyOfferings);
    //         }
            
    //         //Deleting the old records from published Version
    //         if(!catDeletionList.isEmpty()){
    //             delete catDeletionList;
    //         }

    //         if(!SpecDeletionList.isEmpty()){
    //             delete SpecDeletionList;
    //         }

    //         if(!transDeletionList.isEmpty()){
    //             delete transDeletionList;
    //         }

    //         if(!ResDeletionList.isEmpty()){
    //             delete ResDeletionList;
    //         }
    //         //Inserting all the respective records
    //         if(!categoriesToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isCreateable()){
    //             insert categoriesToBeInsertedList;
    //         }
            
    //         if(!specsToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isCreateable()){
    //             insert specsToBeInsertedList;
    //         }
            
    //         if(!translationsToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Translation__c.isCreateable()){
    //             insert translationsToBeInsertedList;
    //         }
            
    //         if(!resToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
    //             insert resToBeInsertedList;
    //         }
        
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //         Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    //         String[] sendingTo = new String[]{};
    //         sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
    //         semail.setToAddresses(sendingTo);
    //         semail.setSubject('OfferingException');
    //         semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    //     }
        
        
    // } 
    // /**
    // * @description Method to create Categories
    // * @param List,set,map
    // * @return List<PMP_Partner_Offering_Category__c>
    // **/

    // public static List<PMP_Partner_Offering_Category__c> createCategories(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
    //     List<PMP_Partner_Offering_Category__c> clonedOffCatList = new List<PMP_Partner_Offering_Category__c>();
    //     try{
    //         //Querying all the child records
    //         DescribeSObjectResult offCatFields = PMP_Partner_Offering_Category__c.getSObjectType().getDescribe();   
    //         List<String> catFieldNames = new List<String>( offCatFields.fields.getMap().keySet() );    
    //         String offCatQuery =    ' SELECT ' +     String.escapeSingleQuotes(String.join( catFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offCatFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds'; 
    //         List<PMP_Partner_Offering_Category__c> tempCatList = Database.query(offCatQuery);
            
    //         for(PMP_Partner_Offering_Category__c offCat:tempCatList){
    //             PMP_Partner_Offering_Category__c clonedOffCat = new PMP_Partner_Offering_Category__c();
    //             clonedOffCat = offCat.clone(false,false,true,true);
    //             for(PMP_Partner_Offering__c tempOff:offList){                                
    //                 if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offCat.PMP_Offering_Id__c)){ //Assigning offering Id as the newly created published offering
    //                     clonedOffCat.PMP_Offering_Id__c = tempOff.Id;
    //                 }  
    //             }
    //             //clonedOffCat.CreatedById = offCat.CreatedById;
    //             clonedOffCatList.add(clonedOffCat);
    //         }
            
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    //     return clonedOffCatList;  // Returning all the categories that needs to be inserted.
    // }

    // /**
    // * @description Method to create Specifications
    // * @param List,set,map
    // * @return List<PMP_Partner_Offering_Specification__c>
    // **/

    // public static List<PMP_Partner_Offering_Specification__c> createSpecifications(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
    //     List<PMP_Partner_Offering_Specification__c> clonedOffSpecList = new List<PMP_Partner_Offering_Specification__c>();
    //     try{
    //         //Querying all the child records
    //         DescribeSObjectResult offSpecFields = PMP_Partner_Offering_Specification__c.getSObjectType().getDescribe();   
    //         List<String> specFieldNames = new List<String>( offSpecFields.fields.getMap().keySet() );    
    //         String offSpecQuery =    ' SELECT ' +        String.escapeSingleQuotes(String.join( specFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offSpecFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds';
    //         List<PMP_Partner_Offering_Specification__c> tempSpecList = Database.query(offSpecQuery);
                        
    //         for(PMP_Partner_Offering_Specification__c offSpec:tempSpecList){
    //             PMP_Partner_Offering_Specification__c clonedOffSpec = new PMP_Partner_Offering_Specification__c();
    //             clonedOffSpec = offSpec.clone(false,false,true,true);
                
    //             for(PMP_Partner_Offering__c tempOff:offList){
    //                 if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offSpec.PMP_Offering_Id__c)) //Assigning offering Id as the newly created published offering
    //                     clonedOffSpec.PMP_Offering_Id__c = tempOff.Id;
    //             }
    //             //clonedOffSpec.CreatedById = offSpec.CreatedById;
    //             clonedOffSpecList.add(clonedOffSpec);
    //         }
            
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    //     return clonedOffSpecList; // Returning all the Specifications that needs to be inserted.
    // }

    // /**
    // * @description Method to create Translations
    // * @param List,set,map
    // * @return List<PMP_Partner_Offering_Translation__c>
    // **/

    // public static List<PMP_Partner_Offering_Translation__c> createTranslations(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
    //     List<PMP_Partner_Offering_Translation__c> clonedOffTransList = new List<PMP_Partner_Offering_Translation__c>();
    //     try{
    //         //Querying all the child records
    //         DescribeSObjectResult offTransFields = PMP_Partner_Offering_Translation__c.getSObjectType().getDescribe();   
    //         List<String> transFieldNames = new List<String>( offTransFields.fields.getMap().keySet() );    
    //         String offTransQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( transFieldNames, ',' )) +' FROM ' + String.escapeSingleQuotes(offTransFields.getName()) + ' WHERE ' +         ' PMP_Partner_Offering_Id__c  IN : offIds';
    //         List<PMP_Partner_Offering_Translation__c> tempTransList = Database.query(offTransQuery);
            
    //         for(PMP_Partner_Offering_Translation__c offTrans:tempTransList){
    //             PMP_Partner_Offering_Translation__c clonedOffTrans = new PMP_Partner_Offering_Translation__c();
    //             clonedOffTrans = offTrans.clone(false,false,true,true);
    //             for(PMP_Partner_Offering__c tempOff:offList){                                
    //                 if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offTrans.PMP_Partner_Offering_Id__c))
    //                     clonedOffTrans.PMP_Partner_Offering_Id__c = tempOff.Id;  //Assigning offering Id as the newly created published offering
    //             }
    //             //clonedOffTrans.CreatedById = offTrans.CreatedById;
    //             clonedOffTransList.add(clonedOffTrans);
    //         }
            
            
            
            
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    //     return clonedOffTransList; // Returning all the Translations that needs to be inserted.
    // }

    // /**
    // * @description Method to create Resources
    // * @param List,set,map
    // * @return List<PMP_Partner_Offering_Resource__c>
    // **/

    // public static List<PMP_Partner_Offering_Resource__c> createResources(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
    //     List<PMP_Partner_Offering_Resource__c> clonedOffResList = new List<PMP_Partner_Offering_Resource__c>();
    //     try{
    //         //Querying all the child records
    //         DescribeSObjectResult offResFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();   
    //         List<String> resFieldNames = new List<String>( offResFields.fields.getMap().keySet() );    
    //         String offResQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( resFieldNames, ',' )) +    ' FROM ' +         String.escapeSingleQuotes(offResFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds';
    //         List<PMP_Partner_Offering_Resource__c> tempResList = Database.query(offResQuery);
            
    //         Set<Id> resSet = new Set<Id>();
    //         Set<Id> newContentVersionSet = new Set<Id>();
    //         //Map<string,Id> contentDocMap = new Map<string,Id>();
    //         List<ContentVersion> newContentList = new List<ContentVersion>();
    //         Map<Id,Id> newContentDocMap = new Map<Id,Id>();
    //         Map<Id,Id> contentDocOffResourceMap = New Map<Id,Id>();
    //         Map<Id,Id> OffResourceContentDocMap = New map<Id,Id>();
    //         //system.debug('PPP:size'+tempResList.size());
    //         for(PMP_Partner_Offering_Resource__c offResc:tempResList){  
    //             // system.debug('PPP:Res'+offResc);

    //             //if(offResc.PMP_Resource_Type_Nm__c==PMP_StaticConstants_Offering.IMAGE || offResc.PMP_Resource_Type_Nm__c=='Thumbnail Image'){
    //             //to accomodate new additonal resource changes as additional resource records will also have files
    //             if(string.isNotBlank(offResc.PMP_Partner_Offering_Image__c)){
    //                 resSet.add(offResc.PMP_Partner_Offering_Image__c);   //Adding all the ids of resources where type is Image
    //                 contentDocOffResourceMap.put((id) offResc.PMP_Partner_Offering_Image__c, offResc.Id);
    //                 OffResourceContentDocMap.put(offResc.Id, (id) offResc.PMP_Partner_Offering_Image__c);
    //             }
    //         }
            
            
    //         //Querying Content Versions from Above Set
                
    //             List<ContentVersion>  contentList=[SELECT Id, ContentDocumentId,Title, IsLatest, PathOnClient,FirstPublishLocationId, Description, RatingCount, VersionData, FileExtension 
    //             FROM ContentVersion where ContentDocumentId IN: resSet AND IsLatest=true];
                
                    
    //             if(!contentList.isEmpty()){
    //                 for(ContentVersion cv:contentList){
    //                     ContentVersion newContent = new ContentVersion();
    //                     newContent.Title  = cv.Title+'_'+ string.valueOf(contentDocOffResourceMap.get(cv.ContentDocumentId));
    //                     newContent.PathOnClient  = cv.PathOnClient;
    //                     newContent.VersionData = cv.VersionData; 
                                        
    //                     newContentList.add(newContent);
    //                 }
    //             }
    //         /** Clearing Content List to reduce heap size**/
    //         contentList.clear();
    //         /** Clearing Content List to reduce heap size**/
                
    //         if(!newContentList.isEmpty()){
    //             insert newContentList;  // Creating New Content version
                
    //             for(ContentVersion cv:newContentList){
    //                 newContentVersionSet.add(cv.Id); //Adding all the new Ids in set to query newly created records as we need to get content document for newly created content versions
    //             }
    //             /** Clearing Content List to reduce heap size**/
    //             newContentList.clear();
    //             /** Clearing Content List to reduce heap size**/
                
                
    //                 List<ContentVersion>  newConVersionList=[SELECT Id, Title, ContentDocumentId,VersionData FROM ContentVersion where Id IN: newContentVersionSet AND IsLatest=true];
    //                 if(!newConVersionList.isEmpty()){
    //                     for(ContentVersion cv:newConVersionList){
    //                         newContentDocMap.put( string.valueOf(OffResourceContentDocMap.get(cv.Title.substringAfterLast('_'))), cv.ContentDocumentId );
    //                     }
    //                 }
    //                 /** Clearing Content List to reduce heap size**/
    //                 newConVersionList.clear();
    //             /** Clearing Content List to reduce heap size**/
                    
    //         }
                    
    //         for(PMP_Partner_Offering_Resource__c offResc:tempResList){
    //             PMP_Partner_Offering_Resource__c clonedOffResc = new PMP_Partner_Offering_Resource__c();
    //             clonedOffResc = offResc.clone(false,false,true,true);
    //             for(PMP_Partner_Offering__c tempOff:offList){
    //                 if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offResc.PMP_Offering_Id__c)){  
    //                     clonedOffResc.PMP_Offering_Id__c = tempOff.Id; 
    //                 }    
    //             }
    //             //clonedOffResc.CreatedById = offResc.CreatedById;
    //             clonedOffResc.PMP_Partner_Offering_Image__c = newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c); //Getting the value of new content document Id
    //             clonedOffResList.add(clonedOffResc);
    //         }
                        
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    //     return clonedOffResList; // Returning all the Translations that needs to be inserted.
    // }



    // /**
    // * @description Method to update working copy post publishing the offering
    // * @param List<PMP_Partner_Offering__c>
    // * @return void 
    // **/
    //     public static void updateWorkingCopyPostPublished(List<PMP_Partner_Offering__c> offList){

    //     try{
    //         List<PMP_Partner_Offering__c> currentOfferingList = new List<PMP_Partner_Offering__c>();
    //         if(!offList.isEmpty()) {            
    //             for(PMP_Partner_Offering__c off:offList) {                
    //                 PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c(Id=off.Id);
    //                 //If working copy is published set the flag to true (only first time we need to set)
    //                 if(!off.PMP_Is_Published_Ind__c){
    //                     offering.PMP_Is_Published_Ind__c=true;
    //                 } 
    //                 //if the visibility is Intel only then change to public after publishing
    //                 if(off.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {
    //                     offering.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
    //                 }
    //         //if the Pre-release check is Yes or No,clear it post publish/republish
    //                 if(off.PMP_Pre_Release_Check_Nm__c==PMP_StaticConstants_MasterData.Yes||off.PMP_Pre_Release_Check_Nm__c==PMP_StaticConstants_MasterData.No) {
    //                     offering.PMP_Pre_Release_Check_Nm__c='';
    //                 }
    //                 offering.PMP_Partner_Offering_LifecycleStatus_Txt__c= off.PMP_Partner_Offering_Lifecycle_Status_Nm__c; //transfer the updated value to show as second column in look filter on events
    //                 currentOfferingList.add(offering);
    //             }
    //             if(!currentOfferingList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
    //                 update currentOfferingList;
    //             }
    //         }
    //     }
            
    //     catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    // }

    // /**
    // * @description sync featured indicator from working copy to published copy
    // * @param Map
    // * @return Void
    // **/

    // public static void syncFeaturedOffering(Map<Id,Boolean> featuredOfferingMap){
    //     try{
            
    //         List<PMP_Partner_Offering__c> featuredOfferingList = new List<PMP_Partner_Offering__c>();
            
    //         if(!featuredOfferingMap.isEmpty()){
    //             for(PMP_Partner_Offering__c off: [select id,PMP_Featured_Offering_Ind__c,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c IN:featuredOfferingMap.keyset()]){
    //                 off.PMP_Featured_Offering_Ind__c = featuredOfferingMap.get(off.PMP_Working_Copy_Id__c);  
    //                 featuredOfferingList.add(off);
    //             }
    //         }
            
    //         if(featuredOfferingList.size()>0 && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
    //             update featuredOfferingList;  // Update offering
    //             clearfeaturedPlatformCache(featuredOfferingList); // clearing cache for featured offerings.
    //         }
            
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    // }
        
    //     /**
    // * @description To Set Is Notified indicator to True, either Lifecycle stauts changed to approved or PreReleasecount changed to 0.
    // *              When Is Notified is set to True, we are Using the same To send email to the POE To Change the Start Date.
    // * @Object PMP_Partner_Offering__c
    // * @param trigger.new List, Old Map
    // * @return Void
    // * @UserStory US605790,US605797
    // **/

    // public static void isNotifiedToTrue(List<PMP_Partner_Offering__c> offList,map<Id,PMP_Partner_Offering__c> oldMap){
                
    //     for(PMP_Partner_Offering__c off:offList){ //iterate through offering List which has Trigger.New
            
    //         if((oldMap.get(off.Id).PMP_Partner_Offering_Lifecycle_Status_Nm__c != PMP_StaticConstants_MasterData.Approved // either
    //             && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved)          // Old LifeCycle Status not Equals to Approved and New LifeCycleStatus Equals to Approved
    //             ||                                                                                                       // OR   
    //             (oldMap.get(off.Id).PMP_Pre_Release_Item_Count_Num__c !=PMP_StaticConstants_MasterData.Zero              
    //             &&off.PMP_Pre_Release_Item_Count_Num__c==PMP_StaticConstants_MasterData.Zero)                           // Old PreRelease Item Count NotEquals to 0 and New PreRelease Item Count Equals to 0
    //             ){   
    //                 /* even when an offering with one of the above changes enters the Condition
    // Is Notified is Set to True Only when an Offering has LifeCycleStatus Equals to Approved 
    // and PreRelease Item Count Equals to 0, so Checking for both in below if*/
                    
    //                 if (off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.No                             // PreRelease Check NO scenario
    //                     && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved    // LifeCycleStatus Equals to Approved
    //                     && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero)                 // New PreRelease Item Count Equals to 0
    //                 {    
    //                     off.PMP_Is_Notified_Ind__c = true; // Setting IsNotified to True,
                        
    //                 }
                    
    //             }                   
    //     }    
    // }

    // /**
    // * @description This method is used to clear featured offering cache when published offering is promoted. 
    // * @param List of PMP_Partner_Offering__c 
    // * @return Void 
    // **/
    // public static void clearfeaturedPlatformCache(List <PMP_Partner_Offering__c> offeringList){
    // try{
    //     String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
    //     String langKeys=PMP_StaticConstants_Partner.supportedLanguagesForPlatformCache;
    //     Map<String,String> langMap= new Map<string,string>();
    //     for(String languageCode : langKeys.split('\\;')){
    //         langMap.put(languageCode,languageCode.replace('_', '').replace('-', ''));
    //     }
            
    //         for(PMP_Partner_Offering__c offering : offeringList){
    //             String key1 = 'Featured'+langMap.values()[0];
    //             String key2 = 'Featured'+langMap.values()[1];
    //             String key3 = 'Featured'+langMap.values()[2];
    //             Cache.Org.remove(partitionInput+'.'+key1);
    //             Cache.Org.remove(partitionInput+'.'+key2);
    //             Cache.Org.remove(partitionInput+'.'+key3);
    //         }
    //     } catch(Exception error){
    //         PMP_Utility.logError(error,'FeaturedPlatformCacheDeletion');   
    //     }
        
    // }

    // //US1029844
    // /*************************************************************************************************************
    // * Method Name : clearPlatformCache
    // * Description : this method clear the platform cache of featured offerings , event page and offering detail page 
    //             for all the 3 locales for the given offeringsIds
    // * Version     : 1.0 
    // * Created Date: 12-June-2021
    // * Modification Log :
    // * Created By  : Priyanka (Infosys)
    // **************************************************************************************************************/

    // public static void clearPlatformCache(Set<Id> offeringIds){
    //     Map<Id,List<Id>> offeringEventList= new Map<Id,List<Id>>();
    //     List<PMP_Marketplace_Event_Offering__c> evntOfferingList= new List<PMP_Marketplace_Event_Offering__c>();
    //     try{
    //     if(Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible()){
    //         //query all the events associated to offeringIds recieved
    //         evntOfferingList=[select id,name, PMP_Offering_Id__c, PMP_Event_Id__c from  PMP_Marketplace_Event_Offering__c
    //                             where PMP_Offering_Id__c in : offeringIds];
    //     }
    //     for(PMP_Marketplace_Event_Offering__c evntOffering: evntOfferingList)
    //     {
    //         if(offeringEventList.containsKey(evntOffering.PMP_Offering_Id__c)){
    //             List<id> eventIds=offeringEventList.get(evntOffering.PMP_Offering_Id__c);
    //             eventIds.add(evntOffering.PMP_Event_Id__c);
    //             offeringEventList.put(evntOffering.PMP_Offering_Id__c,eventIds); // form the offeringEventList map
                
    //         }
    //         else{
    //             offeringEventList.put(evntOffering.PMP_Offering_Id__c,new List<Id> {evntOffering.PMP_Event_Id__c});// form the offeringEventList map
                
    //         }
    //     }
        
        
    //         String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');//get the partition input
    //         List<PMP_Locale_To_FieldAPINm_Mapping__mdt> mdtRecList =new List<PMP_Locale_To_FieldAPINm_Mapping__mdt>();
    //         //get all the metadata records where the ObjectName is PlatformCache
    //         mdtRecList=[select id ,DeveloperName, PMP_Field_APINm__c, PMP_Field_Nm__c, PMP_Language_Nm__c, PMP_Locale_Nm__c, 
    //                     PMP_Object_Nm__c from PMP_Locale_To_FieldAPINm_Mapping__mdt  where PMP_Object_Nm__c ='PlatformCache']; 
    //         String key;                                                      
    //         for(Id offId: offeringIds){
    //             for(PMP_Locale_To_FieldAPINm_Mapping__mdt mdtRec: mdtRecList){
    //                 String languageCode=mdtRec.PMP_Locale_Nm__c.replace('_', '').replace('-', '');//Remove the unnecessary characters from langCode
    //                 // System.debug('The lang code is:'+languageCode);
    //                 if(mdtRec.PMP_Field_Nm__c == 'Featured' || mdtRec.PMP_Field_Nm__c == 'BaseTaxonomy'){
    //                     key=mdtRec.PMP_Field_Nm__c+languageCode; //form the key
    //                     Cache.Org.remove(partitionInput+'.'+key); //remove the key from platform cache
                        
    //                 }   
    //                 else if(mdtRec.PMP_Field_Nm__c == 'Event' && offeringEventList.containsKey(offId)){
    //                     for(Id eventId: offeringEventList.get(offId)){
    //                         key=mdtRec.PMP_Field_Nm__c+eventId+languageCode; //form the key
    //                         Cache.Org.remove(partitionInput+'.'+key); //remove the key from platform cache
    //                     }    
    //                 }
    //                 else if(mdtRec.PMP_Field_Nm__c == 'OfferingDetail'){
    //                     key=mdtRec.PMP_Field_Nm__c+offId+languageCode; //form the key
    //                     Cache.Org.remove(partitionInput+'.'+key); //remove the key from platform cache
    //                     //System.debug('Cache removed successfully');
    //                 }   
    //             }
    //         }
    //     }catch(Exception error){
    //         PMP_Utility.logError(error,'PMP_ClearPlatformCache'); //log the error if any issues in the method.
    //     }
        
    // }

    // //TWC1824-1066
    // /*************************************************************************************************************
    // * Method Name : replaceEventApprovedOfferings
    // * Description : this method replaces the approved offerings records having pre release products 
    //             with fully publsihed copy when offerings are republished on events
    // * Version     : 1.0 
    // * Created Date: 20-October-2021
    // * Modification Log :
    // * Created By  : Yashasvi Aggarwal
    // **************************************************************************************************************/
    // public static void replaceEventApprovedOfferings(Set<Id> offeringIds){
    //     List<PMP_Marketplace_Event_Offering__c> eventOffList= new List<PMP_Marketplace_Event_Offering__c>();
    //     //try - block
    //     try{  
    //         if(Schema.sObjectType.PMP_Marketplace_Event_Offering__c.isAccessible())
    //         {          
    //             //query all the events offerings associated to offeringIds recieved
    //             eventOffList=[select Id,Name,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c,PMP_Event_Id__c
    //                             from PMP_Marketplace_Event_Offering__c where PMP_Offering_Id__c in : offeringIds];
    //         }
    //         // System.debug('eventOffList-->'+eventOffList);
    //         if(eventOffList.size()>0)
    //         {
    //             //Initialise variables
    //             List<PMP_Marketplace_Event_Offering__c> createEventOfferingList = new List<PMP_Marketplace_Event_Offering__c>();
    //             List<PMP_Marketplace_Event_Offering__c> deleteEventOfferingList = new List<PMP_Marketplace_Event_Offering__c>();
    //             //Iterating on the list of event offerings
    //             for(PMP_Marketplace_Event_Offering__c eventOffObj : eventOffList){
    //                 PMP_Marketplace_Event_Offering__c newEventOff = new PMP_Marketplace_Event_Offering__c();
    //                 newEventOff.PMP_Offering_Id__c=eventOffObj.PMP_Offering_Id__r.PMP_Published_Copy_Id_Txt__c;
    //                 newEventOff.PMP_Event_Id__c=eventOffObj.PMP_Event_Id__c;
    //                 //adding the offering in createEventOfferingList to create event approved offering record
    //                 createEventOfferingList.add(newEventOff);
    //                 //adding the offering in deleteEventOfferingList to delete event published offering record
    //                 deleteEventOfferingList.add(eventOffObj);
    //             }
    //             // System.debug('createEventOfferingList-->'+createEventOfferingList);  
    //             // System.debug('deleteEventOfferingList-->'+deleteEventOfferingList);  
                    
    //             //if the delete offering list is not empty 
    //             if(deleteEventOfferingList.size()>0){
    //                 delete deleteEventOfferingList;
    //             }  
    //             //if the insert offering list is not empty 
    //             if(createEventOfferingList.size()>0){
    //                 insert createEventOfferingList;
    //             } 
    //         }
    //     }
    //     //Catch - block
    //     catch(Exception error){
    //         PMP_Utility.logError(error,'PMP_ReplaceEventApprovedOfferings'); //log the error if any issues in the method.
    //     }    
    // }


    // //TWC1824-2719
    // /*************************************************************************************************************
    // * Method Name : updateRemovePublicofferingList
    // * Description : this method removes the published offerings records from Public once pre release products 
    //             are attached to its approved working copy.
    // * Version     : 1.0 
    // * Created Date: 08-Feb-2021
    // * Modification Log :
    // * Created By  : Vardaan Vashisth
    // **************************************************************************************************************/
    // public static void updateRemovePublicofferingList(List<PMP_Partner_Offering__c> offList){
        
    // // System.debug('--- Inside update Remove offerings method -----');
    //     //syncing working copy with Published Copy
    //         updateRemovePublicOfferings(offList);


    // } 


    // /**
    // * @description : Method to update offering records
    // * @param List
    // * @return void
    // **/
    // public static void updateRemovePublicOfferings(List<PMP_Partner_Offering__c> offList){
        
    //     try{
    //         //Declarations
    //         Set<Id> offIds = new Set<Id>();
    //         //Set<Id> currentOffIds = new Set<Id>();
    //         Set<Id> offeringUpdateSet = new Set<Id>();
    //         Map<Id,PMP_Partner_Offering__c> offeringMap = new Map<Id,PMP_Partner_Offering__c>();
    //         //List<PMP_Partner_Offering__c> createPublishedOfferingList = new List<PMP_Partner_Offering__c>();
    //         List<PMP_Partner_Offering__c> updatePublishedOfferingList = new List<PMP_Partner_Offering__c>();
    //         //List<PMP_Partner_Offering__c> newOfferingList = new List<PMP_Partner_Offering__c>();
    //         Map<Id,Id> existingOfferingMap = new map<Id,Id>();
    //         Map<Id,Id> offeringPublishedMap = new map<Id,Id>();
    //         Set<Id> existingOffIds = new Set<Id>();
    //         Set<Id> newOfferingIds = new Set<Id>();
    //         List<PMP_Partner_Offering__c> existingOfferingList = new List<PMP_Partner_Offering__c>();
            
    //         List<PMP_Partner_Offering_Category__c> categoriesToBeInsertedList = new List<PMP_Partner_Offering_Category__c>();
    //         List<PMP_Partner_Offering_Specification__c> specsToBeInsertedList = new List<PMP_Partner_Offering_Specification__c>();
    //         List<PMP_Partner_Offering_Translation__c> translationsToBeInsertedList = new List<PMP_Partner_Offering_Translation__c>();
    //         List<PMP_Partner_Offering_Resource__c> resToBeInsertedList = new List<PMP_Partner_Offering_Resource__c>();
            
    //         List<PMP_Partner_Offering_Category__c> catDeletionList =  new List<PMP_Partner_Offering_Category__c>();
    //         List<PMP_Partner_Offering_Specification__c> SpecDeletionList = new List<PMP_Partner_Offering_Specification__c>();
    //         List<PMP_Partner_Offering_Resource__c> ResDeletionList = new List<PMP_Partner_Offering_Resource__c>();
    //         List<PMP_Partner_Offering_Translation__c> transDeletionList = new List<PMP_Partner_Offering_Translation__c>();
    //         //Offering to be used to update post publishing
    //         List<PMP_Partner_Offering__c> workingCopyOfferings = new List<PMP_Partner_Offering__c>();
            
            
                        
    //         if(!offList.isEmpty()){
    //             for(PMP_Partner_Offering__c off: offList){
    //                 offIds.add(off.Id);
    //                 offeringMap.put(off.Id,off);
    //                 existingOfferingMap.put(off.Id,off.Id); 
    //                 offeringUpdateSet.add(off.Id);
    //                 // system.debug('offeringUpdateSet'+ offeringUpdateSet);
                    
    //                 updatePublishedOfferingList.add(off); //update published offering
    //                 workingCopyOfferings.add(off); // working copy offerings to be used for post update after publishing    
                
                    
    //                 //system.debug('workingCopyOfferings' + workingCopyOfferings);
    //                 //System.debug('updatePublishedOfferingList' + updatePublishedOfferingList);
                    
    //                 //PMP_CreateOfferingTab5Service.generateThumbnailImages(off.Id); //future method if execution is not a batch context
                    
    //             }
    //         }
                    
    //         if(!updatePublishedOfferingList.isEmpty()){
    //             List<PMP_Partner_Offering__c> publishedOfferingsList;
    //             if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
    //             publishedOfferingsList = [Select Id,PMP_Working_Copy_Id__c,LastModifiedById, PMP_Is_Not_Available_On_MP_Ind__c , PMP_Pre_Release_Item_Count_Num__c,
    //                                                 PMP_Partner_Offering_Visibility_Nm__c,PMP_Pre_Release_Check_Nm__c, PMP_Partner_Offering_Lifecycle_Status_Nm__c,
    //                                                 PMP_Is_Published_Ind__c,PMP_Partner_Offering_Start_Dt__c,PMP_Partner_Offering_LifecycleStatus_Txt__c from PMP_Partner_Offering__c 
    //                                                 where PMP_Working_Copy_Id__c IN : offeringUpdateSet];
    //             }
    //             if(!publishedOfferingsList.isEmpty()){
    //                 for(PMP_Partner_Offering__c off:publishedOfferingsList){
    //                     offeringPublishedMap.put(off.PMP_Working_Copy_Id__c,off.PMP_Working_Copy_Id__c);
    //                     offeringPublishedMap.put(off.PMP_Working_Copy_Id__c,off.PMP_Working_Copy_Id__c);
    //                     PMP_Partner_Offering__c offer = offeringMap.get(off.PMP_Working_Copy_Id__c).clone(false,false,true,true);
    //                     offer.PMP_Working_Copy_Id__c =  offeringMap.get(off.PMP_Working_Copy_Id__c).Id;   // Stamping Id of the offering which invoked the process on the newly created published copy
    //                     offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_MasterData.Published; //changing offering status to published
    //                     offer.CreatedById = offeringMap.get(off.PMP_Working_Copy_Id__c).LastModifiedById;
    //                     offer.PMP_Offering_Status_Update_Dt__c = system.now();      //changing the status update date to today
    //                     offer.PMP_Partner_Offering_Sync_Status_Nm__c = '';             // Clearing the PIM status 
    //                     offer.OwnerId = off.LastModifiedById;
    //                     offer.PMP_Is_Published_Ind__c = false;
    //                     offer.PMP_Pre_Release_Check_Nm__c='';//clearing Pre-release check and Is notified flags for published copy during republish
    //                     offer.PMP_Is_Notified_Ind__c=false;
    //                     offer.PMP_Is_Not_Available_On_MP_Ind__c=true; //make not available on MP Indicator false to publish it
    //                     offer.PMP_Partner_Offering_LifecycleStatus_Txt__c= offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c;  //transfer the updated value to show as second column in look filter on events
    //                     offer.Id = off.Id; 
    //                     newOfferingIds.add(off.Id);
    //                     existingOffIds.add(off.PMP_Working_Copy_Id__c);
    //                     existingOfferingList.add(offer);
    //                 }
    //             }
                
    //             if(!existingOfferingList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering__c.isUpdateable()){
    //                 update existingOfferingList;
    //                 //Deleting all the previously existing child records
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
    //                     catDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN : newOfferingIds];
    //                 }   
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Specification__c.isAccessible()){
    //                     SpecDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c IN :newOfferingIds];
    //                 } 
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
    //                     ResDeletionList = [select id,PMP_Offering_Id__c,PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c IN :newOfferingIds];
    //                 }
    //                 if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
    //                     transDeletionList = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN :newOfferingIds];      
    //                 }   
    //                 //End Of Deletion
                    
    //                 List<PMP_Partner_Offering_Category__c> catUpdateList = createCategories(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Categories from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Specification__c> specUpdateList = createSpecifications(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Specifications from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Translation__c> translationUpdateList = createTranslations(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Translations from Approved record to Published Record
    //                 List<PMP_Partner_Offering_Resource__c> resUpdateList = createResourcesDocumentLink(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Resources from Approved record to Published Record
                    

    //                 //Deleting the old records from published Version
    //                 if(!catDeletionList.isEmpty()){
    //                     delete catDeletionList;
    //                 }

    //                 if(!SpecDeletionList.isEmpty()){
    //                     delete SpecDeletionList;
    //                 }

    //                 if(!transDeletionList.isEmpty()){
    //                     delete transDeletionList;
    //                 }

    //                 if(!ResDeletionList.isEmpty()){
    //                     delete ResDeletionList;
    //                 }
                    
    //                 //List of records that needs to be deleted from published version in order to sync with working copy
    //                 if(!catUpdateList.isEmpty()){
    //                     categoriesToBeInsertedList.addAll(catUpdateList);  
    //                 }
                    
    //                 if(!specUpdateList.isEmpty()){
    //                     specsToBeInsertedList.addAll(specUpdateList);
    //                 }
                    
    //                 if(!resUpdateList.isEmpty()){
    //                     resToBeInsertedList.addAll(resUpdateList);
    //                 }
                    
    //                 if(!translationUpdateList.isEmpty()){
    //                     translationsToBeInsertedList.addAll(translationUpdateList);
    //                 }
                    
    //             }
                
    //         }
                            
    //         // System.debug('workingCopyOfferings' + workingCopyOfferings);
    //         //Use this method to update working copy data after publishing the offering
        
            
    //         //Inserting all the respective records
    //         if(!categoriesToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isCreateable()){
    //             insert categoriesToBeInsertedList;
    //         }
            
    //         if(!specsToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Specification__c.isCreateable()){
    //             insert specsToBeInsertedList;
    //         }
            
    //         if(!translationsToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Translation__c.isCreateable()){
    //             insert translationsToBeInsertedList;
    //         }
            
    //         if(!resToBeInsertedList.isEmpty() && Schema.sObjectType.PMP_Partner_Offering_Resource__c.isCreateable()){
    //             insert resToBeInsertedList;
    //         }
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //         Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
    //         String[] sendingTo = new String[]{};
    //         sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
    //         semail.setToAddresses(sendingTo);
    //         semail.setSubject('OfferingException');
    //         semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
    //         Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    //     }
        
        
    // } 



    // public static List<PMP_Partner_Offering_Resource__c> createResourcesDocumentLink(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
    //     List<PMP_Partner_Offering_Resource__c> clonedOffResList = new List<PMP_Partner_Offering_Resource__c>();
    //     try{
    //         //Querying all the child records
    //         DescribeSObjectResult offResFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();   
    //         List<String> resFieldNames = new List<String>( offResFields.fields.getMap().keySet() );    
    //         String offResQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( resFieldNames, ',' )) +    ' FROM ' +         String.escapeSingleQuotes(offResFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds';
    //         List<PMP_Partner_Offering_Resource__c> tempResList = Database.query(offResQuery);
            
    //         Set<Id> resSet = new Set<Id>();
    //         Map<Id,Id> newContentDocMap = new Map<Id,Id>();
    //         Map<Id,Id> contentDocOffResourceMap = New Map<Id,Id>();
    //         Map<Id,Id> OffResourceContentDocMap = New map<Id,Id>();
    //         //List<ContentAsset> contentAssetList = new List<ContentAsset>();
            
    //         //system.debug('PPP:size'+tempResList.size());
           
    //         for(PMP_Partner_Offering_Resource__c offResc:tempResList){  
    //             // system.debug('PPP:Res'+offResc);
    //             if(string.isNotBlank(offResc.PMP_Partner_Offering_Image__c)){
    //                resSet.add(offResc.PMP_Partner_Offering_Image__c);
    //                contentDocOffResourceMap.put((id) offResc.PMP_Partner_Offering_Image__c, offResc.Id);
    //                OffResourceContentDocMap.put(offResc.Id, (id) offResc.PMP_Partner_Offering_Image__c);
                   
    //             }
    //         }
            
            
    //         //Querying Content Versions from Above Set
               
    //             List<ContentVersion>  contentList=[SELECT Id, ContentDocumentId,Title  FROM ContentVersion where ContentDocumentId IN: resSet AND IsLatest=true];
                
                    
    //             if(!contentList.isEmpty()){
    //                 for(ContentVersion cv:contentList){
    //                     String title = string.valueOf(contentDocOffResourceMap.get(cv.ContentDocumentId));
    //                     newContentDocMap.put( string.valueOf(OffResourceContentDocMap.get(title)), cv.ContentDocumentId );
    //                 }
    //             }

    //             //system.debug('newContentDocMap:::'+ newContentDocMap);
    //         /** Clearing Content List to reduce heap size**/
    //         contentList.clear();
    //         /** Clearing Content List to reduce heap size**/
            
    //         //Added as Part of ORG Health Issues
    //         Map<Id, Set<Id>> existingLinksMap = new Map<Id, Set<Id>>();
    //         for (ContentDocumentLink existingLink : [
    //             SELECT Id, LinkedEntityId, ContentDocumentId
    //             FROM ContentDocumentLink
    //             WHERE ContentDocumentId IN :resSet
    //         ]) {
    //             if (!existingLinksMap.containsKey(existingLink.ContentDocumentId)) {
    //                 existingLinksMap.put(existingLink.ContentDocumentId, new Set<Id>());
    //              }
	// 			existingLinksMap.get(existingLink.ContentDocumentId).add(existingLink.LinkedEntityId);
				
    //         }
    //         //End as Part of ORG Health Issues

    //         List<ContentDocumentLink> clonedDocumentLinks = new List<ContentDocumentLink>();//List to store contentDocumentLinks 
    //         //List<ContentDocumentLink> deleteDocumentLinks = new List<ContentDocumentLink>();//List to store contentDocumentLinks   
            
            
    //         for(PMP_Partner_Offering_Resource__c offResc:tempResList){
    //             PMP_Partner_Offering_Resource__c clonedOffResc = new PMP_Partner_Offering_Resource__c();
    //             clonedOffResc = offResc.clone(false,false,true,true);
    //             for(PMP_Partner_Offering__c tempOff:offList){
    //                 if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offResc.PMP_Offering_Id__c)){  
    //                     clonedOffResc.PMP_Offering_Id__c = tempOff.Id; 
    //                 }    
    //             }
                
    //             clonedOffResc.PMP_Partner_Offering_Image__c = newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c); //Getting the value of new content document Id
                
    //             clonedOffResList.add(clonedOffResc);
    //             //system.debug('I AM HERE outside IF 1145');
    //             if(newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c)!=null &&
    //                (clonedOffResc.PMP_Partner_Offering_Image__c != null || clonedOffResc.PMP_Partner_Offering_Image__c != '')){//if the resource type is image, create contentDocument link for that image
                    
    //                 //String  deleteLinkOffId = clonedOffResc.PMP_Offering_Id__c;
    //                 //Added as Part of ORG Health Issues
    //                 Set<Id> existingLinkedEntities = existingLinksMap.get(newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c));
    //                 Boolean documentAlreadyLinked = existingLinkedEntities != null && existingLinkedEntities.contains(clonedOffResc.PMP_Offering_Id__c);
    //                 //End as Part of ORG Health Issues
                    
    //                 // Check if the document is already linked
    //             if (!documentAlreadyLinked)  {
    //                     //system.debug('I AM HERE INSIDE IF 1151');
    //                     ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c), clonedOffResc.PMP_Offering_Id__c);//get contentDocumentLink from utility class
    //                     clonedDocumentLinks.add(cdl);
    //                 }
    //             }
    //         }
            
    //         insert clonedDocumentLinks;
                      
    //     }catch(exception e){
    //         PMP_Utility.logError(e,'PMP_CreateOffering');
    //     }
    //     return clonedOffResList; // Returning all the Translations that needs to be inserted.
    // }


    // public static void deleteImageFiles(List<PMP_Partner_Offering_Resource__c> deleteIds){
    //     //Added for copado validation error
    // }
    }