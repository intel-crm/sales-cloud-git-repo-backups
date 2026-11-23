Global with sharing class Core_IPS_CaseAdvanceSearch_CTRL    {
    
    
    public Core_IPS_Product_Issue_Category__c Issue_Category {get;set;}    
    public Attachment attach{get;set;}
    public Core_IPS_Project__c project{get;set;}
    public case caseForSearch {
        get;
        set;
    }
    public string SelectStatus{get;set;}
    public datetime CreatingDateFrom{get;set;}
    public datetime CreatingDateTo{get;set;}
    public Core_IPS_CaseAdvanceSearch_CTRL   (ApexPages.StandardController controller) {
        CaseForSearch = new case ();
        
    }
    
    @AuraEnabled(cacheable=true)
    global static List <case> getCaseList(String caseSearch, string filterStr,string subStatus) {
        String prodId = caseSearch;
        //FLS fix added by Nagendra on 14-10-2022
        filterStr = String.escapeSingleQuotes(filterStr);
        subStatus = String.escapeSingleQuotes(subStatus);
        String prodId1 = filterStr;
        string FilterSOQLRTF = '';
        string FilterSOQL = '';
        boolean NoSoslFilter = true;
        Map < id,case >MapCase = new Map < id,case >();
        Map < string, string > MapFilterData = new Map < string, string > ();
        datetime dtCreateFrom = system.now();
        datetime dtCreateTo = system.now();
        if (prodId1 != '') {
            MapFilterData = Core_IPS_CaseAdvanceSearch_CTRL.GetFilterdata(prodId1);
            if (MapFilterData.containsKey('CaseNumber')) {
                FilterSOQL = FilterSOQL + +((FilterSOQL != '') ? ' AND ' : '') + ' CaseNumber like \'%' + MapFilterData.get('CaseNumber') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + +((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.CaseNumber like \'%' + MapFilterData.get('CaseNumber') + '%\'';
            }
            
            if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo')) {
                dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                
                dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);
                
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom AND createdDate <=:dtCreateto';
                
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >= :dtCreateFrom AND Core_IPS_Case__r.createdDate <=:dtCreateFrom';
                
            } else if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo') == false) {
                dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom ';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >=:dtCreateFrom ';
                
            } else if (MapFilterData.containsKey('CreatingDateFrom') == false && MapFilterData.containsKey('CreatingDateTo')) {
                dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate <=:dtCreateTo ';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate <=:dtCreateTo ';
            }
            
            if (MapFilterData.containsKey('Status')) {
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' status in (' + MapFilterData.get('Status') + ')';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.status in (' + MapFilterData.get('status') + ')';
            }
            
            if (MapFilterData.containsKey('ProductName')) {
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_IPS_Product__c like \'%' + MapFilterData.get('ProductName') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_IPS_Product__c Like \'%' + MapFilterData.get('ProductName') + '%\'';
                
            }
            if (MapFilterData.containsKey('Core_Customer_Reference_ID__c')) {
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_Customer_Reference_ID__c like \'%' + MapFilterData.get('Core_Customer_Reference_ID__c') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_Customer_Reference_ID__c Like \'%' + MapFilterData.get('Core_Customer_Reference_ID__c') + '%\'';
                
            }
            
            if (MapFilterData.size() > 0 && MapFilterData.containsKey('CaseSubject') == false) {
                NoSoslFilter = false;
            }
        }
        string strfinalFilter = '';
        if (prodId != '') {
            prodId = prodId.trim();
            strfinalFilter = prodId;
        }
        
        Set < string > SetCaseID = new Set < string > ();
        string CaseSOSL = 'Find :strfinalFilter IN ALL FIELDS Returning Case (';
        string CaseSoql = 'Select ';
        for (Schema.FieldSetMember f: Core_Utility.readFieldSet('Core_IPS_Global_Search_Field_Result', 'Case')) {
            if (string.valueOf(f.getType()).equalsIgnoreCase('REFERENCE')) {
                if (f.getFieldPath().indexOF('__c') > -1) {
                    CaseSoql += f.getFieldPath().replace('__c', '__r.Name') + ',';
                    CaseSOSL += f.getFieldPath().replace('__c', '__r.Name') + ',';
                } else {
                    CaseSoql += f.getFieldPath().replace('Id', '.Name') + ',';
                    CaseSOSL += f.getFieldPath().replace('Id', '.Name') + ',';
                }
                
            } else {
                CaseSoql += f.getFieldPath() + ',';
                CaseSOSL += f.getFieldPath() + ',';
            }
            
        }
        CaseSOSL += 'id';
        CaseSOQL += 'id';
        
        FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_IPS_Customer_Visible__c = '+true; 
        CaseSOSL += (FilterSOQL != '' ? (' Where ' + FilterSOQL) : '') + ' order by LastModifiedDate desc LIMIT 1000 ),Core_IPS_Case_Comments__c(id,Core_IPS_Case__c ' + (FilterSOQLRTF != '' ? (' Where ' + FilterSOQLRTF) : '') + ' order by LastModifiedDate desc Limit 1000)';
        List < List < SObject >> LstCase = new List < List < SObject >> ();
        system.debug('NoSoslFilter'+NoSoslFilter);
        system.debug('strfinalFilter'+strfinalFilter);
        system.debug('CaseSOSL'+CaseSOSL);
        //system.debug('test'+search.Query(CaseSOSL));
        if (strfinalFilter != '' && NoSoslFilter) {
            LstCase = search.query(CaseSOSL);
        }
        system.debug('LstCase'+LstCase);
        if (LstCase.size() > 0) {
            integer counter = 0;
            for (List < sobject > lst: LstCase) {
                if (counter == 0) {
                    for (sobject c: lst) {
                        MapCase.put(c.id, (case) c);
                    }
                }
                if (counter == 1) {
                    for (sobject c: lst) {
                        Core_IPS_Case_Comments__c caseComm = (Core_IPS_Case_Comments__c) c;
                        SetCaseId.add(string.valueof(caseComm.Core_IPS_Case__c));
                    }
                }
                counter++;
            }
            
        }
        if (FilterSOQL != '' && SetCaseId.size() > 0 && NoSoslFilter == false) {
            FilterSOQL += ' OR id in:SetCaseId ';
        } else if (SetCaseId.size() > 0) {
            FilterSOQL = ' iD in:SetCaseId ';
        }
        CaseSoql += ' from case ' + (FilterSOQL != '' ? ' Where ' + FilterSOQL : '') + ' order by LastModifiedDate desc LIMIT 3000';
        if(subStatus!='' ){
            subStatus=subStatus.subString(0,subStatus.length()-1);
            List<String> queryStringList=CaseSoql.split('order by LastModifiedDate desc LIMIT');
            List<String> subStatusFilter=subStatus.split(',');
            String tempquery='';
            tempquery=queryStringList[0]+' AND ( ' ;
            for(Integer i=0 ;i< subStatusFilter.size();i++){
                if(subStatusFilter.get(i)!='' || subStatusFilter.get(i)!=null){
                    if((i==0 && i== subStatusFilter.size()-1) || i== subStatusFilter.size()-1){
                        tempquery=tempquery+' Core_Sub_Status__c =\''+subStatusFilter.get(i)+'\')';
                        break;
                    }
                    else{
                        tempquery=tempquery+' Core_Sub_Status__c =\''+subStatusFilter.get(i)+'\'' +' Or ';
                    }
                }
            }         
            tempquery=tempquery+' order by LastModifiedDate desc LIMIT '+queryStringList[1];
            CaseSoql=tempquery;
        }
        if (SetCaseId.size() > 0 || NoSoslFilter == false) {
            for (Case c: database.query(CaseSoql)) {
                MapCase.put(c.id, c);
            }
        }
        return MapCase.values();
    }
    
    public static map < string, string > GetFilterdata(string prodId1) {
    //FLS fix added by Nagendra on 14-10-2022
        prodId1=prodId1.replace('\\\'New\\\'','\'New\'');
        prodId1=prodId1.replace('\\\'Open\\\'','\'Open\'');
        prodId1=prodId1.replace('\\\'Closed\\\'','\'Closed\'');
        Map < string, string > MapFilterData = new Map < string, string > ();
        List < string > LstFilter = prodId1.split('#%#');
        for (string str: LstFilter) {
            List < string > lstFilter1 = str.split('=');
            if (lstFilter1[1] != null && lstFilter1[1] != '') {
                MapFilterData.put(lstFilter1[0], lstFilter1[1]);
            }
        }
        return MapFilterData;
    }
}