public class DowloadCSVDataBase64 {
    /*
    Public void readcsvFile(){
        String hexResult = EncodingUtil.convertToHex(csvFileBody);
        final Integer bytesCount = hexResult.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i){
            bytes[i] =  hexResult.mid(i << 1, 2);
        }
        csvAsString = EncodingUtil.urlDecode('%' + String.join(bytes, '%'), 'ISO-8859-1');
        csvFileLines = csvAsString.split('\n');
        inputValues = new String[]{};
            
            for(string st:csvfilelines[0].split(',')){
                fieldList.add(st); 
            }
        
        for(Integer i=1; i<csvfilelines.size(); i++){
            Account accRec = new Account() ;
            string[] csvRecordData = csvFileLines[i].split(',');
            accRec.Name = csvRecordData[0] ;             
            accRec.AccountNumber = csvRecordData[1];
            accRec.Type = csvRecordData[2];
            accRec.Industry = csvRecordData[3];                                                                               
            sObjectList.add(accRec);   
        }
    }*/
  // public String CsvString {get;set;}
    public Map<Id,List<String>> getAllImageURLMap = new Map<Id,List<String>>();
   // public List<String> urlLinkList {get;set;}
    public  String getCsvString(){
        List<Case> extractCaseList = new List<Case>();
        String generatedCSVFile ='';
        List<String> queryFields = new List<String>{'Id','caseNumber','Description Contain Image'};
            String fileRow = '';
        generatedCSVFile = generatedCSVFile + String.join(queryFields,',');
      //  urlLinkList = new List<String>();
        List<Case> queriedcaseList =[Select id,casenumber, Core_Issue_Description__c from case  limit 50]; // where id='5003F000007RMzJ'
        for(Case caseObj: queriedcaseList){
            fileRow = '\n' + (String.valueOf(caseObj.Id)).escapeCsv()+','+ (caseObj.caseNumber).escapeCsv();
            if(String.isNOTBlank(caseObj.Core_Issue_Description__c)){
                for(String str:  Core_IPS_JSON_Utility.getAllImageURL(caseObj.Core_Issue_Description__c)){
                    fileRow = fileRow +','+ str;
                }
                for(String str:  Core_IPS_JSON_Utility.getAllImageURLtoBase64(caseObj.Core_Issue_Description__c)){
                    fileRow = fileRow +','+ str;
                }
            }
            generatedCSVFile = generatedCSVFile + fileRow ;
        //    getAllImageURLMap.put(caseObj.id, Core_IPS_JSON_Utility.getAllImageURL(caseObj.Core_Issue_Description__c));
        //    urlLinkList.addAll(Core_IPS_JSON_Utility.getAllImageURL(caseObj.Core_Issue_Description__c));
        }
        
        system.debug('generatedCSVFile'+generatedCSVFile);
        Blob csvBlob = blob.valueOf(generatedCSVFile);
        return generatedCSVFile+'\n\n';
    }
    public  List<String> getUrlLinkList1(){
        List<String> urlLinkList1 = new List<String>();
        List<Case> queriedcaseList =[Select id,casenumber, Core_Issue_Description__c from case where id='5003F000007RMzJ' limit 1000]; //
        for(Case caseObj: queriedcaseList){
            urlLinkList1.addAll(Core_IPS_JSON_Utility.getAllImageURL(caseObj.Core_Issue_Description__c));
        }
        
        return urlLinkList1;
    }
    public  List<String> getUrlLinkList(){
        List<String> urlLinkList1 = new List<String>();
        List<Case> queriedcaseList =[Select id,casenumber, Core_Issue_Description__c from case where id='5003F000007RMzJ' limit 1000]; //
        for(Case caseObj: queriedcaseList){
            urlLinkList1.addAll(Core_IPS_JSON_Utility.getAllImageURLtoBase64(caseObj.Core_Issue_Description__c));
        }
        
        return urlLinkList1;
    }
}