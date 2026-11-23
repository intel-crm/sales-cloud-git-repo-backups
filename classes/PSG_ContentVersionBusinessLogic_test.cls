@isTest
public  class PSG_ContentVersionBusinessLogic_test {
    @isTest
    public static void contentDocumentTest(){
       // List<User> pmsUserlst = [SELECT id,name from USER where name like '%PMS%'];//to be covered as part of post deployment step
        /*List<GroupMember> pmsUserlst1=[SELECT id,UserOrGroupId,Group.DeveloperName,Group.Name from GroupMember  WHERE Group.Name='AGS_PSG Internal - PMS'];
        Set<String> myLibraryNameSet = new Set<String>();
        Set<Id> UserIds = new Set<Id>();
        for(GroupMember gm:pmsUserlst1){
            UserIds.add(gm.UserOrGroupId);
        }
         List<User> pmsUserlst=[SELECT id,name from USER where id IN :UserIds];
        
        System.runAs(pmsUserlst[0]){
            //ContentWorkspace cw=new ContentWorkspace();
            //String libName=Label.PSG_Lib_test;
            //cw.Name=libName;
            //insert cw; 
            
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
           
        	ContentVersion cv = new ContentVersion();
        	cv.Title = 'Test Document';
        	cv.PathOnClient = 'TestDocument.pdf';
        	cv.VersionData = Blob.valueOf('Test Content');
       	    cv.IsMajorVersion = true;
            cv.FirstPublishLocationId=Workspace[0].id;
            Insert cv;
            System.assert(cv.Id!=null,'File Created');
            try{
                PSG_ContentVersionBusinessLogic.afterInsertUpdateOperationsNew(null,null,true);
            }
            catch(Exception e){
                
            }
            
        }*/
    }

}