public without sharing class CRM_UpdateReportsAndDashbordsNewClone {
    @InvocableMethod 
    public static void shareReportFolder(List<FolderSharingRequest> requests) {
        Set<string> reFolder = new Set<string>();
        Set<string> dashFolder = new Set<string>();
        Set<string> reFoldDevlNamlst = new Set<string>();
        Set<string> dashFoldDevlNamlst = new Set<string>();
        Set<Id> dashboardId = new  Set<Id>();
        Set<Id> ReportId = new  Set<Id>();
        List<string> dashApiNamr = new List<string>();
        for(FolderSharingRequest request : requests){
            If(request.selectedRepots != null){
            for( Report Repot: request.selectedRepots){
                if(Repot.FolderName != 'Public Reports'){
                    reFolder.add(Repot.FolderName);
                }
            }}
            If(request.selectedDashboard  != null){
            for( Dashboard dash: request.selectedDashboard){
                dashFolder.add(dash.FolderName);
                dashboardId.add(dash.Id);
            }}
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
            for(Dashboard dash: [SELECT FolderName,DeveloperName FROM Dashboard where Id In: dashboardId and RunningUser.IsActive = false]){
                String apiName = dash.FolderName + '/' + dash.DeveloperName;
                dashApiNamr.add(apiName);
            }
        }
        // end of Dashbord Report Logic
        if(!reFolder.isEmpty()){
            for(folder FolDevelName : [SELECT DeveloperName from folder where name =:reFolder and Type='Report' ]){
                reFoldDevlNamlst.add(FolDevelName.DeveloperName);
            }
            system.debug(reFoldDevlNamlst);
        }
        if(!dashFolder.isEmpty()){
            for(folder FolDevelName : [SELECT DeveloperName from folder where name =:dashFolder and Type='Dashboard']){
                dashFoldDevlNamlst.add(FolDevelName.DeveloperName);
            }
        }
        if(!reFoldDevlNamlst.isEmpty() || !dashFoldDevlNamlst.isEmpty() ){
            User userId;
            If(requests.size()>0){
                userId = [SELECT Id,Username FROM user WHERE Email=: requests[0].ToUserEmail][0];
            }
            String userName = userId.Username;
            if(!reFoldDevlNamlst.isEmpty()){
                updateReFolders(reFoldDevlNamlst,userName);
            }
            if(!dashFoldDevlNamlst.isEmpty()){
                updateDashFolders(dashFoldDevlNamlst,userName);
            }
           CRM_CheckUserAccess_Dashboard.updateRunningUser(dashApiNamr,userId.Id); 
        }
        
    }
    //Runing User Change Logic Here
    
    //End Of Running User Logic
    @future(callout=true)
    public static Void updateReFolders(Set<string> reFoldDevlNamlst,String userName){
        List<MetadataService.ReportFolder> Repfolderlst = new List<MetadataService.ReportFolder>();
        for(String FdName : reFoldDevlNamlst){
            
            MetadataService.ReportFolder Refolder = new MetadataService.ReportFolder();
            Refolder.fullName = FdName;  // Folder Developer Name
            Refolder.accessType = 'Public';
            MetadataService.FolderShare share = new MetadataService.FolderShare();
            share.accessLevel = 'View';  // View or EditAllContents or Manage
            share.sharedTo = userName;    //TO UserName or Group ID
            share.sharedToType = 'User';
            Refolder.folderShares = new List<MetadataService.FolderShare>{ share };
                Repfolderlst.add(Refolder);
        }
        CreatesessionId( Repfolderlst);    
    }
    @future(callout=true)
    public static Void updateDashFolders(Set<string> reFoldDevlNamlst,String userName){
        List<MetadataService.DashboardFolder> dFolderlst = new List<MetadataService.DashboardFolder>();
        for(String FdName : reFoldDevlNamlst){
            
            MetadataService.DashboardFolder dashFolder = new MetadataService.DashboardFolder();
            dashFolder.fullName = FdName;  // Folder Developer Name
            dashFolder.accessType = 'Public';
            MetadataService.FolderShare share = new MetadataService.FolderShare();
            share.accessLevel = 'EditAllContents';  // View or EditAllContents or Manage
            share.sharedTo = userName;    //TO UserName or Group ID
            share.sharedToType = 'User';
            dashFolder.folderShares = new List<MetadataService.FolderShare>{ share };
                dFolderlst.add(dashFolder);
            
        }
        System.debug('<103 Dash Folder >'+ dFolderlst);
        CreatesessionId( dFolderlst);
    }
    public static Void CreatesessionId(List<MetadataService.Metadata> Repfolderlst){
        try {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        if(Repfolderlst.Size()>10){
            List<MetadataService.Metadata> subList = new List<MetadataService.Metadata>();
            for (Integer lstsize = 0; lstsize< Repfolderlst.Size(); lstsize++) {
                subList.add(Repfolderlst[lstsize]);
                if(math.mod(lstsize,10)==0 || lstsize == Repfolderlst.Size()-1 ){
                    MetadataService.SaveResult[] results = service.updateMetadata(subList);
                    for (MetadataService.SaveResult result : results) {
                        if (!result.success) {
                            for (MetadataService.Error err : result.errors) {
                                System.debug('Error sharing folder: ' + err.message);
                            }
                        }
                    }
                    subList.clear();
                }
            }
        }
        else{
            MetadataService.SaveResult[] results = service.updateMetadata(Repfolderlst);
            //for (MetadataService.SaveResult result : results) {if (result.success) {System.debug('<Line106> Success'); }}
            for (MetadataService.SaveResult result : results) {
                if (!result.success) {
                    for (MetadataService.Error err : result.errors) {
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
    public class FolderSharingRequest {
        
        @InvocableVariable
        public List<Report> selectedRepots = null;
        
        @InvocableVariable
        public List<Dashboard> selectedDashboard = null;
        
        @InvocableVariable(required=true)
        public String ToUserEmail;
    }
    
}