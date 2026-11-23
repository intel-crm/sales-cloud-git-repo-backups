public without sharing class CRM_CheckUserAccess_Report {
    @AuraEnabled(cacheable=true)
    public static List<Report> UserReports( String FromUser,String ToUser){
        List<Id> SendRepID = new List<Id>();
        List<Report> SendRep = new List<Report>();
        Map<String,Set<Report>> refolsetIdMap = new Map<String,Set<Report>>();
        Map<Id,String> foldNmIdmap = new Map<Id,String>();
        Set<Id> usAcReId = new Set<Id>();
        set<Id>FinalReId = new Set<Id>();
        set<Report>FinalReport = new Set<Report>();
        User frUsID = [SELECT Id FROM user WHERE Username=: FromUser];
        User toUsID = [SELECT Id FROM user WHERE Username=: ToUser]; 
        List<Report> frUsRep= [SELECT Id,Name, FolderName, CreatedDate,CreatedBy.Name,CreatedBy.IsActive,CreatedBy.Profile.Name,OwnerId,LastRunDate  FROM Report where CreatedById =: frUsID.Id ];
        if(!frUsRep.isEmpty()){
            for( Report Repot: frUsRep){
                if(Repot.FolderName != 'Public Reports'){
                    //set<Id> reId = new Set<Id>();
                    set<Report> rept = new Set<Report>();
                    if(refolsetIdMap.containsKey(Repot.FolderName)){
                        rept = refolsetIdMap.get(Repot.FolderName);
                    }
                    rept.add(Repot);
                    refolsetIdMap.put(Repot.FolderName,rept);
                }
            }
        }
        if(refolsetIdMap != null){
            for(folder FolDevelName : [SELECT Id,Name from folder where name IN: refolsetIdMap.keySet() and Type='Report']){
                foldNmIdmap.put(FolDevelName.Id , FolDevelName.Name);
            }
        }
       // system.debug(foldNmIdmap);
        if(foldNmIdmap != null){
            for(UserRecordAccess usReAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId IN: foldNmIdmap.keySet() AND UserId =: toUsID.ID  ]){
                if(usReAcc.HasReadAccess == false){
                    usAcReId.add(usReAcc.RecordId);
                }
            }
        }
       // system.debug(usAcReId);
        if(!usAcReId.isEmpty()){
            for(Id uaId: usAcReId){
                if(foldNmIdmap.containsKey(uaId)){
                    //FinalReId.addAll(refolsetIdMap.get(foldNmIdmap.get(uaId)));
                    FinalReport.addAll(refolsetIdMap.get(foldNmIdmap.get(uaId)));
                }
            }
        }
        //system.debug(FinalReId.Size());
       /* SendRepID.addAll(FinalReId);
        sendRepId sr = new sendRepId();
        if(!SendRepID.isEmpty()){
            sr.sendReportId = SendRepID;
        }
        return new List<sendRepId>{ sr };*/
        SendRep.addAll(FinalReport);
        return SendRep;
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