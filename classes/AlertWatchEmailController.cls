public class AlertWatchEmailController {
	public String headerURL;    
    public List<AlertWatch.AlertWatchResponse> WatchResponse; 
     public String getHeaderURL(){
        String domainName;
        String orgId;
        
        Document document;            
        document = [select Id from Document where Name=: Label.Pricing_IQR_Intel_Logo LIMIT 1];
        domainName = String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];
        orgId = UserInfo.getOrganizationId();
        headerURL = domainName + '/servlet/servlet.ImageServer?id=' + document.Id + '&oid=' + orgId;       
        return headerURL;
    }
    
    public String getDomainName(){
        String domainName;
        domainName =  String.valueOf(System.Url.getOrgDomainUrl());
        domainName = domainName.split('=')[1].split(']')[0];         
        return domainName;
    }
    
     public List<AlertWatch.AlertWatchResponse> getWatchResponse(){
       //	WatchResponse = AlertWatch.GetInactiveRecordData();     
        return WatchResponse;
    }
}