/* eslint-disable no-unused-vars */
/* eslint-disable eqeqeq */
/* eslint-disable no-alert */
import { LightningElement, track, wire} from 'lwc';
//import Details from '@salesforce/apex/fetchProducts.Details';
export default class IpaProductCard extends LightningElement {
    products;
    newProductDetails = [];
    ProdDetail = [{
                    id:1,
                   Name: 'Avnet Embedded',
                   Description: 'Avnet enbedded builds embedded compute, display and software testing',
                   ProductCode: 'Titanium Partner',
                   StockKeepingUnit: 'Original Equipment Manifacture (OEM)',
                   DisplayUrl: 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'
    },
{
    id:2,
    Name: 'Avnet Embedded',
                   Description: 'Avnet enbedded builds embedded compute, display and software testing',
                   ProductCode: 'Titanium Partner',
                   StockKeepingUnit: 'Original Equipment Manifacture (OEM)',
                   DisplayUrl: 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'
},
{
    id:3,
    Name: 'Avnet Embedded',
                   Description: 'Avnet enbedded builds',
                   ProductCode: 'Titanium Partner',
                   StockKeepingUnit: 'Original Equipment Manifacture (OEM)',
                   DisplayUrl: 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'
},
{
    id:4,
    Name: 'Avnet Embedded',
                   Description: 'Avnet enbedded builds embedded compute, display and software testing',
                   ProductCode: 'Titanium Partner',
                   StockKeepingUnit: 'Original Equipment Manifacture (OEM)',
                   DisplayUrl: 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'
},
{
    id:5,
    Name: 'Avnet Embedded',
                   Description: 'Avnet enbedded builds embedded compute, display and software testing',
                   ProductCode: 'Titanium Partner',
                   StockKeepingUnit: 'Original Equipment Manifacture (OEM)',
                   DisplayUrl: 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'
}
];

// @wire(Details)
// wireRecord({data}){
//     if(data){
// this.products = data;
// alert("hello");
// alert(data);
// alert(JSON.stringify(this.products));
// alert(this.products.length);
// alert(JSON.stringify(this.products[0]));
// // alert(this.products.shift());
// // alert(this.products.length);

// //alert(JSON.stringify(products).length);
// if(this.products.length > 4){
//     // for (let i = 0; i < 4; i++) {
//       this.newProductDetails.push(JSON.parse(JSON.stringify(this.products[0])));
//       this.newProductDetails.push(JSON.parse(JSON.stringify(this.products[1])));
//     // }  
//    }
   
//    alert(this.newProductDetails);
//     }
// }

connectedCallback(){
    if(this.ProdDetail.length > 4){
        for (let i = 0; i < 4; i++) {
          this.newProductDetails.push(this.ProdDetail.shift());
          
         }  
         alert(this.newProductDetails);
         alert(this.newProductDetails.length);
         alert(this.ProdDetail.length);
         alert(this.ProdDetail);
       }
}





handleProductList(){
    alert('shiva');

if(this.ProdDetail.length != 0){
    alert("hello");
    this.newProductDetails = [];
    this.newProductDetails.push(this.ProdDetail.shift());
}
 }


}