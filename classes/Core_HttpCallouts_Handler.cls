public class Core_HttpCallouts_Handler {
    private static final String UPDATE_REASON_AGS_SYNC = 'AGS Sync'; 
    // Pass in the endpoint to be used using the string url
    public static String getUpdatedAGSStatus(Contact conRef) {
        String strAGSResponse = '';
        String strResStatus = '';
        Map<String,id> mapAGSConEntId = new Map<String,id>();
        Map<id,Core_Contact_Entitlement__c> mapidConEnt = new Map<id,Core_Contact_Entitlement__c>();
        Map<String, Object> mapAGSRes = new Map<String, Object>();
        Set<String> stAGSRoles = new Set<String>();
        List<Core_Contact_Entitlement__c> lstToUpdate = new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> lstToInset = new List<Core_Contact_Entitlement__c>();
        Set<String> stAGSToCreate = new Set<String>();
        Set<String> stAGSRolesToGetEnt = new Set<String>();
        Map<Contact,Set<String>> mapConlstAGSRoles =  new Map<Contact,Set<String>>();
        
        List<Core_Contact_Entitlement__c> lstConEnt = new List<Core_Contact_Entitlement__c>();
        
        Core_System_Credentials__c sObjRecSystemCred = Core_System_Credentials__c.getValues('Core_AGS_Get_Entitlement');
        
        if(!String.isBlank(conRef.Core_Enterprise_Id__c) && sObjRecSystemCred != null){
            
            List<String> lstEnterpriseId = new List<String>{conRef.Core_Enterprise_Id__c};
                
                lstConEnt = [SELECT id,Core_Selected__c,Core_Status__c,Core_Entitlement_Id__c,Core_Entitlement_Id__r.Core_IsActive__c,Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c FROM Core_Contact_Entitlement__c WHERE Core_Contact_Id__c = : conRef.Id AND Core_Entitlement_Id__r.Core_IsActive__c = true];
            
            system.debug('==lstEnterpriseId==>'+JSON.Serialize(lstEnterpriseId));
            
            Integer timeout=Integer.ValueOf(Label.Core_AGS_TimeOut);
            
            Http httpRef = new Http();
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint(sObjRecSystemCred.Core_End_Point_URL__c);
            req.setMethod('POST');
            System.debug('===timeout==='+timeout);
            req.setTimeout(timeout);
            
            
            String sUsername = sObjRecSystemCred.Core_UserName__c; 
            String sPassword = sObjRecSystemCred.Core_Password__c ;
            
            Blob headerValue = Blob.valueOf(sUsername+ ':' + sPassword);
            String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-type', 'application/json');
            req.setBody(JSON.Serialize(lstEnterpriseId));
            
            system.debug('==lalitha request====='+req);
            
            HttpResponse res = httpRef.send(req);
            strAGSResponse = res.getBody();
            
            
            
            System.debug('===lalitha==strAGSResponse==>'+strAGSResponse);
            
            if(!String.isBlank(strAGSResponse)){
                list<Object> objlst = (List<Object>)JSON.deserializeUntyped(strAGSResponse);
                
                system.debug('lalitha==objlst===>'+objlst);
                mapAGSRes = (Map<String, Object>)objlst[0];
                system.debug('lalitha==mapAGSRes==>'+mapAGSRes);
                List<Object> lstAGSRoles = (List<Object>)mapAGSRes.get('roles');
                
                for(Object obj : lstAGSRoles){
                    stAGSRoles.add(String.valueOf(obj)); 
                }
                system.debug('==lalitha==stAGSRoles===>'+stAGSRoles);
                for(Core_Contact_Entitlement__c conEntRef : lstConEnt){
                    Core_Contact_Entitlement__c updateConEntRef = new Core_Contact_Entitlement__c(id = conEntRef.id);
                    if(conEntRef.Core_Selected__c){
                        system.debug(conEntRef.Core_Status__c+'==lalitha==selected==='+conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c+'===='+stAGSRoles.contains(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c));
                        if((conEntRef.Core_Status__c == 'In Progress' || conEntRef.Core_Status__c == 'Pending') && stAGSRoles.contains(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c)){ 
                            updateConEntRef.Core_Status__c = 'Complete';
                            updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                            lstToUpdate.add(updateConEntRef);
                            system.debug('==lalitha==1===');
                        }else if((conEntRef.Core_Status__c == 'Complete' || String.isBlank(conEntRef.Core_Status__c)) && !stAGSRoles.contains(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c)){
                            updateConEntRef.Core_Selected__c = false;
                            if(String.isBlank(conEntRef.Core_Status__c)){
                                updateConEntRef.Core_Status__c = 'Complete';
                            }
                            updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                            lstToUpdate.add(updateConEntRef);
                            system.debug('==lalitha==2===');
                        }    
                    }else { 
                        system.debug('==lalitha==unSelected===');
                        if((conEntRef.Core_Status__c == 'In Progress' || conEntRef.Core_Status__c == 'Pending') && !stAGSRoles.contains(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c)){
                            updateConEntRef.Core_Status__c = 'Complete';
                            updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                            lstToUpdate.add(updateConEntRef); 
                            system.debug('==lalitha==3===');
                        }else if((conEntRef.Core_Status__c == 'Complete' || String.isBlank(conEntRef.Core_Status__c)) && stAGSRoles.contains(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c)){
                            updateConEntRef.Core_Selected__c = true;
                            if(String.isBlank(conEntRef.Core_Status__c)){
                                updateConEntRef.Core_Status__c = 'Complete';
                            }
                            updateConEntRef.Core_Update_Reason__c = UPDATE_REASON_AGS_SYNC;
                            lstToUpdate.add(updateConEntRef); 
                            system.debug('==lalitha==4===');
                        }
                    }
                    //To use when inserting 'core contact entitlement' that exist in AGS and record not exist under contact
                    mapAGSConEntId.put(conEntRef.Core_Entitlement_Id__r.Core_AGS_Role_Id__r.Core_Technical_Name__c,conEntRef.id);
                    //mapidConEnt.put(conEntRef.id,conEntRef);
                }
                
                for(String strRoles : stAGSRoles){
                    if(!mapAGSConEntId.containsKey(strRoles)){
                        stAGSRolesToGetEnt.add(strRoles);
                    }
                }
                if(stAGSRolesToGetEnt.size()>0){
                    mapConlstAGSRoles.put(conRef,stAGSRolesToGetEnt);
                    insertConEntByAGSRoles(mapConlstAGSRoles, UPDATE_REASON_AGS_SYNC);
                }
                
                
                if(lstToUpdate.size()>0){
                    try{
                        system.debug('==lalitha==lstToUpdate=='+lstToUpdate);
                        update lstToUpdate;
                        strResStatus = 'Updated';
                    }catch(Exception e){
                        if(String.isBlank(strResStatus)){
                            strResStatus = e.getMessage();
                        }else{
                            strResStatus = strResStatus + e.getMessage();
                        }
                    }
                }else{
                    strResStatus = 'NoRecordsToUpdate';
                }
            }else{
                strResStatus = 'NoResponse';
            }
        }
        return strResStatus;
    }
    
    public static Void insertConEntByAGSRoles(Map<Contact, Set<String>> mapConlstAGSRoles, String reason){
        Set<String> stAGSRolesToGetEnt = new Set<String>();
        Map<String,Id> mapAGSEntId = new Map<String,Id>();
        List<Core_Contact_Entitlement__c> lstToInset = new List<Core_Contact_Entitlement__c>();
        
        for(Contact conRef : mapConlstAGSRoles.keySet()){
            for(String str : mapConlstAGSRoles.get(conRef))
            {
                stAGSRolesToGetEnt.add(str);
            }
        }
        if(stAGSRolesToGetEnt.size()>0){
            List<Core_Entitlement__c> lstEnt = [SELECT id,Core_IsActive__c,Core_AGS_Role_Id__c,Core_AGS_Role_Id__r.Core_Technical_Name__c FROM Core_Entitlement__c where Core_AGS_Role_Id__r.Core_Technical_Name__c IN : stAGSRolesToGetEnt AND Core_IsActive__c = true];
            
            for(Core_Entitlement__c entRef : lstEnt){
                mapAGSEntId.put(entRef.Core_AGS_Role_Id__r.Core_Technical_Name__c,entRef.id);
            }
            
            for(Contact conRef : mapConlstAGSRoles.keySet()){  
                for(String strRef : mapConlstAGSRoles.get(conRef)){
                    if(mapAGSEntId.get(strRef) != null){
                        Core_Contact_Entitlement__c conRefNew = new Core_Contact_Entitlement__c();
                        conRefNew.Core_Entitlement_Id__c = mapAGSEntId.get(strRef);
                        conRefNew.Core_Contact_Id__c = conRef.id;
                        conRefNew.Core_Selected__c = true;
                        conRefNew.Core_Status__c = 'Complete';
                        conRefNew.Core_Update_Reason__c = reason;
                        lstToInset.add(conRefNew);
                    }
                }
            }
            if(lstToInset.size()>0){
                try{
                    insert lstToInset;
                }catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        }
        
    }
}