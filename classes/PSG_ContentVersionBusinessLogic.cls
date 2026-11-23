public  class  PSG_ContentVersionBusinessLogic {
   
    // To create ContentDistribution when file is uploaded from owned by me/shared by me
    // Called from Core_ContentDocuemntLinkTriggerHandler
    public static void afterInsertUpdateOperationsNew(List<ContentDocumentLink> cdlList,Map<Id,ContentDocumentLink> oldMap,Boolean isInsert){
         /*try{
          //Set<Id> ContentVersion = new Set<Id>();
          Set<String> myLibraryNameSet = new Set<String>();
          String libraryName=Label.PSG_Library_Name;
            if(libraryName!=null){
                if(libraryName.contains(':')){
                    for(String name:libraryName.split(':')){
                        myLibraryNameSet.add(libraryName);
                    }
                }
                else{
                    myLibraryNameSet.add(libraryName);
                }
            }
            
          List<ContentWorkspace> Workspace=new List<ContentWorkspace>([Select id from ContentWorkspace where Name IN :myLibraryNameSet]);
          //List<ContentWorkspace> Workspace=new List<ContentWorkspace>([Select id from ContentWorkspace]);
          Set<Id> myLibraryIdSet = new Set<Id>();
          for(ContentWorkspace cw:Workspace){
                myLibraryIdSet.add(cw.Id);
            }
          //boolean haspermission= false;
          Set<Id> cvIds = new Set<Id>();
         for(ContentDocumentLink cdl : cdlList){
                  //System.debug('Inside insert +++++'+cv.FirstPublishLocationId);
                  for(Id cwId:myLibraryIdSet){
                      if(cdl.LinkedEntityId==cwId){
                        cvIds.add(cdl.ContentDocumentId);
                  }
                }
            }
          //Map<Id, ContentVersion> docVersions = new Map<Id, ContentVersion>([SELECT contentDocumentId, firstPublishLocationId, Id
                                                     // FROM ContentVersion
                                                      //WHERE contentDocumentId IN : cvIds ]); 
          
        
            
          List<ContentDistribution> cdListToInsert = new List<ContentDistribution>();
          /*Set<Id> librarymemSet= new Set<Id>();
          
            
          List<ContentWorkspaceMember> librarymems= new List <ContentWorkspaceMember>([SELECT Id,ContentWorkspaceId, ContentWorkspace.Name, ContentWorkspacePermission.Name, MemberId, MemberType FROM ContentWorkspaceMember WHERE ContentWorkspaceId=:Workspace.Id ]);
            for(ContentWorkspaceMember cm: librarymems){
                if(cm.MemberType=='G'){
                    librarymemSet.add(cm.MemberId);
                }
    
            }
            List<GroupMember> gm=new List<GroupMember>([select UserOrGroupId,groupid,Group.Name,group.DeveloperName from GroupMember where UserOrGroupId =: UserInfo.getUserId() AND groupid IN :librarymemSet]);
            system.debug('ANS@@'+gm.size());
            if(!gm.isEmpty()){
                haspermission=true;
            }*/
            
          
          
         // Boolean hasCustomPermission = FeatureManagement.checkPermission('PSG_Internal_PMS');
         
            
          
         /*if(isInsert){
            for(ContentVersion cv : [SELECT Id,contentDocumentId, firstPublishLocationId,Title FROM ContentVersion WHERE contentDocumentId IN : cvIds]){
                  
                  //for(Id cwId:myLibraryIdSet){
                      //if(cv.FirstPublishLocationId==cwId){
                        cdListToInsert.add(new ContentDistribution(
                        ContentVersionId = cv.Id,
                        Name = cv.Title
                  ));
                  //}
                //}
            }
            if(!cdListToInsert.IsEmpty()){
             // insert cdListToInsert; 
                Database.insert(cdListToInsert,false);
            }
          }   
         
   }
         catch(Exception ex){
              PSG_Utility.logError(ex);
          }*/
    }
    


}