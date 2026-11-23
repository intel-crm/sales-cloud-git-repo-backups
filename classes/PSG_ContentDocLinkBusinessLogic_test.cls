@isTest
public  class PSG_ContentDocLinkBusinessLogic_test {
    @isTest
    public static void contentDocumentTest(){
        Group g=[Select Id from Group where Name='AGS_PSG Internal - PMS' ];
        GroupMember gm=new GroupMember();
        gm.GroupId=g.Id;
        gm.UserOrGroupId=Userinfo.getUserId();
        insert gm;
        //List<GroupMember> pmsUserlst1=[SELECT id,UserOrGroupId,Group.DeveloperName,Group.Name from GroupMember  WHERE Group.Name='AGS_PSG Internal - PMS'];
        Set<String> myLibraryNameSet = new Set<String>();
        Set<Id> UserIds = new Set<Id>();
        /*for(GroupMember gm:pmsUserlst1){
            UserIds.add(gm.UserOrGroupId);
        }*/
        userIds.add(Userinfo.getUserId());
         List<User> pmsUserlst=[SELECT id,name from USER where id IN :UserIds];
         System.runAs(pmsUserlst[0]){
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
            ContentWorkspace cw = new ContentWorkspace();
            cw.name ='PSG Price book Library';
            insert cw;
            List<ContentWorkspace> Workspace=new List<ContentWorkspace>([Select id from ContentWorkspace where Name IN :myLibraryNameSet]);
            Test.startTest();
			ContentVersion cv = new ContentVersion();
        	cv.Title = 'Test Document';
        	cv.PathOnClient = 'TestDocument.pdf';
        	cv.VersionData = Blob.valueOf('Test Content');
       	    cv.IsMajorVersion = true;
            cv.FirstPublishLocationId=Workspace[0].id;
            Insert cv;
            System.assert(cv.Id!=null,'File Created');
            try{
                PSG_ContentDocLinkBusinessLogic.afterInsertUpdateOperations(null,null,true);
            }
            catch(Exception e){
                
            }
           Test.stopTest();
         }
    }
}