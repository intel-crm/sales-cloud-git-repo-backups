global class core_MDF_IUPGMMonitorIterableBatch implements Database.Batchable<sObject>,Database.Stateful {
    Public String csvHeader = 'Account Id, Account Name, Program Name, Role, Region';
    Public List<String> csvData = new List<String>{csvHeader};
    Public Set<String> progList = new Set<String>();
    Public String Program;
    Public Integer count = 0;

    global core_MDF_IUPGMMonitorIterableBatch(){
        List<ContentDocument> cd = [SELECT id from ContentDocument where title = 'IUPGM_Monitor.csv'];
        if(cd != null || !cd.isEmpty()){
            Database.delete(cd);
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Core_MDF_Account__c, Core_MDF_Account__r.Name, Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c FROM Core_MDF_Partner_Group_Mapping__c WHERE Core_MDF_Account__c != NULL AND Core_MDF_Channel_Program__c != NULL AND Core_MDF_Type_of_Access__c = \'External\' AND Core_MDF_Account__r.RecordType.DeveloperName  = \'Mastered_Account\' Order by Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Core_MDF_Partner_Group_Mapping__c> pgmList) {
        Set<String> accIdSet = new Set<String>();
        Set<String> roleSet = new Set<String>();
        Set<String> programSet = new Set<String>();
        Map<Id, String> accIdToNameMap = new Map<Id, String>();
        Set<Id> childAccList = new Set<Id>();
        Set<String> pgmKeySet = new Set<String>();
        Set<String> iupgmKeySet = new Set<String>();
        Map<String,Set<String>> ProgToRegionMap = new Map<String,Set<String>>();   
        Map<String, List<String>> programToPgmKeyMap = new Map<String, List<String>>();
        Map<String, List<String>> programToPgmChildKeyMap = new Map<String, List<String>>();
        
        /*if(allAccKeySet != null && allAccKeySet.isEmpty()){
            pgmKeySet.addAll(allAccKeySet);
        }*/
        for(Core_MDF_ProgramGeoRoleGroupMap__c csRec : [SELECT Id,
                                                            Core_MDF_Region_txt__c, 
                                                            Core_MDF_Program_txt__c, 
                                                            Core_MDF_Role_txt__c,
                                                            Core_MDF_All_Accounts__c,
                                                            Core_MDF_Budget_Type_txt__c,
                                                            Core_MDF_Is_Ultimate_Account_Based_Ind__c
                                                            FROM Core_MDF_ProgramGeoRoleGroupMap__c
                                                            WHERE Core_MDF_Is_Active__c = true 
                                                            AND Core_MDF_Is_For_IUPGM_Monitor_Ind__c = true]){
                                                                List<String> Region = new List<String>();
                                                                if(csRec.Core_MDF_Region_txt__c != null){
                                                                    Region = csRec.Core_MDF_Region_txt__c.split(',');
                                                                }
                                                                programSet.add(csRec.Core_MDF_Program_txt__c);
                                                                roleSet.add(csRec.Core_MDF_Role_txt__c);

                                                                String csKey = csRec.Core_MDF_Program_txt__c+';'+csRec.Core_MDF_Role_txt__c;
                                                                //prog,role
                                                                for(String geo : Region){
                                                                    String Key = csKey+';'+ geo;
                                                                    if(ProgToRegionMap.containsKey(csRec.Core_MDF_Program_txt__c)){ 
                                                                        ProgToRegionMap.get(csRec.Core_MDF_Program_txt__c).add(geo);
                                                                    }
                                                                    else{
                                                                        ProgToRegionMap.put(csRec.Core_MDF_Program_txt__c,new Set<String>{geo});
                                                                    }//program to role Map
                                                                    if(csRec.Core_MDF_Is_Ultimate_Account_Based_Ind__c == true && csRec.Core_MDF_All_Accounts__c != 'Yes'){
                                                                        if(programToPgmKeyMap.containsKey(csRec.Core_MDF_Program_txt__c)){ 
                                                                            programToPgmKeyMap.get(csRec.Core_MDF_Program_txt__c).add(Key);
                                                                        }
                                                                        else{
                                                                            programToPgmKeyMap.put(csRec.Core_MDF_Program_txt__c,new List<String>{Key});
                                                                        }//prog,role,geo
                                                                    }//for pgm query
                                                                    if(csRec.Core_MDF_Is_Ultimate_Account_Based_Ind__c == false && csRec.Core_MDF_All_Accounts__c != 'Yes'){
                                                                        if(programToPgmChildKeyMap.containsKey(csRec.Core_MDF_Program_txt__c)){ 
                                                                            programToPgmChildKeyMap.get(csRec.Core_MDF_Program_txt__c).add(Key);
                                                                        }
                                                                        else{
                                                                            programToPgmChildKeyMap.put(csRec.Core_MDF_Program_txt__c,new List<String>{Key});
                                                                        }
                                                                    }// for child query
                                                                    /*if(csRec.Core_MDF_All_Accounts__c != 'No'){
                                                                        key=Key+';'+null;
                                                                        if(!pgmKeySet.contains(key)){
                                                                            pgmKeySet.add(key);
                                                                        }  
                                                                    }*/
                                                                }
                                                            }
        
        for(Core_MDF_Partner_Group_Mapping__c pgm : pgmList){					
                                                            String prog = pgm.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c;
                                                            if(programToPgmKeyMap.containsKey(prog) && programToPgmKeyMap.get(prog) != null){
                                                                for(String key : programToPgmKeyMap.get(prog)){
                                                                    accIdSet.add(pgm.Core_MDF_Account__c);
                                                                    key = key +';'+pgm.Core_MDF_Account__c;
                                                                    //prog,role,geo,UltiAccId when allAcc is No
                                                                    if(!pgmKeySet.contains(key)){
                                                                        pgmKeySet.add(key);
                                                                    } 
                                                                }
                                                            }
                                                            if(programToPgmChildKeyMap.containsKey(prog))
                                                            {
                                                                childAccList.add(pgm.Core_MDF_Account__c);// 
                                                            }
                                                            accIdToNameMap.put(pgm.Core_MDF_Account__c, pgm.Core_MDF_Account__r.Name);
                                                        }//from pgm we will only get records which are allAcc no and UT


        for (Account acc : [SELECT Id,
                            Name,Core_MDF_CoMarketingActive__c,
                            Core_MDF_CoMarketing_Ultimate_Account__c,
                            Core_MDF_Channel_Program__r.Name 
                            FROM Account 
                            WHERE Core_MDF_Channel_Program__r.Name in: programToPgmChildKeyMap.keySet()
                            AND Core_MDF_CoMarketing_Ultimate_Account__c in: childAccList])
                            {
                                accIdToNameMap.put(acc.Id, acc.Name);
                                String prog = acc.Core_MDF_Channel_Program__r.Name;
                                if(programToPgmChildKeyMap.containsKey(prog) && programToPgmChildKeyMap.get(prog) != null){
                                    for(String key : programToPgmChildKeyMap.get(prog)){
                                        accIdSet.add(acc.Id);
                                        key = key +';'+acc.Id;
                                        if(!pgmKeySet.contains(key)){
                                            pgmKeySet.add(key);
                                        } 
                                        //prog,role,geo,ChildAccId when allAcc is No and UT No
                                    }
                                }
                            }

        if(!accIdSet.isEmpty() && !programSet.isEmpty() && !roleSet.isEmpty()){
            for(Core_MDF_Int_Users_Partner_Geo_Mapping__c iupgm : [SELECT Id, Core_MDF_Account_id__c,
                                                                    Core_MDF_Account_id__r.Name, 
                                                                    Core_MDF_Program_nm__c, 
                                                                    Core_MDF_Role_nm__c, 
                                                                    Core_MDF_Region_Sub_Region_nm__c, 
                                                                    Core_MDF_All_Accounts_cd__c
                                                                    FROM Core_MDF_Int_Users_Partner_Geo_Mapping__c 
                                                                    WHERE (Core_MDF_Account_id__c IN: accIdSet OR Core_MDF_All_Accounts_cd__c = 'Yes') 
                                                                    AND Core_MDF_Program_nm__c IN: programSet 
                                                                    AND Core_MDF_Role_nm__c IN: roleSet 
                                                                    AND Core_MDF_Active_Ind__c = true]){
                                                                        if(iupgm.Core_MDF_Region_Sub_Region_nm__c != null){
                                                                            List<String> iupgmRegionList = iupgm.Core_MDF_Region_Sub_Region_nm__c.split(';');//iupgm can contain comma seperated region
                                                                            for(String iupgmRegion : iupgmRegionList){
                                                                                if(iupgm.Core_MDF_All_Accounts_cd__c == 'No'){
                                                                                    if(iupgmRegion == 'WW' && iupgmRegion != null){
                                                                                        for(String geo : ProgToRegionMap.get(iupgm.Core_MDF_Program_nm__c)){
                                                                                            String iupgmAccProgRoleKey = iupgm.Core_MDF_Program_nm__c + ';' + iupgm.Core_MDF_Role_nm__c + ';' + geo + ';' + iupgm.Core_MDF_Account_id__c;
                                                                                            iupgmKeySet.add(iupgmAccProgRoleKey);
                                                                                        }
                                                                                    }
                                                                                    else{
                                                                                        String iupgmAccProgRoleKey = iupgm.Core_MDF_Program_nm__c + ';' + iupgm.Core_MDF_Role_nm__c + ';' + iupgmRegion + ';' + iupgm.Core_MDF_Account_id__c;
                                                                                        iupgmKeySet.add(iupgmAccProgRoleKey);
                                                                                    }
                                                                                }
                                                                                else{
                                                                                    if(iupgmRegion == 'WW' && iupgmRegion != null){
                                                                                        for(String geo : ProgToRegionMap.get(iupgm.Core_MDF_Program_nm__c)){
                                                                                            String iupgmAccProgRoleKey = iupgm.Core_MDF_Program_nm__c + ';' + iupgm.Core_MDF_Role_nm__c + ';' + geo + ';' + null;
                                                                                            iupgmKeySet.add(iupgmAccProgRoleKey);
                                                                                        }
                                                                                    }
                                                                                    else{
                                                                                        String iupgmAccProgRoleKey = iupgm.Core_MDF_Program_nm__c + ';' + iupgm.Core_MDF_Role_nm__c + ';' + iupgmRegion + ';' + null;
                                                                                        iupgmKeySet.add(iupgmAccProgRoleKey);
                                                                                    }
                                                                                }

                                                                            }
                                                                        }

                                                                    }
        }  

        pgmKeySet.removeAll(iupgmKeySet); // it will remove all the common elements
        for(String key : pgmKeySet){
            List<String> noIupgmEntries = key.split(';');
            if(noIupgmEntries != null && noIupgmEntries.size() == 4){
                if(!progList.contains(noIupgmEntries[0])){
                    progList.add(noIupgmEntries[0]);
                }
                System.debug('progList'+progList.size());
                string accName = 'null';
                if(noIupgmEntries[3] != 'null'){
                    accName = accIdToNameMap.containsKey(noIupgmEntries[3]) ? accIdToNameMap.get(noIupgmEntries[3]) : noIupgmEntries[3];
                }
                string csvValues = noIupgmEntries[3]+','+ accName + ',' + noIupgmEntries[0] + ',' + noIupgmEntries[1] + ','+ noIupgmEntries[2]; 

                if(progList.size() != 1 || count == 50000){
                    ContentVersion cv = new ContentVersion();
                    cv.Title = 'IUPGM_Monitor.csv';
                    String base64 = EncodingUtil.base64Encode(Blob.valueOf(String.join(csvData,'\n')));
                    cv.VersionData = EncodingUtil.base64Decode(base64);
                    cv.PathOnClient = 'IUPGM_Monitor.csv';
                    Database.insert(cv);
                    csvData.clear();
                    csvData.add(csvHeader);
                    progList.remove(Program);
                    count = 0;
                }
                if(progList.size() == 1){

                    if(!csvData.contains(csvValues)){
                        csvData.add(csvValues);
                        ++count;
                        Program = noIupgmEntries[0];
                    }
                    //Account Id, Account Name, Program Name, Role, Region
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for(ContentVersion cv : [SELECT id, title, VersionData from ContentVersion  where title = 'IUPGM_Monitor.csv']){
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            string csvname= cv.title;
            csvAttc.setFileName(csvname);
            csvAttc.setBody(cv.VersionData);
            attachments.add(csvAttc);
        }
        String templateName = 'Core_MDF_iupgmMonitorNotification';
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName LIMIT 1];
        List<String> emailIdList = Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IUPGMDataMonitorRecipients').Split(';');
        List<User> userList = [SELECT Id FROM user WHERE email in: emailIdList];
        for(User user : userList){
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            email.setTargetObjectId(user.Id);
            email.setTemplateId(template.Id);
            email.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            email.setSaveAsActivity(false);
            email.setFileAttachments(attachments);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}