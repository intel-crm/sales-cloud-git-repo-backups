public without sharing class CRM_UpdateReportsAndDashbords {
    @AuraEnabled 
    public static Boolean shareReportFolder(List<id> selectedRowIds,Id toUser, String obj /*,Core_MDF_Custom_Utility_Config__c objConfigRec*/) {
        Set<string> reFolder = new Set<string>();
        Set<string> dashFolder = new Set<string>();
        Set<string> reFoldDevlNamlst = new Set<string>();
        Set<string> dashFoldDevlNamlst = new Set<string>();
        Set<Id> dashboardId = new  Set<Id>();
        Set<Id> ReportId = new  Set<Id>();
        List<string> dashApiNamr = new List<string>();
        if(obj == 'Reports'){
            for(Report Repot : [SELECT FolderName FROM Report where Id In: selectedRowIds] ){
                if(Repot.FolderName != 'Public Reports'){
                    reFolder.add(Repot.FolderName);
                }
            }
        }
        else if(obj == 'Dashboards'){
            dashboardId.addAll(selectedRowIds);
        }
        //Dashbord Report Logic 
        if(!dashboardId.isEmpty()){
            for(DashboardComponent dashcomp : [SELECT CustomReportId,DashboardId FROM DashboardComponent where DashboardId In: dashboardId]){
                ReportId.add(dashcomp.CustomReportId);
            }
            for(Report Repot : [SELECT FolderName FROM Report where Id In: ReportId] ){
                if(Repot.FolderName != 'Public Reports'){
                    reFolder.add(Repot.FolderName);
                }
            }
            for(Dashboard dash: [SELECT FolderName,DeveloperName,RunningUser.IsActive FROM Dashboard where Id In: dashboardId /*and RunningUser.IsActive = false*/]){
                if(dash.RunningUser.IsActive == false){
                    String apiName = dash.FolderName + '/' + dash.DeveloperName;
                    dashApiNamr.add(apiName);
                }
                
                dashFolder.add(dash.FolderName);
            }
        }
        // end of Dashbord Report Logic
        if(!reFolder.isEmpty()){
            for(folder FolDevelName : [SELECT DeveloperName from folder where name =:reFolder and Type='Report' ]){
                reFoldDevlNamlst.add(FolDevelName.DeveloperName);
            }
        }
        if(!dashFolder.isEmpty()){
            for(folder FolDevelName : [SELECT DeveloperName from folder where name =:dashFolder and Type='Dashboard']){
                dashFoldDevlNamlst.add(FolDevelName.DeveloperName);
            }
        }
        if(!reFoldDevlNamlst.isEmpty() || !dashFoldDevlNamlst.isEmpty() ){
            User userId;
                userId = [SELECT Id,Username,Name FROM user WHERE Id=: toUser];
            String userName = userId.Username;
            String Name =userId.Name;
            if(!reFoldDevlNamlst.isEmpty()){
                updateReFolders(reFoldDevlNamlst,userName);
            }
            if(!dashFoldDevlNamlst.isEmpty()){
                updateDashFolders(dashFoldDevlNamlst,userName);
            }
           CRM_CheckUserAccess_Dashboard.updateRunningUser(dashApiNamr,userId.Id); 
        }
        return true;
    }
    
    //End Of Running User Logic
    @future(callout=true)
    public static Void updateReFolders(Set<string> reFoldDevlNamlst,String userName){
        List<CRM_MetadataService.ReportFolder> Repfolderlst = new List<CRM_MetadataService.ReportFolder>();
        for(String FdName : reFoldDevlNamlst){
            
            CRM_MetadataService.ReportFolder Refolder = new CRM_MetadataService.ReportFolder();
            Refolder.fullName = FdName;  // Folder Developer Name
            Refolder.accessType = 'Public';
            CRM_MetadataService.FolderShare share = new CRM_MetadataService.FolderShare();
            share.accessLevel = 'View';  // View or EditAllContents or Manage
            share.sharedTo = userName;    //TO UserName or Group ID
            share.sharedToType = 'User';
            Refolder.folderShares = new List<CRM_MetadataService.FolderShare>{ share };
                Repfolderlst.add(Refolder);
        }
        CreatesessionId( Repfolderlst);    
    }
    @future(callout=true)
    public static Void updateDashFolders(Set<string> reFoldDevlNamlst,String userName){
        List<CRM_MetadataService.DashboardFolder> dFolderlst = new List<CRM_MetadataService.DashboardFolder>();
        for(String FdName : reFoldDevlNamlst){
            
            CRM_MetadataService.DashboardFolder dashFolder = new CRM_MetadataService.DashboardFolder();
            dashFolder.fullName = FdName;  // Folder Developer Name
            dashFolder.accessType = 'Public';
            CRM_MetadataService.FolderShare share = new CRM_MetadataService.FolderShare();
            share.accessLevel = 'EditAllContents';  // View or EditAllContents or Manage
            share.sharedTo = userName;    //TO UserName or Group ID
            share.sharedToType = 'User';
            dashFolder.folderShares = new List<CRM_MetadataService.FolderShare>{ share };
                dFolderlst.add(dashFolder);
            
        }
        CreatesessionId( dFolderlst);
    }
    public static Void CreatesessionId(List<CRM_MetadataService.Metadata> Repfolderlst){
        try {
        CRM_MetadataService.MetadataPort service = new CRM_MetadataService.MetadataPort();
        service.SessionHeader = new CRM_MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        if(Repfolderlst.Size()>10){
            List<CRM_MetadataService.Metadata> subList = new List<CRM_MetadataService.Metadata>();
            for (Integer lstsize = 0; lstsize< Repfolderlst.Size(); lstsize++) {
                subList.add(Repfolderlst[lstsize]);
                if(math.mod(lstsize,10)==0 || lstsize == Repfolderlst.Size()-1 ){
                    CRM_MetadataService.SaveResult[] results = service.updateMetadata(subList);
                    for (CRM_MetadataService.SaveResult result : results) {
                        if (!result.success) {
                            for (CRM_MetadataService.Error err : result.errors) {
                                System.debug('Error sharing folder: ' + err.message);
                            }
                        }
                    }
                    subList.clear();
                }
            }
        }
        else{
            CRM_MetadataService.SaveResult[] results = service.updateMetadata(Repfolderlst);
            for (CRM_MetadataService.SaveResult result : results) {if (result.success) {System.debug('<Line106> Success'); }}
            for (CRM_MetadataService.SaveResult result : results) {
                if (!result.success) {
                    for (CRM_MetadataService.Error err : result.errors) {
                        System.debug('Error sharing folder: ' + err.message);
                    }
                }
            }
        }
    } 
        catch(Exception Ex){
            system.debug(Ex.getMessage());
        }   
    }
    
}