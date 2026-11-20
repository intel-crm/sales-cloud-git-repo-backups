/***************************************************************************************************
Class Name          : Core_IPS_Core_Question_Handler
Version             : 1.0 
Created Date        : 18 Dec 2017
Function            : This Class is a Handler class for trigger Core_IPS_Core_QuestionTrigger on Core_IPS_Question__c object.
Input Parameters    : NA
Output Parameters   : NA
Description         : NA
Used in             : trigger Dispatcher class Core_IPS_Core_Question_Dispatcher
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Yogesh Sharma               18/12/2017             Created
* Aayushi Singhal             06/04/2018             Modified
* Amritesh                    06/18/2018             Modified - US108250 
****************************************************************************************************/       

public without sharing class Core_IPS_Core_Question_Handler
{    
    /***************************************************************************************************
    Method Name         : updateAssignedEnvironmentVariablesFromCoreQuestion
    Method Type         : void
    Version             : 1.0 
    Created Date        : 18 Dec 2017
    Function            : This method is used update the child object Core_Assigned_Environment_Variables__c record status on update of parent object Core_IPS_Question__c record.
    Input Parameters    : trigger.new records in a List and Trigger.oldMap records in a Map
    Output Parameters   : NA
    Description         : This method takes a list of Core_IPS_Question__c records whose status field is changed and then update the child object Core_Assigned_Environment_Variables__c record status field value accordingly as per parent object status value.
    Used in             : trigger Dispatcher class Core_IPS_Core_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              18/12/2017              Created
    ****************************************************************************************************/       
 
    
    public static void updateAssignedEnvironmentVariablesFromCoreQuestion(List<Core_IPS_Question__c> newList,Map<Id,Core_IPS_Question__c> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateAssignedEnvironmentVarFromEDQ'))
            return;
            
        Map<Id,String> coreQuestionIdAndStatusMap = new Map<Id,String>();
        for(Core_IPS_Question__c cq : newList){           
            if(cq.Core_IPS_Status__c != oldMap.get(cq.id).Core_IPS_Status__c){
                coreQuestionIdAndStatusMap.put(cq.id,cq.Core_IPS_Status__c);                
            }
        } 
        
        Map<Id,Core_IPS_Assigned_Environment_Variables__c> assignedEnvironmentVariablesMap = new Map<Id,Core_IPS_Assigned_Environment_Variables__c>([SELECT id,Core_Status__c,Core_IPS_Question__c FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_IPS_Question__c IN : coreQuestionIdAndStatusMap.keyset()]);
        if(assignedEnvironmentVariablesMap.size() > 0){
            for(ID assignVariableId : assignedEnvironmentVariablesMap.keyset()){                
                assignedEnvironmentVariablesMap.get(assignVariableId).Core_Status__c = coreQuestionIdAndStatusMap.get(assignedEnvironmentVariablesMap.get(assignVariableId).Core_IPS_Question__c);                
            }
            if(!assignedEnvironmentVariablesMap.isempty()){
                update assignedEnvironmentVariablesMap.values();
            }  
        }         
    } 
    
    /***************************************************************************************************
    Method Name         : preventToDeletetheEnvironmentalDetailQuestion
    Method Type         : void
    Version             : 1.0 
    Created Date        : 18 Dec 2017
    Function            : This method is used Prevent the deletion of Core_IPS_Question__c object Record if Record used in any Core_IPS_Response__c Object Record. 
    Input Parameters    : trigger.old records in a List
    Output Parameters   : NA
    Description         : This method is used Prevent the deletion of Core_IPS_Question__c object Record if Record used in any Core_IPS_Response__c Object Record. 
    Used in             : trigger Dispatcher class Core_IPS_Core_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              18/12/2017              Created
    ****************************************************************************************************/       

    
    public static void preventToDeletetheEnvironmentalDetailQuestion(List<Core_IPS_Question__c> oldList,Map<Id,Core_IPS_Question__c> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToDeletetheEDQ'))
            return;
        
        String response_del_error = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Response_Del_Error');
        Map<Id,Core_IPS_Response__c> coreResponseMap = new  Map<Id,Core_IPS_Response__c>([SELECT Id,Core_IPS_Question_Master__c FROM Core_IPS_Response__c WHERE Core_IPS_Question_Master__c IN : oldMap.keySet()]);
        if(!coreResponseMap.isEmpty() && coreResponseMap.size() > 0){
            for(Core_IPS_Question__c cq : oldList){
                cq.addError(response_del_error); 
            }
        }
    }
    
    /***************************************************************************************************
    Method Name         : copyOwnerFromSupportOrgToEnvironmentalDetailQuestion
    Method Type         : void
    Version             : 1.0 
    Created Date        : 27 Dec 2017
    Function            : This method is used copy the owner from Support org to Environmental Detail Question Object.
    Input Parameters    : trigger.new records in a List
    Output Parameters   : NA
    Description         : This method is used copy the owner from Support org to Environmental Detail Question Object.
    Used in             : trigger Dispatcher class Core_IPS_Core_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              27/12/2017              Created
    ****************************************************************************************************/       

    
    public static void copyOwnerFromSupportOrgToEnvironmentalDetailQuestion(List<Core_IPS_Question__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('copyOwnerFromSupportOrgToEDQ'))
            return;
        
        Set<Id> supportOrgIds = new Set<Id>();
        for(Core_IPS_Question__c cq : newList){
            supportOrgIds.add(cq.Core_IPS_Product_Organization__c);
        }
        
        if(!supportOrgIds.isEmpty()){
            Map<Id,Core_IPS_Product_Organization__c> supportOrgMap = new Map<Id,Core_IPS_Product_Organization__c>([SELECT Id, ownerId FROM Core_IPS_Product_Organization__c WHERE Id IN : supportOrgIds]);
            
            if(!supportOrgMap.isEmpty()){
                for(Core_IPS_Question__c cq : newList){
                    if(supportOrgMap.containsKey(cq.Core_IPS_Product_Organization__c)){
                        cq.ownerId = supportOrgMap.get(cq.Core_IPS_Product_Organization__c).ownerId;  
                    }
                }
            }
        }
    }
    
    /***************************************************************************************************
    Method Name         : preventToCreateEnvironmentalDetailQuestion
    Method Type         : void
    Version             : 1.0 
    Created Date        : 27 Dec 2017
    Function            : This method is used to prevent the create Environmental Detail Question Record if user not have write access on Support org.
    Input Parameters    : trigger.new records in a List
    Output Parameters   : NA
    Description         : This method is used to prevent the create Environmental Detail Question Record if user not have write access on Support org.
    Used in             : trigger Dispatcher class Core_IPS_Core_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Yogesh Sharma              27/12/2017              Created
    * Amritesh                   06/18/2018              Modified- US108250 
    ****************************************************************************************************/       

    
    public static void preventToCreateEnvironmentalDetailQuestion(List<Core_IPS_Question__c> newList){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToCreateEDQ'))
            return;
        
        Id userId = UserInfo.getUserId(); 
        Set<Id> supportOrgIds = new Set<Id>(); 
        
        for(Core_IPS_Question__c cq : newList){  
            if(cq.Core_IPS_Product_Organization__c!=null) //added by amritesh - US108250 - 06/18/2018
            supportOrgIds.add(cq.Core_IPS_Product_Organization__c);
        }
        if(!supportOrgIds.isEmpty()){
            Map<Id,Boolean> hasRecordEditAccess = Core_IPS_Questions_Utility.recordEditAccessMap(supportOrgIds,userId);
            String create_edq_error = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Create_EDQ_Error');
            for(Core_IPS_Question__c cq : newList){
                if(hasRecordEditAccess.containsKey(cq.Core_IPS_Product_Organization__c) && !hasRecordEditAccess.get(cq.Core_IPS_Product_Organization__c)){ //modified by amritesh - US108250 - 06/18/2018
                    cq.addError(create_edq_error);
                }
            }
        }
    }
    
    /***************************************************************************************************
    Method Name         : updateEDQfilteringFieldOnCase
    Method Type         : void
    Version             : 1.0 
    Created Date        : 4 April 2018
    UserStory#          : US95468
    Function            : This method is used to add response to the EDQ filtering fields on the Case record if 
                          the reporting name field is changed on the question.
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Description         : This method will populate the two EDQ filtering fields on Case with the Response Questions' Reporting Name
                          and the Response Answer text
    Used in             : trigger Dispatcher class Core_IPS_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Aayushi Singhal            04/04/2018               Created
    ****************************************************************************************************/ 
    public static void  updateEDQfilteringFieldOnCase(List<Core_IPS_Question__c> newList,Map<Id,Core_IPS_Question__c> oldMap){
        List<Core_IPS_Response__c> respList = new List<Core_IPS_Response__c>();
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('updateEDQfilteringFieldOnCase'))
            return;  
        try{
            List<Id> quesList=new List<Id>();
            for(Core_IPS_Question__c ques: newList){
                if((ques.Core_IPS_Add_to_Reporting__c!=oldMAp.get(ques.Id).Core_IPS_Add_to_Reporting__c ||  ques.Core_IPS_Reporting_Name__c!=oldMAp.get(ques.Id).Core_IPS_Reporting_Name__c)){
                 quesList.add(ques.Id);   
                }
            } 
            if(quesList!=null && quesList.size()>0){
                //FLS check added-Venugopal
                if(Core_IPS_Response__c.SObjectType.getDescribe().isAccessible()){
          		respList=[Select Id,Core_IPS_Case__c,Core_IPS_Answer__c,Core_IPS_Question_Master__c from Core_IPS_Response__c where Core_IPS_Question_Master__c In: quesList];
                }
                if(respList!=null && respList.size()>0){
                    Core_IPS_Response_Handler.updateEDQfilteringFieldOnCase(respList);
                }
            }          
            
        }catch(Exception ex){ }
    }
        
    /***************************************************************************************************
    Method Name         : preventToUpdateParentEDQDataType
    Method Type         : void
    Version             : 1.0 
    Created Date        : 16 April 2018
    UserStory#          : US101342
    Function            : This method is used to restrict the updation of Parent Question DataType
    Input Parameters    : trigger.new and old records
    Output Parameters   : NA
    Description         : This method is used to restrict the updation of Parent Question DataType
    Used in             : trigger Dispatcher class Core_IPS_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Karthick                   16/04/2018               Created
    ****************************************************************************************************/
    public static void preventToUpdateParentEDQDataType(List<Core_IPS_Question__c> newList,Map<Id,Core_IPS_Question__c> oldMap){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToUpdateParentEDQDataType'))
            return;
        
        Map<Id,Core_IPS_Question__c> mapParentChild = new Map<Id,Core_IPS_Question__c>();
        List<Core_IPS_Question__c> listParentChild = new List<Core_IPS_Question__c>();
        if(Core_IPS_Question__c.SObjectType.getDescribe().isQueryable()){
            listParentChild = [select id,Core_IPS_Parent_Question__c,Core_IPS_Datatype__c,Core_IPS_Question__c from Core_IPS_Question__c where Core_IPS_Parent_Question__c IN : oldMap.keySet()];
        
        for(Core_IPS_Question__c objChild : listParentChild){
            mapParentChild.put(objChild.Core_IPS_Parent_Question__c,objChild);
        }
        
        for(Core_IPS_Question__c objQues : newList){
            
            if(mapParentChild.containsKey(objQues.Id)){
                if(objQues.Core_IPS_Datatype__c != Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Picklist')){
                    objQues.addError(System.Label.Core_IPS_Parent_EDQ_Err);
                }
            }
        }
        
        }
        
    }
    
    /***************************************************************************************************
    Method Name         : preventToCreateGrandChildEDQ
    Method Type         : void
    Version             : 1.0 
    Created Date        : 16 April 2018
    UserStory#          : US102274
    Function            : This method is used to restrict the creation of GrandChild EDQs
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Description         : This method is used to restrict the creation of GrandChild EDQs
    Used in             : trigger Dispatcher class Core_IPS_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Karthick                   16/04/2018               Created
    * Karthick                   28/08/2018               Modified
    ****************************************************************************************************/
    public static void preventToCreateGrandChildEDQ(List<Core_IPS_Question__c> newList){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToCreateGrandChildEDQ'))
            return;
        
        Set<Id> setParentQuesId = new Set<Id>();
        
        for(Core_IPS_Question__c objQues : newList){  
            setParentQuesId.add(objQues.Core_IPS_Parent_Question__c);
            //Added by karthick as part of US146475
            if(objQues.Core_IPS_Order_No__c ==null)
                objQues.Core_IPS_Order_No__c = Integer.valueof(System.Label.Core_IPS_Default_EDQ_Order_No);
            
        }

        Integer parentCount = [SELECT count() FROM Core_IPS_Question__c WHERE Id IN :setParentQuesId AND Core_IPS_Parent_Question__c!= NULL];

        if(parentCount>0){
            newList[0].addError(System.Label.Core_IPS_GrantChild_EDQ_Err); 
        }
        
    }
    
    /***************************************************************************************************
    Method Name         : preventToCreateThousandEDQ
    Method Type         : void
    Version             : 1.0 
    Created Date        : 16 April 2018
    UserStory#          : US102274
    Function            : This method is used to restrict to create more than 1000 EDQs for one support org.
    Input Parameters    : trigger.new records
    Output Parameters   : NA
    Used in             : trigger Dispatcher class Core_IPS_Question_Dispatcher
    Number of Queries Within this Method    : 1
    Number of Queries in Loop               : 0
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Karthick                   05/09/2018               Created
    ****************************************************************************************************/
    public static void preventToCreateThousandEDQ(List<Core_IPS_Question__c> newList,map<Id, Core_IPS_Question__c> mapOld){
        
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToCreateThousandEDQ'))
            return;
        
        Integer edqCount;
        String supportOrgEdqLimit = Core_IPS_Helper_Utility.getIPSLabel('Core_IPS_Support_Org_Edq_Count');
        Set<Id> setSupportOrg = new Set<Id>();
        Map<Id,Integer> supportOrgEdqMap = new Map<Id,Integer>();
        
        for(Core_IPS_Question__c objQues : newList){
            
            Id supportOrgId = objQues.Core_IPS_Product_Organization__c;
        
            if(mapOld != null && mapOld.size()>0 && mapOld.containsKey(objQues.Id)){
                if(supportOrgId != mapOld.get(objQues.Id).Core_IPS_Product_Organization__c){
                    setSupportOrg.add(supportOrgId);
                    
                    if(supportOrgEdqMap.containsKey(supportOrgId)){
                        supportOrgEdqMap.put(supportOrgId,supportOrgEdqMap.get(supportOrgId)+1);
                    }else{
                        supportOrgEdqMap.put(supportOrgId,1);
                    }
                    
                }
            }else{
                setSupportOrg.add(supportOrgId);
                
                if(supportOrgEdqMap.containsKey(supportOrgId)){
                    supportOrgEdqMap.put(supportOrgId,supportOrgEdqMap.get(supportOrgId)+1);
                }else{
                    supportOrgEdqMap.put(supportOrgId,1);
                }
            }
            
        }
        //FLS fix added-Venugopal
        if(setSupportOrg!=null && setSupportOrg.size()>0 && Core_IPS_Question__c.SObjectType.getDescribe().isAccessible()){
            for(AggregateResult ag : [SELECT count(Id),Core_IPS_Product_Organization__c FROM Core_IPS_Question__c WHERE Core_IPS_Product_Organization__c IN :setSupportOrg GROUP BY Core_IPS_Product_Organization__c ]){
                
                Id supportOrgId = (Id)ag.get('Core_IPS_Product_Organization__c');
                Integer recCount = (integer)ag.get('expr0');
                
                if(supportOrgEdqMap.containsKey(supportOrgId)){
                    supportOrgEdqMap.put(supportOrgId,supportOrgEdqMap.get(supportOrgId)+recCount);
                }else{
                    supportOrgEdqMap.put(supportOrgId,recCount);
                }
                
            }
        }
        
        if(supportOrgEdqMap!=null && supportOrgEdqMap.size()>0){
            for(Core_IPS_Question__c objQues : newList){ 
                edqCount = supportOrgEdqMap.containsKey(objQues.Core_IPS_Product_Organization__c)?supportOrgEdqMap.get(objQues.Core_IPS_Product_Organization__c):0;
                if(edqCount>Integer.valueof(supportOrgEdqLimit)){
                    objQues.addError(System.Label.Core_IPS_EDQ_Count_Err); 
                }
                
            }
        }
        
    }
    /***************************************************************************************************
    Method Name         : updateReportingName
    Method Type         : void
    Version             : 1.0 
    Created Date        : 18 June 2020
    UserStory#          : US694730
    Function            : This method is used to populate 'Reporting Name' field with 'Question No' field if it is blank and spaces are replaced with underscore 
    Input Parameters    : trigger.new records and old records
    Output Parameters   : NA
    Used in             : trigger Dispatcher class Core_IPS_Question_Dispatcher
    Number of Queries Within this Method    : 0
    Number of Queries in Loop               : 1
    Number of Queries from Called methods   : 0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Tejaswi                   06/18/2018               Created
    ****************************************************************************************************/
    // US694730
    public static void updateReportingName(List<Core_IPS_Question__c> newList, Map<Id,Core_IPS_Question__c> oldMap){
        if(!Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('preventToCreateEDQ')
           || !Schema.sObjectType.Core_IPS_Question__c.fields.Core_IPS_Reporting_Name__c.isUpdateable()){
               return;  
           }
        List<Core_IPS_Question__c> newListUpd = new List<Core_IPS_Question__c>();
        for(Core_IPS_Question__c cq : newList){
            if(cq.Core_IPS_Reporting_Name__c == null || cq.Core_IPS_Reporting_Name__c == ''){
                if(trigger.isinsert && trigger.isafter){
                    Core_IPS_Question__c newCq =new Core_IPS_Question__c();
                    /*US1021248 - 05/26/2021 - Vishal - FLS Check for security vulnerability --*/
                       newCq.id=cq.id;
                  //  if (Schema.sObjectType.Core_IPS_Question__c.fields.Core_IPS_Reporting_Name__c.isUpdateable()) {
                        newCq.Core_IPS_Reporting_Name__c = cq.Name;
                   // }
                    newListUpd.add(newCq);
                }
                else if(!trigger.isinsert){
                    cq.Core_IPS_Reporting_Name__c = cq.Name;
                }
            }
            else if((cq.Core_IPS_Reporting_Name__c != null || cq.Core_IPS_Reporting_Name__c != '') &&
                    ((oldMap == null) || 
                     (cq.Core_IPS_Reporting_Name__c != oldMap.get(cq.Id).Core_IPS_Reporting_Name__c)) && trigger.isbefore){
                         cq.Core_IPS_Reporting_Name__c = cq.Core_IPS_Reporting_Name__c.trim();
                         cq.Core_IPS_Reporting_Name__c = cq.Core_IPS_Reporting_Name__c.replaceAll('(\\s+)','_');
                     }
        }
        if(newListUpd.size() > 0 ){
            update newListUpd;
        }        
    }
}