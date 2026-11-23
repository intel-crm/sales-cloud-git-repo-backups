global without sharing class CreateFileAndAttachToRecord implements Database.Batchable<object>, Database.Stateful {
    global String finalcontentForFile;
    global string fileTitle;
    global string parentId;
    global string typeOfData;
    global List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> wrapperdata;
    global List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> wrapperdata1;
    global List<String> columnsForCSV;

    public CreateFileAndAttachToRecord(
        List<String> columnNamesCSV,
        Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>> wrapdata,
        String title,
        String parentRecId,
        String datatype
    ) {
        finalcontentForFile = '';
        fileTitle = title;
        parentId = parentRecId;
        wrapperdata = new List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>();
        for (Integer key : wrapdata.keyset()) {
            wrapperdata.addAll(wrapdata.get(key));
        }
        columnsForCSV = columnNamesCSV;
        typeOfData = datatype;
        System.debug('>>>>wrapperdata' + wrapperdata.size());
    }

    public CreateFileAndAttachToRecord(
        List<String> columnNamesCSV,
        Map<Integer, List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>> wrapdata,
        String title,
        String parentRecId,
        String datatype
    ) {
        finalcontentForFile = '';
        fileTitle = title;
        parentId = parentRecId;
        wrapperdata1 = new List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>();
        for (Integer key : wrapdata.keyset()) {
            wrapperdata1.addAll(wrapdata.get(key));
        }
        columnsForCSV = columnNamesCSV;
        typeOfData = datatype;

        System.debug('>>>>wrapperdata1' + wrapperdata1.size());
    }

    global Iterable<object> start(Database.BatchableContext BC) {
        if (wrapperdata!= null && !wrapperdata.isEmpty()) {
            return (List<Object>) wrapperdata;
        }else if(wrapperdata1!= null && !wrapperdata1.isEmpty()){
            return (List<Object>) wrapperdata1;
        }
        return null;
    }

    global void execute(
        Database.BatchableContext BC,
        List<object> lstWrapRecords
    ) {
        if (typeOfData == 'salesdata') {
            finalcontentForFile += createDataString(
                (List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails>) lstWrapRecords,
                finalcontentForFile
            );
        } else if (typeOfData == 'trainingsData') {
            finalcontentForFile += createDataString(
                (List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>) lstWrapRecords,
                finalcontentForFile
            );
        } else if (typeOfData == 'opidTrainingsData') {
            finalcontentForFile += createDataString(
                (List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails>) lstWrapRecords,
                finalcontentForFile
            );
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (!String.isEmpty(finalcontentForFile)) {
            createFile(finalcontentForFile, fileTitle, parentId);
        }
    }
    /**
    @description private method for iterating through and creating the CSV string from a list of wrappers
    */
    public String createDataString(
        List<PRM_External_Objects_Data.PRM_WrapperForSalesgDetails> csvRowList,
        String finalcontentForFile
    ) {
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        String concantenatedStr = '';
        Integer headerSize = columnsForCSV.size();
        concantenatedStr+= '<table border = 1><tr>';
        if (String.isBlank(FinalcontentForFile)) {
            for(String colhead : columnsForCSV){
                concantenatedStr += '<td>'+colhead+'</td>';
            }
        }
        concantenatedStr+= '</tr>';
        Map<String, object> objFieldMap;
        for (
            PRM_External_Objects_Data.PRM_WrapperForSalesgDetails row : csvRowList
        ) {
            objFieldMap = (Map<String, object>) JSON.deserializeUntyped(
                JSON.serialize(row)
            );
            concantenatedStr+= '<tr>';
            Integer j = 0;
            for (String objField : columnsForCSV) {
                system.debug('>>>'+objFieldMap.get(objField));
                 
                concantenatedStr += objFieldMap.get(objField) != null
                    ? '<td>'+String.valueOf(objFieldMap.get(objField))+'</td>'
                    : '';
                j++;
            }
            i++;
            concantenatedStr+= '</tr>';
        }
        concantenatedStr += '</table>';
        return concantenatedStr;
    }


    public String createDataString(
        List<PRM_External_Objects_Data.PRM_WrapperForTrainingDetails> csvRowList,
        String finalcontentForFile
    ) {
        Integer i = 0;
        Integer rowListSize = csvRowList.size();
        String concantenatedStr = '';
        Integer headerSize = columnsForCSV.size();
        concantenatedStr+= '<table border = 1><tr>';
        if (String.isBlank(FinalcontentForFile)) {
            for(String colhead : columnsForCSV){
                concantenatedStr += '<td>'+colhead+'</td>';
            }
        }
        concantenatedStr+= '</tr>';
        Map<String, object> objFieldMap;
        for (
            PRM_External_Objects_Data.PRM_WrapperForTrainingDetails row : csvRowList
        ) {
            objFieldMap = (Map<String, object>) JSON.deserializeUntyped(
                JSON.serialize(row)
            );
            concantenatedStr+= '<tr>';
            Integer j = 0;
            for (String objField : columnsForCSV) {
                system.debug('>>>'+objFieldMap.get(objField));
                 
                concantenatedStr += objFieldMap.get(objField) != null
                    ? '<td>'+String.valueOf(objFieldMap.get(objField))+'</td>'
                    : '';
                j++;
            }
            i++;
            concantenatedStr+= '</tr>';
        }
        concantenatedStr += '</table>';
        return concantenatedStr;
    }

    /**
    @description create a file
    */
    public static void createFile(
        String versionData,
        String title,
        string parentId
    ) {

        List<Network> psmNetwork = [SELECT Id FROM Network WHERE Name =: 'Intel Partner Alliance' ];
        Id networkId = psmNetwork.size() > 0 ? psmNetwork[0].Id : null;
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        system.debug('>>>'+title);
        cv.Title = title;
        cv.PathOnClient = title;
        cv.VersionData = Blob.valueOf(versionData);
        //cv.NetworkId = '0DB2i000000CaTwGAK';
        cv.NetworkId = networkId;
        insert cv;
        Id conDocument = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ]
        .ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;
        cDocLink.LinkedEntityId = parentId;
        cDocLink.ShareType = 'V';
        cDocLink.Visibility = 'AllUsers';
        insert cDocLink;

        List<ContentDistribution> cdList = new List<ContentDistribution>();

        ContentDistribution cd = new ContentDistribution();
        cd.Name = conDocument;
        cd.ContentVersionId = cv.id;
        cd.PreferencesAllowViewInBrowser = true;
        cd.PreferencesLinkLatestVersion = true;
        cd.PreferencesNotifyOnVisit = false;
        cd.PreferencesPasswordRequired = false;
        cd.PreferencesAllowOriginalDownload = true;
        cdList.add(cd);
        insert cdList;
        List<ContentDistribution> cdList1 = new List<ContentDistribution>();

        cdlist1 = [
            SELECT Id, Name, ContentDownloadUrl, ContentDocumentId
            FROM ContentDistribution
            WHERE ContentDocumentId = :conDocument
        ];

        System.debug('final link : ' + cdlist1[0].ContentDownloadUrl);
        Messaging.reserveSingleEmailCapacity(2);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> EmailidList  = new List<String>();
        EmailidList.add(UserInfo.getUserEmail());
        system.debug('EmailidList---->'+EmailidList);
        String emailBody = [select HtmlValue from EmailTemplate where DeveloperName ='Download_External_Data' limit 1].HtmlValue;
        emailBody= emailBody.replace('{!downloadLink}',cdlist1[0].ContentDownloadUrl);
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new List<String>{
            // 'piyushx.hasija@intel.com',
            'piyushxasdsad11231@mailinator.com'
        };

        mail.setToAddresses(toAddresses);
        // Specify the subject line for your email address.
        mail.setSubject('Download link for report');

        mail.setHtmlBody(
            emailBody
        );

        // Send the email you have created.
       // Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
}