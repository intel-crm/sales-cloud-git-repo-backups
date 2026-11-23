public without sharing class Core_MDF_SubUnsub_Notifications_Utility {
    
    //Query Notification Subscription records based on user access
    @AuraEnabled
    public static List<notificationData> getSubscriptionDetails(Id usrId, String application) 
    {
        List<notificationData> finalWrapperList= new List<notificationData>();
        try {
            Id userId = usrId;
            Map<String,List<String>> objectToNotificationTypes = new  Map<String,List<String>>();
            List<String> mandateNotificationsList = new List<String>();        
            Map<String,Boolean> userSubsMap = new Map<String,Boolean>();
            Map<String,String> notificationTypeOptionsMap = new Map<String,String>();
            Map<String,String> notificationToHelpTextMap = new Map<String,String>();
            Map<String,String> objectTypeOptionsMap = new Map<String,String>();
            Map<String,Id> notificationToSubsRec = new Map<String,Id>();
            List<String> assignedProfiles = new List<String>();
            List<String> assignedPermissionSets = new List<String>();
            List<String> assignedPermSetGrps = new List<String>();
            List<String> assignedCustomPermission = new List<String>();
            
            for (Core_MDF_Subscription_Notification_Type__c notifType : [SELECT Core_MDF_Object_API_nm__c, Core_MDF_Object_Label_txt__c, Core_MDF_Notification_Type_API_nm__c, Core_MDF_Notification_Type_Label_txt__c FROM Core_MDF_Subscription_Notification_Type__c]) {
                notificationTypeOptionsMap.put(notifType.Core_MDF_Notification_Type_API_nm__c,notifType.Core_MDF_Notification_Type_Label_txt__c);
                objectTypeOptionsMap.put(notifType.Core_MDF_Object_API_nm__c,notifType.Core_MDF_Object_Label_txt__c);
            }

            // notificationTypeOptionsMap = Core_MDF_CCP_GenericUtility.getPickListvalues('Core_MDF_Subscription_Notification_Type__c','Core_MDF_Notification_Type_API_nm__c');
            
            // objectTypeOptionsMap = Core_MDF_CCP_GenericUtility.getPickListvalues('Core_MDF_Subscription_Notification_Type__c','Core_MDF_Object_API_nm__c');
            
            //Query on User Permission sets/ Profiles/ Permission Set Groups/ Customer Permissions
            
            String fields = ' Id,PermissionSet.Name,PermissionSetGroup.DeveloperName,PermissionSet.Profile.Name,PermissionSet.Id ';
            String whereClause = ' AssigneeId =\'' + userId +'\' ';  
            
            Map<String,List<String>> acccessTypeMap = Core_MDF_CCP_GenericUtility.getUserAccessMap(fields,whereClause);
            assignedProfiles = acccessTypeMap.get('Profile');
            assignedPermissionSets = acccessTypeMap.get('PermissionSet');
            assignedPermSetGrps = acccessTypeMap.get('PermissionSetGroup');
            assignedCustomPermission = acccessTypeMap.get('CustomPermission');
            
            List<Core_MDF_Subscription_Notification_Type__c> subscriptionList = querySubscriptionRecords(assignedPermissionSets,assignedProfiles,assignedPermSetGrps,assignedCustomPermission,application);
            
            //Create a Map to store Object and its corresponding Notification Types
            for(Core_MDF_Subscription_Notification_Type__c  subs : subscriptionList) {
                
                if(objectToNotificationTypes.containskey(subs.Core_MDF_Object_API_nm__c)) {
                    objectToNotificationTypes.get(subs.Core_MDF_Object_API_nm__c).add(subs.Core_MDF_Notification_Type_API_nm__c);
                }
                else {
                    objectToNotificationTypes.put(subs.Core_MDF_Object_API_nm__c, new List<String> {subs.Core_MDF_Notification_Type_API_nm__c});
                }
                
                //Create a Map to store Notification Type to Subscription Record Id
                notificationToSubsRec.put(subs.Core_MDF_Notification_Type_API_nm__c,subs.Id);
                
                //Get Mandate Notification Types
                Boolean isMandate  = getMandateNotificationTypes(assignedPermissionSets,assignedProfiles,assignedPermSetGrps,assignedCustomPermission,subs);
                
                //If notification type is mandate then add it in the mandateNotificationList
                if(isMandate) {
                    mandateNotificationsList.add(subs.Core_MDF_Notification_Type_API_nm__c);
                }
                //Get Helptext for each Notification Type
                notificationToHelpTextMap.put(subs.Core_MDF_Notification_Type_API_nm__c,subs.Core_MDF_Help_Text_txt__c);
                
            }
            //Query Email Preference Object to check if a Notification type is Unsubscribed
            for(Pricing_IQR_Email_Preferences__c userSub : [Select id,Core_MDF_Module_Nm__c,Pricing_Notification_Name_Nm__c,Pricing_User__c,Pricing_Opt_In_Ind__c from Pricing_IQR_Email_Preferences__c where Pricing_User__c =: userId]) {
                userSubsMap.put(userSub.Pricing_Notification_Name_Nm__c,userSub.Pricing_Opt_In_Ind__c);
            }
            
            //Create a final Wrapper List and send to component
            
            for(String obj : objectToNotificationTypes.keySet()) {
                List<notificationTypesWrapper> notificationWrapperList = new List<notificationTypesWrapper>();
                notificationData wrap = new notificationData();
                wrap.objectName = obj;
                wrap.objectLabel = objectTypeOptionsMap.get(obj);
                for(String type : objectToNotificationTypes.get(obj)) {
                    notificationTypesWrapper notifyWrapper = new notificationTypesWrapper();
                    notifyWrapper.label = notificationTypeOptionsMap.get(type);
                    notifyWrapper.apiname = type;
                    if(mandateNotificationsList != null && mandateNotificationsList.contains(type)) {
                        notifyWrapper.subscribed =  true;
                        notifyWrapper.mandateNotification = true;
                    }
                    else if(userSubsMap.containsKey(type) && userSubsMap.get(type) != null && !userSubsMap.get(type)) {
                        notifyWrapper.subscribed = false;
                    } 
                    notifyWrapper.helpText = notificationToHelpTextMap.get(type);
                    notifyWrapper.subsRecId = notificationToSubsRec.get(type);
                    notificationWrapperList.add(notifyWrapper);
                } 
                wrap.notificationTypes = notificationWrapperList;
                finalWrapperList.add(wrap);  
            }
            
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);
        throw new AuraHandledException(e.getMessage());}
        return finalWrapperList;
    }
    
    public static List<Core_MDF_Subscription_Notification_Type__c> querySubscriptionRecords(List<String> assignedPermissionSets, List<String> assignedProfiles, List<String> assignedCustomPermission, List<String> assignedPermSetGrps, String application) {
        
          
            String assignedProfilesStr = '';
            String assignedPermissionSetsStr = '';
            String assignedPermSetGrpsStr = '';
            String assignedCustomPermissionStr = '';
        
        
         //Concatenate all the values of the list into a single string 
            if(assignedProfiles != null && assignedProfiles.size() >0){
                assignedProfilesStr ='(\'' + String.join(assignedProfiles, '\', \'') + '\')';}
            
            if(assignedPermSetGrps != null && assignedPermSetGrps.size() > 0){
                assignedPermSetGrpsStr ='(\'' + String.join(assignedPermSetGrps, '\', \'') + '\')';}
            
            if(assignedPermissionSets != null && assignedPermissionSets.size() > 0){
                assignedPermissionSetsStr ='(\'' + String.join(assignedPermissionSets, '\', \'') + '\')';}
            
            if(assignedCustomPermission != null && assignedCustomPermission.size() > 0) {
                assignedCustomPermissionStr ='(\'' + String.join(assignedCustomPermission, '\', \'') + '\')';}
            
             //Create a query to Subscription records
        	String query = 'Select id,Core_MDF_Object_API_nm__c, Core_MDF_Notification_Type_API_nm__c, Core_MDF_Help_Text_txt__c,Core_MDF_Mandate_PermissionSets_nm__c,Core_MDF_Mandate_Profiles_nm__c,Core_MDF_Mandate_CustomPermissions_nm__c,Core_MDF_Mandate_PermissionSet_Grp_nm__c from Core_MDF_Subscription_Notification_Type__c where Core_MDF_Active_Ind__c  = true ';
      
           if(String.isNotBlank(application)) {
             query += ' AND Core_MDF_Project_Application_nm__c =: application ' ;
           }
           
	        query +=  ' AND  (( ';
			
			if(String.isNotBlank(assignedProfilesStr)) {
			  query += ' (not(Core_MDF_Conflict_Profiles_nm__c INCLUDES ' + assignedProfilesStr + ' ))';
			}
			
			if(String.isNotBlank(assignedPermissionSetsStr)) {
			  query += ' AND (not(Core_MDF_Conflict_PermissionSets_nm__c INCLUDES ' + assignedPermissionSetsStr + ' ))';
			}
			query += ' ) ';
              
			query += ' OR (Core_MDF_Conflict_Profiles_nm__c = null AND Core_MDF_Conflict_PermissionSets_nm__c =null' + '))';
				
			query += ' AND ( ';
	  
	  
	        if(String.isNotBlank(assignedProfilesStr)) {
			    query += ' Core_MDF_Applicable_Profiles_nm__c INCLUDES ' + assignedProfilesStr;
			
			}
			
			if(String.isNotBlank(assignedPermissionSetsStr)) {
			    query += '  OR Core_MDF_Applicable_PermissionSets_nm__c INCLUDES ' + assignedPermissionSetsStr;
			}
 
            if(String.isNotBlank(assignedCustomPermissionStr)) {
                    query += ' OR Core_MDF_Applicable_CustomPermissions_nm__c INCLUDES ' + assignedCustomPermissionStr;
            }
          
            if(String.isNotBlank(assignedPermSetGrpsStr)) {
               query += ' OR Core_MDF_Applicable_PermissionSet_Grp_nm__c INCLUDES ' + assignedPermSetGrpsStr;
			    
            }

            query += ' )';
        
            
        
         return Database.query(query);
    }
    
    public static Boolean getMandateNotificationTypes( List<String> assignedPermissionSets,List<String> assignedProfiles, List<String> assignedPermSetGrps, List<String> assignedCustomPermission, Core_MDF_Subscription_Notification_Type__c subs) 
    {
       
        
        if(subs.Core_MDF_Mandate_Profiles_nm__c != null) {   
            for(String profile : subs.Core_MDF_Mandate_Profiles_nm__c.split(';')) {
                if(assignedProfiles != null && assignedProfiles.contains(profile)) {
                    return true;
                }   
            }	    
        }
        
        if(subs.Core_MDF_Mandate_CustomPermissions_nm__c != null) {   
            for(String cusPer : subs.Core_MDF_Mandate_CustomPermissions_nm__c.split(';')) {
                if(assignedCustomPermission != null && assignedCustomPermission.contains(cusPer)) {
                    return true;
                }                                       
            }
        }
        
        if(subs.Core_MDF_Mandate_PermissionSet_Grp_nm__c != null) {
            for(String perSetGrp : subs.Core_MDF_Mandate_PermissionSet_Grp_nm__c.split(';')) {
                
                if(assignedPermSetGrps != null && assignedPermSetGrps.contains(perSetGrp)) {
                    return true;
                }
                
            }
            
        }
        
         if(subs.Core_MDF_Mandate_PermissionSets_nm__c != null) {
            for(String perSet : subs.Core_MDF_Mandate_PermissionSets_nm__c.split(';')) {
                if(assignedPermissionSets != null && assignedPermissionSets.contains(perSet)) {
                    return true;
                }
            }   
        }
        
        
        return false;
    }
    
    //Create or update IQR Email Preference record.
    @AuraEnabled 
    public static string addOrRemoveUserSubscriptionRecord(List<subsUnsubsDataWrapper> subsUnsubsData) {
        String returnValue ='';
        try {
            
           
            //Id userId =UserInfo.getUserId(); 
            Set<ID> userIDSet =  new Set<ID>();     
            List<Pricing_IQR_Email_Preferences__c> finalUserSubList = new List<Pricing_IQR_Email_Preferences__c>();
            Map<String,Id> userSubsMap = new Map<String,Id>();
             for (subsUnsubsDataWrapper subsUnsubsRec : subsUnsubsData) {
                 userIDSet.add(subsUnsubsRec.userId);
             }
            
            //Query Email Preference records 
            for(Pricing_IQR_Email_Preferences__c userSub : [Select id,Core_MDF_Module_Nm__c,Pricing_Notification_Name_Nm__c,Pricing_User__c,Pricing_Opt_In_Ind__c from Pricing_IQR_Email_Preferences__c where Pricing_User__c IN : userIDSet]) {
                userSubsMap.put(userSub.Pricing_Notification_Name_Nm__c,userSub.Id);
            }
            
            for (subsUnsubsDataWrapper subsUnsubsRec : subsUnsubsData) {
                String obj = subsUnsubsRec.objectName;
                String notificationName = subsUnsubsRec.notificationName;
                Boolean optInOrOut = subsUnsubsRec.response;
                Id subsRecId = subsUnsubsRec.subsRecId;
                Id usrId = subsUnsubsRec.userId;
                Pricing_IQR_Email_Preferences__c usersubsRecInst = new 	Pricing_IQR_Email_Preferences__c();
                
                //If already IQR Email Preference record exist then update Opt In field
                if(userSubsMap.containskey(notificationName) && userSubsMap.get(notificationName) != null) {
                    usersubsRecInst.Id = userSubsMap.get(notificationName);
                    usersubsRecInst.Pricing_Opt_In_Ind__c = optInOrOut;  
                    //usersubsRecInst.Core_MDF_External_Id__c = userID;
                }
                //Else create new IQR Email Preference record
                else {
                    usersubsRecInst.Pricing_User__c = usrId;
                    usersubsRecInst.Core_MDF_Module_Nm__c = obj;
                    usersubsRecInst.Pricing_Opt_In_Ind__c = optInOrOut;
                    usersubsRecInst.Pricing_Notification_Name_Nm__c = notificationName ;
                    usersubsRecInst.Core_MDF_Subscription_Notification_Type__c = subsRecId;
                    usersubsRecInst.Core_MDF_External_Id__c = usrId + notificationName ;
                }
                
                finalUserSubList.add(usersubsRecInst);              
            }
            upsert finalUserSubList;
            returnValue = 'Success';
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);  
            returnValue = 'Exception'; 
            //throw new AuraHandledException(e.getMessage()); 
                           }
        return returnValue;
    } 
    
    /*****************************************************************************************************                              
Method Name   :        filterUserBasedOnSubscription                              
@return       :        void                             
@parameters   :        Notification type for which the user do not want to receive the notification, Object for which the notification belongs and List of Internal Users,                            
Description   :        List of Filtered Users who want to receive notification except for the notifications selected by them in the Notification User Object.
Added By      :        Accenture - Akanksha - 4 Jun 2024                                                              
******************************************************************************************************/ 
    public static List<Id> filterUserBasedOnSubscription(String notificationType, String objectName, set<Id> inputUserIds) {//inputUserIds
        List<Id> finalListOfSubscribedUsers = new List<Id>();
        // Create a set of user IDs who do not want notifications
        Set<Id> unsubscribedUserIds = new Set<Id>();
        try{
            // Query to fetch user subscriptions who do not want notifications
            if(notificationType!=null && objectName!=null && inputUserIds!=null && inputUserIds.size() > 0){
                
                List<Pricing_IQR_Email_Preferences__c> unsubscribedUsersList = [SELECT  Id,Pricing_User__c,Core_MDF_Module_Nm__c, Pricing_Notification_Name_Nm__c
                                                                                           FROM Pricing_IQR_Email_Preferences__c
                                                                                           WHERE Core_MDF_Module_Nm__c = :objectName
                                                                                           AND Pricing_Notification_Name_Nm__c =:notificationType
                                                                                           AND Pricing_User__c IN :inputUserIds
                                                                                		   AND Pricing_Opt_In_Ind__c = False
                                                                                		   AND Core_MDF_Active_Ind__c = True
                                                                                          ];
                if(unsubscribedUsersList!=null && unsubscribedUsersList.size() > 0){
                    for (Pricing_IQR_Email_Preferences__c subscription : unsubscribedUsersList) {
                        unsubscribedUserIds.add(subscription.Pricing_User__c); 
                    }
                    // Iterate through the original usersList and add only those who are not in unsubscribedUserIds to finalList
                    if(unsubscribedUserIds!=null && unsubscribedUserIds.size()>0){
                        //change to incomingUserLst
                        for (Id userId : inputUserIds) {
                            if (!unsubscribedUserIds.contains(userId)) {
                                finalListOfSubscribedUsers.add(userId);
                            }
                        }
                    }else{
                        finalListOfSubscribedUsers.addAll(inputUserIds);
                    }
                }else{
                    //if there exist no records for the user in the notification subscription object, add all the users to the final list
                    finalListOfSubscribedUsers.addAll(inputUserIds);
                }
            }
            else{
                finalListOfSubscribedUsers.addAll(inputUserIds);
            }
            
        }catch(Exception e){ Core_MDF_CCP_UtilityClass.logError(e);} 
        return finalListOfSubscribedUsers;
    }
   
    public class MailParams{
        
        @InvocableVariable(label = 'UserIdList')
        public List<Id> userIdList = new List<Id>();

         @InvocableVariable(label = 'objectName')
        public List<String> objectName;

         @InvocableVariable(label = 'notificationName')
        public List<String> notificationName;
        
    }
    
     //Method to be called from flow to filterout users 
    @InvocableMethod
    public static List<List<Core_MDF_FlowMapClass>> getExcludedUserList(List<mailParams> paramsList) {//getEmailExcludedUserList
        
        List<String> notificationType = new List<String>();
        List<String> objectName= new List<String>();
        Set<Id> inputUserIds = new Set<Id>();
        Map<String,List<Id>> notificationToUserMap = new Map<String,List<Id>>();
        Map<String,List<String>> notificationToUserEmailMap = new Map<String,List<String>>();
        
        
        for(mailParams params : paramsList){

            notificationType.addAll(params.notificationName);
            objectName.addAll(params.objectName);
        }
        
       
       List<Core_MDF_FlowMapClass> flowMapClassList = new List<Core_MDF_FlowMapClass>();
      
       List<Pricing_IQR_Email_Preferences__c> unsubscribedUsersList = [SELECT  Id,Pricing_User__c,Pricing_User__r.Email, Core_MDF_Module_Nm__c, Pricing_Notification_Name_Nm__c
                                                                                           FROM Pricing_IQR_Email_Preferences__c
                                                                                           WHERE Core_MDF_Module_Nm__c IN :objectName
                                                                                           AND Pricing_Notification_Name_Nm__c IN:notificationType
                                                                                		   AND Pricing_Opt_In_Ind__c = False
                                                                                		   AND Core_MDF_Active_Ind__c = True
                                                                                          ];
       
        

        for(Pricing_IQR_Email_Preferences__c subs : unsubscribedUsersList) {
            
            if(notificationToUserMap.containsKey(subs.Pricing_Notification_Name_Nm__c + ';' +subs.Core_MDF_Module_Nm__c)) {
                notificationToUserMap.get(subs.Pricing_Notification_Name_Nm__c + ';' + subs.Core_MDF_Module_Nm__c).add(subs.Pricing_User__c);
                notificationToUserEmailMap.get(subs.Pricing_Notification_Name_Nm__c + ';' + subs.Core_MDF_Module_Nm__c).add(subs.Pricing_User__r.Email);
                
            }
            else {
                notificationToUserMap.put(subs.Pricing_Notification_Name_Nm__c + ';' + subs.Core_MDF_Module_Nm__c, new List<Id> {subs.Pricing_User__c});
                notificationToUserEmailMap.put(subs.Pricing_Notification_Name_Nm__c + ';' + subs.Core_MDF_Module_Nm__c,new List<String> {subs.Pricing_User__r.Email});
            }
            
            
        }

     for(String key : notificationToUserMap.keySet()) {
             Core_MDF_FlowMapClass mapClass = new Core_MDF_FlowMapClass();
             List<String> str = key.split(';');
             mapClass.notificationType = str[0];
             mapClass.objectName = str[1];
             mapClass.userIdList = notificationToUserMap.get(key);
             mapClass.userEmailList = notificationToUserEmailMap.get(key);
       
             flowMapClassList.add(mapClass);

        }
        List<List<Core_MDF_FlowMapClass>> finalFlowMapList = new List<List<Core_MDF_FlowMapClass>>();
        finalFlowMapList.add(flowMapClassList);
        return finalFlowMapList;
        
    }

    
    
     //method to fetch user List
    @AuraEnabled
    public static List<SObjectResult> getUserList(String userName, String app){
        List<PermissionSetAssignment> userList =new List<PermissionSetAssignment>();
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        List<PermissionSetAssignment> assignedPermissionSets = new  List<PermissionSetAssignment>();
        String appToPermSetMap = Label.Core_MDF_ApplicationToPermissionSetMapping;
		
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(appToPermSetMap);
        String requiredPerSet = jsonMap.containsKey(app) && jsonMap.get(app) !=null ? (String)jsonMap.get(app) : '';
        List<String> requiredPerSetList = requiredPerSet.split(',');
        
        String requiredPerSetStr ='(\'' + String.join(requiredPerSetList, '\', \'') + '\')';
        //We have to take as part WW49 for checkMarx fix
        requiredPerSetStr = requiredPerSetStr.replaceAll('\\\\','');
    
                if(String.isNotEmpty(userName))
                {
                    string searchText = '\'%' + userName + '%\'';
                    String fields = ' Id,AssigneeId,Assignee.Name, Assignee.Email, Assignee.IsActive, Assignee.Partner_License_Reclaimed__c ';  //License Reclaim changes - Roshan
                    String whereClause = ' PermissionSet.Name IN ' +  requiredPerSetStr + ' and Assignee.Name like ' + searchText.trim()+' and (Assignee.IsActive = true or Assignee.Partner_License_Reclaimed__c = true) LIMIT 10';  //License Reclaim changes - Roshan
                    
                    assignedPermissionSets = Core_MDF_CCP_GenericUtility.getPermSetAssignmentList(fields, whereClause);
                    for(PermissionSetAssignment psa : assignedPermissionSets) 
                    {
                        sObjectResultList.add(new SObjectResult(psa.Assignee.Name, psa.AssigneeId, psa.Assignee.Email, psa.Assignee.IsActive, psa.Assignee.Partner_License_Reclaimed__c));
                    }
                }
        return sObjectResultList;
    }

    @AuraEnabled
    public static EmulationWrapper checkEmulationAccessAndGetAppList() {
        
        EmulationWrapper emulationWrap = new EmulationWrapper();
        Id usrId = userInfo.getUserId();
        List<String> assignedPermissionSets = new List<String>();
        List<String> appList = new List<String>();
        Boolean hasEmulationAccess = false;

        try {
        String subscriptionAppJson = Label.Core_MDF_SubsEmulationAccessJson;
		
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(subscriptionAppJson);

        String fields = ' Id,PermissionSet.Name,PermissionSetGroup.DeveloperName,PermissionSet.Profile.Name ';
        String whereClause = '  AssigneeId =\'' + usrId +'\' '; 
        Map<String,List<String>> acccessTypeMap = Core_MDF_CCP_GenericUtility.getUserAccessMap(fields,whereClause);
        assignedPermissionSets = acccessTypeMap.get('PermissionSet');

         
        for(String app : jsonMap.keySet()) {
            String emulationAccessStr = (String)jsonMap.get(app);
            List<String> emulationAccessList = emulationAccessStr.split(',');
            for(String accessName : emulationAccessList) {
               if(assignedPermissionSets != null && assignedPermissionSets.contains(accessName) && !appList.contains(app)) {
                   appList.add(app);
                   hasEmulationAccess = true;
                }
           }

        }
        emulationWrap.appList = appList;
        emulationWrap.hasEmulationAccess = hasEmulationAccess;
        }
        catch(Exception e) {
            Core_MDF_CCP_UtilityClass.logError(e);
            throw new AuraHandledException(e.getMessage());
        }
        return emulationWrap;
        
    }
        
    public class EmulationWrapper {

       @AuraEnabled public Boolean hasEmulationAccess;
       @AuraEnabled public List<String> appList;

    }
        
        
        
    //Wrapper to store Notification data for each Object 
    public class notificationData{
        @AuraEnabled Public string objectName ;
        @AuraEnabled public String objectLabel;
        @AuraEnabled Public List<notificationTypesWrapper> notificationTypes ;
        
    }
    
    //Wrapper to store details for each Notification type
    public class notificationTypesWrapper{
        @AuraEnabled Public string label ;
        @AuraEnabled Public String apiname ;
        @AuraEnabled Public Boolean subscribed = true;
        @AuraEnabled Public Boolean mandateNotification = false;
        @AuraEnabled Public String helpText;
        @AuraEnabled public Id subsRecId;
        
        
    }
    
    //wrapper to store user response for each notification type
    public class subsUnsubsDataWrapper
    {
        @auraenabled
        public string objectName{get;set;}
        @auraenabled
        public string notificationName{get;set;}
        @AuraEnabled
        public Boolean response { get; set; }
        @AuraEnabled 
        public Id subsRecId { get; set; }
        @AuraEnabled 
        public Id userId { get; set; }
    }

    public class SObjectResult {
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public Id userId;
        @AuraEnabled
        public String userEmail;
        @AuraEnabled
        public Boolean userActive;
        @AuraEnabled
        public Boolean userLicenseReclaim;  //License Reclaim changes - Roshan
        
        
        
        public SObJectResult(String name, Id usrId, String email, Boolean active, Boolean licenseReclaim) {
            userName = name;
            userId = usrId;
            userEmail = email;
            userActive = active;
            userLicenseReclaim = licenseReclaim;  //License Reclaim changes - Roshan
        }
        public SObjectResult() {
            
        }
    }
    
    
    
}