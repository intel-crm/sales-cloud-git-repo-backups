public class ContentlinkBusinessLogic {
       public static void afterInsertUpdateOperations(List<ContentDocumentLink> cvList,Map<Id,ContentDocumentLink> oldMap,Boolean isInsert){
           List<ContentDistribution> cdListToInsert = new List<ContentDistribution>();  
			system.debug('Am i in::'+cvlist);
          // if(isInsert){
           Set<Id> docId=new Set<Id>();
           for(ContentDocumentLink cv : cvList){
               docId.add(cv.contentDocumentId);
            }
           Set<Id> docId1=new Set<Id>();
            for(ContentDocumentLink cdl :[SELECT LinkedEntity.Name, Id,  ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =: docId]){
           // mapdopc.put(cdl.ContentDocumentId,cdl.LinkedEntity.Name);
           system.debug('Am i in::'+cdl);
                if( cdl.LinkedEntity.Name == 'PSG Price book library'){
                  docId1.add(cdl.contentDocumentId);                  
              }
            }
         
         for(ContentVersion cv :[Select Id,Title,isLatest, contentDocumentId From ContentVersion where contentDocumentId =: docId1]){
             system.debug('Am i in::'+cv);
             cdListToInsert.add(new ContentDistribution(
                      ContentVersionId = cv.Id,
                      Name = cv.Title
                  ));
         }
            
      	if(!cdListToInsert.IsEmpty()){
          insert cdListToInsert; 
        // Database.insert(cdListToInsert,false);
            system.debug('cdListToInsert'+cdListToInsert);
            ContentDistribution cd = [SELECT ID , ContentDocumentId FROM ContentDistribution WHERE Id =:cdListToInsert[0].Id limit 1];
                        system.debug('cd'+cd);

      	}
     // }     
   /*
        if(isInsert){

           
            Set<Id> docId=new Set<Id>();
            for(ContentVersion cv : cvList){
               docId.add(cv.contentDocumentId);
            }
            Map<id,string> mapdopc=new Map<id,string>();
            for(ContentDocumentLink cdl :[SELECT LinkedEntity.Name, Id,  ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId =:docId]){
            mapdopc.put(cdl.ContentDocumentId,cdl.LinkedEntity.Name);
            }
            for(ContentVersion cv : cvList){
            if(mapdopc.get(cv.ContentDocumentId) == 'PSG Price book library'){
            cdListToInsert.add(new ContentDistribution(
            ContentVersionId = cv.Id,
            Name = cv.Title
            ));
            }
            }
            if(!cdListToInsert.IsEmpty()){
            // insert cdListToInsert;
            Database.insert(cdListToInsert,false);
            }
            
            
            }*/
    }
}