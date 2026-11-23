public  without sharing class Mocktrail_PSG {
    public static  void  getDPALines(Id recordId){
       List<core_cpq_dpa_aln_line__c> dpalinelist= DPALine_selector.newInstance().selectDPAById(recordId);
        System.debug('ANS@@@@'+dpalinelist);
        List<core_cpq_dpa_aln_line__c> dpalinelisttoUpdated=new List<core_cpq_dpa_aln_line__c>();
        for(core_cpq_dpa_aln_line__c lineList:dpalinelist){
            lineList.core_cpq_comments_txt__c='InUpdation';
            lineList.core_cpq_requested_qty_nbr__c=12;
            dpalinelisttoUpdated.add(lineList);
        }
        if(!dpalinelisttoUpdated.isEmpty()){
            update dpalinelisttoUpdated;
            System.debug('In Update');
        }
    }
}