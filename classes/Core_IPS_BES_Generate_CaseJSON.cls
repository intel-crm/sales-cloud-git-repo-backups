public with sharing class Core_IPS_BES_Generate_CaseJSON {
    
    public static Map<String, JSONGenerator> getJsonForCaseObject(List<Id> caseIdList)
    {
        //Declarations
        String sObjectFields = ''; //this will contain fields that will be used to Query Case object
        String sObjectFieldsEnv = '';//this will contain fields that will be used to Query Response object for EDQ Section
        String objName ='Case'; //USed in case query From object parameter
        Map<String,List<IPS_Case_Fields__c>> dataX = new Map<String,List<IPS_Case_Fields__c>>();//building a map from custom setting as Object name as key and Object as value.
        Map<String,String> fieldMap = new Map<String, String>(); //contains case object Map
        Map<String,String> fieldMapEnv = new Map<String, String>(); //Contains Response object map(EDQ)
        Map<String, IPS_Case_Fields__c > additionalInfoMap = new Map<String, IPS_Case_Fields__c >();//this map is used to store field-value mapping for those objects where checkbox is checked in custom setting
        Transient Map<String, JSONGenerator> genMap = new Map<String, JSONGenerator>();
        Map<String, String> quesAnsMap;
        Map<String, String> tableMap = new Map<String, String>();
        Map<String, Map<String,String>> caseIdTableMap = new Map<String, Map<String,String>>();
        String jsonData = '';
        String formedAttachemntBody ='';
        String exceptionGeneratedCase ='';
        List<Id> DCGCaseList = new List<Id>();
        Map<String,CaseHistory> casePrevNewValues = new Map<String,CaseHistory>();
        List<Core_IPS_BES_Questions__c> customRecList = Core_IPS_BES_Questions__c.getAll().values();
        Map<String, String> retrievedValues= new Map<String, String>();
		List<IPS_Case_Fields__c> allCustomSettings = new List<IPS_Case_Fields__c>();
        Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping = new Map<String,List<Core_IPS_BES_AllTenants_CustomMapping__c>>(); //15-9-23
        Map<String,Core_IPS_BES_CaseTypeMapping__c> customArticleTypeMapping = new Map<String,Core_IPS_BES_CaseTypeMapping__c>();// 20-05-2024
        Map<String,String> articleTypeMapping = new Map<String,String>();// 20-05-2024
        try{
            if(caseIdList.size()>0) {
                if(IPS_Case_Fields__c.SObjectType.getDescribe().isQueryable()){
                    allCustomSettings =[Select id, Object_Name__c, API_Name__c, JSON_Field_Name__c,Order__c,Additional_Info__c from IPS_Case_Fields__c order by Order__c DESC Limit 49999]; //Limit Added by Tushar
                    
                    for(IPS_Case_Fields__c  cc : allCustomSettings) {
                        if(cc.Object_Name__c == 'Case'){
                             if(cc.API_Name__c == 'Account.Core_CIM_ID__c' && Label.Core_IPS_UCD_Toggle_Switch == '1') {
                                 fieldMap.put('Account.Core_Business_Party_Id__c', 'account_cim_id');
                             } else {
                                 fieldMap.put(cc.API_Name__c, cc.JSON_Field_Name__c);
                             }
                        }
                        if(cc.Object_Name__c == 'Core_IPS_Response__c'){
                            fieldMapEnv.put(cc.API_Name__c, cc.JSON_Field_Name__c);
                        }
                        if(cc.Additional_Info__c == true){
                             if(cc.API_Name__c == 'Account.Core_CIM_ID__c' && Label.Core_IPS_UCD_Toggle_Switch == '1') {
                                 additionalInfoMap.put('Account.Core_Business_Party_Id__c', new IPS_Case_Fields__c(
                                     														API_Name__c = 'Account.Core_Business_Party_Id__c',
                                 															JSON_Field_Name__c='account_cim_id',Additional_Info__c = true));
                             } else {
                            	additionalInfoMap.put(cc.API_Name__c, cc);
                             }
                        }
                        //Default value
                    }
                }
                
                sObjectFields = String.join(new List<String>(fieldMap.keySet()),',');
                //Dynamic SOQL Query with all fields
                
                String soqlQuery = 'SELECT '+ sObjectFields +' FROM '+objName+' WHERE Id IN: caseIdList';                
                List<sObject> sObjList = Database.Query(soqlQuery);
                sObjectFieldsEnv = String.join(new List<String>(fieldMapEnv.keySet()), ',');
                sObjectFieldsEnv+=',Core_IPS_Case__c ';
                String objNameNew = 'Core_IPS_Response__c';
                String soqlQueryEnv = 'SELECT '+ sObjectFieldsEnv +' FROM '+objNameNew+' WHERE Core_IPS_Case__c IN: caseIdList';
                
                sObject test1 ;
                List<sObject> sObjEnv = Database.Query(soqlQueryEnv);
                
                // Map<String, String> queAnsMap = new Map<String,String>();
                Map<String,Map<String,String>> queAnsMapwithCase = new Map<String, Map<String,String>>();
                if(sObjEnv!= null){
                    for(sObject resobj:sObjEnv){
                        if(queAnsMapwithCase.get(String.valueof(resobj.get('Core_IPS_Case__c')))!=null){
                            
                            if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))==null){
                                queAnsMapwithCase.get(String.valueof(resobj.get('Core_IPS_Case__c'))).put('DefaultedValue',String.ValueOf(resobj.get('Core_IPS_Answer__c')));
                            }else if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))!= '' && String.ValueOf(resobj.get('Core_IPS_Answer__c'))!= ''){
                                queAnsMapwithCase.get(String.valueof(resobj.get('Core_IPS_Case__c'))).put(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c')),String.ValueOf(resobj.get('Core_IPS_Answer__c')));
                            }else if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))!= '' && String.ValueOf(resobj.get('Core_IPS_Answer__c'))== ''){
                                queAnsMapwithCase.get(String.valueof(resobj.get('Core_IPS_Case__c'))).put(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c')),'');
                            }
                        }else{
                            
                            if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))==null){
                                queAnsMapwithCase.put(String.valueof(resobj.get('Core_IPS_Case__c')), new Map<String,String>{'DefaultedValue' => String.ValueOf(resobj.get('Core_IPS_Answer__c'))}); 
                            }else if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))!= '' && String.ValueOf(resobj.get('Core_IPS_Answer__c'))!= ''){
                                queAnsMapwithCase.put(String.valueof(resobj.get('Core_IPS_Case__c')), new Map<String,String>{String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c')) => String.ValueOf(resobj.get('Core_IPS_Answer__c'))}); 
                            }else if(String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c'))!= '' && String.ValueOf(resobj.get('Core_IPS_Answer__c'))== ''){
                                queAnsMapwithCase.put(String.valueof(resobj.get('Core_IPS_Case__c')), new Map<String,String>{String.valueof(resobj.getSObject('Core_IPS_Question_Master__r').get('Core_IPS_Reporting_Name__c')) => ''}); 
                            }
                        }
                        
                    }  
                    
                }
                    
                customMapping = prepareCustomSettingData();
                // Added by Pavani for grabbing only DCG case IDs and get their respective CaseHistory latest records - TWC745-5487 - 26/02/2024
                for(sObject sobj1: sObjList){ 
                    if(sObj1.getsObject('Core_IPS_New_Backend_System__r') != null && sObj1.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && String.ValueOf(sObj1.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('DCG') ){
                    	DCGCaseList.add((Id) sobj1.get('Id'));  
                    }
                }
                if(!DCGCaseList.isEmpty()){
                    // Added by Pavani for getting ArticleType Mapping custom setting records - 20/05/2024
                     customArticleTypeMapping = Core_IPS_BES_CaseTypeMapping__c.getAll();
                     for(String c: customArticleTypeMapping.keySet()){
                          articleTypeMapping.put(customArticleTypeMapping.get(c).HSD_Article_Type__c,customArticleTypeMapping.get(c).Default_Status_Reason__c	);
                     }//END - 20/05/2024
                     customArticleTypeMapping.clear();
                   casePrevNewValues = Core_IPS_BES_HSD_CustomLogic.getPrevNewValuesLogic(DCGCaseList);
                 
                }
              	// End by Pavani - TWC745-5487 - 26/02/2024
                //start JSON
                // Ajith added this to Concatenate the Edq value
                string getBackendSystemName;
                string checkBESName;
                boolean checkBackendSystems;
                for(sObject sobj: sObjList){ 
                    exceptionGeneratedCase = (String) sobj.get('Id');
                    quesAnsMap = queAnsMapwithCase.get(String.valueof(sObj.get('Id'))); //20/9/23
                    String newReasonValue = '';
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null){
                    	getBackendSystemName = String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name'));
                    }
                    // if(String.isBlank(containsBackendSystems(quesAnsMap,customRecList))){
                    checkBESName = containsBackendSystems(quesAnsMap,customRecList);
                    //}
                    
                    checkBackendSystems=containsQuestionMap(getBackendSystemName,customRecList,quesAnsMap);
                    for(String field: fieldMap.keySet()){
                         if(field.contains('.')){
                            list<String>templist = new list<String>();
                            templist = field.split('\\.');
                             if(sObj.getsObject(templist[0])!= null
                               && sObj.getsObject(templist[0]).get(templist[1])!=null && String.ValueOf(sObj.getsObject(templist[0]).get(templist[1]))!=null && fieldMap.get(field)!=null && String.isNotBlank(String.ValueOf(sObj.getsObject(templist[0]).get(templist[1])))){

                                       gen.writeStringField(fieldMap.get(field),  String.ValueOf(sObj.getsObject(templist[0]).get(templist[1]))); 
                                   
                               }else{
                                   gen.writeStringField(fieldMap.get(field), '');
                               }
                        } else if(sObj.get(field) != null && String.ValueOf(sObj.get(field))!=null && String.isNotBlank(String.ValueOf(sObj.get(field))) ){
                            //this is prem getBase64ImgConvert
                            String caseDescription = ''; // Added By Hassan Khan as a Part for Bug Assist
                            if(field.equalsIgnoreCase('Core_Issue_Description__c')){
                                //if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('CC - HSDES') && quesAnsMap!=null && quesAnsMap.containsKey(Label.Core_IPS_BES_Environmental_Details) && quesAnsMap.get(Label.Core_IPS_BES_Environmental_Details)!='' && quesAnsMap.get(Label.Core_IPS_BES_Environmental_Details)!=null){
                                    //gen.writeStringField(fieldMap.get(field), Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+String.ValueOf(quesAnsMap.get(Label.Core_IPS_BES_Environmental_Details)).replaceAll('\n','<br>')); 
                                //}
                                // Ajith added this to Concatenate the Edq value
                                if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && quesAnsMap!=null && checkBackendSystems && !String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('IoT')){
                                    //  START Added By Hassan Khan as a Part for Bug Assist
                                    if (String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')) == 'CC - HSDES Client Platform') {
                                        String sstLog = String.ValueOf(sObj.get('Do_you_have_SST_log_to_upload__c'));
                                        String sstLogValue = (sstLog == 'true') ? 'yes' : 'no';
                                        String sstReason = String.ValueOf(sObj.get('Reason_for_not_providing_the_SST_Log__c'));
                                        if(sstLogValue == 'no' && sstReason != '' && sstReason != null){
                                            caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+checkBESName;
                                            gen.writeStringField(fieldMap.get(field), caseDescription + '<br><br><br>' + System.label.Core_IPS_Bug_Assist_System_Scope + ' = ' + sstLogValue + ' (reason : '+ sstReason +')' ); 
                                        }
                                        else if(sstLogValue == 'yes' && sstReason == null) {
                                            caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+checkBESName;
                                            gen.writeStringField(fieldMap.get(field), caseDescription + '<br><br><br>' + System.label.Core_IPS_Bug_Assist_System_Scope + ' = ' + sstLogValue); 
                                        } else {
                                            caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+checkBESName;
                                            gen.writeStringField(fieldMap.get(field),caseDescription);
                                        }
                                    } else {
                                        caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+checkBESName;
                                        gen.writeStringField(fieldMap.get(field),caseDescription);
                                    }
                                    // End
                                }else if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('IoT') && sObj.get('Core_Environment_Details__c')!='' && sObj.get('Core_Environment_Details__c')!=null){
                                    String EDQ = String.ValueOf(sObj.get('Core_Environment_Details__c'))?.replace('Question','EDQ');
                                    caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field))) + '<br><br>'+EDQ.replaceAll('\n','<br>');
                                    gen.writeStringField(fieldMap.get(field), caseDescription); 
                                }
                                else{
                                    caseDescription = Core_IPS_JSON_Utility.getBase64ImgConvert(String.ValueOf(sObj.get(field)));
                                    gen.writeStringField(fieldMap.get(field), caseDescription);
                                }
                            }
                            else if(field.equalsIgnoreCase('Core_Contact_Name__c')){
                                if(sObj.getsObject('Contact')!= null && String.ValueOf(sObj.getsObject('Contact').get('LastName'))!=null && String.ValueOf(sObj.getsObject('Contact').get('FirstName'))!=null ){
                                    gen.writeStringField(fieldMap.get(field),  String.ValueOf(sObj.getsObject('Contact').get('LastName')) + ',' + String.ValueOf(sObj.getsObject('Contact').get('FirstName')));
                                }
                                else if(sObj.getsObject('CreatedBy')!= null && String.ValueOf(sObj.getsObject('CreatedBy').get('LastName'))!=null && String.ValueOf(sObj.getsObject('CreatedBy').get('FirstName'))!=null ){
                                    gen.writeStringField(fieldMap.get(field),  String.ValueOf(sObj.getsObject('CreatedBy').get('LastName')) + ',' + String.ValueOf(sObj.getsObject('CreatedBy').get('FirstName')));
                                }
                            }
                            else if(field.equalsIgnoreCase('Core_External_Issue_Category__c') && sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null  && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')) == 'CC - HSDES Client Platform' ){
                                gen.writeStringField('report_type', Core_IPS_BES_CCG_CustomLogic.getReportTypeValue(sobj,field));
                                gen.writeStringField('submitter_org', Core_IPS_BES_CCG_CustomLogic.getsubmitterOrgValue(sobj,customMapping));
                                gen.writeStringField(fieldMap.get(field), String.ValueOf(sObj.get(field)));
                            }
                            //added by Tejaswini for IOT source_type custom logic
                            else if(field.equalsIgnoreCase('Core_External_Issue_Category__c') && sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null  && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('IoT')){   
                                gen.writeStringField('source_type', Core_IPS_BES_HSD_CustomLogic.getSourceType(sObj, customMapping));                             

                            } 
                            
                            else if(field.equalsIgnoreCase('Core_Case_Closure__c')){
                                if( sObj.get('Core_Case_Closure__c') != null && sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') != null  && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('DCG')){
                                  gen.writeStringField('fix_description','Issue closed via IPS');  
                                }
                                gen.writeStringField(fieldMap.get(field), String.ValueOf(sObj.get(field)));
                                
                            }
                            
                            // Added by Pavani for If transformed value exists for status and reason for DCG case in the outbound flow then include them in the JSON TWC745-5487 - 26/02/2024
                            else if(field.equalsIgnoreCase('Core_Sub_Status__c') && String.ValueOf(sObj.get(field)) == 'Investigating' && casePrevNewValues!=null && sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null  && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('DCG')){
                            	gen.writeStringField(fieldMap.get(field), String.ValueOf(sObj.get(field)));
                                newReasonValue = Core_IPS_BES_HSD_CustomLogic.processDCGStatusReasonLogic(exceptionGeneratedCase,casePrevNewValues);
                                if(String.isNotBlank(newReasonValue)){
                                    gen.writeStringField('hsd_status', 'open');
                                    // Added by Pavani for If transformed value is open.new then send default value based on the case type - 20/05/2024
                                    if(newReasonValue == 'new' && articleTypeMapping!=null ){
                                        if(sObj.get('Core_IPS_HSD_Article_Type__c')!=null && articleTypeMapping.containsKey(String.ValueOf(sObj.get('Core_IPS_HSD_Article_Type__c')))){
                                        	gen.writeStringField('hsd_reason',articleTypeMapping.get(String.ValueOf(sObj.get('Core_IPS_HSD_Article_Type__c'))).substringAfter('.'));
                                        }
                                        else{
                                            gen.writeStringField('hsd_reason',articleTypeMapping.get('defaultvalue').substringAfter('.'));
                                        }
                                    }
                                    else{
                                       gen.writeStringField('hsd_reason', newReasonValue); 
                                    }
                                    // End by Pavani - 20/05/2024
                                }
                            }// End by Pavani - TWC745-5487 - 26/02/2024
                            //Added by Tejaswini to process IOTG outbound logic
                     	    else if((field.equalsIgnoreCase('Core_Sub_Status__c') || field.equalsIgnoreCase('Status')) && sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null  && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('IoT')){                                
                               
                                if(field.equalsIgnoreCase('Status') && String.ValueOf(sObj.get('Status')) == 'Closed'){
                                    String statusNReason = Core_IPS_BES_HSD_CustomLogic.getStatusNReasonForIOT(sObj, field,customMapping.get('EMBED - HSDES IoT Platform'));
                                    if(String.isNotBlank(statusNReason)){
                                    	gen.writeStringField('iot_status', statusNReason);
                                        gen.writeStringField('iot_substatus', '');
                                    }
                                    
                                } else if(field.equalsIgnoreCase('Core_Sub_Status__c') && String.ValueOf(sObj.get('Status')) != 'Closed'){
                                    gen.writeStringField('iot_status', String.ValueOf(sObj.get('HSD_Mirror_Status__c')));
                                    gen.writeStringField('iot_substatus',String.ValueOf(sObj.get('HSD_Mirror_Reason__c')) );
                                }                              
                            }  // End by Tejaswini
                
                            
                            else{
                                gen.writeStringField(fieldMap.get(field), String.ValueOf(sObj.get(field)));
                            }
                            if(field.equalsIgnoreCase('Core_IPS_Case_URL__c')){
                                gen.writeStringField(fieldMap.get(field), Label.Core_IPS_BES_CaseInternalHyperLink.replace('{CASEID}',exceptionGeneratedCase));
                            }
                        }else{
                            gen.writeStringField(fieldMap.get(field), '');
                        } 
                        
                    }
                    for(String s: additionalInfoMap.keyset()){
                        if(s.contains('.')){
                            list<String> templistadd = new list<String>();
                            templistadd = s.split('\\.');
                            if(sObj.getsObject(templistadd[0]) != null && String.ValueOf(sObj.getsObject(templistadd[0]).get(templistadd[1]))!=null){
                                tableMap.put(additionalInfoMap.get(s).JSON_Field_Name__c, String.ValueOf(sObj.getsObject(templistadd[0]).get(templistadd[1])));
                            }
                            else{
                            	tableMap.put(additionalInfoMap.get(s).JSON_Field_Name__c, '');
                        	}
                        }else if(sObj.get(s) != null){
                            tableMap.put(additionalInfoMap.get(s).JSON_Field_Name__c, String.ValueOf(sObj.get(s)));
                        }else if(s.equalsIgnoreCase('core_Account_Name__c') && String.isBlank(String.ValueOf(sObj.get('core_Account_Name__c')))){
                            tableMap.put(additionalInfoMap.get(s).JSON_Field_Name__c, 'Intel');
                        }
                        else{
                            tableMap.put(additionalInfoMap.get(s).JSON_Field_Name__c, '');
                        }
                    }
                    caseIdTableMap.put(String.ValueOf(sObj.get('Id')), tableMap);
                    
                    //quesAnsMap = queAnsMapwithCase.get(String.valueof(sObj.get('Id')));
                    
                    if(quesAnsMap!= null && quesAnsMap.size()!=0 ){
                        for(String quest:quesAnsMap.keySet()){
                            if(quesAnsMap.get(quest)!=null){
                              
                             if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('HSDES') &&
                                   quest == Label.Core_IPS_BES_bkc_bsp_version && quesAnsMap.get(quest).length() > Integer.valueOf(Label.Core_IPS_BES_bkc_bsp_versionLimit )){
                                   gen.writeStringField(quest,quesAnsMap.get(quest).substring(0,Integer.valueOf(Label.Core_IPS_BES_bkc_bsp_versionLimit) - 1));  
                                }else if(sObj.getsObject('Core_IPS_New_Backend_System__r') != null && sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name') !=null && String.ValueOf(sObj.getsObject('Core_IPS_New_Backend_System__r').get('Name')).contains('DCG') &&
                                         quest == Label.Core_IPS_BES_bkc_sw_version && quesAnsMap.get(quest).length() > Integer.valueOf(Label.Core_IPS_BES_bkc_bsp_versionLimit )){
                                        gen.writeStringField(quest,quesAnsMap.get(quest).substring(0,Integer.valueOf(Label.Core_IPS_BES_bkc_bsp_versionLimit) - 1));   
                                         }
                                else{
                                     gen.writeStringField(quest,quesAnsMap.get(quest)); 
                                }
              
                            }
                        }
                    }
                    gen.writeStringField('upload_attach_to_ips', '<?xml version=\"1.0\" ?><dict><a href=\"'+Label.Core_BES_IPS_Upload_URL+sObj.get('Id')+Label.Core_IPS_BES_FileUploadURL+'>Upload to IPS (Public)</a></dict>');
                    formedAttachemntBody = formAttachmentBody(caseIdTableMap.get(String.valueof(sObj.get('Id'))));
                    if(sObj.get('Core_Environment_Details__c') != null){
                        formedAttachemntBody+= String.ValueOf(sObj.get('Core_Environment_Details__c'))?.replace('Question','EDQ');
                    }
                    gen.writeStringField(Label.Core_IPS_additional_information, formedAttachemntBody);
                    gen.writeEndObject();
                    
                    genMap.put(String.ValueOf(sObj.get('Id')), gen);
                    
                }
            }
        }
        catch(Exception e){
            Core_IPS_BES_LogEntry_Utility.insertLog(e, null, null, null, String.join(caseIdList,','));
        }
        return genMap;
    }
    /*********************************************
* Method Name : formAttachmentBody 
* Author : Sriranjini J N
* Date Created :  
* Description : This method is called from getJsonFromSObject, in Additional info field.This generates html body and return as string.
* Version Updates :  
************************************************/
    public static String formAttachmentBody(Map<String, String> additionalInfoMap){
        String s1;
        String formingString  ='<table>';
        String finalString ='';
        String finalTableString ='';
        for(String s: additionalInfoMap.keyset()){
           
            	s1= '<tr><td>'+s+'</td><td>'+ additionalInfoMap.get(s)+'</td></tr>';
            	finalString = finalString + s1;
        }
        finalTableString = formingString+finalString+'</table>';
        return finalTableString;
    }
    
    public static Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> prepareCustomSettingData(){
        Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapData = new Map<String,List<Core_IPS_BES_AllTenants_CustomMapping__c>>(); //15-9-23
        
        for(Core_IPS_BES_AllTenants_CustomMapping__c custMap : Core_IPS_BES_AllTenants_CustomMapping__c.getAll().values()){
                    if(custMap!=null && !customMapData.keyset().contains(custMap.Backend_System_Name__c)){
                        List<Core_IPS_BES_AllTenants_CustomMapping__c> custList = new List<Core_IPS_BES_AllTenants_CustomMapping__c>();
                        custList.add(custMap);
                    	customMapData.put(custMap.Backend_System_Name__c,custList);
                    }
                    else if(customMapData.keyset().contains(custMap.Backend_System_Name__c)){
                        List<Core_IPS_BES_AllTenants_CustomMapping__c> custListRec = customMapData.get(custMap.Backend_System_Name__c);
                        custListRec.add(custMap);
                        customMapData.put(custMap.Backend_System_Name__c,custListRec);                       
                    }
                    
        }
        return customMapData;
    }
// Ajith added this to Concatenate the Edq value
    public static boolean containsQuestionMap(string getBackendSystemName, List<Core_IPS_BES_Questions__c> customRecList, Map<String, String> quesAnsMap) {
        boolean checkCustomSettingValue = false;
        if(getBackendSystemName!=null && getBackendSystemName!='' && customRecList!=null && customRecList.size()>0 && quesAnsMap!=null){
           for(Core_IPS_BES_Questions__c customSettingValues : customRecList){
            if(getBackendSystemName.contains(customSettingValues.Backend_System_Name__c) && quesAnsMap.containsKey(customSettingValues.Environmental_Detail_Question__c)){
                checkCustomSettingValue=true;
                break;
            }
        } 
        }
        
        return checkCustomSettingValue;
    }
    // Ajith added this to Concatenate the Edq value
    public static string containsBackendSystems(Map<String, String> quesAnsMap,List<Core_IPS_BES_Questions__c> customRecList){
        string getEdqValue ;
        if(customRecList!=null && customRecList.size()>0  && quesAnsMap!=null){
        for(Core_IPS_BES_Questions__c customSettingValues : customRecList){
            if((quesAnsMap.containskey(customSettingValues.Environmental_Detail_Question__c)) && (quesAnsMap.get(customSettingValues.Environmental_Detail_Question__c)!=null)){
                 getEdqValue = String.ValueOf(quesAnsMap.get(customSettingValues.Environmental_Detail_Question__c)).replaceAll('\n','<br>');   
                }
        }
    }
        return getEdqValue;
        
    }
    
}