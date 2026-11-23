public with sharing class Core_Notes_Attachments_Ctrl {

    @auraEnabled
    public static Account fetchAccountDetails(String recordId){
        return [select Id, Name from Account where Id =: recordId];
    }
    
    @auraEnabled
    public static List<Core_Note_Att_Wrapper> getAllNotesAttachments(String recordId){
        List<Core_Note_Att_Wrapper> noteAttWrapperList = new List<Core_Note_Att_Wrapper>();
        Set<String> userRoleSet = new Set<String>();
        Boolean isValidRecord = false;
        Core_Notes_Attachments_Access_Profiles__c ntAttProfileAccess = Core_Notes_Attachments_Access_Profiles__c.getInstance(UserInfo.getUserId());
        if(ntAttProfileAccess.Id <> null){
            isValidRecord = ntAttProfileAccess.Core_is_Access__c;
        }
        
        if(!isValidRecord){
            ntAttProfileAccess = Core_Notes_Attachments_Access_Profiles__c.getInstance(UserInfo.getProfileId());
            if(ntAttProfileAccess.Id <> null){
                isValidRecord = ntAttProfileAccess.Core_is_Access__c;
            }
        }
        
        if(!isValidRecord){
            Account accRec = [select Id, OwnerId, Owner.UserRoleId from Account where Id =: recordId];
            if(accRec.OwnerId == UserInfo.getUserId()){
                isValidRecord = true;
            }else{
                List<AccountTeamMember> accTeamMemberList = [select Id, UserId, User.UserRoleId from AccountTeamMember where AccountId =: accRec.Id];
                if(!accTeamMemberList.isEmpty()){
                    for(AccountTeamMember accTeam : accTeamMemberList){
                        if(accTeam.UserId == UserInfo.getUserId()){
                            isValidRecord = true;
                        }
                        userRoleSet.add(accTeam.User.UserRoleId);
                    }
                }
                if(!isValidRecord){
                    userRoleSet.add(accRec.Owner.UserRoleId);
                }
            }
        }
        
        if(!isValidRecord){
            isValidRecord = isValidRole(UserInfo.getUserRoleId(), userRoleSet);
        }
        
        return fetchNotesAttachments(isValidRecord, recordId, noteAttWrapperList);
    }
    
    public static List<Core_Note_Att_Wrapper> fetchNotesAttachments(Boolean isValidRecord, String recordId, List<Core_Note_Att_Wrapper> noteAttWrapperList){
        Map<DateTime, Core_Note_Att_Wrapper> noteAttWrapperMap = new Map<DateTime, Core_Note_Att_Wrapper>();
        List<Note> noteList = new List<Note>();
        List<Attachment> attList = new List<Attachment>();
        List<ContentNote> contNoteList = new List<ContentNote>();
        List<ContentVersion> ContDocList = new List<ContentVersion>();
        if(isValidRecord){
            noteList = [select Id, Title, Body, CreatedDate, LastModifiedDate, owner.Name, ownerId from Note where parentId =: recordId];
        }else{
            noteList = [select Id, Title, Body, CreatedDate, LastModifiedDate, owner.Name, ownerId from Note where parentId =: recordId AND ownerId =: UserInfo.getUserId()];
        }
        if(!noteList.isEmpty()){
            for(Note nt : noteList){
                noteAttWrapperMap = getNoteAttWrapRec(isValidRecord, 'Note', nt.Id, nt.Title, nt.Body, nt.LastModifiedDate, nt.owner.Name, nt.ownerId, false, noteAttWrapperMap);
            }
        }
        
        if(isValidRecord){
            attList = [select Id, Name, BodyLength, CreatedDate, LastModifiedDate, owner.Name, ownerId, IsPrivate from Attachment where parentId =: recordId];
        }else{
            attList = [select Id, Name, BodyLength, CreatedDate, LastModifiedDate, owner.Name, ownerId, IsPrivate from Attachment where parentId =: recordId AND (IsPrivate = false OR ownerId =: UserInfo.getUserId())];
        }
        if(!attList.isEmpty()){
            for(Attachment att : attList){
                noteAttWrapperMap = getNoteAttWrapRec(isValidRecord, 'Attachment', att.Id, att.Name, String.valueOf(att.BodyLength), att.LastModifiedDate, att.owner.Name, att.ownerId, att.IsPrivate, noteAttWrapperMap);
            }
        }
        
        List<ContentDocumentLink> contDocLinkList = [select ContentDocumentId, ContentDocument.FileExtension from ContentDocumentLink where LinkedEntityId =: recordId];       
        if(!contDocLinkList.isEmpty()){
            List<String> contNoteIdList = new List<String>();
            List<String> contDocIdList = new List<String>();
            for(ContentDocumentLink contDocLink : contDocLinkList){
                if(contDocLink.ContentDocument.FileExtension == 'snote'){
                    contNoteIdList.add(contDocLink.ContentDocumentId);
                }else{
                    contDocIdList.add(contDocLink.ContentDocumentId);
                }
            }
            if(!contNoteIdList.isEmpty()){
                if(isValidRecord){
                    contNoteList = [select Id, Title, Content, CreatedDate, LastModifiedDate, owner.Name, ownerId from ContentNote where Id IN: contNoteIdList];
                }else{
                    contNoteList = [select Id, Title, Content, CreatedDate, LastModifiedDate, owner.Name, ownerId from ContentNote where Id IN: contNoteIdList AND ownerId =: UserInfo.getUserId()];
                }
                if(!contNoteList.isEmpty()){
                    for(ContentNote nt : contNoteList){
                        noteAttWrapperMap = getNoteAttWrapRec(isValidRecord, 'Enhanced Note', nt.Id, nt.Title, nt.Content.toString(), nt.LastModifiedDate, nt.owner.Name, nt.ownerId, false, noteAttWrapperMap);
                    }
                }
            }
            
            if(!contDocIdList.isEmpty()){
                if(isValidRecord){
                    ContDocList = [select ContentDocumentId, Title, FileExtension, ContentDocument.ContentSize, CreatedDate, LastModifiedDate, owner.Name, ownerId, Core_Is_Public__c from ContentVersion where ContentDocumentId IN: contDocIdList];
                }else{
                    ContDocList = [select ContentDocumentId, Title, FileExtension, ContentDocument.ContentSize, CreatedDate, LastModifiedDate, owner.Name, ownerId, Core_Is_Public__c from ContentVersion where ContentDocumentId IN: contDocIdList AND (Core_Is_Public__c = true OR ownerId =: UserInfo.getUserId())];
                }
                for(ContentVersion att : ContDocList){
                    noteAttWrapperMap = getNoteAttWrapRec(isValidRecord, 'File', att.ContentDocumentId, att.Title+'.'+att.FileExtension, String.valueOf(att.ContentDocument.ContentSize), att.LastModifiedDate, att.owner.Name, att.ownerId, att.Core_Is_Public__c, noteAttWrapperMap);
                }
            }
        }
        if(!noteAttWrapperMap.isEmpty()){
            List<DateTime> tempList = new List<DateTime>();
            tempList.addAll(noteAttWrapperMap.keyset());
            tempList.sort();
            Core_Note_Att_Wrapper tempNoteWrap;
            for(Integer i=tempList.size()-1; i>=0; i--){
                tempNoteWrap = noteAttWrapperMap.get(tempList[i]);
                noteAttWrapperList.add(tempNoteWrap);
            }
        }
        return noteAttWrapperList;
    }
    
    public static Map<DateTime,Core_Note_Att_Wrapper> getNoteAttWrapRec(Boolean isValidRecord, String docType, String recId, String nameString, String bodyString, Datetime lastModDate, String ownerName, String ownerId, Boolean accessLevel, Map<DateTime,Core_Note_Att_Wrapper> noteAttWrapMap){
        String publicString = 'Public';
        String privateString = 'Private';
        Core_Note_Att_Wrapper noteAttWrap = new Core_Note_Att_Wrapper();
        noteAttWrap.docId = recId;
        noteAttWrap.docName = nameString;
        noteAttWrap.docType = docType;
        if(docType.containsIgnoreCase('Note')){
            noteAttWrap.docDescription = bodyString;
        }
        noteAttWrap.lastModiDate = Date.valueOf(lastModDate);
        noteAttWrap.ownerName = ownerName;
        noteAttWrap.ownerId = ownerId;
        noteAttWrap.imageName = getImageName(docType, nameString);
        String accLevel = privateString;
        if(docType.equalsIgnoreCase('Attachment')){
            if(accessLevel){
                accLevel = privateString;
            }else{
                accLevel = publicString;
            }
        }
        if(docType.equalsIgnoreCase('File')){
            if(accessLevel){
                accLevel = publicString;
            }else{
                accLevel = privateString;
            }
        }
        noteAttWrap.accessLevel = accLevel;
        if(docType.containsIgnoreCase('Note')){
            noteAttWrap.fileSize = '-';
        }else{
            noteAttWrap.fileSize = getFileSize(Long.valueOf(bodyString));
        }
        noteAttWrap.createdDurNDocId = lastModDate;
        if(isValidRecord || ownerId == UserInfo.getUserId()){
            noteAttWrap.hasAccess = true;
        }else{
            noteAttWrap.hasAccess = false;
        }
        noteAttWrapMap.put(noteAttWrap.createdDurNDocId, noteAttWrap);
        return noteAttWrapMap;
    }
    
    public static string getImageName(String docType, String nameString){
        String imageName;
        if(docType == 'Note'){
            imageName = 'txt';
        }else if(docType == 'Enhanced Note'){
            imageName = 'stypi';
        }else{
            imageName = nameString.split('\\.')[1];
            if(imageName == 'mp3'){
                imageName = 'audio';
            }else if(imageName == 'csv'){
                imageName = 'csv';
            }else if(imageName == 'xlsx' || imageName == 'xls' || imageName == 'xlsm' || imageName == 'xltx' || imageName == 'xltm'){
                imageName = 'excel';
            }else if(imageName == 'jpg' || imageName == 'jpeg' || imageName == 'png' || imageName == 'gif'){
                imageName = 'image';
            }else if(imageName == 'pdf'){
                imageName = 'pdf';
            }else if(imageName == 'ppt' || imageName == 'pptx' || imageName == 'pptm' || imageName == 'potx' || imageName == 'potm' || imageName == 'ppsx' || imageName == 'ppsm' || imageName == 'sldx' || imageName == 'sldm'){
                imageName = 'ppt';
            }else if(imageName == 'vsd'){
                imageName = 'visio';
            }else if(imageName == 'doc' || imageName == 'docx' || imageName == 'docm' || imageName == 'dotx' || imageName == 'dotm' || imageName == 'docb'){
                imageName = 'word';
            }else if(imageName == 'xml'){
                imageName = 'xml';
            }else if(imageName == 'mp4'){
                imageName = 'mp4';
            }else if(imageName == 'zip'){
                imageName = 'zip';
            }else if(imageName == 'txt'){
                imageName = 'txt';
            }else{
                imageName = 'attachment';
            }
        }
        return imageName;
    }
    
    public static String getFileSize(Long bodyValue){
        String fileSize;
        Integer temp = 1024;
        if(bodyValue < temp){
            fileSize = string.valueOf(bodyValue) + 'B';
        }else if(bodyValue >= temp && bodyValue < (temp*temp)){
            Decimal kb = Decimal.valueOf(bodyValue);
            kb = kb.divide(temp,2);
            fileSize = string.valueOf(kb) + 'KB';
        }else {
            Decimal mb = Decimal.valueOf(bodyValue);
            mb = mb.divide((temp*temp),2);
            fileSize = string.valueOf(mb) + 'MB';
        }
        return fileSize;
    }
    
    public static boolean isValidRole(Id roleId, Set<String> userRoleSet) {
        // To veriy if user is 
        return isValidRoleHierarchy(new Set<ID>{roleId}, userRoleSet);
    }
    
    public static boolean isValidRoleHierarchy(Set<ID> roleIds, Set<String> userRoleSet) {
        Set<ID> currentRoleIds = new Set<ID>();
        Boolean flag = false;
        // Get all the roles underneath the passed roles.
        for(UserRole userRole :[select Id from UserRole where ParentRoleId IN: roleIds AND ParentRoleID != null]){
            if(userRoleSet.contains(userRole.Id)){
                flag = true;
            }
            currentRoleIds.add(userRole.Id);
        }
        if(currentRoleIds.size() > 0 && !flag){
            flag = isValidRoleHierarchy(currentRoleIds, userRoleSet);
        }
        return flag;
    }
    
    @auraEnabled
    public static void createUpdateNote(String noteId, String noteTitle, String noteDesc, String noteType, String parentId){
        try{
            if(noteType == 'Note'){
                Note nt = new Note();
                nt.Id = noteId;
                nt.Title = noteTitle;
                nt.Body = noteDesc;
                update nt;
            }else{
                ContentNote nt = new ContentNote();
                nt.Title = noteTitle;
                nt.Content = Blob.valueOf(noteDesc);
                if(noteId == ''){
                    insert nt;
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = nt.Id;
                    cdl.LinkedEntityId = parentId;
                    cdl.Visibility = 'AllUsers';
                    insert cdl;
                }else{
                    nt.Id = noteId;
                    update nt;
                }
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void delNote(String recId){
        try{
            delete [select Id from Note where Id =: recId];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void delAttachment(String recId){
        try{
            delete [select Id from Attachment where Id =: recId];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void delEnhancedNote(String recId){
        try{
            delete [select Id from ContentNote where Id =: recId];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void delFile(String recId){
        try{
            delete [select Id from ContentDocument where Id =: recId];
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @auraEnabled
    public static void updateAccessLevel(String recordId, String recType, String desiredAccess){
        if(recType.equalsIgnoreCase('Attachment')){
            Attachment att = new Attachment(Id = recordId);
            if(desiredAccess.equalsIgnoreCase('Public')){
                att.IsPrivate = false;
            }else{
                att.IsPrivate = true;
            }
            update att;
        }
        if(recType.equalsIgnoreCase('File')){
            ContentVersion att = [select Id, Core_Is_Public__c from ContentVersion where contentDocumentId =: recordId];
            if(desiredAccess.equalsIgnoreCase('Public')){
                att.Core_Is_Public__c = true;
            }else{
                att.Core_Is_Public__c = false;
            }
            update att;
        }
    }
    
    public class Core_Note_Att_Wrapper{
        @auraEnabled
        public string docId{get;set;}
        @auraEnabled
        public string docName{get;set;}
        @auraEnabled
        public string docType{get;set;}
        @auraEnabled
        public string docDescription{get;set;}
        @auraEnabled
        public date lastModiDate{get;set;}
        @auraEnabled
        public string ownerName{get;set;}
        @auraEnabled
        public string ownerId{get;set;}
        @auraEnabled
        public string imageName{get;set;}
        @auraEnabled
        public string accessLevel{get;set;}
        @auraEnabled
        public string fileSize{get;set;}
        @auraEnabled
        public DateTime createdDurNDocId;
        @auraEnabled
        public boolean hasAccess{get;set;}
    }
}