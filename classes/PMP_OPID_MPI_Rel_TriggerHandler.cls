public with sharing class PMP_OPID_MPI_Rel_TriggerHandler extends TriggerHandler {
    
    Map<Id,PMP_OPID_MPI_Rel__c> oldMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.oldMap;
    Map<Id,PMP_OPID_MPI_Rel__c> newMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.newMap;
    
    static final LoggingLevel logLevel = LoggingLevel.DEBUG;
    static final String CORE_MP_STR = System.Label.PMP_Group_Name_Prefix;  
    static final String RECORD_SHARE_ACCESS_LEVEL_EDIT = 'Edit';
    static final String RECORD_SHARE_ACCESS_LEVEL_READ = 'Read';
    static final String USER_PREFIX_ID = '005';
    static final String GROUP_PREFIX_ID = '00G';
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll();
/*
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    Public Static Boolean solutionInsertOpidRecursive= false;
    Public Static Boolean solutionUpdateOpidRecursive= false;
    */
    public override void afterInsert() 
    {   
        Map<Id,PMP_OPID_MPI_Rel__c> oldMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.oldMap;
        Map<Id,PMP_OPID_MPI_Rel__c> newMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.newMap;
        if((mapFunctionalityNameTriggerExecution.containsKey('OPID_MPI_Junction_Status_Handler') && 
           mapFunctionalityNameTriggerExecution.get('OPID_MPI_Junction_Status_Handler').Core_Active__c)){
                PMP_AccountBenefitPartnerUtility.onAccountMpiRelationStatusChange(newMap,oldMap,mapFunctionalityNameTriggerExecution.containsKey('MPI_Benefit_Backfill_Handler') && mapFunctionalityNameTriggerExecution.get('MPI_Benefit_Backfill_Handler').Core_Active__c);
           }
	    
	    // if((mapFunctionalityNameTriggerExecution.containsKey('PMP_OPID_MPI_OfferingSharing_Handler') && 
        //    mapFunctionalityNameTriggerExecution.get('PMP_OPID_MPI_OfferingSharing_Handler').Core_Active__c)){
        //        PMP_Offering_Sharing.onAccountMPIUpsertOfferSharing(newMap,oldMap);
        //    }
	   	/*IPA2.0: US-TWC729-7976*/
         //Start :added by krishna ch for solution OPID redesign changes.
        /*if(mapFunctionalityNameTriggerExecution.containsKey('PSS_OPIDMPI_Rel__c') 
           && mapFunctionalityNameTriggerExecution.get('PSS_OPIDMPI_Rel__c').Core_Active__c){
               PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(trigger.new,oldMap,true,false);
            
        }*/
        //End.
        if(Trigger.isInsert)
        {
            //Calling method shareBasedOnCompanyInfoAccount where sharing is happening based on the Junction Object
             if((mapFunctionalityNameTriggerExecution.containsKey('PMP_Companyinfosharing_handler') && 
           mapFunctionalityNameTriggerExecution.get('PMP_Companyinfosharing_handler').Core_Active__c)){
          		shareBasedOnJunctionObjectInfoAccount(/*oldCompanyInfoList,*/ Trigger.New);
           }
            //TWC3123-654 start

            if(mapFunctionalityNameTriggerExecution.containsKey('reprocessLeadSharing') && 
               mapFunctionalityNameTriggerExecution.get('reprocessLeadSharing').Core_Active__c ){
                   Core_LeadRoutingHandler.reprocessLeadRoutingOnInsert(Trigger.New);
            }
            //TWC3123-654 end.

        }
        
    }
    // Added on 28/09/2021 for OPID Restructure
    // #2 : Check if there is an existing active junction record for the OPID with any MPI. ( yes-throw error; no-insert)
    public override void beforeInsert() 
    {
        // added to prevent duplicate junction records - Sathish
        List<PMP_OPID_MPI_Rel__c> newJunctionList = (List<PMP_OPID_MPI_Rel__c>) Trigger.new;
        for(PMP_OPID_MPI_Rel__c junction : newJunctionList){
            junction.PMP_Account_MPI_Unique_ID__c = junction.PMP_One_Partner_ID__c+'_'+junction.PMP_Marketing_Profile_Id__c;
        }
        
        // System.debug('Working inside before insert');       
        if((mapFunctionalityNameTriggerExecution.containsKey('OPID_MPI_Validation_Handler') && 
        mapFunctionalityNameTriggerExecution.get('OPID_MPI_Validation_Handler').Core_Active__c)){
            PMP_AccountBenefitPartnerUtility.validateMultipleOPIDRelations(Trigger.new);
        }
        
    }
    
    // #3 : Check if there is an existing active junction record for the OPID with any MPI. ( yes-throw error; no-update)
   
    
    public override void beforeUpdate() 
    {

        if((mapFunctionalityNameTriggerExecution.containsKey('OPID_MPI_Validation_Handler') && 
        mapFunctionalityNameTriggerExecution.get('OPID_MPI_Validation_Handler').Core_Active__c)){
            PMP_AccountBenefitPartnerUtility.validateMultipleOPIDRelations(Trigger.new);
        }
        
    } 
    
    
    
    
    public override void afterUpdate() 
    {
        List<PMP_OPID_MPI_Rel__c> inActivatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
        List<PMP_OPID_MPI_Rel__c> ActivatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
       
        Map<Id,PMP_OPID_MPI_Rel__c> oldMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.oldMap;
        Map<Id,PMP_OPID_MPI_Rel__c> newMap = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.newMap;
        if((mapFunctionalityNameTriggerExecution.containsKey('OPID_MPI_Junction_Status_Handler') && 
           mapFunctionalityNameTriggerExecution.get('OPID_MPI_Junction_Status_Handler').Core_Active__c)){
                PMP_AccountBenefitPartnerUtility.onAccountMpiRelationStatusChange(newMap,oldMap,mapFunctionalityNameTriggerExecution.containsKey('MPI_Benefit_Backfill_Handler') && mapFunctionalityNameTriggerExecution.get('MPI_Benefit_Backfill_Handler').Core_Active__c);
           }
	   
	//  if((mapFunctionalityNameTriggerExecution.containsKey('PMP_OPID_MPI_OfferingSharing_Handler') && 
    //        mapFunctionalityNameTriggerExecution.get('PMP_OPID_MPI_OfferingSharing_Handler').Core_Active__c)){
    //            PMP_Offering_Sharing.onAccountMPIUpsertOfferSharing(newMap,oldMap);
    //        }
	   	/*IPA2.0: US-TWC729-7976*/
        //Start :added by krishna ch for solution OPID redesign changes.
        /*if(mapFunctionalityNameTriggerExecution.containsKey('PSS_OPIDMPI_Rel__c') 
           && mapFunctionalityNameTriggerExecution.get('PSS_OPIDMPI_Rel__c').Core_Active__c){
            // Commented by Sathish- as to proceed with opid testing - this logic creating some error 
               PSS_SolutionOPIDRollup.populateMPIOPIDOnSolution(trigger.new,oldMap,false,true);        
        }*/
        //End 
        for(Id singleJunctionRecordId : Trigger.NewMap.keySet())
        {
            PMP_OPID_MPI_Rel__c triggerOldValue = (PMP_OPID_MPI_Rel__c) Trigger.OldMap.get(singleJunctionRecordId);
            PMP_OPID_MPI_Rel__c triggerNewValue = (PMP_OPID_MPI_Rel__c) Trigger.NewMap.get(singleJunctionRecordId);
            
                      
            
                if(triggerOldValue.Is_Active__c == true && triggerNewValue.Is_Active__c == false)
                {   
                    inActivatedJunctionRecords.add(triggerNewValue);
                }
                if(triggerOldValue.Is_Active__c == false && triggerNewValue.Is_Active__c == true)
                {
                    ActivatedJunctionRecords.add(triggerNewValue);
                    
                }
           
           
        }
        
        
            if(inActivatedJunctionRecords != null)
            {
                updatePublicGroupSharingInactive(inActivatedJunctionRecords);
            }
        
       
        
        
        
            if(ActivatedJunctionRecords != null)
            {
                shareBasedOnJunctionObjectInfoAccount(ActivatedJunctionRecords);
            }

		//TWC3123-654 start
        Map<Id,PMP_OPID_MPI_Rel__c> oldMapLead = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.oldMap; 
        if(mapFunctionalityNameTriggerExecution.containsKey('reprocessLeadSharing') && 
           mapFunctionalityNameTriggerExecution.get('reprocessLeadSharing').Core_Active__c ){
               Core_LeadRoutingHandler.reprocessLeadRoutingOnUpdate(Trigger.New,oldMapLead);
           }
        //TWC3123-654 end.
        
                
        
    }
    
    
    public override void beforeDelete() 
    {
        // System.debug('Inside before delete');
        List<PMP_OPID_MPI_Rel__c> inActivatedJunctionRecords = new List<PMP_OPID_MPI_Rel__c>();
        for(PMP_OPID_MPI_Rel__c singleJunctionRecordId : (List<PMP_OPID_MPI_Rel__c>)Trigger.Old)
        {
            // System.debug('Value of singleJunctionRecordId.Is_Active__c ::'+singleJunctionRecordId.Is_Active__c);
            if(singleJunctionRecordId.Is_Active__c == false)
            {
                inActivatedJunctionRecords.add(singleJunctionRecordId);
            }
            else if(singleJunctionRecordId.Is_Active__c == true)
            {
                // System.debug('before adding error message ');
                singleJunctionRecordId.Is_Active__c.addError('Junction record is active');
            }
            
        }
        if(inActivatedJunctionRecords != null)
        {
            updatePublicGroupSharingInactive(inActivatedJunctionRecords);
        }
        //TWC3123-654 start
        /*Map<Id,PMP_OPID_MPI_Rel__c> oldMapLead = (Map<Id,PMP_OPID_MPI_Rel__c>) Trigger.oldMap; 
        if(mapFunctionalityNameTriggerExecution.containsKey('reprocessLeadSharing') && 
                   mapFunctionalityNameTriggerExecution.get('reprocessLeadSharing').Core_Active__c ){
                    Core_LeadRoutingHandler.reprocessLeadRoutingOnDelete(oldMapLead);
        }*/
        //TWC3123-654 end.
    }
    
    
   
    
    
    
    
    
    /************************ Method to share company info record based Junction Object account*******************/
    @TestVisible private static void shareBasedOnJunctionObjectInfoAccount(List<PMP_OPID_MPI_Rel__c> OPIDToMPIJunctionObj){
            
        //Map of partner account to set of company info record which is suppose to be share with that pag based on Junction Object record.
        Map<Id, set<Id>> partnerAccIdToCompanyInfoRecordsMap = new Map<Id, set<Id>>();
        String publicGroupName = '';
        Set<String> publicGroupNameToBeAddedSet = new Set<String>();
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> companyProfileIds = new Set<Id>();
        for(PMP_OPID_MPI_Rel__c singleJunctionObject : OPIDToMPIJunctionObj) 
        {
            setAccountIds.add(singleJunctionObject.PMP_One_Partner_ID__c);
            companyProfileIds.add(singleJunctionObject.PMP_Marketing_Profile_Id__c);
            // System.debug('Value of Working copy ::'+singleJunctionObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c);
        }
        
        //Map<Id,Account> mapPartnerAccount = new Map<Id,Account>([Select Id From Account where Id IN: setAccountIds AND RecordType.DeveloperName = 'Core_Partner_Account_Group']);
        
        Map<Id,PMP_Company__c> mapComponayProfile = new Map<Id,PMP_Company__c>([Select Id,PMP_Is_Published_Ind__c,PMP_Is_Working_Copy_Ind__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Is_Working_Copy_Ind__c,PMP_Working_Copy_Id__r.Id,PMP_Working_Copy_Id__r.PMP_Is_Published_Ind__c From PMP_Company__c where Id IN: companyProfileIds]);
       //system.debug('Values of mapComponayProfile : '+mapComponayProfile);
        map<Id,Id> MPIPCToWCMap = new Map<Id,Id>();
        for(Id singleMPIRecordsId: mapComponayProfile.keySet())
        {
            PMP_Company__c singleMPIRecords = mapComponayProfile.get(singleMPIRecordsId);
            // system.debug('Values of singleMPIRecords : '+singleMPIRecords);
            if(singleMPIRecords.PMP_Working_Copy_Id__r.Id != null)
            {
                sObject sobjectRecordForWorkingCopy = singleMPIRecords.PMP_Working_Copy_Id__r.Id.getSObjectType().newSObject(singleMPIRecords.PMP_Working_Copy_Id__r.Id);
                PMP_Company__c workingCopyRecord = (PMP_Company__c) sobjectRecordForWorkingCopy;
                workingCopyRecord.PMP_Is_Working_Copy_Ind__c = singleMPIRecords.PMP_Working_Copy_Id__r.PMP_Is_Working_Copy_Ind__c;
                // System.debug('Value of workingCopyRecord ::'+workingCopyRecord);
                mapComponayProfile.put(workingCopyRecord.Id,workingCopyRecord);
                MPIPCToWCMap.put(singleMPIRecords.Id,workingCopyRecord.Id);
                // system.debug('Values of mapComponayProfile : '+mapComponayProfile);
            }
        }
        
        
        for(PMP_OPID_MPI_Rel__c singleJunctionObject : OPIDToMPIJunctionObj) 
        {
            // system.debug('Value of singleJunctionObject : :' +singleJunctionObject);
            // system.debug('Value of singleJunctionObject.PMP_Marketing_Profile_Id__r : :' +singleJunctionObject.PMP_Marketing_Profile_Id__c);
            // system.debug('Value of singleJunctionObject.PMP_Marketing_Profile_Id__r : :' +singleJunctionObject.PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c);
            if(singleJunctionObject.PMP_One_Partner_ID__c != null && singleJunctionObject.Is_Active__c == true /* && mapPartnerAccount.keySet().contains(singleJunctionObject.PMP_One_Partner_ID__c )*/)
            {
                if(!partnerAccIdToCompanyInfoRecordsMap.containsKey(singleJunctionObject.PMP_One_Partner_ID__c)) 
                {
                    publicGroupName = CORE_MP_STR + singleJunctionObject.PMP_One_Partner_ID__c;
                    publicGroupNameToBeAddedSet.add(publicGroupName);
                    set<Id> temp = new Set<Id>();
                    temp.add(singleJunctionObject.PMP_Marketing_Profile_Id__c);
                    if(MPIPCToWCMap.containsKey(singleJunctionObject.PMP_Marketing_Profile_Id__c))
                    {
                        temp.add(MPIPCToWCMap.get(singleJunctionObject.PMP_Marketing_Profile_Id__c));
                    }
                    // System.debug('Value of temp ::'+temp);
                    partnerAccIdToCompanyInfoRecordsMap.put(singleJunctionObject.PMP_One_Partner_ID__c, temp);
                    //System.debug('Value of partnerAccIdToCompanyInfoRecordsMap ::'+JSON.serializePretty(partnerAccIdToCompanyInfoRecordsMap));
                }
                else
                {
                    partnerAccIdToCompanyInfoRecordsMap.get(singleJunctionObject.PMP_One_Partner_ID__c).add(singleJunctionObject.PMP_Marketing_Profile_Id__c);
                }
            }
        }
            // End US709757 Avanish
            if(publicGroupNameToBeAddedSet != null && !publicGroupNameToBeAddedSet.isEmpty())
            {
                
                Set<String> publicGroupNameToBeAdded = new Set<String>();
                publicGroupNameToBeAdded.addAll(publicGroupNameToBeAddedSet);
                
                //Create the needed public group(s) if it doesn't exist
                List<Group> queriedGrps = PMP_Batch_Group_Management.createPublicGroups(publicGroupNameToBeAdded);
            
                Map<String, Id> groupDevNameToGrpId = new Map<String, Id>();
                
                // Create a map of public group developer name to corresponding group id
                for(Group groupRec : queriedGrps)
                {
                    groupDevNameToGrpId.put(groupRec.DeveloperName , groupRec.Id);
                }
                
                Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords = new Map<Id, Set<PMP_Company__c>>();
                if(OPIDToMPIJunctionObj != null && !OPIDToMPIJunctionObj.isEmpty())
                {
                	for(PMP_OPID_MPI_Rel__c singleJunctionObject : OPIDToMPIJunctionObj)
                	{
                    	Set<Id> temp = partnerAccIdToCompanyInfoRecordsMap.containsKey(singleJunctionObject.PMP_One_Partner_ID__c)?partnerAccIdToCompanyInfoRecordsMap.get(singleJunctionObject.PMP_One_Partner_ID__c):new Set<Id>();// added by sathish to fix null pointer exception
                    	Set<PMP_Company__c> compayInfoRecords = new Set<PMP_Company__c>();
                    	for(Id singleMPIRecords: temp)
                    	{
                        	compayInfoRecords.add(mapComponayProfile.get(singleMPIRecords));
                    	}
                    
                   		if(compayInfoRecords != null && !compayInfoRecords.isEmpty())
                    	{
                        String groupDevName = CORE_MP_STR + singleJunctionObject.PMP_One_Partner_ID__c;
                        
                        if(!String.isBlank(groupDevName))
                        	{
                            Id grpIdRec = groupDevNameToGrpId.get(groupDevName);
                           		if(grpIdRec != null)
                            	{
                               		groupIdToCompanyInfoRecords.put(grpIdRec, compayInfoRecords);
                               	}       
                        	}
                    	}
                	}
                }
                
                
                
                //Check if groupIdToCompanyInfoRecords is not null then call createSharingRecords method
                if(groupIdToCompanyInfoRecords != null && !groupIdToCompanyInfoRecords.isEmpty())
                {
                    createSharingRecords(groupIdToCompanyInfoRecords);
                }   

            }
            
        //}//end of if
        
    }// end of method

    
    /********************** Method to create sharing records **********************************************/
    @TestVisible private static void createSharingRecords(Map<Id, Set<PMP_Company__c>> groupIdToCompanyInfoRecords){
        //System.debug('Value of groupIdToCompanyInfoRecords ::'+JSON.serializePretty(groupIdToCompanyInfoRecords));
       
        List<PMP_Company__Share> partCompanyInfoShareList = new List<PMP_Company__Share>();

        if(groupIdToCompanyInfoRecords !=null && !groupIdToCompanyInfoRecords.isEmpty()){
            for(Id groupIdRecord : groupIdToCompanyInfoRecords.keySet()){
                Set<PMP_Company__c> companyInfoRecords = groupIdToCompanyInfoRecords.get(groupIdRecord);
                if(companyInfoRecords != null && !companyInfoRecords.isEmpty()){
                    for(PMP_Company__c companyInfoRecordId : companyInfoRecords){
                        
                        if(companyInfoRecordId.PMP_Is_Published_Ind__c==true){
                              PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                              partCompanyInfoShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL_READ;
                              partCompanyInfoShare.UserOrGroupId  = groupIdRecord;
                              partCompanyInfoShare.ParentId = companyInfoRecordId.Id;
                              partCompanyInfoShareList.add(partCompanyInfoShare);
                        }
                        else if(companyInfoRecordId.PMP_Is_Working_Copy_Ind__c==true){
                             PMP_Company__Share partCompanyInfoShare = new PMP_Company__Share();
                             partCompanyInfoShare.AccessLevel  = RECORD_SHARE_ACCESS_LEVEL_EDIT;
                             partCompanyInfoShare.UserOrGroupId  = groupIdRecord;
                             partCompanyInfoShare.ParentId = companyInfoRecordId.Id;
                             partCompanyInfoShareList.add(partCompanyInfoShare); 
                        }
                        
                    }
                }
            }
        }
        
       
       String jsonString = json.serialize(partCompanyInfoShareList);
       //Calling sharePartnerCompanyInfo method to share company info record
       sharePartnerCompanyInfo(jsonString);
        
        
    }
    
    
    /**************************Method to create company share record*****************************/
    //@future
    @TestVisible private static void sharePartnerCompanyInfo(String jsonString){
        
        List<PMP_Company__Share> partCompanyInfoShareList 
                = (List<PMP_Company__Share>)Json.deserialize(jsonString,List<PMP_Company__Share>.class);
        

        if(partCompanyInfoShareList != null && !partCompanyInfoShareList.isEmpty()){
            Database.SaveResult[] srList = Database.insert(partCompanyInfoShareList, false);
        
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    // System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        // System.debug('The following error has occurred.');                    
                        // System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        // System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
    }
    
    
    

    
    
    @TestVisible public static void updatePublicGroupSharingInactive(List<PMP_OPID_MPI_Rel__c> inActivatedJunctionRecords)
    {
        PMP_Utility utilityHelper = new PMP_Utility();
        Map<Id,List<PMP_Company__c>> OPIDToListMPIWCandPC = utilityHelper.getAllAccountRelatedToMPI_WCandPC(inActivatedJunctionRecords);
        //System.debug('Value of returned OPIDToListMPIWCandPC :: '+JSON.serializePretty(OPIDToListMPIWCandPC));
        if(OPIDToListMPIWCandPC != null)
        {
            deleteSharingRecords(OPIDToListMPIWCandPC);
        }
        
    }
        
    
    
    
    
    /*********************** Method to delete sharing of company info record who are eligible to be deleted**********************/
    
    @TestVisible private static void deleteSharingRecords(Map<Id, List<PMP_Company__c>> groupIdToCompanyInfoRecords){
        

        List<PMP_Company__Share> partCompanyInfoDeleteList = new List<PMP_Company__Share>();
        List<PMP_Company__Share> finalCompanyInfoDeleteList = new List<PMP_Company__Share>();
        //Map<Id, Id> accIdToPartnerAccIdMap = new Map<Id, Id>();
        //Set<Id> allGroupIds = new Set<Id>(); 
        //Map<PMP_Company__c, Id> companyInfoIdToGrpId = new Map<PMP_Company__c, Id>();
        Map<Id, String> grpIdToGroupDevName = new Map<Id, String>();
        Set<PMP_Company__c> allCompanyInfoIds = new Set<PMP_Company__c>();
        
        //Forming a map of company info to thier group id
        for(Id groupId : groupIdToCompanyInfoRecords.keySet()){
            List<PMP_Company__c> tempCompanyInfoIds = groupIdToCompanyInfoRecords.get(groupId);
            allCompanyInfoIds.addAll(tempCompanyInfoIds);
            
        }
        //System.debug('Value of allCompanyInfoIds ::'+allCompanyInfoIds.size());
        
       
        //Get Company info delete list        
        if(groupIdToCompanyInfoRecords !=null && !groupIdToCompanyInfoRecords.isEmpty()){
            
            partCompanyInfoDeleteList = [Select AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM PMP_Company__Share
                                        where ParentId in :allCompanyInfoIds];
            
        }
        // System.debug('Value of partCompanyInfoDeleteList ::'+partCompanyInfoDeleteList);
       
        List<Id> groupIds = new List<Id>();
        for(PMP_Company__Share partCompanyInfoDeleteRec : partCompanyInfoDeleteList){
            if(partCompanyInfoDeleteRec.UserOrGroupId != null)
                groupIds.add(partCompanyInfoDeleteRec.UserOrGroupId);
        }
        
        List<Group> queriedGrps1 = new List<Group>();
        if(groupIds!=null && !groupIds.isEmpty()){
            queriedGrps1=[SELECT Id,DeveloperName,Name FROM Group where Id in :groupIds];
        }
        List<Group> queriedGrps = new List<Group>();
        
        for(Group singleGroup: queriedGrps1)
        {
            // System.debug('Value of singleGroup ::'+singleGroup);
            String singlegroupDeveloperName = singleGroup.DeveloperName;
            for(Id opId : groupIdToCompanyInfoRecords.keySet())
            {
                if(singlegroupDeveloperName.contains(opId))
                {
                    //System.debug('Value of groupId ::'+singleGroup);
                    queriedGrps.add(singleGroup);
                }
            }
        }
        //System.debug('Value of queriedGrps ::'+queriedGrps);
        
        // Create a map of public group developer name to corresponding group id
        for(Group groupRec : queriedGrps){
            if(groupRec.Id != null && groupRec.DeveloperName != null)
                grpIdToGroupDevName.put(groupRec.Id, groupRec.DeveloperName);
        }
        
        Map<Id, List<PMP_Company__Share>> groupIdToSharingRecMap = new Map<Id, List<PMP_Company__Share>>();
        
        for(PMP_Company__Share pmpCompanyShare : partCompanyInfoDeleteList){
            
            String tempGroupId = pmpCompanyShare.UserOrGroupId;

            if(tempGroupId != null && groupIdToCompanyInfoRecords != null && !tempGroupId.startsWith(USER_PREFIX_ID) 
              && tempGroupId.startsWith(GROUP_PREFIX_ID) && grpIdToGroupDevName != null 
              && grpIdToGroupDevName.get(tempGroupId) != null 
              && grpIdToGroupDevName.get(tempGroupId).startsWith(CORE_MP_STR)
              && !groupIdToCompanyInfoRecords.keySet().contains(tempGroupId)){
                
                //Map of groupId to their sharing record
                // System.debug('Value of tempGroupId in loop '+tempGroupId);
                // System.debug('Value of pmpCompanyShare '+pmpCompanyShare);
                if(groupIdToSharingRecMap.containsKey(tempGroupId) && groupIdToSharingRecMap.get(tempGroupId) != null)
                {
                    List<PMP_Company__Share> pmpCompanyShareList = groupIdToSharingRecMap.get(tempGroupId);
                    pmpCompanyShareList.add(pmpCompanyShare);
                    groupIdToSharingRecMap.put(tempGroupId,pmpCompanyShareList); 
                }
                else
                {
                    groupIdToSharingRecMap.put(tempGroupId, new List<PMP_Company__Share> {pmpCompanyShare});
                }
                // System.debug('Value of groupIdToSharingRecMap ::'+groupIdToSharingRecMap);
                
                  
            }
        }
        for(Id singleGoupIds : groupIdToSharingRecMap.keySet())
        {
            finalCompanyInfoDeleteList.addAll(groupIdToSharingRecMap.get(singleGoupIds));   
        }
        //System.debug('Value of finalCompanyInfoDeleteList ::'+JSON.serializePretty(finalCompanyInfoDeleteList));
        if(finalCompanyInfoDeleteList != null){
            String jsonString = json.serialize(finalCompanyInfoDeleteList);
            //Calling unSharePartnerCompanyInfo method to delete the sharing
            unSharePartnerCompanyInfo(jsonString);
        } 
    }
    
    
   /**************************Method to Delete company share record*****************************/ 
    //@future
    @TestVisible private static void unSharePartnerCompanyInfo(String jsonString){
        List<PMP_Company__Share> partCompanyInfoDeleteShareList 
                = (List<PMP_Company__Share>)Json.deserialize(jsonString,List<PMP_Company__Share>.class);
        //System.debug('Value of jsonString ::'+jsonString);
        if(partCompanyInfoDeleteShareList != null && !partCompanyInfoDeleteShareList.isEmpty())
            Database.delete(partCompanyInfoDeleteShareList, false);
    }
    

}