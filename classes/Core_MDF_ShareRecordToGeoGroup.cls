/****************************************************************************************************************************************
* Class Name  : Core_MDF_ShareRecordToGeoGroup 
* Version     : 1.0   
* Created Date: 14-10-2019
* Modification Log :
* Developer               Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - SM         14-10-2019                    Created Core_MDF_ShareRecordToGeoGroup for Geo based sharing Utility Methods      
*****************************************************************************************************************************************/
public without sharing class Core_MDF_ShareRecordToGeoGroup {
    private Static String underscore = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Underscore');
    private Static String IPATechnicalProgram=Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Technical_program_name');
    /***************************************************************************************************** 
Method Name:        ShareRecordToGeoGroup
@return  :          void
@parameters:        List of Core_MDF_RecordGeoShare
Description:        This method is used to perform Geo Based Sharing for a record
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    
    public static Map<String,List<String>> programGroupMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupMapRO = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupBudgetTypeMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGroupBudgetTypeMapRO = new Map<String,List<String>>();
    public static Map<String,List<String>> programGeoBudgetTypeMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGeoBudgetTypeMapRO = new Map<String,List<String>>();
    public static Map<String,List<String>> programGeoMap = new Map<String,List<String>>();
    public static Map<String,List<String>> programGeoMapRO = new Map<String,List<String>>();
    
    public static void shareRecordToGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {

        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();

        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && updatedRecordGeoShareLst.size()>0)
        {
            for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
            {
               //Check acccesslevel for Edit Groups
               if(rec.accessLevelForEditGrps != NULL && rec.accessLevelForEditGrps.equalsIgnoreCase('READ'))
               {
                 if(recordGeoShareMapRO.containsKey(rec.recordId)){
                    recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId);
                  }
                  else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId.clone());
                   }
               }
               else
               {
                if(recordGeoShareMap.containsKey(rec.recordId)){
                    recordGeoShareMap.get(rec.recordId).addAll(rec.groupId);
                }
                else{
                    recordGeoShareMap.put(rec.recordId, rec.groupId.clone());
                }
               }
                
                if(recordGeoShareMapRO.containsKey(rec.recordId)){
                    recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId_RO);
                }
                else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId_RO.clone());
                }
                
            }    
        }

        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Edit Access
        if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Read Access
        if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInstRead);
        }
    }
    

    public static List<sObject> shareRecordToGeoGroupforBatch(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        List<sObject> shareRecordList = new List<sObject>();

        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && updatedRecordGeoShareLst.size()>0)
        {
            for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
            {
                if(recordGeoShareMap.containsKey(rec.recordId)){
                    recordGeoShareMap.get(rec.recordId).addAll(rec.groupId);
                }
                else{
                    recordGeoShareMap.put(rec.recordId, rec.groupId.clone());
                }
                if(recordGeoShareMapRO.containsKey(rec.recordId)){
                    recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId_RO);
                }
                else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId_RO.clone());
                }
                
            }    
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Edit Access
        if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            List<sObject> geoShareRecordList = Core_MDF_GenericShareRecordActionClass.createShareRecordListforBatch(rmsInst);
            shareRecordList.addAll(geoShareRecordList);
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Read Access
        if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read','Manual');
            List<sObject> geoShareReadRecordList = Core_MDF_GenericShareRecordActionClass.createShareRecordListforBatch(rmsInstRead);
            shareRecordList.addAll(geoShareReadRecordList);
        }

        return shareRecordList;

    }

    /***************************************************************************************************** 
Method Name:        addGroupstoRecordGeoShareLst
@return  :          void
@parameters:        List of Core_MDF_RecordGeoShare
Description:        This method is used to add the corresponding group id's for each record
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    public static List<Core_MDF_RecordGeoShare> addGroupstoRecordGeoShareLst(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        programGroupBudgetTypeMap.clear();
        programGroupBudgetTypeMapRO.clear();
        programGeoBudgetTypeMap.clear();
        programGeoBudgetTypeMapRO.clear();
        programGeoMap.clear();
        programGeoMapRO.clear();
        Set<string> programSet = new Set<string>();
        Map<String,String> pgmGeoSubGeoBudgetTypeGrpMap = new Map<String,String>();
        Map<String,String> pgmGeoSubGeoBudgetTypeGrpMapRO = new Map<String,String>();
        Map<String,String> pgmBudgetTypeGrpMap = new Map<String,String>();
        Map<String,String> pgmBudgetTypeGrpMapRO = new Map<String,String>();
        //Map to store if a program requires sub geo sharing
        Map<String,Boolean> pgmSubGeoShareReq = new Map<String,Boolean>();
        Set<String> grpNames = new Set<String>();
        Set<String> geoSubGeoNames = new Set<String>();
        Map<String,Set<String>> progToBudgetTypesMap = new Map<String,Set<String>>();
        Set<string> budgettypeSet = new Set<String>();        
        //List to store all the objects that do not require Geo-based sharing
        List<String> objectsForAllGeoSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_Objects_for_RO_All_Geo_Sharing');
        List<String> objectsForHostRegSharing = Core_MDF_CustomLabelConfig.getTextList('Core_MDF_HostRegionSharingReqObj');
        for(Core_MDF_RecordGeoShare shareRec : recordGeoShareLst)
        {
            programSet.add(shareRec.program);
        }
        //to get all the groups of the incoming programs
        for(Core_MDF_ProgramGeoGroupMap__mdt rec:[SELECT Core_MDF_Group_Name__c, Core_MDF_Group_Name_RO__c, Core_MDF_Program__c,Core_MDF_Region__c,
                                                  Core_MDF_Sub_Region__c,Core_MDF_Check_SubGeo__c,Core_MDF_Budget_Type_txt__c
                                                  From Core_MDF_ProgramGeoGroupMap__mdt where Core_MDF_Program__c in :programSet])
        {
            
            //to populate the Sub geo group maps with the group data
            if(rec.Core_MDF_Region__c!=null){
                
                if(rec.Core_MDF_Check_SubGeo__c)
                {
                    //to populate the geo+subgeo+budgetType group maps with the group data Eg: IPA ASMO LAR SPAI, IPA ASMO LAR SPAI RO
                    if(rec.Core_MDF_Budget_Type_txt__c!=null)
                    {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Sub_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name__c);
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Sub_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name_RO__c); 
                        addToProgramBudgetTypeGrpMap(rec);
                        
                        if(progToBudgetTypesMap.containsKey(rec.Core_MDF_Program__c))
                        {
                            progToBudgetTypesMap.get(rec.Core_MDF_Program__c).add(rec.Core_MDF_Budget_Type_txt__c);
                               
                        }
                        else
                        {
                            progToBudgetTypesMap.put(rec.Core_MDF_Program__c,new set<String>{rec.Core_MDF_Budget_Type_txt__c});
                        }
                    }
                    else
                    {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name__c);//CCF_ASMO_NAR, ASMO NAR
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Sub_Region__c, rec.Core_MDF_Group_Name_RO__c);  
                    }
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    geoSubGeoNames.add(rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Sub_Region__c);
                    //pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    if(pgmSubGeoShareReq.containsKey(rec.Core_MDF_Region__c)){
                        if(!pgmSubGeoShareReq.get(rec.Core_MDF_Region__c))
                            pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    }
                    else{
                        pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    }
                }
                //to populate the geo group maps with the group data
                else
                {  
                    //to populate the geo+budgetType group maps with the group data Eg: IPA APJ SPAI, IPA APJ SPAI RO
                    if(rec.Core_MDF_Budget_Type_txt__c!=null)
                    {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name__c);
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, rec.Core_MDF_Group_Name_RO__c); 
                        addToProgramBudgetTypeGrpMap(rec);
                        if(progToBudgetTypesMap.containsKey(rec.Core_MDF_Program__c))
                        {
                            progToBudgetTypesMap.get(rec.Core_MDF_Program__c).add(rec.Core_MDF_Budget_Type_txt__c);
                        }
                        else
                        {
                            progToBudgetTypesMap.put(rec.Core_MDF_Program__c,new set<String>{rec.Core_MDF_Budget_Type_txt__c});
                        }
                    } 
                    else
                    {
                        pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name__c); // CCF_APJ, APJ ALL
                        pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c, rec.Core_MDF_Group_Name_RO__c);// CCF_APJ, APJ ALL RO
                    }
                    grpNames.add(rec.Core_MDF_Group_Name__c);
                    grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                    //pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, false);
                    if(pgmSubGeoShareReq.containsKey(rec.Core_MDF_Region__c)){
                        if(!pgmSubGeoShareReq.get(rec.Core_MDF_Region__c))
                            pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    }
                    else{
                        pgmSubGeoShareReq.put(rec.Core_MDF_Region__c, rec.Core_MDF_Check_SubGeo__c);
                    }
                    geoSubGeoNames.add(rec.Core_MDF_Region__c);
                }
                
            }
            //for groups without geo eg. CCF ALL, DCF ALL
            else
            {
                grpNames.add(rec.Core_MDF_Group_Name__c);
                grpNames.add(rec.Core_MDF_Group_Name_RO__c);
                pgmGeoSubGeoBudgetTypeGrpMap.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name__c);
                pgmGeoSubGeoBudgetTypeGrpMapRO.put(rec.Core_MDF_Program__c,rec.Core_MDF_Group_Name_RO__c);
            }
        } 
        //Map to store the GroupName and their corresponding Id.
        Map<string,Id> grpNametoIdMap = new Map<string,Id>();
        for(Group grp:[SELECT Id, DeveloperName FROM Group where DeveloperName IN :grpNames])
        {
            grpNametoIdMap.put(grp.DeveloperName, grp.Id);
        }
        //To Loop thro each incoming record and store the groups that it should be shared with
        for(Core_MDF_RecordGeoShare record: recordGeoShareLst)
        {  
            //to store rw group id's
            List<Id> grpLst = new List<Id>();
            //to store ro group id's
            List<Id> grpLstRO = new List<Id>();
               
            if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+record.geo))
            {
                if(record.budgetType != null){
                    
                    if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+record.geo+underscore+record.budgetType))
                    {
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.budgetType)))
                        {
                            grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.budgetType)));
                        }
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.budgetType)))
                        {
                            grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.budgetType)));
                        }  
                    }
                    if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+'WW'+underscore+record.budgetType)){
                         if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+'WW'+underscore+record.budgetType)))
                        {
                            grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+'WW'+underscore+record.budgetType)));
                        }
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+'WW'+underscore+record.budgetType)))
                        {
                            grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+'WW'+underscore+record.budgetType)));
                        } 
                    }
                }
                if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo)))
                {
                    grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo)));
                }
                if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo)))
                {
                    grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo)));
                }
            }
            //else 
            if(pgmSubGeoShareReq != null &&  pgmSubGeoShareReq.containsKey(record.geo) && pgmSubGeoShareReq.get(record.geo) 
                    && pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+record.geo+underscore+record.subGeo)) 
            {
                if(record.budgetType != null){
                    if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+record.geo+underscore+record.subGeo+System.Label.Core_MDF_Underscore+record.budgetType))
                    {
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.subGeo+underscore+record.budgetType)))
                        {
                            grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.subGeo+underscore+record.budgetType)));
                        }
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.subGeo+underscore+record.budgetType)))
                        {
                            grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.subGeo+underscore+record.budgetType)));
                        }
                    }
                     if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program+underscore+'WW'+underscore+record.budgetType)){
                         if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+'WW'+underscore+record.budgetType)))
                        {
                            grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+'WW'+underscore+record.budgetType)));
                        }
                        if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+'WW'+underscore+record.budgetType)))
                        {
                            grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+'WW'+underscore+record.budgetType)));
                        } 
                    }
                }
                if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.subGeo)))
                {
                    grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+record.geo+underscore+record.subGeo)));
                }
                if((grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.subGeo))))
                {
                    grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+record.geo+underscore+record.subGeo)));
                }
            }
            if(pgmGeoSubGeoBudgetTypeGrpMap.containsKey(record.program))
            {
                if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program)))
                {
                    grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program)));
                }
                if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program)))
                {
                    grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program)));
                }
            }

            //In case of objects that need to be shared to all the Geo groups.
            if(objectsForAllGeoSharing.contains(objectName) && (record.program!=Label.Core_MDF_Retail_Channel_Program_Name) && (record.program!=IPATechnicalProgram) &&
               (record.program != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name') && (record.program != Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') )))
            {
                /*for(String grpNm : pgmGeoSubGeoBudgetTypeGrpMap.values())
                {   
                    if(grpNametoIdMap.containsKey(grpNm))
                    {
                        grpLst.add(grpNametoIdMap.get(grpNm));
                    }
                }
                for(String grpNmRO : pgmGeoSubGeoBudgetTypeGrpMapRO.values())
                {   
                    if(grpNametoIdMap.containsKey(grpNmRO))
                    {
                        grpLstRO.add(grpNametoIdMap.get(grpNmRO));
                    }
                }*/
                for(String geo : geoSubGeoNames){
                    if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+geo)))
                    {
                        grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+geo)));
                    }
                    if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+geo)))
                    {
                        grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+geo)));
                    }
                }
            } 
            //In case of objects that need to be shared to all the Geo groups.
            if(objectsForAllGeoSharing.contains(objectName) && ((record.program==IPATechnicalProgram && ((String.isBlank(record.geo) && objectsForHostRegSharing.contains(objectName)) || !objectsForHostRegSharing.contains(objectName))) || (record.program== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_EEF_Program_Name')) || (record.program== Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') )))
                
            {

                
                //for(List<String> groupNames: programGroupBudgetTypeMap.values())   
                if(record.budgetType!=null && programGroupBudgetTypeMap.containsKey(record.program+underscore+record.budgetType))
                {
                    for(String grpNameBudgetType : programGroupBudgetTypeMap.get(record.program+underscore+record.budgetType))
                    {   
                        if(grpNametoIdMap.containsKey(grpNameBudgetType))
                        {
                            grpLst.add(grpNametoIdMap.get(grpNameBudgetType));
                        }
                    }
                }else if(record.budgetType==null && progToBudgetTypesMap.containsKey(record.program) && progToBudgetTypesMap.get(record.program) != null){

                    for(String budgetType : progToBudgetTypesMap.get(record.program))
                    {   
                        if(programGroupBudgetTypeMap.containsKey(record.program+underscore+budgetType)){
                           
                            for(String grpName : programGroupBudgetTypeMap.get(record.program+underscore+budgetType))
                            {
                                if(grpNametoIdMap.containsKey(grpName))
                                {
                                    grpLst.add(grpNametoIdMap.get(grpName));
                                }
                            }
                        }
                    }
                } 
                //for(List<String> groupNamesRo: programGroupBudgetTypeMapRo.values())
                if(record.budgetType!=null && programGroupBudgetTypeMapRO.containsKey(record.program+underscore+record.budgetType))
                {
                    for(String grpNameROBudgetType : programGroupBudgetTypeMapRO.get(record.program+underscore+record.budgetType))
                    {   
                        if(grpNametoIdMap.containsKey(grpNameROBudgetType))
                        {
                            grpLstRO.add(grpNametoIdMap.get(grpNameROBudgetType));
                        }
                    }
                }else if(record.budgetType==null && progToBudgetTypesMap.containsKey(record.program) && progToBudgetTypesMap.get(record.program) != null){
                    for(String budgetType : progToBudgetTypesMap.get(record.program))
                    {   

                        if(programGroupBudgetTypeMapRO.containsKey(record.program+underscore+budgetType)){
                            
                            for(String grpNameRO : programGroupBudgetTypeMapRO.get(record.program+underscore+budgetType))
                            {
                                if((grpNametoIdMap.containsKey(grpNameRO)))
                                {
                                    grpLstRO.add(grpNametoIdMap.get(grpNameRO));
                                }
                            }
                        }
                    }                        
                }
                for(String geo : geoSubGeoNames){
                    if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+geo)))
                    {
                        grpLst.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMap.get(record.program+underscore+geo)));
                    }
                    if(grpNametoIdMap.containsKey(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+geo)))
                    {
                        grpLstRO.add(grpNametoIdMap.get(pgmGeoSubGeoBudgetTypeGrpMapRO.get(record.program+underscore+geo)));
                    }
                }

            }
            if(objectsForAllGeoSharing.contains(objectName) && record.program==IPATechnicalProgram && objectsForHostRegSharing.contains(objectName) && String.isNotBlank(record.geo)){
                if(record.budgetType!=null){
                    if(programGeoBudgetTypeMap.containsKey(record.program+underscore+record.geo+underscore+record.budgetType)){
                        for(String grpGeoBudgetType : programGeoBudgetTypeMap.get(record.program+underscore+record.geo+underscore+record.budgetType))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeoBudgetType))
                            {
                                grpLst.add(grpNametoIdMap.get(grpGeoBudgetType));
                            }
                        }
                    }
                    if(programGeoBudgetTypeMap.containsKey(record.program+underscore+'WW'+underscore+record.budgetType)){
                        for(String grpGeoBudgetType : programGeoBudgetTypeMap.get(record.program+underscore+'WW'+underscore+record.budgetType))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeoBudgetType))
                            {
                                grpLst.add(grpNametoIdMap.get(grpGeoBudgetType));
                            }
                        }
                    }
                    if(programGeoBudgetTypeMapRO.containsKey(record.program+underscore+record.geo+underscore+record.budgetType)){
                        for(String grpGeoBudgetType : programGeoBudgetTypeMapRO.get(record.program+underscore+record.geo+underscore+record.budgetType))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeoBudgetType))
                            {
                                grpLstRO.add(grpNametoIdMap.get(grpGeoBudgetType));
                            }
                        }
                    }
                    if(programGeoBudgetTypeMapRO.containsKey(record.program+underscore+'WW'+underscore+record.budgetType)){
                        for(String grpGeoBudgetType : programGeoBudgetTypeMapRO.get(record.program+underscore+'WW'+underscore+record.budgetType))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeoBudgetType))
                            {
                                grpLstRO.add(grpNametoIdMap.get(grpGeoBudgetType));
                            }
                        }
                    }
                }else{
                    if(programGeoMap.containsKey(record.program+underscore+record.geo) && programGeoMap.get(record.program+underscore+record.geo) != null){                        
                        for(String grpGeo : programGeoMap.get(record.program+underscore+record.geo))
                        {
                            if(grpNametoIdMap.containsKey(grpGeo))
                            {
                                grpLst.add(grpNametoIdMap.get(grpGeo));
                            }
                        }                        
                    }
                    if(programGeoMap.containsKey(record.program+underscore+'WW')){
                        for(String grpGeo : programGeoMap.get(record.program+underscore+'WW'))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeo))
                            {
                                grpLst.add(grpNametoIdMap.get(grpGeo));
                            }
                        }
                    }
                    if(programGeoMapRO.containsKey(record.program+underscore+record.geo) && programGeoMapRO.get(record.program+underscore+record.geo) != null){                        
                        for(String grpGeo : programGeoMapRO.get(record.program+underscore+record.geo))
                        {
                            if(grpNametoIdMap.containsKey(grpGeo))
                            {
                                grpLstRO.add(grpNametoIdMap.get(grpGeo));
                            }
                        }                        
                    }
                    if(programGeoMapRO.containsKey(record.program+underscore+'WW')){
                        for(String grpGeo : programGeoMapRO.get(record.program+underscore+'WW'))
                        {   
                            if(grpNametoIdMap.containsKey(grpGeo))
                            {
                                grpLstRO.add(grpNametoIdMap.get(grpGeo));
                            }
                        }
                    }
                }               
            }
            //assigning the group lists to the record
            record.groupId = grpLst;
            record.groupId_RO = grpLstRO;
            
        }
        return recordGeoShareLst;
    }
    /***************************************************************************************************** 
Method Name:        addToProgramGrpMap
@return  :          void
@parameters:        Record of Core_MDF_ProgramGeoGroupMap__mdt
Description:        This method is used to add all the Program specific groups for each record.
To be used in case of objects that need to be shared to all the Geo group
Added By:           Intel - SM
Modified By:        Date:       Changes: 
******************************************************************************************************/
    
    public static void addToProgramBudgetTypeGrpMap(Core_MDF_ProgramGeoGroupMap__mdt rec)
    {
        if(programGroupBudgetTypeMap.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c)){
            programGroupBudgetTypeMap.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name__c);
        }
        else{
            programGroupBudgetTypeMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name__c});
        }
        if(programGroupBudgetTypeMapRO.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c)){
            programGroupBudgetTypeMapRO.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name_RO__c);
        }
        else{
            programGroupBudgetTypeMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name_RO__c});
        }
        if(rec.Core_MDF_Program__c==IPATechnicalProgram){
            if(programGeoBudgetTypeMap.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c)){
            	programGeoBudgetTypeMap.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name__c);
            }else{
                programGeoBudgetTypeMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name__c});
            }
            if(programGeoBudgetTypeMapRO.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c)){
                programGeoBudgetTypeMapRO.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c).add(rec.Core_MDF_Group_Name_RO__c);
            }
            else{
                programGeoBudgetTypeMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c+underscore+rec.Core_MDF_Budget_Type_txt__c, new List<String>{rec.Core_MDF_Group_Name_RO__c});
            }
            if(programGeoMap.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c)){
            	programGeoMap.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c).add(rec.Core_MDF_Group_Name__c);
            }else{
                programGeoMap.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c, new List<String>{rec.Core_MDF_Group_Name__c});
            }
            if(programGeoMapRO.containsKey(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c)){
                programGeoMapRO.get(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c).add(rec.Core_MDF_Group_Name_RO__c);
            }
            else{
                programGeoMapRO.put(rec.Core_MDF_Program__c+underscore+rec.Core_MDF_Region__c, new List<String>{rec.Core_MDF_Group_Name_RO__c});
            }
        }
    }
    
    public static List<sObject> getShareRecordToGeoGroup(string objectName, List<Core_MDF_RecordGeoShare> recordGeoShareLst)
    {
        List<sObject> shareRecordList = new List<sObject>();
        List<Core_MDF_RecordGeoShare> updatedRecordGeoShareLst = addGroupstoRecordGeoShareLst(objectName,recordGeoShareLst);
        Map<Id,List<Id>> recordGeoShareMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> recordGeoShareMapRO = new Map<Id,List<Id>>();
        //To create a map of the record and the respective groups it should be shared for Edit and Read Only.
        if(updatedRecordGeoShareLst != NULL && updatedRecordGeoShareLst.size()>0)
        {
            for(Core_MDF_RecordGeoShare rec : updatedRecordGeoShareLst)
            {
                if(recordGeoShareMap.containsKey(rec.recordId)){
                    recordGeoShareMap.get(rec.recordId).addAll(rec.groupId);
                }
                else{
                    recordGeoShareMap.put(rec.recordId, rec.groupId.clone());
                }
                if(recordGeoShareMapRO.containsKey(rec.recordId)){
                    recordGeoShareMapRO.get(rec.recordId).addAll(rec.groupId_RO);
                }
                else{
                    recordGeoShareMapRO.put(rec.recordId, rec.groupId_RO.clone());
                }
            }    
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Edit Access
        if(recordGeoShareMap != NULL && recordGeoShareMap.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMap, 'Edit');
            List<sObject> shareRecList = Core_MDF_GenericShareRecordActionClass.getShareRecordList(rmsInst);
            if(shareRecList!=Null && shareRecList.size()>0){
                shareRecordList.addAll(shareRecList);
            }
        }
        // Passing the Map<Given Object, List<GroupID> to the Generic Share Record Class method
        // to share the Record to the respective Group with Read Access
        if(recordGeoShareMapRO != NULL && recordGeoShareMapRO.size()>0)
        {
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInstRead = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass(objectName,recordGeoShareMapRO, 'Read');
            List<sObject> shareRecList = Core_MDF_GenericShareRecordActionClass.getShareRecordList(rmsInstRead);
            if(shareRecList!=Null && shareRecList.size()>0){
                shareRecordList.addAll(shareRecList);
            }
        }
        return shareRecordList;
    }
}