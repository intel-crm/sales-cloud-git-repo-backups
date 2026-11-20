/****************************************************************************************************************************************
* Class Name  : Seismic_PIMDOVSync 
* Version     : 1.0 
* Created Date: 05/15/2023  
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		Apex Test Classes for entire Seismic_PIMDOVSync Inteface 
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/
public class Seismic_PIMDOVSync Implements Schedulable{
    
    public static Boolean isTest = false; //Test Mode
    public static String syncSFDC = 'False'; //Seismic is Sync with SFDC
    public static String bearerTokenPIM ='';
    public static String seismicToken ='';
    public static List<Seismic_PIMResponseWrapper.Seismic_PIMCategory> listHierarchy = new List<Seismic_PIMResponseWrapper.Seismic_PIMCategory>();
    public static Map<String, String> config = new Map<String, String>();
    public static Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV> seismicDOVList = new Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV>();
    public static Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV> seismicDOVList2 = new Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV>();
    public static Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV> seismicDOVList3 = new Map<String, Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV>();
    public static Map<String, Seismic_DOV__c> sfdcDOVList= new Map<String, Seismic_DOV__c>();
    Public static Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem listCustomProperty = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem();
    Public static List<Seismic_DOVAction> notifyDOVs = new List<Seismic_DOVAction>();
    Public static List<Seismic_DOV__c> tmpDOVInsertList = new List<Seismic_DOV__c>();
    Public static List<Seismic_DOV__c> tmpDOVUpdateList = new List<Seismic_DOV__c>();
    Public static List<Seismic_DOV__c> tmpDOVList = new List<Seismic_DOV__c>();
    
    private static String message ='';

    /*Method to schedule the job*/
    public void execute(SchedulableContext sc)
    {
         main();
    }
    
    public static void main() {
        
        //01. Initialize
        List<Seismic_DOV__c> tempTable = [SELECT Property_Name__c FROM Seismic_DOV__c LIMIT 1];
        Seismic_PIMConfig__c mconfig = [SELECT Value__c FROM Seismic_PIMConfig__c WHERE Key__c = 'Seismic_SDFC_SYNC' LIMIT 1];
        syncSFDC =  mconfig.Value__c;
        try{
            //02. processing for the first time no record found in log.
            if(tempTable.size() <=0){
                Seismic_SFDC_BatchSync myBatchObject = new Seismic_SFDC_BatchSync();
                Database.executeBatch(myBatchObject,1);
       
            }    
            //03. Sync in last load, lets sync Seismic from PIM and Sync SFDC from Seismic.
            else if(tempTable.size() >0 && syncSFDC == 'True'){
                system.debug('start');
                
                Seismic_PIMDOV_BatchSync syncBatchObject = new Seismic_PIMDOV_BatchSync();
                Database.executeBatch(syncBatchObject,1); 
            }
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in PIMDOV Sync main', 'Error occurred in main : ' + e.getMessage());
        }
    }

    /*initialize*/
    public static Boolean initialize() {
        Boolean flg = false;
        if(config.size() == 0) {
            try{
                System.debug('initialize called');
                //List<Seismic_PIMConfig__c> tempTable = [SELECT Key__c, Value__c FROM Seismic_PIMConfig__c LIMIT 100];
                List<Seismic_PIM_Secrets__c> tempTable = [SELECT Name, Value__c FROM Seismic_PIM_Secrets__c];
                for(Seismic_PIM_Secrets__c s : tempTable)                                             
                {
                    config.put(s.Name, s.Value__c); 
                } 
               
                flg = true;
            }
            catch (Exception e) {
                Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in initialize', 'Error occurred in initialize : ' + e.getMessage());
                throw e;
            }
        }
        return flg;
    }
    
    /*Add DOVs*/
    public static void add_SeismicDOV_SFDC() {
        try{     
            Seismic_DOV__c DOVc;
            for(Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dov : listCustomProperty.domainOfValues){                                                           
                DOVc = new Seismic_DOV__c();
                DOVc.Property_Name__c = listCustomProperty.name;
                DOVc.DOV_ID__c = dov.id;
                DOVc.Name = dov.value;
                tmpDOVInsertList.add(DOVc);
            }
        }
        catch (Exception e) {
            //Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in add_SeismicDOV_SFDC', 'Error occurred in add_SeismicDOV_SFDC : ' + e.getMessage());
            //throw e;
        }
        
    }
    
    /*Update PMI IDs*/
    public static void update_PIMDOVID_SFDC(Integer propertyLevel, List<Seismic_DOV__c> tmpDOVList) {
        try{     
            generateData();
            
            String pimDOV = '';
            
            for(Seismic_DOV__c tmpDOV : tmpDOVList){
                System.debug(tmpDOV.Name);
                for(Seismic_PIMResponseWrapper.Seismic_PIMCategory hierarchyUpdate : listHierarchy){
                    if(hierarchyUpdate.intelLabel != null && hierarchyUpdate.intelLabel != '' && !hierarchyUpdate.taggingPath.containsIgnoreCase('DO NOT USE')){
                        if(hierarchyUpdate.taggingPath.countMatches('/') == propertyLevel){
                            //pimDOV = hierarchyUpdate.taggingPath.mid(hierarchyUpdate.taggingPath.lastIndexOf('/') + 1, hierarchyUpdate.taggingPath.length());
                            //pimDOV = pimDOV.replace(',','&#44;');//Formating comma
                            pimDOV = hierarchyUpdate.displayName;
                            if(pimDOV.equalsIgnoreCase(tmpDOV.Name)){
                                tmpDOV.PIM_GUID__c = hierarchyUpdate.guid; 
                            }
                        }
                    }
                }
            }
            
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in update_PIMDOVID_SFDC', 'Error occurred in update_PIMDOVID_SFDC : ' + e.getMessage());
            throw e;
        }
    }
    
    
    //Add/Update the Seismic DOVs
    public static Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyItem identifyToSync(String bearerTokenPIM, String seismicToken, Seismic_PIMActiveHierarchy__c activeHierarchy, Integer propertyLevel,String propertyLevelId) {
        String pimDOV = '';
        seismicDOVList.clear();
        seismicDOVList2.clear();
        sfdcDOVList.clear();
        Seismic_DOVAction notifyDOV;
        Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV myDOV;
        
        try{
            if(Test.isRunningTest()){
                generateData();
            }
            else{
                listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(seismicToken, propertyLevelId);
                tmpDOVList = [SELECT Property_Name__c, DOV_ID__c, Name, Date_Sync__c, PIM_GUID__c FROM Seismic_DOV__c WHERE Property_Name__c = :listCustomProperty.name];//WHERE Property_Name__c = :listCustomProperty.name
            }
            
            Seismic_DOV__c DOVc;
                        
            for(Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dov : listCustomProperty.domainOfValues){
                seismicDOVList.put(dov.value.replace('&#44;',',').tolowercase(), dov);
                seismicDOVList2.put(dov.id, dov);
            }
            
            for(Seismic_DOV__c tmpDOV : tmpDOVList)  {
                sfdcDOVList.put(tmpDOV.PIM_GUID__c, tmpDOV);
            }
            
            //ADD : Iterate through PIM Hierarchy List to determin new dovs to add
            //********************************************************************
            for(Seismic_PIMResponseWrapper.Seismic_PIMCategory hierarchy : listHierarchy){
                if(hierarchy.intelLabel != null && hierarchy.intelLabel != '' && !hierarchy.taggingPath.containsIgnoreCase('DO NOT USE')){
                    //L1 - example taggingPath='EMT_Audience/Consumer';
                    if(hierarchy.taggingPath.countMatches('/') == propertyLevel){
                        //pimDOV = hierarchy.taggingPath.mid(hierarchy.taggingPath.lastIndexOf('/') + 1, hierarchy.taggingPath.length());
                        //pimDOV = hierarchy.displayName.replace(',','&#44;');//Formating comma
                        pimDOV = hierarchy.displayName;
                        
                        //NEW DOV  - DOV Doesn't exist in Seismic and SFDC.
                        if(!seismicDOVList.containsKey(pimDOV.tolowercase()) && !seismicDOVList3.containsKey(pimDOV) && !sfdcDOVList.containsKey(hierarchy.guid) && !pimDOV.containsIgnoreCase('DO NOT USE')){
                            
                            myDOV = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV();
                            //myDOV.id=hierarchy.guid;
                            myDOV.value = pimDOV;
                            myDOV.order = listCustomProperty.domainOfValues.size()+1;
                            listCustomProperty.domainOfValues.add(myDOV);
                            seismicDOVList3.put(pimDOV, myDOV);//make sure not duplicates
                            
                            notifyDOV = new Seismic_DOVAction();
                            notifyDOV.propertyName = listCustomProperty.name;
                            notifyDOV.dovName = pimDOV;
                            notifyDOV.action = 'ADDED';
                            notifyDOVs.add(notifyDOV);
                            System.debug(notifyDOV);
                        }
                        //UPDATE DOV
                        else if(sfdcDOVList.containsKey(hierarchy.guid) && !seismicDOVList.containsKey(pimDOV.tolowercase()) &&  !pimDOV.containsIgnoreCase('DO NOT USE')){
                            Seismic_DOV__c sfdcDOV = sfdcDOVList.get(hierarchy.guid);
                            String value_to_update = '';
                            if(sfdcDOV!= null){
                                Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV seismicDOV = seismicDOVList2.get(sfdcDOV.DOV_ID__c);
                                if(seismicDOV!= null){
                                    value_to_update = '';
                                    for (Integer ii = (listCustomProperty.domainOfValues.size()-1) ; ii>= 0 ; ii--){
                                        if(listCustomProperty.domainOfValues.get(ii).id.equals(seismicDOV.id) && !seismicDOV.value.equals(pimDOV)){
                                            value_to_update = listCustomProperty.domainOfValues.get(ii).value;
                                            listCustomProperty.domainOfValues.get(ii).value = pimDOV;
                                            //seismicDOVList3.put(pimDOV, myDOV);//make sure not duplicates
                                            break;
                                        }
                                    } 
                                    if(!value_to_update.equals('')){
                                        notifyDOV = new Seismic_DOVAction();
                                        notifyDOV.propertyName = listCustomProperty.name;
                                        notifyDOV.dovName = 'OLD: "' + value_to_update +'" NEW:"'+ pimDOV +'"';
                                        notifyDOV.action = 'UPDATED';
                                        notifyDOVs.add(notifyDOV);
                                        value_to_update = '';
                                        System.debug(notifyDOV);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            
            //DELETE : Iterate through Seismic DOV List to determin dovs to remove which doesn't exist in PIM
            //************************************************************************************************
            seismicDOVList.clear();
            pimDOV = '';
            for(Seismic_PIMResponseWrapper.Seismic_PIMCategory hierarchyDEL : listHierarchy){
                if(hierarchyDEL.intelLabel != null && hierarchyDEL.intelLabel != '' && !hierarchyDEL.taggingPath.containsIgnoreCase('DO NOT USE')){
                    if(hierarchyDEL.taggingPath.countMatches('/') == propertyLevel){
                        //pimDOV = hierarchyDEL.taggingPath.mid(hierarchyDEL.taggingPath.lastIndexOf('/') + 1, hierarchyDEL.taggingPath.length());
                        //pimDOV = hierarchyDEL.displayName.replace('&#44;',',');//Formating comma
                        pimDOV = hierarchyDEL.displayName;
                        seismicDOVList.put(pimDOV.tolowercase(), null);
                    }
                }
            }
            //If PIM List is not empty, check if anythig to remove
            if(seismicDOVList.size() >0){
                for (Integer i = (listCustomProperty.domainOfValues.size()-1) ; i>= 0 ; i--){
                    Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dov = listCustomProperty.domainOfValues[i];
                    if(!seismicDOVList.containsKey(dov.value.replace('&#44;',',').tolowercase())){
                        notifyDOV = new Seismic_DOVAction();
                        notifyDOV.propertyName = listCustomProperty.name;
                        notifyDOV.dovName = dov.value;
                        notifyDOV.action = 'DELETED';
                        notifyDOVs.add(notifyDOV);
                        System.debug(notifyDOV);
                        listCustomProperty.domainOfValues.remove(i);
                    }
                } 
            }
            
        }
        catch (Exception e) {
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in identifyToSync', 'Error occurred in identifyToSync : ' + e.getMessage());
            throw e;
        }
        
        return listCustomProperty;
    }

     public class Seismic_DOVAction {
        @TestVisible public String propertyName {get; private set;}  //
        @TestVisible public String dovName {get; private set;}  //
        @TestVisible public String action {get; private set;}  //
    }
    
    /*Test data generator*/
    private static void generateData(){
         if(Test.isRunningTest()){
                Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dvd = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV();
                dvd.id = '';
                dvd.value = '';
                dvd.order = 0;
                
                Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV dvd2 = new Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV();
                dvd2.id = 'fb317790-19ed-5699-959b-740907a4d419';
                dvd2.value = 'AMD';
                dvd2.order = 1;
                
                List<Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV> dvs = new List<Seismic_CustomPropertiesResponseWrapper.Seismic_CustomPropertyDOV>();
                dvs.add(dvd);
                dvs.add(dvd2);
                listCustomProperty.domainOfValues = dvs;
                listCustomProperty.name = 'Competitor Products';
                
                Seismic_DOV__c dv = new Seismic_DOV__c(DOV_ID__c = 'fb317790-19ed-5699-959b-740907a4d419', Name = 'Desktop', PIM_GUID__c = 'etm-e4f6d07a61b045aa91e68d3342315746', Property_Name__c = 'Competitor Products L1');
                tmpDOVList = new List<Seismic_DOV__c>();
                tmpDOVList.add(dv);
                
                Seismic_PIMResponseWrapper.Seismic_PIMCategory cat2 = new Seismic_PIMResponseWrapper.Seismic_PIMCategory();
                cat2.displayName = 'DesktopX';
                cat2.guid = 'etm-e4f6d07a61b045aa91e68d3342315746';
                cat2.intelLabel = 'DesktopX';
                cat2.taggingPath = 'DAM Competition Products/DesktopX';
                Seismic_PIMDOVSync.listHierarchy.add(cat2);
                
            }
    }
}