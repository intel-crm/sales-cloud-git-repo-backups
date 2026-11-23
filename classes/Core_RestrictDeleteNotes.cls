/**************************************************************************************
Apex Class Name:  Core_RestrictDeleteNotes
Version     : 1.0 
Created Date: 10/07/21
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------   

* Sanket Mahajan              10/07/21                Initial Revision
/**************************************************************************************/

public class Core_RestrictDeleteNotes {
    
    /****************************************************************************************************** 
Method Name:        restrictDeleteOppNotes
@return  :          void
@parameters:        List<ContentDocument>
Description:        This method is used to restrict the deletion of Notes & attachment
*******************************************************************************************************/
    public static void restrictDeleteOppNotes(List<ContentDocument> newContentFiles){
        for(ContentDocument cd : newContentFiles){
            system.debug('newContentFiles>'+newContentFiles);
            List<ContentDocumentLink> cdl = [select id,LinkedEntityId from ContentDocumentLink where ContentDocumentId =: cd.id];
            system.debug('cdl->'+cdl);
            List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            String MyProflieName = PROFILE[0].Name;
            List<String> profilesToRestrictFileDelete = (System.Label.Core_restrictProfilesOnNotesDelete).split(';');
            for(ContentDocumentLink cdl1 :cdl){
                String objId = cdl1.LinkedEntityId;
                system.debug('objId->'+objId);
                if(objId.startsWith('006')){
                    system.debug('inside only for Opp');
                    if(profilesToRestrictFileDelete.contains(MyProflieName)){
                        // cd.addError(System.Label.Core_restrictProfilesOnNotesDeleteErrMsg);
                        
                    }
                }
            }
        }
        
        
    }
}