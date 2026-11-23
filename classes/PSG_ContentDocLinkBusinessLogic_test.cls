@isTest
public  class PSG_ContentDocLinkBusinessLogic_test {
    /*
    @isTest
    public static void contentDocumentTest(){
        Group g=[Select Id from Group where Name='AGS_PSG Internal - PMS' ];
        GroupMember gm=new GroupMember();
        gm.GroupId=g.Id;
        gm.UserOrGroupId=Userinfo.getUserId(); 
        insert gm;
        Set<String> myLibraryNameSet = new Set<String>();
        Set<Id> UserIds = new Set<Id>();
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
            List<ContentWorkspace> Workspace=new List<ContentWorkspace>([Select id from ContentWorkspace where Name =: Label.PSG_Library_Name]);
            Test.startTest();
            List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            cv.FirstPublishLocationId=Workspace[0].id;
            Insert cv;
            System.assert(cv.Id != null, 'CV created');
            try{
                //PSG_ContentDocLinkBusinessLogic.afterInsertUpdateOperations(null, null, true);
            }catch(Exception e){}
            Test.stopTest();
        }
    }
    */
}