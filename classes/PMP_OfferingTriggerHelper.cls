/**************************************************************************************
Apex Class Name : PMP_OfferingTriggerHelper
Version     : 1.0 
Created Date: 26th Jan, 2019
Description : Trigger handler for PMP_Offering_Resource_Trigger
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Shahrukh                  26/03/2019               Original Version
*************************************************************************************/

public class PMP_OfferingTriggerHelper{
    /**
    * @description : Method to send the list of records to which published version needs to be created
    * @param List,Map
    * @return void
    **/
    public static void clonePublishedOffering(List<PMP_Partner_Offering__c> offList,map<Id,PMP_Partner_Offering__c> oldMap){
        try{
                //Declarations
                List<PMP_Partner_Offering__c> offeringList = new List<PMP_Partner_Offering__c>();
                Map<Id,Boolean> featuredOfferingMap = new Map<Id,Boolean>();
               System.debug('--- Inside clone publish offerings -----');
               /* 
            Offering to be published only if it is 
                Approved && StartDate is <= Today && Pre Release COunt is Zero && Pre Release Check should not be No
            */
            for(PMP_Partner_Offering__c off:offList){
                if((oldMap.get(off.Id).PMP_Partner_Offering_Lifecycle_Status_Nm__c != PMP_StaticConstants_MasterData.Approved
                    && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved
                    && off.PMP_Partner_Offering_Start_Dt__c <= system.Today()
                    && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero 
                    && off.PMP_Pre_Release_Check_Nm__c != PMP_StaticConstants_MasterData.No) // Yes or Blank
                   ||     //Adding below conditions for offerings with Pre-release flag set as No
                   (off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.No
                    && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero
                    && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved
                    && off.PMP_Partner_Offering_Start_Dt__c <= system.Today()
                    && off.PMP_Is_Notified_Ind__c == false))
                    
                {
                    offeringList.add(off);      // Adding all the offerings which satisfies above criteria to a list
                    
                }
                    
                   
                    if(off.PMP_Featured_Offering_Ind__c!=oldMap.get(off.Id).PMP_Featured_Offering_Ind__c){
                        featuredOfferingMap.put(off.Id,off.PMP_Featured_Offering_Ind__c);
                    }
                   
                }
               system.debug('offeringList before--------'+offeringList);
                if(!offeringList.isEmpty()){
                    String cronId = System.scheduleBatch(new PMP_CreateUpdatePublishOfferings(offeringList), 'MonitorThumbnailImages'+ System.now().getTime(),1);
                    // createPublishedOfferings(offeringList);  // Passing the offering list to a method where new offerings are created
                }
                system.debug('###Batch got scheduled:->');
                system.debug('###featuredOfferingMap:->'+featuredOfferingMap);
                if(!featuredOfferingMap.isEmpty()){
                    syncFeaturedOffering(featuredOfferingMap);
                }
            
            }catch(exception e){
            
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{};
            sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
            semail.setToAddresses(sendingTo);
            semail.setSubject('OfferingException');
            semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        }
    }
    /**
    * @description : Method to create published offering records
    * @param List
    * @return void
    **/
    public static void createPublishedOfferings(List<PMP_Partner_Offering__c> offList){
        
        System.debug('--- Inside create publish offerings -----');
        try{
            //Declarations
            Set<Id> offIds = new Set<Id>();
            Set<Id> currentOffIds = new Set<Id>();
            Set<Id> offeringUpdateSet = new Set<Id>();
            Map<Id,PMP_Partner_Offering__c> offeringMap = new Map<Id,PMP_Partner_Offering__c>();
            List<PMP_Partner_Offering__c> createPublishedOfferingList = new List<PMP_Partner_Offering__c>();
            List<PMP_Partner_Offering__c> updatePublishedOfferingList = new List<PMP_Partner_Offering__c>();
            List<PMP_Partner_Offering__c> newOfferingList = new List<PMP_Partner_Offering__c>();
            Map<Id,Id> existingOfferingMap = new map<Id,Id>();
            Map<Id,Id> offeringPublishedMap = new map<Id,Id>();
            Set<Id> existingOffIds = new Set<Id>();
            Set<Id> newOfferingIds = new Set<Id>();
            List<PMP_Partner_Offering__c> existingOfferingList = new List<PMP_Partner_Offering__c>();
            
            List<PMP_Partner_Offering_Category__c> categoriesToBeInsertedList = new List<PMP_Partner_Offering_Category__c>();
            List<PMP_Partner_Offering_Specification__c> specsToBeInsertedList = new List<PMP_Partner_Offering_Specification__c>();
            List<PMP_Partner_Offering_Translation__c> translationsToBeInsertedList = new List<PMP_Partner_Offering_Translation__c>();
            List<PMP_Partner_Offering_Resource__c> resToBeInsertedList = new List<PMP_Partner_Offering_Resource__c>();
            
            List<PMP_Partner_Offering_Category__c> catDeletionList =  new List<PMP_Partner_Offering_Category__c>();
            List<PMP_Partner_Offering_Specification__c> SpecDeletionList = new List<PMP_Partner_Offering_Specification__c>();
            List<PMP_Partner_Offering_Resource__c> ResDeletionList = new List<PMP_Partner_Offering_Resource__c>();
            List<PMP_Partner_Offering_Translation__c> transDeletionList = new List<PMP_Partner_Offering_Translation__c>();
            //Offering to be used to update post publishing
			List<PMP_Partner_Offering__c> workingCopyOfferings = new List<PMP_Partner_Offering__c>();
			            
            if(!offList.isEmpty()){
                for(PMP_Partner_Offering__c off: offList){
                    offIds.add(off.Id);
                    offeringMap.put(off.Id,off);
                    existingOfferingMap.put(off.Id,off.Id);
                    if(off.PMP_Is_Published_Ind__c==false){
                       createPublishedOfferingList.add(off);  //If Published indicator is false we are creating a new offering by adding it in create list
                       
                    }else{
                        
                        offeringUpdateSet.add(off.Id);
                        updatePublishedOfferingList.add(off); //Else we are updating the previously published offering
                    }
                    workingCopyOfferings.add(off); // working copy offerings to be used for post update after publishing
                }
            }
            
            
            if(!createPublishedOfferingList.isEmpty()){
                for(PMP_Partner_Offering__c off:offList){
                    PMP_Partner_Offering__c clonedOff = new PMP_Partner_Offering__c();
                    clonedOff = off.clone(false,true,true,true);    // Creating clone of approved offering with new salseforce id and copying all the other fields
                    clonedOff.PMP_Working_Copy_Id__c = off.Id;        // Stamping Id of the offering which invoked the process on the newly created published copy
                    
                   //if the visibility is intel only content then change to public
                    if(clonedOff.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {                    
                        clonedOff.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
                    }
                    clonedOff.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_MasterData.Published;//changing offering status to published
                    clonedOff.PMP_Pre_Release_Check_Nm__c='';//clearing Pre-release check and Is notified flags for published copy during first publish
                    clonedOff.PMP_Is_Notified_Ind__c=false;
                    system.debug('****lastMod*******'+off.LastModifiedById);
                    system.debug('****created*******'+off.createdById);
                    clonedOff.CreatedById = off.LastModifiedById;
                    clonedOff.OwnerId = off.LastModifiedById;
                    clonedOff.PMP_Offering_Status_Update_Dt__c = system.now();
                    newOfferingList.add(clonedOff);
                    currentOffIds.add(off.Id);
                    
                }
                
                if(!newOfferingList.isEmpty()){
                    system.debug('newOfferingList before ------'+newOfferingList);
                    insert newOfferingList;
                    system.debug('newOfferingList after------'+newOfferingList);
                    
                    
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                    List<PMP_Partner_Offering_Category__c> catList = createCategories(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Categories from Approved record to Published Record
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                    List<PMP_Partner_Offering_Specification__c> specList = createSpecifications(newOfferingList,currentOffIds,existingOfferingMap); //To Clone specifications from Approved record to Published Record
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                    List<PMP_Partner_Offering_Translation__c> translationList = createTranslations(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Translations from Approved record to Published Record
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                    List<PMP_Partner_Offering_Resource__c> resList = createResources(newOfferingList,currentOffIds,existingOfferingMap); //To Clone Resources from Approved record to Published Record
                   // system.debug('List before batch-------'+newOfferingList+' '+currentOffIds+' '+existingOfferingMap);
                   // String cronId = System.scheduleBatch(new cloneImageRecordsForPublishOfferings(newOfferingList,currentOffIds,existingOfferingMap), 'MonitorThumbnailImages'+ System.now().getTime(),1);
                   // System.debug('cronId in Helper----------'+cronId);
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                    
                    if(!catList.isEmpty()){
                       categoriesToBeInsertedList.addAll(catList);  //Adding Categories that needs to be inserted
                    }
                    
                    if(!specList.isEmpty()){
                       specsToBeInsertedList.addAll(specList); //Adding Specifications that needs to be inserted 
                    }
                    
                    if(!translationList.isEmpty()){
                       translationsToBeInsertedList.addAll(translationList); //Adding Translations that needs to be inserted
                    }
                    
                    if(!resList.isEmpty()){
                       system.debug('resList'+resList); 
                       resToBeInsertedList.addAll(resList);  //Adding Resources that needs to be inserted 
                    }
                    //system.debug('###HeapLimit:->'+Limits.getHeapSize());
                }
                
                
            
            }
            
            if(!updatePublishedOfferingList.isEmpty()){
            
                List<PMP_Partner_Offering__c> publishedOfferingsList = [Select Id,PMP_Working_Copy_Id__c,LastModifiedById from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c IN : offeringUpdateSet];
                
                if(!publishedOfferingsList.isEmpty()){
                    for(PMP_Partner_Offering__c off:publishedOfferingsList){
                        offeringPublishedMap.put(off.PMP_Working_Copy_Id__c,off.PMP_Working_Copy_Id__c);
                        PMP_Partner_Offering__c offer = offeringMap.get(off.PMP_Working_Copy_Id__c).clone(false,false,true,true);
                        offer.PMP_Working_Copy_Id__c =  offeringMap.get(off.PMP_Working_Copy_Id__c).Id;   // Stamping Id of the offering which invoked the process on the newly created published copy
                         //if the visibility is intel only content then change to public
                        if(offer.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {                    
                            offer.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
                        }
                        offer.PMP_Partner_Offering_Lifecycle_Status_Nm__c = PMP_StaticConstants_MasterData.Published; //changing offering status to published
                        offer.CreatedById = offeringMap.get(off.PMP_Working_Copy_Id__c).LastModifiedById;
                        offer.PMP_Offering_Status_Update_Dt__c = system.now();      //changing the status update date to today
                        offer.PMP_Partner_Offering_Sync_Status_Nm__c = '';             // Clearing the PIM status 
                        offer.OwnerId = off.LastModifiedById;
                        offer.PMP_Is_Published_Ind__c = false;
                        offer.PMP_Pre_Release_Check_Nm__c='';//clearing Pre-release check and Is notified flags for published copy during republish
                        offer.PMP_Is_Notified_Ind__c=false;
                        offer.Id = off.Id; 
                        newOfferingIds.add(off.Id);
                        existingOffIds.add(off.PMP_Working_Copy_Id__c);
                        existingOfferingList.add(offer);
                    }
                }
                
                if(!existingOfferingList.isEmpty()){
                    update existingOfferingList;
                    clearPlatformCache(existingOfferingList);                  
                    //Deleting all the previously existing child records
                    catDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c IN : newOfferingIds];
                               
                    SpecDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Specification__c where PMP_Offering_Id__c IN :newOfferingIds];
                             
                    ResDeletionList = [select id,PMP_Offering_Id__c from PMP_Partner_Offering_Resource__c where PMP_Offering_Id__c IN :newOfferingIds];
                          
                    transDeletionList = [select id,PMP_Partner_Offering_Id__c from PMP_Partner_Offering_Translation__c where PMP_Partner_Offering_Id__c IN :newOfferingIds];      
                    //End Of Deletion
                    
                    List<PMP_Partner_Offering_Category__c> catUpdateList = createCategories(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Categories from Approved record to Published Record
                    List<PMP_Partner_Offering_Specification__c> specUpdateList = createSpecifications(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Specifications from Approved record to Published Record
                    List<PMP_Partner_Offering_Translation__c> translationUpdateList = createTranslations(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Translations from Approved record to Published Record
                    List<PMP_Partner_Offering_Resource__c> resUpdateList = createResources(existingOfferingList,existingOffIds,offeringPublishedMap); //To Clone Resources from Approved record to Published Record
                    
                    
                    //List of records that needs to be deleted from published version in order to sync with working copy
                    if(!catUpdateList.isEmpty()){
                       categoriesToBeInsertedList.addAll(catUpdateList);  
                    }
                    
                    if(!specUpdateList.isEmpty()){
                       specsToBeInsertedList.addAll(specUpdateList);
                    }
                    
                    if(!resUpdateList.isEmpty()){
                       resToBeInsertedList.addAll(resUpdateList);
                    }
                    
                    if(!translationUpdateList.isEmpty()){
                       translationsToBeInsertedList.addAll(translationUpdateList);
                    }
                }
                
            }
            
            //Use this method to update working copy data after publishing the offering
			if(!workingCopyOfferings.isEmpty()){				
				updateWorkingCopyPostPublished(workingCopyOfferings);
            }
            
            //Inserting all the respective records
            if(!categoriesToBeInsertedList.isEmpty()){
               insert categoriesToBeInsertedList;
            }
            
            if(!specsToBeInsertedList.isEmpty()){
               insert specsToBeInsertedList;
            }
            
            if(!translationsToBeInsertedList.isEmpty()){
               insert translationsToBeInsertedList;
            }
            system.debug('resToBeInsertedList'+resToBeInsertedList);
            if(!resToBeInsertedList.isEmpty()){
               insert resToBeInsertedList;
               system.debug('resToBeInsertedList'+resToBeInsertedList); 
            }
            
            //Deleting the old records from published Version
            if(!catDeletionList.isEmpty()){
                delete catDeletionList;
            }
            
            if(!SpecDeletionList.isEmpty()){
                delete SpecDeletionList;
            }
            
            if(!transDeletionList.isEmpty()){
                delete transDeletionList;
            }
            system.debug('ResDeletionList'+ResDeletionList);
            if(!ResDeletionList.isEmpty()){
                delete ResDeletionList;
            }
        
        }catch(exception e){
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            String[] sendingTo = new String[]{};
            sendingTo = PMP_Utility.getValue('Exception_Email').split(',');
            semail.setToAddresses(sendingTo);
            semail.setSubject('OfferingException');
            semail.setPlainTextBody('Message:'+e.getMessage()+' '+'Line Number:'+e.getLineNumber());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        }
        
     
    } 
    /**
    * @description Method to create Categories
    * @param List,set,map
    * @return List<PMP_Partner_Offering_Category__c>
    **/
    
    public static List<PMP_Partner_Offering_Category__c> createCategories(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
        List<PMP_Partner_Offering_Category__c> clonedOffCatList = new List<PMP_Partner_Offering_Category__c>();
        try{
            //Querying all the child records
            DescribeSObjectResult offCatFields = PMP_Partner_Offering_Category__c.getSObjectType().getDescribe();   
            List<String> catFieldNames = new List<String>( offCatFields.fields.getMap().keySet() );    
            String offCatQuery =    ' SELECT ' +     String.escapeSingleQuotes(String.join( catFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offCatFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds'; 
            List<PMP_Partner_Offering_Category__c> tempCatList = Database.query(offCatQuery);
            
            for(PMP_Partner_Offering_Category__c offCat:tempCatList){
                PMP_Partner_Offering_Category__c clonedOffCat = new PMP_Partner_Offering_Category__c();
                clonedOffCat = offCat.clone(false,false,true,true);
                for(PMP_Partner_Offering__c tempOff:offList){                                
                    if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offCat.PMP_Offering_Id__c)){ //Assigning offering Id as the newly created published offering
                      clonedOffCat.PMP_Offering_Id__c = tempOff.Id;
                    }  
                }
                //clonedOffCat.CreatedById = offCat.CreatedById;
                clonedOffCatList.add(clonedOffCat);
            }
            
        }catch(exception e){
            system.debug(e.getMessage());
           throw e;
        }
        return clonedOffCatList;  // Returning all the categories that needs to be inserted.
    }
    
    /**
    * @description Method to create Specifications
    * @param List,set,map
    * @return List<PMP_Partner_Offering_Specification__c>
    **/
    
    public static List<PMP_Partner_Offering_Specification__c> createSpecifications(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        List<PMP_Partner_Offering_Specification__c> clonedOffSpecList = new List<PMP_Partner_Offering_Specification__c>();
        try{
            //Querying all the child records
            DescribeSObjectResult offSpecFields = PMP_Partner_Offering_Specification__c.getSObjectType().getDescribe();   
            List<String> specFieldNames = new List<String>( offSpecFields.fields.getMap().keySet() );    
            String offSpecQuery =    ' SELECT ' +        String.escapeSingleQuotes(String.join( specFieldNames, ',' )) +    ' FROM ' +          String.escapeSingleQuotes(offSpecFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds';
            List<PMP_Partner_Offering_Specification__c> tempSpecList = Database.query(offSpecQuery);
                        
            for(PMP_Partner_Offering_Specification__c offSpec:tempSpecList){
                PMP_Partner_Offering_Specification__c clonedOffSpec = new PMP_Partner_Offering_Specification__c();
                clonedOffSpec = offSpec.clone(false,false,true,true);
                
                for(PMP_Partner_Offering__c tempOff:offList){
                   if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offSpec.PMP_Offering_Id__c)) //Assigning offering Id as the newly created published offering
                      clonedOffSpec.PMP_Offering_Id__c = tempOff.Id;
                }
                //clonedOffSpec.CreatedById = offSpec.CreatedById;
                clonedOffSpecList.add(clonedOffSpec);
            }
            
        }catch(exception e){
            system.debug(e.getMessage());
            throw e;
        }
        return clonedOffSpecList; // Returning all the Specifications that needs to be inserted.
    }
    
    /**
    * @description Method to create Translations
    * @param List,set,map
    * @return List<PMP_Partner_Offering_Translation__c>
    **/
    
    public static List<PMP_Partner_Offering_Translation__c> createTranslations(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        
        List<PMP_Partner_Offering_Translation__c> clonedOffTransList = new List<PMP_Partner_Offering_Translation__c>();
        try{
            //Querying all the child records
            DescribeSObjectResult offTransFields = PMP_Partner_Offering_Translation__c.getSObjectType().getDescribe();   
            List<String> transFieldNames = new List<String>( offTransFields.fields.getMap().keySet() );    
            String offTransQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( transFieldNames, ',' )) +' FROM ' + String.escapeSingleQuotes(offTransFields.getName()) + ' WHERE ' +         ' PMP_Partner_Offering_Id__c  IN : offIds';
            List<PMP_Partner_Offering_Translation__c> tempTransList = Database.query(offTransQuery);
            
            for(PMP_Partner_Offering_Translation__c offTrans:tempTransList){
                PMP_Partner_Offering_Translation__c clonedOffTrans = new PMP_Partner_Offering_Translation__c();
                clonedOffTrans = offTrans.clone(false,false,true,true);
                for(PMP_Partner_Offering__c tempOff:offList){                                
                    if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offTrans.PMP_Partner_Offering_Id__c))
                        clonedOffTrans.PMP_Partner_Offering_Id__c = tempOff.Id;  //Assigning offering Id as the newly created published offering
                }
                //clonedOffTrans.CreatedById = offTrans.CreatedById;
                clonedOffTransList.add(clonedOffTrans);
            }
            
            
            
            
        }catch(exception e){
            system.debug(e.getMessage());
            throw e;
        }
        return clonedOffTransList; // Returning all the Translations that needs to be inserted.
    }
    
    /**
    * @description Method to create Resources
    * @param List,set,map
    * @return List<PMP_Partner_Offering_Resource__c>
    **/
    
    public static List<PMP_Partner_Offering_Resource__c> createResources(List<PMP_Partner_Offering__c> offList,Set<Id> offIds,map<Id,Id> offIdsMap){
        //system.debug('###HeapLimit:->'+Limits.getHeapSize());
        List<PMP_Partner_Offering_Resource__c> clonedOffResList = new List<PMP_Partner_Offering_Resource__c>();
        try{
            //Querying all the child records
            DescribeSObjectResult offResFields = PMP_Partner_Offering_Resource__c.getSObjectType().getDescribe();   
            List<String> resFieldNames = new List<String>( offResFields.fields.getMap().keySet() );    
            String offResQuery =    ' SELECT ' +       String.escapeSingleQuotes(String.join( resFieldNames, ',' )) +    ' FROM ' +         String.escapeSingleQuotes(offResFields.getName()) +    ' WHERE ' +         ' PMP_Offering_Id__c  IN : offIds';
            List<PMP_Partner_Offering_Resource__c> tempResList = Database.query(offResQuery);
            
            Set<Id> resSet = new Set<Id>();
            Set<Id> newContentVersionSet = new Set<Id>();
            Map<string,Id> contentDocMap = new Map<string,Id>();
            List<ContentVersion> newContentList = new List<ContentVersion>();
            Map<Id,Id> newContentDocMap = new Map<Id,Id>();
            Map<Id,Id> contentDocOffResourceMap = New Map<Id,Id>();
            Map<Id,Id> OffResourceContentDocMap = New map<Id,Id>();
            
            for(PMP_Partner_Offering_Resource__c offResc:tempResList){  
                if(offResc.PMP_Resource_Type_Nm__c==PMP_StaticConstants_Offering.IMAGE || offResc.PMP_Resource_Type_Nm__c=='Thumbnail Image'){
                   resSet.add(offResc.PMP_Partner_Offering_Image__c);   //Adding all the ids of resources where type is Image
                   contentDocOffResourceMap.put((id) offResc.PMP_Partner_Offering_Image__c, offResc.Id);
                   OffResourceContentDocMap.put(offResc.Id, (id) offResc.PMP_Partner_Offering_Image__c);
                }
            }
            system.debug('resSet'+resSet);
            
            //Querying Content Versions from Above Set
               
            List<ContentVersion>  contentList=[SELECT Id, ContentDocumentId,Title, IsLatest, PathOnClient,FirstPublishLocationId, Description, RatingCount, VersionData, FileExtension 
            FROM ContentVersion where ContentDocumentId IN: resSet AND IsLatest=true];
            system.debug('contentList'+contentList);
                
            if(!contentList.isEmpty()){
                for(ContentVersion cv:contentList){
                    ContentVersion newContent = new ContentVersion();
                    newContent.Title  = cv.Title+'_'+ string.valueOf(contentDocOffResourceMap.get(cv.ContentDocumentId));
                    newContent.PathOnClient  = cv.PathOnClient;
                    newContent.VersionData = cv.VersionData; 
                   // string blobToStr = EncodingUtil.base64Encode(cv.VersionData);                    
                    //contentDocMap.put(blobToStr+cv.Title,cv.ContentDocumentId);    
                    //contentDocMap.put(cv.Title,cv.ContentDocumentId);
                    system.debug('content old'+cv.ContentDocumentId);               
                    newContentList.add(newContent);
                }
            }
            /** Clearing Content List to reduce heap size**/
            contentList.clear();
            /** Clearing Content List to reduce heap size**/
            system.debug('###HeapLimit:->'+Limits.getHeapSize());
            system.debug('newContentList'+newContentList);    
            if(!newContentList.isEmpty()){
                insert newContentList;  // Creating New Content version
                
                for(ContentVersion cv:newContentList){
                    newContentVersionSet.add(cv.Id); //Adding all the new Ids in set to query newly created records as we need to get content document for newly created content versions
                    system.debug('content new'+cv.ContentDocumentId);
                }
                /** Clearing Content List to reduce heap size**/
                newContentList.clear();
                /** Clearing Content List to reduce heap size**/
                system.debug('###HeapLimit:->'+Limits.getHeapSize());
                List<ContentVersion>  newConVersionList=[SELECT Id, Title, ContentDocumentId,VersionData FROM ContentVersion where Id IN: newContentVersionSet AND IsLatest=true];
                system.debug('newConVersionList'+newConVersionList);
                if(!newConVersionList.isEmpty()){
                    for(ContentVersion cv:newConVersionList){
                        //system.debug('content newest'+cv.ContentDocumentId);
                        //string blobTostr = EncodingUtil.base64Encode(cv.VersionData);
                       // newContentDocMap.put(contentDocMap.get(blobTostr+cv.Title),cv.ContentDocumentId); //Storing all the content document ids
                        //newContentDocMap.put(contentDocMap.get(cv.Title),cv.ContentDocumentId);
                        newContentDocMap.put( string.valueOf(OffResourceContentDocMap.get(cv.Title.substringAfterLast('_'))), cv.ContentDocumentId );
                    }
                    system.debug('newContentDocMap'+newContentDocMap);
                }
                /** Clearing Content List to reduce heap size**/
                newConVersionList.clear();
                /** Clearing Content List to reduce heap size**/
            }
            system.debug('###HeapLimit:->'+Limits.getHeapSize());
            system.debug('newContentDocMap'+newContentDocMap);       
            for(PMP_Partner_Offering_Resource__c offResc:tempResList){
                PMP_Partner_Offering_Resource__c clonedOffResc = new PMP_Partner_Offering_Resource__c();
                clonedOffResc = offResc.clone(false,false,true,true);
                for(PMP_Partner_Offering__c tempOff:offList){
                    if(tempOff.PMP_Working_Copy_Id__c==offIdsMap.get(offResc.PMP_Offering_Id__c)){
                        system.debug('offIdsMap.get(offResc.PMP_Offering_Id__c)'+newContentDocMap);  
                        clonedOffResc.PMP_Offering_Id__c = tempOff.Id; 
                    }    
                }
                //clonedOffResc.CreatedById = offResc.CreatedById;
                system.debug('offResc.PMP_Partner_Offering_Image__c'+offResc.PMP_Partner_Offering_Image__c);
                system.debug('newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c)'+newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c));
                clonedOffResc.PMP_Partner_Offering_Image__c = newContentDocMap.get(offResc.PMP_Partner_Offering_Image__c); //Getting the value of new content document Id
                clonedOffResList.add(clonedOffResc);
            }
        
            system.debug('###HeapLimit:->'+Limits.getHeapSize());            
            
            
        }catch(exception e){
            system.debug(e.getMessage()+e.getLinenumber());
            throw e;
        }
        system.debug('clonedOffResList'+clonedOffResList);
        return clonedOffResList; // Returning all the Translations that needs to be inserted.
    }
    


/**
* @description Method to update working copy post publishing the offering
* @param List<PMP_Partner_Offering__c>
* @return void 
**/
    public static void updateWorkingCopyPostPublished(List<PMP_Partner_Offering__c> offList){

        try{
            List<PMP_Partner_Offering__c> currentOfferingList = new List<PMP_Partner_Offering__c>();
            if(!offList.isEmpty()) {            
                for(PMP_Partner_Offering__c off:offList) {                
                    PMP_Partner_Offering__c offering = new PMP_Partner_Offering__c(Id=off.Id);
                    //If working copy is published set the flag to true (only first time we need to set)
                   if(!off.PMP_Is_Published_Ind__c){
                        offering.PMP_Is_Published_Ind__c=true;
                   } 
                   //if the visibility is Intel only then change to public after publishing
                   if(off.PMP_Partner_Offering_Visibility_Nm__c==PMP_StaticConstants_MasterData.Intel_Only_Content) {
                        offering.PMP_Partner_Offering_Visibility_Nm__c=PMP_StaticConstants_MasterData.Public_Content;
                   }
 		   //if the Pre-release check is Yes or No,clear it post publish/republish
                   if(off.PMP_Pre_Release_Check_Nm__c==PMP_StaticConstants_MasterData.Yes||off.PMP_Pre_Release_Check_Nm__c==PMP_StaticConstants_MasterData.No) {
                        offering.PMP_Pre_Release_Check_Nm__c='';
                   }

                    currentOfferingList.add(offering);
                }
                if(!currentOfferingList.isEmpty()){
                    update currentOfferingList;
                }
            }
        }
            
        catch(exception e){
            system.debug(e.getMessage());
            throw e;
        }
    }
    
    /**
    * @description sync featured indicator from working copy to published copy
    * @param Map
    * @return Void
    **/
    
    public static void syncFeaturedOffering(Map<Id,Boolean> featuredOfferingMap){
        try{
            system.debug('---------------Inside syncFeaturedOffering--------------');
            List<PMP_Partner_Offering__c> featuredOfferingList = new List<PMP_Partner_Offering__c>();
            
            if(!featuredOfferingMap.isEmpty()){
               for(PMP_Partner_Offering__c off: [select id,PMP_Featured_Offering_Ind__c,PMP_Working_Copy_Id__c from PMP_Partner_Offering__c where PMP_Working_Copy_Id__c IN:featuredOfferingMap.keyset()]){
                   off.PMP_Featured_Offering_Ind__c = featuredOfferingMap.get(off.PMP_Working_Copy_Id__c);  
                   featuredOfferingList.add(off);
               }
            }
            
            if(featuredOfferingList.size()>0){
                update featuredOfferingList;  // Update offering
            }
            
        }catch(exception e){
            system.debug(e.getMessage() +e.getLinenumber());
            throw e;
        }
    }
     
     /**
* @description To Set Is Notified indicator to True, either Lifecycle stauts changed to approved or PreReleasecount changed to 0.
*              When Is Notified is set to True, we are Using the same To send email to the POE To Change the Start Date.
* @Object PMP_Partner_Offering__c
* @param trigger.new List, Old Map
* @return Void
* @UserStory US605790,US605797
**/
    
    public static void isNotifiedToTrue(List<PMP_Partner_Offering__c> offList,map<Id,PMP_Partner_Offering__c> oldMap){
              
        for(PMP_Partner_Offering__c off:offList){ //iterate through offering List which has Trigger.New
            
            if((oldMap.get(off.Id).PMP_Partner_Offering_Lifecycle_Status_Nm__c != PMP_StaticConstants_MasterData.Approved // either
                && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved)          // Old LifeCycle Status not Equals to Approved and New LifeCycleStatus Equals to Approved
               ||                                                                                                       // OR   
               (oldMap.get(off.Id).PMP_Pre_Release_Item_Count_Num__c !=PMP_StaticConstants_MasterData.Zero              
                &&off.PMP_Pre_Release_Item_Count_Num__c==PMP_StaticConstants_MasterData.Zero)                           // Old PreRelease Item Count NotEquals to 0 and New PreRelease Item Count Equals to 0
                   ){   
                       /* even when an offering with one of the above changes enters the Condition
                           Is Notified is Set to True Only when an Offering has LifeCycleStatus Equals to Approved 
                           and PreRelease Item Count Equals to 0, so Checking for both in below if*/
                       
                   if (off.PMP_Pre_Release_Check_Nm__c == PMP_StaticConstants_MasterData.No                             // PreRelease Check NO scenario
                       && off.PMP_Partner_Offering_Lifecycle_Status_Nm__c == PMP_StaticConstants_MasterData.Approved    // LifeCycleStatus Equals to Approved
                       && off.PMP_Pre_Release_Item_Count_Num__c == PMP_StaticConstants_MasterData.Zero)                 // New PreRelease Item Count Equals to 0
                   {    
                    off.PMP_Is_Notified_Ind__c = true; // Setting IsNotified to True,
                    
                   }
                   
               }           
        }
        
    }
/**
* @description This method will be used to clear cache when published offering is updated after 
*              the edited working copy is approved.
* 
* @param List of PMP_Partner_Offering__c 
* @return Void
* @UserStory US678629
**/
    public static void clearPlatformCache(List <PMP_Partner_Offering__c> offeringList){
        String partitionInput = PMP_Utility.getValue('Org_Cache_Partition');
       /* cache will be different for different languages. Ex- For english language user - [offeringId+'en']
        to dynamically create the key, we need to get the different langauges in which offering can be translated hence we are using the metadata */
        
        List<PMP_Locale_To_FieldAPINm_Mapping__mdt> localeMetadata = [Select PMP_Locale_Nm__c from PMP_Locale_To_FieldAPINm_Mapping__mdt
                                                                Where PMP_Object_Nm__c = 'Offering_Translation'];
        
        //iteratre over the published offerings and check clear cache related to the offering.
        for ( PMP_Partner_Offering__c offering : offeringList ){
            
            for(PMP_Locale_To_FieldAPINm_Mapping__mdt meta : localeMetadata){
                string key;
                if(meta.PMP_Locale_Nm__c == 'ja_JP'){
                    key = offering.id + 'ja';
                }
                else{
                    key = offering.id + meta.PMP_Locale_Nm__c.replace('_', '');
                }
               
                
                if(Cache.Org.contains(partitionInput+'.'+ key)){
                    Cache.Org.remove(partitionInput+'.'+key);
                    
                }
            }
        }
    }  

}