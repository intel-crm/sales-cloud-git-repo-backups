public class PSG_MigrationFuture {
    @future(callout=true)
    public static void bulkSAPRequestFuture() {
        Map<String,List<String>> preobjToPLVMap=new Map<String,List<String>>{
            'SBQQ__Quote__c.PSG_Quote_New.core_cpq_quote_type_nm__c' => new List<String>{'Design Win','Budgetary','Tools','Transfer Pricing','CM Buy','Transfer','Contract Admin','CM Bid','Price Request','Contract Pricing'},
            'SBQQ__Quote__c.PSG_Quote_Submitted.core_cpq_quote_type_nm__c' => new List<String>{'Design Win','Budgetary','Tools','Transfer Pricing','CM Buy','Transfer','Contract Admin','CM Bid','Price Request','Contract Pricing'},
            'core_cpq_dpa_aln__c.PSG_ALN.core_cpq_aln_type__c' => new List<String>{'Time Based','Lmt Qty'},
            'core_cpq_dpa_aln__c.PSG_ALN.core_cpq_status_txt__c' => new List<String>{'Approved','Replaced','Hold','Request','Rejected','New','Expired','Extended'},
            'core_cpq_dpa_aln__c.PSG_DPA.core_cpq_status_txt__c' => new List<String>{'Approved','Replaced','Hold','Request','Rejected','New','Expired','Extended'},
            'core_cpq_dpa_aln_line__c.PSG_DPA_Lines.core_cpq_margin_program__c' => new List<String>{'Middle','Protected'},
            'core_cpq_dpa_aln_line__c.PSG_ALN_Lines.core_cpq_margin_program__c' => new List<String>{'Middle','Protected'}
            
        };
            Map<String,List<String>> postobjToPLVMap=new Map<String,List<String>>{
                'SBQQ__Quote__c.PSG_Quote_New.core_cpq_quote_type_nm__c' => new List<String>{'Design Win','Budgetary','Tools','Transfer Pricing'},
                'SBQQ__Quote__c.PSG_Quote_Submitted.core_cpq_quote_type_nm__c' => new List<String>{'Design Win','Budgetary','Tools','Transfer Pricing'},
                'core_cpq_dpa_aln__c.PSG_ALN.core_cpq_aln_type__c' => new List<String>{'Time Based','Lmt Qty'},
                'core_cpq_dpa_aln__c.PSG_ALN.core_cpq_status_txt__c' => new List<String>{'Approved','Replaced','Hold','Request','Rejected','New','Expired','Extended'},
                'core_cpq_dpa_aln__c.PSG_DPA.core_cpq_status_txt__c' => new List<String>{'Approved','Replaced','Hold','Request','Rejected','New','Expired','Extended'},
                'core_cpq_dpa_aln_line__c.PSG_DPA_Lines.core_cpq_margin_program__c' => new List<String>{'Middle','Protected','Standard'},
                'core_cpq_dpa_aln_line__c.PSG_ALN_Lines.core_cpq_margin_program__c' => new List<String>{'Middle','Protected','Standard'}
                
            };
                Map<String,String> rtAPIToLabelMap=new Map<String,String>{
                    'SBQQ__Quote__c.PSG_Quote_New' => 'PSG Quote - New',
                    'SBQQ__Quote__c.PSG_Quote_Submitted'  => 'PSG Quote - Submitted',
                        //'core_cpq_dpa_aln__c.PSG_ALN' => 'PSG ALN',
                        //'core_cpq_dpa_aln__c.PSG_ALN' => 'PSG ALN',
                        //'core_cpq_dpa_aln__c.PSG_DPA' => 'PSG DPA'
                        'core_cpq_dpa_aln_line__c.PSG_DPA_Lines' => 'PSG DPA Lines',
                        'core_cpq_dpa_aln_line__c.PSG_ALN_Lines' => 'PSG ALN Lines'
                        
                        };
                            Boolean ChangeFlag=true;
        
        Map<String,List<String>> objToPLVMap=new Map<String,List<String>>();
        if(ChangeFlag)
        {  
            objToPLVMap=postobjToPLVMap;
        }
        else
        {
            objToPLVMap=preobjToPLVMap;
            
        }	
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();   
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        List<MetadataService.RecordType> rtList = new List<MetadataService.RecordType>();
        
        for(String key : objToPLVMap.keySet()){
            List<String> values=key.split('\\.');
            String objAPIName=values[0];
            String rtAPIName=values[1];
            String fieldAPIName=values[2];
            List<String> pkValues=objToPLVMap.get(key);
            MetadataService.RecordType rt = new MetadataService.RecordType();
            rt.active = true;
            rt.fullName = objAPIName+'.'+rtAPIName;
            rt.label = rtAPIToLabelMap.get(objAPIName+'.'+rtAPIName);
            MetadataService.RecordTypePicklistValue rtPKLList = new MetadataService.RecordTypePicklistValue();
            List<MetadataService.PicklistValue> pickListValues=new List<MetadataService.PicklistValue>();
            for(String value:pkValues){
                MetadataService.PicklistValue plv = new MetadataService.PicklistValue();
                plv.fullName= value;
                plv.default_x=false;
                pickListValues.add(plv);
            }
            rtPKLList.Picklist = fieldAPIName;
            rtPKLList.values = pickListValues;
            rt.PicklistValues = new MetadataService.RecordTypePicklistValue[] { rtPKLList };
                if(pkValues.size()>0){
                    rtList.add(rt);
                }
        }
        List<MetadataService.Metadata> listMeta=new List<MetadataService.Metadata>();
        for(MetadataService.RecordType rt:rtList){
            List<MetadataService.SaveResult> lstResults=service.updateMetadata( new MetadataService.RecordType[]{rt});
            for (MetadataService.SaveResult objResult : lstResults) {
                System.debug(objResult);
                if (objResult.success) {
                    System.debug('Successfully updated');
                }else {                       
                    if(objResult.errors.size() > 0){
                        System.debug('eror : ' + objResult.errors[0].message);
                    }
                }
            }
        }
        
    }
}