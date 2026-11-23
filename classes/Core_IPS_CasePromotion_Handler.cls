/**************************************************************************************************
Apex Class Name:  Core_IPS_CasePromotion_Handler
Version     : 1.0 
Created Date: 13 08 2015
Function    : Handler Class for IPS case Backend Routing. This class defines all the methods
              which are used for backend system determination, failed promotes re-processing
              logic etc.
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Kareem Unnisa/Sushma Hamom          13/08/2015              Original Version
* Tanvi Chauhan                       04/04/2016              CheckCriteria & stamping method updated
* Manoj Kumar                         04/10/2016              executeBackendFieldUpdate method updated
* Sadhvika G B                        27/02/2017              Stop Re-triggering when the status is set to sent successfully
*                                                             Set promote status to done if backend ID is found for all user types
* Sushma                              26/05/2017              Add logic to handle RSNDA while determing backend system
* Gourav                               10/03/2019              US304935:Added if condition to check update before assigning backend system to avoid 101 error
* Sneha                                                       US454558 TECH: BES:  Enable changing of DCG JIRA backend systems
*****************************************************************************************************/
public without sharing class Core_IPS_CasePromotion_Handler {

Public Static Final String IPS_BACKEND_INTEGRATION_USER = 'ips.backend.integrationuser';
    public static boolean initCheck = true;     
//************************************************************************************//
// This is main method which is called from Case Object trigger dispatcher: 
//  Core_CaseTrigger_Dispatcher
//************************************************************************************// 
   Public static void executeBackendRoutingfromCaseTrigger(List<Case> oldList,List<Case> newList, Map<Id,Case> oldMap, Map<Id,Case> newMap)  
   {
      List<Core_IPS_Backend_System__c> BackIDs = new List<Core_IPS_Backend_System__c>();
      List<Case> ListCase = new List<Case>();
      List<Case> ListUpdateCase = new List<Case>();
      Set<ID> backID = new Set<ID>();
      boolean continue_flag = true;
      Map<id,id> mapIdOfCaseMap = new Map<id,id>();
      
      List<Core_IPSBackendPromoteReprocesing__c> configIds = Core_IPSBackendPromoteReprocesing__c.getAll().values(); 
      Map<String,String> MapOfBackSFId =  new Map<String,String>();
      for(Core_IPSBackendPromoteReprocesing__c configId: configIds)
      {
          if( configId.Core_Group_Lookup_Name__c <> null &&
           ((configId.Core_Group_Lookup_Name__c == 'DM_PROFILEID'&& Userinfo.getProfileID() == configId.Core_Translate_value__c )||
           // (Userinfo.getUserName().containsIgnoreCase(IPS_BACKEND_INTEGRATION_USER)) ||-- commented by Sadhvika
             (configId.Core_Group_Lookup_Name__c == 'DM_USERNAME' && Userinfo.getUserName() == configId.Core_Translate_value__c) ||
             (configId.Core_Group_Lookup_Name__c == 'BACKENDINTEG_USERNAME' && Userinfo.getUserName() == configId.Core_Translate_value__c)) )             
          { 
            continue_flag = false;
	     break; 
	   }   
            /**********Forming map of backend system id for filtering the redetrminsationLogic**********/ //added by Aswin
            if(configId.Core_Group_Lookup_Name__c <> null && configId.Core_Group_Lookup_Name__c.equalsIgnoreCase('Backend System')){
                   MapOfBackSFId.put(configId.Core_Translate_Value__c,configId.Core_Translate_Value__c);   
             }          
      } 
      if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('enableIPSCaseBackendRouting') && continue_flag == true){
         try{     
           for(Case cs:newList){
            if(cs.Core_IPS_Backend_ID__c != null && cs.Core_IPS_Backend_ID__c != '0' && cs.Core_IPS_Backend_ID__c != '-1' && (cs.Core_Promote_Status__c == null || (cs.Core_Promote_Status__c != null && !(cs.core_promote_status__c.equalsignorecase('Done')))))
            { 
                cs.core_promote_status__c = 'Done'; 
                continue;
            }
            if(!(Userinfo.getUserName().containsIgnoreCase(IPS_BACKEND_INTEGRATION_USER)))
            {
            if((cs.Core_IPS_Backend_ID__c != null && cs.Core_IPS_Backend_ID__c == '0') && cs.Core_IPS_Backend_System__c != null){
              cs.core_promote_status__c = 'In Progress'; 
              cs.Core_IPS_Backend_ID__c = '';
              continue;
            }
            if(cs.Core_IPS_Backend_ID__c != null && cs.Core_IPS_Backend_System__c != null){
              backID.add(cs.Core_IPS_Backend_System__c);
              //==================aswin============================//
                  if((oldMap.get(cs.id).Core_IPS_Backend_System__c == cs.Core_IPS_Backend_System__c) && MapOfBackSFId.containskey(oldMap.get(cs.id).Core_IPS_Backend_System__c) ){
                  if((oldMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c)||(oldMap.get(cs.id).Core_IPS_Assigned_Queue__c != cs.Core_IPS_Assigned_Queue__c)||(oldMap.get(cs.id).Core_jsonfield__c !=cs.Core_jsonfield__c)||(oldMap.get(cs.id).Core_External_Issue_Category__c != cs.Core_External_Issue_Category__c)||(oldMap.get(cs.id).Core_External_Issue_Subcategory__c != cs.Core_External_Issue_Subcategory__c)||(oldMap.get(cs.id).Status != cs.Status)||(oldMap.get(cs.id).Core_Sub_Status__c != cs.Core_Sub_Status__c)){
                  if(newMap.get(cs.id).Core_IPS_Backend_System__c == oldMap.get(cs.id).Core_IPS_Backend_System__c){
                     cs.Core_IPS_Backend_System__c =null;
                     mapIdOfCaseMap.put(cs.id,cs.id);
                  }
                 ListUpdateCase.add(cs);
                 
                 }}
                 else{
              ListUpdateCase.add(cs); } 
              //=======================End aswin=== ===================//
            }
            else{
               //Gourav US304935 : To avoid 101 SOQL error  
             //  if((oldMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c)||(oldMap.get(cs.id).Core_IPS_Assigned_Queue__c != cs.Core_IPS_Assigned_Queue__c)||(oldMap.get(cs.id).Core_jsonfield__c !=cs.Core_jsonfield__c)||(oldMap.get(cs.id).Core_External_Issue_Category__c != cs.Core_External_Issue_Category__c)||(oldMap.get(cs.id).Core_External_Issue_Subcategory__c != cs.Core_External_Issue_Subcategory__c)||(oldMap.get(cs.id).Status != cs.Status)||(oldMap.get(cs.id).Core_Sub_Status__c !=cs.Core_Sub_Status__c)||(oldMap.get(cs.id).Core_Promote_Status__c != cs.Core_Promote_Status__c) ) { 

               if( initCheck || (oldMap.get(cs.id).Core_IPS_Supported_Product__c != cs.Core_IPS_Supported_Product__c)||(oldMap.get(cs.id).Core_IPS_Assigned_Queue__c != cs.Core_IPS_Assigned_Queue__c)||(oldMap.get(cs.id).Core_jsonfield__c !=cs.Core_jsonfield__c)||(oldMap.get(cs.id).Core_External_Issue_Category__c != cs.Core_External_Issue_Category__c)||(oldMap.get(cs.id).Core_External_Issue_Subcategory__c != cs.Core_External_Issue_Subcategory__c)||(oldMap.get(cs.id).Status != cs.Status)||(oldMap.get(cs.id).Core_Sub_Status__c !=cs.Core_Sub_Status__c)||(oldMap.get(cs.id).Core_Promote_Status__c != cs.Core_Promote_Status__c) ) { 
                        ListCase.add(cs);
                } //new if initCheck
            }         
           }
           }
         if(ListCase.size()>0) {  
            executeMainRouting(ListCase, oldMap, 'Case'); 
            initcheck=false; //initCheck to stop recursion 
         }  
         
         if(ListUpdateCase.size()>0 && backID.size()>0){            
            List<Case> caseUpdateList = new List<Case>();
            //=============aswin===========================//
                List<Case> caseBackendUpdated = new List<Case>();
               
                  Core_IPS_CasePromotion_Handler.getBackendID(ListUpdateCase, oldMap, 'Case') ; 
                  for(case csUpdated:ListUpdateCase){
                      if(csUpdated.Core_IPS_Backend_System__c == oldMap.get(csUpdated.id).Core_IPS_Backend_System__c ){
                          
                         csUpdated.Core_Promote_Status__c = 'Done' ;
                         if(csUpdated.Core_IPS_Backend_Previous_Status__c != null && csUpdated.Core_IPS_Backend_Previous_Status__c.contains('disassociate')){
                              csUpdated.Core_IPS_Backend_Previous_Status__c='promoted';
                          }
                          caseBackendUpdated.add(csUpdated);
                      }
                      else{
                          if(csUpdated.Core_IPS_Backend_System__c != null  ){
                          if(mapIdOfCaseMap.containskey(csUpdated.id)){
                          if(oldMap.get(csUpdated.id).Core_IPS_Backend_System__c != null && (oldMap.get(csUpdated.id).Core_IPS_Backend_ID__c != null && oldMap.get(csUpdated.id).Core_IPS_Backend_ID__c!= '')){
                          
                          csUpdated.Core_IPS_Backend_Previous_Status__c ='disassociate'+'|'+oldMap.get(csUpdated.id).Core_IPS_Backend_ID__c+'|'+oldMap.get(csUpdated.id).Core_IPS_Backend_System__c;
                          csUpdated.Core_IPS_Backend_ID__c ='';
                          }
                          }
                          }
                          else{
                              if(oldMap.get(csUpdated.id).Core_IPS_Backend_System__c != null){
                              csUpdated.Core_IPS_Backend_System__c = oldMap.get(csUpdated.id).Core_IPS_Backend_System__c;
                              csUpdated.Core_Promote_Status__c = 'Done' ;
                              caseBackendUpdated.add(csUpdated);
                              }
                          }
                          
                          
                      }
                  }
                  if(caseBackendUpdated.size()>0){
                      ListUpdateCase = caseBackendUpdated;
                  }
               
            
            
            //================end==========================//
            //FLS check added-Venugopal
            if(Core_IPS_Backend_System__c.SObjectType.getDescribe().isAccessible()){ 
            	BackIDs = [Select id from Core_IPS_Backend_System__c WHERE ID=:backID AND Core_IPS_Support_Case_Field_Update__c=true];
            }
             Set<ID> backIDSet = new Set<ID>();
            for(Core_IPS_Backend_System__c back:BackIDs){
              BackIDSet.add(back.id);
            }
            if(backIDSet.size()>0){
              for(Case cs:ListUpdateCase){
                 if(backIDSet.contains(cs.Core_IPS_Backend_System__c)) 
                 caseUpdateList.add(cs);
              }  
            }
            if(caseUpdateList.size()>0){ 
                executeBackendFieldUpdate(oldList, caseUpdateList, oldMap, newMap, backID);
            }
          }         
         } catch(Exception e){  }
      } 
   }

//************************************************************************************//
// This is main method which is called from IPS Case Attachment Object trigger Dispatcher: 
//  Core_IPS_Case_Attachments_Dispatcher
//************************************************************************************// 
   Public static void executeBackendRoutingfromIPSCaseAttachmentTrigger(List<Core_IPS_Case_Attachments__c> oldList,List<Core_IPS_Case_Attachments__c> newList, Map<Id,Core_IPS_Case_Attachments__c> oldMap, Map<Id,Core_IPS_Case_Attachments__c> newMap)
   {
      List<Case> caseList = new List<Case>();
      Set<ID> caseIds = new Set<ID>();
      boolean continue_flag = true;
      
      //Created an empty map to call 'executeMainRouting' method---05/30/2016---tanvix.chauhan
      Map<Id, Case> emptyCaseMap = new Map<Id, Case>();
           
      List<Core_IPSBackendPromoteReprocesing__c> configIds = Core_IPSBackendPromoteReprocesing__c.getAll().values(); 
      for(Core_IPSBackendPromoteReprocesing__c configId: configIds)
      {
          if( configId.Core_Group_Lookup_Name__c <> null &&
            ((configId.Core_Group_Lookup_Name__c == 'DM_PROFILEID'&& Userinfo.getProfileID() == configId.Core_Translate_value__c )||
             (Userinfo.getUserName().containsIgnoreCase(IPS_BACKEND_INTEGRATION_USER)) ||
             (configId.Core_Group_Lookup_Name__c == 'DM_USERNAME' && Userinfo.getUserName() == configId.Core_Translate_value__c) ||
             (configId.Core_Group_Lookup_Name__c == 'BACKENDINTEG_USERNAME' && Userinfo.getUserName() == configId.Core_Translate_value__c)))
          {  
             continue_flag = false;
	     break;
	  }             
      } 
      
      if(Core_IPS_Helper_Utility.isHandlerMethodExecutionEnabled('enableIPSCaseAttBackendRouting') && continue_flag == true) {
         try{
            if(newList.size()>0){         
               for(Core_IPS_Case_Attachments__c att:newList){
                 if(att.Core_Upload_Status__c!=null && 
                 (att.Core_Upload_Status__c.equalsignorecase('Complete') || att.Core_Upload_Status__c.equalsignorecase('Completed'))){
                   caseIds.add(att.Core_Case__c);  
                  }  
               }  
				//Avoid Deeply Nested IF Statements - Kamala
				//FLS check added-Venugopal
               if((caseIds.size()>0) && (case.SObjectType.getDescribe().isAccessible())){
                 	caseList=[SELECT id, core_ips_backend_System__c, assetid, Core_IPS_Product_Org1__c, productID, Core_Case_Issue_Category__c, Core_External_Issue_Category__c, Core_Case_Issue_Sub_Category__c, Core_External_Issue_Subcategory__c,status,Core_IPS_Backend_ID__c,Core_IPS_gec_flag__c,Core_IPS_gec_status__c,core_promote_status__c,Core_IPS_Supported_Product__c FROM case WHERE id=:caseIds];                  
                   
               }
            }
            if(caseList.size()>0){
                //executeMainRouting(caseList, oldMap, 'Core_IPS_Case_Attachments__c');
                //Passing an empty <ID, CASE> map inorder to skip checkCriteria logic for CaseAttachments ---05/30/2016---tanvix.chauhan
                executeMainRouting(caseList, emptyCaseMap, 'Core_IPS_Case_Attachments__c');
            }
         } catch(Exception e){    }
     }
   } 
   
    
//************************************************************************************//
// This method filters out cases which does not satisfy the below condition
// The case should not be in closed status, it should not be GEC flagged and if GEC flagged, it should be approved.
// Backend system and Backend ID should be blank, if backend system is assigned already, 
// backend id should be blank and also the promote status should not "In progress" or "Failed". 
// These cases should only be reprocesed using reprocessing mechanism.
//************************************************************************************//     
    Public static void executeMainRouting(List<case> caseList, Map<Id, Case> oldMap, String objectType)
    {
       List<case> ListCase = new List<case>();
       try
       {
         for(Case cs:caseList){         
           if((cs.status == null || !(cs.status.equalsignorecase('Closed'))) && 
             (cs.Core_IPS_gec_flag__c == null || cs.Core_IPS_gec_flag__c == false ||
              ( cs.Core_IPS_gec_flag__c ==  true && (cs.Core_IPS_gec_status__c != null  && cs.Core_IPS_gec_status__C.contains('Approved')) )) && 
             (
              ( cs.core_ips_backend_system__c == Null && cs.Core_ips_Backend_ID__c == Null) || 
              ( cs.core_ips_backend_system__c!= null && cs.core_ips_backend_id__c == null && (cs.core_promote_status__c ==  Null ||
              !(cs.core_promote_status__c.equalsignorecase('In Progress')  || 
                cs.core_promote_status__c.equalsignorecase('Done') || 
                cs.core_promote_status__c.equalsignorecase('Sent Successfully'))) )
             )            
             )
           {             
             ListCase.add(cs);            
           }
           else
           {            
           }
         }

         if(ListCase.size()>0){
             Core_IPS_CasePromotion_Handler.getBackendID(ListCase, oldMap, objectType); 
         }  
         else{
         } 
       } catch(Exception e){      }           
  }    
    
Public Static void executeBackendFieldUpdate(List<Case> oldList, List<Case> newList, Map<Id,Case> oldMap, Map<Id,Case> newMap, Set<ID> backIDList)
{
   boolean backendFieldUpdateFlag = false;
   Set<String> fieldSet = new Set<String>();
   Set<String> envFieldSet = new Set<String>();
   Map<String,String> envFieldSetMap = new Map<String,String>();
   List<Core_IPS_Backend_Field_Mapping__c> fieldUpdateSupportList = new List<Core_IPS_Backend_Field_Mapping__c>();
   try{     
      if (backIdList <> null)
      {
       if(Core_IPS_Backend_Field_Mapping__c.SObjectType.getDescribe().isAccessible()){   	
        	fieldUpdateSupportList = [Select id, Core_IPS_Field_Object_Name__c, Core_IPS_Field_Technical_name__c, Core_IPS_Backend_System__c, (select Id,Core_IPS_Source_Value__c,Core_IPS_Target_Value__c,Core_IPS_Previous_Source_Value__c from Backend_Value_Mappings__r where Core_IPS_Previous_Source_Value__c != Null) from Core_IPS_Backend_Field_Mapping__c WHERE core_IPS_backend_system__c IN: backIdList AND Core_IPS_Support_Update__c = true];
       }
      }

      if(fieldUpdateSupportList <> null && fieldUpdateSupportList.size()>0)
      {
        Schema.SObjectType objType = newList.getSObjectType(); 
        Map<String, Schema.SObjectField> mapFields =  Schema.SObjectType.Case.fields.getMap();
        for(Case cs:newList)       
        {
        if(oldMap.get(cs.Id) != null){
          fieldSet = new Set<String>();
          envFieldSet = new Set<String>();
          envFieldSetMap = new Map<String, String>();
          for(Core_IPS_Backend_Field_Mapping__c fieldlist:fieldUpdateSupportList)
          {
             if(cs.Core_IPS_backend_System__c == fieldList.Core_IPS_Backend_System__c)
             {  
                if(fieldlist.Core_IPS_Field_Object_Name__c == 'Case')
                {
                     //Start Routing BackendFieldUpdate for Case 'SubStatus' update through 'Backend_Status_update' workflow--10/04/2016---Manoj Kumar
                    if((fieldlist.Core_IPS_Field_Technical_name__c != null && fieldlist.Core_IPS_Field_Technical_name__c == 'Core_Sub_Status__c') && (cs.Core_Sub_Status__c != oldMap.get(cs.Id).Core_Sub_Status__c))
                    {
                        // check for existing Backend Value Mappings
                        if(!fieldlist.Backend_Value_Mappings__r.isEmpty() && fieldlist.Backend_Value_Mappings__r.size()>0)
                        {
                            String bkPreviousValue = '';
                            for(Core_IPS_Backend_Value_Mapping__c bkvalue : fieldlist.Backend_Value_Mappings__r)
                            {
                                String bkfieldvalueSource = '';
                                String bkfieldvaluePrevious = '';
                                
                                bkfieldvalueSource = (cs.Core_Sub_Status__c == null) ? cs.status : (cs.status+'.'+cs.Core_Sub_Status__c);
                                bkfieldvaluePrevious = (oldMap.get(cs.Id).Core_Sub_Status__c == null) ? oldMap.get(cs.Id).Status : (oldMap.get(cs.Id).Status+'.' +oldMap.get(cs.Id).Core_Sub_Status__c);
                                 
                                // Comparing Case Status with Backend Value Mappings 
                                if((bkvalue.Core_IPS_Previous_Source_Value__c.equalsIgnoreCase(String.valueof(oldMap.get(cs.Id).Status))) 
                                && (bkvalue.Core_IPS_Source_Value__c.equalsIgnoreCase(String.valueof(cs.status))|| 
                                    bkvalue.Core_IPS_Source_Value__c.equalsIgnoreCase(bkfieldvalueSource)))
                                {   
                                    cs.Core_IPS_Backend_Previous_Status__c = String.valueof(bkvalue.Core_IPS_Previous_Source_Value__c);
                                    break;
                                }
                                else 
                                {
                                    //when Case Substatus got updated check for match with Backend Value Mappings 
                                    if((bkvalue.Core_IPS_Previous_Source_Value__c.equalsIgnoreCase(bkfieldvaluePrevious)) &&
                                      (bkvalue.Core_IPS_Source_Value__c.equalsIgnoreCase(String.valueof(cs.status)) || 
                                        bkvalue.Core_IPS_Source_Value__c.equalsIgnoreCase(bkfieldvalueSource)))
                                    {
                                       bkPreviousValue = String.valueof(bkvalue.Core_IPS_Previous_Source_Value__c);
                                    }
                                    
                                    else 
                                    {
                                        //updating Case Backend Previous Status field to 'True' if it doesn't match with Backend Value Mapping which triggers 'Backend_Status_update' workflow
                                        cs.Core_IPS_Backend_Previous_Status__c = 'True';
                                    }
                                }
                                if(!String.isBlank(bkPreviousValue))
                                {
                                    //updating Case Backend Previous Status field with Backend Value Mapping which triggers 'Backend_Status_update' workflow
                                    cs.Core_IPS_Backend_Previous_Status__c = bkPreviousValue;
                                }
                            }
                        }
                        //End Routing Case Substatus update-- Manoj Kumar
                        else //Added by Sushma //Triggers the backend_status_update workflow
                        { cs.Core_IPS_Backend_Previous_Status__c = 'True';   }
                        
                    }
                    else
                    {
                        fieldSet.add(fieldlist.Core_IPS_Field_Technical_name__c);
                    }
                
                }
                if(fieldlist.Core_IPS_Field_Object_Name__c == 'Core_IPS_Environment_Details__c')
                {
                    String fieldname = (fieldlist.Core_IPS_Field_Technical_name__c).deleteWhiteSpace();
                    envFieldSetMap.put(fieldname, fieldname);
                    envFieldSet.add(fieldname);
                }
             }
          } 
          if(fieldSet.size()==0 && envFieldSet.size()==0) {  continue; }
          backendFieldUpdateFlag = false;
          
          for(String fieldName:fieldSet)
          {
             if(mapfields.get(fieldname) != null && cs.get(fieldName) != oldMap.get(cs.Id).get(fieldName))
             {
                backendFieldUpdateFlag = true;
             } 
             if(backendFieldUpdateFlag == true)
                 { break; } 
          }
          if(backendFieldUpdateFlag == false)
          {
// check for Environmental field update
             if(mapfields.get('Core_jsonfield__c') != null && cs.get('Core_jsonfield__c') != oldMap.get(cs.Id).get('Core_jsonfield__c'))    
             {
                backendFieldUpdateFlag = executeBackendFieldUpdateFromCaseEnvDet(cs, envFieldSet, envFieldSetMap, oldMap.get(cs.Id));
             }      
          }         
          if(backendFieldUpdateFlag == true)         
          {             
             if(cs.Core_IPS_BK_Flds_UpdatedAt_PreVal__c == null)
             {
                cs.Core_IPS_BK_Flds_UpdatedAt_PreVal__c = cs.CreatedDate;
                cs.Core_IPS_BK_Flds_UpdatedAt__c = cs.CreatedDate;
             }
             Timezone tz = Timezone.getTimeZone('America/Los_Angeles');
             cs.Core_IPS_BK_Flds_UpdatedAt__c = DateTime.newInstance(System.Now().getTime() + tz.getOffset(System.Now())); 
          }
          else
          {                                                             
             if(cs.Core_IPS_BK_Flds_UpdatedAt__c != null){ cs.Core_IPS_BK_Flds_UpdatedAt_PreVal__c = cs.Core_IPS_BK_Flds_UpdatedAt__c;  }
          }
       }
       }
     } 
   }catch(Exception e) {  }
} 
Public Static boolean executeBackendFieldUpdateFromCaseEnvDet(Case caseRecord, Set<String> envFieldSet, Map<String, String> envFieldSetMap, Case oldCaseRecord)
{  
  boolean backendFieldUpdateFlag = false;  
  Set<ID> caseIdSet = new Set<Id>();  
  Set<String> fieldSet = new Set<String>();  
  Map<String, String> newFields = new Map<String, String>();
  Map<String, String> oldFields = new Map<String, String>();

  try  
  {    
     String jasonStrNew = caseRecord.Core_jsonfield__c;
     String jasonStrOld = oldCaseRecord.Core_jsonfield__c;
       
// Parse the Json strings of the previous and new values and check the backend relevant field is changed or not       
     newFields = parseCaseJsonEnvDetString(jasonStrNew, envFieldSetMap);
     oldFields = parseCaseJsonEnvDetString(jasonStrOld, envFieldSetMap);
     if(newFields.size()>0 && oldFields.size()==0) {  backendFieldUpdateFlag = true; }
// compare the fields:
     if(newfields.size()>0 && oldFields.size()>0)     
     {
       for(String field:envFieldSet)
       {
         if(newfields.get(field)!= null)  
         {
            if((oldfields.get(field) != null && oldfields.get(field) != newfields.get(field)) ||
              (oldfields.get(field) == null && newfields.get(field)!= null))
            {
               backendFieldUpdateFlag = true;
               break;
            }
         }
       }
     }                 
   } catch(Exception e)   {       }  
   return backendFieldUpdateFlag; 
 }   
 Public class caseEnvDet
 {
   public String Qstn;
   public String Ansr;
   
   public caseEnvDet(String Qstn, String Ansr)
   {
      Qstn = Qstn;
      Ansr = Ansr;
   }
 } 
 Public static Map<String, String> parseCaseJsonEnvDetString(String caseJsonStr, Map<String, String> envFieldSetMap)
 {
    Map<String, String> mapFields = new Map<String, String>();
    Try
    {
      JSONParser parser = JSON.createParser(caseJsonStr);
      while (parser.nextToken() != null) 
      {
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) 
        {
          while (parser.nextToken() != null) 
          {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) 
            {
               caseEnvDet csEnvDet = (caseEnvDet)parser.readValueAs(caseEnvDet.class);
               String question = (csEnvDet.Qstn).deleteWhiteSpace();
               If(envFieldSetMap.get(question) !=null)
               {
                  mapFields.put(question, csEnvDet.ansr);
               }
            }
          }
        }
      } 
    } catch(Exception e) {   }
    return mapFields;
 }
	//************************************************************************************//
	// This is main method processes the main backend routing
	//************************************************************************************//        
	Public static void getBackendID(List<case> ListCase, Map<Id, Case> oldMap, String objectType){
		List<Core_IPS_Supported_Product__c> listSuppProd= new List<Core_IPS_Supported_Product__c>();
		List<Core_IPS_Backend_Supported_Product_Map__c> mapsupptBackend = new List<Core_IPS_Backend_Supported_Product_Map__c>();
		Map<ID, Core_IPS_Backend_Supported_Product_Map__c> notDefault = New Map<ID, Core_IPS_Backend_Supported_Product_Map__c>();
		Set<ID> backendSystemIDs = new Set<ID>();
		Map<Id,List<Case>> spIDCaseListMap;
		Map<String,List<Case>> queueCaseListMap;
		Set<ID> suppProdIDs = new Set<ID>();
		ID  supProdID;
		List<Case> csList = new List<Case>();
		List<Case> caseList = new List<case>();
		Map<Id,ID> caseIDSpIDMap = new MAP<Id, ID>();   
		Map<Id, List<Core_IPS_Backend_Supported_Product_Map__c>> csBKSuppProdMap;
		Set<ID> caseSubCatIds = new Set<ID>();
		Map<Id, Case> csMapUpdate = new Map<Id, Case>();
        Boolean handleRecursion = false;

		try{      
			for(Case cs: ListCase){
				if(cs.id==null){
					continue; 
				}
                //Added by chetan to handle recursion for SOQL Error
                if(cs.Core_IPS_BackendID__c == null  && cs.Core_IPS_Supported_Product__c != oldMap.get(cs.Id).Core_IPS_Supported_Product__c 
                   && cs.Core_IPS_Case_Owner__c != oldMap.get(cs.Id).Core_IPS_Case_Owner__c){
                    handleRecursion = true;
                }
                
				if(cs.core_ips_backend_system__c != null && 
				// ( cs.Core_IPS_Restricted_Secret_Content__c == null || ( cs.Core_IPS_Restricted_Secret_Content__c != null && cs.Core_IPS_Restricted_Secret_Content__c == false ))&&
				(cs.core_promote_status__c != null && (cs.core_promote_status__c.equalsignorecase('Promote')|| cs.core_promote_status__c.equalsignorecase('Failed') || cs.core_promote_status__c.equalsignorecase('Done')))){
					cs.core_promote_status__c = 'In Progress';
					if(objectType != null && objectType != 'Case'){    csMapUpdate.put(cs.id, cs);   }
					continue;
				}
				csList.add(cs);
			}
			if(csMapUpdate!= null && csMapUpdate.size()>0){     update csMapUpdate.values();  }
			// First derived the Supported Product ID which contains the product and support org combination
			// Backend Systems are defined at Support Org level and supported product provides the list of 
			// products part of the Support Org which are considered for Case Backend Routing        

			if(csList <> null && csList.size() > 0){
				spIDCaseListMap = getSupportedProductID(csList);
				//Aswin added for queue based routing
				queueCaseListMap = getqueMapRoute(csList);
				for(ID spID: spIDCaseListMap.keyset()){
					caseList = new List<case>();
					caseList = spIDCaseListMap.get(spID);
					for(Case cs1:caseList){
						caseIDspIDMap.put(cs1.id, spId);
					}
				}  
			}

			// if Supported product is found, retrieve backend support Map from "Core_IPS_Backend_Supported_Product_Map__c" considers only active maps
			//getting backend system for all the supported products which are resulted from the first query and only backend system which are active
         
			if( spIDCaseListMap != null && spIDCaseListMap.size() > 0){    
				//Commented out to query IssueCategory child object in single SOQL
					/*mapsupptBackend =[ select name, Core_IPS_Backend_System__c, Core_IPS_Default__c,Core_IPS_Auto_Promote__c, id , Core_IPS_Supported_Product__c from Core_IPS_Backend_Supported_Product_Map__c 
					where Core_IPS_Supported_Product__c=: spIDCaseListMap.keyset() AND 
					Core_IPS_Deactivated__c = false AND
					Core_IPS_Backend_System_Deactivated__c = false AND
					Core_IPS_SP_EIOS_Status__c = false];
					*/
				//FLS check added-Venugopal
                if(Core_IPS_Backend_Supported_Product_Map__c.SObjectType.getDescribe().isAccessible()){
				mapsupptBackend = [SELECT ID, Name, Core_IPS_Backend_System__c, Core_IPS_Default__c,Core_IPS_Queue__c,Core_IPS_Auto_Promote__c, Core_IPS_Supported_Product__c, Core_IPS_Back_Sys_No_Restricted_Secret__c,
                            ( 
                              SELECT Id, Core_IPS_Backend_SP_Map__c, Core_IPS_Case_Category__C, Core_IPS_Case_Category_Name__c, Core_IPS_Case_SubCategory__c, Core_IPS_Case_SubCategory_Name__c 
                              FROM Backend_Issue_Categories_Maps__r WHERE Core_IPS_Deactivated__c = false
                            ) 
                            FROM Core_IPS_Backend_Supported_Product_Map__c 
                            WHERE (Core_IPS_Supported_Product__c=: spIDCaseListMap.keyset() OR Core_IPS_Queue__c =: queueCaseListMap.keyset()) AND Core_IPS_Deactivated__c = false AND Core_IPS_Backend_System_Deactivated__c = false AND Core_IPS_SP_EIOS_Status__c = false];     
               			}
			}

			// Main Processing Starts here
			List<Case> caseListForCriteria = new List<case>();           
			if(mapsupptBackend!=null && mapsupptBackend.size()>0){
				// for each case get the map of case id with list of backend supported product map id
				for(Case cs:csList){
					supProdID = caseIDspIDMap.get((id)cs.id);
					Boolean isBSUpdated = FALSE;
					if(supProdID == null){   continue;      }      
					caseListForCriteria = new List<case>();
					List<Core_IPS_Backend_Supported_Product_Map__c> listProd = new List<Core_IPS_Backend_Supported_Product_Map__c>();          
					csBKSuppProdMap= new Map<Id, List<Core_IPS_Backend_Supported_Product_Map__c>>();					
				
					for(Core_IPS_Backend_Supported_Product_Map__c prod : mapsupptBackend){					
						
						if(prod.Core_IPS_Supported_Product__c ==  supProdID ){
							if(!isBSUpdated && oldMap.get(cs.id).Core_IPS_Backend_System__c != null && cs.Core_IPS_Backend_System__c != null && cs.Core_IPS_Backend_System__c != oldMap.get(cs.id).Core_IPS_Backend_System__c ){ isBSUpdated = TRUE; }
							
							/** Commented out below code to allow case records for BackendStamping even if 'Auto-promote' is false 05102016**/
							//ignore the backend system which does not support auto promote and the case is not set for manual promote
							/*  if((cs.core_promote_status__c==null || (cs.core_promote_status__c!=null && cs.core_promote_status__c!='Promote')) && prod.core_ips_auto_promote__c==false) 
							{
							continue;
							}*/
							/*if(prod.Core_IPS_Back_Sys_No_Restricted_Secret__c != null && prod.Core_IPS_Back_Sys_No_Restricted_Secret__c == true && 
							cs.Core_IPS_Restricted_Secret_Content__c != null && cs.Core_IPS_Restricted_Secret_Content__c == true)
							{
							continue;                
							}*/

							/* Sneha US454558 TECH: BES:  Enable changing of DCG JIRA backend systems START */
						  
							if(isBSUpdated && prod.Core_IPS_Backend_System__c.equals(cs.Core_IPS_Backend_System__c) && !prod.Core_IPS_Auto_Promote__c){
								stampBackendID(prod.Core_IPS_Backend_System__c,prod.Core_IPS_Auto_Promote__c, cs, objectType);
								break;
							}
							/* Sneha US454558 TECH: BES:  Enable changing of DCG JIRA backend systems END*/
						   if(!isBSUpdated && prod.Core_IPS_Default__c == true){  // stamp the first default backend system  
							  
							   if(cs.Core_IPS_Backend_System__c == null) {
								   stampBackendID(prod.Core_IPS_Backend_System__c,prod.Core_IPS_Auto_Promote__c, cs, objectType);   
								}                   
							}
							else{     
								if(!isBSUpdated){
									listProd.add(prod); //list of backend supported product records
									notDefault.put(prod.id, prod);  //list of Backend supported product Ids and records Map                    
									backendSystemIDs.add(prod.Core_IPS_Backend_System__c);    // get all Backend System IDs for the backend SP map ID 
								}
							}                  
						}
						//************added for queue routing 
						else{
							if(prod.Core_IPS_Queue__c != null && prod.Core_IPS_Queue__c != ''){
								if(prod.Core_IPS_Default__c == true){  
									// stamp the first default backend system  
									if(cs.Core_IPS_Backend_System__c == null){
									   stampBackendID(prod.Core_IPS_Backend_System__c,prod.Core_IPS_Auto_Promote__c, cs, objectType);   
									}                   
								}
								else{                   
									listProd.add(prod); //list of backend supported product records
									notDefault.put(prod.id, prod);  //list of Backend supported product Ids and records Map                    
									backendSystemIDs.add(prod.Core_IPS_Backend_System__c);    // get all Backend System IDs for the backend SP map ID 
								}   
                     
							}
                 
						} 
						//***********end here************                            
					}  
                    if(ListProd <> null && Listprod.size()>0){
						csBKSuppProdMap.put(cs.id, ListProd);
                        suppProdIds.add(supProdID);
						caseListForCriteria.add(cs);
						if(cs.Core_Case_Issue_Sub_Category__c <> null) { caseSubCatIds.add( cs.Core_Case_Issue_Sub_Category__c ); }                
					}
				}
            
				if(csBKSuppProdMap <> null && csBKSuppProdMap.size()>0){
					checkCriteria(suppProdIds, backendSystemIDs, caseSubCatIds, caseIDspIDMap, csBKSuppProdMap, notDefault, objectType, caseListForCriteria, oldMap); 
				}             
			}
		} catch(Exception e) {  }
	}    //End of method  getBackendID 

public static void checkCriteria(Set<Id> suppProdIDs, Set<ID> backendSysIDs, Set<ID> caseSubCatIds, Map<Id, ID> caseIDspIDMap, Map<Id, List<Core_IPS_Backend_Supported_Product_Map__c>> csBKSuppProdMap, Map<Id,Core_IPS_Backend_Supported_Product_Map__c> bksupIdObjMap, String objectType, List<Case> caseListAll, Map<Id, Case> oldMap)
{
  List<Core_IPS_Backend_Env_Details_Map__c> listEnvCriteria = new List<Core_IPS_Backend_Env_Details_Map__c>();
  List< Core_IPS_Backend_Case_Categories_Map__c> issueCatListCriteria = new List< Core_IPS_Backend_Case_Categories_Map__c>();
  /**********Changing the list type of CaseEnvDetResponse for environmental object change*****3/19/18*******/
  //List<Core_IPS_Environment_Details__c> CaseEnvDetResponse = new List<Core_IPS_Environment_Details__c>();
  /*********created new list of type Core_IPS_Response__c*********3/19/18********/
  List<Core_IPS_Response__c> CaseEnvDetResponse = new List<Core_IPS_Response__c>();
  
  List<Core_IPS_Assigned_Environment_Variables__c> caseAssignedEnvDet = new List<Core_IPS_Assigned_Environment_Variables__c>();
  List<Core_IPS_Assigned_Environment_Variables__c> caseAssignedEnvDet1 = new List<Core_IPS_Assigned_Environment_Variables__c>();
  Map< String,String> caseEnvDetQA; 
  Map<ID, map<String,string>> caseEnvQAmap = new Map<Id, Map<String, String>>();
  List<Core_IPS_Backend_Supported_Product_Map__c> bksupIDObjList;
  Core_IPS_Backend_Supported_Product_Map__c supIDObj;
  ID backendID;
  Set<String> questionSet;
  Map<String,String> questionAns; 
  boolean matched_flag = false;
  List<ID> listNotEnv = new List<ID>();
  boolean bk_system_stamped = false; 
  Integer only_env_details = 0;
  Boolean hasAssignedEnvVar = false;
  List<Core_IPS_Backend_Supported_Product_Map__c> bkSuppProdObjlistNoEnv = new List<Core_IPS_Backend_Supported_Product_Map__c>();
  ID supProdID;
  Map<ID, Case> csMap = new Map<ID, Case>();
  Map<Id, Case> csMapFinalList = new Map<Id, Case>();  
  List<Case> csList = new List<Case>();
  
  /** Updated the code to resolve Prod issue : tanvix.chauhan 03052016 **/
 try{
  
// Get the environmental details criteria for all backend Ids - note environmental details criteria are defined at backend system ID level   
// FLS check added-Venugopal   
     if(Core_IPS_Backend_Env_Details_Map__c.SObjectType.getDescribe().isAccessible()){
     	listEnvCriteria =[SELECT Name, Core_IPS_Backend_System__c, Core_IPS_Environment_Variable_Answer__c,Core_IPS_Environment_Variable_Question__c
    	FROM Core_IPS_Backend_Env_Details_Map__c WHERE Core_IPS_Backend_System__c IN: backendSysIDs AND Core_IPS_Deactivated__c = false];  
     }
/** Added this 'IF' condition to query Assigned Env Details only if 'Environment details criteria exists for all Backend Ids 05102016 **/
 if(listEnvCriteria.size() > 0){
    // get the assigned environmental details for the case Supported IDs or Issue Sub Categories
       caseAssignedEnvDet =[SELECT id, Core_Supported_Product__c , Core_Product_Issue_Sub_Category__c FROM Core_IPS_Assigned_Environment_Variables__c 
                           WHERE (Core_Supported_Product__c IN:suppProdIDs) OR (Core_Product_Issue_Sub_Category__c IN:caseSubCatIds) ];  

      //Merging the following Query with the above---06092016---tanvix.chauhan
      /*caseAssignedEnvDet1 =[SELECT id, Core_Supported_Product__c , Core_Product_Issue_Sub_Category__c FROM Core_IPS_Assigned_Environment_Variables__c WHERE Core_Product_Issue_Sub_Category__c IN:caseSubCatIds];  
      if(caseAssignedEnvDet1 <> null && caseAssignedEnvDet1.size()>0) { 
        caseAssignedEnvDet.addAll(caseAssignedEnvDet1);
      }*/  
  
      if(!caseAssignedEnvDet.isEmpty()){
      //Get the environmental responses for the case ID if assigned environmental details exists for the case Supported Ids
      /**********Changing the query for environmental object change*****3/19/18*******/
        //CaseEnvDetResponse=[SELECT Core_Question__c , Core_Answer__c, Core_Case__c FROM Core_IPS_Environment_Details__c WHERE Core_Case__c IN:csBKSuppProdMap.keyset()];
           //FLS check added-Venugopal
          if(Core_IPS_Response__c.SObjectType.getDescribe().isAccessible()){
          	CaseEnvDetResponse=[SELECT Core_IPS_ANswer__c,Core_IPS_Question__c,Core_IPS_Case__c FROM Core_IPS_Response__c WHERE Core_IPS_Case__c IN:csBKSuppProdMap.keyset()  ];//AND (Core_IPS_Survey_Type__c = null OR Core_IPS_Survey_Type__c ='')
          }
      }

}    //End of 'if' listEnvCriteria check

  Map<Id, Id> spProductsMap = new Map<Id, Id>();            //Map(EnvDetailsID, SupportedProd id)

  for(Core_IPS_Assigned_Environment_Variables__c assigned : caseAssignedEnvDet){
        if(assigned.Core_Supported_Product__c != Null){
            spProductsMap.put(assigned.Core_Supported_Product__c, assigned.Core_Supported_Product__c);
        }
        if(assigned.Core_Product_Issue_Sub_Category__c != Null){
            spProductsMap.put(assigned.Core_Product_Issue_Sub_Category__c, assigned.Core_Product_Issue_Sub_Category__c);
        }
   }
   
  
  for(Case cs:caseListAll){
  //<Id,Case> Trigger old map will be empty when this method is called from CaseAttachment use case---05/30/2016---tanvix.chauhan
  if(!oldMap.isEmpty()) {  
      //check if it is not the initial value
      if((oldMap.get(cs.Id)).Core_IPS_Supported_Product__c != NULL){
      //if new list but supported products are Different
      if(cs.Core_IPS_Supported_Product__c != (oldMap.get(cs.Id)).Core_IPS_Supported_Product__c){
      
      //check if assigned env variable is there or not
      if(spProductsMap.keySet() != NULL && ((spProductsMap.get(cs.Core_IPS_Supported_Product__c) != Null) || (spProductsMap.get(cs.Core_Case_Issue_Sub_Category__c) != Null ))){
            if(cs.Core_jsonfield__c != (oldMap.get(cs.Id)).Core_jsonfield__c){    csList.add(cs);  }
          }
          else{
            csList.add(cs);
          }
        }
        else{
            csList.add(cs);
        }
    }
    else{
        csList.add(cs);
    } 
  
  }
    
  }
  
  if(csList.size() == 0){
      return;
  } 


/** Commented SOQL to retrieve IssueCategory list - tanvix.chauhan---06-11-2016 **/
// Get Issue categories criteria defined for all support product backend system map IDs    List< Core_IPS_Backend_Case_Categories_Map__c>  
   /*issueCatListCriteria =[SELECT id,Core_IPS_Backend_SP_Map__c,Core_IPS_Case_Category__C, Core_IPS_Case_Category_Name__c, Core_IPS_Case_SubCategory__c, Core_IPS_Case_SubCategory_Name__c FROM Core_IPS_Backend_Case_Categories_Map__c 
       WHERE Core_IPS_Backend_SP_Map__c=:bksupIDObjMap.keyset() AND Core_IPS_Deactivated__c = false];
   */
   
  for(Core_IPS_Backend_Supported_Product_Map__c parent : bksupIDObjMap.values()){
    List<Core_IPS_Backend_Case_Categories_Map__c> listOfIssueCat = parent.Backend_Issue_Categories_Maps__r;
    for(Core_IPS_Backend_Case_Categories_Map__c child : listOfIssueCat){
        issueCatListCriteria.add(child);
    }
  } 
   
//Start preparing data for processing
//First get the Question and answer map for the case environmental details
  for(Case cs:csList) {
// get the list of backend supported ID maps for this case  
        bksupIDObjList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
        bksupIDObjList =  csBKSuppProdMap.get(cs.id);
        supProdID = caseIDspIDMap.get(cs.id);
            
        caseEnvDetQA = new Map<String, String>();
        /***********commented for environmetal object change 3/19/18*************/
        //for(Core_IPS_Environment_Details__c csenv : CaseEnvDetResponse){
        for(Core_IPS_Response__c csenv : CaseEnvDetResponse){
            /********commented for environmetal object change 3/19/18*********/
           //if(csenv.Core_Case__c == cs.id)Core_IPS_Case__c
           if(csenv.Core_IPS_Case__c== cs.id)
           {
            /********commented for env ironmetal object change 3/19/18*********/
             //caseEnvDetQA.put(csenv.Core_Question__c,(csenv.Core_Question__c + csenv.Core_Answer__c).deleteWhitespace());
             /********added new response object fields to map*************3/19/18***/
             caseEnvDetQA.put(csenv.Core_IPS_Question__c,(csenv.Core_IPS_Question__c+ csenv.Core_IPS_Answer__c).deleteWhitespace());
           }        
        }
        
        if(caseEnvDetQA.size()>0){
           caseEnvQAmap.put(cs.id,caseEnvDetQA);  
        }

// get the assigned environment varaibles:
        hasAssignedEnvVar = false;
        /** Commented out 'for loop' to reuse values stored in 'spProductsMap' by tanvix.chauhan 05092016**/
        /*for(Core_IPS_Assigned_Environment_Variables__c csAssignedEnv:caseAssignedEnvDet){
          if((csAssignedEnv.core_supported_product__c <> null && csAssignedEnv.core_supported_product__c == supProdID) || 
             (csAssignedEnv.Core_Product_Issue_Sub_Category__c <> null && csAssignedEnv.Core_Product_Issue_Sub_Category__c == cs.Core_Case_Issue_Sub_Category__c))
          {
            hasAssignedEnvVar = true;
            break;
          }        
        }*/
        
        if(spProductsMap.keySet() != NULL && (spProductsMap.get(supProdID) <> Null || spProductsMap.get(cs.Core_Case_Issue_Sub_Category__c) <> Null)){
                hasAssignedEnvVar = true;
        }
        
        if(hasAssignedEnvVar == false)  ///go directly for issue categories check for only backend supported product with no environmentl details criteria defined
        {
           if(listEnvCriteria.size() == 0)
           {  bkSuppProdObjlistNoEnv.addAll(bksupIDObjList);  }
           else
           {   
              boolean env_criteria_exists = false;
              for(Core_IPS_Backend_Supported_Product_Map__c bksupIDObj1: bksupIDObjList) 
              {
                 env_criteria_exists = false;
                 for(Core_IPS_Backend_Env_Details_Map__c env1:listEnvCriteria)   
                 {
                    if(env1.Core_IPS_Backend_System__c!=null && env1.Core_IPS_Backend_System__c == bksupIdObj1.Core_IPS_Backend_System__c)
                    {
                       env_criteria_exists = true;
                       break;
                    }
                 } 
                 if(env_criteria_exists == false) {   bkSuppProdObjlistNoEnv.add(bksupIDObj1); }
              }              
           }   
        }          
        else
        {
          if(bksupIDObjList <> null && caseEnvQAmap.size()>0)
          {        
             for(Core_IPS_Backend_Supported_Product_Map__c bksupIDObj: bksupIDObjList)   
             {
               questionSet = new Set<String>();
               questionAns = new Map<String,String>();
               matched_flag = false;                      
               backendID = bksupIdObj.Core_IPS_Backend_System__c; 
// get the environmental check criteria and form the question and answer map

              for(Core_IPS_Backend_Env_Details_Map__c env:listEnvCriteria)
              {
                 if(env.Core_IPS_Backend_System__c!=null && env.Core_IPS_Backend_System__c == backendID)
                 {
                    String questionanswer = (env.Core_IPS_Environment_Variable_Question__c+env.Core_IPS_Environment_Variable_Answer__c).deleteWhitespace();
                    questionAns.put(questionanswer,questionanswer);
                    questionSet.add(env.Core_IPS_Environment_Variable_Question__c);  
                 }
               }
// check environmental assigned records exist or not for the supported product
// // collect the supported product ids to perform issue catgeories check           
               if(questionSet ==  null || questionSet.size()==0)   {    bkSuppProdObjlistNoEnv.add(bksupIDObj);  }
               else
               {
// perform environmental check  
                   matched_flag = checkEnvironmentalCriteria( bksupIDObj, caseEnvDetQA, questionSet, questionAns ); 
                   if(matched_flag == true)
                   {
// proceed with issue catgeories check
                     Integer res = checkIssueCategoriesCriteria(issueCatListCriteria,bksupIDObj.id,cs);
                     if(res == 0)
                     {                          
//Issue catgeories are not maintained as part of criteria stamp the backend id which has pass environmental check
                        only_env_details = only_env_details + 1;
                        if(cs.Core_IPS_Backend_System__c == null || only_env_details == 1)
                        {
                           csMap = stampBackendID(bksupIDObj.Core_IPS_Backend_System__c, bksupIDObj.Core_IPS_Auto_Promote__c, cs, objectType);                           
                           bk_system_stamped = true;
                           if(csMap!= null && csMap.size()>0){ csMapFinalList.putAll(csMap);  }                         
                           if(issueCatListCriteria.size()==0){  break; }               
                        }          
                     }
                     else if (res == 1)
                     {
                        csMap = stampBackendID(bksupIDObj.Core_IPS_Backend_System__c, bksupIDObj.Core_IPS_Auto_Promote__c, cs, objectType);
                        bk_system_stamped = true;
                        if(csMap!= null && csMap.size()>0)
                        { csmapFinalList.putAll(csMap); }                       
                        Break;                
                     }                               
                  }           
               }         
             } 
           }
        }
    
 // process all the backend supported product map ids for which environmental checks not done.
 // first perform issue categories check
        if(bk_system_stamped == false && bkSuppProdObjlistNoEnv!= null && bkSuppProdObjlistNoEnv.size()>0)  
        {          
          for(Core_IPS_Backend_Supported_Product_Map__c bkspObj:bkSuppProdObjlistNoEnv)
          {         
             Integer res = checkIssueCategoriesCriteria(issueCatListCriteria,bkspObj.id,cs);
             if (res == 1){
                csMap = stampBackendID(bkspObj.Core_IPS_Backend_System__c, bkspObj.Core_IPS_Auto_Promote__c, cs, objectType);
                bk_system_stamped = true;
                if(csMap!= null && csMap.size()>0){ csMapFinalList.putAll(csMap);  }
                Break;                
             }
             if (res == 0 && bk_system_stamped == false){
                csMap = stampBackendID(bkspObj.Core_IPS_Backend_System__c, bkspObj.Core_IPS_Auto_Promote__c, cs, objectType);
                if(csMap!= null && csMap.size()>0)
                { csMapFinalList.putAll(csMap);  }
             }             
           }            
         } 
     } 
     if(csMapFinalList!= null && csMapFinalList.size()>0 && objectType != null && objectType != 'Case' ){ 
        update csmapFinalList.values();  
    }                                           
  } catch(Exception e) {  }
} 
public static boolean checkEnvironmentalCriteria(Core_IPS_Backend_Supported_Product_Map__c bksuppProdObj,Map<String, String> caseEnvDetQA, Set<String> questionSet,Map<String, String> questionAns)
{
   boolean matched_flag;
   try
   {
      if(questionSet.size()>0)
      {                              
         for(String question:questionSet)
         {
             String caseQA = caseEnvDetQA.get(question); 
                    
             if (questionAns.get(caseQA)!= null && caseQA.equalsignorecase(questionAns.get(caseQA)))
             {  matched_flag = true;   }
             else
             {
                matched_flag = false;
                break;
             }               
           }    
        }
   } catch(Exception e)  {   }
   return matched_flag;
}             

// *******This method derives the supported product id for a case ***********
//********which is the main input to start processing the logic  ************
//***first step look for supported product Id at case level **********************
//***second read from asset if not found in first step*******
Public Static Map<ID, List<Case>> getSupportedProductID(List<Case> csList)
{
 Map<Id,Id> caseIDsuppProdIdMap;
 Map<Id, List<Case>> suppProdIDCaseListMap;
 ID prodID;
 ID suppOrgID;
 Set<ID> suppProdIDList = new Set<ID>();
 List<Case> suppProdCaseList = new List<Case>();
 List<Case> noSuppProdCaseList = new List<Case>();
 List<Core_IPS_Supported_Product__c> listSuppProd= new List<Core_IPS_Supported_Product__c>();
 List<Asset> assetList= new List<Asset>();
 Set<ID> assetIDs = new Set<ID>();
 Map<ID,ID> prodSupOrgMap = new Map<ID, ID>();
 List<Case> cslist1 = new List<Case>();
     try
    {  
   if(csList <> null && csList.size() > 0){
       caseIDsuppProdIdMap = new Map<Id,Id>();
       suppProdIDCaselistMap = new Map<Id, List<Case>>();
       List<Case> caseList;
       for(Case csObj:csList)
       {
         if(csObj.Core_IPS_Supported_Product__c <> null)
         { 
           suppProdIDList.add(csObj.Core_IPS_Supported_Product__c);
           suppProdCaseList.add(csObj);
         }
         else  
         {             
            if(csObj.assetid!=null)  
            {  
               assetIDs.add(csObj.assetid);
               noSuppProdCaseList.add(csObj); 
            }
         }      
       }
       for(ID suppProdID:suppProdIDList)
       {
           caseList = new List<Case>();
           for(Case csObj1:suppProdCaseList)
           {
               if(csObj1.Core_IPS_Supported_Product__c <> null && csObj1.Core_IPS_Supported_Product__c == suppProdID)
               {    caseList.add(csObj1); }
           }
           if(caseList <> null && caseList.size() >0 )
           {  suppProdIDCaseListMap.put(suppProdID, caseList);    }  
       } 
   }
     
   if (assetIDs <> null && assetIds.size()>0)
   {
       //FLS check added-Venugopal
       if(Asset.SObjectType.getDescribe().isAccessible()){
       		assetList=[SELECT core_supported_product__c, Product2id, Core_Product_Organization__c From Asset Where id IN:assetIds];
       }
       if(assetlist <> null && assetList.size()>0)
     {
       for(Asset asset:assetList)
       {
         cslist1 = new List<Case>();
         if(asset.Core_Supported_Product__c <> null )
         {
           for(Case cs:noSuppProdCaseList)
           {
             if(asset.id == cs.assetid) 
             { cslist1.add(cs);  }
           }
           if(cslist1 <> null && cslist1.size() >0) 
           {  suppProdIDCaseListMap.put(asset.Core_Supported_Product__c, csList1); }
         }
       }
     }
   }  
 } catch(Exception e) {    }   
 return  suppProdIDCaseListMap;

} //End of method "getSupportedProductID"
//**********methode to form map of queue and case*****************
public static map<string,list<case>> getqueMapRoute(List<Case> csList){

    Map<String,List<Case>> mapQueCase = new Map<String,List<Case>>();
    try{
        if(csList <> null && csList.size() > 0){
         for(case dl:csList){
                 
                 //================adding value to map=========
                     
                      if(mapQueCase.containsKey(dl.Core_IPS_Assigned_Queue__c)) 
                    {
                        mapQueCase.get(dl.Core_IPS_Assigned_Queue__c).add(dl);
                    }
                    else
                    {
                        List<case> lineList= new List<case>();
                        lineList.add(dl);
                        mapQueCase.put(dl.Core_IPS_Assigned_Queue__c, lineList);
                    }
                 
                 //=================end==============
                  
               }
        }
    } catch(exception e){   }

return mapQueCase;
}

//**********This method checks the Issue Category Criteria to stamp backend ID ***************
//**********which is called inside the method "checkIssueCategoriesCriteria" *****************
Public Static Boolean checkIssueCategoryWithCase(List<Core_IPS_Backend_Case_Categories_Map__c> i_isscatList, case i_cs)
{
  boolean matched_flag = false;
  try
  {
    for(Core_IPS_Backend_Case_categories_Map__c issuecat:i_isscatList)
    {
      if(issuecat.Core_IPS_Case_Category_Name__c != null && issuecat.Core_IPS_Case_Category_Name__c == i_cs.Core_External_Issue_Category__c)
      { 
         matched_flag = true;
         if(issuecat.Core_IPS_Case_SubCategory_Name__c == null) 
         {
		break;
	 }
         else
         { 
            if(issuecat.Core_IPS_Case_SubCategory_Name__c == i_cs.Core_External_Issue_SubCategory__c){ 
		matched_flag = true;
		break;
	    } 
            else 
            {
		matched_flag = false;
	    } 
         }
      }
   }   
 } catch(Exception e) {    }     
 return matched_flag;
    
} //End of Method: "Boolean checkIssueCategoryWithCase(List<Core_IPS_Backend_Case_Categories_Map__c> i_isscatList, case i_cs)" 

//**************This method checks whether the backend system supported product map ids ***************
//**************has the issue categories filter defined or not*****************************************

public static Integer checkIssueCategoriesCriteria(List<Core_IPS_Backend_Case_Categories_Map__c > issueCatList, ID suppProdId, Case cs)
{
 List<Core_IPS_Backend_Case_Categories_Map__c > issueCat = new List<Core_IPS_Backend_Case_Categories_Map__c>();  
 Integer result = 0;
 try
 {  
   for(Core_IPS_Backend_Case_Categories_Map__c issCat:issueCatList) 
   {
     if(suppProdId == issCat.Core_IPS_Backend_SP_Map__c)
     {  issueCat.add(issCat); }
   }   
 
  if(issueCat.size()>0)
  {  
     boolean res = checkIssueCategoryWithCase(issueCat, cs);
     if(res == true)
     {  result = 1;  } //"Check passed          
     else { result = -1;  } //"Check not passed
  }
  else
  { result = 0;  } //"issue categories not maintained
 } catch(Exception e) {   }          
 return result;
}  // End of Method: "Integer checkIssueCategoriesCriteria(List<Core_IPS_Backend_Case_Categories_Map__c > issueCatList, ID suppProdId)" 


//*************This method stamps the determined Backend System on the case and ************************
//*************set the Promote Status field to "In Progress" which will be picked up *******************
//*************by workflow rule to trigger outbound message to IPaas************************************
public Static Map<Id, Case> stampBackendID(ID backendID, Boolean auto_promote, Case cs, String objectType)
{    
   Map<ID, Case> csMap = new Map<ID, Case>();
   Boolean update_object = false;
   try {
   if(backendID != null){
       cs.core_IPS_backend_system__c= backendID;  //backendID_from_db[0].id;
       /** Added auto promote check to determine the promote status by tanvix.chauhan 05102016**/
       if(auto_promote == true){
           cs.core_promote_status__c='In Progress';
       }else{
           cs.core_promote_status__c ='Not Yet Promoted';
       }
       
       csMap.put(cs.id, cs); 
    }
    else
    { }
 } catch(Exception e) { } 
 return csMap;
} //End of Method "void stampBackendID(ID backendID, Case cs)"   

} //End of Class