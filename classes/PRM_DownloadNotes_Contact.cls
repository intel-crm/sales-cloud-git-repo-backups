public with sharing class PRM_DownloadNotes_Contact {
 
  @AuraEnabled (cacheable=true)
  public static List<notesWrapper> getNotes() {
      string size;
      string icon;
      string logEntry;
      list<notesWrapper> notesList = new list<notesWrapper>();
      map<id, ContentDocumentLink> ContentDocumentIdMap = new  map<id, ContentDocumentLink>();
      map<id, string> mapOfDownloadURL = new map<id, string>();
      map<string, string> mapOfIconBasedOnFileType = new map<string, string>{'EXCEL' => 'doctype:excel', 'CSV' => 'doctype:csv'};
      list<string> listOfFilesTypesToDownload = new list<string>{'CSV', 'EXCEL'};

      User loggedInUser = [SELECT ContactId FROM User WHERE id =: UserInfo.getUserId()];
      Contact cont = [SELECT id, Name, AccountId FROM Contact WHERE Id =: loggedInUser.ContactId];

      if(cont.id != null){
          for(ContentDocumentLink cd : [SELECT id,visibility, ContentDocument.Title,ContentDocument.LastModifiedDate ,ContentDocument.CreatedBy.name, ContentDocument.ContentSize, ContentDocument.LatestPublishedVersionId, ContentDocument.FileType 
                                      FROM ContentDocumentLink 
                                      WHERE LinkedEntityId =: cont.id 
                                      AND ContentDocument.FileType IN: listOfFilesTypesToDownload                                      
                                      ORDER BY ContentDocument.LastModifiedDate desc]
          ){
              ContentDocumentIdMap.put(cd.ContentDocument.id,cd);
          }
      }

      if(!ContentDocumentIdMap.isEmpty()){
       for(ContentDistribution cds:[SELECT Id, Name, ContentDownloadUrl, ContentDocumentId
                                  FROM ContentDistribution
                                  WHERE ContentDocumentId =: ContentDocumentIdMap.keySet()]
          ){
              mapOfDownloadURL.put(cds.ContentDocumentId,cds.ContentDownloadUrl);
      }

      for(Id contentIds: ContentDocumentIdMap.keySet()){
          size = convertSize(ContentDocumentIdMap.get(contentIds).ContentDocument.contentSize);
          icon = mapOfIconBasedOnFileType.containsKey(ContentDocumentIdMap.get(contentIds).ContentDocument.FileType) ? mapOfIconBasedOnFileType.get(ContentDocumentIdMap.get(contentIds).ContentDocument.FileType) : 'doctype:attachment';
          notesWrapper nw = new notesWrapper( ContentDocumentIdMap.get(contentIds).ContentDocument.Id, ContentDocumentIdMap.get(contentIds).ContentDocument.Title, ContentDocumentIdMap.get(contentIds).ContentDocument.CreatedBy.name, 
                                              ContentDocumentIdMap.get(contentIds).ContentDocument.LastModifiedDate, size, mapOfDownloadURL.get(contentIds), icon);
          notesList.add(nw);
      }
  }
  system.debug('notesList-->'+ notesList);
  return notesList;    
  }

  public static string convertSize(Integer contentSize){
      string size;
      // Decimal contentSize = Decimal.valueOf(contentSize1);
      // if(contentSize >= 1000 && contentSize < 1000000){
      //     size = string.valueOf((contentSize/1024).setscale(1)) + 'KB';
      // }
      // else if(contentSize>=1000000 && contentSize<1000000000){
      //     size = string.valueOf((contentSize/(1024*1000)).setscale(1)) + 'MB';
      // }
      // else if(contentSize>1000000000){
      //     size = string.valueOf((contentSize/1024).setscale(1)) + 'GB';
      // }
      Decimal roundNumber=0;
      roundNumber = contentSize;
      system.debug('contentSize-->'+contentSize);
      if (contentSize < 1024)
            return string.valueOf(contentSize) + ' Bytes';
          else
          if (contentSize >= 1024 && contentSize < (1024*1024))
          {
            //KB
            Decimal kb = Decimal.valueOf(contentSize);
            kb = math.round(kb.divide(1024,2));
            return string.valueOf(kb) + ' KB';
          }
          else
          if (contentSize >= (1024*1024) && contentSize < (1024*1024*1024))
          {
            //MB
            Decimal mb = Decimal.valueOf(contentSize);
            mb = mb.divide((1024*1024),2);
            system.debug('mb-->'+mb);
         //   roundNumber=mb.setScale(1, RoundingMode.HALF_UP);
        
            return string.valueOf(mb.setScale(1)) + ' MB';
           
          }
          else
          {
            //GB
            Decimal gb = Decimal.valueOf(contentSize);
            gb = gb.divide((1024*1024*1024),2);
           
            return string.valueOf(gb.setScale(1)) + ' GB';
          }    
    //  return size;
  }

  public with sharing class notesWrapper {
      @AuraEnabled public string title {get;set;}
      @AuraEnabled public string createdBy {get;set;}
      @AuraEnabled public Datetime lastModified {get;set;}
      @AuraEnabled public String size {get;set;}
      @AuraEnabled public String downloadAttachment {get;set;}
      @AuraEnabled public String iconType {get;set;}
      @AuraEnabled public String recordId {get;set;}

      public notesWrapper(Id rId, String name, String createdByName, Datetime lastModifiedByName, String fileSize, string downloadURL, string type){
          recordId = rId;
          title = name;
          createdBy = createdByName ;
          lastModified = lastModifiedByName ;
          size = fileSize;
          downloadAttachment = downloadURL;
          iconType = type;
      }
  } 
}