// /*******************************************************************************************************************************************************************************************************
// * Class Name  : PMP_SendEmailAlertsForOfferings
// * Description : Stores the logic for sending the email for all offering email scenarios.
// * Version     : 1.0 
// * Created Date: 19-Nov-2020
// * Modification Log :
// * Created By  : Priyanka (Infosys)
// ********************************************************************************************************************************************************************************************************/

public without sharing class PMP_SendEmailAlertsForOfferings {
    
    public static Boolean isWorking() {
        return true;
    }
    
//     //wrapper which holds the offerings and submitter and template details
//     public class SendEmailRequestWrapper {
//         @InvocableVariable(label='Offering Id' description='Offering Id Captured here' required=true)
//         public Id offeringId;
//         @InvocableVariable(label='Template Name' description='Template Name is Captured here' required=true)
//         Public String templateName;
//     }
    
//     /*******************************************************************************************************************************************************************************************************
// * Method Name : sendOfferingEmailNotifications
// * Description : This method will send the email to all offering email scenarios and it is invoked by a process builder -PMP_Offering_StatusChange_Alerts
// * Params	  : SendEmailRequestWrapper[] , which contains template name , offering id, submitter id
// * Version     : 1.0 
// * Created Date: 19-Nov-2020
// * Modification Log :
// * Created By  : Priyanka (Infosys)
// ********************************************************************************************************************************************************************************************************/
    
//     @InvocableMethod(label='Send Emails for Offerings' description='Sends the email to recent submitter of offering')
//     public static void sendOfferingEmailNotifications(List<SendEmailRequestWrapper> offeringAndSubmitterDetails) {

//         //get the Email-Template Name
//         String templateName=offeringAndSubmitterDetails[0].templateName;
        
//         //All offering Ids recieved from process builder
//         List<Id> offeringIds=new List<Id>();
                
//         //userWhatId map (user, List<offeringId>)
//         Map<Id,List<Id>> submitterOfferingIdListMap = new Map<Id,List<Id>>();
        
//         //offering id and offering map used in inactive scenario
//         Map<id,PMP_Partner_Offering__c> offeringMap=new Map<id,PMP_Partner_Offering__c>();
        
//         //form  the userWhatId map (user, offeringId)
//         for(SendEmailRequestWrapper req: offeringAndSubmitterDetails){
//             offeringIds.add(req.offeringId);
//         }

//         // added Variable as part of OPID Restructure to hold the list accounts associated to the Offering
//         Map<Id,Set<Id>> mapOfferingToAccntIdList = new Map<Id,Set<Id>>();
        
//         List<PMP_Partner_Offering__c> offeringList= new List<PMP_Partner_Offering__c>();
//         if(Schema.sObjectType.PMP_Partner_Offering__c.isAccessible()){
//             offeringList=[SELECT Id, PMP_Offering_Submitter_UserId__c,PMP_Company_Id__c FROM PMP_Partner_Offering__c WHERE Id IN:offeringIds];
//         }

//          submitterOfferingIdListMap =getOfferingData(offeringList, submitterOfferingIdListMap, mapOfferingToAccntIdList, offeringMap, templateName);

//         //map to store inactive user and corresponding offerings
//         Map<Id,List<Id>> inActivatedUsersAndOfferingMap= new Map<Id,List<Id>>();
//         List<Id> offeringsForInactiveScenario= new List<Id>();
//         removeInactiveusers(inActivatedUsersAndOfferingMap, offeringsForInactiveScenario, submitterOfferingIdListMap );
    
//         // to send the email to recent submitter and log the email to associated offering.
//         if(!submitterOfferingIdListMap.keySet().isEmpty()){
//             PMP_Utility.sendEmailAndLogDataWithBulkification(templateName, submitterOfferingIdListMap);
//         }
//         //Email Scenarios user is inactive.
//         sendEmailToUser(inActivatedUsersAndOfferingMap, templateName, submitterOfferingIdListMap,offeringMap,offeringsForInactiveScenario,mapOfferingToAccntIdList);	
//     }
	
//     public static  Map<Id, List<Id>> getOfferingData(List<PMP_Partner_Offering__c> offeringList,Map<Id, List<Id>> submitterOfferingIdListMap,Map<Id, Set<Id>> mapOfferingToAccntIdList, 
//         Map<Id, PMP_Partner_Offering__c> offeringMap, String templateName) {               
//             Map<Id,Set<Id>> mapMpiToAccountListActive = getMpiToAccountMapper(offeringList);
//             for (PMP_Partner_Offering__c offering : offeringList) {
//                 processOffering(offering, submitterOfferingIdListMap, mapOfferingToAccntIdList, mapMpiToAccountListActive, templateName);
//                 offeringMap.put(offering.Id, offering);
//             }
            
//             if (checkTemplate(templateName) && !offeringMap.isEmpty()) {
//                 submitterOfferingIdListMap = getGroupPAPADPOEUsers(offeringMap, mapOfferingToAccntIdList);
//             }
//             return  submitterOfferingIdListMap;                  
//     }

//     public static void processOffering(PMP_Partner_Offering__c offering, Map<Id, List<Id>> submitterOfferingIdListMap, Map<Id, Set<Id>> mapOfferingToAccntIdList, Map<Id,Set<Id>>  mapMpiToAccountListActive, String templateName) {
//         if (offering.PMP_Offering_Submitter_UserId__c != null) {
//             processSubmitterOffering(offering, submitterOfferingIdListMap);
            
//             if (shouldAddToOfferingToAccntIdList(offering, mapMpiToAccountListActive)) {
//                 addOfferingToAccntIdList(offering, mapOfferingToAccntIdList, mapMpiToAccountListActive);
//             }
//             return;
//         }
//         if (checkTemplate(templateName) && mapMpiToAccountListActive.containsKey(offering.PMP_Company_Id__c)) {
//             addOfferingToAccntIdList(offering, mapOfferingToAccntIdList, mapMpiToAccountListActive);
//         }
//     }

//     public static boolean checkTemplate(String templateName){
//         if((templateName.contains('PMP_OfferingExpiryFinalReminder'))
//         ||(templateName.contains('PMP_OfferingExpiryFirstReminder'))
//            ||(templateName.contains('PMP_OfferingExpirySecondReminder'))){
//             return true;
//         }
//         return false;
//     }

//     public static void processSubmitterOffering(PMP_Partner_Offering__c offering, Map<Id, List<Id>> submitterOfferingIdListMap) {
//         List<Id> offIds = submitterOfferingIdListMap.get(offering.PMP_Offering_Submitter_UserId__c);
//         if (offIds == null) {
//             offIds = new List<Id>();
//         }
//         offIds.add(offering.Id);
//         submitterOfferingIdListMap.put(offering.PMP_Offering_Submitter_UserId__c, offIds);                                      
//     }

//     public static boolean shouldAddToOfferingToAccntIdList(PMP_Partner_Offering__c offering, Map<Id,Set<Id>> mapMpiToAccountListActive) {
//         return mapMpiToAccountListActive.containsKey(offering.PMP_Company_Id__c);
//     }

//     public static void addOfferingToAccntIdList(PMP_Partner_Offering__c offering, Map<Id, Set<Id>> mapOfferingToAccntIdList, Map<Id,Set<Id>> mapMpiToAccountListActive) {
//         mapOfferingToAccntIdList.put(offering.Id, mapMpiToAccountListActive.get(offering.PMP_Company_Id__c));
//     }

//     public static Map<Id,Set<Id>> getMpiToAccountMapper(List<PMP_Partner_Offering__c> offeringList){
//          Set<Id> companyIds = new Set<Id>();
//          for(PMP_Partner_Offering__c off:offeringList){
//              companyIds.add(off.PMP_Company_Id__c);
//          }
//          // Added as part of OPID Restructure - get the MPI Id using account Using junction Object 
//          List<PMP_OPID_MPI_Rel__c> junctionRecords = PMP_Utility.getJunctionAccountToMpiByCompanyId(companyIds);
//          Map<Id,Set<Id>> mapMpiToAccountListActive = PMP_Utility.getMapMpiToListAccountActive(junctionRecords);
//          return mapMpiToAccountListActive;
//     }

//     public static void removeInactiveusers(Map<Id,List<Id>> inActivatedUsersAndOfferingMap, List<Id> offeringsForInactiveScenario, Map<Id,List<Id>> submitterOfferingIdListMap ){
//         //get all users who have recently submitted offerings
//         Set<Id> userIds= submitterOfferingIdListMap.keySet();
//         //get only active users who have submitted offerings
//         List<Id> activeUsers =PMP_Utility.getActiveUsers(userIds);
//         //remove inactive users from map 
//         for(Id userId:userIds){
//             if(!activeUsers.contains(userId)){
//                 inActivatedUsersAndOfferingMap.put(userId,submitterOfferingIdListMap.get(userId));
//                 offeringsForInactiveScenario.addAll(submitterOfferingIdListMap.get(userId));
//                 submitterOfferingIdListMap.remove(userId);
//             }
//         }
//     }

//     public static void sendEmailToUser(Map<Id,List<Id>> inActivatedUsersAndOfferingMap,String templateName, Map<Id,List<Id>> submitterOfferingIdListMap,Map<id,PMP_Partner_Offering__c> offeringMap, List<Id> offeringsForInactiveScenario, Map<Id,Set<Id>> mapOfferingToAccntIdList){
//         if(inActivatedUsersAndOfferingMap.keySet().size()>0){
//             Core_Apex_EmailNotification__c apexEmailRec = New Core_Apex_EmailNotification__c();            
//             String apexEmailRecName = templateName;  //appeniding the type to the metadata name to fetch the relavant record
//             //querying apexEmail to get the email template name and permission sets required on user to send email
//             apexEmailRec = PMP_Utility.getApexEmailRecord(apexEmailRecName);  
//             List<string> allowedPermissionSets = New List<string>(); //allowed permission sets are stored in the metadata as comma seperate values    
//             allowedPermissionSets = apexEmailRec.Core_Allowed_Permission_Nm__c.split(',');
//             //TWC1824-2917
//             if (checkTemplate(templateName)) 
//             		{
//             			allowedPermissionSets.add('PMP_External_Offering_Editor'); // Added for POE
//                 	}
//             //TWC1824-2917
// 			submitterOfferingIdListMap=getGroupUsers(offeringMap,offeringsForInactiveScenario,allowedPermissionSets,mapOfferingToAccntIdList);
//             if(!submitterOfferingIdListMap.keySet().isEmpty()){
//                 PMP_Utility.sendEmailAndLogDataWithBulkification(templateName, submitterOfferingIdListMap);
//                 }  
//         }
//     }
    
//     public static Map<Id,List<Id>> getGroupUsers(Map<Id, PMP_Partner_Offering__c> offList ,List<Id> offeringsForInactiveScenario, List<String> allowedPermissionSets,Map<Id,Set<Id>> mapOfferingToAccntIdList){
//         //userId and List of offerings Map
//         Set<id> intelAccountIds = New set<id>();
//         Map<id,id> accIdCompInfoMap = new Map<id,id>();
//         Map<Id,List<Id>> companyOfferingList = new Map<Id,List<Id>>();
//         Map<Id, List<Id>> userOfferingList= new Map<Id, List<Id>>();
//         Map<Id,Id> intelAccCompInfoMap= new Map<Id,Id>();
//         //List<Id> listAccountIds = new List<Id>();
//         List<Core_Account_Group_Member__c > pagMemberList = New List<Core_Account_Group_Member__c >();
//         for(PMP_Partner_Offering__c off:offList.values()){
//             if(offeringsForInactiveScenario.contains(off.id)){
//                 // Added as part of OPID Restructure
//                 for(Id accountId : mapOfferingToAccntIdList.get(off.Id)){
//                     accIdCompInfoMap.put(accountId,off.PMP_Company_Id__c);
//                 }
//                 getCompanyOffering(companyOfferingList,off);
//             }
//             //output of the above block is Map<Partner,list of offerings>
//         }
//         if(!accIdCompInfoMap.keySet().isEmpty()){
//             //A Partner account can have multiple accounts under it, get the list of all such junction records  
//             pagMemberList=PMP_Utility.getPagMembers(accIdCompInfoMap.keySet());
//             getIntelAccountInfo(pagMemberList,intelAccCompInfoMap,intelAccountIds,accIdCompInfoMap);

//             List<PermissionSetAssignment> permissionAssignmentList = New List<PermissionSetAssignment>();
//             if(!allowedPermissionSets.isEmpty()){
//                //returns permission set assignments for given permissionset and intelAccounts
//                 permissionAssignmentList= PMP_Utility.getActiveUserOfPermissionSet(intelAccountIds,allowedPermissionSets);
//                 //System.debug('..permissionAssignmentList..'+permissionAssignmentList);
//                 getUserOffering(permissionAssignmentList,userOfferingList,intelAccCompInfoMap,companyOfferingList);
//             }
//         }
//         return userOfferingList;
//     }

//     public static void getCompanyOffering(Map<Id,List<Id>> companyOfferingList,PMP_Partner_Offering__c off){
//         List<Id> offeringIds = companyOfferingList.get(off.PMP_Company_Id__c);
//         if (offeringIds == null) {
//             offeringIds = new List<Id>();
//             companyOfferingList.put(off.PMP_Company_Id__c, offeringIds);
//         }
//         offeringIds.add(off.Id);
//     }
    
//     public static void getIntelAccountInfo( List<Core_Account_Group_Member__c > pagMemberList, Map<Id,Id> intelAccCompInfoMap, Set<id> intelAccountIds,Map<id,id> accIdCompInfoMap ){
//         for(Core_Account_Group_Member__c mem : pagMemberList){
//                 //add the intel account ids to a set. Intel accounts will have contact under them to whom the email needs to be sent.
//                 intelAccountIds.add(mem.Core_Intel_Account_Id__c);
//                 /*A partner account related to the Company Info record can have multiple intel accounts, some contacts will have user associted with them,
// 				(so that tey can login to community)*/
//                 // intelAccCompInfoMap: Key: Intel account Id, Value: PMP_Company__c.id 
//                 intelAccCompInfoMap.put(mem.Core_Intel_Account_Id__c, accIdCompInfoMap.get(mem.Core_Partner_Account_Id__c)); 
//             } 
//     }
    
//     public static void getUserOffering(List<PermissionSetAssignment> permissionAssignmentList,Map<Id, List<Id>> userOfferingList, Map<Id,Id> intelAccCompInfoMap,Map<Id,List<Id>> companyOfferingList){
//       for(PermissionSetAssignment pa : permissionAssignmentList){
//                     /*get the company info record id is required to set whatId while sending email.
// 					  first get the account which is parent of the company info record, and from the compInfoAccIdMap get the
// 					  company info id related */
//                     Id companyId=intelAccCompInfoMap.get(pa.Assignee.AccountId);
//                     userOfferingList.put(pa.AssigneeId,companyOfferingList.get(companyId));  
//                 }  
//     }
	
// 	//TWC1824-2917 -- Method added to fetch users(Partner Admin, Partner Admin Delegate and Partner Offering Editor) for sending offering expiry remainder emails
// 	 public static Map<Id,List<Id>> getGroupPAPADPOEUsers(Map<Id, PMP_Partner_Offering__c> offList, Map<Id,Set<Id>> mapOfferingToAccntIdList){
//         //System.debug('off'+offList);
//         //userId and List of offerings Map
//         Set<id> papoeintelAccountIds = New set<id>();
//         Map<id,id> papoeaccIdCompInfoMap = new Map<id,id>();
//         Map<Id,List<Id>>papoecompanyOfferingList = new Map<Id,List<Id>>();
//         Map<Id, List<Id>> papoeuserOfferingList= new Map<Id, List<Id>>();
//         Map<Id,Id> papoeintelAccCompInfoMap= new Map<Id,Id>();
//         //List<Id> listAccountIds = new List<Id>();
//         List < String > papoePermissionSets = new List < String > {  
//             'PMP_External_Partner_Admin',  
//             'PMP_External_Offering_Editor'  
//         };  
//         List<Core_Account_Group_Member__c > papoepagMemberList = New List<Core_Account_Group_Member__c >();
//         for(PMP_Partner_Offering__c off:offList.values()){
//                 // Added as part of OPID Restructure
//             if(!mapOfferingToAccntIdList.isempty() && mapOfferingToAccntIdList.containskey(off.id)){
//                 for(Id accountId : mapOfferingToAccntIdList.get(off.Id)){
//                     papoeaccIdCompInfoMap.put(accountId,off.PMP_Company_Id__c);
//                 }
//             }
//             getpapCompanyOffering(papoecompanyOfferingList,off);
//             //output of the above block is Map<Partner,list of offerings>
//         }
        
//         if(!papoeaccIdCompInfoMap.keySet().isEmpty()){
//             //A Partner account can have multiple accounts under it, get the list of all such junction records  
//             papoepagMemberList=PMP_Utility.getPagMembers(papoeaccIdCompInfoMap.keySet());
//             getPapIntelCompInfo(papoepagMemberList,papoeintelAccountIds,papoeintelAccCompInfoMap,papoeaccIdCompInfoMap);
//             List<PermissionSetAssignment> papoepermissionAssignmentList = New List<PermissionSetAssignment>();
//             if(!papoePermissionSets.isEmpty()){
//                //returns permission set assignments for given permissionset and intelAccounts
//                papoepermissionAssignmentList= PMP_Utility.getActiveUserOfPermissionSet(papoeintelAccountIds,papoePermissionSets);
//                getPapUseOffering(papoepermissionAssignmentList,papoeintelAccCompInfoMap,papoeuserOfferingList,papoecompanyOfferingList);
                
//             }
//         }
//         return papoeuserOfferingList;
//     }
    
//     public static void getpapCompanyOffering(Map<Id,List<Id>> papoecompanyOfferingList,PMP_Partner_Offering__c off){
//         List<Id> papoeofferingIds = papoecompanyOfferingList.get(off.PMP_Company_Id__c);
//         if (papoeofferingIds == null) {
//             papoeofferingIds = new List<Id>();
//             papoecompanyOfferingList.put(off.PMP_Company_Id__c, papoeofferingIds);
//         }
//         papoeofferingIds.add(off.Id);
//     }
    
//     public static void getPapIntelCompInfo( List<Core_Account_Group_Member__c > papoepagMemberList,Set<id> papoeintelAccountIds,Map<Id,Id> papoeintelAccCompInfoMap,Map<id,id> papoeaccIdCompInfoMap){
//           for(Core_Account_Group_Member__c mem : papoepagMemberList){
//                 //add the intel account ids to a set. Intel accounts will have contact under them to whom the email needs to be sent.
//                 papoeintelAccountIds.add(mem.Core_Intel_Account_Id__c);
//                 /*A partner account related to the Company Info record can have multiple intel accounts, some contacts will have user associted with them,
//                  (so that tey can login to community)*/
//                 // papoeintelAccCompInfoMap: Key: Intel account Id, Value: PMP_Company__c.id 
//                 papoeintelAccCompInfoMap.put(mem.Core_Intel_Account_Id__c, papoeaccIdCompInfoMap.get(mem.Core_Partner_Account_Id__c));
                
//             }
//     }
    
//     public static void getPapUseOffering( List<PermissionSetAssignment> papoepermissionAssignmentList,Map<Id,Id> papoeintelAccCompInfoMap, Map<Id, List<Id>> papoeuserOfferingList, Map<Id,List<Id>>papoecompanyOfferingList){
//         for(PermissionSetAssignment pa : papoepermissionAssignmentList){
//             /*get the company info record id is required to set whatId while sending email.
//             first get the account which is parent of the company info record, and from the compInfoAccIdMap get the
//             company info id related */
//             Id companyId=papoeintelAccCompInfoMap.get(pa.Assignee.AccountId);
//             papoeuserOfferingList.put(pa.AssigneeId,papoecompanyOfferingList.get(companyId));                    
//             }   
//     }
 }