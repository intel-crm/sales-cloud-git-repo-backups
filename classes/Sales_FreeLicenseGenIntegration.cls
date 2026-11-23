public without sharing class Sales_FreeLicenseGenIntegration{
    /*private static final string ORIGIN = 'Sales_SFDCOrderManagement';
    private static final string SEVERITY = 'Critical';
    private static final string PROJECT = 'PSG Sales';
    private static final String SAP_LICENSE_GENERATION_ENDPOINT = 'callout:Sales_License_Generation_Integration';
    private static final String HTTP_POST = 'POST';
    private static final String BEARER ='Bearer ';
    private static final String TEMPORARY_TYPE ='TEMPORARY';
    private static final String EMERGENCY_TYPE ='EMERGENCY';
    //private static final String DAYS_FOR_TEMPORARY_TYPE ='14';--Unused
    //private static final String DAYS_FOR_EMERGENCY_TYPE ='31';--Unused
    private static final String PRODUCTION_TYPE ='PRODUCTION';
    //private static final String EVALUATION_TYPE ='EVALUATION';--Unused
    //private static final String EMPLOYEE_TYPE = 'EMPLOYEE';--Unused
    //private static final String PARENT_HIERARCHY ='parent';--Unused
    //private static final String BUNDLE_HIERARCHY ='bundle';--Unused
    //private static final String CHILD_HIERARCHY ='child';--Unused
    private static final String SOURCE = 'PSG Licensing';
    private static final String HOSTTYPE ='NIC ID';
    //private static final String COMPONENT_TYPE_OPTION_PRODUCT = 'Component';--Unused
    //private static final String ACCESORY_TYPE_OPTION_PRODUCT = 'Accessory';--Unused
    //private static final String RELATED_PRODUCT_OPTION_PRODUCT = 'Related Product';--Unused
    private static final String BUNDLE = 'bundle';
    private static final String PARENT = 'parent';
    private static final String CHILD = 'child';
    private static final String SALES_STATUS_NEW = 'New';
    private static final String SALES_STATUS_COMPLETE = 'Complete';
    private static final String SALES_STATUS_SUBMITTED = 'Submitted';
    //private static final String SALES_STATUS_ERROR_FILE = 'Error File';--Unused
    private static final String SALES_STATUS_ERROR_SUBMISSION = 'Error Submission';
    private static final String DEF_TOKEN_ENDPOINT = 'callout:Order_SAP_Integration_Token';
    private static String accessToken;
    private static List<Sales_SAP_Token_Detail__c> connectSettingRecordList = new List<Sales_SAP_Token_Detail__c>();
    private static List<LicenseDetails> licneseDetailsRecordList = new List<LicenseDetails>();
    private static Map<Id,LicenseHeader> licenseHeaderRecordMap = new Map<Id,LicenseHeader>();
    private static String licenseList;
    private static List<LicenseHeader> licenseHeaderWrapperList = new List<LicenseHeader>();
    private static List<String> contentVersionList = new List<String>();
    private static String prodName='';
    private static Boolean throwException = false;
    private static Boolean isChatbot = false;
    private static Boolean isAutorenewal=false;
    private static String contactName='';
    private static String contactEmail='';
    public static String emailtoSend ='';
	 
    public static void setEmail(String requesterEmail,String hostInfo){
        emailtoSend = requesterEmail;
        returnHostIdDetail(hostInfo,'HostId','Event Feedback');
    }
    
    // return newly created record Details
    @AuraEnabled
    public static Sales_License__c getRecordDetails(String recordId){
        return [select Id,Sales_License_Expiration_Date_Dt__c,Sales_License_Avbl_Qty_Nbr__c,
                Sales_License_Status__c,Sales_License_Product__c,
                Sales_License_Product__r.Name   ,   Sales_License_Product__r.Core_OPN__c,Sales_License_Activation_Code__c,
                Sales_License_Web_Display_Flag__c,Sales_License_Host_Node_Id__r.Name,Sales_License_Quantity__c,
                Sales_Tool_License_Type__c, Sales_License_Primary_Admin_Contact__c
                from Sales_License__c where id =:recordId];
    }
    
    //This method will return hostId based on input - serial#/hostId
    @AuraEnabled
    public static Boolean returnHostIdDetail(String input,String inputType, String eventType ){
        List<String> eventTypeList = new List<String>();
        system.debug('eventType>>>>'+eventType);
        Boolean isOrderTrigger=false;
        Boolean isTempLicenseGen=false;
        String eventTypeOnLogtable='';
        List<Sales_License_Generation_Req_Log__c> logTableList=new List<Sales_License_Generation_Req_Log__c>();
        Map<id,Sales_License_Generation_Req_Log__c> logTableMap=new Map<id,Sales_License_Generation_Req_Log__c>();
        eventTypeList = eventType.split(',');
        System.debug('eventTypeList size>>>'+eventTypeList.size());
        if(eventTypeList.size()==3 && !eventTypeList[0].contains('autorenewal')){
            System.debug('eventTypeList>>>'+eventTypeList);
            isChatbot=true;
            System.debug('79'+isChatbot);
            if(eventTypeList[0].contains('isTempLicenseGen')){
                System.debug('Check temp license from chatbot');
                isTempLicenseGen=true;
                eventTypeOnLogtable='Temporary';
            }
        }
        else if(eventTypeList.size()==1 && eventTypeList[0].contains('autorenewal')){
            isAutorenewal=true;
            System.debug('isAutorenewal>>'+isAutorenewal);
        }
        else{
            System.debug('non chatbot');
            if(eventType=='isOrderTrigger'){
                isOrderTrigger=true;
            }
            else if(eventType=='isTempLicenseGen'){
                isTempLicenseGen=true;
                eventTypeOnLogtable='Temporary';
            }
            else if(eventType==''){
                isOrderTrigger=false;
                isTempLicenseGen=false;
                isChatbot=false;
                isAutorenewal=false;
            }
        }
        System.debug('isChatbot 101:'+isChatbot);
        Boolean throwException = false;
        String hostId='';
        System.debug('input>>>'+input);
        System.debug('inputType>>>'+inputType);
        system.debug('isTempLicenseGen>>'+isTempLicenseGen+'  isOrderTrigger>>'+isOrderTrigger);
        if(inputType=='LicenseId')  {           //if input type is activationCode then need to query on license to get hostId
            System.debug('If license activation code');
            Sales_License__c license = [Select Id,Sales_License_Host_Node_Id__c,Sales_License_Order_Product__r.Product2.Name from Sales_License__c where id =:input limit 1];
            hostId = license.Sales_License_Host_Node_Id__c;
            
        }
        else if(inputType=='HostId'){
            System.debug('If hostid');
            hostId = input;
        }
        try{            
            // Insert the log table record with status as New
            Sales_License_Generation_Req_Log__c fileTypeLogTable= new Sales_License_Generation_Req_Log__c();
            Sales_License_Generation_Req_Log__c log= new Sales_License_Generation_Req_Log__c();
            fileTypeLogTable.License_Id__c='';
            List<Sales_License_Generation_Req_Log__c> nonFileLogTable = new list<Sales_License_Generation_Req_Log__c>();
            List<Sales_License_Generation_Req_Log__c> finalLogTableList = new list<Sales_License_Generation_Req_Log__c>();
         /*   Sales_License__c licNew = [select id from Sales_License__c where Sales_License_Host_Node_Txt__c=:hostId];
            System.debug('licNewww ' +licNew);*/
            /*for(Sales_License__c lic:[select id, Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c,
                                      Sales_License_Lic_User_Contact_ID__c,Sales_License_Maintenance_Exp_Dt__c,Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c,Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c,Sales_License_Expiration_Date_Dt__c,Sales_License_Status__c,Sales_Parent_License__c,
                                      Sales_Parent_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c,Sales_License_Available_Temp_Licenses__c from Sales_License__c 
                                      where Sales_License_Host_Node_Txt__c=:hostId OR (Sales_Parent_License__c!=null AND Sales_Parent_License__r.Sales_License_Host_Node_Txt__c =: hostId)]){
                                          system.debug('license records>>'+lic);
                                          //parent license and standalone type
                                          if(lic.Sales_Parent_License__c==null){
                                              
                                              system.debug('parent license>>'+lic);
                                              //excluding licenses where main. exp is null
                                              if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c=='Standalone File' 
                                                 && lic.Sales_License_Maintenance_Exp_Dt__c!=null && (lic.Sales_License_Expiration_Date_Dt__c==null || lic.Sales_License_Expiration_Date_Dt__c>=system.today()) 
                                                 && lic.Sales_License_Status__c=='Licensed'){ 
                                                     //exclude temp lic when available qty is less than zero
                                                     system.debug('Available temp license>>'+lic.Sales_License_Available_Temp_Licenses__c);
                                                     if(isTempLicenseGen && (lic.Sales_License_Available_Temp_Licenses__c!=null && lic.Sales_License_Available_Temp_Licenses__c>0)){
                                                         system.debug('Temp licesne eligible standalone');
                                                       //  Sales_License_Generation_Req_Log__c log= new Sales_License_Generation_Req_Log__c();
                                                         log.License_Id__c=lic.id+',';
                                                         log.Sales_License_Name__c=hostId;
                                                         log.Sales_Status__c=SALES_STATUS_NEW;
                                                         log.Evevt_Type__c=eventTypeOnLogtable;
                                                         log.Sales_Host_Id__c = 'aAND30000000IOlOAM';
                                                         nonFileLogTable.add(log);
                                                         logTableMap.put(lic.id,log);
                                                     }
                                                     //non temp license
                                                     else if(!isTempLicenseGen){
                                                         system.debug('non temporary licenses standalone>>');
                                                      //   Sales_License_Generation_Req_Log__c log= new Sales_License_Generation_Req_Log__c();
                                                     /*    log.License_Id__c=lic.id+',';
                                                         log.Sales_License_Name__c=hostId;
                                                         log.Sales_Status__c=SALES_STATUS_NEW;
                                                         log.Evevt_Type__c=eventTypeOnLogtable;
                                                         log.Sales_Host_Id__c = 'aAND30000000IOlOAM';
                                                         nonFileLogTable.add(log);
                                                         System.debug('loValue ' +log);
                                                         logTableMap.put(lic.id,log);*/
                                                         /*fileTypeLogTable.License_Id__c+=lic.id+',';
                                                     }
                                                     
                                                 }
                                              //parent license (status check is licensed) and file type
                                              //excluding licenses where main. exp is null
                                              else if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c=='File' && lic.Sales_License_Maintenance_Exp_Dt__c!=null  
                                                      && (lic.Sales_License_Expiration_Date_Dt__c==null || lic.Sales_License_Expiration_Date_Dt__c>=system.today()) 
                                                      && lic.Sales_License_Status__c=='Licensed'){
                                                          system.debug('parent license file type>>'+lic);
                                                          if(isTempLicenseGen && (lic.Sales_License_Available_Temp_Licenses__c!=null && lic.Sales_License_Available_Temp_Licenses__c>0)){
                                                              system.debug('Temp licesne eligible file');
                                                              fileTypeLogTable.License_Id__c+=lic.id+',';
                                                          }
                                                          else if(!isTempLicenseGen){
                                                              system.debug('non temporary licenses file>>');
                                                              fileTypeLogTable.License_Id__c+=lic.id+',';
                                                          } 
                                                          
                                                      }
                                          }                             
                                          
                                          //optional license logic
                                          else{
                                              system.debug('optional license>>'+lic);
                                              if(logTableMap.containsKey(lic.Sales_Parent_License__c)){
                                                  system.debug('parent lic available if>>');
                                                  Sales_License_Generation_Req_Log__c logList=logTableMap.get(lic.Sales_Parent_License__c);
                                                  if(logList!=null){
                                                      logList.License_Id__c+=lic.id+',';
                                                      logTableMap.put(lic.Sales_Parent_License__c,logList);
                                                  }
                                                  
                                              }
                                              else if(lic.Sales_Parent_License__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c=='File' && lic.Sales_Parent_License__r.Sales_License_Maintenance_Exp_Dt__c!=null && (lic.Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c==null || lic.Sales_Parent_License__r.Sales_License_Expiration_Date_Dt__c>=system.today())){
                                                  fileTypeLogTable.License_Id__c+=lic.id+',';
                                              } 
                                              
                                          }  
                                          
                                      }
            system.debug('nonFileLogTable>>>'+nonFileLogTable);
            system.debug('logTableMap>>>'+logTableMap);
            if(nonFileLogTable.size()>0){
                for(Id licId:logTableMap.keySet()){
                    Sales_License_Generation_Req_Log__c logList=logTableMap.get(licId);
                    finalLogTableList.add(logList);
                }
                system.debug('finalLogTable with map>>>'+finalLogTableList);   
            }
            if(fileTypeLogTable.License_Id__c!='' && fileTypeLogTable.License_Id__c!= null){
                fileTypeLogTable.Sales_License_Name__c=hostId;
                fileTypeLogTable.Sales_Status__c=SALES_STATUS_NEW;
                fileTypeLogTable.Evevt_Type__c=eventTypeOnLogtable;
                fileTypeLogTable.Sales_Host_Id__c = 'aAND30000000IOlOAM';
                system.debug('fileTypeLogTable>>>>'+fileTypeLogTable);
                finalLogTableList.add(fileTypeLogTable);
                //insert fileTypeLogTable;
            }
            //insert log table
            system.debug('finalLogTable before insert>>>'+finalLogTableList); 
            if(finalLogTableList.size()>0){
                insert finalLogTableList;
            }
            
            system.debug('eventTypeOnLogtable>>>'+eventTypeOnLogtable);
            if(eventTypeOnLogtable==''){
                system.debug('Inside if eventTypeOnLogtable blank');
                logTableList=[select id from Sales_License_Generation_Req_Log__c where Sales_License_Name__c=:hostId and (Sales_Type__c=null and Sales_File_Ext__c=null and Evevt_Type__c!='Temporary')];
                
            }
            else if(eventTypeOnLogtable=='Temporary'){
                system.debug('Inside if eventTypeOnLogtable temp');
                logTableList=[select id from Sales_License_Generation_Req_Log__c where Sales_License_Name__c=:hostId and (Sales_Type__c=null and Sales_File_Ext__c=null and Evevt_Type__c='Temporary')];
                
            }
            system.debug('logTableList>>'+logTableList);
            for(Sales_License_Generation_Req_Log__c logNew:logTableList){ //As Mozaik team have such payload design this is done to fullfill the requirement.
                system.debug('eventTypeList>>>'+eventTypeList);
                Sales_FreeLicenseGenIntegration.submitLicenseRequest(logNew.id,isOrderTrigger,isTempLicenseGen,isChatbot,eventTypeList);
            }
            
        }
        catch(Exception e){
            Core_Log_Entry.logEntryWithException(ORIGIN, PROJECT, 'Message', SEVERITY, e.getMessage(), e.getStackTraceString(), '', '', '',e);  //To create log record for exception
        }
        return throwException;
    }
    
    //This method will generate license header details(Header Details)
    public static void generateLicenseHeaderDetails(String input, Boolean isOrderTrigger, Boolean isTempLicenseGen, Sales_License_Generation_Req_Log__c logTable, Boolean isChatbot, List<String> eventTypeList){
        system.debug('batch id header details>>>'+input);
        String licenseIds;
        String hostId;
        
        List<String> licenseIdsList=new List<String>();
        System.debug('logTableeee ' +logTable);
        //Sales_License_Generation_Req_Log__c logTable=[select id,Sales_License_Contact__c,name,Sales_Host_Id__c,License_Id__c from Sales_License_Generation_Req_Log__c where id=:input];
        if(logTable.License_Id__c!=null && logTable.Sales_Host_Id__c!=null){
            licenseIds=logTable.License_Id__c.removeEnd(',');
            hostId=logTable.Sales_License_Name__c;
        }
        System.debug('licenseIds in generateLicenseHeaderDetails >>>'+licenseIds);
        if(licenseIds!=null){
            licenseIdsList= licenseIds.split(',');
        }
        List<String> contactEmailList=new List<String>();
        if(licenseIdsList.size()>0 && eventTypeList[0].contains('autorenewal') && eventTypeList.size()==1){
            contactEmailList = returncontactforautoRenewal(licenseIdsList);
        }
        
        Id contactId;
        //system.debug('licenseIds>>>>>'+licenseIds+'hostId>>>>'+hostId);
        if(!licenseIdsList.isEmpty()){ 
            Sales_License__c hostInfo = [Select id,Sales_License_Host_Node_Id__c,Sales_License_Order__c,Sales_License_Order__r.Sales_Order_Sub_Type__c,Sales_License_Host_Node_Id__r.Temporary_NIC_ID__c,Sales_License_Lic_User_Contact_ID__r.Name,Sales_License_Lic_User_Contact_ID__r.Email,
                                         Sales_License_Host_Node_Id__r.Name,Sales_License_Host_Node_Id__r.Sales_Contact__r.Name,Sales_License_Host_Node_Id__r.Sales_Contact__r.id,
                                         Sales_License_Host_Node_Id__r.Sales_Contact__r.Email, Sales_License_Host_Node_Id__r.Sales_Computer_Type__c,Sales_License_PriAdm_Email__c, 
                                         Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c, Sales_License_Host_Node_Id__r.Sales_License_Type__c,Sales_License_Host_Node_Txt__c,
                                         Sales_License_Host_Node_Id__r.Sales_Type__c,Sales_License_Host_Node_Id__r.Sales_Redundant_Server1_Txt__c, 
                                         Sales_License_Host_Node_Id__r.Sales_Redundant_Server2_Txt__c, Sales_License_Host_Node_Id__r.Sales_Companion_Server1_Txt__c, 
                                         Sales_License_Host_Node_Id__r.Sales_Companion_Server2_Txt__c,Sales_Renewed_Description__c,Sales_License_Order_Product__r.Sales_Contact__r.Email, 
                                         Sales_License_Order_Product__r.Sales_Contact__r.Name,Sales_License_Order_Product__r.Sales_Contact__r.id, 
                                         Sales_License_Primary_Admin_Contact__r.Name,Sales_License_Primary_Admin_Contact__r.Email,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c,
                                         Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Non_Commercial_Purpose_Nm__c
                                         from Sales_License__c  where Sales_License_Host_Node_Txt__c =:hostId AND Sales_License_Status__c='Licensed' limit 1]; 
            
            System.debug('hostInfo>>>>>'+hostInfo);
            //Assigning the values to license header attributes
            LicenseHeader licenseHeaderWrapper = new LicenseHeader();
            if(!isTempLicenseGen){
                licenseHeaderWrapper.HOSTID = hostInfo.Sales_License_Host_Node_Txt__c;
                
            }
            else{
                licenseHeaderWrapper.HOSTID = hostInfo.Sales_License_Host_Node_Txt__c;
                
            }
            
            
            if(isOrderTrigger==null){
                isOrderTrigger = false;
            }
			if(logTable.Sales_Contact__c==null && logTable.Sales_Contact_Email_Address__c==null){
				
            if(!isOrderTrigger){
                System.debug('isChatbot>>>'+isChatbot);
                System.debug('isAutorenewal>>>'+isAutorenewal);
                System.debug('eventTypeList>>>'+eventTypeList);
                
                /*if(hostInfo.Sales_Renewed_Description__c!=null && hostInfo.Sales_License_Order__r.Sales_Order_Sub_Type__c!='Corporate Order'){
licenseHeaderWrapper.CONTACTID = hostInfo.Sales_License_Order_Product__r.Sales_Contact__r.Name;
licenseHeaderWrapper.CONTACTEMAIL = hostInfo.Sales_License_Order_Product__r.Sales_Contact__r.Email;

}
else */
               /* if(isChatbot && eventTypeList.size()==3){
                    System.debug('Is Chatbot');
                    System.debug('eventTypeList>>>'+eventTypeList);
                    System.debug('291'+eventTypeList[1]);
                    licenseHeaderWrapper.CONTACTID = eventTypeList[1];
                    licenseHeaderWrapper.CONTACTEMAIL = eventTypeList[2];
                }
                else if(eventTypeList[0].contains('autorenewal') && eventTypeList.size()==1 && contactEmailList.size()>0){
                    System.debug('Is autorenewed');
                    System.debug('contactEmailList>>>'+contactEmailList);
                    System.debug('311'+contactEmailList[1]);
                    licenseHeaderWrapper.CONTACTID = contactEmailList[0];
                    licenseHeaderWrapper.CONTACTEMAIL = contactEmailList[1];
                }
                else{
                    System.debug('322');
                    id userId = UserInfo.getUserId();
                    User loginUser = [Select id,email,name from User where Id = :userId and IsActive=true];
                   // licenseHeaderWrapper.CONTACTEMAIL =loginUser.email;
                    licenseHeaderWrapper.CONTACTID=loginUser.name;
                    licenseHeaderWrapper.CONTACTEMAIL =hostInfo.Sales_License_PriAdm_Email__c;
                    licenseHeaderWrapper.CONTACTID=loginUser.name;
                   //  System.debug('emailtoSendddd ' +emailtoSend);
                   //  licenseHeaderWrapper.CONTACTEMAIL = emailtoSend;
                    //contactId=hostInfo.Sales_License_Host_Node_Id__r.Sales_Contact__c;
                }
                
            }
            else{//this block will uodate only for renewal corporate Order Trigger
              //  licenseHeaderWrapper.CONTACTID = hostInfo.Sales_License_Host_Node_Id__r.Sales_Contact__r.Name; //US972949
                licenseHeaderWrapper.CONTACTEMAIL = hostInfo.Sales_License_PriAdm_Email__c; //US972949
            }
			}
			else{
				licenseHeaderWrapper.CONTACTID=logTable.Sales_Contact__c;
				licenseHeaderWrapper.CONTACTEMAIL=logTable.Sales_Contact_Email_Address__c;
			}
            contactEmail=licenseHeaderWrapper.CONTACTEMAIL;
			contactName=licenseHeaderWrapper.CONTACTID;
			
            system.debug('licenseHeaderWrapper.CONTACTEMAIL>>'+licenseHeaderWrapper.CONTACTEMAIL);
            system.debug('licenseHeaderWrapper.CONTACTID>>>>'+licenseHeaderWrapper.CONTACTID);
            //logTable.Sales_License_Contact__c=contactId;
            //update contact email
            //update logTable;
            licenseHeaderWrapper.SOURCE = SOURCE;           //PSG Licensing
            if(isTempLicenseGen){
                licenseHeaderWrapper.TYPE=TEMPORARY_TYPE;
            }
            else{
                if(hostInfo.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Enforcement_Method_Nm__c=='Standalone File' && hostInfo.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Non_Commercial_Purpose_Nm__c!=null){
                    licenseHeaderWrapper.TYPE=hostInfo.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Non_Commercial_Purpose_Nm__c.toUpperCase();
                    
                }
                else{
                    licenseHeaderWrapper.TYPE=PRODUCTION_TYPE;
                }
                
            }
            If(licenseHeaderWrapper.TYPE == TEMPORARY_TYPE){        
                licenseHeaderWrapper.HOST=hostInfo.Sales_License_Host_Node_Id__r.Sales_Computer_Type__c;        //For Temporary type, computer type of host otherwise its blank
            }
            
            licenseHeaderWrapper.HOSTTYPE = HOSTTYPE;  
            licenseHeaderWrapper.LIC_PARAMETER_DEF=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_PARAMETER_DEF').Sales_Default_Value__c;   // -a  -e  -y2  -r
            licenseHeaderWrapper.LIC_GENERATOR_DEF=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_GENERATOR_DEF').Sales_Default_Value__c;       //genlic
            licenseHeaderWrapper.LIC_SYNTAX_DEF=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_SYNTAX_DEF').Sales_Default_Value__c;     //-p
            //licenseHeaderWrapper.HOST_ID = hostInfo.Sales_License_Host_Node_Id__r.Name;             //Host Name
            //added by dnyanada as part of TWC3144#587
            if(!isTempLicenseGen){
                licenseHeaderWrapper.HOST_ID = hostInfo.Sales_License_Host_Node_Txt__c;
                
            }
            else{
                licenseHeaderWrapper.HOST_ID = hostInfo.Sales_License_Host_Node_Id__r.Temporary_NIC_ID__c;
                
            }
            licenseHeaderWrapper.HOST_NAME = hostInfo.Sales_License_Host_Node_Id__r.Sales_Computer_Name_Txt__c;
            licenseHeaderWrapper.HOST_ID2 = hostInfo.Sales_License_Host_Node_Id__r.Sales_Redundant_Server1_Txt__c;
            licenseHeaderWrapper.HOST_ID3 = hostInfo.Sales_License_Host_Node_Id__r.Sales_Redundant_Server2_Txt__c;
            licenseHeaderWrapper.HOST_TYPE = hostInfo.Sales_License_Host_Node_Id__r.Sales_Computer_Type__c;
            licenseHeaderWrapper.HOST_LIC_TYPE = hostInfo.Sales_License_Host_Node_Id__r.Sales_License_Type__c;      //License Type-Fixed/Float
            licenseHeaderWrapper.COMP_HOST_ID = hostInfo.Sales_License_Host_Node_Id__r.Sales_Companion_Server1_Txt__c;
            licenseHeaderWrapper.COMP_HOST_TYPE = '';
            licenseHeaderWrapper.COMP_HOST_ID2 = hostInfo.Sales_License_Host_Node_Id__r.Sales_Companion_Server2_Txt__c;
            if(licenseHeaderWrapper.TYPE==TEMPORARY_TYPE){  //For Temporary Type 14 days need to pass
                licenseHeaderWrapper.EMERGENCY_EXPDAYS = Sales_LicenseGen_Integration_Mapping__mdt.getInstance('TEMPORARY_TYPE').Sales_Default_Value__c;    
                licenseHeaderWrapper.TEMP_EXPDAYS = Sales_LicenseGen_Integration_Mapping__mdt.getInstance('TEMPORARY_TYPE').Sales_Default_Value__c;
            } else if(licenseHeaderWrapper.TYPE==EMERGENCY_TYPE){       //For Emergency Type 31 days need to pass
                licenseHeaderWrapper.EMERGENCY_EXPDAYS = Sales_LicenseGen_Integration_Mapping__mdt.getInstance('EMERGENCY_TYPE').Sales_Default_Value__c;
                licenseHeaderWrapper.TEMP_EXPDAYS = Sales_LicenseGen_Integration_Mapping__mdt.getInstance('EMERGENCY_TYPE').Sales_Default_Value__c;
            }
            //Sales_License_Generation_Req_Log__c logTable  = [Select Id,Name,Sales_Host_Id__r.Name from Sales_License_Generation_Req_Log__c where Sales_Host_Id__c =: hostInfo.Sales_License_Host_Node_Id__c order by CreatedDate desc LIMIT 1]; //updated to get only the latest request log request entry
            licenseHeaderWrapper.BTCH_ID = logTable.Name;
            licenseHeaderRecordMap.put(hostInfo.Sales_License_Host_Node_Id__c, licenseHeaderWrapper);       
            licenseHeaderWrapperList.add(licenseHeaderWrapper);
        }
    }
    
    //Increment logic of IP/Neutral
    public static Map<Id,String> incrementforIPNeutral(List<String> licenseIdsList){
        Map<Id,String> incrementIPMap = new Map<Id,String>();
        System.debug('licenseIdsList>>>'+licenseIdsList);
        String prodNameIPMain='';
        String prodName='';
        Boolean incrementIP=false;
        Date maintdateforIP;
        Integer seatsforIP;
        String finalIncrement;
        String licId='';
        
        For(Sales_License__c licforIP : [Select Id,Name,Sales_License_Product__r.Name,Sales_Parent_License__c,Sales_License_Quantity__c,Sales_License_Maintenance_Exp_Dt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Sales_License__c where id IN : licenseIdsList
                                         and Sales_Parent_License__c=null and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c='IP' and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c='NEUTRAL' 
                                         Order by Sales_License_Product__r.Name asc, Sales_License_Maintenance_Exp_Dt__c DESC,Sales_License_Quantity__c DESC]){
                                             while(incrementIP && !incrementIPMap.containsKey(licforIP.Id)){
                                                 if(licforIP.Sales_License_Product__r.Name==prodNameIPMain){
                                                     finalIncrement=incrementLogicforIP(licforIP.Sales_License_Maintenance_Exp_Dt__c,Integer.valueOf(licforIP.Sales_License_Quantity__c),maintdateforIP,seatsforIP);
                                                     incrementIPMap.put(licforIP.Id,finalIncrement);
                                                     licId=licforIP.Id;
                                                 }
                                                 else{
                                                     prodNameIPMain=licforIP.Sales_License_Product__r.Name;
                                                     finalIncrement=incrementLogicforIP(licforIP.Sales_License_Maintenance_Exp_Dt__c,Integer.valueOf(licforIP.Sales_License_Quantity__c),maintdateforIP,seatsforIP);
                                                     incrementIPMap.put(licforIP.Id,finalIncrement);
                                                 }
                                                 /*  if(incrementIPMap.containsKey(licforIP.Id)){
break;
}*/
                                           /*  }
                                             
                                             if(!incrementIP){
                                                 prodNameIPMain=licforIP.Sales_License_Product__r.Name;
                                                 maintdateforIP=licforIP.Sales_License_Maintenance_Exp_Dt__c;
                                                 seatsforIP=INTEGER.valueOf(licforIP.Sales_License_Quantity__c);
                                                 incrementIP=true;
                                                 finalIncrement='';
                                                 licId=licforIP.Id;
                                                 incrementIPMap.put(licforIP.Id,finalIncrement);
                                             }
                                             System.debug('incrementIPMap>>>'+incrementIPMap);
                                             System.debug('license Increment:'+licforIP.Id+':'+incrementIPMap.get(licforIP.Id));
                                         }
        return incrementIPMap;
    }
    
    //This method will generate license details for related host Id(child record details)[RUList{}]
    public static void generateLicenseDetails(String reqInput, Sales_License_Generation_Req_Log__c logTable){
        //Sales_License_Generation_Req_Log__c logTable=[select id,name,Sales_Host_Id__c,License_Id__c from Sales_License_Generation_Req_Log__c where id=:reqInput];
        Map<Id,String> incrementIPMap = new Map<Id,String>();
        
        
        String licenseIds;
        List<String> licenseIdsList= new List<String>();
        String hostId;
        system.debug('licenseIds>>>>>'+licenseIds+'hostId>>>>'+hostId);
        if(logTable.License_Id__c!=null && logTable.Sales_License_Name__c!=null){
            licenseIds=logTable.License_Id__c.removeEnd(',');
            hostId=logTable.Sales_License_Name__c;
        }
        if(licenseIds!=null){
            licenseIdsList= licenseIds.split(',');
        }
        system.debug('licenseIdsList>>>>>'+licenseIdsList);
        incrementIPMap=incrementforIPNeutral(licenseIdsList);
        Set<String> licenseDetailsSet = new Set<String>();
        Id reqId=(Id)reqInput;
        Boolean incrementBaseFloat=false;
        Boolean incrementBaseNeutral=false;
        Boolean isBundle;
        Boolean isParent;
        Boolean isChild;
        Boolean checkHierarchy=false;
        Set<Id> hostIdSet = new Set<Id>();
        String toollicensetype='';
        hostIdSet.add(reqId);
        Date maintdateforBaseFloat;
        Integer seatsforBase;
        Date maintdateforBaseNeutral;
        Integer seatsforBaseNeutral;
        Set<Id> productIdSet = new Set<Id>();
        List<String> childProductList = new List<String>();
        Map<String,String> licenseIncrementMap = new Map<String,String>();
        Map<id,List<Sales_License__c>> licenseProdMap = new Map<id,List<Sales_License__c>>();
        Set<Id> licnesesSet = new Set<Id>();
        set<String> prodNameSet= new set<string>();
        
        system.debug('reqInput generateLicenseDetails>>>>'+reqInput);
        
        If(!licenseIdsList.isEmpty()){      //Loop starts here
            //Query to get license records associated with the specific hostId
            For(Sales_License__c lic : [Select Id,Name,Sales_Parent_License__c,Sales_Parent_License__r.Sales_License_Product__c,Sales_License_Quantity__c,Sales_License_Product__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Generator_Parameter_Txt__c,Sales_Tool_License_Type__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Parameter_txt__c,Sales_License_Product__r.Name ,Sales_License_Expiration_Date_Dt__c,Sales_License_Host_Node_Id__r.Sales_License_Type__c, 
                                        Sales_License_Maintenance_Exp_Dt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Authorization_Cd__c, Sales_License_Order_Product__r.Product2Id ,Sales_License_Order_Product__r.Product2.Name,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__c,
                                        Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_File_Data_Encryption_Std_Cd__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Comment_Txt__c ,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c
                                        ,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__c,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Generator_txt__c,
                                        Sales_License_Order_Product__r.Product2.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Name,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Feature_Lyn_Syntx_txt__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Companion_Ind__c,Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c from Sales_License__c where id IN : licenseIdsList
                                        Order by Sales_License_Maintenance_Exp_Dt__c DESC,Sales_License_Quantity__c DESC]){
                                            //Order BY Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,Sales_Tool_License_Type__c,Sales_License_Product__r.Name]){
                                            LicenseDetails licenseDetailWrapper = new LicenseDetails();
                                            
                                            System.debug('License>>>'+lic);
                                            system.debug('License product>>>'+lic.Sales_License_Product__r);
                                            system.debug('License product>>>'+lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r);
                                            licnesesSet.add(lic.id);
                                            //licenseIncrementMap.put(String.valueOf(lic.id),(String.valueOf(lic.id)+String.valueOf(lic.Sales_License_Host_Node_Id__c)));  
                                            //increment logic start   
                                            System.debug('lic type>'+lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c);                                                                                 
                                            System.debug('tool type>'+lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c);  
                                            
                                            if(lic.Sales_Parent_License__c==null)
                                            {	
                                                if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='BASE' &&
                                                   lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c=='FLOAT')
                                                {
                                                    if(incrementBaseFloat)
                                                    {
                                                        licenseDetailWrapper.INCREMENT=incrementforBase(lic.Sales_License_Maintenance_Exp_Dt__c,Integer.valueOf(lic.Sales_License_Quantity__c),maintdateforBaseFloat,seatsforBase);
                                                    }
                                                    else if(!incrementBaseFloat)
                                                    {
                                                        licenseDetailWrapper.INCREMENT='';
                                                        incrementBaseFloat=true;
                                                        maintdateforBaseFloat=lic.Sales_License_Maintenance_Exp_Dt__c;
                                                        seatsforBase=Integer.valueOf(lic.Sales_License_Quantity__c);
                                                    }
                                                }
                                                else if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='BASE' &&
                                                        lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c=='NEUTRAL')
                                                {
                                                    if(incrementBaseNeutral)
                                                    {
                                                        licenseDetailWrapper.INCREMENT=incrementforBase(lic.Sales_License_Maintenance_Exp_Dt__c,Integer.valueOf(lic.Sales_License_Quantity__c),maintdateforBaseNeutral,seatsforBaseNeutral);
                                                    }
                                                    else if(!incrementBaseNeutral)
                                                    {
                                                        licenseDetailWrapper.INCREMENT='';
                                                        incrementBaseNeutral=true;
                                                        maintdateforBaseNeutral=lic.Sales_License_Maintenance_Exp_Dt__c;
                                                        seatsforBaseNeutral=Integer.valueOf(lic.Sales_License_Quantity__c);
                                                    }
                                                }
                                                else if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='IP' &&
                                                        lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c=='NEUTRAL'){
                                                            System.debug('incrementIPMap>>>'+incrementIPMap);
                                                            licenseDetailWrapper.INCREMENT= incrementIPMap.get(lic.Id);
                                                            System.debug('Increment:'+licenseDetailWrapper.INCREMENT);
                                                        }
                                                else{
                                                    licenseDetailWrapper.INCREMENT='';
                                                }
                                                
                                            }
                                            else	//for optional license Increment will be always empty string
                                            {
                                                licenseDetailWrapper.INCREMENT='';
                                            }
                                            
                                            //increment logic end
                                            if(lic.Sales_Parent_License__c==null){
                                                productIdSet.add(lic.Sales_License_Product__c);
                                            }
                                            prodNameSet.add(lic.Sales_License_Product__r.Name);
                                            ///used for child product
                                            List<Sales_License__c> tempLicenseList = new List<Sales_License__c>();
                                            if(licenseProdMap.containsKey(lic.Sales_License_Product__c)){
                                                tempLicenseList = licenseProdMap.get(lic.Sales_License_Product__c);
                                                tempLicenseList.add(lic);
                                                licenseProdMap.put(lic.Sales_License_Product__c,tempLicenseList);
                                            }
                                            else{
                                                tempLicenseList.add(lic);
                                                licenseProdMap.put(lic.Sales_License_Product__c,tempLicenseList);
                                            }
                                            
                                            system.debug('licenseProdMap>>>'+licenseProdMap);
                                            //prodName+= lic.Sales_License_Product__r.Name +' | ';
                                            
                                            //Assigning values to license details
                                            if(lic.Sales_Parent_License__c!=null){
                                                
                                                // licenseDetailWrapper.RU_ID = lic.Sales_Parent_License__r.Sales_License_Product__c;
                                                //for child RU id will be parent license id
                                                licenseDetailWrapper.RU_ID=lic.Sales_Parent_License__c;
                                                licenseDetailWrapper.HIERARCHY = CHILD;
                                                
                                            }
                                            else{   
                                                //licenseDetailWrapper.RU_ID = lic.Sales_License_Product__c;
                                                licenseDetailWrapper.RU_ID=lic.id;
                                                licenseDetailWrapper.HIERARCHY = PARENT;
                                            }
                                            licenseDetailWrapper.AUTHCODE_PROD = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Authorization_Cd__c;
                                            licenseDetailWrapper.DES_PARAM = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_File_Data_Encryption_Std_Cd__c;
                                            licenseDetailWrapper.PROD_NAME = lic.Sales_License_Product__r.Name;
                                            licenseDetailWrapper.ADDITIONAL_SWITCH = '';
                                            licenseDetailWrapper.LICENSE_COMMENT = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Comment_Txt__c;
                                            if(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__c!=null){
                                                licenseDetailWrapper.LIC_PARAMETER = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Parameter_txt__c;
                                                licenseDetailWrapper.LIC_GENERATOR = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Generator_txt__c;//generator value
                                                licenseDetailWrapper.LIC_SYNTAX = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Feature_Lyn_Syntx_txt__c;
                                            }
                                            else{
                                                licenseDetailWrapper.LIC_PARAMETER=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_PARAMETER_DEF').Sales_Default_Value__c;   // -a  -e  -y2  -r
                                                licenseDetailWrapper.LIC_GENERATOR=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_GENERATOR_DEF').Sales_Default_Value__c;       //genlic
                                                licenseDetailWrapper.LIC_SYNTAX=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_SYNTAX_DEF').Sales_Default_Value__c;     //-p
                                            }
                                            // licenseDetailWrapper.PROD_ROWID = lic.id;
                                            licenseDetailWrapper.PROD_ROWID=lic.Sales_License_Product__c;
                                            System.debug('tool type>>>'+lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c);
                                            licenseDetailWrapper.TOOL_TYPE=lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
                                            System.debug('licenseDetailWrapper.TOOL_TYPE>>'+licenseDetailWrapper.TOOL_TYPE);
                                            licenseDetailWrapper.AUTHCODE_BUNDLE = '';
                                            licenseDetailWrapper.LIC_QTY = string.valueof(lic.Sales_License_Quantity__c!=null?lic.Sales_License_Quantity__c:0);
                                            licenseDetailWrapper.SEAT = string.valueof(lic.Sales_License_Quantity__c!=null?lic.Sales_License_Quantity__c:0);
                                            licenseDetailWrapper.MAINTEXP = lic.Sales_License_Maintenance_Exp_Dt__c;
                                            
                                            //if companion flag true send Y otherwise N
                                            If(lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Companion_Ind__c == True){
                                                licenseDetailWrapper.COMPANION_FLAG = 'Y';
                                            }
                                            else{
                                                licenseDetailWrapper.COMPANION_FLAG = 'N';
                                            }
                                            
                                            licenseDetailWrapper.EXP_DATE = lic.Sales_License_Expiration_Date_Dt__c;
                                            
                                            //For Fixed type, FIXED_NODE is Y else N
                                            if(lic.Sales_License_Host_Node_Id__r.Sales_License_Type__c == 'FIXED'){
                                                licenseDetailWrapper.FIXED_NODE = 'Y';
                                            }
                                            else{
                                                licenseDetailWrapper.FIXED_NODE = 'N';
                                            }
                                            licenseDetailWrapper.webdesc = lic.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c;
                                            licneseDetailsRecordList.add(licenseDetailWrapper);
                                            if(lic.Sales_Parent_License__c==null){
                                                licenseDetailsSet.add(licenseDetailWrapper.RU_ID);
                                            }
                                        }        
            //populating unique product ids in log table fields
            system.debug('prodNameSet>>>'+prodNameSet);
            /*for(String Name:prodNameSet){
prodName+=Name+'|';

}*/
       /*     prodName = String.join(new List<String>(prodNameSet),'|');
            system.debug('prodName>>>>>'+prodName);                               
            //query to get record for increment attribute
            //query based on highest maintainance date followed by highest no of seats
            //This can be optimized
            /*For(Sales_License__c salesLicense : [Select Id,Sales_License_Host_Node_Id__c,Sales_License_Maintenance_Exp_Dt__c,Sales_Quantity__c,Sales_License_Quantity__c,
Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c 
from Sales_License__c 
where id IN : licenseIdsList and Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c  IN ('BASE','IP')  and  Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c IN ('FLOAT','NEUTRAL') 
ORDER BY Sales_License_Maintenance_Exp_Dt__c DESC,Sales_License_Quantity__c DESC]){
system.debug('licenseIncrementMap>>>>'+licenseIncrementMap);
If(licenseIncrementMap.containsKey(String.valueOf(salesLicense.id))){
increment=true;
}
}*/
            
            //Added by Srishty
         /*   for(SBQQ__ProductOption__c prodOption : [Select id,Name,SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Generator_Parameter_Txt__c,SBQQ__Type__c, SBQQ__Bundled__c, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Parameter_txt__c,
                                                     SBQQ__OptionalSKU__r.Name,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Authorization_Cd__c, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_File_Data_Encryption_Std_Cd__c, 
                                                     SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Comment_Txt__c, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__c,
                                                     SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__c,
                                                     SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Generator_txt__c, SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Feature_Lyn_Syntx_txt__c,
                                                     SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Companion_Ind__c,SBQQ__OptionalSKU__r.Core_Prod_Tool_Type_Nm__c from SBQQ__ProductOption__c
                                                     where SBQQ__ConfiguredSKU__c IN: productIdSet and SBQQ__Bundled__c =true and SBQQ__OptionalSKU__c !=null and SBQQ__Type__c ='Component' order by Name desc]){
                                                         String authBundle = prodOption.SBQQ__OptionalSKU__r.Core_Prod_Tool_Type_Nm__c == 'PACKAGE' ? getAllOptionProducts(new Set<Id>{prodOption.SBQQ__OptionalSKU__c},new List<String>()) : '';
                                                         
                                                         for(Sales_License__c license : licenseProdMap.get(prodOption.SBQQ__ConfiguredSKU__c)){
                                                             LicenseDetails licenseDetailWrapper = new LicenseDetails();
                                                             //licenseDetailWrapper.RU_ID =prodOption.SBQQ__OptionalSKU__c;
                                                             /*
if(license.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'BASE' ||
license.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c == 'IP'){
licenseDetailWrapper.INCREMENT='null';
}
else{
licenseDetailWrapper.INCREMENT='-i';
}
*/
                                                             //increment is not required for bundle
                                                             /*licenseDetailWrapper.INCREMENT='';
                                                             licenseDetailWrapper.RU_ID = license.Id;
                                                             
                                                             licenseDetailWrapper.AUTHCODE_PROD = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Authorization_Cd__c;
                                                             licenseDetailWrapper.DES_PARAM = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_File_Data_Encryption_Std_Cd__c;
                                                             licenseDetailWrapper.PROD_NAME = prodOption.SBQQ__OptionalSKU__r.Name;
                                                             licenseDetailWrapper.ADDITIONAL_SWITCH = '';
                                                             licenseDetailWrapper.LICENSE_COMMENT = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Comment_Txt__c;
                                                             system.debug('before if >>>'+prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__c);
                                                             if(prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__c!=null){
                                                                 licenseDetailWrapper.LIC_PARAMETER = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Parameter_txt__c;
                                                                 licenseDetailWrapper.LIC_GENERATOR = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Generator_txt__c;//generator value
                                                                 licenseDetailWrapper.LIC_SYNTAX = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Group_Id__r.Sales_License_Generator__r.Sales_License_Feature_Lyn_Syntx_txt__c;
                                                             }
                                                             else{
                                                                 licenseDetailWrapper.LIC_PARAMETER=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_PARAMETER_DEF').Sales_Default_Value__c;	// -a  -e  -y2  -r
                                                                 licenseDetailWrapper.LIC_GENERATOR=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_GENERATOR_DEF').Sales_Default_Value__c;		//genlic
                                                                 licenseDetailWrapper.LIC_SYNTAX=Sales_LicenseGen_Integration_Mapping__mdt.getInstance('LIC_SYNTAX_DEF').Sales_Default_Value__c;		//-p
                                                             }
                                                             licenseDetailWrapper.PROD_ROWID = prodOption.SBQQ__OptionalSKU__c;	//check how to get license id
                                                             licenseDetailWrapper.HIERARCHY = BUNDLE; //need to check with Shridhar
                                                             licenseDetailWrapper.TOOL_TYPE=prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c;
                                                             licenseDetailWrapper.AUTHCODE_BUNDLE = authBundle;
                                                             licenseDetailWrapper.LIC_QTY = string.valueof(license.Sales_License_Quantity__c!=null?license.Sales_License_Quantity__c:0);
                                                             licenseDetailWrapper.SEAT = string.valueof(license.Sales_License_Quantity__c!=null?license.Sales_License_Quantity__c:0);
                                                             licenseDetailWrapper.MAINTEXP = license.Sales_License_Maintenance_Exp_Dt__c;
                                                             licenseDetailWrapper.EXP_DATE = license.Sales_License_Expiration_Date_Dt__c;
                                                             If(prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Companion_Ind__c){
                                                                 licenseDetailWrapper.COMPANION_FLAG = 'Y';
                                                             }
                                                             else{
                                                                 licenseDetailWrapper.COMPANION_FLAG = 'N';
                                                             }
                                                             if(prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == 'FIXED' || prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Type_Nm__c == 'NEUTRAL'){
                                                                 licenseDetailWrapper.FIXED_NODE = 'Y';
                                                             }
                                                             else{
                                                                 licenseDetailWrapper.FIXED_NODE = 'N';
                                                             }
                                                             licenseDetailWrapper.webdesc = prodOption.SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Prod_Web_Dsc__c;
                                                             licneseDetailsRecordList.add(licenseDetailWrapper);
                                                             licenseDetailsSet.add(licenseDetailWrapper.RU_ID);
                                                         }
                                                     }
            
            
            List<String> licenseDetailsList = new List<String>(licenseDetailsSet);
            //making RUString as concatenated
            for(LicenseHeader licenseHeaderWrapper : licenseHeaderWrapperList){
                licenseList = String.join(licenseDetailsList, ',');
                System.debug('licenseList>>'+licenseList);
                licenseHeaderWrapper.RUString = licenseList;
            }            
        }
    }
    
    //This Method return response
    @future(callout=true)
    private static void submitLicenseRequest(String reqInput, Boolean isOrderTrigger, Boolean isTempLicenseGen, Boolean isChatbot, List<String> eventTypeList){//single input
        System.debug('@@@isOrderTrigger'+isOrderTrigger+'isTempLicenseGen>>>>'+isTempLicenseGen);
        system.debug('batch id>>'+reqInput);    
        String payLoad = generateLicenseRequestBody(reqInput,isOrderTrigger,isTempLicenseGen,isChatbot,eventTypeList);// to generate the request body for callout
        setAccessToken();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(SAP_LICENSE_GENERATION_ENDPOINT);       //endpoint
        request.setMethod(HTTP_POST);
        request.setBody(payLoad);
        request.setHeader('Authorization', BEARER + accessToken);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        request.setTimeout(120000);
        System.debug('payload generated>>>>>'+payLoad);
        HttpResponse response = http.send(request);
        if(connectSettingRecordList.size()>0){
            upsert connectSettingRecordList;
        }
        system.debug('response.getBody()>>>'+response.getBody());
        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','',response.getBody(), '', '', '');
        Sales_License_Generation_Req_Log__c logTable  = [Select Id,Name,Sales_Host_Id__c,Sales_Host_Id__r.Name,Sales_Contact_Email_Address__c,Sales_Contact__c from Sales_License_Generation_Req_Log__c where 
                                                         id =: reqInput order by CreatedDate desc LIMIT 1]; //updated to get only the latest log request entry
        logTable.Sales_Products_in_License__c =prodName;   
        System.debug('contactEmail>>>'+contactEmail);
        if(response!=null){
            System.debug('logTable.Sales_Contact_Email_Address__c>>>'+logTable.Sales_Contact_Email_Address__c);
            if(logTable.Sales_Contact_Email_Address__c==Null && logTable.Sales_Contact__c==Null ){
                System.debug('Inside If condition');
            logTable.Sales_Contact_Email_Address__c	=contactEmail;
			 logTable.Sales_Contact__c	=contactName;
            }

            if(response.getStatusCode()==200){
                /*String comment;
String status;
/*Sales_LicenseResponseWrapper deserializedResponse = (Sales_LicenseResponseWrapper) JSON.deserialize(response.getBody(), Sales_LicenseResponseWrapper.class);
System.debug('@@deserializedResponse:'+deserializedResponse);*/
                /*System.debug('@@response:'+response.getBody());
                throwException=true;
                logTable.Sales_Status__c = SALES_STATUS_SUBMITTED;
                
            }
            else{
                logTable.Sales_Status__c = SALES_STATUS_ERROR_SUBMISSION;
                throwException=false;
            }
            update logTable;
        }
        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','Generate License File log table Name:'+logTable.Name,'Generate License File - Payload:'+payLoad, logTable.Sales_Host_Id__c, '', '');  //to store request payload
        Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','Generate License File log table Name:'+logTable.Name,'Response StatusCode:'+response.getStatusCode()+' License File Submission - Response:'+response.getBody(), logTable.Sales_Host_Id__c, '', '');   //to store response
    }
    
    //this method will generate body response for license request
    public static String generateLicenseRequestBody(String reqInput, Boolean isOrderTrigger, Boolean isTempLicenseGen, Boolean isChatbot, List<String> eventTypeList){
        System.debug('reqInput>>>>>>>>'+reqInput);
        System.debug('eventTypeList>>>'+eventTypeList);
        Sales_License_Generation_Req_Log__c logTable=[select id,name,Sales_Host_Id__c,License_Id__c,Sales_Contact__c,Sales_Contact_Email_Address__c,Sales_License_Name__c from Sales_License_Generation_Req_Log__c where id=:reqInput];
        
        generateLicenseHeaderDetails(reqInput, isOrderTrigger,isTempLicenseGen,logTable,isChatbot,eventTypeList);//for setting header detail in payload
        generateLicenseDetails(reqInput,logTable);//for setting RUList detail in payload
        String strJson = '';
        LicenseHeader licenseHeaderWrapper = licenseHeaderRecordMap.values()[0];
        
        JSONGenerator payloadObj = JSON.createGenerator(false); //Create instance of JSONGenerator class
        payloadObj.writeStartObject(); //1
        payloadObj.writeFieldName('LicenceGenerator'); //insert first key of request body
        payloadObj.writeStartObject();//2
        payloadObj.writeStringField('BTCH_ID', genericStringValue(licenseHeaderWrapper.BTCH_ID));
        payloadObj.writeStringField('HOSTID', genericStringValue(licenseHeaderWrapper.HOSTID));
        payloadObj.writeStringField('CONTACTID', genericStringValue(licenseHeaderWrapper.CONTACTID));
        payloadObj.writeStringField('CONTACTEMAIL', genericStringValue(licenseHeaderWrapper.CONTACTEMAIL));
        payloadObj.writeStringField('SOURCE', genericStringValue(licenseHeaderWrapper.SOURCE));
        payloadObj.writeStringField('TYPE', genericStringValue(licenseHeaderWrapper.TYPE));
        payloadObj.writeStringField('HOST', genericStringValue(licenseHeaderWrapper.HOST));
        payloadObj.writeStringField('HOSTTYPE', genericStringValue(licenseHeaderWrapper.HOSTTYPE));
        payloadObj.writeStringField('LIC_PARAMETER_DEF', genericStringValue(licenseHeaderWrapper.LIC_PARAMETER_DEF));
        payloadObj.writeStringField('LIC_GENERATOR_DEF', genericStringValue(licenseHeaderWrapper.LIC_GENERATOR_DEF));
        payloadObj.writeStringField('LIC_SYNTAX_DEF', genericStringValue(licenseHeaderWrapper.LIC_SYNTAX_DEF));
        payloadObj.writeStringField('HOST_ID', genericStringValue(licenseHeaderWrapper.HOST_ID));
        payloadObj.writeStringField('HOST_NAME', genericStringValue(licenseHeaderWrapper.HOST_NAME));
        payloadObj.writeStringField('HOST_ID2', genericStringValue(licenseHeaderWrapper.HOST_ID2));
        payloadObj.writeStringField('HOST_ID3', genericStringValue(licenseHeaderWrapper.HOST_ID3));
        payloadObj.writeStringField('HOST_TYPE', genericStringValue(licenseHeaderWrapper.HOST_TYPE));
        payloadObj.writeStringField('HOST_LIC_TYPE', genericStringValue(licenseHeaderWrapper.HOST_LIC_TYPE));
        payloadObj.writeStringField('COMP_HOST_ID', genericStringValue(licenseHeaderWrapper.COMP_HOST_ID));
        payloadObj.writeStringField('COMP_HOST_TYPE', genericStringValue(licenseHeaderWrapper.COMP_HOST_TYPE));
        payloadObj.writeStringField('COMP_HOST_ID2', genericStringValue(licenseHeaderWrapper.COMP_HOST_ID2));
        payloadObj.writeStringField('EMERGENCY_EXPDAYS', genericStringValue(licenseHeaderWrapper.EMERGENCY_EXPDAYS));
        payloadObj.writeStringField('TEMP_EXPDAYS', genericStringValue(licenseHeaderWrapper.TEMP_EXPDAYS));
        payloadObj.writeStringField('RUString', genericStringValue(licenseList));
        payloadObj.writeFieldName('RULists'); //insert first key of request body
        payloadObj.writeStartArray();//1
        
        for(LicenseDetails licenseDetailsWrapper : licneseDetailsRecordList){
            payloadObj.writeStartObject();//3
            payloadObj.writeStringField('RU_ID', genericStringValue(licenseDetailsWrapper.RU_ID));
            payloadObj.writeStringField('HIERARCHY', genericStringValue(licenseDetailsWrapper.HIERARCHY));
            payloadObj.writeStringField('AUTHCODE_PROD', genericStringValue(licenseDetailsWrapper.AUTHCODE_PROD));
            payloadObj.writeStringField('DES_PARAM', genericStringValue(licenseDetailsWrapper.DES_PARAM));
            payloadObj.writeStringField('PROD_NAME', genericStringValue(licenseDetailsWrapper.PROD_NAME));
            payloadObj.writeStringField('ADDITIONAL_SWITCH', genericStringValue(licenseDetailsWrapper.ADDITIONAL_SWITCH));
            payloadObj.writeStringField('LICENSE_COMMENT', genericStringValue(licenseDetailsWrapper.LICENSE_COMMENT));
            payloadObj.writeStringField('LIC_PARAMETER', genericStringValue(licenseDetailsWrapper.LIC_PARAMETER));
            payloadObj.writeStringField('LIC_GENERATOR', genericStringValue(licenseDetailsWrapper.LIC_GENERATOR));
            payloadObj.writeStringField('LIC_SYNTAX', genericStringValue(licenseDetailsWrapper.LIC_SYNTAX));
            payloadObj.writeStringField('PROD_ROWID', genericStringValue(licenseDetailsWrapper.PROD_ROWID));
            payloadObj.writeStringField('TOOL_TYPE', genericStringValue(licenseDetailsWrapper.TOOL_TYPE));
            payloadObj.writeStringField('AUTHCODE_BUNDLE', genericStringValue(licenseDetailsWrapper.AUTHCODE_BUNDLE));
            payloadObj.writeStringField('LIC_QTY', licenseDetailsWrapper.LIC_QTY);
            payloadObj.writeStringField('SEAT', licenseDetailsWrapper.SEAT);
            if(licenseDetailsWrapper.MAINTEXP == null){
                payloadObj.writeNullField('MAINTEXP');
            }
            else{
                payloadObj.writeDateField('MAINTEXP', licenseDetailsWrapper.MAINTEXP);
            }
            payloadObj.writeStringField('COMPANION_FLAG', genericStringValue(licenseDetailsWrapper.COMPANION_FLAG));
            if(licenseDetailsWrapper.EXP_DATE==null){
                payloadObj.writeNullField('EXP_DATE');
            }
            else{
                payloadObj.writeDateField('EXP_DATE', licenseDetailsWrapper.EXP_DATE);
                
            }
            payloadObj.writeStringField('INCREMENT', genericStringValue(licenseDetailsWrapper.INCREMENT));
            payloadObj.writeStringField('FIXED_NODE', genericStringValue(licenseDetailsWrapper.FIXED_NODE));
            payloadObj.writeStringField('webdesc', genericStringValue(licenseDetailsWrapper.webdesc));
            payloadObj.writeEndObject();//3
        }
        payloadObj.writeEndArray();//1
        payloadObj.writeEndObject();//2
        payloadObj.writeEndObject();//1
        strJson=payloadObj.getAsString();
        System.debug('@@strJson:'+strJson);
        return strJson; // return the json string
    }
    
    //method upload .dat file in log table 
    public static String insertFileOnLicGenReqLog(String hostId,String fileName,Blob fileContent, String fileType, String productfromLicense){  
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        conVer.PathOnClient = fileName+'.dat'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = fileContent; //setting file content recived from response.
        //insert conVer;  
        //conVer.Description = productfromLicense+', File Type-'+fileType;
        Database.SaveResult saveResult = Database.insert(conVer);
        contentVersionList.add(conVer.id);
        System.debug('1st document id:'+conVer.id);
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        System.debug('2nd document id:'+conDoc);
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
       // conDocLink.LinkedEntityId = hostId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';//giving view permission
        insert conDocLink;
        System.debug('@@conDocLink'+conDocLink);
        ContentDistribution cd = new ContentDistribution();
        cd.Name = fileName;
        cd.ContentVersionId = conVer.id;
        cd.PreferencesAllowViewInBrowser= true;
        cd.PreferencesLinkLatestVersion=true;
        cd.PreferencesNotifyOnVisit=false;
        cd.PreferencesPasswordRequired=false;
        cd.PreferencesAllowOriginalDownload= true;
        insert cd;
        return conDoc;
    }
    
    //This method gets all the attributes to update from LicenseFile_Info request wrapper and updates in log table record
    public static void updateLicenseFileDetails(Sales_LicenseGenIntegration_Service.LicenseFile_Info LicenseFile_Data){ 
        List<Sales_License_Generation_Req_Log__c> licReqList = new List<Sales_License_Generation_Req_Log__c>();
        String fileName='';
        Boolean throwException=false;
        if(LicenseFile_Data!=null && LicenseFile_Data.BatchId!=null){
            Sales_License_Generation_Req_Log__c licReq = [Select Id,Sales_Host_Id__c,Sales_Host_Id__r.Name,Name,Sales_Status__c,Sales_Products_in_License__c,Sales_License_Name__c from Sales_License_Generation_Req_Log__c where Name=:LicenseFile_Data.BatchId limit 1];
            licReq.Sales_Status__c = SALES_STATUS_COMPLETE;         //update status as complete after getting license file successfully
            String productFromLicense = licReq.Sales_Products_in_License__c;
            Blob fileContent = Blob.valueOf(LicenseFile_Data.FileString);
            fileName = licReq.Sales_License_Name__c+'_License';       //FileName-->hostName+filetype+_License
            String fileType = LicenseFile_Data.FileType;
            String contentDocumentId = Sales_FreeLicenseGenIntegration.insertFileOnLicGenReqLog(licReq.Sales_License_Name__c,fileName,fileContent,fileType,productFromLicense);
            System.debug('@@3rd:'+contentDocumentId);
            ContentDistribution contentDist = [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl,ContentVersion.ContentSize from ContentDistribution where ContentDocumentId=:contentDocumentId and ContentDocumentId!=null];
            System.debug('@@4th:'+contentDist.ContentDocumentId);
            System.debug('Size>>>'+contentDist.ContentVersion.ContentSize);
            Integer Value=contentDist.ContentVersion.ContentSize;
            if (Value >= 1024 && Value < (1024*1024))
            {
                //KB
                Decimal kb = Decimal.valueOf(Value);
                kb = kb.divide(1024,2);
                licReq.Sales_File_size__c=string.valueOf(kb) + ' KB';
            }
            System.debug('@@ContentDownloadUrl:'+contentDist.ContentDownloadUrl);
            licReq.Sales_File__c = contentDist.ContentDownloadUrl;
            licReq.Sales_Content_Document_Id__c = contentDocumentId;
            licReq.Sales_File_Ext__c='dat';
            licReq.Sales_Type__c = fileType;
            licReqList.add(licReq);
            system.debug('licReqList>>>>'+licReqList);
            update licReqList;
        }
        else
        {
            Core_Log_Entry.logEntryWithDetails(ORIGIN, PROJECT,'','Info','',String.valueOf(LicenseFile_Data), '', '', '');
        }
    }
    
    //Access Token method 
    private static HttpRequest getAccessTokenRequest() {
        System.debug('Inside token request');
        String clientId = '{!$Credential.Username}';
        String clientSecret = '{!$Credential.Password}';
        String payload = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&refresh_token=' + '&grant_type=client_credentials';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(DEF_TOKEN_ENDPOINT);
        req.setMethod(HTTP_POST);
        req.setBody(payload);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept', 'application/json');
        return req;
    }
    
    private static void setAccessToken() {
        List<Sales_SAP_Token_Detail__c> connectSettingInfos = [Select Id, Name,Sales_Access_Token__c,Sales_Expires_In_Time__c,Sales_Expires_In_Seconds__c From Sales_SAP_Token_Detail__c 
                                                               Where Name ='SAP License Token Details'];
        if(connectSettingInfos != null && connectSettingInfos.size()>0 && connectSettingInfos[0].Sales_Expires_In_Time__c >= System.Now()){
            accessToken=connectSettingInfos[0].Sales_Access_Token__c;   
        }
        else{
            Sales_SAP_Token_Detail__c connectSettingRecord = new Sales_SAP_Token_Detail__c();
            String accessTokenKey = 'access_token';
            HttpResponse response = new Http().send(getAccessTokenRequest());
            if(response.getStatusCode()==200){
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(responseMap.containsKey(accessTokenKey)) {
                    accessToken = (String) responseMap.get(accessTokenKey);
                    String expiresIn=(String)responseMap.get('expires_in');
                    connectSettingRecord.Sales_Access_Token__c=accessToken;
                    connectSettingRecord.Sales_Expires_In_Seconds__c=Decimal.valueOf(expiresIn);
                    connectSettingRecord.Sales_Expires_In_Time__c=System.now().addSeconds(Integer.valueOf(expiresIn));
                    connectSettingRecord.Name ='SAP License Token Details';
                    if(connectSettingInfos!=null && connectSettingInfos.size()>0){
                        connectSettingRecord.Id=connectSettingInfos[0].Id;
                    }
                    connectSettingRecordList.clear();
                    connectSettingRecordList.add(connectSettingRecord); 
                }
            }
        }
    }
    
    //Added by Srishty to get all the option products for auth code bundle
    public static String getAllOptionProducts(Set<Id> prodIdSet, List<String> allOptionProducts){ //C1, c1   C1 has c3, C4   C3-- C5 , C6
        for(SBQQ__ProductOption__c optionProduct : [Select id,Name,SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__r.Core_Product_Ext_Attribute_Id__r.Core_SW_Lic_Authorization_Cd__c, SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where SBQQ__ConfiguredSKU__c IN :prodIdSet AND SBQQ__Bundled__c =true]){
            String authCode = optionProduct.SBQQ__OptionalSKU__r?.Core_Product_Ext_Attribute_Id__r?.Core_SW_Lic_Authorization_Cd__c;
            if(authCode!=null){
                if(authCode.toLowerCase().contains('-p')){
                    List<String> tempString = new List<String>();
                    for(String code : authCode.split('-p')){
                        allOptionProducts.add(code.trim());
                    }
                }
                else{
                    allOptionProducts.add(authCode); //C1,C3,C4  || C1,C3,C4,C5,C6
                }
            }
        }
        return String.join(allOptionProducts,','); //C1 C3 C4 C5 C6
    }
    
    //date and # of seats logic for increment of IP/NEUTRAL
    public static String incrementLogicforIP(Date maintDate,Integer seats,Date highestMaintDate,Integer highestSeats){
        String increment;
        if(maintDate>=highestMaintDate && seats>=highestSeats){
            increment='';
        }
        else{
            increment='-i';
        }
        return increment;
    }
    
    public static String incrementforBase(Date maintDate,Integer Seats,Date highestMaintDate,Integer highestSeats){
        String increment;
        if(maintDate>=highestMaintDate && Seats>=highestSeats)
        {
            if(maintDate==highestMaintDate && Seats==highestSeats)
            {
                increment='-i';
            }
            else
            {
                increment='';
            }
        }
        else
        {
            increment='-i';
        }
        return increment;
    }
    
    //generic method to convert null into blank String
    public static String genericStringValue( String o){
        try{
            if(o==null)
                return '';          //return blank string
            else
                return String.valueOf(o);
        }catch(Exception e){
            System.debug('Error Occurred - '+e.getMessage());
            return '';
        }
    }
    
    //Generic method to return the count of Licenses present in the Host record
    @AuraEnabled
    public static Integer hostRelatedLicensesCount(Id hostRecordId){
        List<Sales_License__c> relatedLicensesList = [Select (Select Id from Licenses__r) from Sales_Host__c where Id=:hostRecordId].Licenses__r;       
        System.debug('Count of Licenses Related to Host is --> '+relatedLicensesList.size());
        return relatedLicensesList.size();
    }
    
    public static List<String> returncontactforautoRenewal(List<String> licenseIdsList){
        String contactNameEmail='';
        List<String> contactList=new List<String>();
        For(Sales_License_Order_Product__c lic:[Select id,Name,Sales_Renewable_license__c,Sales_Renewable_license__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c,Sales_License__r.Sales_License_Product__c,Sales_Renewable_license__r.Sales_License_Product__c,Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Name,Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Email,Sales_Renewable_license__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c,
                                                Sales_Renewable_license__r.Name from Sales_License_Order_Product__c where Sales_License__c IN:licenseIdsList and Sales_Renewable_license__r.Sales_Renewed_Description__c !=null and Sales_Renewable_license__c!=null and Sales_Renewable_license__r.Sales_License_Status__c ='Renewals Applied' and Sales_Renewable_license__r.Sales_License_Avbl_Qty_Nbr__c = 0 and LastModifiedDate =TODAY  and CreatedDate = TODAY  order by LastModifiedDate desc,Sales_Renewable_license__r.LastModifiedDate desc]){
                                                    if(lic.Sales_Renewable_license__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='RENEWAL') {
                                                        if(lic.Sales_Renewable_license__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Foundation_Product_Id__c==lic.Sales_License__r.Sales_License_Product__c) {
                                                            contactNameEmail=lic.Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Name+','+lic.Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Email;
                                                            contactList=contactNameEmail.split(',');
                                                            System.debug('lic Name'+lic.Name);
                                                            System.debug('renewal lic'+lic.Sales_Renewable_license__c);
                                                            
                                                        }
                                                    }
                                                    else if(lic.Sales_Renewable_license__r.Sales_License_Product__r.Core_Product_Ext_Attribute_Id__r.Core_Prod_Tool_Type_Nm__c=='BASE'){
                                                        if(lic.Sales_License__r.Sales_License_Product__c==lic.Sales_Renewable_license__r.Sales_License_Product__c){
                                                            contactNameEmail=lic.Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Name+','+lic.Sales_Renewable_license__r.Sales_License_Order_Product__r.Sales_Contact__r.Email;
                                                            contactList=contactNameEmail.split(','); 
                                                            System.debug('lic Name'+lic.Name);
                                                            System.debug('renewal lic'+lic.Sales_Renewable_license__c);
                                                        }
                                                    }
                                                    if(contactNameEmail!=''){
                                                        System.debug('contactNameEmail'+contactNameEmail);
                                                        break;
                                                    }     
                                                }
        return contactList;
    }
    
    public LicenseHeader LicenseHeader;
    
    public class LicenseDetails {
        public String RU_ID;
        public String HIERARCHY;
        public String AUTHCODE_PROD;
        public String DES_PARAM;
        public String PROD_NAME;
        public String ADDITIONAL_SWITCH;
        public String LICENSE_COMMENT;
        public String LIC_PARAMETER;
        public String LIC_GENERATOR;
        public String LIC_SYNTAX;
        public String PROD_ROWID;
        public String TOOL_TYPE;
        public String AUTHCODE_BUNDLE;
        public String LIC_QTY;
        public String SEAT;
        public Date MAINTEXP;
        public String COMPANION_FLAG;
        public Date EXP_DATE;
        public String INCREMENT;
        public String FIXED_NODE;
        public String webdesc;
    }
    
    public class LicenseHeader {
        public String BTCH_ID;
        public String HOSTID;
        public String CONTACTID;
        public String CONTACTEMAIL;
        public String SOURCE;
        public String TYPE;
        public String HOST;
        public String HOSTTYPE;
        public String LIC_PARAMETER_DEF;
        public String LIC_GENERATOR_DEF;
        public String LIC_SYNTAX_DEF;
        public String HOST_ID;
        public String HOST_NAME;
        public String HOST_ID2;
        public String HOST_ID3;
        public String HOST_TYPE;
        public String HOST_LIC_TYPE;
        public String COMP_HOST_ID;
        public String COMP_HOST_TYPE;
        public String COMP_HOST_ID2;
        public String EMERGENCY_EXPDAYS;
        public String TEMP_EXPDAYS;
        public String RUString;
        public String LIC_GENERATOR;
        public String HIERARCHY;
        public List<LicenseDetails> LicenseDetails;
    }
    
    public Sales_LicenseResponseWrapper LicenseResponse;
    public class Sales_LicenseResponseWrapper {
        public String Status;
        public String Comments;
    } */
}