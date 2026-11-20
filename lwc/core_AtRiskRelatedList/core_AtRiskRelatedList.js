import { LightningElement,api,track,wire } from 'lwc';
import { gql, graphql,refreshGraphQL } from 'lightning/uiGraphQLApi';
const columns = [
    { label: 'Product',
    fieldName: 'ProductURL',
    type: 'url',
    typeAttributes: { label: { fieldName: 'Product2' }, target: '_blank' },initialWidth: 180},
    { label: 'BU', fieldName: 'Core_BU_Short_Name__c', type: 'string' ,initialWidth: 180},
    { label: 'At Risk', fieldName: 'Core_At_Risk__c', type: 'string' ,initialWidth: 180},
    { label: 'Risk Reason', fieldName: 'Core_Risk_Reason1__c', type: 'string' ,initialWidth: 180},   
    { label: 'Risk Priority', fieldName: 'Core_Risk_Priority__c', type: 'string' ,initialWidth: 180},
    { label: 'Risk Status', fieldName: 'Core_At_Risk_Status__c', type: 'string' ,initialWidth: 180},
    { label: 'Product Risk Owner', fieldName: 'Core_Product_Risk_Owner__c', type: 'string' ,initialWidth: 180},
    { label: 'Risk Detail', fieldName: 'Core_Risk_Detail__c', type: 'string' ,initialWidth: 180},
    { label: 'Risk Create Date', fieldName: 'Core_Risk_Create_Date__c',type: 'date',
                    typeAttributes:{month: "short",day: "numeric",year: "numeric",
                    hour: 'numeric',minute: 'numeric',second: 'numeric',hour12: true},initialWidth: 180},
    { label: 'Risk End Date', fieldName: 'Core_Risk_End_Date__c', type: 'date',
                    typeAttributes:{month: "short",day: "numeric",year: "numeric",
                    hour: 'numeric',minute: 'numeric',second: 'numeric',hour12: true} ,initialWidth: 180},
];
export default class Core_AtRiskRelatedList extends LightningElement {
@api recordId;
  error;
  OpportunityLineItems;
  noData=true;
  columns=columns;
  graphqlData;
  countRiskProds;
  spinner=true;
  errorflag=false;
  connectedCallback() {
      console.log('recordId'+this.recordId);
  }
//Avoiding apex call by using graphQL for fetching OpportunityLineItems Data
@wire(graphql, {
    query: gql`
        query OLI($recordId: ID!) {
            uiapi {
                query {
                    OpportunityLineItem(where: {and:{ OpportunityId: { eq: $recordId, }, Core_At_Risk__c: { eq: true } }},orderBy: { Product2: { Name:  { order: ASC }}}) {
                        edges {
                            node {
                                Id
                                Name {value}
                                Product2Id{value}
                                Core_BU_Short_Name__c{value}
                                Core_At_Risk__c{value}
                                Core_Risk_Reason1__c{value}
                                Core_Risk_Priority__c{value}
                                Core_At_Risk_Status__c{value}
                                Core_Product_Risk_Owner__c{value}
                                Core_Risk_Detail__c{value}
                                Core_Risk_Create_Date__c{value}
                                Core_Risk_End_Date__c{value}
                                    Product2{
                                        Name{value}
                                    }
                            }
                        }
                    }
                }
            }
        }
    `,
    variables: "$variables",
  })
  graphqlQueryResult(result) {
    const { data, errors } = result;
    if(data){
        this.spinner=false;
       
    this.OpportunityLineItems = data.uiapi.query.OpportunityLineItem.edges.map((edge) => ({
                Id: edge.node.Id,
                Product2: edge.node.Product2.Name.value,
                ProductURL: '/'+edge.node.Id,
                Name: edge.node.Name.value, 
                Core_BU_Short_Name__c: edge.node.Core_BU_Short_Name__c.value,
                Core_At_Risk__c: edge.node.Core_At_Risk__c.value,
                Core_Risk_Reason1__c: edge.node.Core_Risk_Reason1__c.value,
                Core_Risk_Priority__c: edge.node.Core_Risk_Priority__c.value,             
                Core_At_Risk_Status__c: edge.node.Core_At_Risk_Status__c.value, 
                Core_Product_Risk_Owner__c: edge.node.Core_Product_Risk_Owner__c.value, 
                Core_Risk_Detail__c: edge.node.Core_Risk_Detail__c.value, 
                Core_Risk_Create_Date__c: edge.node.Core_Risk_Create_Date__c.value, 
                Core_Risk_End_Date__c: edge.node.Core_Risk_End_Date__c.value,              
            })); 

        
           if(this.OpportunityLineItems.length === 0){
                this.noData=true;
           }else{
            this.noData=false;
           }
           this.graphqlData = result;
           this.countRiskProds='('+this.OpportunityLineItems.length+')';
           this.itemCount=this.OpportunityLineItems.length===1? '1 item' : this.OpportunityLineItems.length + ' items';
           if(this.OpportunityLineItems.length === 0){
                this.noData=true;
           }else{
            this.noData=false;

           }
        }
        if (errors) {
            this.spinner=false;
            this.errors = errors;
            this.errorflag=true;
        }
    }

  async refresh() {
    this.spinner=true;
    this.OpportunityLineItems=[];
    return refreshGraphQL(this.graphqlData);
  }

     get variables() {
    return {
      recordId: this.recordId,
    };
  }

}