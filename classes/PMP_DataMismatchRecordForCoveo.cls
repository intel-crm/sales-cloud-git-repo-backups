public class PMP_DataMismatchRecordForCoveo {
    
    public static Set<Id> fetchCoveoRecords(){
       Set<Id> setOfMismatchMpiIds= new Set<Id>();
        List<PMP_Company__c> listOfMpiIds;
        Set<Id> mpiRec = new Set<Id>();
        Map<Id,String> mapOfMpiIdToMpamTier = new Map<Id,String>();
        List<PMP_Marketing_Profile_Attributes_Mapping__c> atrributeMappingList = [Select Id,Name,PMP_Partner_Tier__r.Name,PMP_Marketing_Profile_Id__r.Id,
                                                                                  PMP_Marketing_Profile_Id__r.Name, PMP_Marketing_Profile_Id__r.PMP_IPA_Badge_Tier_Txt__c,
                                                                                  PMP_Partner_Role__c,
                                                                                  PMP_Partner_Role__r.Name, PMP_Marketing_Profile_Id__r.PMP_Partner_Program_nm__c,
                                                                                  PMP_Partner_Segment__c,
                                                                                  PMP_Partner_Segment__r.Name, PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c,
                                                                                  PMP_Partner_Specialty__c,
                                                                                  PMP_Partner_Specialty__r.Name, PMP_Marketing_Profile_Id__r.PMP_Account_Specialty__c
                                                                                  From PMP_Marketing_Profile_Attributes_Mapping__c
                                                                                  where PMP_Marketing_Profile_Id__r.PMP_Company_Lifecycle_Status_Nm__c = 'Published'
                                                                                  ORDER By Name DESC];
        
        //system.debug('atrributeMappingList ' + atrributeMappingList.size() + atrributeMappingList);
        
        for(PMP_Marketing_Profile_Attributes_Mapping__c atrributeMapping :atrributeMappingList){
            mpiRec.add(atrributeMapping.PMP_Marketing_Profile_Id__c);
            
            //if Partner Tier, Partner Role, Specality, Partner Segment is null
            if(atrributeMapping.PMP_Partner_Tier__r.Name == null && atrributeMapping.PMP_Partner_Role__r.Name == null
               && atrributeMapping.PMP_Partner_Segment__r.Name == null && atrributeMapping.PMP_Partner_Specialty__r.Name == null)
              {
                setOfMismatchMpiIds.add(atrributeMapping.PMP_Marketing_Profile_Id__c);
            }
            
        }
        
        listOfMpiIds =[Select Id, Name, PMP_Partner_Program_nm__c, PMP_IPA_Badge_Tier_Txt__c from PMP_Company__c where Id In :mpiRec];
        
        //For Partner Tier
        for(PMP_Marketing_Profile_Attributes_Mapping__c partnerTierRec : atrributeMappingList){
            if(mapOfMpiIdToMpamTier.get(partnerTierRec.PMP_Marketing_Profile_Id__c) == null){
                mapOfMpiIdToMpamTier.put(partnerTierRec.PMP_Marketing_Profile_Id__c, partnerTierRec.PMP_Partner_Tier__r.Name);
            }
        }
        
        for(PMP_Company__c mpiRecord : listOfMpiIds){
            if((mpiRecord.PMP_IPA_Badge_Tier_Txt__c == null &&  mapOfMpiIdToMpamTier.get(mpiRecord.Id) != null)
               || (mpiRecord.PMP_IPA_Badge_Tier_Txt__c != null &&  mapOfMpiIdToMpamTier.get(mpiRecord.Id) == null)
               || (mpiRecord.PMP_IPA_Badge_Tier_Txt__c != mapOfMpiIdToMpamTier.get(mpiRecord.Id)))
            {
                setOfMismatchMpiIds.add(mpiRecord.Id);
            }
        }        
        
        // For Partner Role
        Map<Id,String> mapOfMpiIdToRoleMpi = new Map<Id,String>();
        Map<Id,List<String>> mapOfMpiIdToListRoleMpam = new Map<Id,List<String>>();
        Map<Id,List<String>> mapOfMpiIdToListRoleMpi = new Map<Id,List<String>>();
        
        try{ 
            for(PMP_Marketing_Profile_Attributes_Mapping__c atrributeMapping :atrributeMappingList){  
                if(mapOfMpiIdToListRoleMpam.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    if(atrributeMapping.PMP_Partner_Role__r.Name == null){
                        mapOfMpiIdToListRoleMpam.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>());
                    }
                    else{
                        mapOfMpiIdToListRoleMpam.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>{atrributeMapping.PMP_Partner_Role__r.Name});  
                    }
                }
                else if(atrributeMapping.PMP_Partner_Role__r.Name != null){
                    mapOfMpiIdToListRoleMpam.get(atrributeMapping.PMP_Marketing_Profile_Id__c).add(atrributeMapping.PMP_Partner_Role__r.Name);
                }
                
                if(mapOfMpiIdToRoleMpi.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    mapOfMpiIdToRoleMpi.put(atrributeMapping.PMP_Marketing_Profile_Id__c, atrributeMapping.PMP_Marketing_Profile_Id__r.PMP_Partner_Program_nm__c);
                    
                }
                
            }
            
            for(Id mpiId : mapOfMpiIdToRoleMpi.keySet()){
                if(mapOfMpiIdToRoleMpi.get(mpiId) == null && mapOfMpiIdToListRoleMpi.get(mpiId) == null){// if Partner Program of Mpi is null.
                    mapOfMpiIdToListRoleMpi.put(mpiId, new List<String>());
                }
                if(mapOfMpiIdToListRoleMpi.get(mpiId) == null){
                    mapOfMpiIdToListRoleMpi.put(mpiId, mapOfMpiIdToRoleMpi.get(mpiId).split(';'));
                }
            } 
            
            for(Id id : mpiRec){
                if(mapOfMpiIdToListRoleMpam.get(id).size() != mapOfMpiIdToListRoleMpi.get(id).size()){
                    setOfMismatchMpiIds.add(id);
                }
                else{   
                    for(String str : mapOfMpiIdToListRoleMpam.get(id)){
                        if(!mapOfMpiIdToRoleMpi.get(id).contains(str)){
                            setOfMismatchMpiIds.add(id);
                        }
                    }    
                }
            }                     
        }
        catch(Exception e){
            system.debug('error - ' + e.getCause() + e.getLineNumber() + e.getStackTraceString());
        }
        
        //system.debug('setOfMismatchMpiIds ' + setOfMismatchMpiIds.size() + setOfMismatchMpiIds);
        
        //For Specality    
        Map<Id,String> mapOfMpiIdToMpiSpeciality = new Map<Id,String>();
        Map<Id,List<String>> mapOfMpiIdToMpamListSpeciality = new Map<Id,List<String>>();
        Map<Id,List<String>> mapOfMpiIdToMpiListSpeciality = new Map<Id,List<String>>();
        
        try{ 
            for(PMP_Marketing_Profile_Attributes_Mapping__c atrributeMapping :atrributeMappingList){
                if(mapOfMpiIdToMpamListSpeciality.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    if(atrributeMapping.PMP_Partner_Specialty__r.Name == null){
                        mapOfMpiIdToMpamListSpeciality.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>());
                    }
                    else{
                        mapOfMpiIdToMpamListSpeciality.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>{atrributeMapping.PMP_Partner_Specialty__r.Name});  
                    }
                }
                else if(atrributeMapping.PMP_Partner_Specialty__r.Name != null){
                    mapOfMpiIdToMpamListSpeciality.get(atrributeMapping.PMP_Marketing_Profile_Id__c).add(atrributeMapping.PMP_Partner_Specialty__r.Name);
                }      
                if(mapOfMpiIdToMpiSpeciality.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    mapOfMpiIdToMpiSpeciality.put(atrributeMapping.PMP_Marketing_Profile_Id__c, atrributeMapping.PMP_Marketing_Profile_Id__r.PMP_Account_Specialty__c);         
                }  
            }  
            
            for(Id mpiId : mapOfMpiIdToMpiSpeciality.keySet()){
                if(mapOfMpiIdToMpiSpeciality.get(mpiId) == null && mapOfMpiIdToMpiListSpeciality.get(mpiId) == null){// if Specality of Mpi is null.
                    mapOfMpiIdToMpiListSpeciality.put(mpiId, new List<String>());
                }
                if(mapOfMpiIdToMpiListSpeciality.get(mpiId) == null){
                    mapOfMpiIdToMpiListSpeciality.put(mpiId, mapOfMpiIdToMpiSpeciality.get(mpiId).split(';'));
                }
            } 
            
            for(Id id : mpiRec){
                if(mapOfMpiIdToMpamListSpeciality.get(id).size() != mapOfMpiIdToMpiListSpeciality.get(id).size()){
                    setOfMismatchMpiIds.add(id);
                }
                else{    
                    for(String str : mapOfMpiIdToMpamListSpeciality.get(id)){
                        if(!mapOfMpiIdToMpiSpeciality.get(id).contains(str)){
                            setOfMismatchMpiIds.add(id);
                        }
                    }                   
                }
            }        
        }
        catch(Exception e){
            system.debug('error - ' + e.getCause() + e.getLineNumber() + e.getStackTraceString());
        }  
        //system.debug('setOfMismatchMpiIds ' + setOfMismatchMpiIds.size() + setOfMismatchMpiIds);
        
        // For Partner Segment
        Map<Id,String> mapOfMpiIdToMpiSegment = new Map<Id,String>();
        Map<Id,List<String>> mapOfMpiIdToMpamListSegment = new Map<Id,List<String>>();
        Map<Id,List<String>> mapOfMpiIdToMpiListSegment = new Map<Id,List<String>>();
        
        try{  
            for(PMP_Marketing_Profile_Attributes_Mapping__c atrributeMapping :atrributeMappingList){ 
                if(mapOfMpiIdToMpamListSegment.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    if(atrributeMapping.PMP_Partner_Segment__r.Name == null){
                        mapOfMpiIdToMpamListSegment.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>());
                    }
                    else{
                        mapOfMpiIdToMpamListSegment.put(atrributeMapping.PMP_Marketing_Profile_Id__c, new List<String>{atrributeMapping.PMP_Partner_Segment__r.Name});  
                    }
                }
                else if(atrributeMapping.PMP_Partner_Segment__r.Name != null){
                    mapOfMpiIdToMpamListSegment.get(atrributeMapping.PMP_Marketing_Profile_Id__c).add(atrributeMapping.PMP_Partner_Segment__r.Name);
                }                  
                if(mapOfMpiIdToMpiSegment.get(atrributeMapping.PMP_Marketing_Profile_Id__c) == null){
                    mapOfMpiIdToMpiSegment.put(atrributeMapping.PMP_Marketing_Profile_Id__c, atrributeMapping.PMP_Marketing_Profile_Id__r.PMP_Partner_Segment_Nm__c);        
                }          
            }           
      
            for(Id mpiId : mapOfMpiIdToMpiSegment.keySet()){
                if(mapOfMpiIdToMpiSegment.get(mpiId) == null && mapOfMpiIdToMpiListSegment.get(mpiId) == null){// if Partner Segment of Mpi is null.
                    mapOfMpiIdToMpiListSegment.put(mpiId, new List<String>());
                }
                if(mapOfMpiIdToMpiListSegment.get(mpiId) == null){
                    mapOfMpiIdToMpiListSegment.put(mpiId, mapOfMpiIdToMpiSegment.get(mpiId).split(';'));
                }
            } 
            
            for(Id id : mpiRec){
                if(mapOfMpiIdToMpamListSegment.get(id).size() != mapOfMpiIdToMpiListSegment.get(id).size()){
                    setOfMismatchMpiIds.add(id);
                }
                else{                    
                    for(String str : mapOfMpiIdToMpamListSegment.get(id)){
                        if(!mapOfMpiIdToMpiSegment.get(id).contains(str)){
                            setOfMismatchMpiIds.add(id);
                        }
                    }                   
                }
            }          
        }
        catch(Exception e){
            system.debug('error - ' + e.getCause() + e.getLineNumber() + e.getStackTraceString());
        }
      
        system.debug('setOfMismatchMpiIds ' + JSON.serializePretty(setOfMismatchMpiIds));
        
        
        return setOfMismatchMpiIds; 
        
    }
    
}