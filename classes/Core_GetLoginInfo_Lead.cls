public class Core_GetLoginInfo_Lead {
    
    Public class appNameResult{
        @InvocableVariable(label='Application')
        Public string application;
    }
    
	@InvocableMethod(label='Get User Last Login Application')
    Public static List<appNameResult> getLoginApp(List<String> userIds)
    {
        List<appNameResult> resultList = new List<appNameResult>();
        
           LoginHistory historyList = [Select Application from LoginHistory where UserId =:UserInfo.getuserId() 
                                             ORDER BY LoginTime DESC Limit 1];
           appNameResult result = new appNameResult();
           result.application = historyList != null ? historyList.Application : 'unknown';	
           resultList.add(result);
     
        Return resultList;
    }
}