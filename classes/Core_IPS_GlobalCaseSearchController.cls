/***************************************************************************************************
    Class Name: Core_IPS_GlobalCaseSearchController
    Class Type: Controller 
    Version     : 1.0 
    Created Date: Nov-12-2015
    Function    : This class is used to do  the global search.
    Input Parameters: NA
    Output Parameters: NA
    Description: This class is used to do  the global search. 
    Used in     : Core_IPS_GlobalCaseSearchPage
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani            11/12/2015                 Created
    * Varun Gupta               01/05/2017                 Modified
    ****************************************************************************************************/
Global with sharing class Core_IPS_GlobalCaseSearchController {

    public Core_IPS_Environment_Details__c Environment_Details {
        get;
        set;
    }
    //public Core_IPS_Product_Issue_Category__c Issue_Category {get;set;}    
    //public Attachment attach{get;set;}
    //public Core_IPS_Project__c project{get;set;}
    public
    case caseForSearch {
        get;
        set;
    }
    //public string SelectStatus{get;set;}
    //public datetime CreatingDateFrom{get;set;}
    //public datetime CreatingDateTo{get;set;}
    public Core_IPS_GlobalCaseSearchController(ApexPages.StandardController controller) {
        CaseForSearch = new
        case ();

    }
    /***************************************************************************************************
    Method Name:  getCaseColumnsName
    Method Type: get Method 
    Version     : 1.0 
    Created Date: Nov-12-2015
    Function    : This method get the fields from field-set of case also set  first column as link.
    Input Parameters: None
    Output Parameters: None
    Description: This method is called when case search is in progress. 
    Used in     : GlobelCaseSearchPage
    Modification Log :
                   
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sunil Chandani           11/12/2015                 Created
    ****************************************************************************************************/
    public string getCaseColumnsName() {
        String ColumnList = '';
        integer counter = 0;
        for (Schema.FieldSetMember f: Core_Utility.readFieldSet('Core_IPS_Global_Search_Field_Result', 'Case')) {


        /*    if (counter == 0) {
             //added by PartnerProfile doc
               if(UserInfo.getUserType() == Label.Core_IPS_Partner_Community_User_Type) {
                ColumnList += '{"mDataProp": "' + (string.valueOf(f.getType()).contains('REFERENCE') ? ((f.getFieldPath().indexOF('__c') > -1) ? f.getFieldPath().replace('__c', '__r.Name') : f.getFieldPath().replace('Id', '.Name')) : f.getFieldPath()) + '","sTitle":"' + f.getLabel() + '","defaultContent":"","render": function( oObj,row,set ) {return "<a href=\'/partner/" + set.Id+ "\'>" + set.' + f.getFieldPath() + '+"</a>";}},';   
                    
                } else {
                ColumnList += '{"mDataProp": "' + (string.valueOf(f.getType()).contains('REFERENCE') ? ((f.getFieldPath().indexOF('__c') > -1) ? f.getFieldPath().replace('__c', '__r.Name') : f.getFieldPath().replace('Id', '.Name')) : f.getFieldPath()) + '","sTitle":"' + f.getLabel() + '","defaultContent":"","render": function( oObj,row,set ) {return "<a href=\'/IPS/" + set.Id+ "\'>" + set.' + f.getFieldPath() + '+"</a>";}},';
                }
               // End by PartnerProfile doc
                
            } else {
                ColumnList += '{"mDataProp": "' + (string.valueOf(f.getType()).contains('REFERENCE') ? ((f.getFieldPath().indexOF('__c') > -1) ? f.getFieldPath().replace('__c', '__r.Name') : f.getFieldPath().replace('Id', '.Name')) : f.getFieldPath()) + '","sTitle":"' + f.getLabel() + '","defaultContent":""' + (string.valueOf(f.getType()).contains('DATE') ? ',"render":function(oObj,row,set){ return dtConvFromJSON(set.'+f.getFieldPath() +');}': '') + '},';
            }*/
             if (counter == 0) {
                ColumnList += '{"mDataProp": "' + (string.valueOf(f.getType()).contains('REFERENCE') ? ((f.getFieldPath().indexOF('__c') > -1) ? f.getFieldPath().replace('__c', '__r.Name') : f.getFieldPath().replace('Id', '.Name')) : f.getFieldPath()) + '","sTitle":"' + f.getLabel() + '","defaultContent":"","render": function( oObj,row,set ) {return "<a href=\'/IPS/" + set.Id+ "\'>" + set.' + f.getFieldPath() + '+"</a>";}},';
            } else {
                ColumnList += '{"mDataProp": "' + (string.valueOf(f.getType()).contains('REFERENCE') ? ((f.getFieldPath().indexOF('__c') > -1) ? f.getFieldPath().replace('__c', '__r.Name') : f.getFieldPath().replace('Id', '.Name')) : f.getFieldPath()) + '","sTitle":"' + f.getLabel() + '","defaultContent":""' + (string.valueOf(f.getType()).contains('DATE') ? ',"render":function(oObj,row,set){ return dtConvFromJSON(set.'+f.getFieldPath() +');}': '') + '},';
            }
           
            counter++;
        }
        ColumnList = ColumnList.substring(0, ColumnList.length() - 1);
        //ColumnList += '{"mDataProp": "Id"}';
        return ColumnList;
    }




    @RemoteAction
    // For US60963 by Varun for adding one more parameter for subStatus for fetching cases based on subStatus.//
    global static List <case> getCaseList(String caseSearch, string filterStr,string subStatus) {
        System.debug('subStatus = :' +subStatus);
        string FilterSOQLRTF = '';
        string FilterSOQL = '';
        boolean NoSoslFilter = true;
        Map < id,case >MapCase = new Map < id,case >();
        Map < string, string > MapFilterData = new Map < string, string > ();
        datetime dtCreateFrom = system.now();
        datetime dtCreateTo = system.now();
        if (filterStr != '') {
            MapFilterData = Core_IPS_GlobalCaseSearchController.GetFilterdata(filterStr);

            if (MapFilterData.containsKey('CaseNumber')) {
                //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('CaseNumber') + '*} ';
                FilterSOQL = FilterSOQL + +((FilterSOQL != '') ? ' AND ' : '') + ' CaseNumber like \'%' + MapFilterData.get('CaseNumber') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + +((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.CaseNumber like \'%' + MapFilterData.get('CaseNumber') + '%\'';
            }
            system.debug(MapFilterData.containsKey('CreatingDateFrom') + ' >>>>>>>>>>>>> ' + MapFilterData.containsKey('CreatingDateTo'));
            if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo')) {

                dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                system.debug('dtCreateFrom===' + dtCreateFrom);
                dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);
                system.debug('dtCreateTo===' + dtCreateto);
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom AND createdDate <=:dtCreateto';
                //FilterSOQL = FilterSOQL   +   ((FilterSOQL!='') ? ' AND ': '') + ' createdDate >= convertTimezone(' + MapFilterData.get('CreatingDateFrom') + 'T00:00:00Z' + ') AND createdDate < convertTimezone(' + MapFilterData.get('CreatingDateTo') + 'T23:59:00Z)';

                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >= :dtCreateFrom AND Core_IPS_Case__r.createdDate <=:dtCreateFrom';

                //FilterSOQLRTF = FilterSOQLRTF   +   ((FilterSOQLRTF!='') ? ' AND ': '') + '   Core_IPS_Case__r.createdDate >= convertTimezone(' + MapFilterData.get('CreatingDateFrom') + 'T00:00:00Z' + ') AND Core_IPS_Case__r.createdDate < convertTimezone(' + MapFilterData.get('CreatingDateTo') + 'T23:59:00Z)';

            } else if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo') == false) {
                dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                system.debug('dtCreateFrom===' + dtCreateFrom);

                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom ';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >=:dtCreateFrom ';

            } else if (MapFilterData.containsKey('CreatingDateFrom') == false && MapFilterData.containsKey('CreatingDateTo')) {
                dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);

                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate <=:dtCreateTo ';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate <=:dtCreateTo ';
            }


            if (MapFilterData.containsKey('status')) {
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' status in (' + MapFilterData.get('status') + ')';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.status in (' + MapFilterData.get('status') + ')';

            }
            
            
            if (MapFilterData.containsKey('ProductName')) {
                //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('ProductName')+'*}';
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_IPS_Product__c like \'%' + MapFilterData.get('ProductName') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_IPS_Product__c Like \'%' + MapFilterData.get('ProductName') + '%\'';

            }
            if (MapFilterData.containsKey('Core_Customer_Reference_ID__c')) {
                //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('ProductName')+'*}';
                FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_Customer_Reference_ID__c like \'%' + MapFilterData.get('Core_Customer_Reference_ID__c') + '%\'';
                FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_Customer_Reference_ID__c Like \'%' + MapFilterData.get('Core_Customer_Reference_ID__c') + '%\'';

            }

            if (MapFilterData.size() > 0 && MapFilterData.containsKey('CaseSubject') == false) {
                NoSoslFilter = false;
            }


            //system.debug(FilterSOSL);
        }
        string strfinalFilter = '';

        system.debug(caseSearch);

        if (caseSearch != '') {

            caseSearch = caseSearch.trim();
         //   string caseSearchWithWildCard = Core_Utility.SOSLQueryStringValidator(caseSearch);

            // BUG Introducing '\' charactersmodified line below ** string caseSearch_Ciphertext = Core_Utility.SOSLQueryStringValidator(basicAuthCallout(caseSearch));
       /*Pooja Commented for Skyhigh     
            string caseSearch_Ciphertext = basicAuthCallout(caseSearch);

            system.debug('DEBUG SEARCH TERM CALLOUT : ' + caseSearch_Ciphertext);

            if (caseSearch_Ciphertext != caseSearch) {
                strfinalFilter = caseSearch_Ciphertext;
            } else {*/
                strfinalFilter = caseSearch;
        //    }

            system.debug(strfinalFilter);


        }
        //strfinalFilter =  '{'+ caseSearchWithWildCard  +'} OR {*'+ caseSearchWithWildCard  +'} OR {'+ caseSearchWithWildCard  +'*} OR {*'+ caseSearchWithWildCard  +'*} OR {' + caseSearch_WithWildCard+ '} OR {' + caseSearch_WithWildCard+ '*} OR {*' + caseSearch_WithWildCard+ '} OR {*' + caseSearch_WithWildCard+ '*} OR {*' + caseSearch_Ciphertext_withFooter+ '} OR {' + caseSearch_Ciphertext_withHeader+ '*} OR {' + caseSearch_Ciphertext+ '} ' + FilterSOSL;

        //strfinalFilter =  '{' + caseSearch_WithWildCard+ '} OR {*' + caseSearch_WithWildCard+ '*}  OR {' + caseSearch_Ciphertext+ '} OR {' +caseSearch_Ciphertext.substring(0,4) + '*' + caseSearch_WithWildCard + '*' + caseSearch_Ciphertext.substring(caseSearch_Ciphertext.length()-3,caseSearch_Ciphertext.length()) + '} OR {'+ caseSearchWithWildCard  +'} OR {*'+ caseSearchWithWildCard  +'*} OR {dgdg}' ;

        system.debug('DBUG SEARCH TERM FINAL :' + strfinalFilter);
        //caseSearch = caseSearchWithoutWildCard + '*';
        // caseSearch = '惔膇巊版一';//畵厱超磫一

        Set < string > SetCaseID = new Set < string > ();
        string CaseSOSL = 'Find :strfinalFilter IN ALL FIELDS Returning Case (';
        //string CaseSOSL_WithWildCiphertext  = 'Find :caseSearch_WithWildCard IN ALL FIELDS Returning Case (';
        //string CaseSOSL_With_wild  = 'Find :caseSearchWithWildCard IN ALL FIELDS Returning Case (';
        string CaseSoql = 'Select ';



        for (Schema.FieldSetMember f: Core_Utility.readFieldSet('Core_IPS_Global_Search_Field_Result', 'Case')) {

            system.debug(string.valueOf(f.getLabel()));
            system.debug(string.valueOf(f.getType()));
            system.debug(string.valueOf(f.getFieldPath()));
            if (string.valueOf(f.getType()).equalsIgnoreCase('REFERENCE')) {
                system.debug(string.valueOf(f.getType()).equalsIgnoreCase('REFERENCE'));
                if (f.getFieldPath().indexOF('__c') > -1) {
                    system.debug(f.getFieldPath().indexOF('__c'));
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
            //CaseSOSL_With_wild += f.getFieldPath() + ',';
            // CaseSOSL_WithWildCiphertext += f.getFieldPath() + ',';
        }

        CaseSOSL += 'id';
        CaseSOQL += 'id';
        //CaseSOSL_With_wild += 'id';
        // CaseSOSL_WithWildCiphertext += 'id';
         FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_IPS_Customer_Visible__c = '+true;
       
        CaseSOSL += (FilterSOQL != '' ? (' Where ' + FilterSOQL) : '') + ' order by LastModifiedDate desc LIMIT 1000 ),Core_IPS_Case_Comments__c(id,Core_IPS_Case__c ' + (FilterSOQLRTF != '' ? (' Where ' + FilterSOQLRTF) : '') + ' order by LastModifiedDate desc Limit 1000)';

        //CaseSOSL_With_wild += (FilterSOSL!='' ? (' Where ' + FilterSOSL ): '') + ' order by LastModifiedDate desc LIMIT 2000)';
        //CaseSOSL_WithWildCiphertext += (FilterSOSL!='' ? (' Where ' + FilterSOSL ): '') + ' order by LastModifiedDate desc LIMIT 2000)';
        system.debug(CaseSOSL);
        List < List < SObject >> LstCase = new List < List < SObject >> ();
        if (strfinalFilter != '' && NoSoslFilter) {
            LstCase = search.query(CaseSOSL);
        }
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
            // if(LstCase.size() >1)
            // for(sobject c : LstCase[1])
            // {
            // Core_IPS_Case_Comments__c CaseComment =  (Core_IPS_Case_Comments__c)c;
            // case caseFromComment =  new case(CaseComment.Core_IPS_Case__c);
            // }
        }

        /* LstCase = search.query(CaseSOSL_With_wild); 
          if(LstCase.size() >0)
         {
             for(sobject c : LstCase[0])
             {
              MapCase.put(c.id,(case)c);
             }
         } 
         LstCase = search.query(CaseSOSL_WithWildCiphertext); 
          if(LstCase.size() >0)
        {
             for(sobject c : LstCase[0])
             {
              MapCase.put(c.id,(case)c);
             }
         } 
         
          List<List <sObject>> LstEnvironment_Details =  [Find : caseSearch IN ALL FIELDS Returning Core_IPS_Environment_Details__c(ID,Core_Case__c order by LastModifiedDate desc LIMIT 2000)];
         if(LstEnvironment_Details.size() > 0 )
         {
            for(Sobject ED:LstEnvironment_Details[0])
            {
              Core_IPS_Environment_Details__c ED1 =  (Core_IPS_Environment_Details__c)ED;
              SetCaseID.add(ED1.Core_Case__c);
            }
         } 
         //string CaseSoql1 = CaseSoql + ' from case where subject like  \'%:Puerto%\' ';*/

        //system.debug(database.query(CaseSoql1));
        system.debug(FilterSOQL != '' + '&&' + (SetCaseId.size() > 0));
        if (FilterSOQL != '' && SetCaseId.size() > 0 && NoSoslFilter == false) {
            FilterSOQL += ' OR id in:SetCaseId ';
        } else if (SetCaseId.size() > 0) {
            FilterSOQL = ' iD in:SetCaseId ';
        }

        CaseSoql += ' from case ' + (FilterSOQL != '' ? ' Where ' + FilterSOQL : '') + ' order by LastModifiedDate desc LIMIT 3000';
        System.debug(CaseSoql);
        
    // added by Varun below logic for US60963 :- To filter substatus values and add in existing case SOQL query.//////
        if(subStatus!='' ){
            subStatus=subStatus.subString(0,subStatus.length()-1);
            System.debug(subStatus);

            List<String> queryStringList=CaseSoql.split('order by LastModifiedDate desc LIMIT');
            System.debug(subStatus);

            List<String> subStatusFilter=subStatus.split(',');
            System.debug('subStatusFilter.size()' +subStatusFilter.size());
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
            system.debug(tempquery);
            CaseSoql=tempquery;
        }
    ////// End logic US60963 /////
        
        if (SetCaseId.size() > 0 || NoSoslFilter == false) {
            for (Case c: database.query(CaseSoql)) {
                //LstCase[0].add(c);
                MapCase.put(c.id, c);
            }
        }

        return MapCase.values();
    }




    public static map < string, string > GetFilterdata(string filterStr) {
        Map < string, string > MapFilterData = new Map < string, string > ();
        List < string > LstFilter = filterStr.split('#%#');

        for (string str: LstFilter) {
            List < string > lstFilter1 = str.split('=');
            
                if (lstFilter1[1] != null && lstFilter1[1] != '') {
                    MapFilterData.put(lstFilter1[0], lstFilter1[1]);
                }
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>' + MapFilterData);
        }
        return MapFilterData;
    }
   /* public static string basicAuthCallout(string str_Search) {
        try {
            HttpRequest req = new HttpRequest();

                string certName = Label.EAASCertificate_Name;
                // As well as the header and header information 
                Map < String, object > mapEmp = new Map < String, object > ();
                //mapEmp.put('plaintext',str_Search); 
                mapEmp.put('query', str_Search);
                //mapEmp.put('algo','LineFPEEngine');
                System.debug('DEBUG SEARCH String:' + str_Search);

                String JSONString = JSON.serialize(mapEmp);

                System.debug('DEBUG SEARCH JSON String:' + JSONString); 
                req.setBody(JSONString);
                //req.setHeader('Content-Type', 'application/json; charset=utf-8');
                req.setHeader('Content-Type', 'application/json'); 
                req.setEndpoint(Label.EAAS_EndPoint_URL); 
                req.setMethod('POST');
                if (certName != null) {
                    req.setClientCertificateName(certName);
                }


                // Create a new http object to send the request object 

                // A response object is generated as a result of the request   


                Http http = new Http(); 
                HTTPResponse res = http.send(req); 
                System.debug('DEBUG SEARCH res.getBody : ' + res.getBody()); 
                string ciphertext = Core_IPS_fromJSON.Parse(res.getBody()).query;
                System.debug('DEBUG SEARCH res.getBody ciphertext: ' + ciphertext); 


               //ciphertext = null;Using this for testing without Sky high API 
                return ciphertext;
            System.debug('RAZZ'+ciphertext);
               
            }
            catch (exception e) {
                system.debug(e);
                return str_Search;
            }
        }*/

    }