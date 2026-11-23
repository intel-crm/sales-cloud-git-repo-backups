public without sharing class CRM_Create_Dashbord_detail {
    @AuraEnabled 
    public static List<Map<String, Object>> Create_Dasboard_Data( Id FromUser,Id ToUser){
        Set<Id> DashId = new Set<Id>();
        List<Map<String, Object>> res = new List<Map<String, Object>>();
       // List<sendDetails> srList = new List<sendDetails>();
        Map<Id,String> DashName = new Map<Id,String>();
        Map<Id,String> RuningUserName = new Map<Id,String>();
        Map<Id,Boolean> RunUsrIsActive = new Map<Id,Boolean>();
        Map<Id,Set<ID>> MapDashRepotId = new Map<Id,Set<ID>>();
        Set<Id> RepotId = new Set<Id>();
        Map<Id,String> RepotName = new Map<Id,String>();
        Map<Id,String> MapDashRepotNameStr = new Map<Id,String>();
        
        Set<Id> DashIdToShow = new Set<Id>();
        Set<Id> DashIdToChk = new Set<Id>();
        Map<String,Set<Id>> Dashfoldermap = new Map<String,Set<Id>>();
        Map<Id,String> dashFolderId = new Map<Id,String>();
        Map<String,Set<Id>> Repotfoldermap = new Map<String,Set<Id>>();
        Map<Id,String> RepotFolderId = new Map<Id,String>();
        Set<Id> repotIdtoChk = new Set<Id>();
            for(Dashboard dash: [SELECT ID,RunningUser.Name,RunningUser.IsActive,Title,FolderName FROM Dashboard where CreatedById =: FromUser  /*and RunningUser.IsActive = false*/]){
                DashId.add(dash.Id);
                DashName.put(dash.Id,dash.Title);
                RuningUserName.put(dash.ID,dash.RunningUser.Name);
                RunUsrIsActive.put(dash.ID,dash.RunningUser.IsActive);
                set<Id> DashIdfold = new Set<Id>();
                if(dash.RunningUser.IsActive == false){
                    DashIdToShow.add(dash.ID);
                }
                if(Dashfoldermap.containsKey(dash.FolderName)){
                    DashIdfold = Dashfoldermap.get(dash.FolderName);
                }
                DashIdfold.add(dash.Id);
                Dashfoldermap.put(dash.FolderName,DashIdfold);
            }
            for(DashboardComponent dashcomp : [SELECT CustomReportId,DashboardId FROM DashboardComponent where DashboardId In: DashId]){
                Set<Id> custRepotId = New Set<Id>(); 
                if(MapDashRepotId.containsKey(dashcomp.DashboardId)){
                    custRepotId = MapDashRepotId.get(dashcomp.DashboardId);
                }
                custRepotId.add(dashcomp.CustomReportId);
                MapDashRepotId.put(dashcomp.DashboardId,custRepotId);
                RepotId.add(dashcomp.CustomReportId);
            }
            for(Report Repot : [SELECT Id,Name,FolderName FROM Report where Id In: RepotId] ){
                RepotName.put(Repot.Id, Repot.Name);
                set<Id> repotIdfold = new Set<Id>();
                if(Repotfoldermap.containsKey(Repot.FolderName)){
                    repotIdfold = Repotfoldermap.get(Repot.FolderName);
                }
                repotIdfold.add(Repot.Id);
                Repotfoldermap.put(Repot.FolderName,repotIdfold);
            }
            For(Id Dash: MapDashRepotId.keySet()){
                Set<String> RepotNameSet = New Set<String>();
                string RepotNameString = '';
                for(Id Repot : MapDashRepotId.get(Dash)){
                    If(RepotName.containsKey(Repot)){
                        RepotNameSet.add(RepotName.get(Repot));
                    }
                }
                RepotNameString = string.join(New List<String>(RepotNameSet),',');
                MapDashRepotNameStr.put(Dash,RepotNameString);
            }
        if(Dashfoldermap != null){
            for(folder FolName : [SELECT Id,Name from folder where name IN: Dashfoldermap.keySet() and Type='Dashboard']){
                dashFolderId.put(FolName.Id,FolName.Name);
            }
            if(dashFolderId != null){
                for(UserRecordAccess usReAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId IN: dashFolderId.keySet() AND UserId =: ToUser  ]){
                    if(usReAcc.HasReadAccess == false){
                        DashIdToShow.addAll(Dashfoldermap.get(dashFolderId.get(usReAcc.RecordId)));
                    }
                    else{
                        DashIdToChk.addAll(Dashfoldermap.get(dashFolderId.get(usReAcc.RecordId)));
                    }
                }
            }
        }
        if(!DashIdToChk.isEmpty()){
            if(Repotfoldermap != null){
                for(folder FolName : [SELECT Id,Name from folder where name IN: Repotfoldermap.keySet() and Type='Report']){
                    RepotFolderId.put(FolName.Id,FolName.Name);
                } 
            }
            if(RepotFolderId != null){
                for(UserRecordAccess usReAcc : [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE RecordId IN: RepotFolderId.keySet() AND UserId =: ToUser  ]){
                    if(usReAcc.HasReadAccess == false){
                        repotIdtoChk.addAll(Repotfoldermap.get(RepotFolderId.get(usReAcc.RecordId)));
                    }
                }
            }
            if(!repotIdtoChk.isEmpty()){
                for(Id DashIdr : DashIdToChk){
                    for(Id customRepId : MapDashRepotId.get(DashIdr)){
                        if(repotId.contains(customRepId)){
                            DashIdToShow.add(DashIdr);
                            break;
                        }
                    }
                }
            }
            
            
        }
        
        /*for(Id dash : DashIdToShow){
           sendDetails sr = new sendDetails();
            sr.DashaboardId = dash;
            sr.DashaboardName = DashName.get(dash);
            sr.RunningUsrName = RuningUserName.get(dash);
            sr.RunningUsrisActive = RunUsrIsActive.get(dash);
            sr.ReportName = MapDashRepotNameStr.get(dash);
            srList.add(sr);
        }*/
        for(Id dash : DashIdToShow){
           Map<String, Object> recordmap = new Map<String, Object>();
            recordmap.put('DashaboardId',dash);
            recordmap.put('DashaboardName',DashName.get(dash));
            recordmap.put('RunningUsrName',RuningUserName.get(dash));
            recordmap.put('RunningUsrisActive',RunUsrIsActive.get(dash));
            recordmap.put('ReportName',MapDashRepotNameStr.get(dash));
            res.add(recordmap);
        }
        //return srList;
        return res;
    }
    
    /*public class sendDetails {
        @AuraEnabled 
        public Id DashaboardId;
        @AuraEnabled 
        public String DashaboardName;
        @AuraEnabled 
        public String RunningUsrName;
        @AuraEnabled 
        public Boolean RunningUsrisActive;
        @AuraEnabled 
        public String ReportName;
        
    }*/
}