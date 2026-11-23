Global with sharing class core_IPS_GlobalCaseSearchCTRL_LWC {
   
     


    public Core_IPS_Environment_Details__c environment_Details {
          get;
          set;
      }
      //public Core_IPS_Product_Issue_Category__c Issue_Category {get;set;}    
      //public Attachment attach{get;set;}
      //public Core_IPS_Project__c project{get;set;}
      
      public case caseForSearch {
          get;
          set;
      }
      //public string SelectStatus{get;set;}
      //public datetime CreatingDateFrom{get;set;}
      //public datetime CreatingDateTo{get;set;}
      public core_IPS_GlobalCaseSearchCTRL_LWC(ApexPages.StandardController controller) {
          CaseForSearch = new
          case ();
  
      }
     
      public string getCaseColumnsName() {
          String columnList = '';
          integer counter = 0;
          for (Schema.FieldSetMember f: Core_Utility.readFieldSet('Core_IPS_Global_Search_Field_Result', 'Case')) {
  
  
         
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
  
  
  
  
      @AuraEnabled(cacheable=true)
      // For US60963 by Varun for adding one more parameter for subStatus for fetching cases based on subStatus.//
      global static List <case> getCaseList(String caseSearch, string filterStrEsc,string subStatusEsc) {
        	system.debug('filterStrEsc---'+filterStrEsc);
          /*US1038991 - 09/07/2021 - Karthik - security vulnerability --*/
          string filterStr;
          filterStr = String.escapeSingleQuotes(filterStrEsc);   //00213823=====
        	system.debug('filterStr after removin quootes---'+filterStr);
          /*US1038991 - 09/07/2021 - Karthik - security vulnerability --*/
          string subStatus;
          subStatus = String.escapeSingleQuotes(subStatusEsc); 
     
          string filterSOQLRTF = '';
          string filterSOQL = '';
          boolean noSoslFilter = true;
          Map < id,case >mapCase = new Map < id,case >();
          Map < string, string > mapFilterData = new Map < string, string > ();
          datetime dtCreateFrom = system.now();
          datetime dtCreateTo = system.now();
          if (filterStr != '') {
              MapFilterData = core_IPS_GlobalCaseSearchCTRL_LWC.GetFilterdata(filterStr);
      			system.debug('MapFilterData---'+MapFilterData);
              if (MapFilterData.containsKey('CaseNumber')) {
                  //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('CaseNumber') + '*} ';
                  FilterSOQL = FilterSOQL + +((FilterSOQL != '') ? ' AND ' : '') + ' CaseNumber like \'%' + string.escapeSingleQuotes(MapFilterData.get('CaseNumber')) + '%\'';
                  FilterSOQLRTF = FilterSOQLRTF + +((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.CaseNumber like \'%' + string.escapeSingleQuotes( MapFilterData.get('CaseNumber')) + '%\'';
              }
            
              if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo')) {
  
                  dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                
                  dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);
               
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom AND createdDate <=:dtCreateto';
                  //FilterSOQL = FilterSOQL   +   ((FilterSOQL!='') ? ' AND ': '') + ' createdDate >= convertTimezone(' + MapFilterData.get('CreatingDateFrom') + 'T00:00:00Z' + ') AND createdDate < convertTimezone(' + MapFilterData.get('CreatingDateTo') + 'T23:59:00Z)';
  
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >= :dtCreateFrom AND Core_IPS_Case__r.createdDate <=:dtCreateFrom';
  
                  //FilterSOQLRTF = FilterSOQLRTF   +   ((FilterSOQLRTF!='') ? ' AND ': '') + '   Core_IPS_Case__r.createdDate >= convertTimezone(' + MapFilterData.get('CreatingDateFrom') + 'T00:00:00Z' + ') AND Core_IPS_Case__r.createdDate < convertTimezone(' + MapFilterData.get('CreatingDateTo') + 'T23:59:00Z)';
  
              } else if (MapFilterData.containsKey('CreatingDateFrom') && MapFilterData.containsKey('CreatingDateTo') == false) {
                  dtCreateFrom = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateFrom').split('-')[2]), 0, 0, 0);
                 
  
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate >=:dtCreateFrom ';
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate >=:dtCreateFrom ';
  
              } else if (MapFilterData.containsKey('CreatingDateFrom') == false && MapFilterData.containsKey('CreatingDateTo')) {
                  dtCreateTo = datetime.newInstance(integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[0]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[1]), integer.valueOF(MapFilterData.get('CreatingDateTo').split('-')[2]), 23, 59, 0);
  
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' createdDate <=:dtCreateTo ';
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.createdDate <=:dtCreateTo ';
              }
  
  
              if (MapFilterData.containsKey('status')) {
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' status in (' + MapFilterData.get('status') + ')';
                  //FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' status in (' + string.escapeSingleQuotes(MapFilterData.get('status')) + ')';
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.status in (' + string.escapeSingleQuotes(MapFilterData.get('status')) + ')';
  
              }
              
              
              if (MapFilterData.containsKey('ProductName')) {
                  //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('ProductName')+'*}';
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_IPS_Product__c like \'%' + string.escapeSingleQuotes(MapFilterData.get('ProductName')) + '%\'';
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_IPS_Product__c Like \'%' + string.escapeSingleQuotes(MapFilterData.get('ProductName')) + '%\'';
  
              }
              if (MapFilterData.containsKey('Core_Customer_Reference_ID__c')) {
                  //FilterSOSL = FilterSOSL  + 'OR {' + MapFilterData.get('ProductName')+'*}';
                  //FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_Customer_Reference_ID__c like \'%' + string.escapeSingleQuotes(MapFilterData.get('Core_Customer_Reference_ID__c')) + '%\'';
                  FilterSOQL = FilterSOQL + ((FilterSOQL != '') ? ' AND ' : '') + ' Core_Customer_Reference_ID__c like \'%' + MapFilterData.get('Core_Customer_Reference_ID__c') + '%\'';
                  FilterSOQLRTF = FilterSOQLRTF + ((FilterSOQLRTF != '') ? ' AND ' : '') + ' Core_IPS_Case__r.Core_Customer_Reference_ID__c Like \'%' + string.escapeSingleQuotes(MapFilterData.get('Core_Customer_Reference_ID__c')) + '%\'';
  
              }
  
              if (MapFilterData.size() > 0 && MapFilterData.containsKey('CaseSubject') == false) {
              NoSoslFilter = false;
              }
  
  
           
          }
          string strfinalFilter = '';
  
         
          if (caseSearch != '') {
  
              caseSearch = caseSearch.trim();
           
                  strfinalFilter = caseSearch;
          
           
  
  
          }
         
          Set < string > setCaseID = new Set < string > ();
          string caseSOSL = 'Find :strfinalFilter IN ALL FIELDS Returning Case (';
          //string CaseSOSL_WithWildCiphertext  = 'Find :caseSearch_WithWildCard IN ALL FIELDS Returning Case (';
          //string CaseSOSL_With_wild  = 'Find :caseSearchWithWildCard IN ALL FIELDS Returning Case (';
          string caseSoql = 'Select ';
  
  
  
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
         
          List < List < SObject >> lstCase = new List < List < SObject >> ();
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
             
          }
  
           
         
          if (FilterSOQL != '' && SetCaseId.size() > 0 && NoSoslFilter == false) {
              FilterSOQL += ' OR id in:SetCaseId ';
          } else if (SetCaseId.size() > 0) {
             FilterSOQL = ' iD in:SetCaseId ';
          }
  
          CaseSoql += ' from case ' + (FilterSOQL != '' ? ' Where ' + FilterSOQL : '') + ' order by LastModifiedDate desc LIMIT 3000';
         
          
      // added by Varun below logic for US60963 :- To filter substatus values and add in existing case SOQL query.//////
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
      ////// End logic US60963 /////
          
          if (SetCaseId.size() > 0 || NoSoslFilter == false) {
              for (Case c: database.query(CaseSoql)) {
                  //LstCase[0].add(c);
                  MapCase.put(c.id, c);
              }
          }
  
          return MapCase.values();
      }
  
  
  
  
      public static map < string, string > getFilterdata(string filterStr) {
          Map < string, string > mapFilterData = new Map < string, string > ();
          List < string > lstFilter = filterStr.split('#%#');
  			system.debug('Anil lstFilter--'+lstFilter);
          for (string str: LstFilter) {
              List < string > lstFilter1 = str.split('=');
              
                  if (lstFilter1[1] != null && lstFilter1[1] != '') {
                      MapFilterData.put(lstFilter1[0], lstFilter1[1]);
                  }
              
          }
          return MapFilterData;
      }
    
      

    }