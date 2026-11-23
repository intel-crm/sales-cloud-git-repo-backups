public without sharing class CRM_CheckUserAccess_Report {
    @InvocableMethod
    public static List<sendRepId> UserReports(List<UserEmails> Emails){
        List<Id> SendRepID = new List<Id>();
        Map<String,Set<Id>> refolsetIdMap = new Map<String,Set<Id>>();
        Map<Id,String> foldNmIdmap = new Map<Id,String>();
        Set<Id> usAcReId = new Set<Id>();
        set<Id>FinalReId = new Set<Id>();
        User frUsID = [SELECT Id FROM user WHERE email=: Emails[0].FromUserEmail];
        User toUsID = [SELECT Id FROM user WHERE email=: Emails[0].ToUserEmail][1];
        List<Report> frUsRep= [SELECT Id,Name, FolderName, CreatedDate,CreatedBy.Name,CreatedBy.IsActive,CreatedBy.Profile.Name,OwnerId  FROM Report where CreatedById =: frUsID.Id ];
        if(!frUsRep.isEmpty()){
            for( Report Repot: frUsRep){
                if(Repot.FolderName != 'Public Reports'){
                    set<Id> reId = new Set<Id>();
                    if(refolsetIdMap.containsKey(Repot.FolderName)){
                        reId = refolsetIdMap.get(Repot.FolderName);
                    }
                    reId.add(Repot.Id);
                    refolsetIdMap.put(Repot.FolderName,reId);
                }
            }
        }
        if(refolsetIdMap != null){
            for(folder FolDevelName : [SELECT Id,Name from folder where name IN: refolsetIdMap.keySet() and Type='Report']){
                foldNmIdmap.put(FolDevelName.Id , FolDevelName.Name);
            }
        }
        system.debug(foldNmIdmap);
        if(foldNmIdmap != null){
            for(UserRecordAccess usReAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId IN: foldNmIdmap.keySet() AND UserId =: toUsID.ID  ]){
                if(usReAcc.HasReadAccess == false){
                    usAcReId.add(usReAcc.RecordId);
                }
            }
        }
        system.debug(usAcReId);
        if(!usAcReId.isEmpty()){
            for(Id uaId: usAcReId){
                if(foldNmIdmap.containsKey(uaId)){
                    FinalReId.addAll(refolsetIdMap.get(foldNmIdmap.get(uaId)));
                }
            }
        }
        system.debug(FinalReId.Size());
        SendRepID.addAll(FinalReId);
        sendRepId sr = new sendRepId();
        if(!SendRepID.isEmpty()){
            sr.sendReportId = SendRepID;
        }
        return new List<sendRepId>{ sr };
    }
    public class UserEmails {
        @InvocableVariable(required=true)
        public String FromUserEmail;
        @InvocableVariable(required=true)
        public String ToUserEmail;
       
    }
    public class sendRepId {
        @AuraEnabled @InvocableVariable(required=true)
        public List<Id> sendReportId;
       
    }
}