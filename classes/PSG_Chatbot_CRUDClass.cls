/*********************************************************************************************************************
Class Name    : PSG_Chatbot_CRUDClass
Version       : 1.0
Created Date  : 5 Dec 2022

Modification Log :
* Developer                 Date                    Description
* ---------------------------------------------------------------------------------------------------------
* Ranjit Kumar      5-12-2022                  Used to Perform CRUD operation on Quote/QL/DPA&ALN/DPA&ALN Lines.
* *********************************************************************************************************************/

Global class PSG_Chatbot_CRUDClass {
    
    Global class input 
    {
         @InvocableVariable
        Public string Quote;
         @InvocableVariable
        Public string Operation;
        @InvocableVariable
        public SBQQ__QuoteLine__c QuoteLine;
        @InvocableVariable
        public String Active;
        @InvocableVariable
        public String RequestType;
        @InvocableVariable
        public String Objectname;
        @InvocableVariable
        public String Fieldname;
        @InvocableVariable
        public String Userid;
        @InvocableVariable
        Public string DPA;
        @InvocableVariable
        public core_cpq_dpa_aln_line__c DPAlines;
        @InvocableVariable
        public double RequestedResale;
        @InvocableVariable
        public integer EAU;
        @InvocableVariable
        public integer RequestedQty;
        @InvocableVariable
        public double DistyMargin;
        @InvocableVariable
        public Date ShipEndDate;
    } 
    Global class output{
        @InvocableVariable
        public string RequestNumber;
    }
    
    @InvocableMethod(label='Create Portal Request')
    public static List<output> getDetails(List<input> input1)
    {
        string Quote=input1.get(0).Quote;
        string Operation=input1.get(0).Operation;
        string fieldname=input1.get(0).Fieldname;
        string Objectname=input1.get(0).Objectname;
        string RequestType=input1.get(0).RequestType;
        string Active=input1.get(0).Active;
        string Ql='';
        string Userid=input1.get(0).Userid;
        string dpa=input1.get(0).DPA;
        string dpalines='';
        double RequestedResale=input1.get(0).RequestedResale;
        Integer EAU=input1.get(0).EAU;
        Integer RequestedQty=input1.get(0).RequestedQty;
        double DistyMargin=input1.get(0).DistyMargin;
        Date ShipEndDate=input1.get(0).ShipEndDate;
        output loutput = new output();
        List<output> requestoutput = new list<output>();
        for(input inp:input1){
              Ql=inp.QuoteLine.Name;
              dpalines=inp.DPAlines.Name;
        }
        if(Operation=='QuoteLine')
        {
            if(fieldname=='price_requested_resale_amt__c'){
                 SBQQ__QuoteLine__c QLlist=[select id,SBQQ__Quote__r.OwnerId from SBQQ__QuoteLine__c where Name=:Ql and core_cpq_quote_number__c=:Quote];
                 string requestedresalepr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,String.valueOf(Decimal.valueOf(RequestedResale).setScale(2)),QLlist.SBQQ__Quote__r.OwnerId,QLlist.id,Userid,Ql,'Currency');
                 loutput.RequestNumber=requestedresalepr;
                 requestoutput.add(loutput);
                
            }else if(fieldname=='SBQQ__Quantity__c'){
                SBQQ__QuoteLine__c QLlist=[select id,SBQQ__Quote__r.OwnerId from SBQQ__QuoteLine__c where Name=:Ql and core_cpq_quote_number__c=:Quote];
                string quantitypr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,String.valueOf(EAU),QLlist.SBQQ__Quote__r.OwnerId,QLlist.id,Userid,Ql,' Double');
                loutput.RequestNumber=quantitypr;
                requestoutput.add(loutput);
            } 
            
        }else if(Operation=='Quote'){
            
            if(fieldname=='core_cpq_active_cb__c'){
                SBQQ__Quote__c Quotelist=[select id,OwnerId from SBQQ__Quote__c where Name=:Quote];
                 string activepr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,Active,Quotelist.OwnerId,Quotelist.id,Userid,Quote,'Boolean');
                 loutput.RequestNumber=activepr;
                 requestoutput.add(loutput);
            }
        }else if(Operation=='DPA & ALN Line'){
            
            if(fieldname=='core_cpq_requested_qty_nbr__c'){
                core_cpq_dpa_aln_line__c lineslist=[select id,core_cpq_cis_no_nbr__r.OwnerId from core_cpq_dpa_aln_line__c where Name=:dpalines and (core_cpq_DPA_ALN_Number__c=:dpa or core_cpq_sap_number__c=:dpa)];
                string requestedqtypr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,String.valueOf(RequestedQty),lineslist.core_cpq_cis_no_nbr__r.OwnerId,lineslist.id,Userid,dpalines,'Double');
                loutput.RequestNumber=requestedqtypr;
                requestoutput.add(loutput);
            }else if(fieldname=='core_cpq_disty_margin_pct__c'){
                core_cpq_dpa_aln_line__c lineslist=[select id,core_cpq_cis_no_nbr__r.OwnerId from core_cpq_dpa_aln_line__c where Name=:dpalines and (core_cpq_DPA_ALN_Number__c=:dpa or core_cpq_sap_number__c=:dpa)];
                string distymarginpr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,String.valueOf(Decimal.valueOf(DistyMargin).setScale(2)),lineslist.core_cpq_cis_no_nbr__r.OwnerId,lineslist.id,Userid,dpalines,'Percent');
                loutput.RequestNumber=distymarginpr;
                requestoutput.add(loutput);
            }
        }else if(Operation=='DPA & ALN'){
            if(fieldname=='core_cpq_ship_end_date_dt__c'){
                 
                core_cpq_dpa_aln__c DPAlist=[select id,OwnerId from core_cpq_dpa_aln__c where Name=:dpa or core_cpq_dpa_aln_no_nbr__c=:dpa];
                string enddatepr=PSG_Chatbot_CRUDClass.CreatePortalRequest(fieldname,Objectname,RequestType,ShipEndDate.format(),DPAlist.OwnerId,DPAlist.id,Userid,dpa,'Date');
                loutput.RequestNumber=enddatepr;
                requestoutput.add(loutput);
            }
                
        }
       return requestoutput;
    }
    
    
    public static string CreatePortalRequest(string fieldname,string Objectname,string RequestType,string RequestedFieldValue,string owner,string recordid,string userid,string recordnumber,string FieldType)
        {
            Id delegateapprover=[select id,DelegatedApproverId from user where id=:string.escapeSingleQuotes(owner)]?.DelegatedApproverId;
           
                    core_cpq_portalrequest__c PortalRequest = new core_cpq_portalrequest__c(core_cpq_bot_field_name__c=fieldname,
                                                                                core_cpq_bot_Object_Name__c=Objectname,
                                                                                core_cpq_Status__c='Pending',
                                                                                core_cpq_request_type__c=RequestType,
                                                                               core_cpq_value__c=RequestedFieldValue,
                                                                               core_cpq_record_Id__c=recordid,
                                                                               core_cpq_Requested_By__c=Userid,
                                                                               OwnerId=owner,             
                                                                               core_cpq_record_number__c=recordnumber,
                                                                               core_cpq_Field_Type__c=FieldType,
                                                                               core_cpq_delegate_approver__c=delegateapprover);
                try{                                                               
                 insert PortalRequest;
               }catch(DmlException e) {
                  System.debug('The following exception has occurred: ' + e.getMessage());
                }
            
            return [select Name from core_cpq_portalrequest__c where id=:PortalRequest.Id]?.Name;
            
        }
    
      global Id Requestid {get;set;}
    Global core_cpq_portalrequest__c Requestlist{
        
        get{
            List<core_cpq_portalrequest__c> PRlist = [select id,Name,toLabel(core_cpq_bot_Object_Name__c),toLabel(core_cpq_bot_field_name__c),core_cpq_Field_Type__c,core_cpq_Record__c,core_cpq_record_number__c,core_cpq_record_Id__c,core_cpq_request_type__c,core_cpq_Requested_By__r.name,core_cpq_value__c
                                       from core_cpq_portalrequest__c where Id = :Requestid LIMIT 1];
            return !PRlist.isEmpty()?PRlist[0]:null;
        }
        set;
    }

}