/**************************************************************************************
Apex Class Name : PMP_CategoryDataUpdateOnOfferings
Version     : 1.0 
Created Date: 30th Aug, 2019
Description : Batch class to update category data on all the offerings
* Modification Log :
* Developer                 Date                     Description
* ----------------------------------------------------------------------------
* Manasa                  30/08/2019               Original Version
*************************************************************************************/
global class PMP_CategoryDataUpdateOnOfferings implements Database.Batchable<sObject> {
	//Start method
	global Database.QueryLocator start(Database.BatchableContext BC) {
        //Below commented lines are for testing
        //Id offId = 'a3s0n000000Acsf';
        String query = 'select id, Name,PMP_Category_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Nm__c,PMP_Sub_Category_nm__c,PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Source_Id__c from PMP_Partner_Offering__c where PMP_Partner_Offering_Source_Id__c <> NULL';
        //String query = 'select id, Name,PMP_Category_nm__c,PMP_Offering_Language_Nm__c,PMP_Partner_Offering_Nm__c,PMP_Sub_Category_nm__c,PMP_Business_Segment_Nm__c,PMP_Partner_Offering_Source_Id__c from PMP_Partner_Offering__c where id=:offId';
        return Database.getQueryLocator(query);
	}
    //Exceute - Method
    global void execute(Database.BatchableContext BC,List<PMP_Partner_Offering__c> offList) {
        Set<id> idSet = new Set<id>();   
        List<PMP_Partner_Offering__c> updateOfferingList = new List<PMP_Partner_Offering__c>();
        for(PMP_Partner_Offering__c offering : offList){
            idSet.add(offering.Id);
		    updateOfferingList = getCategoryAndTranslationData(offering.Id,idSet);
        }
        System.debug('updateOfferingList**'+updateOfferingList);
        update updateOfferingList;
    }
    global void finish(Database.BatchableContext BC) {   
            //Get the job Id 
            Id job= bc.getJobId();
            System.debug(job);        
    }   
    public List<PMP_Partner_Offering__c> getCategoryAndTranslationData(Id offeringId, Set<id> idSet){
      
        List<PMP_Partner_Offering_Category__c> offCategoryList = new List<PMP_Partner_Offering_Category__c>();
        Map<id,String> offeringCategoryMap = new Map<id,String>();
        Map<id,String> offeringSubCategoryMap = new Map<id,String>();
        Map<id,String> offeringBusinessSegMap = new Map<id,String>();
        List<PMP_Partner_Offering__c> offList = new List<PMP_Partner_Offering__c>();
        List<PMP_Partner_Offering_Translation__c> offTranslationList = PMP_Utility.getOfferingTranslationRecords(offeringId); 
        String inputLanguage;
        PMP_Partner_Offering__c offObj = new PMP_Partner_Offering__c();
        for(PMP_Partner_Offering_Category__c offCategory : [select id,Name,
                                                            PMP_Ancestor_Category_Cd__c,PMP_Category_Id__c,PMP_Offering_Id__r.id,
                                                            PMP_Category_Id__r.Name,PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c,
                                                            PMP_Category_Id__r.Type__c,PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c,
                                                            PMP_Localized_Category_Nm__c,PMP_Offering_Id__c,PMP_Offering_Category_External_Key__c,
                                                            PMP_Category_Id__r.PMP_Business_Segment_Nm__c,PMP_Offering_Id__r.PMP_Category_nm__c,
                                                            PMP_Offering_Id__r.PMP_Offering_Language_Nm__c,PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c,
                                                            PMP_Offering_Id__r.PMP_Sub_Category_nm__c,PMP_Offering_Id__r.PMP_Business_Segment_Nm__c,
                                                            PMP_Offering_Id__r.PMP_Translation_Lifecycle_Status_nm__c,PMP_Offering_Id__r.PMP_Translated_Languages__c
                                                            from PMP_Partner_Offering_Category__c where PMP_Offering_Id__c=:offeringId]){
                  System.debug('offCategory**'+offCategory);
               //get Category Name 
                    if((offCategory.PMP_Ancestor_Category_Cd__c !=null && offCategory.PMP_Ancestor_Category_Cd__c == 'NPP_01_TYPE') &&  (offCategory.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c !=null && offCategory.PMP_Category_Id__r.PMP_Partner_Product_Parent_Category_Cd__c == 'NPP_01_TYPE')){
                       offeringCategoryMap.put(offCategory.PMP_Offering_Id__r.id,offCategory.PMP_Category_Id__r.Name);
                       inputLanguage = offCategory.PMP_Offering_Id__r.PMP_Offering_Language_Nm__c;                  
                    }  
               //get Sub Category Name 
               //get Business segment name
                if(offCategory.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c !=null && offCategory.PMP_Category_Id__r.Type__c !=null){
                    if(offCategory.PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c.countMatches('|')==1 && offCategory.PMP_Category_Id__r.Type__c == 'Category'){
                	   offeringSubCategoryMap.put(offCategory.PMP_Offering_Id__r.id,offCategory.PMP_Category_Id__r.Name);
                       offeringBusinessSegMap.put(offCategory.PMP_Offering_Id__r.id,offCategory.PMP_Category_Id__r.PMP_Business_Segment_Nm__c);               
                    }  
                }                                                 
            
        }
        
        System.debug('offeringCategoryMap**'+offeringCategoryMap);
        System.debug('offeringSubCategoryMap**'+offeringSubCategoryMap);
        System.debug('offeringBusinessSegMap**'+offeringBusinessSegMap);
        System.debug('offTranslationList**'+offTranslationList);
        for(id idIter : idSet){
                offTranslationList = PMP_Utility.getOfferingTranslationRecords(idIter);
                offObj = new PMP_Partner_Offering__c();
                offObj.id = idIter;
                if(offeringCategoryMap.get(idIter) !=null){
                  offObj.PMP_Category_nm__c = offeringCategoryMap.get(idIter);           
                }
                if(offeringSubCategoryMap.get(idIter) !=null){
                    offObj.PMP_Sub_Category_nm__c = offeringSubCategoryMap.get(idIter);  
                }
                if(offeringBusinessSegMap.get(idIter) !=null){
                    offObj.PMP_Business_Segment_Nm__c = offeringBusinessSegMap.get(idIter);
                }
            }
        for(PMP_Partner_Offering_Translation__c offTrans: offTranslationList){
                    if(offTrans.PMP_Field_Nm__c == 'PMP_Partner_Offering_Nm__c'){
                      if(offObj.PMP_Business_Segment_Nm__c != null && !(offObj.PMP_Business_Segment_Nm__c.contains('IoT'))){
                        offObj.PMP_Translation_Lifecycle_Status_nm__c = 'Not Applicable';
                        offObj.PMP_Translated_Languages__c = inputLanguage;
                       }
                        else if (offTrans.PMP_Chinese_Txt__c !=null && offTrans.PMP_English_Txt__c !=null && offTrans.PMP_Japanese_Txt__c !=null){
                        offObj.PMP_Translation_Lifecycle_Status_nm__c = 'Complete';
                        offObj.PMP_Translated_Languages__c = 'English' + ';' + 'Simplified Chinese' + ';'+ 'Japanese';
                       }
                        else if(offTrans.PMP_Chinese_Txt__c !=null && offTrans.PMP_English_Txt__c !=null && offTrans.PMP_Japanese_Txt__c ==null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c = 'English' + ';' + 'Simplified Chinese';
                       }
                       else if(offTrans.PMP_Chinese_Txt__c ==null && offTrans.PMP_English_Txt__c !=null && offTrans.PMP_Japanese_Txt__c !=null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c = 'English' + ';' + 'Japanese';
                       }
                        else if(offTrans.PMP_Chinese_Txt__c !=null && offTrans.PMP_English_Txt__c ==null && offTrans.PMP_Japanese_Txt__c !=null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c = 'Simplified Chinese' + ';' + 'Japanese';
                       }
                        else if(offTrans.PMP_Chinese_Txt__c ==null && offTrans.PMP_English_Txt__c ==null && offTrans.PMP_Japanese_Txt__c !=null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c =  'Japanese';
                       }
                        else if(offTrans.PMP_Chinese_Txt__c !=null && offTrans.PMP_English_Txt__c ==null && offTrans.PMP_Japanese_Txt__c ==null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c =  'Simplified Chinese';
                       }
                        else if(offTrans.PMP_Chinese_Txt__c ==null && offTrans.PMP_English_Txt__c !=null && offTrans.PMP_Japanese_Txt__c ==null){
                           offObj.PMP_Translation_Lifecycle_Status_nm__c = 'In Progress';
                           offObj.PMP_Translated_Languages__c =  'English';
                       }
                  }        
                }
        offList.add(offObj);
        System.debug('offList**'+offList);
        return offList;  
    }
    
}